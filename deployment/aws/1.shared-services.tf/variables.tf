variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "profile" {
  description = "AWS named profile"
  type        = string
  default     = "default"
}

variable "aws_account_ids" {
  description = "List of AWS Account IDs to share resources with"
  type        = list(string)
}