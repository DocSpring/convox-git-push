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

if git ls-remote --exit-code convox > /dev/null 2>&1; then
  echo "convox remote already exists!"
  exit 1
fi

touch .git/info/exclude
grep -q .convox-build .git/info/exclude || echo ".convox-build" >> .git/info/exclude

git clone . ./.convox-build
git remote add convox ./.convox-build
(cd ./.convox-build && git config --local receive.denyCurrentBranch updateInstead)

if [ -d .convox ]; then
  ln -fs ../.convox ./.convox-build/.convox
fi

cat > ./.convox-build/.git/hooks/post-receive <<EOF
#!/bin/sh
read OLDSHA NEWSHA REF
# Do nothing if branch was deleted
if [ "\$NEWSHA" = "0000000000000000000000000000000000000000" ]; then exit; fi
cd ..
echo "Deploying $(git rev-parse HEAD) to convox..."
convox deploy
EOF
chmod +x .convox-build/.git/hooks/post-receive
