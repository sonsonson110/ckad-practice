# Lab 03 — Sidecar: shared emptyDir volume

> **Topic:** Multi-Container Pod Patterns | **Exam Domain:** Application Design & Build
> **Estimated time:** 12 minutes
> **Namespace:** `ckad-lab03`
> **Review:** `bash week2/labs/checks/lab03-check.sh`

---

## 🎯 Objective

In namespace `ckad-lab03`, create a Pod named **`sidecar-demo`** with two containers sharing an `emptyDir` volume mounted at `/var/log/app` in both containers:

- A container named `writer` using the `busybox` image that continuously appends timestamped lines to `/var/log/app/app.log`
- A container named `log-reader` using the `busybox` image that tails `/var/log/app/app.log`

---

## 📋 Tasks

**A.** Write the Pod manifest and apply it.

**B.** Confirm both containers are `Running` (`2/2 READY`).

**C.** Verify the `log-reader` container is streaming log lines written by the `writer` container.

---

## 🏁 Check your work
```bash
bash week2/labs/checks/lab03-check.sh
```
If everything passes, the script auto-deletes the `ckad-lab03` namespace.

---

## 🧹 Manual Cleanup (only if needed)
```bash
kubectl delete namespace ckad-lab03 --force --grace-period=0
```
