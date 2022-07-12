# Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Terraform."

---

> ## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно)
>
> 1. Подробная инструкция на русском языке содержится [здесь]
> (<https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart>).
> 2. Обратите внимание на период бесплатного использования после регистрации аккаунта.
> 3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
> базового терраформ конфига.
> 4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы
> не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

### Ответ на задачу 1
1. done
2. done
3. подготовимся...
   * добавим блок с провайдером:

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

   * добавим блок провайдера:
```
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "<OAuth>"
  cloud_id  = "<идентификатор облака>"
  folder_id = "<идентификатор каталога>"
  zone      = "<зона доступности по умолчанию>"
}
```

4. подготовимся к перемернным окружения

```
$ export TF_VAR_yc_token
$ export TF_VAR_yc_cloud_id
```

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ
>
> 1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
> 2. Зарегистрируйте провайдер
>    1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
>    блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион
>    внутри блока `provider`.
>    2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти
>    [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
> 3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
> их в виде переменных окружения.
> 4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
> 5. В файле `main.tf` создайте рессурс
>    1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
>    Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке
>    `Example Usage`, но желательно, указать большее количество параметров.
>    2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
> 6. Также в случае использования aws:
>    1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
>    2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент:
>        * AWS account ID,
>        * AWS user ID,
>        * AWS регион, который используется в данный момент,
>        * Приватный IP ec2 инстансы,
>        * Идентификатор подсети в которой создан инстанс.  
> 7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок.
> В качестве результата задания предоставьте:
> 1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
> 1. Ссылку на репозиторий с исходной конфигурацией терраформа.  

### Ответ на задачу 2

> 1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?

[Packer](https://www.packer.io/)

> 2. Ссылку на репозиторий с исходной конфигурацией терраформа.  

**В первом варианте** секреты убраны в variables.tf, во втором появилось еще более интересное кмк решение

[Ссылка на репозиторий](https://github.com/skurudo/devops-netology/tree/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/7.2.%20%D0%9E%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D1%8B%D0%B5%20%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D1%8B%20%D0%B8%20%D1%81%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%81%20Terraform/src-01)

![Сделалося](https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/7.2.%20%D0%9E%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D1%8B%D0%B5%20%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D1%8B%20%D0%B8%20%D1%81%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%81%20Terraform/01.jpg)

```
vagrant@dev-docker:~/07-terraform-02-syntax$ terraform init

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of yandex-cloud/yandex from the dependency lock file
- Using previously-installed yandex-cloud/yandex v0.76.0

Terraform has been successfully initialized!
```

```
vagrant@dev-docker:~/07-terraform-02-syntax$ terraform plan
...
Changes to Outputs:
  + external_ip_address_node01_yandex_cloud = (known after apply)
  + internal_ip_address_node01_yandex_cloud = "192.168.101.11"

────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you
run "terraform apply" now.
```

```
yandex_vpc_network.my-network: Creating...
yandex_vpc_network.my-network: Creation complete after 1s [id=enp72seo79pp84rnamra]
yandex_vpc_subnet.my-subnet: Creating...
yandex_vpc_subnet.my-subnet: Creation complete after 1s [id=e9bih4pq1ealhg45od4i]
yandex_compute_instance.test: Creating...
yandex_compute_instance.test: Still creating... [10s elapsed]
yandex_compute_instance.test: Still creating... [20s elapsed]
yandex_compute_instance.test: Still creating... [30s elapsed]
yandex_compute_instance.test: Still creating... [40s elapsed]
yandex_compute_instance.test: Creation complete after 45s [id=fhm646e8t1gqbte8ceoo]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_test_vm = "51.250.67.157"
internal_ip_address_test_vm = "192.168.10.8"
```

**Второй вариант** позволяет не держать переменные в файле, но требует их ручного ввода.. это не слишком эстетично, но довольно забавно, ведь секреты мы вовсе не храним тогда

[Ссылка на репозиторий](https://github.com/skurudo/devops-netology/tree/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/7.2.%20%D0%9E%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D1%8B%D0%B5%20%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D1%8B%20%D0%B8%20%D1%81%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%81%20Terraform/src-02)
![Сделалося](https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/7.2.%20%D0%9E%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D1%8B%D0%B5%20%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D1%8B%20%D0%B8%20%D1%81%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%81%20Terraform/02.jpg)
![Сделалося](https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/7.2.%20%D0%9E%D0%B1%D0%BB%D0%B0%D1%87%D0%BD%D1%8B%D0%B5%20%D0%BF%D1%80%D0%BE%D0%B2%D0%B0%D0%B9%D0%B4%D0%B5%D1%80%D1%8B%20%D0%B8%20%D1%81%D0%B8%D0%BD%D1%82%D0%B0%D0%BA%D1%81%D0%B8%D1%81%20Terraform/03.jpg)