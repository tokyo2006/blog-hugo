#! /bin/sh
echo "[url \"https://${GITHUB_TOKEN}:x-oauth-basic@github.com/\"]"$'\n\t'"insteadOf = https://github.com/" >> /root/.gitconfig
hugo
chmod 777 -R .
cd public
git init
git remote add origin 'https://github.com/tokyo2006/tokyo2006.github.io.git' 
git push --set-upstream origin master

