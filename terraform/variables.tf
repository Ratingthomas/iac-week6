variable "esxi_hostname" {
  default = "192.168.100.2"
}

variable "esxi_hostport" {
  default = "22"
}

variable "esxi_hostssl" {
  default = "443"
}

variable "esxi_username" {
  default = "root"
}

variable "esxi_password" { # Unspecified will prompt
  default = "Welkom01!"
}

variable "ovf_file" {
  default = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.ova"
}

variable "name" {
  default = "week6-NET"
}

variable "subscription_id" {
  default = "c064671c-8f74-4fec-b088-b53c568245eb"
}