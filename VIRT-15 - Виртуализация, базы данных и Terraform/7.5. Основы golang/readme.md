# Домашнее задание к занятию "7.5. Основы golang"

---

С `golang` в рамках курса, мы будем работать не много, поэтому можно использовать любой IDE. 
Но рекомендуем ознакомиться с [GoLand](https://www.jetbrains.com/ru-ru/go/).  

## Задача 1. Установите golang.
1. Воспользуйтесь инструкций с официального сайта: [https://golang.org/](https://golang.org/).
2. Так же для тестирования кода можно использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

### Ответ на задачу 1

```
sku@Angurva:~$ sudo apt install golang
[sudo] password for sku:
Reading package lists... Done
Building dependency tree
Reading state information... Done
golang is already the newest version (2:1.10~4ubuntu1).

sku@Angurva:~$ go version
go version go1.16.4 linux/amd64
```

Но версия староватaя..

```
sku@Angurva:~$ sudo wget https://go.dev/dl/go1.18.3.linux-amd64.tar.gz
sku@Angurva:~$ sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.18.3.linux-amd64.tar.gz

sku@Angurva:~$ go version
go version go1.18.3 linux/amd64
```


## Задача 2. Знакомство с gotour.
У Golang есть обучающая интерактивная консоль [https://tour.golang.org/](https://tour.golang.org/). 
Рекомендуется изучить максимальное количество примеров. В консоли уже написан необходимый код, 
осталось только с ним ознакомиться и поэкспериментировать как написано в инструкции в левой части экрана.  

### Ответ на задачу 2
Done

## Задача 3. Написание кода. 
Цель этого задания закрепить знания о базовом синтаксисе языка. Можно использовать редактор кода 
на своем компьютере, либо использовать песочницу: [https://play.golang.org/](https://play.golang.org/).

1. Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные 
у пользователя, а можно статически задать в коде.
    Для взаимодействия с пользователем можно использовать функцию `Scanf`:
    ```
    package main
    
    import "fmt"
    
    func main() {
        fmt.Print("Enter a number: ")
        var input float64
        fmt.Scanf("%f", &input)
    
        output := input * 2
    
        fmt.Println(output)    
    }
    ```
 
1. Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:
    ```
    x := []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
    ```
1. Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть `(3, 6, 9, …)`.

В виде решения ссылку на код или сам код. 

### Ответ на задачу 3

* программa для перевода метров в футы (1 фут = 0.3048 метр)
```
package main

import "fmt"

const x = 0.3048

func main() {
	fmt.Println("Введите количество футов: ")
	var input float64

	fmt.Scanf("%f", &input)

	output := input * x

	fmt.Println("В метрах это: ", output)
}
```

Результат:
```
sku@Angurva:~$ go run f2m.go
Введите количество футов:
15
В метрах это:  4.572
```

* программa, которая найдет наименьший элемент в любом заданном списке
```
package main
import "fmt"

func main() {

	x := []int{48, 96, 86, 68, 57, 82, 63, 70, 37, 34, 83, 27, 19, 97, 9, 17}

	min := x[0]
	for _, x := range x {
		if x < min {
			min = x
		}
	}

	fmt.Println(min)
}
```
Результат:
```
9

Program exited.
```

* программа, которая выводит числа от 1 до 100, которые делятся на 3. 

```
package main

import "fmt"

func main() {
	for i := 1; i <= 100; i++ {
		if ((i - 1) % 10) == 0 {
			fmt.Print(i-1, " -> ")
		}

		if (i % 3) == 0 {
			fmt.Print(i, ", ")
		}
		if (i % 10) == 0 {
			fmt.Println()
		}
	}
}
```

Результат:
```
0 -> 3, 6, 9, 
10 -> 12, 15, 18, 
20 -> 21, 24, 27, 30, 
30 -> 33, 36, 39, 
40 -> 42, 45, 48, 
50 -> 51, 54, 57, 60, 
60 -> 63, 66, 69, 
70 -> 72, 75, 78, 
80 -> 81, 84, 87, 90, 
90 -> 93, 96, 99, 

Program exited.
```