package main

# Versi PLAN JSON — semua RDS wajib dienkripsi.
deny contains msg if {
	rc := input.resource_changes[_]
	rc.type == "aws_db_instance"
	not rc.change.after.storage_encrypted
	msg := sprintf("RDS '%s' gak dienkripsi — wajib storage_encrypted=true", [rc.name])
}
