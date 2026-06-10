# Домашнее задание к занятию «Работа с данными в MySQL»* - *Выполнил:** Зиновьев Михаил  
**ОС:** RED OS 7.3  
**СУБД:** MySQL 8.0.46 Community Server  
**Способ развёртывания:** Docker-контейнер  

---

## Задание 1
1.1. Поднимите чистый инстанс MySQL версии 8.0+. Можно использовать локальный сервер или контейнер Docker.

1.2. Создайте учётную запись sys_temp.

1.3. Выполните запрос на получение списка пользователей в базе данных. (скриншот)

1.4. Дайте все права для пользователя sys_temp.

1.5. Выполните запрос на получение списка прав для пользователя sys_temp. (скриншот)

1.6. Переподключитесь к базе данных от имени sys_temp.

Для смены типа аутентификации с sha2 используйте запрос:

ALTER USER 'sys_test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
1.6. По ссылке https://downloads.mysql.com/docs/sakila-db.zip скачайте дамп базы данных.

1.7. Восстановите дамп в базу данных.

1.8. При работе в IDE сформируйте ER-диаграмму получившейся базы данных. При работе в командной строке используйте команду для получения всех таблиц базы данных. (скриншот)

Результатом работы должны быть скриншоты обозначенных заданий, а также простыня со всеми запросами.

## Выполнение задания 1

### 1.1. Поднять чистый инстанс MySQL версии 8.0+

Для выполнения задания был развёрнут чистый контейнер MySQL версии 8.0.

```bash
sudo docker run \
  --name mysql80-sakila \
  -e MYSQL_ROOT_PASSWORD='RootPass_123!' \
  -p 3306:3306 \
  -d mysql:8.0
```

Описание команды:

- `sudo` — запуск команды с правами администратора;
- `docker run` — создание и запуск нового контейнера;
- `--name mysql80-sakila` — имя контейнера;
- `-e MYSQL_ROOT_PASSWORD='RootPass_123!'` — установка пароля для пользователя `root` в MySQL;
- `-p 3306:3306` — проброс порта MySQL из контейнера на хост;
- `-d` — запуск контейнера в фоновом режиме;
- `mysql:8.0` — образ MySQL версии 8.0.

### Запуск контейнера MySQL 8.0:
<img width="786" height="460" alt="docker_MySQL_01" src="https://github.com/user-attachments/assets/0b6d5f83-9273-4820-939d-cb620685616f" />


Проверка запущенного контейнера:

```bash
sudo docker ps
```

Команда показывает список запущенных контейнеров.

### Проверка запущенного контейнера:
<img width="1657" height="75" alt="docker_MySQL_02" src="https://github.com/user-attachments/assets/c17f0a73-a7c8-4b69-9d9c-e9061597adc7" />

Проверка логов контейнера:

```bash
sudo docker logs mysql80-sakila
```

Команда выводит служебные сообщения MySQL и позволяет убедиться, что сервер успешно запущен.

### Логи контейнера MySQL:
<img width="1522" height="739" alt="docker_MySQL_03" src="https://github.com/user-attachments/assets/f0450911-3ef1-4b77-8346-256940681831" />


Проверка доступности MySQL:

```bash
sudo docker exec mysql80-sakila mysqladmin ping -uroot -p'RootPass_123!'
```

Команда выполняет `mysqladmin ping` внутри контейнера и проверяет, что MySQL отвечает.

### Проверка доступности MySQL:
<img width="776" height="50" alt="docker_MySQL_04" src="https://github.com/user-attachments/assets/a5d04cf1-aaf9-4b46-a3d8-4884bc9c7691" />


---

### 1.2. Создать учётную запись `sys_temp`

Подключение к MySQL под пользователем `root`:

```bash
sudo docker exec -it mysql80-sakila mysql -uroot -p
```

Создание пользователя:

```sql
CREATE USER IF NOT EXISTS 'sys_temp'@'localhost' IDENTIFIED BY 'SysTemp_123!';
```

Описание запроса:

- `CREATE USER` — создаёт нового пользователя MySQL;
- `IF NOT EXISTS` — предотвращает ошибку, если пользователь уже существует;
- `'sys_temp'@'localhost'` — имя пользователя и хост подключения;
- `IDENTIFIED BY 'SysTemp_123!'` — пароль пользователя.

### Подключение под root и создание пользователя:
<img width="901" height="307" alt="docker_MySQL_uroot_05" src="https://github.com/user-attachments/assets/6ef63807-2f36-4868-8626-5a2ff2d96f76" />


Смена типа аутентификации на `mysql_native_password`:

```sql
ALTER USER 'sys_temp'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'SysTemp_123!';
```

Описание запроса:

- `ALTER USER` — изменяет параметры существующего пользователя;
- `IDENTIFIED WITH mysql_native_password` — задаёт тип аутентификации;
- `BY 'SysTemp_123!'` — задаёт пароль пользователя.

### Смена типа аутентификации:
<img width="710" height="49" alt="docker_MySQL_uroot_06" src="https://github.com/user-attachments/assets/f20c08a1-8836-427d-ba2a-6c21935377e0" />


Применение изменений прав:

```sql
FLUSH PRIVILEGES;
```

Команда перечитывает таблицы привилегий MySQL.

### Применение изменений прав:
<img width="344" height="49" alt="docker_MySQL_uroot_07" src="https://github.com/user-attachments/assets/e2fb4880-98b2-479e-8006-8726f3273f2d" />


---

### 1.3. Выполнить запрос на получение списка пользователей в базе данных

Запрос:

```sql
SELECT user, host, plugin
FROM mysql.user
ORDER BY user, host;
```

Описание запроса:

- `SELECT user, host, plugin` — выводит имя пользователя, хост и тип аутентификации;
- `FROM mysql.user` — данные берутся из системной таблицы пользователей MySQL;
- `ORDER BY user, host` — сортировка результата по пользователю и хосту.

Результат выполнения запроса:

### Список пользователей MySQL: 
<img width="432" height="231" alt="docker_MySQL_uroot_08" src="https://github.com/user-attachments/assets/da2a5680-d504-4fec-8552-0fa0f5c32016" />


---

### 1.4. Дать все права пользователю `sys_temp`

Запрос:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'sys_temp'@'localhost' WITH GRANT OPTION;
```

Описание запроса:

- `GRANT` — выдаёт права пользователю;
- `ALL PRIVILEGES` — выдаёт все доступные права;
- `ON *.*` — права выдаются на все базы данных и все таблицы;
- `TO 'sys_temp'@'localhost'` — пользователь, которому выдаются права;
- `WITH GRANT OPTION` — разрешает пользователю выдавать права другим пользователям.

Применение изменений:

```sql
FLUSH PRIVILEGES;
```

---

### 1.5. Выполнить запрос на получение списка прав пользователя `sys_temp`

Запрос:

```sql
SHOW GRANTS FOR 'sys_temp'@'localhost';
```

Описание запроса:

- `SHOW GRANTS` — показывает права пользователя;
- `FOR 'sys_temp'@'localhost'` — указывает конкретного пользователя.

Результат выполнения запроса:

### Права пользователя sys_temp: 
<img width="1908" height="364" alt="docker_MySQL_uroot_priv_09" src="https://github.com/user-attachments/assets/f086f3c7-e2c2-4282-a3f9-11ff1af023d9" />

---

### 1.6. Переподключиться к базе данных от имени `sys_temp`

Подключение под пользователем `sys_temp`:

```bash
sudo docker exec -it mysql80-sakila mysql -usys_temp -p
```

Проверка текущего пользователя:

```sql
SELECT USER(), CURRENT_USER();
```

Описание запроса:

- `USER()` — показывает пользователя, под которым выполнено подключение;
- `CURRENT_USER()` — показывает пользователя, по которому MySQL проверяет права.

Результат подключения:

### Подключение под пользователем sys_temp:
<img width="616" height="317" alt="docker_MySQL_uSYS_TEMP_LOGIN_010" src="https://github.com/user-attachments/assets/132df093-d1d2-43c1-bebf-0b455a447a83" />


---

### 1.7. Скачать и восстановить дамп базы данных Sakila

Переход в рабочую директорию:

```bash
cd ~/mysql-sakila-hw
```

Скачивание архива с базой Sakila:

```bash
curl -L -o sakila-db.zip https://downloads.mysql.com/docs/sakila-db.zip
```

Описание команды:

- `curl` — скачивает файл из сети;
- `-L` — разрешает переход по перенаправлениям;
- `-o sakila-db.zip` — сохраняет файл под именем `sakila-db.zip`.

Распаковка архива:

```bash
unzip -o sakila-db.zip
```

Описание команды:

- `unzip` — распаковывает архив;
- `-o` — перезаписывает файлы без дополнительного подтверждения.

Проверка файлов:

```bash
ls -la sakila-db
```

Восстановление схемы базы данных:

```bash
sudo docker exec -i mysql80-sakila mysql -usys_temp -p'SysTemp_123!' < sakila-db/sakila-schema.sql
```

Восстановление данных:

```bash
sudo docker exec -i mysql80-sakila mysql -usys_temp -p'SysTemp_123!' < sakila-db/sakila-data.sql
```

Описание команд восстановления:

- `docker exec` — выполняет команду внутри контейнера;
- `-i` — передаёт SQL-файл в стандартный ввод MySQL;
- `mysql80-sakila` — имя контейнера;
- `mysql -usys_temp -p'SysTemp_123!'` — подключение к MySQL под пользователем `sys_temp`;
- `< sakila-db/sakila-schema.sql` — загрузка структуры базы;
- `< sakila-db/sakila-data.sql` — загрузка данных.

Проверка наличия базы:

```sql
SHOW DATABASES;
```

Выбор базы:

```sql
USE sakila;
```

Результат восстановления базы данных:

### Скачивание и восстановление базы Sakila:
<img width="803" height="720" alt="docker_MySQL_RECOVER_DB_011" src="https://github.com/user-attachments/assets/5e690f54-0872-45c4-b715-77eed5768414" />

> Примечание: если SQL-файл с данными запустить повторно, MySQL может вывести ошибку `Duplicate entry`, так как данные уже были загружены ранее. Это означает, что повторная вставка дублирует уже существующие записи.

---

### 1.8. Получить список всех таблиц базы данных

После выбора базы данных:

```sql
USE sakila;
```

Можно вывести таблицы командой:

```sql
SHOW TABLES;
```

Команда показывает все таблицы и представления в выбранной базе данных.

Для вывода только обычных таблиц был использован запрос:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'sakila'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;
```

Описание запроса:

- `information_schema.tables` — системное представление со сведениями о таблицах;
- `table_schema = 'sakila'` — выбор только базы `sakila`;
- `table_type = 'BASE TABLE'` — вывод только обычных таблиц, без представлений;
- `ORDER BY table_name` — сортировка по имени таблицы.

Результат выполнения:

### Список таблиц базы sakila:
<img width="587" height="738" alt="docker_MySQL_DB_TABLES_012" src="https://github.com/user-attachments/assets/3424d9ad-f2a2-4963-87e9-3daa3b7f486d" />


---
## Задание 2
Составьте таблицу, используя любой текстовый редактор или Excel, в которой должно быть два столбца: в первом должны быть названия таблиц восстановленной базы, во втором названия первичных ключей этих таблиц. Пример: (скриншот/текст)

Название таблицы | Название первичного ключа
customer         | customer_id

##  Выполнение задания 2

### Таблица с названиями таблиц и первичными ключами

Для получения списка первичных ключей был выполнен запрос:

```sql
SELECT
    tc.table_name AS 'Название таблицы',
    GROUP_CONCAT(kcu.column_name ORDER BY kcu.ordinal_position SEPARATOR ', ') AS 'Название первичного ключа'
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
   AND tc.table_name = kcu.table_name
WHERE tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_schema = 'sakila'
GROUP BY tc.table_name
ORDER BY tc.table_name;
```

Описание запроса:

- `information_schema.table_constraints` — содержит сведения об ограничениях таблиц;
- `information_schema.key_column_usage` — содержит сведения о колонках, входящих в ключи;
- `constraint_type = 'PRIMARY KEY'` — выбираются только первичные ключи;
- `table_schema = 'sakila'` — анализируется только база `sakila`;
- `GROUP_CONCAT` — объединяет несколько колонок первичного ключа для составных ключей.

Результат выполнения запроса:

### Таблицы и первичные ключи:
<img width="570" height="443" alt="Q2_docker_MySQL_uSYS_TEMP_LOGIN_01" src="https://github.com/user-attachments/assets/d3c741e9-da59-4d06-a171-48af296a31ff" />


Итоговая таблица:

| Название таблицы | Название первичного ключа |
|---|---|
| actor | actor_id |
| address | address_id |
| category | category_id |
| city | city_id |
| country | country_id |
| customer | customer_id |
| film | film_id |
| film_actor | actor_id, film_id |
| film_category | film_id, category_id |
| film_text | film_id |
| inventory | inventory_id |
| language | language_id |
| payment | payment_id |
| rental | rental_id |
| staff | staff_id |
| store | store_id |

---
Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.

## Задание 3*
3.1. Уберите у пользователя sys_temp права на внесение, изменение и удаление данных из базы sakila.

3.2. Выполните запрос на получение списка прав для пользователя sys_temp. (скриншот)

Результатом работы должны быть скриншоты обозначенных заданий, а также простыня со всеми запросами.
## Выполнение задания 3*

### 3.1. Убрать у пользователя `sys_temp` права на внесение, изменение и удаление данных из базы `sakila`

Так как ранее пользователю были выданы глобальные права `ALL PRIVILEGES ON *.*`, сначала были отозваны все права:

```sql
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'sys_temp'@'localhost';
```

Описание запроса:

- `REVOKE` — отзывает ранее выданные права;
- `ALL PRIVILEGES` — отзывает все права;
- `GRANT OPTION` — отзывает возможность выдавать права другим пользователям.

Результат выполнения:

### Отзыв всех прав у пользователя sys_temp:
<img width="526" height="40" alt="Q3_docker_MySQL_REVOKE_01" src="https://github.com/user-attachments/assets/9685e7fb-847e-4ec6-8849-b4cea1382fb4" />

После этого пользователю были выданы права на чтение и служебные операции в базе `sakila`, но без прав `INSERT`, `UPDATE`, `DELETE`:

```sql
GRANT SELECT, SHOW VIEW, EXECUTE, CREATE TEMPORARY TABLES, LOCK TABLES
ON sakila.*
TO 'sys_temp'@'localhost';
```

Описание запроса:

- `SELECT` — разрешает читать данные;
- `SHOW VIEW` — разрешает просматривать представления;
- `EXECUTE` — разрешает выполнять процедуры и функции;
- `CREATE TEMPORARY TABLES` — разрешает создавать временные таблицы;
- `LOCK TABLES` — разрешает блокировать таблицы;
- `ON sakila.*` — права выдаются на все таблицы базы `sakila`;
- отсутствуют `INSERT`, `UPDATE`, `DELETE`, значит пользователь не может добавлять, изменять и удалять данные.

Применение изменений:

```sql
FLUSH PRIVILEGES;
```

Результат выполнения:

### Выдача ограниченного набора прав:
<img width="543" height="109" alt="Q3_docker_MySQL_GRANT_NEW_PRIV_02" src="https://github.com/user-attachments/assets/522727f8-5b05-47fb-8477-ea0628840b8d" />


---

### 3.2. Выполнить запрос на получение списка прав пользователя `sys_temp`

Запрос:

```sql
SHOW GRANTS FOR 'sys_temp'@'localhost';
```

Результат выполнения:

### Проверка прав пользователя после ограничения:
<img width="737" height="119" alt="Q3_docker_MySQL_GRANT_NEW_PRIV_03" src="https://github.com/user-attachments/assets/8ab6cf04-669e-47ca-8fb5-0ee3e5572eac" />


На скриншоте видно, что у пользователя есть права:

- `USAGE`;
- `SELECT`;
- `CREATE TEMPORARY TABLES`;
- `LOCK TABLES`;
- `EXECUTE`;
- `SHOW VIEW`.

Права `INSERT`, `UPDATE`, `DELETE` отсутствуют.

---

### Дополнительная проверка запрета изменения данных

Подключение под пользователем `sys_temp`:

```bash
sudo docker exec -it mysql80-sakila mysql -usys_temp -p
```

Выбор базы данных:

```sql
USE sakila;
```

Проверка чтения данных:

```sql
SELECT * FROM actor LIMIT 5;
```

Проверка запрета на добавление данных:

```sql
INSERT INTO actor (first_name, last_name)
VALUES ('TEST', 'USER');
```

Проверка запрета на изменение данных:

```sql
UPDATE actor
SET first_name = 'TEST'
WHERE actor_id = 1;
```

Проверка запрета на удаление данных:

```sql
DELETE FROM actor
WHERE actor_id = 1;
```

Результат проверки:

### Проверка запрета INSERT UPDATE DELETE:
<img width="718" height="381" alt="Q3_docker_MySQL_GRANT_NEW_PRIV_04" src="https://github.com/user-attachments/assets/292f7faf-ef31-41af-955d-718e5cdabc34" />


На скриншоте видно, что чтение данных выполняется успешно, а операции `INSERT`, `UPDATE`, `DELETE` завершаются ошибкой доступа.

---

## Простыня со всеми запросами

```sql
-- =========================================================
-- Задание 1.2. Создание пользователя sys_temp
-- =========================================================

CREATE USER IF NOT EXISTS 'sys_temp'@'localhost' IDENTIFIED BY 'SysTemp_123!';

ALTER USER 'sys_temp'@'localhost'
IDENTIFIED WITH mysql_native_password BY 'SysTemp_123!';

FLUSH PRIVILEGES;


-- =========================================================
-- Задание 1.3. Получение списка пользователей
-- =========================================================

SELECT user, host, plugin
FROM mysql.user
ORDER BY user, host;


-- =========================================================
-- Задание 1.4. Выдача всех прав пользователю sys_temp
-- =========================================================

GRANT ALL PRIVILEGES ON *.* TO 'sys_temp'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;


-- =========================================================
-- Задание 1.5. Получение списка прав пользователя sys_temp
-- =========================================================

SHOW GRANTS FOR 'sys_temp'@'localhost';


-- =========================================================
-- Задание 1.6. Проверка подключения под sys_temp
-- =========================================================

SELECT USER(), CURRENT_USER();


-- =========================================================
-- Задание 1.8. Получение списка таблиц базы sakila
-- =========================================================

USE sakila;

SHOW TABLES;

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'sakila'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- =========================================================
-- Задание 2. Таблицы и первичные ключи
-- =========================================================

SELECT
    tc.table_name AS 'Название таблицы',
    GROUP_CONCAT(kcu.column_name ORDER BY kcu.ordinal_position SEPARATOR ', ') AS 'Название первичного ключа'
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
   AND tc.table_schema = kcu.table_schema
   AND tc.table_name = kcu.table_name
WHERE tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_schema = 'sakila'
GROUP BY tc.table_name
ORDER BY tc.table_name;


-- =========================================================
-- Задание 3*. Снятие прав на INSERT, UPDATE, DELETE
-- =========================================================

REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'sys_temp'@'localhost';

GRANT SELECT, SHOW VIEW, EXECUTE, CREATE TEMPORARY TABLES, LOCK TABLES
ON sakila.*
TO 'sys_temp'@'localhost';

FLUSH PRIVILEGES;


-- =========================================================
-- Задание 3.2. Проверка прав после ограничения
-- =========================================================

SHOW GRANTS FOR 'sys_temp'@'localhost';


-- =========================================================
-- Дополнительная проверка запрета изменения данных
-- =========================================================

USE sakila;

SELECT * FROM actor LIMIT 5;

INSERT INTO actor (first_name, last_name)
VALUES ('TEST', 'USER');

UPDATE actor
SET first_name = 'TEST'
WHERE actor_id = 1;

DELETE FROM actor
WHERE actor_id = 1;
```

---

## Вывод

В ходе выполнения задания был развёрнут чистый инстанс MySQL 8.0 в Docker-контейнере на RED OS 7.3.  
Был создан пользователь `sys_temp`, ему были выданы полные права, после чего выполнено подключение под этой учётной записью.  
База данных `sakila` была скачана, восстановлена и проверена.  
Также был получен список таблиц базы данных и составлена таблица первичных ключей.  
В дополнительном задании у пользователя `sys_temp` были отозваны права на добавление, изменение и удаление данных из базы `sakila`, что было подтверждено проверочными запросами.
