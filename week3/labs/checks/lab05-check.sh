#!/usr/bin/env bash
# Lab 05 Check — Helm Basics
# Namespace: ckad-lab15

NS="ckad-lab15"
PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✅ PASS${NC} — $1"; ((PASS++)); }
fail() { echo -e "${RED}❌ FAIL${NC} — $1"; echo -e "   ${YELLOW}💡 Hint:${NC} $2"; ((FAIL++)); }
info() { echo -e "${YELLOW}ℹ️  INFO${NC} — $1"; }

echo ""
echo "========================================="
echo "  Lab 05 — Helm Basics Check"
echo "  Namespace: $NS"
echo "========================================="
echo ""

# Check 1 — bitnami repo is configured
if helm repo list 2>/dev/null | grep -q 'bitnami'; then
  pass "Helm repo 'bitnami' is configured"
else
  fail "Helm repo 'bitnami' not found" \
    "Add the repo: helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update"
fi

# Check 2 — Release my-nginx exists in the namespace
if helm list -n "$NS" 2>/dev/null | grep -q 'my-nginx'; then
  pass "Helm release 'my-nginx' exists in namespace $NS"
else
  fail "Helm release 'my-nginx' not found in namespace $NS" \
    "Install the chart: helm install my-nginx bitnami/nginx -n $NS --set replicaCount=2"
fi

# Check 3 — Release status is deployed
RELEASE_STATUS=$(helm list -n "$NS" 2>/dev/null \
  | awk '/my-nginx/ {print $8}')
if [[ "$RELEASE_STATUS" == "deployed" ]]; then
  pass "Release 'my-nginx' status is 'deployed'"
else
  fail "Release status is '${RELEASE_STATUS:-unknown}', expected 'deployed'" \
    "Check release details: helm status my-nginx -n $NS"
fi

# Check 4 — A Deployment with my-nginx or nginx in its name has 3 ready replicas
# Find the deployment belonging to the release
DEPLOY_NAME=$(kubectl get deployments -n "$NS" \
  -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' 2>/dev/null \
  | grep -E 'my-nginx|nginx' | head -1)
if [[ -z "$DEPLOY_NAME" ]]; then
  fail "No Deployment containing 'nginx' or 'my-nginx' found in namespace $NS" \
    "Ensure the release is installed: helm list -n $NS"
else
  READY=$(kubectl get deployment "$DEPLOY_NAME" -n "$NS" \
    -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
  if [[ "$READY" == "3" ]]; then
    pass "Deployment '$DEPLOY_NAME' has 3 ready replicas (upgrade confirmed)"
  else
    fail "Expected 3 ready replicas for '$DEPLOY_NAME', got: ${READY:-0}" \
      "Upgrade the release: helm upgrade my-nginx bitnami/nginx -n $NS --set replicaCount=3"
  fi
fi

# Check 5 — Deployment name contains my-nginx or nginx
if [[ -n "$DEPLOY_NAME" ]]; then
  pass "Deployment '$DEPLOY_NAME' found (name contains 'nginx')"
else
  fail "Could not identify the nginx deployment in namespace $NS" \
    "List deployments: k get deployments -n $NS"
fi

echo ""
echo "========================================="
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "========================================="
echo ""

if [[ "$FAIL" -eq 0 ]]; then
  echo -e "${GREEN}🎉 All checks passed! Cleaning up release and namespace...${NC}"
  helm uninstall my-nginx -n "$NS" && \
    kubectl delete namespace "$NS" --force --grace-period=0
  exit 0
else
  echo -e "${RED}Some checks failed. Fix the issues above and re-run this script.${NC}"
  exit 1
fi
