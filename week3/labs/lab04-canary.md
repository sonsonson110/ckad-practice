> **Topic:** Canary Deployment Strategy
> **Exam Domain:** Application Deployment (20%)
> **Estimated Time:** ~20 minutes
> **Namespace:** `ckad-lab14`
> **Check Command:** `bash week3/labs/checks/lab04-check.sh`

---

# Lab 04 — Canary Deployment

## 🎯 Objective

In namespace `ckad-lab14`, implement a canary deployment pattern. Route ~10% of traffic to a new version by running 1 canary pod alongside 9 stable pods, all behind a single Service that selects on a shared label.

**Resources to create:**

| Resource | Name | Detail |
|---|---|---|
| Deployment (stable) | `frontend-stable` | image `nginx:1.20`, 9 replicas, labels `app=frontend, track=stable` |
| Deployment (canary) | `frontend-canary` | image `nginx:1.21`, 1 replica, labels `app=frontend, track=canary` |
| Service | `frontend-svc` | type `ClusterIP`, port `80`, selector: `app=frontend` only (no `track` key) |

**Key constraint:** The Service selector must contain **only** `app=frontend`. It must **not** include the `track` label, so that traffic is distributed across both stable and canary pods.

**Final state:** The Service must have **10 total endpoints** (9 from stable + 1 from canary).

---

## 📋 Tasks

**A.** Create the namespace `ckad-lab14`, then write a Deployment manifest for `frontend-stable` with image `nginx:1.20`, 9 replicas, and pod template labels `app=frontend` and `track=stable`.

**B.** Write a Deployment manifest for `frontend-canary` with image `nginx:1.21`, 1 replica, and pod template labels `app=frontend` and `track=canary`.

**C.** Write a Service manifest for `frontend-svc` of type `ClusterIP` on port `80`, with selector **only** `app=frontend` (do not include `track`).

**D.** Apply all three manifests to the cluster and wait for all pods to reach Running state.

**E.** Verify that the `frontend-svc` Service has endpoints from both deployments by inspecting the Endpoints object.

---

## 🏁 Check your work

```bash
bash week3/labs/checks/lab04-check.sh
```

---

## 🧹 Manual Cleanup

> Only run this if the check script did not auto-cleanup.

```bash
kubectl delete namespace ckad-lab14 --force --grace-period=0
```
