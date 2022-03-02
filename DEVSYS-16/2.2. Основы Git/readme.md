# 2.2. Основы Git

## Задание №1 – Знакомимся с gitlab и bitbucket
### Gitlab
1. регистрация на гитлаб
2. https://gitlab.com/skurudo/devops-netology
3. check
4. в задании ссылка указана не совсем верно, видимо перенесли - https://gitlab.com/-/profile/password/edit - проще наверное сказать иконка с аватаром -> Preferences -> Password... и добавили ssh ключ на всякий пожарный
5. check
6. $ git remote -v
		origin  https://github.com/skurudo/devops-netology.git (fetch)
		origin  https://github.com/skurudo/devops-netology.git (push)
7. git remote add gitlab  https://gitlab.com/skurudo/devops-netology
8. $ git push -u gitlab main
		Username for 'https://gitlab.com': skurudo
		Password for 'https://skurudo@gitlab.com':
		warning: redirecting to https://gitlab.com/skurudo/devops-netology.git/
		Counting objects: 40, done.
		Delta compression using up to 20 threads.
		Compressing objects: 100% (34/34), done.
		Writing objects: 100% (40/40), 6.48 KiB | 948.00 KiB/s, done.
		Total 40 (delta 13), reused 0 (delta 0)
		To https://gitlab.com/skurudo/devops-netology
 		* [new branch]      main -> main
		Branch 'main' set up to track remote branch 'main' from 'gitlab'.
9. $ git remote -v
		gitlab  https://gitlab.com/skurudo/devops-netology (fetch)
		gitlab  https://gitlab.com/skurudo/devops-netology (push)
		origin  https://github.com/skurudo/devops-netology.git (fetch)
		origin  https://github.com/skurudo/devops-netology.git (push)

### bitbucket
1. check - https://bitbucket.org/skurudo/devops-netology.git
2. check
3. check
4. git remote add bitbucket https://skurudo@bitbucket.org/skurudo/devops-netology.git
5. $ git remote -v
		bitbucket       https://skurudo@bitbucket.org/skurudo/devops-netology.git (fetch)
		bitbucket       https://skurudo@bitbucket.org/skurudo/devops-netology.git (push)
		gitlab  https://gitlab.com/skurudo/devops-netology (fetch)
		gitlab  https://gitlab.com/skurudo/devops-netology (push)
		origin  https://github.com/skurudo/devops-netology.git (fetch)
		origin  https://github.com/skurudo/devops-netology.git (push)  
6. $ git push -u bitbucket main
		Password for 'https://skurudo@bitbucket.org':
		Counting objects: 40, done.
		Delta compression using up to 20 threads.
		Compressing objects: 100% (34/34), done.
		Writing objects: 100% (40/40), 6.48 KiB | 1.08 MiB/s, done.
		Total 40 (delta 13), reused 0 (delta 0)
		To https://bitbucket.org/skurudo/devops-netology.git
 		* [new branch]      main -> main
		Branch 'main' set up to track remote branch 'main' from 'bitbucket'.
7. NB: чтобы сделать push в bitbucket нужно сделать пароль для app -> https://bitbucket.org/account/settings/app-passwords/
8. git remote add bitbuckets git@bitbucket.org:skurudo/devops-netology.git
9. git remote add gitlabs git@gitlab.com:skurudo/devops-netology.git
10. git remote add githubs git@github.com:skurudo/devops-netology.git
11. $ git remote -v
		bitbucket       https://skurudo@bitbucket.org/skurudo/devops-netology.git (fetch)
		bitbucket       https://skurudo@bitbucket.org/skurudo/devops-netology.git (push)
		bitbuckets      git@bitbucket.org:skurudo/devops-netology.git (fetch)
		bitbuckets      git@bitbucket.org:skurudo/devops-netology.git (push)
		githubs git@github.com:skurudo/devops-netology.git (fetch)
		githubs git@github.com:skurudo/devops-netology.git (push)
		gitlab  https://gitlab.com/skurudo/devops-netology (fetch)
		gitlab  https://gitlab.com/skurudo/devops-netology (push)
		gitlabs git@gitlab.com:skurudo/devops-netology.git (fetch)
		gitlabs git@gitlab.com:skurudo/devops-netology.git (push)
		origin  https://github.com/skurudo/devops-netology.git (fetch)
		origin  https://github.com/skurudo/devops-netology.git (push)
12. push работает во все репы

## Задание №2 – Теги
1. легковесный тэг
	$ git log --oneline
	5ae1cf5 (HEAD -> main, origin/main, origin/HEAD, gitlabs/main, gitlab/main, githubs/main, bitbucket/main) 
	...
    $ git tag v0.0 5ae1cf5
	$ git log --oneline
	5ae1cf5 (HEAD -> main, tag: v0.0, origin/main, origin/HEAD, gitlabs/main, gitlab/main, githubs/main, bitbucket/main)
2. аннотированынй тэг
	$ git tag -a v0.1 5ae1cf5
	$ git log --oneline
	5ae1cf5 (HEAD -> main, tag: v0.1, tag: v0.0, origin/main, origin/HEAD, gitlabs/main, gitlab/main, githubs/main, bitbucket/main)	
3. отправка тэгов в репы
	$ git push bitbuckets --tags
	$ git push gitlabs --tags
	$ git push githubs --tags
4. https://gitlab.com/skurudo/devops-netology/-/tags и https://github.com/skurudo/devops-netology/tags
	
## Задание №3 – Ветки
0.1 git checkout remotes/origin/HEAD - детачит head
0.2 git checkout main - вертаемся обратно, если не удалили ветку (:
0.3 ситуация с HEAD просто обязана быть рассмотрена... потому что это ШОК :)

1. git branch --set-upstream-to origin/main main 
2. git log -S "Prepare to delete and move"
3. git checkout 5ce65c0f7bcc7aa5e0bada0a84c314aa587b96c5
4. git checkout -b fix
5. git push -u origin fix
6. https://github.com/skurudo/devops-netology/network
7. nano README.md
8. git commit -a -m "2.2 change line" && git push -u origin
		$ git log --oneline
		b5c2f85 (HEAD -> fix, origin/fix) 2.1 change line
		5ce65c0 homework
		be4e069 Moved and deleted
		a595403 Prepare to delete and move
		5f85b27 Second commit
		b1f02da Second commit
		9605083 First commit
		78711e8 Initial commit

## Задание №4 – Упрощаем себе жизнь
1. check
2. check
3. check
4. check

## Ответы на задания
* https://github.com/skurudo/devops-netology
* https://github.com/skurudo/devops-netology/tree/fix
* https://gitlab.com/skurudo/devops-netology
* https://bitbucket.org/skurudo/devops-netology/src/main/