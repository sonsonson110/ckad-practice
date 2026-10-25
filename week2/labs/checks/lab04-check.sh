#!/usr/bin/env bash
# =============================================================================
# lab04-check.sh — Review script for Lab 04: Jobs & CronJobs
# Namespace: ckad-lab04
# Usage: bash week2/labs/checks/lab04-check.sh
# =============================================================================

NS="ckad-lab04"
JOB1="compute-pi"
JOB2="batch-work"
CRONJOB="minute-logger"
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
echo " Lab 04 Review — Jobs & CronJobs"
echo " Namespace: $NS"
echo "================================================================"

# ════════════════════════════════════════════════
# PART 1 — Job: compute-pi
# ════════════════════════════════════════════════
echo -e "\n${YELLOW}━━━ Part 1: Job '$JOB1' ━━━${NC}"

info "Check 1: Job '$JOB1' exists"
if kubectl get job "$JOB1" -n "$NS" &>/dev/null; then
  pass "Job '$JOB1' found"
else
  fail "Job '$JOB1' not found" \
    "Create it: k create job $JOB1 --image=busybox -n $NS -- sh -c 'echo done'"
fi

info "Check 2: completions = 3"
COMPLETIONS=$(kubectl get job "$JOB1" -n "$NS" \
  -o jsonpath='{.spec.completions}' 2>/dev/null)
if [[ "$COMPLETIONS" -eq 3 ]]; then
  pass "completions: $COMPLETIONS"
else
  fail "completions is '$COMPLETIONS' (expected 3)" \
    "Edit the Job YAML: add spec.completions: 3"
fi

info "Check 3: parallelism = 2"
PARALLELISM=$(kubectl get job "$JOB1" -n "$NS" \
  -o jsonpath='{.spec.parallelism}' 2>/dev/null)
if [[ "$PARALLELISM" -eq 2 ]]; then
  pass "parallelism: $PARALLELISM"
else
  fail "parallelism is '$PARALLELISM' (expected 2)" \
    "Edit the Job YAML: add spec.parallelism: 2"
fi

info "Check 4: backoffLimit is set"
BACKOFF=$(kubectl get job "$JOB1" -n "$NS" \
  -o jsonpath='{.spec.backoffLimit}' 2>/dev/null)
if [[ -n "$BACKOFF" ]]; then
  pass "backoffLimit: $BACKOFF"
else
  fail "backoffLimit not set" \
    "Add spec.backoffLimit: 2 to your Job YAML"
fi

info "Check 5: Job completed successfully (3/3)"
SUCCEEDED=$(kubectl get job "$JOB1" -n "$NS" \
  -o jsonpath='{.status.succeeded}' 2>/dev/null)
if [[ "$SUCCEEDED" -eq 3 ]]; then
  pass "Job succeeded: $SUCCEEDED/3 completions"
else
  fail "Job succeeded: $SUCCEEDED/3 (still running or failed)" \
    "Wait for pods to complete: k get pods -n $NS -l job-name=$JOB1"
fi

# ════════════════════════════════════════════════
# PART 2 — Batch Job: batch-work
# ════════════════════════════════════════════════
echo -e "\n${YELLOW}━━━ Part 2: Job '$JOB2' ━━━${NC}"

info "Check 6: Job '$JOB2' exists"
if kubectl get job "$JOB2" -n "$NS" &>/dev/null; then
  pass "Job '$JOB2' found"
else
  fail "Job '$JOB2' not found" \
    "Create it: k create job $JOB2 --image=busybox -n $NS -- sh -c 'sleep 1'"
fi

info "Check 7: completions = 5"
COMPLETIONS2=$(kubectl get job "$JOB2" -n "$NS" \
  -o jsonpath='{.spec.completions}' 2>/dev/null)
if [[ "$COMPLETIONS2" -eq 5 ]]; then
  pass "completions: $COMPLETIONS2"
else
  fail "completions is '$COMPLETIONS2' (expected 5)" \
    "Edit the Job YAML: spec.completions: 5"
fi

info "Check 8: parallelism = 3"
PARALLELISM2=$(kubectl get job "$JOB2" -n "$NS" \
  -o jsonpath='{.spec.parallelism}' 2>/dev/null)
if [[ "$PARALLELISM2" -eq 3 ]]; then
  pass "parallelism: $PARALLELISM2"
else
  fail "parallelism is '$PARALLELISM2' (expected 3)" \
    "Edit the Job YAML: spec.parallelism: 3"
fi

info "Check 9: batch-work completed (5/5)"
SUCCEEDED2=$(kubectl get job "$JOB2" -n "$NS" \
  -o jsonpath='{.status.succeeded}' 2>/dev/null)
if [[ "$SUCCEEDED2" -eq 5 ]]; then
  pass "Job succeeded: $SUCCEEDED2/5 completions"
else
  fail "Job succeeded: $SUCCEEDED2/5 (still running or failed)" \
    "Wait: k get pods -n $NS -l job-name=$JOB2"
fi

# ════════════════════════════════════════════════
# PART 3 — CronJob: minute-logger
# ════════════════════════════════════════════════
echo -e "\n${YELLOW}━━━ Part 3: CronJob '$CRONJOB' ━━━${NC}"

info "Check 10: CronJob '$CRONJOB' exists"
if kubectl get cronjob "$CRONJOB" -n "$NS" &>/dev/null; then
  pass "CronJob '$CRONJOB' found"
else
  fail "CronJob '$CRONJOB' not found" \
    "Create it: k create cronjob $CRONJOB --image=busybox --schedule='* * * * *' -n $NS -- sh -c 'date'"
fi

info "Check 11: Schedule is '* * * * *' (every minute)"
SCHEDULE=$(kubectl get cronjob "$CRONJOB" -n "$NS" \
  -o jsonpath='{.spec.schedule}' 2>/dev/null)
if [[ "$SCHEDULE" == "* * * * *" ]]; then
  pass "Schedule: '$SCHEDULE'"
else
  fail "Schedule is '$SCHEDULE' (expected '* * * * *')" \
    "Set spec.schedule: '* * * * *' in your CronJob YAML"
fi

info "Check 12: successfulJobsHistoryLimit is set"
SUCCESS_HIST=$(kubectl get cronjob "$CRONJOB" -n "$NS" \
  -o jsonpath='{.spec.successfulJobsHistoryLimit}' 2>/dev/null)
if [[ -n "$SUCCESS_HIST" ]]; then
  pass "successfulJobsHistoryLimit: $SUCCESS_HIST"
else
  fail "successfulJobsHistoryLimit not set" \
    "Add spec.successfulJobsHistoryLimit: 3 to your CronJob YAML"
fi

info "Check 13: At least one Job was spawned by the CronJob (or manually triggered)"
CJ_JOBS=$(kubectl get jobs -n "$NS" \
  -o jsonpath="{.items[?(@.metadata.ownerReferences[0].name==\"$CRONJOB\")].metadata.name}" 2>/dev/null)
MANUAL_JOB=$(kubectl get job "manual-run-1" -n "$NS" &>/dev/null && echo "found" || echo "")
if [[ -n "$CJ_JOBS" || -n "$MANUAL_JOB" ]]; then
  pass "Job(s) triggered from CronJob: ${CJ_JOBS:-manual-run-1}"
else
  fail "No jobs triggered by '$CRONJOB' yet" \
    "Wait 1 minute OR manually trigger: k create job --from=cronjob/$CRONJOB manual-run-1 -n $NS"
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
