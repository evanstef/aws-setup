# ===== OUTPUT module app-stack (yang dikasih balik ke root) =====

output "server_ip" {
  value = aws_eip.app_evan.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/.ssh/id_ed25519_deploy ubuntu@${aws_eip.app_evan.public_ip}"
}

# Alamat RDS — dipakai app buat connect (host DB)
output "db_endpoint" {
  value = aws_db_instance.db.endpoint
}
