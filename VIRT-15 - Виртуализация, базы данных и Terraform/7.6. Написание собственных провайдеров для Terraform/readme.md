# Домашнее задание к занятию "7.6. Написание собственных провайдеров для Terraform."

---

Бывает, что 
* общедоступная документация по терраформ ресурсам не всегда достоверна,
* в документации не хватает каких-нибудь правил валидации или неточно описаны параметры,
* понадобиться использовать провайдер без официальной документации,
* может возникнуть необходимость написать свой провайдер для системы используемой в ваших проектах.   

## Задача 1. 
Давайте потренируемся читать исходный код AWS провайдера, который можно склонировать от сюда: 
[https://github.com/hashicorp/terraform-provider-aws.git](https://github.com/hashicorp/terraform-provider-aws.git).
Просто найдите нужные ресурсы в исходном коде и ответы на вопросы станут понятны.  


1. Найдите, где перечислены все доступные `resource` и `data_source`, приложите ссылку на эти строки в коде на 
гитхабе.   
1. Для создания очереди сообщений SQS используется ресурс `aws_sqs_queue` у которого есть параметр `name`. 
    * С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
    * Какая максимальная длина имени? 
    * Какому регулярному выражению должно подчиняться имя? 
    
### Ответ на задачу 1
	
1. все доступные `resource` и `data_source`
	* data_source - https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L871
	* resource - https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/provider/provider.go#L412

1. aws_sqs_queue
	* С каким другим параметром конфликтует `name`? Приложите строчку кода, в которой это указано.
	``` "ConflictsWith: []string{"name_prefix"}" ``` - https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L87
	
    * Какая максимальная длина имени? 
    
	80
	``` re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`) ``` - https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L427
	
	* Какому регулярному выражению должно подчиняться имя? 
    
	Если правильно понял, буквы большие-малые и цифры...
	
	```
	if fifoQueue {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,75}\.fifo$`)
		} else {
			re = regexp.MustCompile(`^[a-zA-Z0-9_-]{1,80}$`)
		}
	```
	https://github.com/hashicorp/terraform-provider-aws/blob/main/internal/service/sqs/queue.go#L424