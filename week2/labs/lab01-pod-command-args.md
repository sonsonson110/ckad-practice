# Lab 01 — Pod: command, args & resource limits

> **Topic:** Pods Deep Dive | **Exam Domain:** Application Design & Build
> **Estimated time:** 10 minutes
> **Namespace:** `ckad-lab01`
> **Review:** `bash week2/labs/checks/lab01-check.sh`

---

## 🎯 Objective

In namespace `ckad-lab01`, create a Pod named **`date-pod`** using the `busybox` image that:

- Runs the command: `sh -c "while true; do date; sleep 5; done"`
- Sets resource **requests** of `cpu: 50m` and `memory: 64Mi`
- Sets resource **limits** of `cpu: 200m` and `memory: 128Mi`
- Has an environment variable `GREETING` with the value `hello-ckad`

---

## 📋 Tasks

**A.** Generate a Pod YAML skeleton imperatively and save it to `week2/resources/lab01-pod.yaml`.

**B.** Edit the YAML to satisfy all the requirements in the Objective.

**C.** Apply the manifest and confirm the Pod is `Running`.

---

## 🏁 Check your work
```bash
bash week2/labs/checks/lab01-check.sh
```
If everything passes, the script auto-deletes the `ckad-lab01` namespace.

---

## 🧹 Manual Cleanup (only if needed)
```bash
kubectl delete namespace ckad-lab01 --force --grace-period=0
```
