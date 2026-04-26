#!/bin/bash
# ##############################################################################
# DevSecOps Pipeline — Terraform Destroy Script
# Requires typing DESTROY to confirm before destroying infrastructure
# ##############################################################################

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${RED}║           ⚠️  TERRAFORM DESTROY — DEVSECOPS PIPELINE         ║${NC}"
echo -e "${RED}║                                                              ║${NC}"
echo -e "${RED}║  This will permanently delete ALL infrastructure:            ║${NC}"
echo -e "${RED}║    • EKS Cluster (devsecops-cluster)                        ║${NC}"
echo -e "${RED}║    • VPC + Subnets + NAT Gateway                            ║${NC}"
echo -e "${RED}║    • Security Groups                                        ║${NC}"
echo -e "${RED}║    • IAM Roles + Policies                                   ║${NC}"
echo -e "${RED}║    • ECR Repository + ALL images                            ║${NC}"
echo -e "${RED}║    • GitHub Actions OIDC Provider                           ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ── Show what will be destroyed ───────────────────────────────────────────────
echo -e "${CYAN}Running terraform plan -destroy to show what will be deleted...${NC}"
echo ""

cd "$(dirname "$0")/.." || exit 1

terraform plan \
  -destroy \
  -var-file="dev.tfvars" \
  -out=destroy.tfplan

echo ""

# ── Confirmation ──────────────────────────────────────────────────────────────
echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║                    ⚠️  FINAL WARNING                         ║${NC}"
echo -e "${YELLOW}║                                                              ║${NC}"
echo -e "${YELLOW}║  You are about to destroy ALL AWS infrastructure.            ║${NC}"
echo -e "${YELLOW}║  This action CANNOT be undone.                               ║${NC}"
echo -e "${YELLOW}║                                                              ║${NC}"
echo -e "${YELLOW}║  Type DESTROY to confirm or anything else to cancel:         ║${NC}"
echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
read -r -p "Confirmation: " confirmation

# ── Check confirmation ────────────────────────────────────────────────────────
if [ "$confirmation" != "DESTROY" ]; then
  echo ""
  echo -e "${GREEN}✅ Destroy cancelled — no changes were made.${NC}"
  echo ""
  rm -f destroy.tfplan
  exit 0
fi

# ── Run destroy ───────────────────────────────────────────────────────────────
echo ""
echo -e "${RED}🔥 Confirmed — destroying infrastructure...${NC}"
echo ""

terraform apply destroy.tfplan

# ── Cleanup ───────────────────────────────────────────────────────────────────
rm -f destroy.tfplan

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✅ Destroy Complete                             ║${NC}"
echo -e "${GREEN}║                                                              ║${NC}"
echo -e "${GREEN}║  All AWS infrastructure has been deleted.                    ║${NC}"
echo -e "${GREEN}║  Your code is safe in GitHub.                               ║${NC}"
echo -e "${GREEN}║  Run terraform apply to rebuild at any time.                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""