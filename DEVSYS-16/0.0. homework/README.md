# devops-netology
DEVSYS-16 - Pavel Galkin

# pycharm test edit!

# test edit

#Домашнее задание к занятию «2.1. Системы контроля версий.»

##Задание №1 – Создать и настроить репозиторий для дальнейшей работы на курсе.

### репозиторий и первый коммит
1. https://github.com/skurudo
2. неточности на слайде при создании: 
	* если в явном виде указывать add .gitignore none - репозиторий создан не будет
	* если в явном виде указывать add license none - репозиторий создан не будет
	* в связи со странностями западного мира у нас теперь не master, а main =_=
3. git clone https://github.com/skurudo/devops-netology.git
4. cd devops-netology
5. git config --global user.email "pavel@galkin.su"
   git config --global user.name "pavel.galkin"
6. git status
	sku@Angurva:~/devops-netology$ git status
	On branch main
	Your branch is up to date with 'origin/main'.
	nothing to commit, working tree clean

7. nano README.md
8. modified:   README.md
9. git diff (опция staged не выдает ничего)
		sku@Angurva:~/devops-netology$ git diff
		diff --git a/README.md b/README.md
		index 8494582..2547a98 100644
		--- a/README.md
		+++ b/README.md
		@@ -1,2 +1,4 @@
		# devops-netology
		DEVSYS-16 - Pavel Galkin
		+
		+test record one

10. git add README.md
11. git diff --staged (без опции не выдает ничего)
		sku@Angurva:~/devops-netology$ git diff --staged
		diff --git a/README.md b/README.md
		index 8494582..2547a98 100644
		--- a/README.md
		+++ b/README.md
		@@ -1,2 +1,4 @@
		# devops-netology
		DEVSYS-16 - Pavel Galkin
		+
		+test record one

12. git commit -m 'First commit'
	[main 9605083] First commit
	1 file changed, 2 insertions(+)

13. git status выдает данные - Your branch is ahead of 'origin/main' by 1 commit
	git diff --staged - не выдаст данных
	git diff - не выдаст данных
	
### файлы .gitignore и второй комми
1. >.gitignore и ls не покажет, ls -a (или la) покажет
2. git add .gitignore
3. mkdir terraform
   cd terraform/
   >.gitignore
   nano .gitignore
4. nano README.md - описание
5. git add . && git commit -m 'Second commit'

### Экспериментируем с удалением и перемещением файлов (третий и четвертый коммит)
1. echo "will_be_deleted" > will_be_deleted.txt && echo "will_be_moved" > will_be_moved.txt && git add . && git commit -m 'Prepare to delete and move'
2. docs, check
3. rm will_be_deleted.txt && git rm will_be_deleted.txt
4. mv will_be_moved.txt has_been_moved.txt --> deleted: will_be_deleted.txt изменился на Untracked files - has_been_moved.txt
5. git add . && git commit -m 'Moved and deleted'

### Проверка изменений.
1. git log - не был правильный комментарий "Added gitignore" (неверно понял задание :( ), вместо него Second commit дважды
2. steps checked, done

### Отправка изменений в репозиторий
* важно учесть, что пароля больше нет - When Git prompts you for your password, enter your personal access token (PAT) instead. Password-based authentication for Git has been removed, and using a PAT is more secure. (https://docs.github.com/en/get-started/getting-started-with-git/why-is-git-always-asking-for-my-password)

1. получили персональный токен
2. git push

## Задание №2 – Знакомство с документаций
+++ done

# Ссылка на репозиторий
https://github.com/skurudo/devops-netology 

# Вопросы-дополнения:
1. стоит сразу или в лекции рассказать про токеты и ключи при доступе к гитхабу
2. имеет смысл написать про github cli
3. наверное стоило упомянуть сразу про git commit -a -m 'Another commit'







# Расположение файлов
https://drive.google.com/drive/folders/1_9p0-OgUinI2JP8WQY9BDNpEFnrFuXxp?usp=sharing
