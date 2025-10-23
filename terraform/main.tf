terraform {
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

resource "esxi_guest" "web" {
  guest_name = "week6-web"
  disk_store = "datastore1"

  memsize  = "2048"
  numvcpus = "1"

  ovf_source = var.ovf_file
  network_interfaces {
    virtual_network = "VM Network"
  }

  guestinfo = {
    "metadata"          = filebase64("../cloudinit/web/metadata.yaml")
    "metadata.encoding" = "base64"
    "userdata"          = filebase64("../cloudinit/userdata.yaml")
    "userdata.encoding" = "base64"
  }
}


resource "esxi_guest" "phpmyadmin" {
  guest_name = "week6-phpmyadmin"
  disk_store = "datastore1"

  memsize  = "2048"
  numvcpus = "1"

  ovf_source = var.ovf_file
  network_interfaces {
    virtual_network = "VM Network"
  }

  guestinfo = {
    "metadata"          = filebase64("../cloudinit/phpmyadmin/metadata.yaml")
    "metadata.encoding" = "base64"
    "userdata"          = filebase64("../cloudinit/userdata.yaml")
    "userdata.encoding" = "base64"
  }
}


resource "esxi_guest" "db" {
  guest_name = "week6-db"
  disk_store = "datastore1"

  memsize  = "2048"
  numvcpus = "1"

  ovf_source = var.ovf_file
  network_interfaces {
    virtual_network = "VM Network"
  }

  guestinfo = {
    "metadata"          = filebase64("../cloudinit/db/metadata.yaml")
    "metadata.encoding" = "base64"
    "userdata"          = filebase64("../cloudinit/userdata.yaml")
    "userdata.encoding" = "base64"
  }
}

resource "null_resource" "save_ips" {
  provisioner "local-exec" {
    command = <<EOT
cat > ../inventory.ini<< EOF
[all]
${esxi_guest.web.ip_address}
${esxi_guest.phpmyadmin.ip_address}
${esxi_guest.db.ip_address}

[managementservers]
${esxi_guest.phpmyadmin.ip_address}

[webservers]
${esxi_guest.web.ip_address}

[dbservers]
${esxi_guest.db.ip_address}

[all:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_user=thomas
ansible_ssh_private_key_file=~/.ssh/skylab
EOF
    EOT
  }
}

output "ips" {
  value = {
    web         = esxi_guest.web.ip_address
    phpmyadmin  = esxi_guest.phpmyadmin.ip_address
    db          = esxi_guest.db.ip_address
  }
}
