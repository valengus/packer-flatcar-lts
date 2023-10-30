variable "version" {
  type    = string
  default = "3510.3.1"
}

variable "channel" {
  type    = string
  default = "lts"
}

variable "cloud_token" {
  type    = string
  default = "${env("VAGRANT_CLOUD_TOKEN")}"
}

source "qemu" "flatcar-lts" {
  accelerator  = "kvm"
  machine_type = "q35"
  cpus         = 2
  memory       = 4 * 1024
  boot_wait    = "15s"
  boot_command = [
    "echo 'core:core' | sudo chpasswd <enter>",
    "sudo systemctl start sshd <enter>",
  ]
  net_device       = "virtio-net"
  disk_interface   = "virtio-scsi"
  disk_cache       = "unsafe"
  disk_discard     = "unmap"
  disk_size        = 20 * 1024
  format           = "qcow2"
  headless         = false
  http_directory   = "."
  iso_url          = "https://lts.release.flatcar-linux.net/amd64-usr/3510.3.1/flatcar_production_iso_image.iso"
  iso_checksum     = "sha512:42ed6a3ce2c748c521b5959641bd97088a0d02bc5b01db6c9f43d1f21b3f0cca9ef54a7ef5a4237730d73bc7652e357aa86048c87ba585b333d8e0730d9d24cb"
  ssh_password     = "core"
  ssh_username     = "core"
  ssh_wait_timeout = "60m"
  shutdown_command = "sudo poweroff"
}

build {
  sources = [
    "source.qemu.flatcar-lts"
  ]

  provisioner "file" {
    destination = "/tmp/provision.ign"
    source      = "provision.ign"
  }

  provisioner "shell" {
    inline = [
      "sudo flatcar-install -d /dev/sda -C ${var.channel} -i /tmp/provision.ign",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      compression_level    = 9
      output               = "flatcar-${var.channel}.box"
      vagrantfile_template = "Vagrantfile.template"
    }
    post-processor "vagrant-cloud" {
      access_token = "${var.cloud_token}"
      box_tag      = "valengus/flatcar"
      version      = "${var.version}"
      no_release   = true
    }
  }

}
