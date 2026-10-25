#!/usr/bin/env bash
# Lab 04 Check — Canary Deployment
# Namespace: ckad-lab14

NS="ckad-lab14"
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
echo "  Lab 04 — Canary Deployment Check"
echo "  Namespace: $NS"
echo "========================================="
echo ""

# Check 1 — frontend-stable has 9 ready replicas
STABLE_READY=$(kubectl get deployment frontend-stable -n "$NS" \
  -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ "$STABLE_READY" == "9" ]]; then
  pass "Deployment 'frontend-stable' has 9 ready replicas"
else
  fail "Expected 9 ready replicas for 'frontend-stable', got: ${STABLE_READY:-0}" \
    "Check your stable Deployment: k get deployment frontend-stable -n $NS"
fi

# Check 2 — frontend-canary has 1 ready replica
CANARY_READY=$(kubectl get deployment frontend-canary -n "$NS" \
  -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [[ "$CANARY_READY" == "1" ]]; then
  pass "Deployment 'frontend-canary' has 1 ready replica"
else
  fail "Expected 1 ready replica for 'frontend-canary', got: ${CANARY_READY:-0}" \
    "Check your canary Deployment: k get deployment frontend-canary -n $NS"
fi

# Check 3 — Service frontend-svc exists with selector app=frontend
SVC_APP=$(kubectl get service frontend-svc -n "$NS" \
  -o jsonpath='{.spec.selector.app}' 2>/dev/null)
if [[ "$SVC_APP" == "frontend" ]]; then
  pass "Service 'frontend-svc' exists with selector 'app=frontend'"
else
  fail "Service 'frontend-svc' not found or selector 'app' is '${SVC_APP:-not set}'" \
    "Apply your service manifest; selector must include 'app: frontend'"
fi

# Check 4 — Service selector does NOT have the 'track' key
TRACK_VAL=$(kubectl get service frontend-svc -n "$NS" \
  -o jsonpath='{.spec.selector.track}' 2>/dev/null)
if [[ -z "$TRACK_VAL" ]]; then
  pass "Service selector does NOT include the 'track' key (correct — hits both stable and canary)"
else
  fail "Service selector includes 'track=${TRACK_VAL}' — it should NOT include 'track'" \
    "Edit the service and remove the 'track' key from spec.selector so all frontend pods receive traffic"
fi

# Check 5 — frontend-stable pods have image nginx:1.20
STABLE_IMAGE=$(kubectl get deployment frontend-stable -n "$NS" \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$STABLE_IMAGE" == "nginx:1.20" ]]; then
  pass "Stable deployment is running image 'nginx:1.20'"
else
  fail "Expected 'frontend-stable' to use 'nginx:1.20', got: '${STABLE_IMAGE:-none}'" \
    "Check your stable Deployment manifest: containers[0].image should be nginx:1.20"
fi

# Check 6 — frontend-canary pods have image nginx:1.21
CANARY_IMAGE=$(kubectl get deployment frontend-canary -n "$NS" \
  -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [[ "$CANARY_IMAGE" == "nginx:1.21" ]]; then
  pass "Canary deployment is running image 'nginx:1.21'"
else
  fail "Expected 'frontend-canary' to use 'nginx:1.21', got: '${CANARY_IMAGE:-none}'" \
    "Check your canary Deployment manifest: containers[0].image should be nginx:1.21"
fi

# Check 7 — Service has 10 total endpoints (9 stable + 1 canary)
ENDPOINT_COUNT=$(kubectl get endpoints frontend-svc -n "$NS" \
  -o jsonpath='{range .subsets[*]}{range .addresses[*]}{.ip}{"\n"}{end}{end}' 2>/dev/null \
  | grep -c '.' || echo "0")
if [[ "$ENDPOINT_COUNT" -eq 10 ]]; then
  pass "Service 'frontend-svc' has 10 endpoints (9 stable + 1 canary)"
else
  fail "Expected 10 endpoints, got: ${ENDPOINT_COUNT}" \
    "Ensure all pods are Running and the service selector matches: k get endpoints frontend-svc -n $NS"
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
