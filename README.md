# "git push" deploys for convox

### Setup

```bash
cd <your project directory>

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
```

### Usage

```bash
git push convox
```
