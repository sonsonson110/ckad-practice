# Week 2 — Application Design & Build

> **Exam Domain:** Application Design & Build | **Weight:** 20%
> **Roadmap reference:** [CKAD_ROADMAP.md](../CKAD_ROADMAP.md#week-2--application-design--build)

---

## 🎯 Week Goals

- [ ] Understand Dockerfile basics (CMD vs ENTRYPOINT)
- [ ] Deep-dive pod spec: command, args, env, resources
- [ ] Master multi-container patterns (sidecar, init container)
- [ ] Create Jobs and CronJobs imperatively
- [ ] Understand PV/PVC storage model and mount a PVC in a pod

---

## 📁 Practice Files (this folder)

| File | What it covers |
|------|---------------|
| `pod-basic.yaml` | Pod with resources, env vars |
| `pod-init-container.yaml` | Init container pattern |
| `pod-sidecar.yaml` | Sidecar pattern (log shipper) |
| `pod-emptydir.yaml` | Shared emptyDir volume between containers |
| `job-basic.yaml` | Simple one-shot Job |
| `job-parallel.yaml` | Job with completions + parallelism |
| `cronjob-basic.yaml` | CronJob every 5 minutes |
| `pvc-basic.yaml` | PersistentVolumeClaim definition |
| `pod-with-pvc.yaml` | Pod mounting a PVC |

---

## 🚀 Quick Commands Reference

```bash
# Set your shortcuts (do this at session start)
alias k=kubectl
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"

# --- PODS ---
# Generate pod skeleton
k run mypod --image=nginx $do > pod.yaml

# Pod with command override
k run mypod --image=busybox $do -- sh -c "echo hello && sleep 3600" > pod.yaml

# Delete fast
k delete pod mypod $now

# --- JOBS ---
k create job hello --image=busybox $do -- echo hello > job.yaml

# --- CRONJOBS ---
k create cronjob my-cron --image=busybox --schedule="*/5 * * * *" $do \
  -- echo hello > cj.yaml

# --- CHECK STATUS ---
k get pods,jobs,cronjobs
k describe job hello
k logs job/hello
```

---

## 📚 Key Concepts

### CMD vs ENTRYPOINT (Docker → k8s mapping)

| Docker | Kubernetes YAML | Purpose |
|--------|----------------|---------|
| `ENTRYPOINT` | `command` | The executable |
| `CMD` | `args` | Arguments to the executable |

```yaml
# In kubernetes:
containers:
- name: app
  image: busybox
  command: ["/bin/sh"]      # overrides ENTRYPOINT
  args: ["-c", "echo hi"]  # overrides CMD
```

### Multi-Container Patterns

| Pattern | Description | Use Case |
|---------|-------------|----------|
| **Sidecar** | Helper runs alongside main | Log shipper, proxy, metrics |
| **Init Container** | Runs before main, must exit 0 | DB wait, file setup, config pull |
| **Ambassador** | Proxy to external services | Abstracting external endpoints |

### Job Spec Key Fields

```yaml
spec:
  completions: 3         # total successful runs needed
  parallelism: 2         # max concurrent pods
  backoffLimit: 4        # retries before marking failed
  activeDeadlineSeconds: 60  # hard timeout for the whole job
```

### Storage Quick Reference

```
emptyDir   → ephemeral, shared between containers in same pod, lost when pod dies
hostPath   → mounts a node path (avoid in prod, but tested in CKAD)
PVC        → durable storage; pod claims from a PV via PVC
```

---

## ✅ Practice Checklist

- [ ] Create a pod with custom `command` and `args` from imperative command
- [ ] Add resource `requests` and `limits` to a pod
- [ ] Build a pod with an **init container** that waits for a service
- [ ] Build a pod with a **sidecar** sharing an emptyDir volume
- [ ] Create a **Job** that runs 3 completions with 2 in parallel
- [ ] Create a **CronJob** scheduled every minute
- [ ] Create a **PVC** and mount it into a pod at `/data`
- [ ] Complete [CKAD exercises: Multi-container Pods](https://github.com/dgkanatsios/CKAD-exercises/blob/main/d.multi_container_pods.md)
- [ ] Complete [CKAD exercises: State/Volumes](https://github.com/dgkanatsios/CKAD-exercises/blob/main/g.state.md)

---

## 📖 Docs to Bookmark (for exam speed)

- Pods: https://kubernetes.io/docs/concepts/workloads/pods/
- Init Containers: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
- Jobs: https://kubernetes.io/docs/concepts/workloads/controllers/job/
- CronJob: https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
- PVC: https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- Storage volumes: https://kubernetes.io/docs/concepts/storage/volumes/
