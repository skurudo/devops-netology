#!/usr/bin/env python3
a = 1
b = '2'
#c = a + b

# Какое значение будет присвоено переменной `c`? 
#print c
# закономерно получим ошибку

# Как получить для переменной `c` значение 12?
c=str(a)+b
print (c)
# "сложим" строки и получим 12

# Как получить для переменной `c` значение 3?
c=a+int(b)
print (c)
# сложим цифры и получим 3