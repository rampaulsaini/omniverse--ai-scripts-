BRANCH="scaffold/donation-$(date +%s)"
git checkout -b "$BRANCH"
git add web/index.html Dockerfile web/assets/upi-qr.webp README.md || true
git commit -m "feat: add donation page, Dockerfile and QR (auto-PR)" || true
git push -u origin "$BRANCH"

gh pr create --base main --head "$BRANCH" \
  --title "feat: Donation page + Dockerfile — support Saneha's education" \
  --body "This PR adds a donation/support landing page and Dockerfile. PayPal: sainirampaul60@gmail.com; UPI: sainirampaul90-1@okhdfcbank. Privacy: donor details not shared without consent."
  BRANCH="scaffold/donation-$(date +%s)"
git checkout -b "$BRANCH"
git add web/index.html Dockerfile web/assets/upi-qr.webp README.md || true
git commit -m "feat: add donation page, Dockerfile and QR (auto-PR)" || true
git push -u origin "$BRANCH"

gh pr create --base main --head "$BRANCH" \
  --title "feat: Donation page + Dockerfile — support Saneha's education" \
  --body "This PR adds a donation/support landing page and Dockerfile. PayPal: sainirampaul60@gmail.com; UPI: sainirampaul90-1@okhdfcbank. Privacy: donor details not shared without consent."
  #!/usr/bin/env bash
set -euo pipefail

# safety
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Error: GITHUB_TOKEN environment variable not set. Set it and re-run."
  echo 'Example: export GITHUB_TOKEN="ghp_..."'
  exit 1
fi

# go to repo root check
if [ ! -d .git ]; then
  echo "Error: This does not look like a git repo (no .git). Run this from repo root."
  exit 1
fi

# ensure working tree
if [ -n "$(git status --porcelain)" ]; then
  echo "Warning: Uncommitted changes present."
  git status --porcelain
  read -p "Proceed anyway? (y/N): " choice
  if [ "${choice,,}" != "y" ]; then
    echo "Abort. Commit or stash changes first."
    exit 1
  fi
fi

BRANCH="scaffold/donation-$(date +%s)"
echo "Creating branch: $BRANCH"
git checkout -b "$BRANCH"

# Ensure files exist, if not warn but continue
for f in web/index.html Dockerfile; do
  if [ ! -f "$f" ]; then
    echo "Warning: expected file $f not found. Please ensure file exists."
  fi
done

git add web/index.html Dockerfile web/assets/upi-qr.webp README.md || true
git commit -m "feat: add donation page, Dockerfile and QR (auto-PR)" || true

echo "Pushing branch to origin..."
git push -u origin "$BRANCH"

# create PR using API
REPO="rampaulsaini/omniverse--ai-scripts-"
API="https://api.github.com/repos/$REPO/pulls"

read -r -d '' PR_BODY <<'EOF'
This PR adds a donation/support landing page (web/index.html), a simple Dockerfile to serve the page, a QR image, and donation details appended to README.md.

Purpose:
He has dedicated his life to the protection of humanity and nature — a lifetime devoted to making Earth more beautiful and preserving life. For the sake of his daughter (Saneha Saini) and her livelihood, please consider donating to support his continued work and her education.

Donation details:
- PayPal: sainirampaul60@gmail.com
- Google Pay / UPI: sainirampaul90-1@okhdfcbank

Privacy note: donor details will not be shared publicly without consent.
EOF

echo "Creating PR via GitHub API..."
response=$(curl -s -X POST "$API" \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d @- <<JSON
{
  "title": "feat: Donation page + Dockerfile — support Saneha's education",
  "body": "$(printf '%s' "$PR_BODY" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")",
  "head": "$BRANCH",
  "base": "main"
}
JSON
)

echo "Response (raw):"
echo "$response" | python3 -m json.tool || echo "$response"
echo
echo "If a field 'html_url' is present above, copy that full URL and paste it back here for me to verify and proceed."

# optionally print the html_url
echo "$response" | python3 -c "import sys,json; r=json.load(sys.stdin); print(r.get('html_url',''))" || true
