package main

# Versi PLAN JSON — SSH (port 22) gak boleh kebuka ke 0.0.0.0/0.
deny contains pesanan if {
	rc := input.resource_changes[_]
	rc.type == "aws_security_group"
	rule := rc.change.after.ingress[_]
	rule.from_port == 22
	rule.cidr_blocks[_] == "0.0.0.0/0"
	pesanan := sprintf("SG '%s': SSH (port 22) terbuka ke 0.0.0.0/0 — batasi ke IP kantor!", [rc.name])
}
