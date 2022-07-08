variable "vpc_cider" {
  default     = "10.0.0.0/16"
  description = "vpc cidr block"
  type        = string

}
variable "public-A" {
  default     = "10.0.1.0/24"
  description = "public-A"
  type        = string
}

variable "public-B" {
  default     = "10.0.2.0/24"
  description = "public-B"
  type        = string

}

variable "private-A" {
  default     = "10.0.3.0/24"
  description = "private-B"
  type        = string

}
variable "private-B" {
  default     = "10.0.4.0/24"
  description = "private-B"
  type        = string

}