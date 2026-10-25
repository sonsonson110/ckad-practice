#!/usr/bin/env bash
# Lab 01 Check — Rolling Update
# Namespace: ckad-lab11

NS="ckad-lab11"
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
echo "  Lab 01 — Rolling Update Check"
echo "  Namespace: $NS"
echo "========================================="
echo ""

# Check 1 — Deployment exists
if kubectl get deployment webapp -n "$NS" &>/dev/null; then
  pass "Deployment 'webapp' exists in namespace $NS"
else
  fail "Deployment 'webapp' not found in namespace $NS" \
    "Run: k create namespace $NS && k apply -f <your-deployment.yaml>"
fi

# Check 2 — 3 ready replicas
READY=$(kubectl get deployment webapp -n "$NS" -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ "$READY" == "3" ]]; then
  pass "Deployment 'webapp' has 3 ready replicas"
else
  fail "Expected 3 ready replicas, got: ${READY:-0}" \
    "Make sure spec.replicas is 3 and all pods are Running: k get pods -n $NS"
fi

# Check 3 — Image is nginx:1.21
IMAGE=$(kubectl get deployment webapp -n "$NS" \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$IMAGE" == "nginx:1.21" ]]; then
  pass "Deployment image is 'nginx:1.21'"
else
  fail "Expected image 'nginx:1.21', got: '${IMAGE:-none}'" \
    "Update the image: k set image deployment/webapp nginx=nginx:1.21 -n $NS"
fi

# Check 4 — maxSurge is 1
MAX_SURGE=$(kubectl get deployment webapp -n "$NS" \
  -o jsonpath='{.spec.strategy.rollingUpdate.maxSurge}' 2>/dev/null)
if [[ "$MAX_SURGE" == "1" ]]; then
  pass "maxSurge is set to 1"
else
  fail "Expected maxSurge=1, got: '${MAX_SURGE:-not set}'" \
    "Set spec.strategy.rollingUpdate.maxSurge: 1 in your Deployment manifest"
fi

# Check 5 — maxUnavailable is 0
MAX_UNAVAIL=$(kubectl get deployment webapp -n "$NS" \
  -o jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}' 2>/dev/null)
if [[ "$MAX_UNAVAIL" == "0" ]]; then
  pass "maxUnavailable is set to 0"
else
  fail "Expected maxUnavailable=0, got: '${MAX_UNAVAIL:-not set}'" \
    "Set spec.strategy.rollingUpdate.maxUnavailable: 0 in your Deployment manifest"
fi

# Check 6 — Rollout history has >= 2 revisions
REVISIONS=$(kubectl rollout history deployment/webapp -n "$NS" 2>/dev/null \
  | grep -c '^[0-9]')
if [[ "$REVISIONS" -ge 2 ]]; then
  pass "Rollout history has $REVISIONS revision(s) (expected >= 2)"
else
  fail "Rollout history has $REVISIONS revision(s) — expected at least 2" \
    "Perform an image update: k set image deployment/webapp nginx=nginx:1.21 -n $NS, then check: k rollout history deployment/webapp -n $NS"
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
