# Lab 02 — Init Container: wait-for-service pattern

> **Topic:** Multi-Container Pod Patterns | **Exam Domain:** Application Design & Build
> **Estimated time:** 12 minutes
> **Namespace:** `ckad-lab02`
> **Review:** `bash week2/labs/checks/lab02-check.sh`

---

## 🎯 Objective

In namespace `ckad-lab02`, create a Pod named **`webapp`** that:

- Has an **init container** named `wait-for-db` using the `busybox` image that loops until `mydb.ckad-lab02.svc.cluster.local` is resolvable via DNS (using `nslookup`), then exits successfully
- Has a main container named `webapp` using the `nginx` image

Then create a ClusterIP Service named **`mydb`** in namespace `ckad-lab02` on port `5432`, and verify that the Pod transitions from `Init:0/1` to `Running`.

---

## 📋 Tasks

**A.** Create the `webapp` Pod (without the `mydb` service yet) and observe it stuck in `Init:0/1`.

**B.** Create the `mydb` ClusterIP service on port `5432`.

**C.** Confirm the init container completes and the main container starts.

---

## 🏁 Check your work
```bash
bash week2/labs/checks/lab02-check.sh
```
If everything passes, the script auto-deletes the `ckad-lab02` namespace.

---

## 🧹 Manual Cleanup (only if needed)
```bash
kubectl delete namespace ckad-lab02 --force --grace-period=0
```
