terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.11.0"
      configuration_aliases = [ aws.main, aws.dr ]
    }

    tls = {
      source = "hashicorp/tls"
      version = "4.0.4"
    }
  }

   cloud {
    organization = ""

    workspaces {
      name = ""
    }
  }  

}

provider "aws" {
  region = "us-west-2"
}




module "security" {
  source = "./security"
}

module "networking" {
    source = "./networking"
}

module "appinfra" {
    source = "./appinfra"
    app_bucket_name = "<bucket_name>"
  
}




module "api_lambda" {
    source = "./lambda"
    lambda_role_arn=module.security.iam_role_arn
    depends_on = [ module.security ]
}

module "api_gateway" {
    source = "./apigw"
    lambda_execute_arn=module.api_lambda.lambda_execute_arn
    lambda_arn=module.api_lambda.lambda_arn
    depends_on = [ module.api_lambda ]
}

module "instances" {
  
    source = "./instances"
    instance_profile_name = module.security.instance_profile_name
    private_sg_id = module.networking.private_sg_id
    priv_subnet_ids = module.networking.private_subnet_ids
    public_subnet_ids = module.networking.public_subnet_ids
    lb_sg_id = module.networking.lb_sg_id
    vpc_id = module.networking.vpc_id
    depends_on = [ module.networking,module.appinfra,module.security,module.api_gateway,module.api_lambda ]
}

