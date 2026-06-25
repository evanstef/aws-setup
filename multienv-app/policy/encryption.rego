package main

#  buat ngecek db yang belum di encrypted
deny contains msg if {
	db := input.resource.aws_db_instance[name][_]
	not db.storage_encrypted
	msg := sprintf("RDS '%s' gak dienkripsi — wajib storage_encrypted=true", [name])
}
