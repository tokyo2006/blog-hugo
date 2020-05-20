#! /bin/sh
echo "[url \"https://${GITHUB_TOKEN}:x-oauth-basic@github.com/\"]"$'\n\t'"insteadOf = https://github.com/" >> /root/.gitconfig
hugo
sudo chmod 777 -R .
cd public
git init
git remote set-url --add origin https://github.com/tokyo2006/tokyo2006.github.io.git 
git push --set-upstream origin master

