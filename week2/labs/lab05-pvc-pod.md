# Lab 05 — PersistentVolumeClaim & Pod Storage

> **Topic:** Persistent Volumes & Storage | **Exam Domain:** Application Design & Build
> **Estimated time:** 15 minutes
> **Namespace:** `ckad-lab05`
> **Review:** `bash week2/labs/checks/lab05-check.sh`

---

## 🎯 Objective

In namespace `ckad-lab05`, complete the following storage tasks:

### Part 1 — PVC: `app-data-pvc`
Create a PersistentVolumeClaim named **`app-data-pvc`** with:
- `accessModes: ReadWriteOnce`
- `storage: 100Mi`
- `storageClassName: standard`

### Part 2 — Writer Pod: `storage-writer`
Create a Pod named **`storage-writer`** using the `busybox` image that:
- Mounts `app-data-pvc` at `/data`
- Runs `sh -c 'echo "hello from storage" > /data/message.txt && sleep 3600'`

### Part 3 — Reader Pod: `storage-reader`
Delete the `storage-writer` Pod, then create a new Pod named **`storage-reader`** using the `busybox` image that:
- Mounts the same `app-data-pvc` at `/data`
- Reads and prints `/data/message.txt`

Confirm the message written by `storage-writer` is still visible — proving the data persisted.

### Part 4 — hostPath Pod: `hostpath-demo`
Create a Pod named **`hostpath-demo`** using the `busybox` image that:
- Mounts a `hostPath` volume from `/tmp/ckad-test` (type `DirectoryOrCreate`) at `/node-data`
- Writes `echo "node file" > /node-data/test.txt` and then sleeps

---

## 📋 Tasks

**A.** Create the PVC and confirm its status.

**B.** Create the `storage-writer` Pod and confirm the message is written to `/data/message.txt`.

**C.** Delete the `storage-writer` Pod, create the `storage-reader` Pod, and verify the message is still present.

**D.** Create the `hostpath-demo` Pod and verify the file exists at `/node-data/test.txt`.

---

## 🏁 Check your work
```bash
bash week2/labs/checks/lab05-check.sh
```
If everything passes, the script auto-deletes the `ckad-lab05` namespace.

---

## 🧹 Manual Cleanup (only if needed)
```bash
kubectl delete namespace ckad-lab05 --force --grace-period=0
```
