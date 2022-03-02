#Домашнее задание к занятию «2.4. Инструменты Git»

## 0. склонируем репозиторий с исходным кодом терраформа
$ git clone https://github.com/hashicorp/terraform && cd terraformcd 

## 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.
aefead2207ef7e2aa5dc81a34aedf0cad4c32545 Update CHANGELOG.md

### решение
git log --pretty=oneline | grep aefea
или аналогичная команда с возможностью форматировать разное
git log --pretty=format:"%H %s" | grep aefea -- например красивое с датами: git log --pretty=format:"%H - %ad - %s" | grep aefea

в целом получили вот такой вывод:
	aefead2207ef7e2aa5dc81a34aedf0cad4c32545 Update CHANGELOG.md
	8619f566bbd60bbae22baefea9a702e7778f8254 validate providers passed to a module exist
	3593ea8b0aefea1b4b5e14010b4453917800723f build: Remove format check from plugin-dev
	0196a0c2aefea6b85f495b0bbe32a855021f0a24 Changed Required: false to Optional: true in the SNS topic schema

но проще испрользовать git show aefea:

$ git show aefea --oneline
aefead220 Update CHANGELOG.md
diff --git a/CHANGELOG.md b/CHANGELOG.md
index 86d70e3e0..588d807b1 100644
--- a/CHANGELOG.md
+++ b/CHANGELOG.md
@@ -27,6 +27,7 @@ BUG FIXES:
 * backend/s3: Prefer AWS shared configuration over EC2 metadata credentials by default ([#25134](https://github.com/hashicorp/terraform/issues/25134))
 * backend/s3: Prefer ECS credentials over EC2 metadata credentials by default ([#25134](https://github.com/hashicorp/terraform/issues/25134))
 * backend/s3: Remove hardcoded AWS Provider messaging ([#25134](https://github.com/hashicorp/terraform/issues/25134))
+* command: Fix bug with global `-v`/`-version`/`--version` flags introduced in 0.13.0beta2 [GH-25277]
 * command/0.13upgrade: Fix `0.13upgrade` usage help text to include options ([#25127](https://github.com/hashicorp/terraform/issues/25127))
 * command/0.13upgrade: Do not add source for builtin provider ([#25215](https://github.com/hashicorp/terraform/issues/25215))
 * command/apply: Fix bug which caused Terraform to silently exit on Windows when using absolute plan path ([#25233](https://github.com/hashicorp/terraform/issues/25233))	

хотя если подумать, то еще лучше использовать git log:
$ git log aefea --pretty=format:"%H %s" -n 1
aefead2207ef7e2aa5dc81a34aedf0cad4c32545 Update CHANGELOG.md

$ git show aefea --pretty=oneline --no-patch
aefead2207ef7e2aa5dc81a34aedf0cad4c32545 Update CHANGELOG.md

## 2. Какому тегу соответствует коммит 85024d3?
v0.12.23
 
### решение
$ git show 85024d3
commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)

## 3. Сколько родителей у коммита b8d720? Напишите их хеши.
2 родителя - 56cd7859e05c36c06b56d013b55a252d0bb7e158 и 9ea88f22fc6269854151c571162c5bcf958bee2b

### решение
$ git log --pretty=%P -n 1 b8d720
56cd7859e05c36c06b56d013b55a252d0bb7e158 9ea88f22fc6269854151c571162c5bcf958bee2b
или
$ git show -s --pretty=%P b8d720
или
$ git rev-list --parents -n 1 b8d720

## 4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.
33ff1c03bb960b332be3af2e333462dde88b279e v0.12.24
b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release

### решение
$ git log v0.12.23...v0.12.24 --oneline
33ff1c03b (tag: v0.12.24) v0.12.24
b14b74c49 [Website] vmc provider links
3f235065b Update CHANGELOG.md
6ae64e247 registry: Fix panic when server is unreachable
5c619ca1b website: Remove links to the getting started guide's old location
06275647e Update CHANGELOG.md
d5f9411f5 command: Fix bug when using terraform login on Windows
4b6d06cc5 Update CHANGELOG.md
dd01a3507 Update CHANGELOG.md
225466bc3 Cleanup after v0.12.23 release

или

$ git log v0.12.23...v0.12.24 --pretty=format:"%H %s"
33ff1c03bb960b332be3af2e333462dde88b279e v0.12.24
b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release

## 5. Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы).
8c928e835

### решение
$ git log -S "func providerSource" --oneline
5af1e6234 main: Honor explicit provider_installation CLI config when present
8c928e835 main: Consult local directories as potential mirrors of providers
или c датами
$ git log -S "func providerSource" --pretty=format:"%h - %cD - %s"

а далее:
$ git show 8c928e835 | grep "func providerSource"
+func providerSource(services *disco.Disco) getproviders.Source {
и проверяем, что в другом коммите только измения:
$ git show 5af1e6234 | grep "func providerSource"

## 6. Найдите все коммиты в которых была изменена функция globalPluginDirs.
коммиты, где менялась функция:
35a058fb3ddfae9cfee0b3893822c9a95b920f4c
8364383c359a6b738a436d1b7745ccdce178df47

все коммиты, где упоминается функция:
35a058fb3ddfae9cfee0b3893822c9a95b920f4c
c0b17610965450a89598da491ce9b6b5cbd6393f
8364383c359a6b738a436d1b7745ccdce178df47 

### решение 1
git log -S "globalPluginDirs" --oneline
или 
git log -S "globalPluginDirs" --pretty=format:"%h - %cD - %s"

$ git show 35a058fb3ddfae9cfee0b3893822c9a95b920f4c | grep "globalPluginDirs"
+               available := pluginDiscovery.FindPlugins("credentials", globalPluginDirs())
$ git show c0b17610965450a89598da491ce9b6b5cbd6393f | grep "globalPluginDirs"
+               // FIXME: homeDir gets called from globalPluginDirs during init, before
$ git show 8364383c359a6b738a436d1b7745ccdce178df47 | grep "globalPluginDirs"
+               GlobalPluginDirs: globalPluginDirs(),
+// globalPluginDirs returns directories that should be searched for
+func globalPluginDirs() []string {

### решение 2 
$ git grep -n "globalPluginDirs"
commands.go:88:         GlobalPluginDirs: globalPluginDirs(),
commands.go:430:        helperPlugins := pluginDiscovery.FindPlugins("credentials", globalPluginDirs())
internal/command/cliconfig/config_unix.go:34:           // FIXME: homeDir gets called from globalPluginDirs during init, before
plugins.go:12:// globalPluginDirs returns directories that should be searched for
plugins.go:18:func globalPluginDirs() []string {

$ git log -L :globalPluginDirs:plugins.go
$ git log -L :globalPluginDirs:commands.go

## 7. Кто автор функции synchronizedWriters?
Martin Atkins

### решение
* смотрим коммиты с функцией synchronizedWriters
$ git log -S "synchronizedWriters" --oneline
bdfea50cc remove unused
fd4f7eb0b remove prefixed io
5ac311e2a main: synchronize writes to VT100-faker on Windows

* здесь функцию удалили
$ git show fd4f7eb0b | grep synchronizedWriters
-               wrapped := synchronizedWriters(stdout, stderr)

* здесь функцию удалили
$ git show bdfea50cc | grep synchronizedWriters
-// synchronizedWriters takes a set of writers and returns wrappers that ensure
-func synchronizedWriters(targets ...io.Writer) []io.Writer {

* здесь функцию добавили
$ git show 5ac311e2a | grep synchronizedWriters
+               wrapped := synchronizedWriters(stdout, stderr)
+// synchronizedWriters takes a set of writers and returns wrappers that ensure
+func synchronizedWriters(targets ...io.Writer) []io.Writer {

* смотрим кто и когда сделал
$ git show 5ac311e2a --pretty
или
$ git show 5ac311e2a --pretty | grep Author:
