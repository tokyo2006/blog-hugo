#! /bin/sh
echo "[url \"https://${GITHUB_TOKEN}:x-oauth-basic@github.com/\"]"$'\n\t'"insteadOf = https://github.com/" >> /root/.gitconfig
hugo
chmod 777 -R .
cd public
git config --global user.email "rurounikexin@gmail.com"
git config --global user.name "Chen Zeng"
git init
git remote add origin 'https://github.com/tokyo2006/tokyo2006.github.io.git' 
git add .
git commit -m "add new blog"
git push --set-upstream origin master

