param($repoName)

git init
git add -A
git commit -m "init"
git remote add origin git@git-lan.boolood.tk:GE_admin/$repoName.git # git remote -v
git push -u origin master # git push --set-upstream origin master
