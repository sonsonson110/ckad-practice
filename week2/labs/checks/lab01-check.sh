#!/usr/bin/env bash
# =============================================================================
# lab01-check.sh — Review script for Lab 01: Pod command, args, resources, env
# Namespace: ckad-lab01
# Usage: bash week2/labs/checks/lab01-check.sh
# =============================================================================

NS="ckad-lab01"
POD="date-pod"
PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

pass() { echo -e "${GREEN}  ✅ PASS${NC} — $1"; ((PASS++)); }
fail() { echo -e "${RED}  ❌ FAIL${NC} — $1"; echo -e "${YELLOW}     💡 Hint: $2${NC}"; ((FAIL++)); }
info() { echo -e "\n${YELLOW}▶ $1${NC}"; }

echo "================================================================"
echo " Lab 01 Review — Pod: command, args, resources, env"
echo " Namespace: $NS"
echo "================================================================"

# ── 1. Pod exists ──────────────────────────────────────────────────
info "Check 1: Pod '$POD' exists in namespace '$NS'"
if kubectl get pod "$POD" -n "$NS" &>/dev/null; then
  pass "Pod '$POD' found"
else
  fail "Pod '$POD' not found" \
    "Run: k run date-pod --image=busybox -n $NS -- sh -c 'while true; do sleep 3600; done'"
fi

# ── 2. Pod is Running ──────────────────────────────────────────────
info "Check 2: Pod is in Running state"
PHASE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PHASE" == "Running" ]]; then
  pass "Pod phase is Running"
else
  fail "Pod phase is '$PHASE' (expected Running)" \
    "Check events: k describe pod $POD -n $NS"
fi

# ── 3. Image is busybox ────────────────────────────────────────────
info "Check 3: Container image is busybox"
IMAGE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
if echo "$IMAGE" | grep -q "busybox"; then
  pass "Image is '$IMAGE'"
else
  fail "Image is '$IMAGE' (expected busybox)" \
    "Set image: busybox in your pod YAML"
fi

# ── 4. Custom command is set ───────────────────────────────────────
info "Check 4: Container has a custom command/args (not just default)"
CMD=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].command}' 2>/dev/null)
ARGS=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.containers[0].args}' 2>/dev/null)
if [[ -n "$CMD" || -n "$ARGS" ]]; then
  pass "Custom command/args found: command=$CMD args=$ARGS"
else
  fail "No custom command or args set" \
    "Add: command: ['sh', '-c', 'while true; do sleep 3600; done'] OR use -- in kubectl run"
fi

# ── 5. CPU request set ────────────────────────────────────────────
info "Check 5: CPU request is set"
CPU_REQ=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
if [[ -n "$CPU_REQ" ]]; then
  pass "CPU request: $CPU_REQ"
else
  fail "CPU request not set" \
    "Add resources.requests.cpu (e.g. '50m') to your container spec"
fi

# ── 6. Memory request set ─────────────────────────────────────────
info "Check 6: Memory request is set"
MEM_REQ=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.containers[0].resources.requests.memory}' 2>/dev/null)
if [[ -n "$MEM_REQ" ]]; then
  pass "Memory request: $MEM_REQ"
else
  fail "Memory request not set" \
    "Add resources.requests.memory (e.g. '64Mi') to your container spec"
fi

# ── 7. CPU limit set ──────────────────────────────────────────────
info "Check 7: CPU limit is set"
CPU_LIM=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
if [[ -n "$CPU_LIM" ]]; then
  pass "CPU limit: $CPU_LIM"
else
  fail "CPU limit not set" \
    "Add resources.limits.cpu (e.g. '200m') to your container spec"
fi

# ── 8. Memory limit set ───────────────────────────────────────────
info "Check 8: Memory limit is set"
MEM_LIM=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [[ -n "$MEM_LIM" ]]; then
  pass "Memory limit: $MEM_LIM"
else
  fail "Memory limit not set" \
    "Add resources.limits.memory (e.g. '128Mi') to your container spec"
fi

# ── 9. GREETING env var ───────────────────────────────────────────
info "Check 9: Env var GREETING=hello-ckad is set"
GREETING=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.containers[0].env[?(@.name=="GREETING")].value}' 2>/dev/null)
if [[ "$GREETING" == "hello-ckad" ]]; then
  pass "GREETING=$GREETING"
elif [[ -n "$GREETING" ]]; then
  fail "GREETING is '$GREETING' (expected 'hello-ckad')" \
    "Set env[name=GREETING].value to exactly 'hello-ckad'"
else
  fail "Env var GREETING not found" \
    "Add: env: [{name: GREETING, value: hello-ckad}] under your container spec"
fi

# ── Summary ───────────────────────────────────────────────────────
echo ""
echo "================================================================"
echo " Results: ${PASS} passed, ${FAIL} failed"
echo "================================================================"

if [[ "$FAIL" -eq 0 ]]; then
  echo -e "${GREEN}🎉 All checks passed! Cleaning up namespace '$NS'...${NC}"
  kubectl delete namespace "$NS" --force --grace-period=0 2>/dev/null
  echo -e "${GREEN}✅ Namespace '$NS' deleted. Ready for next lab!${NC}"
else
  echo -e "${RED}Fix the failing checks above, then re-run this script.${NC}"
  exit 1
fi
