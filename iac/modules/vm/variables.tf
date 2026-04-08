variable "vm_name" {
  description = "Name of the VM"
  type        = string
  default     = "minikube-vm"
}

variable "vcpus" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 4096
}

variable "disk_size_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 20
}

variable "ubuntu_image_url" {
  description = "Ubuntu cloud image URL"
  type        = string
  default     = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}
