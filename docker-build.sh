#! /bin/sh
echo "[url \"https://${GITHUB_TOKEN}:x-oauth-basic@github.com/\"]"$'\n\t'"insteadOf = https://github.com/" >> /root/.gitconfig
hugo
cd public
git init
git remote set-url --add origin ${GITHUB_REPO}
git push --set-upstream origin master

