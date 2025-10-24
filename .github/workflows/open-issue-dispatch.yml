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
          # read inputs and create JSON for GitHub API
          TITLE="${{ github.event.inputs.title }}"
          BODY="${{ github.event.inputs.body }}"
          LABELS_RAW="${{ github.event.inputs.labels }}"
          ASSIGNEES_RAW="${{ github.event.inputs.assignees }}"

          # convert comma-separated lists to JSON arrays (empty array if none)
          if [ -n "${LABELS_RAW// /}" ]; then
            # split on comma, trim spaces
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

          # Create payload file safely
          python3 - <<PY > /tmp/payload.json
import json,sys
p = {
  "title": """%s""",
  "body": """%s""",
  "labels": %s,
  "assignees": %s
}
print(json.dumps(p))
PY
$(printf '%s\n' "$TITLE" "$BODY" "$LABELS_JSON" "$ASSIGNEES_JSON" | sed '1s/^/%s\n/' )
# The above safe approach prints payload to /tmp/payload.json using python; alternatively write with here-doc
          # fallback simple here-doc (robust for most uses)
          cat > /tmp/payload.json <<EOF
{
  "title": $(jq -Rn --arg v "$TITLE" '$v'),
  "body": $(jq -Rn --arg v "$BODY" '$v'),
  "labels": $(echo $LABELS_JSON),
  "assignees": $(echo $ASSIGNEES_JSON)
}
EOF
          echo "Payload written to /tmp/payload.json"
          cat /tmp/payload.json

      - name: Create issue via REST API
        id: create_issue
        shell: bash
        run: |
          # Use the built-in GITHUB_TOKEN (no secret needed)
          resp=$(curl --fail --show-error --silent \
            -X POST \
            -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
            -H "Accept: application/vnd.github+json" \
            -H "Content-Type: application/json" \
            --data @/tmp/payload.json \
            "https://api.github.com/repos/${{ github.repository }}/issues")

          echo "$resp" | jq . || true

          # capture issue html_url for workflow outputs
          issue_url=$(echo "$resp" | jq -r '.html_url // ""')
          issue_number=$(echo "$resp" | jq -r '.number // ""')
          echo "issue_url=$issue_url" >> $GITHUB_OUTPUT
          echo "issue_number=$issue_number" >> $GITHUB_OUTPUT

      - name: Result
        run: |
          echo "Issue created: ${{ steps.create_issue.outputs.issue_url }}"
          
