# vim Reference for YAML Editing

> Goal: fast, accurate YAML editing. You need this for 100% of exam questions.

---

## 🔧 One-Time Setup (do at exam start)

```bash
cat << 'EOF' >> ~/.vimrc
set tabstop=2
set expandtab
set shiftwidth=2
set number
EOF
```

| Setting | Effect |
|---------|--------|
| `tabstop=2` | Tab = 2 spaces |
| `expandtab` | Tab key inserts spaces (critical for YAML) |
| `shiftwidth=2` | `>>` indent = 2 spaces |
| `number` | Show line numbers |

---

## 🗺️ Movement

| Key | Action |
|-----|--------|
| `h j k l` | ← ↓ ↑ → |
| `w / b` | next / prev word |
| `0 / $` | start / end of line |
| `gg / G` | top / bottom of file |
| `:10` | jump to line 10 |

---

## ✏️ Editing

| Key | Action |
|-----|--------|
| `i` | Insert at cursor |
| `a` | Insert after cursor |
| `o` | New line below + insert |
| `O` | New line above + insert |
| `ESC` | Back to Normal mode |
| `x` | Delete char under cursor |
| `dd` | Delete (cut) current line |
| `d5d` | Delete 5 lines |
| `yy` | Copy (yank) current line |
| `5yy` | Copy 5 lines |
| `p / P` | Paste below / above |
| `u` | Undo |
| `Ctrl+r` | Redo |

---

## 🔡 Visual Mode (for indenting blocks — used constantly in YAML)

```
V          → enter line-select mode
↑ / ↓ or j/k  → select more lines
> / <      → indent / unindent selected block
.          → repeat last action
```

**Example flow** — indent a block of YAML 2 levels:
1. `V` → select lines
2. `>` → indent once (2 spaces)
3. `>` again or `.` → indent again

---

## 🔎 Search & Replace

| Command | Action |
|---------|--------|
| `/term` | Search forward |
| `n / N` | Next / prev match |
| `:%s/old/new/g` | Replace all in file |
| `:%s/old/new/gc` | Replace all with confirmation |

---

## 💾 Saving

| Command | Action |
|---------|--------|
| `:w` | Save |
| `:wq` or `ZZ` | Save and quit |
| `:q!` | Quit WITHOUT saving |
| `:wq!` | Force save and quit |

---

## 📋 Paste Mode (use when pasting from clipboard)

```vim
:set paste      ← disable auto-indent before pasting
:set nopaste    ← re-enable after pasting
```

> Without `:set paste`, pasting YAML from clipboard will stair-step indent — broken YAML.

---

## 🔥 Exam Workflow Example

```bash
# 1. Generate skeleton
k run nginx --image=nginx $do > pod.yaml

# 2. Open in vim
vim pod.yaml

# 3. Navigate, edit what you need
#    - Use 'i' to insert
#    - Use 'V + > or <' for indentation
#    - Use ':set paste' before any clipboard paste

# 4. Save and apply
# :wq
k apply -f pod.yaml
k get pod nginx    # verify
```
