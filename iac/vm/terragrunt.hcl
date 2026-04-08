terraform {
  source = "../modules/vm"
}

# Local state for VM
remote_state {
  backend = "local"
  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  vm_name        = "minikube-vm"
  vcpus          = 2
  memory_mb      = 4096
  disk_size_gb   = 20
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}
