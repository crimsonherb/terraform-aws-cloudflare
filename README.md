# terraform-aws-cloudflare

Practice project to deploy a static website using Terraform, AWS (S3 Bucket), and Cloudflare(Domain).

Idea here is to allow me deploy a basic website but the infrastructure would be setup through Terraform

Currently still need to streamline the following:
Data going into S3 bucket
Role permissions

It turns out it would be hard to utilize the artifact created by a job and have it used on a seperate workflow, so I would be needing to combine them