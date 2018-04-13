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

if git config remote.convox.url > /dev/null; then
  echo "convox remote already exists!"
  exit 1
fi

touch .git/info/exclude
grep -q .convox-build .git/info/exclude || echo ".convox-build" >> .git/info/exclude

git clone . ./.convox-build
(cd ./.convox-build && git config --local receive.denyCurrentBranch updateInstead)

echo "Adding convox git remote..."
git remote add convox ./.convox-build

if [ -d .convox ]; then
  echo "Symlinking .convox/ into build dir..."
  ln -fs ../.convox ./.convox-build/.convox
fi

echo "Setting up post-receive hook in build dir..."
cat > ./.convox-build/.git/hooks/post-receive <<EOF
#!/bin/sh
read OLDSHA NEWSHA REF
# Do nothing if branch was deleted
if [ "$NEWSHA" = "0000000000000000000000000000000000000000" ]; then exit; fi
REVISION=$(git rev-parse HEAD)
echo "Deploying $REVISION to convox..."
cd ..
convox deploy
EOF
chmod +x .convox-build/.git/hooks/post-receive
