# Конфигурация Terragrunt
remote_state = {
  backend = "local"
  config = {
    path = "${path_relative_to_include()}/terraform.tfstate"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}

# Глобальные переменные для всех окружений
inputs = {

}