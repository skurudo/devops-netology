# Домашнее задание к занятию «2.3. Ветвления в Git»

## Задание №1 – Ветвление, merge и rebase.
1. mkdir branching && cd branching && nano merge.sh && nano rebase.sh
2. git checkout main && git add branching/* && git commit -a -m "prepare for merge and rebase" && git push
3. но получили конфликт - error: failed to push some refs - сделали git pull и потом git push
* перед коммитами нужно проверять ветку, совсем забыл, что в прошлый раз был fix 
* причем не только текущую ветку, но и апстрим желательно 

### Подготовка файла merge.sh.
1. git checkout -b git-merge
2. nano branching/merge.sh
3. git commit -a -m "merge: @ instead *" && git push && git push --set-upstream origin git-merge
4. nano branching/merge.sh
5. git commit -a -m "merge: use shift" && git push

### Изменим main.
1. git checkout main
2. nano branching/rebase.sh
3. git commit -a -m "main rebase" && git push --set-upstream origin main

### Подготовка файла rebase.sh.
1. git log -S "prepare for merge and rebase" --> git show 13a7797 --> git checkout 13a7797f972ab5f723e1604da4732500ba98f272
2. git checkout -b git-rebase
3. nano branching/rebase.sh
4. git commit -a -m "git-rebase 1" && git push --set-upstream origin git-rebase
5. git commit -a -m "git-rebase 2" && git push

### Промежуточный итог.
2022-01-29_001.png

### Merge
1. git checkout main
2. git merge git-merge
3. git push
4. 2022-01-29_002.png

### Rebase
1. git checkout git-rebase
2. git rebase -i main
3. видим:
pick 63b9d20 git-rebase 1
pick 31fbf01 git-rebase 2
4. $ git rebase -i main
		Auto-merging branching/rebase.sh
		CONFLICT (content): Merge conflict in branching/rebase.sh
		error: could not apply 63b9d20... git-rebase 1
5. nano branching/rebase.sh
6. git add branching/rebase.sh
7. git rebase --continue
8. sku@Angurva:~/devops-netology$ git rebase --continue
		[detached HEAD 876f042]  git-rebase 2
		Date: Sat Jan 29 03:57:11 2022 +0300
		1 file changed, 2 insertions(+)
		Successfully rebased and updated refs/heads/git-rebase.
9. git push -->
		! [rejected]        git-rebase -> git-rebase (non-fast-forward)
		error: failed to push some refs to 'https://github.com/skurudo/devops-netology.git'
10. git push -u origin git-rebase -f
11. git checkout main
12. git merge git-rebase
13. 2022-01-29_003.png