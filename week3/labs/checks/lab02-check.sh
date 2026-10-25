#!/usr/bin/env bash
# Lab 02 Check — Recreate Strategy
# Namespace: ckad-lab12

NS="ckad-lab12"
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
echo "  Lab 02 — Recreate Strategy Check"
echo "  Namespace: $NS"
echo "========================================="
echo ""

# Check 1 — Deployment exists
if kubectl get deployment batch-app -n "$NS" &>/dev/null; then
  pass "Deployment 'batch-app' exists in namespace $NS"
else
  fail "Deployment 'batch-app' not found in namespace $NS" \
    "Run: k create namespace $NS && k apply -f <your-deployment.yaml>"
fi

# Check 2 — Strategy type is Recreate
STRATEGY=$(kubectl get deployment batch-app -n "$NS" \
  -o jsonpath='{.spec.strategy.type}' 2>/dev/null)
if [[ "$STRATEGY" == "Recreate" ]]; then
  pass "Deployment strategy is 'Recreate'"
else
  fail "Expected strategy 'Recreate', got: '${STRATEGY:-not set}'" \
    "Set spec.strategy.type: Recreate in your manifest (remove rollingUpdate block if present)"
fi

# Check 3 — Image is nginx:1.21
IMAGE=$(kubectl get deployment batch-app -n "$NS" \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "nginx:1.21" ]]; then
  pass "Deployment image is 'nginx:1.21'"
else
  fail "Expected image 'nginx:1.21', got: '${IMAGE:-none}'" \
    "Update the image: k set image deployment/batch-app nginx=nginx:1.21 -n $NS"
fi

# Check 4 — 2 ready replicas
READY=$(kubectl get deployment batch-app -n "$NS" \
  -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ "$READY" == "2" ]]; then
  pass "Deployment 'batch-app' has 2 ready replicas"
else
  fail "Expected 2 ready replicas, got: ${READY:-0}" \
    "Check pod status: k get pods -n $NS"
fi

# Check 5 — No pods running the old image nginx:1.20
OLD_PODS=$(kubectl get pods -n "$NS" \
  -o jsonpath='{range .items[*]}{.spec.containers[0].image}{"\n"}{end}' 2>/dev/null \
  | grep -c "nginx:1.20" || true)
if [[ "$OLD_PODS" -eq 0 ]]; then
  pass "No pods are running the old image 'nginx:1.20'"
else
  fail "$OLD_PODS pod(s) still running 'nginx:1.20'" \
    "Wait for rollout to complete: k rollout status deployment/batch-app -n $NS"
fi

echo ""
echo "========================================="
echo "  Results: ${PASS} passed, ${FAIL} failed"
echo "========================================="
echo ""

if [[ "$FAIL" -eq 0 ]]; then
  echo -e "${GREEN}🎉 All checks passed! Cleaning up namespace $NS...${NC}"
  kubectl delete namespace "$NS" --force --grace-period=0
  exit 0
else
  echo -e "${RED}Some checks failed. Fix the issues above and re-run this script.${NC}"
  exit 1
fi
