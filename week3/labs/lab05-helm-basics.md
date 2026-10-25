> **Topic:** Helm Basics — Install, Upgrade, Rollback
> **Exam Domain:** Application Deployment (20%)
> **Estimated Time:** ~15 minutes
> **Namespace:** `ckad-lab15`
> **Check Command:** `bash week3/labs/checks/lab05-check.sh`

---

# Lab 05 — Helm Basics

## 🎯 Objective

In namespace `ckad-lab15`, use Helm to manage the lifecycle of an application: add a chart repository, install a release, verify it, upgrade it, and verify the upgrade.

**Helm repo to add:**

| Field | Value |
|---|---|
| Repo name | `bitnami` |
| Repo URL | `https://charts.bitnami.com/bitnami` |

**Release to install:**

| Field | Value |
|---|---|
| Chart | `bitnami/nginx` |
| Release name | `my-nginx` |
| Namespace | `ckad-lab15` |
| Initial `replicaCount` | `2` |

**Upgrade target:**

| Field | Value |
|---|---|
| `replicaCount` after upgrade | `3` |

**Final state:** Release `my-nginx` must be in `deployed` status with **3 ready replicas** in namespace `ckad-lab15`.

---

## 📋 Tasks

**A.** Add the Bitnami Helm repository with name `bitnami` and URL `https://charts.bitnami.com/bitnami`, then update your local repo cache.

**B.** Create the namespace `ckad-lab15`.

**C.** Install the `bitnami/nginx` chart as release `my-nginx` into namespace `ckad-lab15`, setting `replicaCount` to `2`.

**D.** Verify the release appears in the Helm release list for namespace `ckad-lab15` and its status shows `deployed`.

**E.** Upgrade the `my-nginx` release to set `replicaCount` to `3`.

**F.** Verify the Deployment managed by the release now has 3 ready replicas.

---

## 🏁 Check your work

```bash
bash week3/labs/checks/lab05-check.sh
```

---

## 🧹 Manual Cleanup

> Only run this if the check script did not auto-cleanup.

```bash
helm uninstall my-nginx -n ckad-lab15
kubectl delete namespace ckad-lab15 --force --grace-period=0
```
