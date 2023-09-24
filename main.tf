terraform {
  cloud {
    organization = "aws-trial"
  }

  required_providers {
    aws = {
      version = "5.10.0"
      source  = "hashicorp/aws"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }

  }
}

module "vpc" {
  source     = "./vpc"
  cidr_block = var.cidr_block
  vpc_tags = merge(local.common_tags, {
    Name = var.vpc_name
  })
  igw_tags = merge(local.common_tags, {
    Name = var.vpc_igw_name
  })
}

module "subnet" {
  source       = "./subnet"
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.cidr_block
  subnet_count = var.subnet_count
  common_tags  = local.common_tags
  igw_id       = module.vpc.igw_id
}


module "bastion_host" {
  source        = "./ec2"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.subnet.public_subnet_ids[0]
  key_name      = var.bastion_host_key_pair_name
  instance_name = var.bastion_host_instance_name
  common_tags   = local.common_tags
}

module "app_secrets_manager" {
  source      = "./secrets_manager"
  secret_name = var.app_secret_name
  secret_string = jsonencode({
    DB_HOSTNAME : module.app_db.hostname,
    DB_PASSWORD : module.app_db.password,
    DB_USERNAME : module.app_db.username,
    DB_PORT : module.app_db.port,
    DB_NAME : var.app_db_name
    OPENSEARCH_PASSWORD : module.default_opensearch_domain.password,
    OPENSEARCH_DOMAIN_URL : module.default_opensearch_domain.domain_url,
    OPENSEARCH_USERNAME : module.default_opensearch_domain.username,
    BASTION_HOST_PRIVATE_KEY : module.bastion_host.private_key
  })
  common_tags = local.common_tags
}

module "app_db" {
  source                          = "./rds"
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.subnet.private_subnet_ids
  subnet_group_name               = var.db_subnet_group_name
  common_tags                     = local.common_tags
  db_name                         = var.db_name
  db_master_username              = var.db_master_username
  cluster_name                    = var.db_cluster_name
  ingress_allowed_security_groups = []
}


module "backend_server_ecr" {
  source = "./ecr"
  name   = var.backend_server_ecr_name
}

module "backend_server_lb" {
  source             = "./alb"
  tg_name            = var.backend_server_tg_name
  vpc_id             = module.vpc.vpc_id
  common_tags        = local.common_tags
  lb_name            = var.backend_server_lb_name
  subnet_ids         = module.subnet.public_subnet_ids
  certificate_arn    = module.backend_server_lb_acm.arn
  load_balancer_type = "application"

  health_check_config = {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/api/check-health"
    unhealthy_threshold = "2"
  }
}


module "backend_server_ecs" {
  source              = "./ecs"
  cluster_name        = var.backend_server_cluster_name
  image_url           = module.backend_server_ecr.repository_url
  container_name      = var.backend_server_container_name
  region              = var.region
  service_name        = var.backend_server_service_name
  common_tags         = local.common_tags
  subnet_ids          = module.subnet.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
  task_name           = var.backend_server_task_name
  ecr_arn             = module.backend_server_ecr.arn
  lb_tg_arn           = module.backend_server_lb.tg_arn
  secrets_manager_arn = module.app_secrets_manager.arn
}


module "backend_server_lb_route53_record" {
  source              = "./route53_record"
  common_tags         = local.common_tags
  zone_name           = var.hosted_zone_name
  primary_domain_name = var.primary_domain_name
  domain_name         = module.backend_server_lb.lb_dns_name
  zone_id             = module.backend_server_lb.lb_zone_id
  record_name         = var.backend_domain_name
}

module "backend_server_lb_acm" {
  source              = "./acm"
  hosted_zone_id      = module.backend_server_lb_route53_record.hosted_zone_id
  domain_name = var.backend_domain_name
}

module "default_opensearch_domain" {
  source                          = "./opensearch"
  master_user_name                = var.opensearch_master_user_name
  common_tags                     = local.common_tags
  vpc_id                          = module.vpc.vpc_id
  name                            = var.opensearch_domain_name
  subnet_ids                      = module.subnet.private_subnet_ids
  ingress_allowed_security_groups = []
  region                          = var.region
}


module "logstash_ecr" {
  source = "./ecr"
  name   = var.logstash_ecr_name
}

module "logstash_nlb" {
  source      = "./nlb"
  name        = var.logstash_lb_name
  tg_name     = var.logstash_lb_tg_name
  subnet_ids  = module.subnet.private_subnet_ids
  vpc_id      = module.vpc.vpc_id
  in_port     = var.logstash_listener_port
  common_tags = local.common_tags
}

module "logstash_ecs" {
  source              = "./ecs"
  cluster_name        = var.logstash_cluster_name
  image_url           = module.logstash_ecr.repository_url
  container_name      = var.logstash_container_name
  region              = var.region
  service_name        = var.logstash_service_name
  common_tags         = local.common_tags
  subnet_ids          = module.subnet.private_subnet_ids
  vpc_id              = module.vpc.vpc_id
  task_name           = var.logstash_task_name
  ecr_arn             = module.logstash_ecr.arn
  lb_tg_arn           = module.logstash_nlb.tg_arn
  secrets_manager_arn = module.app_secrets_manager.arn
  container_port      = var.logstash_listener_port
  host_port           = var.logstash_listener_port
  memory_in_mb        = var.logstash_task_memory_in_mb
  cpu_units           = var.logstash_task_cpu_units
}

module "logstash_route53_record" {
  source              = "./route53_record"
  common_tags         = local.common_tags
  zone_name           = var.hosted_zone_name
  primary_domain_name = var.primary_domain_name
  domain_name         = module.logstash_nlb.lb_dns_name
  zone_id             = module.logstash_nlb.lb_zone_id
  record_name         = var.logstash_domain_name
}


