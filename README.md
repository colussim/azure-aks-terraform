# azure-aks-terraform
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)

# Create a simple Azure Kubernetes Service (AKS) with NGINX Ingress Controller

The purpose of this tutorial is to create an AKS cluster (2 nodes) with Terraform. Azure Kubernetes Service (AKS) is a fully managed Kubernetes service by Azure.

The Kubernetes cluster in a private network, and is deployed without outbound internet access. 
Traffic from the Internet is prohibited, with the exception of requests on TCP ports 443 and 5432.

## What is AKS ?
Azure Kubernetes Service is a managed container orchestration service based on the open source Kubernetes system, which is available on the Microsoft Azure public cloud. 
An organization can use AKS to handle critical functionality such as deploying, scaling and managing Docker containers and container-based applications.

## Prerequisites

Before you get started, you’ll need to have these things:
* Terraform > 0.13.x
* kubectl installed on the compute that hosts terraform
* An Azure account 
* Azure CLI 
* An Azure service principal for terraform.

## Initial setup

The first thing to set up is your Terraform. We will create an Azure service principal for Terraform.

```

$ git clone https://github.com/colussim/terraform-aks-aws.git
$ cd azure-aks-terraform
$ az login
$ terraform init
$ terraform apply

```

## Conclusion

With Terraform, booting a AKS cluster can be done with a single command and it only takes some minutes to get a fully functional configuration.
Next step : deploy an application in our cluster .

## Resources :

[Documentation, Create a Kubernetes cluster with Azure Kubernetes Service using Terraform](https://docs.microsoft.com/en-us/azure/developer/terraform/create-k8s-cluster-with-tf-and-aks#set-up-azure-storage-to-store-terraform-state "Microsoft AKS Documentation")

[Documentation, Create an ingress controller in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-basic?tabs=azure-cli "Create an ingress controller in Azure Kubernetes Service (AKS)")


