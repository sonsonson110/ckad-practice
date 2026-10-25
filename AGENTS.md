# AGENTS.md — Session Context for AI Assistants

> This file provides persistent context about the user and this workspace.
> **Every AI agent/session should read this first** before making suggestions or changes.

---

## 👤 About the User

- **Role:** Software developer with day-to-day Kubernetes usage
- **Current k8s knowledge:** Comfortable with Deployments, Services, Ingress, ConfigMaps in a working context. Not deeply familiar with `kubectl` imperative workflows or `vim`.
- **Goal:** Pass the **CKAD (Certified Kubernetes Application Developer)** exam
- **Study timeline:** 2 months (8 weeks), relaxed pace — depth and clarity over speed
- **Studying since:** October 2025

---

## 📁 Workspace Structure

```
ckad-practice/
├── AGENTS.md                  ← this file (session context)
├── CKAD_ROADMAP.md            ← the main 8-week study plan (source of truth)
└── weekN/
    ├── labs/
    │   ├── labXX-<topic>.md   ← lab instruction files
    │   └── checks/
    │       └── labXX-check.sh ← automated review + auto-cleanup scripts
    └── resources/             ← user saves their YAML practice files here
```

Add practice YAML files, notes, and exercises here as the study progresses.

---

## 📌 Current Study Plan

The full roadmap is in [`CKAD_ROADMAP.md`](./CKAD_ROADMAP.md).

### 8-Week Overview

| Week | Topic | Exam Domain Weight |
|------|-------|--------------------|
| 1 | kubectl fluency, vim, k8s architecture | Foundation |
| 2 | Application Design & Build (Jobs, multi-container pods, PVC) | 20% |
| 3 | Application Deployment (rolling updates, blue/green, canary, Helm) | 20% |
| 4 | Services & Networking (NetworkPolicy, Ingress, DNS) | 20% |
| 5 | Config, Security & Environment (ConfigMaps, Secrets, SecurityContext, SA) | **25%** |
| 6 | Observability & Maintenance (probes, logs, debugging) | 15% |
| 7 | Full review + CKAD exercises + Killer.sh session 1 | Mock |
| 8 | Killer.sh session 2 + final polish + exam | Final |

---

## 🎯 CKAD Exam Quick Facts

- **Format:** Performance-based, live terminal (not multiple choice)
- **Duration:** 2 hours, ~15–20 tasks
- **Pass score:** 66%
- **Allowed during exam:** kubernetes.io/docs, kubernetes.io/blog, helm.sh
- **Free retake:** 1 included with purchase
- **Simulator:** killer.sh (2 sessions included — harder than real exam)

---

## 🧠 Key Conventions & Preferences

### Workflow Style
- **Always prefer imperative commands** to generate YAML skeletons, then edit declaratively:
  ```bash
  kubectl run nginx --image=nginx --dry-run=client -o yaml > pod.yaml
  vim pod.yaml
  kubectl apply -f pod.yaml
  ```
- Use `$do="--dry-run=client -o yaml"` and `$now="--force --grace-period=0"` shortcuts
- Use `alias k=kubectl` in all examples

### When Creating Practice Files
- Save YAML practice files in topic subfolders, e.g., `week2/`, `week3/`, etc.
- Name files descriptively: `pod-init-container.yaml`, `networkpolicy-deny-all.yaml`
- Always include comments in practice YAML explaining what each section does

### Lab Exercise Format (standard for all weeks)

Use this structure when creating lab exercises for any week:

#### Folder layout
```
weekN/
├── labs/
│   ├── lab01-<topic>.md        ← step-by-step instructions
│   ├── lab02-<topic>.md
│   └── checks/
│       ├── lab01-check.sh      ← automated review script
│       └── lab02-check.sh
└── resources/                  ← user saves their own YAML files here
```

#### Lab instruction file (`labXX-<topic>.md`) must include
- Frontmatter: topic, exam domain, estimated time, **namespace** (`ckad-labXX`), and check command
- A `## 🎯 Objective` section with **all required resource names, images, config values, and constraints** stated explicitly — the user must be able to complete the lab using only this section
- Tasks broken into lettered steps (A, B, C…) — **steps describe what to do, not how to do it** (no commands, YAML snippets, hints, or expected output in the task list)
- A `## 🏁 Check your work` section at the bottom pointing to the check script
- A `## 🧹 Manual Cleanup` section (for use only if the auto-check fails)

#### Lab instruction file must NOT include
- Hints, tips, or "key concepts" tables
- Imperative commands or YAML answers inside the task steps
- "Expected result" or "expected output" sections
- Exam tips or explanatory notes within the lab body

#### Review script (`labXX-check.sh`) must
- Target one namespace: `NS="ckad-labXX"`
- Define `pass()` / `fail()` / `info()` helpers with colour output
- Run numbered checks with a specific `💡 Hint` on each failure
- **Auto-delete the namespace** (`kubectl delete namespace $NS --force --grace-period=0`) only when ALL checks pass
- Exit with code 1 if any check fails

#### Namespace convention
- Pattern: `ckad-labXX` (e.g. `ckad-lab01`, `ckad-lab02`)
- **The user creates their own namespaces** — do NOT auto-create them in scripts or during setup
- Remind the user to create namespaces before starting: `k create namespace ckad-labXX`

### Documentation References
- Prefer linking to official k8s docs: `https://kubernetes.io/docs/`
- For any CKAD topic, know the exact docs URL path (user practices navigating docs quickly)

---

## ✅ Progress Log

> Update this section as weeks are completed.

- [x] **Week 1** — kubectl fluency + vim + k8s architecture ✅ (Oct 2026)
- [x] **Week 2** — Application Design & Build ✅ (Oct 2026)
- [ ] **Week 3** — Application Deployment
- [ ] **Week 4** — Services & Networking
- [ ] **Week 5** — Config, Security & Environment
- [ ] **Week 6** — Observability & Maintenance
- [ ] **Week 7** — Full Review + Mock Exams
- [ ] **Week 8** — Killer.sh + Final Polish

---

## 💡 Agent Guidance

When helping this user:

1. **Assume CKAD context** — all kubectl examples should be exam-oriented (imperative-first, fast, no unnecessary verbosity)
2. **Use `k` alias** in all command examples instead of `kubectl`
3. **Highlight exam relevance** — when explaining a concept, note if it's high-yield for the exam
4. **Prefer hands-on practice** over theory — suggest exercises, not just explanations
5. **Reference the roadmap** — if the user asks about a topic, point to the relevant week in `CKAD_ROADMAP.md`
6. **Keep vim tips handy** — user is still building vim fluency; mention relevant shortcuts when editing YAML
7. **Domain weights matter** — Week 5 (Config/Security) is 25% of the exam; prioritize it when time is limited
