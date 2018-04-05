#!/bin/bash
set -e

if [ ! -d .git ]; then
  echo "This is not a git repo!"
  exit 1
fi

if [ -d .convox-build ]; then
  echo ".convox-build directory already exists!"
  exit 1
fi

if if git ls-remote --exit-code convox > /dev/null 2>&1; then echo exists; fi; then
  echo "convox remote already exists!"
  exit 1
fi

touch .git/info/exclude
grep -q .convox-build .git/info/exclude || echo ".convox-build" >> .git/info/exclude

git clone --bare . ./.convox-build
git remote add convox ./.convox-build

cat > ./.convox-build/hooks/post-receive <<EOF
#!/bin/sh
echo "Deploying $(git rev-parse HEAD) to convox..."
convox deploy
EOF
chmod +x .convox-build/hooks/post-receive
