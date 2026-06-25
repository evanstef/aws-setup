package main

# cek ssh gak boleh di bisa di akses dari mana saja 
deny contains pesanan if {
	keamanan := input.resource.aws_security_group[name][_]
	ini_aturan := keamanan.ingress[_]
	ini_aturan.from_port == 22
	ini_aturan.cidr_blocks[_] == "0.0.0.0/0"
	pesanan := sprintf("SG '%s': SSH (port 22) terbuka ke 0.0.0.0/0 — batasi ke IP kantor!", [name])
}
