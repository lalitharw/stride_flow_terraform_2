module "s3" {
  source = "./modules/s3"
}

module "ecr" {
  source = "./modules/ecr"
}

module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr_block  = var.vpc_cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  redis_subnet    = var.redis_subnet
}

module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

module "rds" {
  source     = "./modules/rds"
  db_subnets = module.vpc.private_subnets_id
  rds_sg_id  = module.sg.rds_sg_id
}

module "ec2" {
  source          = "./modules/ec2"
  backend_sg_id   = module.sg.backend-sg-id
  private_subnets = module.vpc.private_subnets_id
}

module "alb" {
  source            = "./modules/alb"
  alb-sg-id         = module.sg.alb-sg-id
  public_subnets_id = module.vpc.public_subnets_id
  vpc_id            = module.vpc.vpc_id
  instance          = module.ec2.instance
}

## Status 403 is coming account needs to be verified
# module "cloudfront" {
#   source         = "./modules/cloudfront"
#   s3_domain_name = module.s3.bucket_domain_name
#   bucket_id      = module.s3.bucket_id
#   bucket_arn     = module.s3.bucket_arn
# }


