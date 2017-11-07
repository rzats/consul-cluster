# consul-cluster

A [Consul cluster](https://www.consul.io/) deployed on [AWS](https://aws.amazon.com) using [Terraform](https://www.terraform.io/).

To deploy the cluster, install Terraform and Docker, configure your AWS credentials using [one of the methods supported by the Terraform AWS provider](https://www.terraform.io/docs/providers/aws/index.html), then run

```
# Create the module and fetch dependencies.
terraform get

# [Optional but recommended] Get an overview of the resources that will be created.
terraform plan

# Deploy the module!
terraform apply
```

After the cluster is deployed, navigate to port 8500 at the public address provided by the output (consul-dns) to view the Consul web UI. Resources created by Terraform can be cleaned up via `terraform destroy`.

This project was partially based on the following blog post: [Creating a Resilient Consul Cluster for Docker Microservice Discovery with Terraform and AWS](http://www.dwmkerr.com/creating-a-resilient-consul-cluster-for-docker-microservice-discovery-with-terraform-and-aws/).
