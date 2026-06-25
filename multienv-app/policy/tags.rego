package main

required := {"CostCenter", "Owner", "Environment"}

deny contains msg if {
	resource := input.resource[tipe][name][_]
	ada := {k | resource.tags[k]} # set tag yang ADA di resource
	kurang := required - ada # set difference: wajib - punya = yang hilang
	count(kurang) > 0
	msg := sprintf("%s.%s kurang tag wajib: %v", [tipe, name, kurang])
}
