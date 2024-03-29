# Домашнее задание к занятию "10.01. Зачем и что нужно мониторить"

## Обязательные задания

*1. Вас пригласили настроить мониторинг на проект. На онбординге вам рассказали, что проект представляет из себя платформу для вычислений с выдачей текстовых отчетов, которые сохраняются на диск. Взаимодействие с платформой осуществляется по протоколу http. Также вам отметили, что вычисления загружают ЦПУ. Какой минимальный набор метрик вы выведите в мониторинг и почему?*

Предложил бы к рассмотрению следующие метрики:
  * Место на диске - чтобы понимать сколько осталось, по графику можно пытаться прогнозировать
  * Нагрузка на диск, iowait - проседает ли скорость чтения-записи
  * Состояние дисков (smart) - не умирает ли диск физически
  * Состояние рейда (если такой в наличии) - не развалился ли
  * Общая нагрузка на CPU / Load Average - оценка нагрузки
  * Мониторинг http запросов - сколько запросов, с какими кодами отвечает, как по скорости
  * Мониторинг сетевой активности - хотя бы смотреть, на забит ли наш канал

*2. Менеджер продукта посмотрев на ваши метрики сказал, что ему непонятно что такое RAM/inodes/CPU/la. Также он сказал, что хочет понимать, насколько мы выполняем свои обязанности перед клиентами и какое качество обслуживания. Что вы можете ему предложить?*

SLA, SLO, SLI.. можно мне зачет и я пойду? :-)

Однако при общении с менеджером можно пойти двумя путями...
  1. обучить менеджера - в данном случае имеет смысл провести беседу о том, что такое RAM (оперативная память), inodes (загруженность файловой систыемы), CPU (нагрузка на процессор), LA (средняя нагрузка). Из метрик рисуем ему график, который он начинает понимать.
  
  2. удовлетворить менеджера - использовать не конкретные метрики из области администрирования, а оперировать уже какими-то понятными менеджеру "попугаями", которые естественно берутся и складываются из реальности. Вероятно, при утвержденных SLO/SLI менеджеру будут понятнее услышать про целевой уровень обслуживания и индикатор качества, т.е. цифры и проценты, а из чего они будут складываться менеджер не интересуется.


*3. Вашей DevOps команде в этом году не выделили финансирование на построение системы сбора логов. Разработчики в свою очередь хотят видеть все ошибки, которые выдают их приложения. Какое решение вы можете предпринять в этой ситуации, чтобы разработчики получали ошибки приложения?*

Денег нет, но вы держитесь - это наиболее свежая фраза. А раньше говорили - ну ты умный, придумай что-нибудь. Обычно имееет смысл идти двумя путями - искать бесплатные и условно-бесплатные ресурсы для размещения данных - ELK, если объемы позволяют, или же попытаться оптимизировать свои серверы, пытаясь скроить где-нибудь местечко и мощности. Но более идеальный вариант - выбивать дополнительное финансирование, потому что далеко всегда "административные задачи стоит решать техническими заплатками".


*4. Вы, как опытный SRE, сделали мониторинг, куда вывели отображения выполнения SLA=99% по http кодам ответов. 
Вычисляете этот параметр по следующей формуле: summ_2xx_requests/summ_all_requests. Данный параметр не поднимается выше 70%, но при этом в вашей системе нет кодов ответа 5xx и 4xx. Где у вас ошибка?*

Ошибка в том, что мы совсем забыли про коды ошибок 1хх и 3хх, при этом формула преображается в следующую:
(summ_1xx_requests + summ_2xx_requests + summ_3xx_requests)/(summ_all_requests)