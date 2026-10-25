#!/usr/bin/env bash
# =============================================================================
# lab02-check.sh — Review script for Lab 02: Init Container
# Namespace: ckad-lab02
# Usage: bash week2/labs/checks/lab02-check.sh
# =============================================================================

NS="ckad-lab02"
POD="webapp"
SVC="mydb"
PASS=0
FAIL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}  ✅ PASS${NC} — $1"; ((PASS++)); }
fail() { echo -e "${RED}  ❌ FAIL${NC} — $1"; echo -e "${YELLOW}     💡 Hint: $2${NC}"; ((FAIL++)); }
info() { echo -e "\n${YELLOW}▶ $1${NC}"; }

echo "================================================================"
echo " Lab 02 Review — Init Container: wait-for-service"
echo " Namespace: $NS"
echo "================================================================"

# ── 1. Pod exists ─────────────────────────────────────────────────
info "Check 1: Pod '$POD' exists in namespace '$NS'"
if kubectl get pod "$POD" -n "$NS" &>/dev/null; then
  pass "Pod '$POD' found"
else
  fail "Pod '$POD' not found" \
    "Apply your pod YAML with: k apply -f week2/resources/lab02-init-pod.yaml"
fi

# ── 2. Pod is Running ─────────────────────────────────────────────
info "Check 2: Pod is in Running state (init container completed)"
PHASE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PHASE" == "Running" ]]; then
  pass "Pod phase is Running"
elif [[ "$PHASE" == "Pending" ]]; then
  INIT_STATE=$(kubectl get pod "$POD" -n "$NS" \
    -o jsonpath='{.status.initContainerStatuses[0].state.waiting.reason}' 2>/dev/null)
  fail "Pod is Pending — init container is likely still waiting (reason: $INIT_STATE)" \
    "Create the '$SVC' service: k create service clusterip $SVC --tcp=5432:5432 -n $NS"
else
  fail "Pod phase is '$PHASE'" \
    "Check: k describe pod $POD -n $NS"
fi

# ── 3. Init container exists ──────────────────────────────────────
info "Check 3: Pod has at least one init container"
INIT_COUNT=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.initContainers}' 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(len(d))" 2>/dev/null || echo "0")
if [[ "$INIT_COUNT" -ge 1 ]]; then
  INIT_NAME=$(kubectl get pod "$POD" -n "$NS" \
    -o jsonpath='{.spec.initContainers[0].name}' 2>/dev/null)
  pass "Found $INIT_COUNT init container(s) — first: '$INIT_NAME'"
else
  fail "No init containers found in pod spec" \
    "Add an initContainers: section at the same level as containers: in your pod YAML"
fi

# ── 4. Init container image is busybox ────────────────────────────
info "Check 4: Init container uses busybox image"
INIT_IMG=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.initContainers[0].image}' 2>/dev/null)
if echo "$INIT_IMG" | grep -q "busybox"; then
  pass "Init container image: $INIT_IMG"
else
  fail "Init container image is '$INIT_IMG' (expected busybox)" \
    "Set initContainers[0].image to busybox"
fi

# ── 5. Init container uses nslookup ───────────────────────────────
info "Check 5: Init container command includes 'nslookup' (DNS wait pattern)"
INIT_CMD=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.initContainers[0].command}' 2>/dev/null)
INIT_ARGS=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.initContainers[0].args}' 2>/dev/null)
FULL_CMD="$INIT_CMD $INIT_ARGS"
if echo "$FULL_CMD" | grep -q "nslookup"; then
  pass "Init container uses nslookup DNS check"
else
  fail "Init container does not use nslookup" \
    "Use: command: ['sh', '-c', 'until nslookup mydb.$NS.svc.cluster.local; do sleep 2; done']"
fi

# ── 6. Main container image is nginx ─────────────────────────────
info "Check 6: Main container uses nginx image"
MAIN_IMG=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.containers[0].image}' 2>/dev/null)
if echo "$MAIN_IMG" | grep -q "nginx"; then
  pass "Main container image: $MAIN_IMG"
else
  fail "Main container image is '$MAIN_IMG' (expected nginx)" \
    "Set containers[0].image to nginx"
fi

# ── 7. Service mydb exists ────────────────────────────────────────
info "Check 7: Service '$SVC' exists in namespace '$NS'"
if kubectl get service "$SVC" -n "$NS" &>/dev/null; then
  pass "Service '$SVC' found"
else
  fail "Service '$SVC' not found" \
    "Create it: k create service clusterip $SVC --tcp=5432:5432 -n $NS"
fi

# ── 8. Init container completed successfully ──────────────────────
info "Check 8: Init container exited with code 0 (completed)"
INIT_READY=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.status.initContainerStatuses[0].state.terminated.exitCode}' 2>/dev/null)
if [[ "$INIT_READY" == "0" ]]; then
  pass "Init container completed with exit code 0"
else
  fail "Init container has not completed successfully (exitCode: '$INIT_READY')" \
    "Ensure the '$SVC' service exists so nslookup succeeds"
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
