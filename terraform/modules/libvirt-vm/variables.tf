variable "vm_name" {
  description = "Имя виртуальной машины"
  type        = string
}

variable "ip" {
  description = "Network interface IP address"
  type        = string
}

variable "prefix" {
  description = "Network interface IP address"
  type        = number
  default     = 24
}
variable "gateway" {
  description = "Network interface IP address"
  type        = string
}

variable "mac" {
  description = "Network interface MAC address"
  type        = string
}

variable "adminlogin" {
  description = "admin login"
  type        = string
}

variable "adminpassword" {
  description = "admin password"
  type        = string
  sensitive   = true
}

variable "vcpus" {
  description = "Количество vCPU"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Объем оперативной памяти (в MB)"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Размер диска (в байтах)"
  type        = number
  default     = 10737418240 # 10GB
}

variable "pool_name" {
  description = "Имя пула томов"
  type        = string
}

variable "basevolume_path" {
  description = "Путь к базовому диску"
  type        = string
}

variable "network_name" {
  description = "Имя сети"
  type        = string
  default     = "default"
}

variable "ssh_public_key" {
  description = "Публичный SSH ключ"
  type        = string
}

variable "vncport" {
  description = "Порт для VNC подключения (-1 для авто, 0 для отключения, >0 для конкретного порта)"
  type        = number
  validation {
    condition     = var.vncport >= -1 && var.vncport <= 65535
    error_message = "VNC порт должен быть в диапазоне от -1 до 65535."
  }
}