#!/usr/bin/env bash
# =============================================================================
# lab03-check.sh — Review script for Lab 03: Sidecar + emptyDir
# Namespace: ckad-lab03
# Usage: bash week2/labs/checks/lab03-check.sh
# =============================================================================

NS="ckad-lab03"
POD="sidecar-demo"
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
echo " Lab 03 Review — Sidecar: shared emptyDir volume"
echo " Namespace: $NS"
echo "================================================================"

# ── 1. Pod exists ─────────────────────────────────────────────────
info "Check 1: Pod '$POD' exists in namespace '$NS'"
if kubectl get pod "$POD" -n "$NS" &>/dev/null; then
  pass "Pod '$POD' found"
else
  fail "Pod '$POD' not found" \
    "Apply: k apply -f week2/resources/lab03-sidecar-pod.yaml -n $NS"
fi

# ── 2. Pod has 2 containers ───────────────────────────────────────
info "Check 2: Pod has exactly 2 containers"
CONTAINER_COUNT=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.containers}' 2>/dev/null \
  | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
if [[ "$CONTAINER_COUNT" -eq 2 ]]; then
  pass "Pod has 2 containers"
else
  fail "Pod has $CONTAINER_COUNT container(s) (expected 2)" \
    "Add both 'writer' and 'log-reader' containers in the containers: list"
fi

# ── 3. Both containers are running (2/2) ──────────────────────────
info "Check 3: Both containers are Running (2/2 Ready)"
READY=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.status.containerStatuses[*].ready}' 2>/dev/null)
RUNNING_COUNT=$(echo "$READY" | tr ' ' '\n' | grep -c "true" || echo "0")
if [[ "$RUNNING_COUNT" -eq 2 ]]; then
  pass "Both containers are ready (2/2)"
else
  fail "Only $RUNNING_COUNT/2 containers are ready" \
    "Check: k describe pod $POD -n $NS — look at each container's state"
fi

# ── 4. An emptyDir volume is defined ─────────────────────────────
info "Check 4: Pod defines an emptyDir volume"
EMPTYDIR=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.volumes[*].emptyDir}' 2>/dev/null)
if [[ -n "$EMPTYDIR" ]]; then
  VOL_NAME=$(kubectl get pod "$POD" -n "$NS" \
    -o jsonpath='{.spec.volumes[?(@.emptyDir)].name}' 2>/dev/null)
  pass "emptyDir volume found: '$VOL_NAME'"
else
  fail "No emptyDir volume defined in pod spec" \
    "Add under volumes: - name: shared-logs\n  emptyDir: {}"
fi

# ── 5. Both containers mount the same volume ──────────────────────
info "Check 5: Both containers share the same volume (via volumeMounts)"
VOL_NAME=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.volumes[?(@.emptyDir)].name}' 2>/dev/null)

C0_MOUNT=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath="{.spec.containers[0].volumeMounts[?(@.name==\"$VOL_NAME\")].name}" 2>/dev/null)
C1_MOUNT=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath="{.spec.containers[1].volumeMounts[?(@.name==\"$VOL_NAME\")].name}" 2>/dev/null)

if [[ -n "$C0_MOUNT" && -n "$C1_MOUNT" ]]; then
  pass "Both containers mount volume '$VOL_NAME'"
elif [[ -n "$C0_MOUNT" ]]; then
  fail "Only container[0] mounts '$VOL_NAME' — container[1] does not" \
    "Add the same volumeMount (name: $VOL_NAME) to the second container"
elif [[ -n "$C1_MOUNT" ]]; then
  fail "Only container[1] mounts '$VOL_NAME' — container[0] does not" \
    "Add the same volumeMount (name: $VOL_NAME) to the first container"
else
  fail "Neither container mounts the emptyDir volume '$VOL_NAME'" \
    "Both containers need: volumeMounts: [{name: $VOL_NAME, mountPath: /var/log/app}]"
fi

# ── 6. Both mount at the same path ───────────────────────────────
info "Check 6: Both containers mount the volume at the same mountPath"
MP0=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath="{.spec.containers[0].volumeMounts[?(@.name==\"$VOL_NAME\")].mountPath}" 2>/dev/null)
MP1=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath="{.spec.containers[1].volumeMounts[?(@.name==\"$VOL_NAME\")].mountPath}" 2>/dev/null)
if [[ -n "$MP0" && "$MP0" == "$MP1" ]]; then
  pass "Both containers use mountPath: $MP0"
elif [[ -n "$MP0" && -n "$MP1" ]]; then
  fail "Containers mount at different paths: '$MP0' vs '$MP1'" \
    "Both containers should use the same mountPath so they share the same directory"
else
  fail "Could not verify mountPaths" \
    "Ensure volumeMounts are set in both containers"
fi

# ── 7. Sidecar is actually reading the shared file ────────────────
info "Check 7: Sidecar container has log output (is reading the shared file)"
SIDECAR_NAME=$(kubectl get pod "$POD" -n "$NS" \
  -o jsonpath='{.spec.containers[1].name}' 2>/dev/null)
SIDECAR_LOGS=$(kubectl logs "$POD" -n "$NS" -c "$SIDECAR_NAME" --tail=5 2>/dev/null)
if [[ -n "$SIDECAR_LOGS" ]]; then
  pass "Sidecar ('$SIDECAR_NAME') has log output"
  echo "    Last lines: $(echo "$SIDECAR_LOGS" | tail -2)"
else
  fail "Sidecar container '$SIDECAR_NAME' has no log output yet" \
    "Wait a few seconds and retry — the writer may still be starting up"
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
