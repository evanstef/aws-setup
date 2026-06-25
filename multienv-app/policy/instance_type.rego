package main

# instance type harus dari allowlist
allowed := {"t3.micro", "t3.medium", "t3.small"}

deny contains msg if {
	ec2 := input.resource.aws_instance[name][_]
	not allowed[ec2.instance_type]
	msg := sprintf("Instance '%s' pakai tipe '%s' — di luar allowlist", [name, ec2.instance_type])
}
