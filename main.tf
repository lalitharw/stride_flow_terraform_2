# module "s3" {
#   source = "./modules/s3"
# }

# module "ecr" {
#   source = "./modules/ecr"
# }

module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr_block  = var.vpc_cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  redis_subnet    = var.redis_subnet
  frontend_subnet = var.frontend_subnet
}



module "rds" {
  source     = "./modules/rds"
  db_subnets = module.vpc.private_subnets_id
  rds_sg_id  = module.sg.rds_sg_id
}

# module "ec2" {
#   source                 = "./modules/ec2"
#   backend_sg_id          = module.sg.backend-sg-id
#   private_subnets        = module.vpc.private_subnets_id
#   private_subnet_id      = module.vpc.private_subnet_id
#   redis_sg_id            = module.sg.redis-sg-id
#   redis_private_subnet   = module.vpc.redis_private_subnet
#   iam_instance_profile   = module.iam.iam_instance_profile
#   eic-endpoint-sg-id     = module.sg.eic-endpoint-sg-id
#   frontend-sg-id         = module.sg.frontend-sg-id
#   frontend_public_subnet = module.vpc.frontend_public_subnet_id
# }

# module "alb" {
#   source            = "./modules/alb"
#   alb-sg-id         = module.sg.alb-sg-id
#   public_subnets_id = module.vpc.public_subnets_id
#   vpc_id            = module.vpc.vpc_id
#   #   instance          = module.ec2.instance
# }


# module "asg" {
#   source             = "./modules/asg"
#   target_group_arn   = module.alb.target_group_arn
#   instance_launch_id = module.ec2.instance_launch_id
#   private_subnets    = module.vpc.private_subnets_id
# }


module "iam" {
  source = "./modules/iam"
}


module "sg" {
  source = "./modules/sg"
  vpc_id = module.vpc.vpc_id
}

## Status 403 is coming account needs to be verified
# module "cloudfront" {
#   source         = "./modules/cloudfront"
#   s3_domain_name = module.s3.bucket_domain_name
#   bucket_id      = module.s3.bucket_id
#   bucket_arn     = module.s3.bucket_arn
# }


