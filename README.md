# omniverse--ai-scripts-

Personal fork for Omniverse AI + EcoSim scripts, automated PDF generation, and workflow testing. Fully safe, no upstream push.

## What this repo contains (base)
- `.github/workflows/` — CI / automation workflows
- `web/` — static donation page
- `src/` — scripts
- `docs/` — generated PDFs and docs

## Donate / Support
If this project helps you, please consider supporting Saneha Saini's education and livelihood:

- PayPal: `sainirampaul60@gmail.com`
- Google Pay / UPI: `sainirampaul90-1@okhdfcbank`

---

**Note:** This README is a minimal restore. If you want, I can expand it with the full project instructions and links after the repo is stable.
# 1) install git in Termux (only if not installed)
pkg update -y
pkg install git -y

# 2) clone your repo (use SSH if you have keys, else HTTPS)
git clone https://github.com/rampaulsaini/omniverse--ai-scripts-.git
cd omniverse--ai-scripts-

# 3) create/replace workflow file
mkdir -p .github/workflows
cat > .github/workflows/open-issue-dispatch.yml <<'EOF'
[PASTE THE FIXED YAML HERE]
EOF

# 4) replace README
cat > README.md <<'EOF'
[PASTE THE MINIMAL README HERE]
EOF

# 5) commit & push (you will need credentials - use username+password or gh cli)
git add .github/workflows/open-issue-dispatch.yml README.md
git commit -m "fix: restore README and open-issue workflow"
git push origin main
name: Open Issue (manual)

on:
  workflow_dispatch:
    inputs:
      title:
        description: 'Issue title'
        required: false
        default: 'Manual issue: please review - run by workflow_dispatch'
      body:
        description: 'Issue body (markdown allowed)'
        required: false
        default: |
          This issue was opened by the workflow **${{ github.workflow }}** (event: ${{ github.event_name }}).

          Repository: ${{ github.repository }}
          Triggered by actor: ${{ github.actor }}
          Run: ${{ github.run_url }}
      labels:
        description: 'Comma-separated labels (optional)'
        required: false
        default: ''
      assignees:
        description: 'Comma-separated assignees (optional)'
        required: false
        default: ''

jobs:
  open_issue:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      issues: write

    steps:
      - name: Build JSON payload (safe)
        id: build_payload
        shell: bash
        run: |
          set -euo pipefail
          TITLE="${{ github.event.inputs.title }}"
          BODY="${{ github.event.inputs.body }}"
          LABELS_RAW="${{ github.event.inputs.labels }}"
          ASSIGNEES_RAW="${{ github.event.inputs.assignees }}"

          labels_json='[]'
          if [ -n "${LABELS_RAW// /}" ]; then
            IFS=',' read -ra _L <<< "$LABELS_RAW"
            printf '%s\n' "${_L[@]}" | python3 -c 'import sys,json; print(json.dumps([s.strip() for s in sys.stdin.read().splitlines() if s.strip()]))' > /tmp/labels.json
            labels_json=$(cat /tmp/labels.json)
          fi

          assignees_json='[]'
          if [ -n "${ASSIGNEES_RAW// /}" ]; then
            IFS=',' read -ra _A <<< "$ASSIGNEES_RAW"
            printf '%s\n' "${_A[@]}" | python3 -c 'import sys,json; print(json.dumps([s.strip() for s in sys.stdin.read().splitlines() if s.strip()]))' > /tmp/assignees.json
            assignees_json=$(cat /tmp/assignees.json)
          fi

          jq -n --arg title "$TITLE" --arg body "$BODY" \
            --argjson labels "$labels_json" --argjson assignees "$assignees_json" \
            '{title:$title, body:$body, labels:$labels, assignees:$assignees}' > /tmp/payload.json

          echo "Payload written to /tmp/payload.json"
          cat /tmp/payload.json

      - name: Create issue via REST API
        id: create_issue
        shell: bash
        run: |
          resp=$(curl --fail --show-error --silent \
            -X POST \
            -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
            -H "Accept: application/vnd.github+json" \
            -H "Content-Type: application/json" \
            --data @/tmp/payload.json \
            "https://api.github.com/repos/${{ github.repository }}/issues")
          echo "$resp" | jq . || true
          issue_url=$(echo "$resp" | jq -r '.html_url // ""')
          echo "issue_url=$issue_url" >> $GITHUB_OUTPUT

      - name: Result
        run: |
          echo "Issue created: ${{ steps.create_issue.outputs.issue_url }}"
          # omniverse--ai-scripts-

Personal fork for Omniverse AI + EcoSim scripts, automated PDF generation, and workflow testing. Fully safe, no upstream push.

## Donate / Support
- PayPal: `sainirampaul60@gmail.com`
- Google Pay / UPI: `sainirampaul90-1@okhdfcbank`
- 
