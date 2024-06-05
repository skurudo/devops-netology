# Дипломный практикум в Yandex.Cloud по курсу "DevOps-инженер" в Нетологии

- [Дипломный практикум в Yandex.Cloud по курсу "DevOps-инженер" в Нетологии](#дипломный-практикум-в-yandexcloud-по-курсу-devops-инженер-в-нетологии)
  - [Цели:](#цели)
  - [Этапы выполнения:](#этапы-выполнения)
    - [Планирование и проработка этапов выполнения](#планирование-и-проработка-этапов-выполнения)
    - [Подготовка - Gitlab](#подготовка---gitlab)
    - [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
    - [Создание Kubernetes кластера](#создание-kubernetes-кластера)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

[Оригинальный текст задания](readme.md)

---

## Этапы выполнения:

### Планирование и проработка этапов выполнения

По целям в изначальном задании, у нас должна появиться инфраструктура в Яндекс.Облаке, а внутри этой самой инфраструктуры несколько элементов:
* виртуальные сети
* в облаке должно быть яндекс.регистри для сборок
* в облаке должен быть бакет для терраформа 
* виртуальные машины с kubernetes-кластером или managed кластер
* внутри кластера у нас должен быть мониторинг
* внутри кластера у нас должно быть приложение
* домены и сертификаты для них

С самого начала помимо динамической и изменяемой структуры в виде облака и всякого другого, у нас должен появится некий статичный элемент в виде хранилища кода и центра для деплоя. Этим краеугольным камнем станет Gitlab-сервер. Держать мы его будет отдельно, чтобы избежать дополнительных расходов.

Общими мазками выглядит приблизительно так:
![общая схема](img/scheme.png)

Слева Gitlab - мощнейщий велосипед для почти всего. В нем мы будем держать данные по инфраструктуре и приложению. Будем стараться избежать монорепозитория. Отдельно будем хранить данные с манифестами терраформа по созданию сети, k8s кластера и отдельно по приложению, которое планируется деплоить в кластер.

Справа Яндекс.облако - динамически изменяемая среда в зависимости от того, что у нас будет, что у нас будет лежать в репозитории Gitlab. Таким образом мы по сути прикоснемся и используем методологию Gitops, исходя из которой у нас декларативно описана структура в виде кода и мы автоматически разворачивыем её.

### Подготовка - Gitlab

Подготовим виртуальную машину, а также домен для нашего проекта - lab.galkin.work. Используем операционную систему Ubuntu в конфигурации 4 vCPU / 8 Gb RAM. Это немного меньше, чем рекомендованные настройки, но с учетом того, что у нас она почти пустая, нам хватит.

В принципе не так важно, где именно мы разместим машину, главное - доступность и возможность дополнительных настроек. Gitlab мы выбрали за возможность использования CI/CD и раннеров прямо на борту. Также крайне и крайне желательно на старте иметь возможность дать Gitlab нормальные сертификаты, в противном случае можно довольно знатно пройтись по граблям. 

<details>
  <summary>Подготовка операционной системы: softs, docker, helm, terraform, yc</summary>

![сервер Gitlab](img/gitlab-srv.png)

  * **Сменим хостнейм**
  ```  hostnamectl set-hostname lab.galkin.work ```

  * **Немного украсим внешний вид**
  ``` cat /dev/null > .bash_profile; nano .bash_profile ```

  ``` 
  PS1="\[\033[1;36m\]\t \[\e[39m\][\[\e[31m\]\u\[\e[39m\]@\[\e[35m\]\h\[\e[39m\]:\[\e[1;34m\]\w\[\e[m\] \[\e[39m\]] \[\e[0;31m\]\$ \[\e[m\]\[\e[0;37m\]"
  export HISTTIMEFORMAT="%d/%m/%y %T "
 ```
  
  * **Обновим систему**
  ```  apt update && apt upgrade --yes --force-yes ```

  * **Установим софты**
   ``` apt install  mc curl wget htop vnstat monit ncdu nano git rsync host whois dnsutils sysstat iotop pwgen siege sshfs nmap p7zip-full screen nmap python3 python3-pip nmon expect pv etckeeper mtr auditd acct jq --yes  ```

  * **Установим docker**
   ``` sudo apt install apt-transport-https ca-certificates curl software-properties-common --yes && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - &&  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" &&  sudo apt-cache policy docker-ce &&  sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose --yes && sudo systemctl status docker &&  docker ps ```

  * **Установим helm**
  ```
  snap install helm --classic
  ```  

  * **Установим kubectl**
  ```
  snap install kubectl --classic
  ```  

  * **Установим terraform**
  ```
  wget https://hashicorp-releases.yandexcloud.net/terraform/1.8.3/terraform_1.8.3_linux_amd64.zip
  unzip terraform_*_linux_amd64.zip
  sudo mv terraform /usr/local/bin/
  ```

  * **Установим автоподстановки**
```
terraform -install-autocomplete
```

А также нам нужно добавить провайдер - Яндекс, скачать его с санкционного терраформа будет немного проблематично.
```
nano ~/.terraformrc
```
```
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

  * **Установим yc**
  ```
  curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash

  source "/root/.bashrc"  
  ```

  * **Сгенерируем ключи**
  ```
  ssh-keygen -t rsa
  ssh-keygen -t ed25519
  ```  
</details>



<details>
  <summary>На случай проблем с докером</summary>

  ```
   nano /etc/docker/daemon.json  
  ```

  ```
  {
  "registry-mirrors": [      
          "https://dockerhub.timeweb.cloud",
          "https://huecker.io"
  ]
  }
  ```

  При наличии домена и VPS в зазеркалье можно нехитрым образом сделать свой миррор, что более предпочтительно

  * [_env](src/docker-mirror/_env) - переименовать в .env и указать свой домен (А запись нужно указать заранее, иначе сертификат сразу можно не получить!)
  * [config.yml](src/docker-mirror/config.yml) - конфигурационный файл для registry
  * [docker-compose.yml](src/docker-mirror/docker-compose.yml) - запускаем как обычно
  * [traefik.yml](src/docker-mirror/traefik.yml) - доп. конфиг для Traefik
  
</details>

<details>
  <summary>Запускаем Gitlab</summary>

* **Подготовим docker-compose для Gitlab**

docker-compose.yml

```
version: '3.7'

services:
  web:
    image: 'gitlab/gitlab-ce:16.9.8-ce.0'
    restart: always
    hostname: 'lab.galkin.work'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://lab.galkin.work'
        gitlab_rails['gitlab_shell_ssh_port'] = 2224
    ports:
      - '80:80'
      - '443:443'
      - '2224:22'
    volumes:
      - './config:/etc/gitlab'
      - './logs:/var/log/gitlab'
      - './data:/var/opt/gitlab'
    shm_size: '256m'
  ```

```
docker-compose up -d
```

* **Зададим пароль пользователя**

```
docker exec -it gitlab /bin/bash
gitlab-rake "gitlab:password:reset"
```

Например такие:
```
root
ну-вы-поняли (по запросу)
```

* **После входа заведем сразу runner - тип shell**

```
# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64

# Give it permission to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Create a GitLab Runner user
sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash

# Install and run as a service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start
```
```
gitlab-runner register --url https://lab.galkin.work --token glrt-B9bR4BpxzWPyDy5f2HfR
```

![сервер Gitlab](img/gitlab-face.png)

![сервер Gitlab](img/gitlab-face2.png)

![сервер Gitlab](img/gitlab-runner.png)


Создадим в Gitlab несколько проектов. Как мы декларировали ранее, мы постараемся уйти от монорепозитория:
- **infra** - инфраструктура проекта
- **app** - для нашего приложения
- **monitor** - мониторинг

![сервер Gitlab](img/gitlab-face3.png)
</details>

### Создание облачной инфраструктуры

Создание облачной инфраструкты проходит на базе Яндекс.Облако с использованием terraform. Работы проводились с рабочей машины с сервером Gitlab. 

<details>
    <summary>yc - сервис-аккаунт и токен</summary>

  ```
  yc init

  получаем токен и проводим первоначальную настройку
  ```
  
  Создаем сервисный аккаунт и получаем токен 

  ```
  yc iam service-account create sa-key
  yc iam key create --service-account-name sa-key --output key.json

  yc iam create-token
  ```

  ```
root@lab:~/v03# yc iam service-account create sa-key
done (1s)
id: ajeatu7jd5l3o85qrb1u
folder_id: b1gsk3plrk6l86to7geb
created_at: "2024-06-03T13:02:01.891878178Z"
name: sa-key
  ```

  ```
  root@lab:~# yc iam key create --service-account-name sa-key --output key.json
  id: ajeqjbr8719fopi06o79
  service_account_id: aje74mb2ucv975of1ud3
  created_at: "2024-05-21T14:08:39.873190357Z"
  key_algorithm: RSA_2048
  ```

  ```
  root@lab:/opt/dev-one# yc iam create-token
  t1.9euelZqelMaPk5KQyJmbnpCeksuUj-3rnpWalI2Tzs7LiZGck5zOz5TIzM_l8_cPO01N-e8TdWxf_N3z909pSk357xN1bF_8zef1656VmpLHmYqWkZTJjpSdkZqTm5KM7_zF656VmpLHmYqWkZTJjpSdkZqTm5KM.[CENSORED]
  ```
</details>

<details>
  <summary>Уточняем ID облака и каталога для указания в манифесте</summary>

  ```
  root@lab:/opt/dev-one# yc resource-manager cloud list
  +----------------------+-------------+----------------------+
  |          ID          |    NAME     |   ORGANIZATION ID    |
  +----------------------+-------------+----------------------+
  | b1gjruksal1mu1cb4lmv | thesis      | bpf0m4gb7drjlcg56asf |
  +----------------------+-------------+----------------------+

  root@lab:/opt/dev-one# yc resource-manager folder list
  +----------------------+-------+--------+--------+
  |          ID          | NAME  | LABELS | STATUS |
  +----------------------+-------+--------+--------+
  | b1gsk3plrk6l86to7geb | cloud |        | ACTIVE |
  +----------------------+-------+--------+--------+
  ```

  Добавим переменные окружения
  ```
  export YC_TOKEN=$(yc iam create-token)
  export YC_CLOUD_ID=$(yc config get cloud-id)
  export YC_FOLDER_ID=$(yc config get folder-id)
  ```

  Добавим в переменные окружения идентификатор ключа и секретный ключ

  ```
  yc iam access-key create --service-account-name sa-key > key.json

  cat key.json | grep key_id | awk '{print $2}'
  cat key.json | grep secret | awk '{print $2}'

  export ACCESS_KEY="<идентификатор_ключа>"
  export SECRET_KEY="<секретный_ключ>"
  ```
</details>

<details>
  <summary>Создаем манифесты и делаем s3 backend</summary>

Данные c исходниками в каталоге с [исходниками](src/pro-one-infra-init/) или на [gitlab](https://lab.galkin.work/admin/projects/dev/infra) (пока он еще жив)

* [private.auto.tfvars](src/pro-one-infra-init/private.auto.tfvars) - переменные
* [provider.tf](src/pro-one-infra-init/provider.tf) - провайдер
* [s3-backet.tf_](src/pro-one-infra-init/s3-backet.tf_) - описание бекенда s3
* [s3.tf](src/pro-one-infra-init/s3.tf) - статические ключи для бакета
* [sa-storage-admin.tf](src/pro-one-infra-init/sa-storage-admin.tf) - название бакета
* [variables.tf](src/pro-one-infra-init/variables.tf) - описание переменных
* [s3_destroy.sh](src/pro-one-infra-init/s3_destroy.sh) - sh файл с terraform destroy
* [s3_install.sh](src/pro-one-infra-init/s3_install.sh) - sh файл с terraform init и apply
* [s3_install-state.sh](src/pro-one-infra-init/s3_install-state.sh) - добавление бекенда для хранения terraform state


**История в картинках:**
  * Сначала было ничего
  ![](img/yandex-cloud-s3-01.png)

  ![](img/terraform-01.png)

  * Запустили создание и появился бакет
  ![](img/terraform-02.png)
  
  ![](img/terraform-03.png)

  ![](img/yandex-cloud-s3-02.png)

  * Проверили, что бакет удаляется и появляется
  ![](img/terraform-04.png) 
  
  ![](img/yandex-cloud-s3-03.png)

  ![](img/terraform-05.png) 

  ![](img/terraform-06.png) 

  ![](img/yandex-cloud-s3-04.png)

  * Добавили бекенд для хранилища и появилось состояние
  ![](img/terraform-07.png) 

  ![](img/yandex-cloud-s3-05.png)


Иными словами стейт мы благополучно храним в s3. Но фикус в том, что этот самый s3 нам сначала нужно создать, а потом положить туда стейт, указать бэкенд и смигрировать. Т.е. на мой взгляд было бы логичнее хранить стейт не там же, где мы проводим массовые манипуляции, а переложить его в более "статичное" и не подверженное изменениям место, например Gitlab. 

А также замечу, что, к счастью, мы не можем грохнуть s3 со стейтом, т.к. облако Яндекс (не знаю, как там с AWS или другими, не удалось попробовать) не дает удалить бакет, в котором что-то есть. Инами словами потери стейта не происходит (что хорошо), но и полной автоматизации процесса нет (что допустимо, по всей видимости).

*Хотя было довольно забавно ради спортивного интереса удалить remote state из бакета и посмотреть на поведение terraform (никогда так не делайте, особенно в проде и особенно при работе в команде) :)*

</details>

<details>
  <summary>Создание VPC с подсетями в разных зонах доступности</summary>

Забегая вперед замечу, что создать прям во всех зонах доступности не вышло из-за квотирования. На аккаунте мне доступны только A и B зоны. Зона С скоро будет закрыта - https://cloud.yandex.ru/blog/posts/2023/08/new-availability-zone - потому пришлось создать три штуки, но в двух зонах.

Вместо этого можно использовать зону D, т.е. у нас получаются машины в зонах A, B и D. Единственный нюанс, мы не сможем использовать виртуальные машины с  Intel Broadwell, но выбирать Intel Cascade Lake (standard-v2 / Intel® Xeon® Gold 6230) или Intel Ice Lake (standard-v3 / Intel® Xeon® Gold 6338).

![](img/terraform-08.png)

![](img/yandex-cloud-zone.png)


Данные c исходниками в каталоге с [исходниками](src/pro-one-infra-init-test-vps/), [исходниками-2-с-зоной-D](src/pro-one-infra-init-test-vps2/) или на [gitlab](https://lab.galkin.work/admin/projects/dev/infra) (пока он еще жив)

*Вариант 1*
* [private.auto.tfvars](src/pro-one-infra-init-test-vps/private.auto.tfvars) - переменные
* [provider.tf](src/pro-one-infra-init-test-vps/provider.tf) - провайдер
* [s3-backet.tf_](src/pro-one-infra-init-test-vps/s3-backet.tf) - описание бекенда s3
* [s3.tf](src/pro-one-infra-init-test-vps/s3.tf) - статические ключи для бакета
* [sa-storage-admin.tf](src/pro-one-infra-init-test-vps/sa-storage-admin.tf) - название бакета
* [variables.tf](src/pro-one-infra-init-test-vps/variables.tf) - описание переменных
* [vpc-s3_destroy.shh](src/pro-one-infra-init-test-vps/vpc-s3_destroy.sh) - sh файл с terraform destroy
* [vpc-s3_install.sh](src/pro-one-infra-init-test-vps/vpc-s3_install.sh) - sh файл с terraform init и apply
* [s3_install-state.sh](src/pro-one-infra-init-test-vps/s3_install-state.sh) - добавление бекенда для хранения terraform state

Кроме того добавляем некоторые дополнительные файлы:
* [networks.tf](src/pro-one-infra-init-test-vps/networks.tf) - список сетей 
* [output.tf](src/pro-one-infra-init-test-vps/output.tf) - вывод полученного
* [secret.txt](src/pro-one-infra-init-test-vps/secret.txt) - мета-данные для передачи в виртуальные машины
* [vpc.tf](src/pro-one-infra-init-test-vps/vpc.tf) - манифест для создания виртуальных машин

А также переименовали sh скрипты в vpc-s3_destroy.sh и vpc-s3_install.sh, но по сути там ничего не поменялось.

*Вариант 2*

* [private.auto.tfvars](src/pro-one-infra-init-test-vps2/private.auto.tfvars) - переменные
* [provider.tf](src/pro-one-infra-init-test-vps2/provider.tf) - провайдер
* [s3-backet.tf_](src/pro-one-infra-init-test-vps2/s3-backet.tf) - описание бекенда s3
* [s3.tf](src/pro-one-infra-init-test-vps2/s3.tf) - статические ключи для бакета
* [sa-storage-admin.tf](src/pro-one-infra-init-test-vps2/sa-storage-admin.tf) - название бакета
* [variables.tf](src/pro-one-infra-init-test-vps2/variables.tf) - описание переменных
* [vpc-s3_destroy.shh](src/pro-one-infra-init-test-vps2/vpc-s3_destroy.sh) - sh файл с terraform destroy
* [vpc-s3_install.sh](src/pro-one-infra-init-test-vps2/vpc-s3_install.sh) - sh файл с terraform init и apply
* [s3_install-state.sh](src/pro-one-infra-init-test-vps2/s3_install-state.sh) - добавление бекенда для хранения terraform state

Кроме того добавляем некоторые дополнительные файлы:
* [networks.tf](src/pro-one-infra-init-test-vps2/networks.tf) - список сетей - сеть в зоне ru-central1-d
* [output.tf](src/pro-one-infra-init-test-vps2/output.tf) - вывод полученного
* [secret.txt](src/pro-one-infra-init-test-vps2/secret.txt) - мета-данные для передачи в виртуальные машины
* [vpc.tf](src/pro-one-infra-init-test-vps2/vpc.tf) - манифест для создания виртуальных машин - изменение в выборе платформы на одной из машин


**История в картинках:**

  * В начале снова ничего, кроме s3 и стейта
  ![](img/yandex-cloud-vpc-01.png)

  * Запустили создание - вариант 1
  ![](img/yandex-cloud-vpc-02.png)

  * Запустили создание - вариант 2
  ![](img/yandex-cloud-vpc-07.png)

  * Создалось - вариант 1:
  ![](img/yandex-cloud-vpc-03.png)

  ![](img/yandex-cloud-vpc-04.png)

  * Создалось - вариант 2:
  ![](img/yandex-cloud-vpc-08.png)

  ![](img/yandex-cloud-vpc-09.png)

  * Видео создания (вариант 1):
  [https://youtu.be/8m-nbBQoqDI](https://youtu.be/8m-nbBQoqDI)

  * Видео удаления:
  [https://youtu.be/iJznXWd4vlY](https://youtu.be/iJznXWd4vlY)

  * Удаление:
  ![](img/yandex-cloud-vpc-05.png)
  
  * И ничего кроме s3 со стейтом не осталось
  ![](img/yandex-cloud-vpc-06.png)

  Виртуальные машины многократно создавались и пересоздавались для проверки работы манифестов и отсутствия при этом критичных ошибок.

  Материалы по теме:
  * [Метаданные виртуальной машины](https://yandex.cloud/ru/docs/compute/concepts/vm-metadata)
  * [Как создать виртуальную машину с доступом по паролю](https://yandex.cloud/ru/docs/troubleshooting/compute/how-to/create-password-protected-vm)
  * [Включить доступ по OS Login](https://yandex.cloud/ru/docs/organization/operations/os-login-access)
  * [Добавить SSH-ключ](https://yandex.cloud/ru/docs/organization/operations/add-ssh#tf_1)
  * [Платформы](https://yandex.cloud/ru/docs/compute/concepts/vm-platforms#standard-platforms)
  * [TF Yandex - yandex_compute_instance](https://terraform-provider.yandexcloud.net/Resources/compute_instance)
</details>


<details>
  <summary>Summary</summary>

В скромной части работы, конечно, не совсем полная автоматизация, хотя по заданию было свести все к минимуму, но пока моих знаний и умений недостаточно. В идеальной картинке мира было бы здорово когда-нибудь добиться более автоматизированной истории, скорее всего, при помощи модулей от Яндекса:

  * Автоматическое создание дополнительных служебных учеток средствами terraform. На мой взгляд использование одной для всего, безусловно, удобнее, но идеально, когда для каждого "ресурса" у нас свои креды и они строго ограничены в рамках своих прав. С точки зрения отладки это то еще приключение, но с точки зрения безопасности - более надежное решение.
  * Для хранения секретов также идеально было бы использовать Vault от HashiCorp в связке с Terraform, а если секреты лежат в файлах, то аккуратнее подходить к gitignore (здесь эта рекомендация сознательно не соблюдалась, чтобы было понятно, что происходит)
  * Не хватает автоматизации миграции state terraform при хранении его в облачной инфраструктуре. По заданию мы храним его в s3, но это хранилище создает и потенциально пытается убить тот же terraform. Да, у него не получается, но это как-то не очень здорово выглядит. Т.е. тут более идеальной наверное историей было бы мигрирование state в локальный при убийстве всех ресурсов (в том числе очистка бакета) и переходе обратно. Но скорее всего все это оверкил, и state было бы логичнее хранить в Gitlab.
</details>

<details>
  <summary>Материалы по теме</summary>

  * [Документация по созданию бакета](https://yandex.cloud/ru/docs/storage/operations/buckets/create)
  * [Документация по созданию приватного бакета от Hashicorp](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/storage_bucket)
  * [Документация по s3 от HashiCorp](https://www.terraform.io/docs/language/settings/backends/s3.html)
  * [Деплоим Yandex Cloud с помощью Terraform и GitLab](https://www.youtube.com/watch?v=U58zSIvgyDI)
  * [Загрузка состояний Terraform в Yandex Object Storage](https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-state-storage)
  * [Terraform: от незнания к best practices](https://habr.com/ru/companies/nixys/articles/721404/)
</details>


### Создание Kubernetes кластера

Создание кластера Kubernetes проходит на базе Яндекс.Облако с использованием terraform. Работы проводились с рабочей машины с сервером Gitlab. 

<details>
  <summary>Манифесты и конфигурация</summary>

  ```
  long console output here
  ```
</details>

<details>
  <summary>Проверка создания</summary>

  ```
  long console output here
  ```
</details>

<details>
  <summary>Summary</summary>

  ```
  long console output here
  ```
</details>

<details>
  <summary>Материалы по теме</summary>

  * [HashiCorp - yandex_kubernetes_cluster](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster)
  * [HashiCorp - yandex_kubernetes_node_group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  * [TF Yandex - yandex_kubernetes_cluster](https://terraform-provider.yandexcloud.net/Resources/kubernetes_cluster)
  * [TF Yandex - yandex_kubernetes_node_group](https://terraform-provider.yandexcloud.net/Resources/kubernetes_node_group)
</details>