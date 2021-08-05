
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  validation {
    condition     = length(setsubtract(["Application", "Tier", "Owner"], keys(var.tags))) == 0
    error_message = "Required tags missing."
  }
  default = {
    "Application" = "airflow"
    "Tier" : "PROD",
    "Owner" : "Terrafrom User"
  }
}
variable "aws_region" {
  default = "<region-name>"
}

variable "profile" {
}

variable "vpc_id" {
  type        = string
  default     = "<vpc-id>"
}


variable "cluster_name" {
    type = string
    default = "test"
}

variable "node_instance_type" {
  type = list(string)
  default = ["t2.large"]
}



variable "ssh_key_name" {
  type = string
  default = "<key-name>"
}

variable "node_instance_disk_size" {
  type = string
  default = 30
}

variable "node_policy_name" {
  type = string
  default = "eks-node-policy-prod"
}

variable "node_group_name" {
  type = string
  default = "node-group-prod"
  description = "(optional) describe your variable"
}

variable "eks_cluster_policy_name" {
  type = string
  default = "eks-cluster-policy-prod"
}

variable "auto_scalar_access" {
  type = string
  default = "auto_scalar_policy"
}

variable "scaling_config" {
  type = map(string)
  default = {
    "desired_size" = 1
    "max_size"     = 1
    "min_size"     = 1
  }
}
