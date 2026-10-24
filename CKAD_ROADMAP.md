# 🎯 CKAD Learning Roadmap — 2-Month Study Plan

> **Goal:** Pass the Certified Kubernetes Application Developer (CKAD) exam with confidence.
> **Duration:** 8 weeks | **Exam:** ~15–20 tasks in 120 minutes | **Pass score:** 66%
> **Your baseline:** Day-to-day k8s (Deployment, Service, Ingress, ConfigMap) — not yet fluent with kubectl/vim

---

## 📋 Table of Contents

- [Exam Overview](#exam-overview)
- [Curriculum Domains](#curriculum-domains)
- [Learning Resources](#learning-resources)
- [Week-by-Week Plan](#week-by-week-plan)
- [Exam Day Playbook](#exam-day-playbook)
- [kubectl Cheat Sheet](#kubectl-cheat-sheet)
- [vim Quick Reference](#vim-quick-reference)
- [Progress Tracker](#progress-tracker)

---

## Exam Overview

| Item | Detail |
|------|--------|
| Format | Performance-based (hands-on terminal) |
| Duration | 2 hours |
| Tasks | ~15–20 questions |
| Pass Score | 66% |
| Allowed Docs | kubernetes.io/docs, kubernetes.io/blog, helm.sh |
| Retake | 1 free retake included |
| Validity | 2 years |

---

## Curriculum Domains

| Domain | Weight | Your Priority |
|--------|--------|--------------|
| Application Environment, Configuration & Security | 25% | 🔴 High |
| Application Design & Build | 20% | 🟡 Medium |
| Application Deployment | 20% | 🟢 Already familiar |
| Services & Networking | 20% | 🟡 Medium |
| Application Observability & Maintenance | 15% | 🟡 Medium |

---

## Learning Resources

### Free
- 📖 [Official Kubernetes Docs](https://kubernetes.io/docs/) ← **your best friend during exam**
- 🏋️ [dgkanatsios/CKAD-exercises](https://github.com/dgkanatsios/CKAD-exercises) — must-do practice exercises
- 🎯 [killer.sh](https://killer.sh) — 2 free simulator sessions with exam purchase
- 🖥️ [Killercoda CKAD scenarios](https://killercoda.com/killer-shell-ckad) — free browser-based practice

### Paid (Optional but Recommended)
- 🎓 [KodeKloud CKAD Course](https://kodekloud.com/courses/certified-kubernetes-application-developer-ckad/) — hands-on labs in browser
- 📚 [Udemy: CKAD by Mumshad Mannambeth](https://www.udemy.com/course/certified-kubernetes-application-developer/) — very popular, often on sale

### Practice Clusters (Free)
- [Killercoda](https://killercoda.com/killer-shell-ckad) — free browser-based k8s scenarios
- Local: `minikube` or `kind` on your machine

---

## Week-by-Week Plan

---

### Week 1 — Tooling & kubectl Fluency
> **Theme:** Master your weapons before battle. Speed is everything in this exam.

#### Goals
- [x] Set up a local practice cluster (minikube or kind)
- [x] Learn kubectl basics inside out
- [x] Get comfortable with vim for YAML editing
- [x] Understand k8s architecture conceptually

#### K8s Architecture (Concepts to Understand)
- [x] Control Plane components: API Server, etcd, Scheduler, Controller Manager
- [x] Node components: kubelet, kube-proxy, container runtime
- [x] How a Pod is scheduled (API Server → etcd → Scheduler → kubelet)
- [x] Namespaces and resource isolation
- [x] RBAC overview (who can do what)

#### kubectl Essentials

Practice until these feel automatic:

```bash
# Context & Namespace management (CRITICAL — always do this per question)
kubectl config current-context
kubectl config use-context <context>
kubectl config set-context --current --namespace=<ns>

# Getting info
kubectl get pods -n <namespace> -o wide
kubectl describe pod <name>
kubectl get all -A                    # everything in all namespaces
kubectl get events --sort-by='.lastTimestamp'

# Quick pod operations
kubectl run nginx --image=nginx
kubectl delete pod nginx --force --grace-period=0

# Exec into containers
kubectl exec -it <pod> -- /bin/sh
kubectl exec -it <pod> -c <container> -- bash   # multi-container pod

# Logs
kubectl logs <pod>
kubectl logs <pod> -c <container>
kubectl logs <pod> --previous          # crashed container logs

# Apply / replace
kubectl apply -f file.yaml
kubectl replace --force -f file.yaml   # force delete + recreate
```

#### vim for YAML — Must Learn

Create `~/.vimrc` (do this once at exam start too):
```
set tabstop=2
set expandtab
set shiftwidth=2
set number
```

Key vim commands:

| Command | Action |
|---------|--------|
| `i` | Insert mode |
| `ESC` | Normal mode |
| `dd` | Delete line |
| `yy` | Copy line |
| `p` | Paste below |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `gg` | Go to top |
| `G` | Go to bottom |
| `:%s/old/new/g` | Find & replace all |
| `:set paste` | Paste mode (disable auto-indent) |
| `:wq` | Save & exit |
| `:q!` | Quit without saving |
| `V` then `>` or `<` | Indent/outdent selected lines |

#### Daily Practice
- [x] Day 1–2: Set up cluster, explore `kubectl get/describe/logs`
- [x] Day 3–4: Practice vim with YAML files, get fast at editing
- [x] Day 5–7: Run through [k8s.io/docs — kubectl cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

---

### Week 2 — Application Design & Build
> **Exam Weight: 20%** | Topics: Containers, Jobs, Multi-container Pods, Volumes

#### Container Images
- [ ] Understand Dockerfile basics (FROM, RUN, COPY, CMD, ENTRYPOINT)
- [ ] Know the difference between CMD and ENTRYPOINT
- [ ] Build and push images: `docker build`, `docker push`
- [ ] In exam: you won't build images, but you'll reference them

#### Pods Deep Dive

```bash
# Generate pod YAML (use this template approach always)
kubectl run mypod --image=nginx $do > pod.yaml
kubectl apply -f pod.yaml

# Override command and args
kubectl run mypod --image=busybox $do -- sh -c "echo hello && sleep 3600"
```

Key pod spec fields to know:

```yaml
spec:
  containers:
  - name: app
    image: nginx:1.21
    command: ["/bin/sh"]
    args: ["-c", "echo hello"]
    env:
    - name: MY_VAR
      value: "myvalue"
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "256Mi"
```

#### Multi-Container Pod Patterns
- [ ] **Sidecar**: helper container alongside main (e.g., log shipper, proxy)
- [ ] **Init Container**: runs before main container (e.g., wait for DB, copy files)
- [ ] **Ambassador**: proxy to external services

```yaml
# Init container pattern
spec:
  initContainers:
  - name: init-wait
    image: busybox
    command: ['sh', '-c', 'until nslookup mydb; do echo waiting; sleep 2; done']
  containers:
  - name: app
    image: myapp
```

#### Jobs & CronJobs (High yield — often tested)

```bash
# Job
kubectl create job hello --image=busybox $do -- echo hello > job.yaml

# CronJob
kubectl create cronjob my-cron --image=busybox --schedule="*/5 * * * *" $do \
  -- echo hello > cj.yaml
```

Key Job spec options:

```yaml
spec:
  completions: 3          # run 3 times total
  parallelism: 2          # run 2 at a time
  backoffLimit: 4         # retry on failure
  activeDeadlineSeconds: 60
```

#### Persistent Volumes & Storage
- [ ] PersistentVolume (PV) — cluster-level storage resource
- [ ] PersistentVolumeClaim (PVC) — pod's request for storage
- [ ] StorageClass — dynamic provisioning
- [ ] emptyDir — ephemeral volume shared between containers in same pod
- [ ] hostPath — mount node path (not prod, but tested)

```yaml
# PVC (the most commonly tested part)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  storageClassName: standard
---
# Mount in pod
spec:
  containers:
  - name: app
    volumeMounts:
    - name: data
      mountPath: /data
  volumes:
  - name: data
    persistentVolumeClaim:
      claimName: my-pvc
```

#### Practice Exercises
- [ ] [CKAD exercises: Multi-container Pods](https://github.com/dgkanatsios/CKAD-exercises/blob/main/d.multi_container_pods.md)
- [ ] [CKAD exercises: State/Volumes](https://github.com/dgkanatsios/CKAD-exercises/blob/main/g.state.md)
- [ ] Create a pod with init container + sidecar from scratch

---

### Week 3 — Application Deployment
> **Exam Weight: 20%** | You have baseline here — go deeper!

#### Deployments — Go Beyond Basics

```bash
kubectl create deployment myapp --image=nginx --replicas=3 $do > deploy.yaml

# Rolling updates
kubectl set image deployment/myapp nginx=nginx:1.21
kubectl rollout status deployment/myapp
kubectl rollout history deployment/myapp
kubectl rollout undo deployment/myapp
kubectl rollout undo deployment/myapp --to-revision=2

# Pause/resume rollout
kubectl rollout pause deployment/myapp
kubectl rollout resume deployment/myapp
```

Rolling update strategy spec:

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1         # extra pods during update
      maxUnavailable: 0   # no downtime
```

#### Deployment Strategies (Often Tested)
- [ ] **Rolling Update** (default) — gradual pod replacement
- [ ] **Recreate** — kill all, then create new (downtime)
- [ ] **Blue/Green** — run two deployments, switch Service selector
- [ ] **Canary** — run small % of new version alongside old

```yaml
# Blue/Green: Service switches selector
# Blue deployment: labels app=myapp, version=blue
# Green deployment: labels app=myapp, version=green
# Service: selector: {app: myapp, version: blue}  → change to green to cut over

# Canary: two deployments, service selects both by app label only
# Deployment v1: 9 replicas
# Deployment v2-canary: 1 replica
# Service selector: app=myapp (hits both)
```

#### Helm Basics (In Scope)

```bash
helm repo add stable https://charts.helm.sh/stable
helm search repo nginx
helm install my-release stable/nginx-ingress
helm upgrade my-release stable/nginx-ingress --set replicas=2
helm rollback my-release 1
helm uninstall my-release
helm list
```

#### Practice
- [ ] [CKAD exercises: Deployments](https://github.com/dgkanatsios/CKAD-exercises/blob/main/e.deployments.md)
- [ ] Simulate a blue/green deployment manually
- [ ] Practice rollback scenarios

---

### Week 4 — Services & Networking
> **Exam Weight: 20%** | Focus: Services, NetworkPolicy, Ingress

#### Services Deep Dive

```bash
kubectl expose deployment myapp --port=80 --target-port=8080 $do > svc.yaml
kubectl expose deployment myapp --type=NodePort --port=80 --name=myapp-np
```

| Service Type | Access | Use Case |
|-------------|--------|----------|
| ClusterIP (default) | Internal only | Internal microservices |
| NodePort | Node IP + port (30000-32767) | Dev/testing external access |
| LoadBalancer | External IP (cloud) | Production external access |
| ExternalName | DNS alias | Connect to external service by name |

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp
spec:
  selector:
    app: myapp
  ports:
  - port: 80          # service port
    targetPort: 8080  # container port
  type: ClusterIP
```

#### NetworkPolicy (High yield — commonly tested)

NetworkPolicy controls pod-to-pod traffic. **By default, all traffic is allowed.**

```yaml
# Allow ingress only from frontend pods
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - port: 8080
---
# Deny all ingress (isolation policy)
spec:
  podSelector: {}
  policyTypes:
  - Ingress
```

> 💡 **Tip**: Always look up NetworkPolicy examples from k8s docs during exam — don't memorize, know the structure.

#### Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-svc
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-svc
            port:
              number: 80
```

#### DNS & Service Discovery
- [ ] Every Service gets a DNS entry: `<svc-name>.<namespace>.svc.cluster.local`
- [ ] Within same namespace: just `<svc-name>` works
- [ ] Cross-namespace: `<svc-name>.<namespace>`

```bash
# Test DNS / connectivity from inside cluster
kubectl run tmp --image=busybox --rm -it -- wget -O- http://myapp:80
kubectl run tmp --image=busybox --rm -it -- nslookup myapp.default.svc.cluster.local
```

#### Practice
- [ ] [CKAD exercises: Services & Networking](https://github.com/dgkanatsios/CKAD-exercises/blob/main/f.services.md)
- [ ] Create a NetworkPolicy: allow ingress from specific namespace, deny all egress except DNS
- [ ] Set up an Ingress with path-based routing

---

### Week 5 — Config, Security & Environment
> **Exam Weight: 25% — THE BIGGEST DOMAIN — Give it extra time!**

#### ConfigMaps

```bash
# Create from literals
kubectl create cm app-config \
  --from-literal=DB_HOST=postgres \
  --from-literal=DB_PORT=5432 $do > cm.yaml

# Create from file
kubectl create cm app-config --from-file=config.properties
```

Use ConfigMap in pod (3 ways — all tested):

```yaml
spec:
  containers:
  - name: app
    image: myapp
    # Option 1: individual env var
    env:
    - name: DB_HOST
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: DB_HOST
    # Option 2: all keys as env vars
    envFrom:
    - configMapRef:
        name: app-config
    # Option 3: mount as files
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
  volumes:
  - name: config-vol
    configMap:
      name: app-config
```

#### Secrets

```bash
kubectl create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=s3cr3t $do > secret.yaml

# Docker registry secret
kubectl create secret docker-registry regcred \
  --docker-server=registry.io \
  --docker-username=user \
  --docker-password=pass
```

```yaml
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-creds
      key: password
```

> ⚠️ Secrets are base64-encoded, not encrypted. Know this conceptually.

#### Security Contexts

```yaml
spec:
  securityContext:          # Pod-level
    runAsUser: 1000
    runAsGroup: 3000
    fsGroup: 2000
  containers:
  - name: app
    securityContext:        # Container-level (overrides pod)
      runAsNonRoot: true
      readOnlyRootFilesystem: true
      allowPrivilegeEscalation: false
      capabilities:
        add: ["NET_ADMIN"]
        drop: ["ALL"]
```

#### ServiceAccounts

```bash
kubectl create serviceaccount my-sa
kubectl create clusterrolebinding my-sa-binding \
  --clusterrole=view \
  --serviceaccount=default:my-sa
```

```yaml
spec:
  serviceAccountName: my-sa
  automountServiceAccountToken: false  # disable if not needed
```

#### Resource Requests & Limits

```yaml
resources:
  requests:
    cpu: "100m"      # 0.1 CPU cores
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"
```

> 💡 Behavior when limit exceeded:
> - **CPU**: throttled (never killed)
> - **Memory**: OOMKilled (container killed and restarted)

#### Resource Quotas & LimitRanges

```yaml
# ResourceQuota: limits total resources in a namespace
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ns-quota
spec:
  hard:
    pods: "10"
    requests.cpu: "4"
    requests.memory: 4Gi
    limits.cpu: "8"
    limits.memory: 8Gi
---
# LimitRange: sets defaults/min/max per container
apiVersion: v1
kind: LimitRange
metadata:
  name: limits
spec:
  limits:
  - type: Container
    default:
      cpu: 200m
      memory: 256Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
```

#### Custom Resource Definitions (CRDs) — Light Coverage
- [ ] Know what a CRD is: extending the k8s API with custom types
- [ ] Know how to `kubectl get <custom-resource>`
- [ ] Know how to `kubectl explain <crd-name>`
- [ ] You won't create CRDs from scratch in the exam

#### Practice
- [ ] [CKAD exercises: Configuration](https://github.com/dgkanatsios/CKAD-exercises/blob/main/c.configuration.md)
- [ ] Practice mounting secrets as env vars AND as files
- [ ] Create pod that runs as non-root with read-only filesystem

---

### Week 6 — Observability & Maintenance
> **Exam Weight: 15%** | Topics: Probes, Logging, Debugging

#### Probes (Liveness, Readiness, Startup)

| Probe | Purpose | Failure Action |
|-------|---------|----------------|
| **Liveness** | Is container still alive? | Restart container |
| **Readiness** | Is container ready for traffic? | Remove from Service endpoints |
| **Startup** | Is container started? | Restart if startup takes too long |

```yaml
spec:
  containers:
  - name: app
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 3

    readinessProbe:
      tcpSocket:
        port: 8080
      initialDelaySeconds: 5
      periodSeconds: 5

    startupProbe:
      exec:
        command: ["cat", "/tmp/healthy"]
      failureThreshold: 30
      periodSeconds: 10
```

#### Logging

```bash
# Basic logs
kubectl logs <pod>
kubectl logs <pod> --previous          # after crash
kubectl logs <pod> -c <container>      # specific container
kubectl logs <pod> -f                  # follow/stream
kubectl logs <pod> --since=1h          # last 1 hour
kubectl logs -l app=myapp              # by label

# Look for events
kubectl describe pod <pod>             # scroll to Events section
kubectl get events -n <ns> --sort-by='.lastTimestamp'
```

#### Monitoring & Metrics

```bash
kubectl top pods
kubectl top pods --sort-by=memory
kubectl top nodes
```

> ℹ️ Metrics server must be installed. In exam environment, it usually is.

#### Debugging Failing Pods (Most tested scenario)

**Common failure states and fixes:**

| Status | Likely Cause | Debug Command |
|--------|-------------|---------------|
| `Pending` | No resources / PVC not bound | `kubectl describe pod` |
| `CrashLoopBackOff` | App exits, wrong command | `kubectl logs --previous` |
| `ImagePullBackOff` | Wrong image/tag, no pull secret | `kubectl describe pod` → Events |
| `OOMKilled` | Hit memory limit | Increase limit |
| `Error` | Command failed | `kubectl logs` |
| `ContainerCreating` | Volume/secret/cm missing | `kubectl describe pod` → Events |

**Debug workflow:**

```bash
# Step 1: What's the status?
kubectl get pod <name>

# Step 2: Get details and events
kubectl describe pod <name>

# Step 3: Check logs
kubectl logs <name> --previous  # if CrashLoop

# Step 4: Shell into it (if running)
kubectl exec -it <name> -- sh

# Step 5: Use ephemeral debug container
kubectl debug -it <pod> --image=busybox --target=<container>
```

#### Practice
- [ ] Intentionally break pods and debug them (wrong image, wrong command, missing secret)
- [ ] Practice probes: deploy app, misconfigure probe, fix it
- [ ] Run `kubectl top` and interpret results

---

### Week 7 — Full Review & Mock Exams
> **Theme:** Identify gaps, fill them, practice under time pressure

#### Review Checklist (All Domains)

**Application Design & Build**
- [ ] Create pod, deployment, job, cronjob imperatively
- [ ] Multi-container: sidecar + init container
- [ ] PVC + mount in pod
- [ ] Set resource requests/limits

**Application Deployment**
- [ ] Rolling update + rollback
- [ ] Pause/resume rollout
- [ ] Blue/Green deployment
- [ ] Canary deployment
- [ ] helm install/upgrade/rollback

**Services & Networking**
- [ ] ClusterIP, NodePort services
- [ ] Ingress with path routing
- [ ] NetworkPolicy: allow/deny ingress/egress
- [ ] Test connectivity with busybox pod

**Config, Security, Environment**
- [ ] ConfigMap: literal, file, env, volume mount
- [ ] Secret: literal, env, volume mount
- [ ] SecurityContext: runAsUser, capabilities
- [ ] ServiceAccount: create + assign to pod
- [ ] ResourceQuota + LimitRange

**Observability & Maintenance**
- [ ] Add liveness + readiness probes
- [ ] Debug: CrashLoop, ImagePullBackOff, Pending
- [ ] Read container logs + events
- [ ] Use `kubectl top`

#### Mock Exam Schedule
- [ ] Day 1: Take CKAD exercises full run-through (timed, 6 min per question)
- [ ] Day 2: Review failures, look up docs for weak areas
- [ ] Day 3: Killercoda CKAD scenarios — timed
- [ ] Day 4: Repeat weak areas
- [ ] Day 5–7: Full mock on killer.sh (first session) — simulate real exam conditions

#### Time Management Practice
- Set a timer for each task: target **5–6 minutes max** before flagging and moving on
- Practice the full exam setup ritual for every question:

```bash
# Do this at the start of every exam question:
kubectl config use-context <context-from-question>
kubectl config set-context --current --namespace=<namespace-from-question>
```

---

### Week 8 — Killer.sh + Final Polish
> **Theme:** Sharpen everything. No new topics. Confidence-building.

#### Killer.sh Session 2 (Full Exam Simulation)
- [ ] Take killer.sh session 2 under strict exam conditions
  - Full 2 hours, no breaks, no extra help
  - Timer running
  - After: review every wrong answer thoroughly

#### Final Checklist
- [ ] Can you set up shell aliases from memory in 30 seconds?
- [ ] Can you generate YAML skeletons imperatively for all resource types?
- [ ] Do you know where in the k8s docs to find: NetworkPolicy, PVC, SecurityContext, Ingress?
- [ ] Are you comfortable with vim: indentation, find/replace, paste mode?
- [ ] Do you know how to debug the 5 common pod failure states?

#### Last 2 Days — Light Mode
- Review your personal notes only
- Re-read the Exam Day Playbook below
- Get rest — being sharp matters more than cramming
- Practice the exam setup ritual one more time

---

## Exam Day Playbook

### Shell Setup — Do This First (< 1 minute)

```bash
# Aliases and completion
alias k=kubectl
source <(kubectl completion bash)
complete -o default -F __start_kubectl k

# Shortcuts
export do="--dry-run=client -o yaml"
export now="--force --grace-period=0"

# vim config
cat << 'EOF' >> ~/.vimrc
set tabstop=2
set expandtab
set shiftwidth=2
set number
EOF
```

### For Every Single Question

```bash
# Step 1: Switch context (copy-paste from question — never type manually)
kubectl config use-context <context>

# Step 2: Set namespace
kubectl config set-context --current --namespace=<namespace>

# Step 3: Verify
kubectl config view --minify | grep namespace
```

### The "Generate-then-Edit" Rule

Never write YAML from scratch. Always:
1. **Generate skeleton:** `k [command] $do > file.yaml`
2. **Edit with vim**
3. **Apply:** `k apply -f file.yaml`
4. **Verify:** `k get/describe <resource>`

### Time Strategy

| Time | Action |
|------|--------|
| 0–5 min | Skim all questions, note easy vs hard |
| 5–90 min | Work through questions — flag anything taking > 6 min |
| 90–120 min | Return to flagged questions |

### Allowed Documentation — Know Where Things Are

| Topic | Docs URL path |
|-------|--------------|
| NetworkPolicy | /docs/concepts/services-networking/network-policies/ |
| PersistentVolume | /docs/concepts/storage/persistent-volumes/ |
| Security Context | /docs/tasks/configure-pod-container/security-context/ |
| Ingress | /docs/concepts/services-networking/ingress/ |
| RBAC | /docs/reference/access-authn-authz/rbac/ |
| Probes | /docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| kubectl Cheatsheet | /docs/reference/kubectl/cheatsheet/ |

---

## kubectl Cheat Sheet

### Resource Generation (Always use `$do` flag)

```bash
# Pod
k run nginx --image=nginx $do > pod.yaml

# Deployment
k create deploy myapp --image=nginx --replicas=3 $do > deploy.yaml

# Service
k expose deploy myapp --port=80 --target-port=8080 $do > svc.yaml
k expose deploy myapp --type=NodePort --port=80

# ConfigMap
k create cm myconfig --from-literal=key=val $do > cm.yaml
k create cm myconfig --from-file=config.txt

# Secret
k create secret generic mysecret --from-literal=pass=secret $do > sec.yaml

# Job
k create job myjob --image=busybox $do -- echo hello > job.yaml

# CronJob
k create cronjob mycron --image=busybox --schedule="*/5 * * * *" $do -- echo hi > cj.yaml

# ServiceAccount
k create sa mysa

# Namespace
k create ns mynamespace
```

### Useful One-Liners

```bash
# Get pod YAML (already running pod)
k get pod mypod -o yaml > pod.yaml

# Edit running resource
k edit deployment myapp

# Label operations
k label pod mypod env=prod
k label pod mypod env-           # remove label

# Force delete
k delete pod mypod $now

# Check resource quotas
k describe quota -n mynamespace

# Copy from/to pod
k cp mypod:/path/to/file /local/path
k cp /local/file mypod:/path/

# Port forward for testing
k port-forward pod/mypod 8080:80

# Quick check what's failing
k get events -n default --sort-by='.lastTimestamp' | tail -20

# Explain any field
k explain pod.spec.containers.securityContext
k explain deployment.spec.strategy

# Test connectivity (quick debug pod)
k run tmp --image=busybox --rm -it -- wget -O- http://myapp:80
```

---

## vim Quick Reference

```
MOVEMENT:
  h j k l    left / down / up / right
  w / b      next word / previous word
  0 / $      start / end of line
  gg / G     top / bottom of file
  :10        go to line 10

EDITING:
  i          insert at cursor
  o          new line below
  x          delete char
  dd         delete line
  d5d        delete 5 lines
  yy         copy line
  5yy        copy 5 lines
  p / P      paste below / above
  u          undo
  Ctrl+r     redo

VISUAL MODE (indenting):
  V          select lines
  > / <      indent / unindent
  .          repeat last action

SEARCH & REPLACE:
  /term      search forward
  n / N      next / prev match
  :%s/old/new/g    replace all in file

SAVING:
  :w         save
  :wq        save and quit
  :q!        quit without saving

SPECIAL:
  :set paste       disable auto-indent before pasting
  :set nopaste     re-enable auto-indent
```

---

## Progress Tracker

### Week 1 — Tooling
- [x] Cluster setup (minikube/kind)
- [x] kubectl basics practiced daily
- [x] vim configured and practiced
- [x] K8s architecture understood

### Week 2 — Application Design & Build
- [ ] Multi-container pods (sidecar, init container)
- [ ] Jobs & CronJobs
- [ ] PV/PVC storage
- [ ] CKAD exercises: design sections completed

### Week 3 — Application Deployment
- [ ] Rolling updates + rollback
- [ ] Blue/Green strategy practiced
- [ ] Canary strategy practiced
- [ ] Helm basics (install/upgrade/rollback)

### Week 4 — Services & Networking
- [ ] Services (ClusterIP, NodePort)
- [ ] NetworkPolicy (ingress + egress rules)
- [ ] Ingress (path + host routing)
- [ ] DNS/connectivity testing with busybox

### Week 5 — Config, Security & Environment
- [ ] ConfigMaps (all 3 mount methods)
- [ ] Secrets (all 3 mount methods)
- [ ] SecurityContext (user, capabilities)
- [ ] ServiceAccounts
- [ ] ResourceQuota + LimitRange
- [ ] CRD awareness

### Week 6 — Observability & Maintenance
- [ ] Liveness + Readiness + Startup probes
- [ ] Logging commands mastered
- [ ] Debugging workflow practiced
- [ ] Common failure states: can diagnose all 5

### Week 7 — Review & Mock
- [ ] Full CKAD exercises run-through (timed)
- [ ] Killercoda scenarios completed
- [ ] Killer.sh session 1 completed
- [ ] Weak areas identified and reviewed

### Week 8 — Final Sprint
- [ ] Killer.sh session 2 completed
- [ ] Final checklist done
- [ ] Exam setup ritual memorized
- [ ] **READY TO ACE IT 🚀**

---

> **Remember:** The exam is open-book for kubernetes.io/docs.
> You don't need to memorize every YAML field — you need to know what exists and where to find it **fast**.
>
> *Good luck! You've got this.* 🎯
