packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "10605-hw5-part1"
  instance_type = "g5.xlarge"
  region        = "us-east-1"
  # skip_create_ami = "true"

  # Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 22.04)
  source_ami = "ami-01924b6996b062ee3" 
  ssh_username = "ubuntu"
  
  launch_block_device_mappings {
    device_name = "/dev/sda1"
    volume_size = 200
    volume_type = "gp3"
    delete_on_termination = true
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    inline = [
      "mkdir -p ~/miniconda3",
      "wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh",
      "bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3",
      "rm -rf ~/miniconda3/miniconda.sh",
      "~/miniconda3/bin/conda init bash",
      "yes | pip install tqdm tiktoken requests datasets boto3",
      "wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb",
      "sudo dpkg -i cuda-keyring_1.1-1_all.deb",
      "sudo apt-get update",
      "sudo apt-get -y install libcudnn9-dev-cuda-12",
      "git clone https://github.com/NVIDIA/cudnn-frontend.git",
      "mkdir -p ./data && curl -s 'https://api.github.com/repos/10605/F25-ami-materials/releases/tags/v0.0.0-test' | grep 'browser_download_url' | cut -d '\"' -f 4 | xargs -n 1 curl -L -O --output-dir ./data"
    ]
  }
}

