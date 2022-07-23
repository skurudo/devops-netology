# Домашнее задание к занятию "7.3. Основы и принцип работы Терраформ"

---

## Задача 1. Создадим бэкэнд в S3 (необязательно, но крайне желательно).

>Если в рамках предыдущего задания у вас уже есть аккаунт AWS, то давайте продолжим знакомство со >взаимодействиемтерраформа и aws. 

>1. Создайте s3 бакет, iam роль и пользователя от которого будет работать терраформ. Можно создать отдельного >пользователя,а можно использовать созданного в рамках предыдущего задания, просто добавьте ему необходимы >права, как описано [здесь](https://www.terraform.io/docs/backends/types/s3.html).
>1. Зарегистрируйте бэкэнд в терраформ проекте как описано по ссылке выше. 

### Ответ на задачу 1

По причинам санкций пункт пришлось пропустить

## Задача 2. Инициализируем проект и создаем воркспейсы. 

>1. Выполните `terraform init`:
> * если был создан бэкэнд в S3, то терраформ создат файл стейтов в S3 и запись в таблице dynamodb.
> * иначе будет создан локальный файл со стейтами.  
>1. Создайте два воркспейса `stage` и `prod`.
>1. В уже созданный `aws_instance` добавьте зависимость типа инстанса от вокспейса, что бы в разных >ворскспейсах использовались разные `instance_type`.
>1. Добавим `count`. Для `stage` должен создаться один экземпляр `ec2`, а для `prod` два. 
>1. Создайте рядом еще один `aws_instance`, но теперь определите их количество при помощи `for_each`, >а не `count`.
>1. Что бы при изменении типа инстанса не возникло ситуации, когда не будет ни одного инстанса >добавьте параметр жизненного цикла `create_before_destroy = true` в один из рессурсов `aws_instance`.
>1. При желании поэкспериментируйте с другими параметрами и рессурсами.

>В виде результата работы пришлите:
>* Вывод команды `terraform workspace list`.
>* Вывод команды `terraform plan` для воркспейса `prod`.  

### Ответ на задачу 2

Ответы быстро:
* Вывод команды `terraform workspace list`
```
vagrant@dev-docker:~/07-terraform-03-basic$ terraform workspace list
  default
* prod
  stage
```

* Вывод команды `terraform plan` для воркспейса `prod` -> 
[ссылка](https://github.com/skurudo/devops-netology/blob/main/VIRT-15%20-%20%D0%92%D0%B8%D1%80%D1%82%D1%83%D0%B0%D0%BB%D0%B8%D0%B7%D0%B0%D1%86%D0%B8%D1%8F%2C%20%D0%B1%D0%B0%D0%B7%D1%8B%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20Terraform/7.3.%20%D0%9E%D1%81%D0%BD%D0%BE%D0%B2%D1%8B%20%D0%B8%20%D0%BF%D1%80%D0%B8%D0%BD%D1%86%D0%B8%D0%BF%20%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D1%8B%20%D0%A2%D0%B5%D1%80%D1%80%D0%B0%D1%84%D0%BE%D1%80%D0%BC/out.txt )

---

А по шагам сделаем инициализацию:

```
vagrant@dev-docker:~/07-terraform-03-basic$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.76.0...
- Installed yandex-cloud/yandex v0.76.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!
```

Проверим текущие workspace:

```
vagrant@dev-docker:~/07-terraform-03-basic$ terraform workspace list
* default
```

Создадим нужные по заданию workspace:

```
vagrant@dev-docker:~/07-terraform-03-basic$ terraform workspace new stage
Created and switched to workspace "stage"!

vagrant@dev-docker:~/07-terraform-03-basic$ terraform workspace new prod
Created and switched to workspace "prod"!

vagrant@dev-docker:~/07-terraform-03-basic$ terraform workspace list
  default
* prod
  stage
```

