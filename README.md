# 1. make a branch, remove bad content from README and commit
git checkout -b fix/readme-remove-yaml

# Edit README.md (use your editor) and remove the pasted YAML block
# On a PC you can use: nano README.md
# On mobile Termux use: nano or sed; but web UI is easier.

git add README.md
git commit -m "fix: remove accidental workflow YAML from README"

# 2. create workflow file
mkdir -p .github/workflows
cat > .github/workflows/open-issue-dispatch.yml <<'YAML'
# (paste the corrected YAML provided below)
YAML

git add .github/workflows/open-issue-dispatch.yml
git commit -m "chore: add Open Issue manual workflow"
git push -u origin HEAD
# Then open a PR on GitHub for merge (or merge if you can)
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
      - name: Build JSON payload
        id: build_payload
        shell: bash
        run: |
          TITLE="${{ github.event.inputs.title }}"
          BODY="${{ github.event.inputs.body }}"
          LABELS_RAW="${{ github.event.inputs.labels }}"
          ASSIGNEES_RAW="${{ github.event.inputs.assignees }}"

          if [ -n "${LABELS_RAW// /}" ]; then
            IFS=',' read -ra LARR <<< "$LABELS_RAW"
            LABELS_JSON="$(printf '%s\n' "${LARR[@]}" | python3 -c 'import sys,json; print(json.dumps([s.strip() for s in sys.stdin.read().splitlines() if s.strip()]))')"
          else
            LABELS_JSON="[]"
          fi

          if [ -n "${ASSIGNEES_RAW// /}" ]; then
            IFS=',' read -ra AARR <<< "$ASSIGNEES_RAW"
            ASSIGNEES_JSON="$(printf '%s\n' "${AARR[@]}" | python3 -c 'import sys,json; print(json.dumps([s.strip() for s in sys.stdin.read().splitlines() if s.strip()]))')"
          else
            ASSIGNEES_JSON="[]"
          fi

          # safe payload using jq (available on runner)
          jq -n --arg title "$TITLE" --arg body "$BODY" \
            --argjson labels "$LABELS_JSON" --argjson assignees "$ASSIGNEES_JSON" \
            '{title: $title, body: $body, labels: $labels, assignees: $assignees}' > /tmp/payload.json

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
          issue_number=$(echo "$resp" | jq -r '.number // ""')
          echo "issue_url=$issue_url" >> $GITHUB_OUTPUT
          echo "issue_number=$issue_number" >> $GITHUB_OUTPUT

      - name: Result
        run: |
          echo "Issue created: ${{ steps.create_issue.outputs.issue_url }}"
          
