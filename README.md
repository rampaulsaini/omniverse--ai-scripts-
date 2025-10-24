#!/usr/bin/env bash
set -euo pipefail

# CONFIG - change if needed
REPO_DIR="${1:-.}"   # default current dir; or pass path as first arg
QR_URL="https://i.ibb.co/QvVpFK6j/IMG-20251022-190835.webp"

cd "$REPO_DIR"

# ensure git repo
if [ ! -d .git ]; then
  echo "Not a git repo in $REPO_DIR. Clone first or run from repo root."
  exit 1
fi

BRANCH="restore/site-$(date +%s)"
git checkout -b "$BRANCH"

# create folders
mkdir -p web/assets

# write web/index.html
cat > web/index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>Support Omniverse AI Scripts — Donate</title>
  <style>
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f6f8fa}
    .card{background:white;padding:28px;border-radius:12px;box-shadow:0 6px 20px rgba(0,0,0,0.08);max-width:760px;width:100%}
    h1{margin:0 0 8px;font-size:20px}
    p{margin:6px 0 18px;color:#333}
    .methods{display:flex;gap:16px;flex-wrap:wrap}
    .method{flex:1;min-width:220px;padding:14px;border-radius:8px;border:1px solid #eee}
    .btn{display:inline-block;padding:10px 14px;border-radius:8px;text-decoration:none;font-weight:600}
    .paypal{background:#fff;padding:8px 12px;border-radius:8px;border:1px solid #d4d4d4}
    .upi-qr{max-width:180px;display:block;margin-top:10px}
    footer{margin-top:18px;color:#666;font-size:13px}
    .note{background:#fff8e1;padding:8px;border-radius:8px;margin-top:10px}
    code{background:#f5f5f5;padding:2px 6px;border-radius:4px}
  </style>
</head>
<body>
  <div class="card">
    <h1>Support this project — Help Saneha's education</h1>
    <p>If this project helps you, a small donation will go a long way toward my daughter's education and living expenses. Thank you ❤️</p>

    <div class="methods">
      <div class="method">
        <strong>PayPal</strong>
        <p>Contact / Donate via PayPal email:</p>
        <a class="btn paypal" href="mailto:sainirampaul60@gmail.com">Contact / Donate via PayPal (email)</a>
        <p style="margin-top:8px;font-size:13px;color:#444">Or send to: <code>sainirampaul60@gmail.com</code></p>
      </div>

      <div class="method">
        <strong>Google Pay / UPI</strong>
        <p>Scan the QR or use the UPI ID in your UPI app to pay instantly.</p>
        <p><strong>UPI ID:</strong> <code>sainirampaul90-1@okhdfcbank</code></p>
        <img class="upi-qr" src="assets/upi-qr.webp" alt="UPI QR (scan to pay)" onerror="this.style.display='none'"/>
        <p style="margin-top:8px;font-size:13px;color:#444">If QR doesn't display, use the UPI ID above in your UPI app.</p>
      </div>

      <div class="method">
        <strong>Other</strong>
        <p>Want to contact me first? Use email below or open an issue in the repo.</p>
        <p style="font-size:13px;">Email: <code>sainirampaul60@gmail.com</code></p>
      </div>
    </div>

    <div class="note">
      <strong>Privacy:</strong> I will not share donor details publicly without consent. For large donations, please email to coordinate receipts/info.
    </div>

    <footer>
      <p>Thank you for supporting open-source and Saneha's future.</p>
    </footer>
  </div>
</body>
</html>
HTML

# Dockerfile
cat > Dockerfile <<'DOCKER'
FROM python:3.11-slim
RUN useradd -m appuser
WORKDIR /home/appuser
COPY web ./web
EXPOSE 8080
USER appuser
CMD ["python", "-m", "http.server", "8080", "--directory", "web"]
DOCKER

# README restore (minimal)
cat > README.md <<'MD'
# omniverse--ai-scripts-

Personal fork for Omniverse AI + EcoSim scripts, automated PDF generation, and workflow testing. Fully safe, no upstream push.

## Donate / Support
- PayPal: sainirampaul60@gmail.com
- Google Pay / UPI: sainirampaul90-1@okhdfcbank
MD

# try download QR
if command -v curl >/dev/null 2>&1; then
  curl -L -o web/assets/upi-qr.webp "$QR_URL" || true
elif command -v wget >/dev/null 2>&1; then
  wget -O web/assets/upi-qr.webp "$QR_URL" || true
fi

# commit & push
git add web/index.html Dockerfile README.md web/assets/upi-qr.webp || true
git commit -m "restore: donation page, Dockerfile and QR" || true
git push -u origin "$BRANCH"

echo "Pushed branch $BRANCH to origin. If you want, create PR or I can guide next steps."
echo "If push failed, paste error here and I'll fix it."
