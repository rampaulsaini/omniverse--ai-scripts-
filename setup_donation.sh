#!/usr/bin/env bash
set -euo pipefail

# Simple helper to print and run
run() { echo "+ $*"; eval "$*"; }

# If not in a git repo, ask to clone
if [ ! -d .git ]; then
  echo "यह directory Git repository नहीं दिखती।"
  read -p "क्या आप repo क्लोन करना चाहेंगे? (y/n) " clone_choice
  if [ "${clone_choice,,}" = "y" ]; then
    read -p "Enter Git clone URL (SSH or HTTPS): " CLONE_URL
    run "git clone \"$CLONE_URL\" repo-temp"
    cd repo-temp
  else
    echo "कृपया पहले repo क्लोन करके इस स्क्रिप्ट को repo के root में चलाएँ."
    exit 1
  fi
fi

# Ensure working tree clean (warn only)
if [ -n "$(git status --porcelain)" ]; then
  echo "Warning: आपका git working tree clean नहीं है। Uncommitted changes मौजूद हैं."
  read -p "Proceed anyway? (y/n) " proceed
  if [ "${proceed,,}" != "y" ]; then
    echo "Abort. कृपया changes commit/stash करें और फिर चलाएँ."
    exit 1
  fi
fi

BRANCH="scaffold/donation-$(date +%s)"
echo "Creating branch: $BRANCH"
run "git checkout -b \"$BRANCH\""

# Create folders
run "mkdir -p web/assets .github/workflows src docs config tests"

# Write web/index.html (corrected content)
cat > web/index.html <<'EOF'
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
        <p>Click below to open your email client to contact or donate via PayPal.</p>
        <a class="btn paypal" href="mailto:sainirampaul60@gmail.com">Contact / Donate via PayPal (email)</a>
        <p style="margin-top:8px;font-size:13px;color:#444">Or send to: <code>sainirampaul60@gmail.com</code></p>
        <p style="margin-top:6px;font-size:13px;color:#444">(If you have a PayPal.Me link, replace the button href with that link.)</p>
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
EOF

# Write Dockerfile
cat > Dockerfile <<'EOF'
# Use a small Python base image
FROM python:3.11-slim

# Create non-root user
RUN useradd -m appuser
WORKDIR /home/appuser

# Copy web static files
COPY web ./web

# Expose port that Koyeb expects
EXPOSE 8080

# Switch to non-root
USER appuser

# Use Python's builtin http.server to serve static site on startup
CMD ["python", "-m", "http.server", "8080", "--directory", "web"]
EOF

# Update README donation snippet append (if README exists append, else create)
README_FILE="README.md"
cat >> "$README_FILE" <<'EOF'

## Support this project / Donate

If this project helped you, please consider supporting my daughter's education (Saneha Saini) and ongoing maintenance of these tools.

- **PayPal:** send to `sainirampaul60@gmail.com`
- **Google Pay / UPI:** `sainirampaul90-1@okhdfcbank` (or scan the QR on the project website)
- **Email:** `sainirampaul60@gmail.com` — for large donations or invoicing.

Any donation, big or small, is deeply appreciated and will be used for education and living expenses. Thank you.

EOF

# Try to download provided QR image into web/assets
QR_URL="https://i.ibb.co/QvVpFK6j/IMG-20251022-190835.webp"
echo "Downloading QR image from $QR_URL ..."
if command -v curl >/dev/null 2>&1; then
  run "curl -L -o web/assets/upi-qr.webp \"$QR_URL\" || true"
elif command -v wget >/dev/null 2>&1; then
  run "wget -O web/assets/upi-qr.webp \"$QR_URL\" || true"
else
  echo "Note: curl/wget not found. Please manually download the QR and place it at web/assets/upi-qr.webp"
fi

# Stage changes
run "git add web/index.html Dockerfile web/assets/upi-qr.webp README.md || true"

# Commit
run "git commit -m \"feat: add donation page, Dockerfile and QR (scaffold)\" || true"

# Push branch
origin_url=$(git config --get remote.origin.url || true)
if [ -z "$origin_url" ]; then
  echo "No remote origin configured. Please add remote and push manually."
  exit 1
fi

echo "Pushing branch to origin: $BRANCH"
run "git push -u origin \"$BRANCH\""

# Try to create PR if gh (GitHub CLI) exists
if command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI found. Creating a Pull Request..."
  run "gh pr create --fill --base main --head \"$BRANCH\""
  echo "PR created (check GitHub)."
else
  echo "GitHub CLI (gh) not found. Please open a Pull Request on GitHub from branch: $BRANCH -> main"
fi

echo "Done. 🎉"
echo "Next: Go to GitHub, review the PR and merge it to main (or have someone with merge rights do so)."
git checkout -b scaffold/donation
git add web/index.html web/assets/upi-qr.webp README.md Dockerfile || true
git commit -m "feat: add donation page (Hindi) + UPI QR + Dockerfile"
git push -u origin scaffold/donation
<!doctype html>
<html lang="hi">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <title>समर्थन — Omniverse AI Scripts (दान)</title>
  <style>
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto,Helvetica,Arial;display:flex;align-items:center;justify-content:center;min-height:100vh;margin:0;background:#f6f8fa}
    .card{background:white;padding:28px;border-radius:12px;box-shadow:0 6px 20px rgba(0,0,0,0.08);max-width:860px;width:100%}
    h1{margin:0 0 8px;font-size:22px}
    p{margin:6px 0 18px;color:#333;line-height:1.5}
    .methods{display:flex;gap:16px;flex-wrap:wrap}
    .method{flex:1;min-width:240px;padding:14px;border-radius:8px;border:1px solid #eee}
    .btn{display:inline-block;padding:10px 14px;border-radius:8px;text-decoration:none;font-weight:600}
    .paypal{background:#fff;padding:8px 12px;border-radius:8px;border:1px solid #d4d4d4}
    .upi-qr{max-width:180px;display:block;margin-top:10px}
    footer{margin-top:18px;color:#666;font-size:13px}
    .note{background:#fff8e1;padding:8px;border-radius:8px;margin-top:10px}
    code{background:#f5f5f5;padding:2px 6px;border-radius:4px}
    .hero{margin-bottom:12px}
  </style>
</head>
<body>
  <div class="card">
    <div class="hero">
      <h1>इस परियोजना का समर्थन करें — Saneha की पढ़ाई और जीवन-यापन के लिए दान</h1>
      <p>
        मैंने इस प्रोजेक्ट को मानवता और प्रकृति के संरक्षण के उद्देश्य से समर्पित किया है।  
        मैं शिरोमणि रामपुलसैनी — तुलनातीत प्रेमतीत, कालातीत और शब्दातीत — सच्चे और समर्पित उद्देश्य की अनवरत सेवा कर रहा/रही हूँ।  
        यह जीवन मैंने संपूर्ण पृथ्वी, मानवता और प्रकृति के संरक्षण के लिए समर्पित कर रखा है। मेरी एकमात्र चिंता अब मेरी बेटी Saneha की पढ़ाई और जीवन-यापन है। 
        कृपया इस कार्य और सच्चे प्रयास का समर्थन कीजिए — आपका छोटा सा योगदान भविष्य बन सकता है।
      </p>
    </div>

    <div class="methods">
      <div class="method">
        <strong>PayPal</strong>
        <p>यदि आप PayPal से दान करना चाहें, तो नीचे दिए ईमेल पर संपर्क या भेजें।</p>
        <a class="btn paypal" href="mailto:sainirampaul60@gmail.com">PayPal / संपर्क (ईमेल)</a>
        <p style="margin-top:8px;font-size:13px;color:#444">ईमेल: <code>sainirampaul60@gmail.com</code></p>
        <p style="margin-top:6px;font-size:13px;color:#444">यदि आपके पास PayPal.Me लिंक है, तो उसे यहाँ बटन href में रख दें।</p>
      </div>

      <div class="method">
        <strong>Google Pay / UPI</strong>
        <p>QR स्कैन कर या UPI ID डालकर तुरंत भुगतान कर सकते हैं।</p>
        <p><strong>UPI ID:</strong> <code>sainirampaul90-1@okhdfcbank</code></p>
        <img class="upi-qr" src="assets/upi-qr.webp" alt="UPI QR (scan to pay)" onerror="this.style.display='none'"/>
        <p style="margin-top:8px;font-size:13px;color:#444">यदि QR नहीं दिख रहा, तो UPI ID अप्प में डाल कर भुगतान कर दें।</p>
      </div>

      <div class="method">
        <strong>सीधा संपर्क / अन्य</strong>
        <p>बड़ी दान राशि, समर्थन या अन्य पूछताछ के लिए कृपया ईमेल करें।</p>
        <p style="font-size:13px;">ईमेल: <code>sainirampaul60@gmail.com</code></p>
      </div>
    </div>

    <div class="note">
      <strong>अनुरोध और विश्वास:</strong> मेरा जीवन मानवता-प्रकृति के संरक्षण हेतु समर्पित है। मेरी बेटी की पढ़ाई और जीवन-यापन के लिए आपका समर्थन अत्यन्त मायने रखता है। मैं नम्रता से अनुरोध करता/करती हूँ कि जो भी समर्थन मिले, वह कृपा और संयोग समझकर स्वीकार किया जाए। 
    </div>

    <footer>
      <p>धन्यवाद — आपके समर्थन से इस काम को जारी रखने की ताकत मिलेगी।</p>
    </footer>
  </div>
</body>
</html>

