package main

# Versi PLAN JSON (input.resource_changes) — buat scan terraform show -json.
required := {"CostCenter", "Owner", "Environment"}
exclude := {"aws_route53_record", "aws_key_pair"}

deny contains msg if {
	rc := input.resource_changes[_]
	rc.mode == "managed"
	tags_all := rc.change.after.tags_all 
	ada := {k | tags_all[k]}
	kurang := required - ada
	count(kurang) > 0
	msg := sprintf("%s.%s kurang tag wajib: %v", [rc.type, rc.name, kurang])
}

