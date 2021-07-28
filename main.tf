# Provider設定
provider "aws" {
  region = "ap-northeast-1"
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