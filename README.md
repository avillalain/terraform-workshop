# terraform-workshop
The following repository contains basic material used to run a terraform workshop. The folder structure represents 
multiple exercises you could do to explain certain terraform contents.
- The first exercise, terralith (kudos to Nicki Watt @OpenCredo) represents the initial journey into terraform. In this exercise you will create a series of resources in AWS, using a single monolithic resource description file. There we will cover, basic functions, basic interpolations, and discover the main constructs used in terraform.
- The second exercise (modules), covers the necessary steps to refactor your code into reusable modules. As part of this exercise we are going to refactor the code into 2 modules: one for basic AWS networking, and the other used to deploy a service in an EC2 nstance.
- The third step (under state) explains and cover how terraform performs updates and changes to your infrastructure, we will talk about the terraform state, and how to store this state in a remote backend where your team can share the state of your infrastructure.
- The fourth exercise (under workspace) is around environments. How terraform deals with multiple environments.
- The last exercise under streams, lets you understand how infrastructure could be provision independently across multiple independent work streams. Here we introduce the concept of remote state and how can you benefit from it.
