#!/usr/bin/env bash
# Lab 03 Check — Blue/Green Deployment
# Namespace: ckad-lab13

NS="ckad-lab13"
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
echo "  Lab 03 — Blue/Green Deployment Check"
echo "  Namespace: $NS"
echo "========================================="
echo ""

# Check 1 — Blue deployment exists with version=blue label on pod template
BLUE_VERSION=$(kubectl get deployment myapp-blue -n "$NS" \
  -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
if [[ "$BLUE_VERSION" == "blue" ]]; then
  pass "Deployment 'myapp-blue' exists with pod template label 'version=blue'"
else
  fail "Deployment 'myapp-blue' not found or missing label 'version=blue' on pod template (got: '${BLUE_VERSION:-none}')" \
    "Check your blue Deployment manifest: the pod template labels must include 'version: blue'"
fi

# Check 2 — Green deployment exists with version=green label on pod template
GREEN_VERSION=$(kubectl get deployment myapp-green -n "$NS" \
  -o jsonpath='{.spec.template.metadata.labels.version}' 2>/dev/null)
if [[ "$GREEN_VERSION" == "green" ]]; then
  pass "Deployment 'myapp-green' exists with pod template label 'version=green'"
else
  fail "Deployment 'myapp-green' not found or missing label 'version=green' on pod template (got: '${GREEN_VERSION:-none}')" \
    "Check your green Deployment manifest: the pod template labels must include 'version: green'"
fi

# Check 3 — Service myapp-svc exists
if kubectl get service myapp-svc -n "$NS" &>/dev/null; then
  pass "Service 'myapp-svc' exists"
else
  fail "Service 'myapp-svc' not found in namespace $NS" \
    "Apply your service manifest: k apply -f <service.yaml> -n $NS"
fi

# Check 4 — Service selector points to version=green
SVC_VERSION=$(kubectl get service myapp-svc -n "$NS" \
  -o jsonpath='{.spec.selector.version}' 2>/dev/null)
if [[ "$SVC_VERSION" == "green" ]]; then
  pass "Service 'myapp-svc' selector has 'version=green' (cutover complete)"
else
  fail "Service selector 'version' is '${SVC_VERSION:-not set}', expected 'green'" \
    "Patch the service: k patch svc myapp-svc -n $NS -p '{\"spec\":{\"selector\":{\"app\":\"myapp\",\"version\":\"green\"}}}'"
fi

# Check 5 — Green deployment has 3 ready replicas
GREEN_READY=$(kubectl get deployment myapp-green -n "$NS" \
  -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ "$GREEN_READY" == "3" ]]; then
  pass "Deployment 'myapp-green' has 3 ready replicas"
else
  fail "Expected 3 ready replicas for 'myapp-green', got: ${GREEN_READY:-0}" \
    "Check pod status: k get pods -n $NS -l version=green"
fi

# Check 6 — Green pods are running nginx:1.21
GREEN_IMAGE=$(kubectl get deployment myapp-green -n "$NS" \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$GREEN_IMAGE" == "nginx:1.21" ]]; then
  pass "Green deployment is running image 'nginx:1.21'"
else
  fail "Expected 'myapp-green' to use image 'nginx:1.21', got: '${GREEN_IMAGE:-none}'" \
    "Check your green Deployment manifest: spec.template.spec.containers[0].image should be nginx:1.21"
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
