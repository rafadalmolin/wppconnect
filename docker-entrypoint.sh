#!/usr/bin/env bash
set -euo pipefail

has_script () {
  node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts['$1'] ? 0 : 1)"
}

if has_script start:prod; then
  echo ">> npm run start:prod"
  exec dumb-init npm run start:prod
elif has_script start; then
  echo ">> npm start"
  exec dumb-init npm start
elif [ -f dist/index.js ]; then
  echo ">> node dist/index.js"
  exec dumb-init node dist/index.js
elif [ -f src/index.ts ] && npx --yes tsx --version >/dev/null 2>&1; then
  echo ">> npx tsx src/index.ts"
  exec dumb-init npx tsx src/index.ts
elif [ -f index.js ]; then
  echo ">> node index.js"
  exec dumb-init node index.js
else
  echo "!! Não encontrei como iniciar a aplicação. Ajuste os scripts do package.json ou o arquivo de entrada."
  ls -la
  exit 1
fi
