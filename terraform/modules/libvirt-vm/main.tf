
resource "libvirt_volume" "vm_disk" {
  name   = "${var.vm_name}-disk.qcow2"
  target = { format = { type = "qcow2" }}
  pool     = var.pool_name
  capacity = var.disk_size
  backing_store = {
    path   = var.basevolume_path
    format = { type = "qcow2" }
  }
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name = "${var.vm_name}-cloudinit"
  meta_data = yamlencode({
    instance-id    = "${var.vm_name}-cloudinit"
  })
  user_data      = <<-EOF
    #cloud-config
    fqdn: ${var.vm_name}
    prefer_fqdn_over_hostname: true
    create_hostname_file: true
    manage_etc_hosts: true
    preserve_hostname: false
    bootcmd:
      - echo nameserver 8.8.8.8 > /etc/resolv.conf
    runcmd:
      - systemctl restart networking
    users:
      - name: ${var.adminlogin}
        ssh_authorized_keys:
          - ${var.ssh_public_key}
        parsec_user_max_ilev: high
        plain_text_passwd: ${var.adminpassword}
        gecos: Admin User
        sudo: ['ALL = (ALL) NOPASSWD: ALL']
        groups: sudo, astra-console, astra-admin
        shell: /bin/bash
        lock_passwd: false
    apt:
      sources:
        aldpro:
          source: "deb https://dl.astralinux.ru/aldpro/frozen/01/3.2.1/ 1.7_x86-64 main base"
    packages:
      - firefox
      - chromium
      - bash-completion
      - spice-vdagent
      - resolvconf
    package_update: true
    package_reboot_if_required: true
    apt_pipelining: false
    write_files:
    - path: /etc/cloud/cloud-init.disabled
      owner: root:root
      permissions: '0644'
    growpart:
      mode: auto
      devices: ['/']
    manage_resolv_conf: true
    resolv_conf:
      domain: ald.test
      nameservers: [8.8.8.8, 8.8.4.4]
  EOF
  network_config = <<-EOF
    #network-config
    version: 2
    ethernets:
      eth0:
        match:
          macaddress: "${var.mac}"
        dhcp4: false
        gateway4: "${var.gateway}"
        addresses:
          - ${var.ip}/${var.prefix}
        nameservers:
          addresses: [8.8.8.8, 8.8.4.4]
  EOF
}

# Upload cloud-init ISO to a volume
resource "libvirt_volume" "cloudinit-disk" {
  name = "${var.vm_name}-cloudinit.iso"
  pool = var.pool_name
  # Format will be auto-detected as "iso"
  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit.path
    }
  }
}

resource "libvirt_domain" "vm" {
  name        = var.vm_name
  memory      = var.memory
  memory_unit = "MiB"
  vcpu        = var.vcpus
  type        = "kvm"
  autostart   = false
  running     = false

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
  }
  cpu = {
    mode  = "host-passthrough"
    check = "none"
  }
  devices = {
    disks = [
      {
        source = {
          file = {
            file = libvirt_volume.vm_disk.path
          }
        }
        backing_store = {
          format = {
            type = "qcow2" 
            }
          source = {
            file = {
              file  = var.basevolume_path
            } 
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
        driver = {
          name = "qemu"
          type = "qcow2"
        }
      },
      { type   = "file"
        device = "cdrom"
        source = {
          file = {
            file = libvirt_volume.cloudinit-disk.path
          }
        }
        target = {
          bus = "sata"
          dev = "sda"
        }
        driver = {
          name = "qemu"
          type = "raw"
        }
      }
    ]
    interfaces = [{
        type = "network"
        model = {
          type = "virtio"
        }
        source = {
          network = {
            network = var.network_name
          }
        }
        mac = {
          address = var.mac
        }
      }]
    graphics = [
      {
      spice = {
        listen   = "0.0.0.0"
        auto_port = true
        gl       = { enable = "no" }
        listeners = [{
          address = { address = "0.0.0.0" } 
        }]
        clip_board = { copy_paste = "yes" }
       }
      },
      {
        vnc = {
          type         = "address"
          listen       = "0.0.0.0"
          port         = var.vncport
          autoport     = "no"
          share_policy = "force-shared"
        }
      }
    ]

    channels = [{
      type = "spice_vmc"
      
      target = {
        virt_io = {
        name = "com.redhat.spice.0"
        }
      }
      source = {
        spice_vmc = true
      }
      address = {
        type = "virtio-serial"
        controller="0"
        bus="0" 
        port="2"
      }
    },{
      type = "unix"
      target = {
        virt_io = {
        name = "org.qemu.guest_agent.0"
        }
      }
    }
    ]

    videos = [{
        model = {
          type    = "qxl"
          primary = "yes"
          heads   = 1
          vram    = 65536
          ram     = 65536
          vga_mem = 16384
        }
      }]
  }

}