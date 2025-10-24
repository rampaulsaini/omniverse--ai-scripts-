FROM python:3.11-slim
RUN useradd -m appuser
WORKDIR /home/appuser
COPY web ./web
EXPOSE 8080
USER appuser
CMD ["python", "-m", "http.server", "8080", "--directory", "web"]
# omniverse--ai-scripts-

Personal fork for Omniverse AI + EcoSim scripts, automated PDF generation, and workflow testing. Fully safe, no upstream push.

## Donate / Support
If this project helped you, please consider supporting Saneha Saini's education and living expenses:

- **PayPal:** https://paypal.me/yourid  (replace with your PayPal.Me link or keep `sainirampaul60@gmail.com`)
- **Google Pay / UPI:** `sainirampaul90-1@okhdfcbank` (scan the QR on the project website)

Website (donation page): `https://<your-app>.koyeb.app` (will appear after deploy)
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
        <p>Donate via PayPal link:</p>
        <a class="btn paypal" href="https://paypal.me/yourid" target="_blank" rel="noopener">Donate with PayPal</a>
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
        <p>Contact: <code>sainirampaul60@gmail.com</code></p>
      </div>
    </div>

    <div class="note">
      <strong>Privacy:</strong> Donor details will not be shared publicly without consent.
    </div>

    <footer>
      <p>Thank you for supporting Saneha's future.</p>
    </footer>
  </div>
</body>
</html>
pkg update -y
pkg install git -y
cd $HOME
git clone https://github.com/rampaulsaini/omniverse--ai-scripts-.git
cd omniverse--ai-scripts-

# Replace README
cat > README.md <<'EOF'
# omniverse--ai-scripts-

Personal fork for Omniverse AI + EcoSim scripts, automated PDF generation, and workflow testing. Fully safe, no upstream push.

## Donate / Support
- PayPal: https://paypal.me/yourid
- Google Pay / UPI: sainirampaul90-1@okhdfcbank
EOF

# Create web files
mkdir -p web/assets
cat > web/index.html <<'EOF'
(paste the HTML from above)
EOF

# If you have the QR file on phone, move it into repo at web/assets/upi-qr.webp,
# or download it:
curl -L -o web/assets/upi-qr.webp "https://i.ibb.co/QvVpFK6j/IMG-20251022-190835.webp" || true

# Dockerfile
cat > Dockerfile <<'EOF'
(paste Dockerfile from above)
EOF

git add README.md web/index.html web/assets/upi-qr.webp Dockerfile
git commit -m "restore donation page, QR and Dockerfile"
git push origin main
