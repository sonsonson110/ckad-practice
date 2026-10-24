# Kubernetes Architecture — Quick Reference

> You already use k8s daily — this is just naming the things you implicitly know.
> Spend ~30 min here, not more. Architecture questions are rare in CKAD.

---

## 🏗️ The Two Layers

```
┌─────────────────────────────────────────────┐
│              CONTROL PLANE                  │
│  API Server → etcd                          │
│  Scheduler → Controller Manager             │
└─────────────────────────────────────────────┘
            ↓ instructions
┌─────────────────────────────────────────────┐
│               WORKER NODES                  │
│  kubelet + kube-proxy + container runtime   │
└─────────────────────────────────────────────┘
```

---

## 🧠 Control Plane Components

| Component | What it does | Think of it as... |
|-----------|-------------|-------------------|
| **API Server** | Central gateway — all kubectl commands hit this | The front door |
| **etcd** | Distributed key-value store — the source of truth for all cluster state | The database |
| **Scheduler** | Decides which node a new pod runs on | The placement engine |
| **Controller Manager** | Runs control loops (e.g. "ensure 3 replicas exist") | The autopilot |

---

## ⚙️ Node Components

| Component | What it does |
|-----------|-------------|
| **kubelet** | Agent on each node — talks to API Server, manages pod lifecycle |
| **kube-proxy** | Manages network rules for Services (routing traffic to pods) |
| **Container Runtime** | Actually runs containers (containerd, CRI-O) |

---

## 🛤️ Pod Scheduling Flow

```
kubectl apply -f pod.yaml
        ↓
   API Server (validates + stores in etcd)
        ↓
   Scheduler (watches for unscheduled pods, picks a node)
        ↓
   API Server (writes node assignment to etcd)
        ↓
   kubelet on that node (watches etcd, pulls image, starts container)
        ↓
   Pod is Running ✅
```

---

## 🔒 RBAC Overview (lightweight — more in Week 5)

| Object | Defines |
|--------|---------|
| **Role** | Permissions within a namespace |
| **ClusterRole** | Permissions cluster-wide |
| **RoleBinding** | Grants a Role to a user/serviceaccount in a namespace |
| **ClusterRoleBinding** | Grants a ClusterRole cluster-wide |

```bash
# Quick check what you can do
k auth can-i create pods
k auth can-i create pods --as=system:serviceaccount:default:mysa
```

---

## 📦 Namespaces

```bash
k get namespaces
k create ns myns
k get pods -n myns
k get pods -A            # all namespaces

# Switch default namespace for current session
k config set-context --current --namespace=myns
```

- Namespaces = logical isolation within a cluster
- `default` → where things land if no namespace specified
- `kube-system` → control plane components live here
- Resources like Nodes, PersistentVolumes, ClusterRoles = **not namespaced** (cluster-wide)

---

## 💡 What the CKAD Exam Actually Tests From This

- Know that API Server is the central hub → all `kubectl` goes through it
- Know that kubelet runs on nodes and manages pods
- Know namespace isolation + how to switch between them
- Know RBAC exists → ServiceAccounts, RoleBindings (Week 5 deep dive)

> You won't be asked "what port does the API server use" — you'll be asked to *use* these components correctly.
