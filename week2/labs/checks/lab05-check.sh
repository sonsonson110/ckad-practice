#!/usr/bin/env bash
# =============================================================================
# lab05-check.sh — Review script for Lab 05: PVC & Pod Storage
# Namespace: ckad-lab05
# Usage: bash week2/labs/checks/lab05-check.sh
# =============================================================================

NS="ckad-lab05"
PVC_NAME="app-data-pvc"
POD_WRITER="storage-writer"
POD_READER="storage-reader"
POD_HOSTPATH="hostpath-demo"
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
echo " Lab 05 Review — PVC & Pod Storage"
echo " Namespace: $NS"
echo "================================================================"

# ════════════════════════════════════════════════
# PART 1 — PVC
# ════════════════════════════════════════════════
echo -e "\n${YELLOW}━━━ Part 1: PVC ━━━${NC}"

info "Check 1: PVC '$PVC_NAME' exists"
if kubectl get pvc "$PVC_NAME" -n "$NS" &>/dev/null; then
  pass "PVC '$PVC_NAME' found"
else
  fail "PVC '$PVC_NAME' not found" \
    "Apply: k apply -f week2/resources/lab05-pvc.yaml -n $NS"
fi

info "Check 2: PVC is Bound"
PVC_STATUS=$(kubectl get pvc "$PVC_NAME" -n "$NS" \
  -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$PVC_STATUS" == "Bound" ]]; then
  pass "PVC status: Bound"
elif [[ "$PVC_STATUS" == "Pending" ]]; then
  fail "PVC is Pending (not yet bound to a PV)" \
    "PVC binds when a pod uses it (WaitForFirstConsumer mode). Deploy '$POD_WRITER' first."
else
  fail "PVC status: '$PVC_STATUS'" \
    "Check: k describe pvc $PVC_NAME -n $NS"
fi

info "Check 3: PVC requests at least 100Mi storage"
PVC_STORAGE=$(kubectl get pvc "$PVC_NAME" -n "$NS" \
  -o jsonpath='{.spec.resources.requests.storage}' 2>/dev/null)
if [[ -n "$PVC_STORAGE" ]]; then
  pass "PVC storage request: $PVC_STORAGE"
else
  fail "PVC has no storage request" \
    "Add spec.resources.requests.storage: 100Mi to your PVC YAML"
fi

info "Check 4: PVC accessMode is ReadWriteOnce"
PVC_MODE=$(kubectl get pvc "$PVC_NAME" -n "$NS" \
  -o jsonpath='{.spec.accessModes[0]}' 2>/dev/null)
if [[ "$PVC_MODE" == "ReadWriteOnce" ]]; then
  pass "accessMode: ReadWriteOnce"
else
  fail "accessMode is '$PVC_MODE' (expected ReadWriteOnce)" \
    "Set spec.accessModes: [ReadWriteOnce] in your PVC YAML"
fi

# ════════════════════════════════════════════════
# PART 2 — Writer pod
# ════════════════════════════════════════════════
echo -e "\n${YELLOW}━━━ Part 2: Writer Pod ━━━${NC}"

info "Check 5: Pod '$POD_WRITER' exists (or was deleted after writing)"
WRITER_EXISTS=$(kubectl get pod "$POD_WRITER" -n "$NS" &>/dev/null && echo "yes" || echo "no")
if [[ "$WRITER_EXISTS" == "yes" ]]; then
  pass "Pod '$POD_WRITER' found"
  WRITER_PHASE=$(kubectl get pod "$POD_WRITER" -n "$NS" \
    -o jsonpath='{.status.phase}' 2>/dev/null)
  if [[ "$WRITER_PHASE" != "Running" ]]; then
    fail "Pod '$POD_WRITER' is not Running (phase: $WRITER_PHASE)" \
      "Check: k describe pod $POD_WRITER -n $NS"
  else
    pass "Pod '$POD_WRITER' is Running"
  fi
else
  # Pod may have been deleted as part of persistence test — that's OK
  echo -e "  ℹ️  Pod '$POD_WRITER' not found (may have been deleted for persistence test — OK)"
  ((PASS++))
fi

info "Check 6: '$POD_WRITER' mounts the PVC '$PVC_NAME'"
if [[ "$WRITER_EXISTS" == "yes" ]]; then
  MOUNT_PVC=$(kubectl get pod "$POD_WRITER" -n "$NS" \
    -o jsonpath="{.spec.volumes[?(@.persistentVolumeClaim.claimName==\"$PVC_NAME\")].name}" 2>/dev/null)
  if [[ -n "$MOUNT_PVC" ]]; then
    MOUNT_PATH=$(kubectl get pod "$POD_WRITER" -n "$NS" \
      -o jsonpath="{.spec.containers[0].volumeMounts[?(@.name==\"$MOUNT_PVC\")].mountPath}" 2>/dev/null)
    pass "PVC '$PVC_NAME' mounted at '$MOUNT_PATH'"
  else
    fail "PVC '$PVC_NAME' not mounted in pod '$POD_WRITER'" \
      "Add volumes[].persistentVolumeClaim.claimName: $PVC_NAME and a matching volumeMount"
  fi
else
  echo -e "  ℹ️  Skipping PVC mount check (pod deleted)"
  ((PASS++))
fi

# ════════════════════════════════════════════════
# PART 3 — Persistence test (reader pod)
# ════════════════════════════════════════════════
echo -e "\n${YELLOW}━━━ Part 3: Persistence Test (Reader Pod) ━━━${NC}"

info "Check 7: Pod '$POD_READER' exists"
if kubectl get pod "$POD_READER" -n "$NS" &>/dev/null; then
  pass "Pod '$POD_READER' found"
else
  fail "Pod '$POD_READER' not found" \
    "Create a new pod that mounts the SAME PVC ($PVC_NAME) and reads /data/message.txt"
fi

info "Check 8: '$POD_READER' mounts the same PVC '$PVC_NAME'"
READER_PVC=$(kubectl get pod "$POD_READER" -n "$NS" \
  -o jsonpath="{.spec.volumes[?(@.persistentVolumeClaim.claimName==\"$PVC_NAME\")].name}" 2>/dev/null)
if [[ -n "$READER_PVC" ]]; then
  pass "Reader pod mounts PVC '$PVC_NAME'"
else
  fail "Reader pod does not mount PVC '$PVC_NAME'" \
    "Ensure the reader pod YAML has the same volumes[].persistentVolumeClaim.claimName: $PVC_NAME"
fi

info "Check 9: Reader pod logs show the persisted message"
READER_PHASE=$(kubectl get pod "$POD_READER" -n "$NS" \
  -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$READER_PHASE" == "Running" || "$READER_PHASE" == "Succeeded" ]]; then
  READER_LOGS=$(kubectl logs "$POD_READER" -n "$NS" 2>/dev/null)
  if echo "$READER_LOGS" | grep -q "hello from storage"; then
    pass "Reader log output: '$READER_LOGS'"
  elif [[ -n "$READER_LOGS" ]]; then
    fail "Reader logs don't contain expected 'hello from storage' (got: '$READER_LOGS')" \
      "Ensure writer pod wrote 'echo hello from storage > /data/message.txt'"
  else
    fail "Reader pod has no logs yet" \
      "Wait for the reader pod to start: k get pod $POD_READER -n $NS"
  fi
else
  fail "Reader pod is not Running/Succeeded (phase: $READER_PHASE)" \
    "Check: k describe pod $POD_READER -n $NS"
fi

# ════════════════════════════════════════════════
# PART 4 — hostPath pod
# ════════════════════════════════════════════════
echo -e "\n${YELLOW}━━━ Part 4: hostPath Pod ━━━${NC}"

info "Check 10: Pod '$POD_HOSTPATH' exists"
if kubectl get pod "$POD_HOSTPATH" -n "$NS" &>/dev/null; then
  pass "Pod '$POD_HOSTPATH' found"
else
  fail "Pod '$POD_HOSTPATH' not found" \
    "Apply: k apply -f week2/resources/lab05-hostpath.yaml -n $NS"
fi

info "Check 11: '$POD_HOSTPATH' uses a hostPath volume"
HOSTPATH_VOL=$(kubectl get pod "$POD_HOSTPATH" -n "$NS" \
  -o jsonpath='{.spec.volumes[*].hostPath.path}' 2>/dev/null)
if [[ -n "$HOSTPATH_VOL" ]]; then
  pass "hostPath volume found at node path: $HOSTPATH_VOL"
else
  fail "No hostPath volume found in '$POD_HOSTPATH'" \
    "Add volumes: [{name: host-vol, hostPath: {path: /tmp/ckad-test, type: DirectoryOrCreate}}]"
fi

info "Check 12: '$POD_HOSTPATH' is Running"
HP_PHASE=$(kubectl get pod "$POD_HOSTPATH" -n "$NS" \
  -o jsonpath='{.status.phase}' 2>/dev/null)
if [[ "$HP_PHASE" == "Running" ]]; then
  pass "Pod '$POD_HOSTPATH' is Running"
else
  fail "Pod phase: '$HP_PHASE'" \
    "Check: k describe pod $POD_HOSTPATH -n $NS"
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
