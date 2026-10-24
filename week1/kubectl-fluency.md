# kubectl Fluency — Exam Reference

> Exam style: **imperative first**, generate YAML skeleton, then edit.
> Use `k` alias everywhere. Set shortcuts once at exam start.

---

## 🚀 Shell Setup (do once per exam session)

```bash
alias k=kubectl
source <(kubectl completion bash)
complete -o default -F __start_kubectl k

do=(--dry-run=client -o yaml)    # zsh array — expands correctly as multiple args
now=(--force --grace-period=0)   # zsh array
```

---

## 🔄 Context & Namespace (FIRST thing per question)

```bash
# Switch to the context the question specifies — copy-paste, never type
k config use-context <context>

# Lock namespace so you don't have to type -n every time
k config set-context --current --namespace=<namespace>

# Verify
k config view --minify | grep namespace
```

> ⚠️ **Forgetting this = wrong cluster/namespace = zero points for that question.**

---

## 📦 Resource Generation (the generate-then-edit pattern)

```bash
# Pod
k run nginx --image=nginx $do > pod.yaml

# Pod with command override
k run busybox --image=busybox $do -- sh -c "sleep 3600" > pod.yaml

# Deployment
k create deploy myapp --image=nginx --replicas=3 $do > deploy.yaml

# Service (expose existing deployment)
k expose deploy myapp --port=80 --target-port=8080 $do > svc.yaml
k expose deploy myapp --type=NodePort --port=80 --name=myapp-np

# ConfigMap
k create cm myconfig --from-literal=KEY=value $do > cm.yaml
k create cm myconfig --from-file=config.txt

# Secret
k create secret generic mysecret --from-literal=pass=s3cr3t $do > sec.yaml

# Job
k create job myjob --image=busybox $do -- echo hello > job.yaml

# CronJob
k create cronjob mycron --image=busybox --schedule="*/5 * * * *" $do -- echo hi > cj.yaml

# ServiceAccount
k create sa mysa

# Namespace
k create ns mynamespace
```

---

## 🔍 Inspecting Resources

```bash
# Get overview
k get pods -n <namespace> -o wide          # include node + IP
k get all -A                               # everything, all namespaces
k get events -n <ns> --sort-by='.lastTimestamp'   # sorted events

# Details
k describe pod <name>                      # events, conditions, config
k describe node <name>                     # capacity, allocations

# Dump YAML of running resource
k get pod mypod -o yaml > pod.yaml
k get deploy myapp -o yaml

# Explain a field (use instead of memorizing)
k explain pod.spec.containers.securityContext
k explain deployment.spec.strategy
```

---

## 🛠️ Common Operations

```bash
# Edit a running resource directly
k edit deployment myapp

# Apply / force replace
k apply -f file.yaml
k replace --force -f file.yaml    # delete + recreate

# Force delete (instant)
k delete pod mypod $now

# Labels
k label pod mypod env=prod
k label pod mypod env-            # remove a label

# Exec into container
k exec -it <pod> -- /bin/sh
k exec -it <pod> -c <container> -- bash   # multi-container pod

# Logs
k logs <pod>
k logs <pod> --previous           # crashed container
k logs <pod> -c <container>       # specific container in multi-container pod
k logs <pod> -f                   # follow/stream
k logs <pod> --since=1h
k logs -l app=myapp               # by label (all matching pods)

# Port forward (for local testing)
k port-forward pod/mypod 8080:80

# Copy files
k cp mypod:/path/file /local/path
k cp /local/file mypod:/path/

# Quick connectivity test from inside cluster
k run tmp --image=busybox --rm -it -- wget -O- http://myapp:80
k run tmp --image=busybox --rm -it -- nslookup myapp.default.svc.cluster.local
```

---

## 📊 Metrics & Resource Usage

```bash
k top pods
k top pods --sort-by=memory
k top nodes

k describe quota -n <namespace>   # check ResourceQuota usage
```

---

## 🔁 Rollout Commands (Week 3 topic, but good to know early)

```bash
k rollout status deployment/myapp
k rollout history deployment/myapp
k rollout undo deployment/myapp
k rollout undo deployment/myapp --to-revision=2
k rollout pause deployment/myapp
k rollout resume deployment/myapp
```

---

## ⏱️ Time Strategy per Question

| Step | Action | Time |
|------|---------|------|
| 1 | Switch context + namespace | 10s |
| 2 | Generate YAML skeleton imperatively | 20s |
| 3 | Edit YAML in vim | 1–2 min |
| 4 | Apply + verify | 30s |
| **Total target** | | **≤ 5–6 min** |

> If stuck after 4 min → flag the question, move on, come back at the end.
