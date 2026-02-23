# Infrastructure as Object-Oriented Programming (OOP)

When moving from procedural infrastructure scripts to enterprise-grade deployments, the mindset must shift. In this project, we treat Terraform modules exactly like Object-Oriented Programming (OOP) classes.

This paradigm shift ensures code is reusable, encapsulated, and safe to deploy across multiple environments (Dev, Staging, Prod) without drift or naming collisions.

## The Mapping: OOP vs. Terraform

### 1. Classes = Modules
In OOP, a class encapsulates logic and hides complex internal workings from the rest of the application. 
In Terraform, **Modules** (`/modules/*`) act as our classes. 
- The `loadbalancer` module contains the complex logic of bridging a Serverless NEG to a Global Forwarding Rule. 
- The calling code doesn't need to know *how* the NEG works; it only needs to know that the module provides a load balancer.

### 2. Constructor Arguments = Variables
In OOP, you instantiate a class by passing arguments to its constructor.
In Terraform, **Variables** (`variables.tf`) act as constructor arguments.
- We require the calling code to pass in a `project_id`, `region`, and `env_name`.
- This parameterization is what allows us to reuse the exact same module code for a `dev` deployment and a `prod` deployment without hardcoding values.

### 3. Public Properties = Outputs
In OOP, a class exposes data to the outside world via public properties or getter methods.
In Terraform, **Outputs** (`outputs.tf`) act as public properties.
- Our `network` module creates a VPC and a Subnet. 
- Because the module is encapsulated, the `compute` module cannot "see" the subnet inside the network module. The `network` module must explicitly declare `output "subnet_id"` so the `compute` module can consume it.

### 4. The Main Function = Environment Definitions
In OOP, a `main()` function instantiates objects and wires them together via dependency injection.
In Terraform, our **Environment Configurations** (`/environments/dev/main.tf`) act as the main function.
- This file contains almost no actual infrastructure logic. 
- Instead, it instantiates the modules, passing the outputs of one module (like `module.network.subnet_id`) as the input variables to the next module (like `module.compute`).
