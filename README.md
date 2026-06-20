# AWS Setup — DevOps Learning Journey

Repo ini bagian dari perjalanan belajar DevOps saya — infrastruktur AWS yang dikelola **as-code** pakai **Terraform**. Fokusnya: remote state, reusable modules, multi-environment, dan jaringan VPC produksi-grade (public/private subnet + NAT).

> ⚠️ **Buat keperluan belajar/lab.** Beberapa setting sengaja longgar (mis. SSH `0.0.0.0/0`) demi kemudahan eksperimen — bukan konfigurasi produksi nyata.

## 📂 Struktur

```
.
├── tf-state-backend/      # Bootstrap: bikin S3 bucket buat nyimpen remote state
└── multienv-app/          # App infra multi-environment (staging + prod)
    ├── modules/
    │   ├── app-stack/     # Module reusable: EC2 + RDS + Security Group + EIP + DNS
    │   └── network/       # Module reusable: VPC + subnet + IGW + NAT + route table
    └── environments/
        ├── staging/       # Environment staging (instance kecil)
        └── prod/          # Environment prod (instance lebih besar)
```

### `tf-state-backend/`
Bikin S3 bucket (versioning + encryption + block public access) tempat semua proyek lain nyimpen state-nya. Pola **bootstrap**: dibuat duluan dengan state lokal, jadi fondasi remote state. Dibuat **sekali, permanen** (jangan di-destroy).

### `multienv-app/`
Pola **folder-per-environment** (standar industri) + **shared modules**:
- `modules/network/` — bikin VPC sendiri: 1 public subnet (web) + 2 private subnet (DB, 2 AZ), Internet Gateway, NAT Gateway, route table. DB subnet group buat RDS.
- `modules/app-stack/` — EC2 (di public subnet) + RDS (di private subnet, sembunyi) + Security Group + Elastic IP + Route53.
- `environments/{staging,prod}/` — tiap env manggil module yang **sama** dengan input beda (ukuran, domain), dan **state terpisah** (key S3 beda).

## 🧠 Konsep yang dipelajarin
- **Remote state** (S3 backend + native locking, tanpa DynamoDB)
- **Modules** — input (`variables`), body (`main`), output (`outputs`); komposisi module↔module
- **Multi-environment** — folder-per-env, state terpisah, anti-collision via prefix `${var.environment}`
- **VPC networking** — CIDR, public vs private subnet, Internet Gateway, **NAT Gateway** (outbound 1-arah), route table, db subnet group (multi-AZ)
- **Keamanan** — database di private subnet (gak kebuka internet), secret di `.tfvars` (gitignored)

## 🚀 Cara pakai

State backend (sekali, di awal):
```bash
cd tf-state-backend
terraform init
terraform apply
```

Per-environment:
```bash
cd multienv-app/environments/staging   # atau prod
cp terraform.tfvars.example terraform.tfvars   # isi password asli (gitignored)
terraform init
terraform plan
# terraform apply   # ⚠️ bikin resource berbayar (NAT/EC2/RDS) — destroy abis lab
```

## 🔒 Catatan keamanan
- `terraform.tfvars` (berisi password) **di-gitignore** — pakai `.tfvars.example` sebagai template.
- `*.tfstate` & `.terraform/` **di-gitignore**; `.terraform.lock.hcl` **di-commit** (kunci versi provider).
