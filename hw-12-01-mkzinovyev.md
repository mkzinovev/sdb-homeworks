# Домашнее задание к занятию «Базы данных» — выполнил Михаил Зиновьев

## Легенда

Заказчик передал вам [файл в формате Excel](https://github.com/netology-code/sdb-homeworks/blob/main/resources/hw-12-1.xlsx), в котором сформирован отчёт. 

На основе этого отчёта нужно выполнить следующие задания.

---

# Задание 1

## Условие

Опишите не менее семи таблиц, из которых состоит база данных. Определите:

- какие данные хранятся в этих таблицах;
- какой тип данных у столбцов в этих таблицах, если данные хранятся в PostgreSQL.

Также необходимо начертить схему полученной модели данных. На схеме должны быть отображены:

- все таблицы с их названиями;
- все столбцы с указанием типов данных;
- первичные ключи;
- связи между таблицами.

---

## Выполнение задания 1. Проектирование модели данных

### 1. Анализ исходного отчёта

Исходный Excel-отчёт содержит данные о сотрудниках, должностях, подразделениях, филиалах и проектах.

В одной таблице исходного отчёта смешаны разные сущности:

| Данные из отчёта | Как используются в модели |
|---|---|
| ФИО сотрудника | Основные данные сотрудника |
| Должность | Справочник должностей |
| Тип подразделения | Справочник типов подразделений |
| Структурное подразделение | Таблица подразделений |
| Дата найма | Атрибут сотрудника |
| Адрес филиала | Таблица филиалов / площадок |
| Проект, на который назначен сотрудник | Таблица проектов и связующая таблица назначений |

В отчёте есть повторяющиеся данные: должности, типы подразделений, подразделения, филиалы и проекты. Поэтому исходную таблицу нужно разбить на несколько связанных таблиц.

Отдельно выделена таблица `employee_projects`, потому что один сотрудник может быть назначен на несколько 
проектов, а один проект может включать нескольких сотрудников. Такая связь является связью «многие ко многим».

---

## 2. Полученная модель данных

В модели используется 7 таблиц:

1. `positions` — должности сотрудников.
2. `department_types` — типы подразделений.
3. `departments` — структурные подразделения.
4. `branches` — филиалы / площадки компании.
5. `employees` — сотрудники.
6. `projects` — проекты.
7. `employee_projects` — связь сотрудников и проектов.

---

## 3. Описание таблиц

### Таблица `positions`

Хранит справочник должностей сотрудников.

| Столбец | Тип PostgreSQL | Назначение |
|---|---|---|
| `position_id` | `SERIAL` | Первичный ключ |
| `name` | `VARCHAR(150)` | Название должности |
| `description` | `TEXT` | Описание должности |

Первичный ключ: `position_id`.

---

### Таблица `department_types`

Хранит справочник типов подразделений.

| Столбец | Тип PostgreSQL | Назначение |
|---|---|---|
| `department_type_id` | `SERIAL` | Первичный ключ |
| `name` | `VARCHAR(50)` | Название типа подразделения |

Первичный ключ: `department_type_id`.

---

### Таблица `departments`

Хранит структурные подразделения компании.

| Столбец | Тип PostgreSQL | Назначение |
|---|---|---|
| `department_id` | `SERIAL` | Первичный ключ |
| `name` | `VARCHAR(200)` | Название структурного подразделения |
| `department_type_id` | `INTEGER` | Ссылка на тип подразделения |

Первичный ключ: `department_id`.

Внешний ключ:

- `department_type_id` ссылается на `department_types.department_type_id`.

---

### Таблица `branches`

Хранит данные о филиалах / площадках компании.

| Столбец | Тип PostgreSQL | Назначение |
|---|---|---|
| `branch_id` | `SERIAL` | Первичный ключ |
| `name` | `VARCHAR(200)` | Название филиала / площадки |
| `city` | `VARCHAR(100)` | Город |
| `address` | `VARCHAR(255)` | Адрес филиала / площадки |

Первичный ключ: `branch_id`.

---

### Таблица `employees`

Хранит основные данные о сотрудниках.

| Столбец | Тип PostgreSQL | Назначение |
|---|---|---|
| `employee_id` | `SERIAL` | Первичный ключ |
| `last_name` | `VARCHAR(100)` | Фамилия сотрудника |
| `first_name` | `VARCHAR(100)` | Имя сотрудника |
| `middle_name` | `VARCHAR(100)` | Отчество сотрудника |
| `email` | `VARCHAR(150)` | Электронная почта сотрудника |
| `phone` | `VARCHAR(30)` | Телефон сотрудника |
| `position_id` | `INTEGER` | Ссылка на должность |
| `department_id` | `INTEGER` | Ссылка на подразделение |
| `branch_id` | `INTEGER` | Ссылка на филиал |
| `hire_date` | `DATE` | Дата найма |
| `is_active` | `BOOLEAN` | Признак активного сотрудника |

Первичный ключ: `employee_id`.

Внешние ключи:

- `position_id` ссылается на `positions.position_id`;
- `department_id` ссылается на `departments.department_id`;
- `branch_id` ссылается на `branches.branch_id`.

---

### Таблица `projects`

Хранит справочник проектов компании.

| Столбец | Тип PostgreSQL | Назначение |
|---|---|---|
| `project_id` | `SERIAL` | Первичный ключ |
| `name` | `VARCHAR(200)` | Название проекта |
| `description` | `TEXT` | Описание проекта |
| `start_date` | `DATE` | Дата начала проекта |
| `end_date` | `DATE` | Дата завершения проекта |
| `status` | `VARCHAR(30)` | Статус проекта |

Первичный ключ: `project_id`.

---

### Таблица `employee_projects`

Хранит связь сотрудников с проектами.

| Столбец | Тип PostgreSQL | Назначение |
|---|---|---|
| `employee_id` | `INTEGER` | Ссылка на сотрудника |
| `project_id` | `INTEGER` | Ссылка на проект |
| `role_in_project` | `VARCHAR(100)` | Роль сотрудника в проекте |
| `assigned_at` | `DATE` | Дата назначения на проект |

Первичный ключ: составной — `employee_id`, `project_id`.

Внешние ключи:

- `employee_id` ссылается на `employees.employee_id`;
- `project_id` ссылается на `projects.project_id`.

---

## 4. Связи между таблицами

| Связь | Тип связи | Пояснение |
|---|---|---|
| `positions` → `employees` | 1 ко многим | Одна должность может быть у многих сотрудников |
| `department_types` → `departments` | 1 ко многим | Один тип подразделения может быть у многих подразделений |
| `departments` → `employees` | 1 ко многим | В одном подразделении может работать много сотрудников |
| `branches` → `employees` | 1 ко многим | В одном филиале может работать много сотрудников |
| `employees` → `employee_projects` | 1 ко многим | Один сотрудник может иметь несколько назначений на проекты |
| `projects` → `employee_projects` | 1 ко многим | Один проект может включать нескольких сотрудников |
| `employees` ↔ `projects` | многие ко многим | Реализовано через таблицу `employee_projects` |

---

## 5. Почему модель разбита именно так

Исходный Excel-отчёт представляет собой плоскую таблицу. Если оставить данные в одной таблице, появятся проблемы:

- должности будут многократно повторяться;
- названия подразделений будут дублироваться;
- типы подразделений будут повторяться;
- адреса филиалов будут дублироваться;
- проекты неудобно хранить и анализировать, если у сотрудника их несколько;
- при изменении названия должности, подразделения, филиала или проекта потребуется менять много строк.

Поэтому справочные сущности вынесены в отдельные таблицы, а связь сотрудников с проектами вынесена в отдельную связующую таблицу `employee_projects`.

---

## 6. Схема модели данных

Схема модели данных была построена в DBeaver на основе созданных таблиц и внешних ключей.

### ER-диаграмма модели данных:

<img width="1006" height="414" alt="task2_11_er_diagram" src="https://github.com/user-attachments/assets/6c02fc94-fb52-4230-bd5b-4963e7e2320a" />

---

# Задание 2*

## Условие

Разверните СУБД PostgreSQL на своей хостовой машине, на виртуальной машине или в контейнере Docker.

Опишите схему, полученную в предыдущем задании, с помощью SQL-скрипта.

Создайте в полученной СУБД новую базу данных и выполните полученный ранее скрипт для создания модели данных.

В качестве решения приложите SQL-скрипт и скриншот диаграммы.

---

## Выполнение задания 2*

### 1. Установка PostgreSQL на Red OS 7.3

Сначала был выполнен поиск доступных пакетов PostgreSQL в репозиториях Red OS.

```bash
sudo dnf search postgresql | grep -i server
```

### Поиск пакетов PostgreSQL:
<img width="881" height="98" alt="task2_01_search_postgresql" src="https://github.com/user-attachments/assets/5495acce-8a18-4ec7-8418-5c400a33a8d5" />


После этого были установлены сервер PostgreSQL 15 и клиентские утилиты.

```bash
sudo dnf install -y postgresql15-server postgresql15
```

### Установка PostgreSQL:
<img width="997" height="310" alt="task2_02_install_postgresql" src="https://github.com/user-attachments/assets/2ca5f1f7-6bb0-421e-8987-d34d9daa0281" />

---

### 2. Инициализация PostgreSQL

После установки была выполнена инициализация кластера базы данных.

```bash
sudo postgresql-15-setup initdb
```

### Инициализация PostgreSQL: 
<img width="732" height="60" alt="task2_03_initdb" src="https://github.com/user-attachments/assets/9ff07865-d0fc-4f14-97b4-3f64da77a42c" />


Далее служба PostgreSQL была включена в автозагрузку и запущена.

```bash
sudo systemctl enable postgresql-15.service --now
sudo systemctl status postgresql-15.service
```

Также была выполнена проверка, что PostgreSQL слушает стандартный порт `5432`.

```bash
ss -tulpen | grep 5432
```

### Статус службы PostgreSQL и проверка порта:
<img width="1481" height="665" alt="task2_04_service_status_port" src="https://github.com/user-attachments/assets/6cb3ffc9-c70b-440e-a912-17e785161533" />



---

### 3. Создание базы данных

Была создана новая база данных для модели структуры компании.

```bash
su - postgres
createdb company_structure_db
psql -d company_structure_db
```

### Создание базы данных:
<img width="1248" height="624" alt="task2_05_create_database" src="https://github.com/user-attachments/assets/18c61a6b-373f-4962-8a62-7adbc4fe3da9" />

---

### 4. SQL-скрипт создания модели данных

Для создания модели данных был подготовлен SQL-скрипт:

```text
company_structure_schema.sql
```
Файл SQL-скрипта приложен к решению: https://github.com/mkzinovev/sdb-homeworks/blob/d100806f9da2b49a8e37e40f3bf12f9c980adedd/resources/company_structure_schema.sql 


Полный текст скрипта:

```sql
-- company_structure_schema.sql
-- Домашнее задание: Базы данных, задание 2*
-- СУБД: PostgreSQL
-- Назначение: создание модели данных компании из 7 таблиц

-- Скрипт можно запускать повторно: старые таблицы будут удалены.
DROP TABLE IF EXISTS employee_projects CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS department_types CASCADE;
DROP TABLE IF EXISTS positions CASCADE;
DROP TABLE IF EXISTS branches CASCADE;

-- 1. Справочник должностей
CREATE TABLE positions (
    position_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT
);

-- 2. Справочник типов подразделений
CREATE TABLE department_types (
    department_type_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- 3. Филиалы / площадки компании
CREATE TABLE branches (
    branch_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(255)
);

-- 4. Структурные подразделения компании
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    department_type_id INTEGER NOT NULL,
    CONSTRAINT fk_departments_department_type
        FOREIGN KEY (department_type_id)
        REFERENCES department_types(department_type_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 5. Сотрудники
CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(30),
    position_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    branch_id INTEGER NOT NULL,
    hire_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT fk_employees_position
        FOREIGN KEY (position_id)
        REFERENCES positions(position_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_employees_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_employees_branch
        FOREIGN KEY (branch_id)
        REFERENCES branches(branch_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- 6. Проекты компании
CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'planned',

    CONSTRAINT chk_projects_status
        CHECK (status IN ('planned', 'active', 'paused', 'completed', 'cancelled')),

    CONSTRAINT chk_projects_dates
        CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

-- 7. Связующая таблица сотрудников и проектов
-- Реализует связь многие-ко-многим:
-- один сотрудник может участвовать в нескольких проектах,
-- один проект может включать нескольких сотрудников.
CREATE TABLE employee_projects (
    employee_id INTEGER NOT NULL,
    project_id INTEGER NOT NULL,
    role_in_project VARCHAR(100),
    assigned_at DATE NOT NULL DEFAULT CURRENT_DATE,

    PRIMARY KEY (employee_id, project_id),

    CONSTRAINT fk_employee_projects_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_employee_projects_project
        FOREIGN KEY (project_id)
        REFERENCES projects(project_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- Индексы по внешним ключам для ускорения JOIN и поиска связанных записей
CREATE INDEX idx_departments_department_type_id
    ON departments(department_type_id);

CREATE INDEX idx_employees_position_id
    ON employees(position_id);

CREATE INDEX idx_employees_department_id
    ON employees(department_id);

CREATE INDEX idx_employees_branch_id
    ON employees(branch_id);

CREATE INDEX idx_employee_projects_project_id
    ON employee_projects(project_id);

```

---

### 5. Выполнение SQL-скрипта:
<img width="707" height="308" alt="task2_06_run_sql_script" src="https://github.com/user-attachments/assets/ba39b521-b606-4a1e-bbda-dfc4ada90a67" />


SQL-скрипт был выполнен в базе данных `company_structure_db`.

```bash
psql -d company_structure_db -f /tmp/company_structure_schema.sql
```

В результате были созданы таблицы и индексы.


---

### 6. Проверка результата в psql

После выполнения скрипта был проверен список созданных таблиц.

```sql
\dt
```

В базе данных создано 7 таблиц:

- `branches`;
- `department_types`;
- `departments`;
- `employee_projects`;
- `employees`;
- `positions`;
- `projects`.

### Список таблиц:
<img width="1706" height="640" alt="task2_07_show_tables" src="https://github.com/user-attachments/assets/42127d86-147d-412a-bb65-13589ad84b3c" />


Также была проверена структура таблицы `employees`.

```sql
\d employees
```

На скриншоте видно, что таблица содержит первичный ключ, внешние ключи и индексы.

### Структура таблицы employees:
<img width="870" height="349" alt="task2_08_describe_employees" src="https://github.com/user-attachments/assets/b9cc1ca8-4b19-4b81-a6a3-91f998a55bf2" />

Для проверки внешних ключей был выполнен SQL-запрос к системному каталогу PostgreSQL.

```sql
SELECT
    conname AS constraint_name,
    conrelid::regclass AS table_name,
    confrelid::regclass AS referenced_table
FROM pg_constraint
WHERE contype = 'f';
```

Результат показывает, что в базе данных созданы связи между таблицами.

### Проверка внешних ключей: 
<img width="2048" height="1025" alt="task2_09_check_foreign_keys" src="https://github.com/user-attachments/assets/472afc25-3a5b-414e-ae33-098f041516ad" />

---

### 7. Подключение к базе данных через DBeaver

После настройки PostgreSQL было выполнено подключение к базе данных через DBeaver.

Параметры подключения:

```text
Host: localhost
Port: 5432
Database: postgres / company_structure_db
User: postgres
Driver: PostgreSQL JDBC Driver
```

Подключение прошло успешно. На скриншоте видно, что DBeaver подключился к серверу PostgreSQL 15.17.

### Подключение к PostgreSQL через DBeaver:
<img width="1031" height="768" alt="task2_10_dbeaver_connection" src="https://github.com/user-attachments/assets/caa4fec9-07e8-4408-a478-e218593343bf" />

---

### 8. ER-диаграмма в DBeaver

После подключения к базе данных в DBeaver была построена ER-диаграмма модели данных.

На диаграмме отображены все 7 таблиц и связи между ними:

- `department_types` → `departments`;
- `departments` → `employees`;
- `branches` → `employees`;
- `positions` → `employees`;
- `employees` → `employee_projects`;
- `projects` → `employee_projects`.

### ER-диаграмма модели данных:
<img width="1006" height="414" alt="task2_11_er_diagram" src="https://github.com/user-attachments/assets/48bba2c0-b84c-41fd-9e5a-20e59857fa83" />


---

## Итог

В ходе выполнения домашнего задания:

- исходный Excel-отчёт был преобразован в реляционную модель данных;
- выделено 7 таблиц;
- определены типы данных PostgreSQL;
- определены первичные и внешние ключи;
- PostgreSQL был установлен и запущен на Red OS 7.3 Server;
- создана база данных `company_structure_db`;
- подготовлен и выполнен SQL-скрипт `company_structure_schema.sql`;
- созданные таблицы и внешние ключи были проверены в `psql`;
- подключение к базе данных было проверено через DBeaver;
- ER-диаграмма была построена в DBeaver.

Задание выполнено: SQL-скрипт и скриншот диаграммы приложены.
