# terraform-aws-cloudflare

Practice project to deploy a static website using Terraform, AWS (S3 Bucket), and Cloudflare(Domain).

Idea here is to allow me deploy a basic website but the infrastructure would be setup through Terraform

I'll be recording my development thought process here to simulate changes

Currently still need to streamline the following:
Data going into S3 bucket
Role permissions

It turns out it would be hard to utilize the artifact created by a job and have it used on a seperate workflow, so I would be needing to combine them

I opted out from combining them because it would add another layer of complexity and make it so that the terraform apply would not use the artifact created, however, I will be using asistance to make it so that the terraform plan will write on my PR

Looking now, I think this writing on my PR is creating a huge unnecessary effort, but will have one last try before scrapping the idea altogether

Last attempt

So I experienced drift since most of the time, I've been testing directly by performing terraform apply through Github Actions, turns out I need to be able to sync it with my local terraform cli.

I need to find a solution to this

Added another S3 bucket that will serve as my source of truth for current state of my infra