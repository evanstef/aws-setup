package main

# Versi PLAN JSON — instance type harus dari allowlist (kontrol biaya).
allowed := {"t3.micro", "t3.medium", "t3.small"}

deny contains msg if {
	rc := input.resource_changes[_]
	rc.type == "aws_instance"
	not allowed[rc.change.after.instance_type]
	msg := sprintf("Instance '%s' pakai tipe '%s' — di luar allowlist", [rc.name, rc.change.after.instance_type])
}
