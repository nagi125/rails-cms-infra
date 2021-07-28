# Provider設定
provider "aws" {
  region = "ap-northeast-1"
}

variable "DB_NAME" {
  type = string
}

variable "DB_MASTER_NAME" {
  type = string
}

variable "DB_MASTER_PASS" {
  type = string
}

variable "app_name" {
  type = string
  default = "rails-cms-api"
}

variable "zone" {
  type = string
  default = "nagi-dev.jp"
}

variable "domain" {
  type = string
  default = "api.nagi-dev.jp"
}

module "iam" {
  source = "./iam"
  app_name = var.app_name
}

variable "azs" {
  type = list(string)
  default = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
}

module "network" {
  source   = "./network"
  app_name = var.app_name
  azs      = var.azs
}

module "acm" {
  source   = "./acm"
  app_name = var.app_name
  zone     = var.zone
  domain   = var.domain
}

module "elb" {
  source = "./elb"

  app_name = var.app_name

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  zone              = var.zone
  domain            = var.domain
  acm_id            = module.acm.acm_id
}

module "rds" {
  source = "./rds"

  app_name = var.app_name

  vpc_id     = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  database_name   = var.DB_NAME
  master_username = var.DB_MASTER_NAME
  master_password = var.DB_MASTER_PASS
}

module "ecs_cluster" {
  source = "./ecs_cluster"
  app_name = var.app_name
}

module ses {
  source = "./ses"

  zone   = var.zone
  domain = var.domain
}