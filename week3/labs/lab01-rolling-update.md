> **Topic:** Rolling Updates & Rollback
> **Exam Domain:** Application Deployment (20%)
> **Estimated Time:** ~15 minutes
> **Namespace:** `ckad-lab11`
> **Check Command:** `bash week3/labs/checks/lab01-check.sh`

---

# Lab 01 — Rolling Update

## 🎯 Objective

In namespace `ckad-lab11`, create a Deployment and perform a rolling update, then verify the rollout history.

**Resources to create:**

| Resource | Detail |
|---|---|
| Deployment name | `webapp` |
| Initial image | `nginx:1.20` |
| Replicas | `3` |
| Pod label | `app=webapp` |
| Strategy type | `RollingUpdate` |
| `maxSurge` | `1` |
| `maxUnavailable` | `0` |
| Updated image | `nginx:1.21` |
| Change-cause annotation | `Update to nginx 1.21` |

The rollout history must show **at least 2 revisions** after the image update.

---

## 📋 Tasks

**A.** Create the namespace `ckad-lab11`, then write a Deployment manifest named `webapp` with image `nginx:1.20`, 3 replicas, label `app=webapp`, and a RollingUpdate strategy with `maxSurge: 1` and `maxUnavailable: 0`.

**B.** Apply the manifest to the cluster.

**C.** Annotate the current rollout revision with the change-cause `"Update to nginx 1.21"` using `kubectl.kubernetes.io/last-applied-configuration` or the `--record` equivalent annotation field (`kubernetes.io/change-cause`).

**D.** Perform an in-place image update on the `webapp` Deployment to use `nginx:1.21`, and wait for the rollout to complete.

**E.** Verify the rollout history for `webapp` shows at least 2 revisions.

---

## 🏁 Check your work

```bash
bash week3/labs/checks/lab01-check.sh
```

---

## 🧹 Manual Cleanup

> Only run this if the check script did not auto-cleanup.

```bash
kubectl delete namespace ckad-lab11 --force --grace-period=0
```
