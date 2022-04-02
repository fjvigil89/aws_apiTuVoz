output "persistent_dns" {
  value = aws_eip.persistent.public_dns
}

output "docker_compose" {
  value = local.docker_compose
}