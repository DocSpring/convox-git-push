# "git push" deploys for convox

### Setup (Script)

```bash
cd <your project directory>
curl -s https://raw.githubusercontent.com/FormAPI/convox-git-push/master/setup.sh | bash
```

### Setup (Manual)

```bash
cd <your project directory>

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
```

### Usage

```bash
git push convox
```

### Why?

* Ensure you don't include any files by accident (e.g. you forgot to add something to `.dockerignore`)
* No need to `git stash` or `git checkout` before deploying new code.
* Easily push a different branch to convox, e.g. `git push convox mybranch:master`
* Makes convox feel like Heroku
* `git push` deploys are cool
