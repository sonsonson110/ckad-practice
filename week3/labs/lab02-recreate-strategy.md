> **Topic:** Recreate Deployment Strategy
> **Exam Domain:** Application Deployment (20%)
> **Estimated Time:** ~10 minutes
> **Namespace:** `ckad-lab12`
> **Check Command:** `bash week3/labs/checks/lab02-check.sh`

---

# Lab 02 — Recreate Strategy

## 🎯 Objective

In namespace `ckad-lab12`, create a Deployment using the `Recreate` strategy and perform an image update to verify that all old pods are terminated before new ones are created.

**Resources to create:**

| Resource | Detail |
|---|---|
| Deployment name | `batch-app` |
| Initial image | `nginx:1.20` |
| Replicas | `2` |
| Pod label | `app=batch-app` |
| Strategy type | `Recreate` |
| Updated image | `nginx:1.21` |

After the image update, all 2 replicas must be running `nginx:1.21` and **no pods** running `nginx:1.20` should remain.

---

## 📋 Tasks

**A.** Create the namespace `ckad-lab12`, then write a Deployment manifest named `batch-app` with image `nginx:1.20`, 2 replicas, label `app=batch-app`, and a `Recreate` update strategy.

**B.** Apply the manifest to the cluster.

**C.** Update the image of the `batch-app` Deployment to `nginx:1.21`.

**D.** Wait for the rollout to finish, then confirm that all running pods are using the new image `nginx:1.21` and no pods from the old image remain.

---

## 🏁 Check your work

```bash
bash week3/labs/checks/lab02-check.sh
```

---

## 🧹 Manual Cleanup

> Only run this if the check script did not auto-cleanup.

```bash
kubectl delete namespace ckad-lab12 --force --grace-period=0
```
