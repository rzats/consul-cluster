#!/bin/bash

set -x
exec > /var/log/user-data.log 2>&1

ASG_NAME="${asgname}"
REGION="${region}"
EXPECTED_SIZE="${size}"

sudo yum update -y
sudo yum install -y awslogs

# Create config files for awslogs.
cat <<- EOF | sudo tee /etc/awslogs/awscli.conf
[plugins]
cwlogs = cwlogs
[default]
region = ${region}
EOF

cat <<- EOF | sudo tee /etc/awslogs/config/user-data.conf
	[/var/log/user-data.log]
	file = /var/log/user-data.log
	log_group_name = /var/log/user-data.log
	log_stream_name = {instance_id}
EOF

cat <<- EOF | sudo tee /etc/awslogs/config/docker.conf
	[/var/log/docker]
	file = /var/log/docker
	log_group_name = /var/log/docker
	log_stream_name = {instance_id}
	datetime_format = %Y-%m-%dT%H:%M:%S.%f
EOF

# Start the awslogs service and set to restart on reboot.
sudo service awslogs start
sudo chkconfig awslogs on

# Install Docker, add ec2-user, start Docker and set to restart on reboot.
yum install -y docker
usermod -a -G docker ec2-user
service docker start
chkconfig docker on

# TODO: all of this should be replaced by Consul's new EC2 discovery feature.

# Return the id of each instance in the cluster.
function cluster-instance-ids {
    aws --region="$REGION" autoscaling describe-auto-scaling-groups --auto-scaling-group-name $ASG_NAME \
        | grep InstanceId \
        | cut -d '"' -f4
}

# Return the private IP of each instance in the cluster.
function cluster-ips {
    for id in $(cluster-instance-ids)
    do
        aws --region="$REGION" ec2 describe-instances \
            --query="Reservations[].Instances[].[PrivateIpAddress]" \
            --output="text" \
            --instance-ids="$id"
    done
}

# Wait until we have as many cluster instances as we are expecting.
while COUNT=$(cluster-instance-ids | wc -l) && [ "$COUNT" -lt "$EXPECTED_SIZE" ]
do
    echo "$COUNT instances in the cluster, waiting for $EXPECTED_SIZE instances to warm up..."
    sleep 1
done

# Get our own instance IP, then all other IPs.
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
mapfile -t ALL_IPS < <(cluster-ips)
OTHER_IPS=( $${ALL_IPS[@]/$${IP}/} )
echo "Instance IP is: $IP, Cluster IPs are: $${ALL_IPS[@]}, Other IPs are: $${OTHER_IPS[@]}"

# Start the Consul server.
docker run -d --net=host \
    --name=consul \
    consul agent -server -ui \
    -bind="$$IP" \
    -client="0.0.0.0" \
    -retry-join="$${OTHER_IPS[0]}" -retry-join="$${OTHER_IPS[1]}" \
    -retry-join="$${OTHER_IPS[2]}" -retry-join="$${OTHER_IPS[3]}" \
    -bootstrap-expect="$EXPECTED_SIZE"
