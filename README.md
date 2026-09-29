# abd-cloud-params

Environment-specific configuration for the AbD Cloud infrastructure platform. Contains no Terraform logic — only `*.tfvars` and `*_config.sh` files consumed by the `abd-cloud` template runner.

## Structure

```
global_config.sh / global_config.tfvars     Platform-wide defaults (tags, region)
├── abd-global/                             Management account (813984516777)
│   ├── account_config.sh/.tfvars          Account identity and global settings
│   ├── account-global/                    Account-level resources
│   │   ├── cloudtrail/                    CloudTrail configuration
│   │   ├── dynamodb/terraform/            Terraform state lock table
│   │   └── s3/
│   │       ├── access-log/               S3 access logging bucket
│   │       └── lambda/                   Lambda artefact bucket
│   └── services-vpc/                      Shared services VPC
│
└── abd-wordpress/                         WordPress account (800653036500)
    ├── account_config.sh/.tfvars         Account identity and Docker registry
    ├── account-global/                   Account-level resources
    │   ├── cloudtrail/
    │   └── s3/
    │       ├── access-log/
    │       └── lambda/
    └── wordpress-vpc/                    WordPress VPC and all hosted workloads
        ├── vpc-peering/                  Cross-account peering to services-vpc
        ├── database/                     Aurora MySQL cluster
        ├── storage/
        │   ├── efs/                      Shared WordPress media storage
        │   └── s3/                       Application S3 buckets
        ├── application/                  EC2 ASG WordPress application tier
        ├── app-ecs/                      ECS Fargate (prevented — future use)
        └── hosted-sites/                 Per-domain DNS, SSL, and ALB configuration
            ├── analysisbydesign.co.uk/
            ├── abd.training/
            ├── oranjj.uk/
            ├── baltihot.co.uk/
            ├── daverix.uk/
            ├── blacklit.uk/
            ├── amyegillin.uk/
            └── rixinteriors.co.uk/
```

## Configuration Cascade

`tf-run.sh` walks from the target resource path up to the params root, sourcing each `*_config.sh` and accumulating `*.tfvars` files as it goes. Values at deeper levels override those above.

```
global_config.sh/.tfvars         ← common_tag_owner, region, etc.
└── account_config.sh/.tfvars   ← account CIDR, account ID, Docker registry
    └── resource_config.sh      ← build_resources, statefile_basename, resource vars
```

Each `*_config.sh` sets at minimum:
- `build_resources` — the template path under `tf-templates/` to run
- `statefile_basename` — unique identifier for this resource's S3 state key

## Build Sequence

[`sequence/prod.csv`](sequence/prod.csv) defines the priority order for `tf-run-all.sh`. Format:

```
priority,protect,prevent,resource_path
1000,protect,,abd-global
2000,protect,,abd-wordpress/wordpress-vpc
```

- `protect` — prevents accidental `terraform destroy` without the `-o` override flag
- `prevent` — skips this resource entirely in all operations

## Adding a New Resource

1. Create a directory under the appropriate account path
2. Add `resource_config.sh` setting `build_resources`, `statefile_basename`, and any `TF_VAR_*` exports
3. Add a `resource_config.tfvars` with module inputs
4. Add an entry to `sequence/prod.csv` at the appropriate priority

## Adding a Developer DNS Zone

Each Tulox developer has a zone `<initials>.tulox.uk`, delegated from `tulox.uk` and pointing at their machine's Tailscale address, plus an IAM user for Caddy's ACME DNS-01 challenge. `hosted-sites/dr.tulox.uk` is the reference copy.

1. Copy the reference directory, leaving its Terraform cache behind:

   ```bash
   cd abd-wordpress/wordpress-vpc/hosted-sites
   mkdir xx.tulox.uk
   cp dr.tulox.uk/dns_config.sh dr.tulox.uk/dns_config.tfvars xx.tulox.uk/
   ```

   Do not copy `.terraform/` - it holds the state key of the zone it was copied from.

2. In `xx.tulox.uk/dns_config.sh` change the state key:

   ```bash
   statefile_basename="${vpc_name}/public-zones/xx.tulox.uk"
   ```

3. In `xx.tulox.uk/dns_config.tfvars` change:

   | Setting | Value |
   | --- | --- |
   | `public_sub_domain` | `"xx"` |
   | `delegate_set_name` | `"xxtuloxuk"` |
   | `dns_extra` | both `value` entries to the Tailscale IPv4 address |
   | `dns_challenge_user_name` | `"tulox-caddy-dns-xx"` |

4. Add the directory to `sequence/prod.csv` at priority 5000.

5. From the `abd-cloud` directory, plan, review, then apply:

   ```bash
   aws-vault exec abd_global -- ./tf-run.sh ../abd-cloud-params/abd-wordpress/wordpress-vpc/hosted-sites/xx.tulox.uk plan
   aws-vault exec abd_global -- ./tf-run.sh ../abd-cloud-params/abd-wordpress/wordpress-vpc/hosted-sites/xx.tulox.uk apply
   ```

6. Create the access key by hand and paste it into that machine's local Laravel `.env`. It is never created by Terraform, as the secret would land in state:

   ```bash
   aws iam create-access-key --user-name tulox-caddy-dns-xx
   ```

7. Verify from any machine:

   ```bash
   dig +short NS xx.tulox.uk        # four awsdns name servers
   dig +short xx.tulox.uk           # the Tailscale address
   dig +short anything.xx.tulox.uk  # the Tailscale address
   ```

`dev.tulox.uk` and its hand-created IAM user belong to a different machine and are not managed by this process.

## Pre-commit

```bash
pip install pre-commit
pre-commit install
```

Enforces `terraform fmt` on all `*.tfvars` files and `shellcheck` on all `*_config.sh` scripts. See [.pre-commit-config.yaml](.pre-commit-config.yaml).
