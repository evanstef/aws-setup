package main

required := {"CostCenter", "Owner", "Environment"}
exclude := {"aws_route53_record", "aws_key_pair"}

deny contains msg if {
	resource := input.resource[aku][name][_]
	not exclude[aku]
	ada := {k | resource.tags[k]} # set tag yang ADA di resource
	kurang := required - ada # set difference: wajib - punya = yang hilang
	count(kurang) > 0
	msg := sprintf("%s.%s kurang tag wajib: %v", [aku, name, kurang])
}
