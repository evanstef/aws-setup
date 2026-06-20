# AWS Infrastructure — Terraform

Infrastructure-as-code untuk aplikasi yang di-host di AWS, dikelola dengan **Terraform**. Mencakup remote state, reusable modules, multi-environment (staging & prod), dan jaringan VPC dengan isolasi public/private subnet + NAT Gateway.

## 📂 Struktur

```
.
├── tf-state-backend/      # S3 bucket buat nyimpen remote state
└── multienv-app/          # Infra aplikasi multi-environment (staging + prod)
    ├── modules/
    │   ├── app-stack/     # EC2 + RDS + Security Group + EIP + DNS
    │   └── network/       # VPC + subnet + IGW + NAT + route table
    └── environments/
        ├── staging/       # Environment staging
        └── prod/          # Environment prod
```

### `tf-state-backend/`
Bikin S3 bucket (versioning + encryption + block public access) tempat semua proyek nyimpen state. Pola bootstrap: dibuat sekali, jadi fondasi remote state.

### `multienv-app/`
Pola **folder-per-environment** + **shared modules**:
- `modules/network/` — VPC sendiri: 1 public subnet (web) + 2 private subnet (DB, 2 AZ), Internet Gateway, NAT Gateway, route table, DB subnet group.
- `modules/app-stack/` — EC2 di public subnet + RDS di private subnet (terisolasi dari internet) + Security Group + Elastic IP + Route53.
- `environments/{staging,prod}/` — tiap env manggil module yang sama dengan input beda (ukuran, domain), state terpisah (key S3 beda).

## 🏗️ Arsitektur jaringan

```
Internet → Internet Gateway → Public subnet  (EC2 web, NAT Gateway)
                                    │
                              Private subnet  (RDS — keluar lewat NAT, gak bisa diakses dari internet)
```

## 🚀 Cara pakai

State backend (sekali, di awal):
```bash
cd tf-state-backend
terraform init && terraform apply
```

Per-environment:
```bash
cd multienv-app/environments/staging   # atau prod
cp terraform.tfvars.example terraform.tfvars   # isi password (gitignored)
terraform init
terraform plan
terraform apply
```

## 🔒 Keamanan
- Database di private subnet — tidak ter-ekspos ke internet.
- `terraform.tfvars` (berisi password) di-gitignore — pakai `.tfvars.example` sebagai template.
- `*.tfstate` & `.terraform/` di-gitignore; `.terraform.lock.hcl` di-commit (kunci versi provider).
