# Exam Setup Ritual

> **Memorize this cold.** Do it within the first 60 seconds of every exam session.
> You get a terminal — this is the first thing you type.

---

## ⚡ Full Setup Script (copy-paste at exam start)

```zsh
# 1. Completion system init (required before compdef works)
autoload -Uz compinit && compinit

# 2. Alias + autocomplete — ORDER MATTERS
source <(kubectl completion zsh)
alias k=kubectl
compdef k=kubectl   # must come after both compinit and source above

# 3. Time-saving shortcuts (arrays — required in zsh for correct word splitting)
do=(--dry-run=client -o yaml)
now=(--force --grace-period=0)

# 4. vim config
cat << 'EOF' >> ~/.vimrc
set tabstop=2
set expandtab
set shiftwidth=2
set number
EOF
```

---

## 🔄 Per-Question Ritual (every single question)

```bash
# Step 1: Switch context (copy-paste from question)
k config use-context <context-name>

# Step 2: Set namespace
k config set-context --current --namespace=<namespace>

# Step 3: Verify (optional but safe)
k config view --minify | grep namespace
```

> **Never skip this.** Wrong context = working on the wrong cluster = 0 points.

---

## 📝 The Generate-Then-Edit Rule

**Never write YAML from scratch.**

```
1. Generate:  k <command> $do > file.yaml
2. Edit:      vim file.yaml
3. Apply:     k apply -f file.yaml
4. Verify:    k get/describe <resource>
```

---

## 🌐 Allowed Docs — Know These URLs

Open these tabs at exam start:

| Topic | URL |
|-------|-----|
| kubectl cheatsheet | kubernetes.io/docs/reference/kubectl/cheatsheet/ |
| NetworkPolicy | kubernetes.io/docs/concepts/services-networking/network-policies/ |
| PersistentVolume | kubernetes.io/docs/concepts/storage/persistent-volumes/ |
| Security Context | kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| Ingress | kubernetes.io/docs/concepts/services-networking/ingress/ |
| Probes | kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| RBAC | kubernetes.io/docs/reference/access-authn-authz/rbac/ |

---

## ⏰ Time Strategy

| Time Range | Action |
|------------|--------|
| 0–5 min | Skim ALL questions. Mark easy/hard. |
| 5–90 min | Work through questions. Flag anything > 5 min. |
| 90–120 min | Return to flagged questions. |

- Target **5–6 minutes max** per question
- Partial credit exists → attempt something even if unsure
- Easy questions first, hard questions flagged for later
