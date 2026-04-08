terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-base.qcow2"
  pool   = "default"
  source = var.ubuntu_image_url
  format = "qcow2"
}

resource "libvirt_volume" "vm_disk" {
  name           = "${var.vm_name}.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = var.disk_size_gb * 1073741824
}

resource "libvirt_cloudinit_disk" "init" {
  name = "${var.vm_name}-init.iso"
  pool = "default"

  user_data = <<-EOF
    #cloud-config
    hostname: ${var.vm_name}
    users:
      - name: ubuntu
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    package_update: true
    packages:
      - curl
      - apt-transport-https
  EOF
}

resource "libvirt_domain" "vm" {
  name   = var.vm_name
  vcpu   = var.vcpus
  memory = var.memory_mb

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }

  cloudinit = libvirt_cloudinit_disk.init.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
