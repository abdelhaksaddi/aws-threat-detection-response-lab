variable "aws_profile" {
  type        = string
  description = "Named AWS CLI profile; do not embed access keys."
  default     = "academy"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}
