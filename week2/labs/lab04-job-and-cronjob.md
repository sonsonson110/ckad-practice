# Lab 04 — Jobs & CronJobs

> **Topic:** Jobs & CronJobs | **Exam Domain:** Application Design & Build
> **Estimated time:** 15 minutes | ⭐ High-yield exam topic
> **Namespace:** `ckad-lab04`
> **Review:** `bash week2/labs/checks/lab04-check.sh`

---

## 🎯 Objective

In namespace `ckad-lab04`, create the following resources:

### Part 1 — Job: `compute-pi`
A Job named **`compute-pi`** using the `busybox` image that runs `sh -c "echo 'Calculating...'; sleep 2; echo 'Done!'"`, configured with:
- `completions: 3`
- `parallelism: 2`
- `backoffLimit: 2`
- `activeDeadlineSeconds: 120`

### Part 2 — Job: `batch-work`
A Job named **`batch-work`** using the `busybox` image that runs `sh -c "echo working on task; sleep 1; echo done"`, configured with:
- `completions: 5`
- `parallelism: 3`

### Part 3 — CronJob: `minute-logger`
A CronJob named **`minute-logger`** using the `busybox` image that runs `sh -c "echo Job ran at: $(date)"` on a `* * * * *` schedule, configured with:
- `successfulJobsHistoryLimit: 3`
- `failedJobsHistoryLimit: 1`

---

## 📋 Tasks

**A.** Create the `compute-pi` Job and confirm it reaches `3/3` completions.

**B.** Create the `batch-work` Job and confirm all 5 pods complete.

**C.** Create the `minute-logger` CronJob and confirm a Job is triggered on schedule.

**D.** Manually trigger a Job from the `minute-logger` CronJob named `manual-run-1` and confirm its logs show the date.

---

## 🏁 Check your work
```bash
bash week2/labs/checks/lab04-check.sh
```
If everything passes, the script auto-deletes the `ckad-lab04` namespace.

---

## 🧹 Manual Cleanup (only if needed)
```bash
kubectl delete namespace ckad-lab04 --force --grace-period=0
```
