# Contributing to Kubelabs

Thank you for contributing to Kubelabs! This guide explains how to add new tutorials and keep the repository clean and well-structured.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Add a New Tutorial](#how-to-add-a-new-tutorial)
- [Tutorial Structure](#tutorial-structure)
- [Tutorial Checklist](#tutorial-checklist)
- [YAML Manifest Guidelines](#yaml-manifest-guidelines)
- [Validation](#validation)
- [Submitting a Pull Request](#submitting-a-pull-request)

---

## Code of Conduct

Be respectful, inclusive, and constructive. See the [Collabnix Community Slack](https://launchpass.com/collabnix) for community guidelines.

---

## How to Add a New Tutorial

1. **Pick a topic** — Check the existing directories to avoid duplicates. Good candidates are Kubernetes features, ecosystem tools, or cloud provider integrations not yet covered.

2. **Create the directory** — Name it `<Topic>101` for beginner content or `<Topic>201` for intermediate:

   ```bash
   mkdir Gateway101
   ```

3. **Follow the tutorial structure** described below.

4. **Validate your tutorial** before opening a PR:

   ```bash
   ./scripts/validate-tutorials.sh Gateway101/
   ```

5. **Open a Pull Request** targeting the `master` branch.

---

## Tutorial Structure

Every tutorial directory **must** contain:

```
<Topic>101/
├── README.md          ← Main tutorial file (required)
└── *.yaml             ← Kubernetes manifests referenced in the tutorial
```

Additional files (optional):

```
<Topic>101/
├── README.md
├── <subtopic>.md      ← Additional markdown pages for advanced topics
├── *.yaml             ← Manifest files
└── scripts/           ← Helper scripts (shell, Python, etc.)
```

---

## Tutorial Structure Template

Use the following template when creating a new tutorial (`README.md`):

```markdown
# <Topic> 101

A brief (2-3 sentence) description of what this topic is and why it matters.

## What You Will Learn

- Concept 1
- Concept 2
- Hands-on lab

## Prerequisites

- A running Kubernetes cluster (use [Play with Kubernetes](https://labs.play-with-k8s.com/) if needed)
- `kubectl` installed and configured
- Any topic-specific tools

---

## What is <Topic>?

<!-- Theory section: explain the concept clearly with diagrams or tables if helpful -->

---

## Lab 1: <First Lab Title>

<!-- Step-by-step instructions -->

```bash
# Example command
kubectl apply -f example.yaml
```

Expected output:

```
<paste real output here>
```

---

## Cleaning Up

<!-- Always include cleanup instructions -->

```bash
kubectl delete -f example.yaml
```

---

## Further Reading

- [Official Docs](https://kubernetes.io/docs/)
- Related tutorials in this repo
```

---

## Tutorial Checklist

Before opening a PR, verify:

- [ ] Directory is named `<Topic>101` or `<Topic>201`
- [ ] `README.md` exists and is non-empty (≥ 100 bytes)
- [ ] `README.md` starts with an `# H1` heading
- [ ] All YAML manifests are syntactically valid (`yamllint`)
- [ ] All YAML manifests include `resources.requests` and `resources.limits` for containers
- [ ] Steps are in logical order and can be followed top-to-bottom
- [ ] A "Cleaning Up" section is included
- [ ] A "Further Reading" or "Next Steps" section is included
- [ ] The tutorial is linked from `README.md` in the repo root
- [ ] `./scripts/validate-tutorials.sh <dir>` passes with no errors

---

## YAML Manifest Guidelines

- Always specify `apiVersion`, `kind`, `metadata`, and `spec`
- Always add `resources.requests` and `resources.limits` to container specs
- Use `namespace: default` explicitly unless a different namespace is required
- Add comments to explain non-obvious fields
- Use realistic but minimal resource values (e.g., `cpu: "50m"`, `memory: "64Mi"`)
- Prefer multi-document YAML files (separated by `---`) over many single-resource files

---

## Validation

The repository includes an automated validator. Run it locally before opening a PR:

```bash
# Validate all tutorials
./scripts/validate-tutorials.sh

# Validate a specific tutorial
./scripts/validate-tutorials.sh Gateway101/
```

The validator checks:

1. ✅ `README.md` exists
2. ✅ `README.md` has at least 100 bytes of content
3. ✅ `README.md` contains a Markdown heading
4. ✅ All `*.yaml` / `*.yml` files are syntactically valid
5. ⚠️  No placeholder links (e.g., `TODO`, `FIXME`, bare `#`)

The same validation runs automatically in CI on every pull request via the **Validate Tutorials** GitHub Actions workflow.

---

## Submitting a Pull Request

1. Fork the repository and create a feature branch:

   ```bash
   git checkout -b add-gateway101-tutorial
   ```

2. Make your changes following the guidelines above.

3. Run the validator:

   ```bash
   ./scripts/validate-tutorials.sh <YourTopic>101/
   ```

4. Commit your changes with a descriptive message:

   ```bash
   git commit -m "Add Gateway API 101 tutorial"
   ```

5. Push and open a Pull Request against `master`.

6. The automated CI will:
   - Validate tutorial structure
   - Lint Markdown files
   - Validate YAML syntax
   - Summarise changed tutorial directories

7. Address any review comments and update your PR.

---

Thank you for helping make Kubelabs the best free Kubernetes learning platform! 🚀
