# Домашнее задание к занятию «Базы данных» — выполнил `Михаил Зиновьев`


### Легенда

Заказчик передал вам [файл в формате Excel](https://github.com/netology-code/sdb-homeworks/blob/main/resources/hw-12-1.xlsx), в котором сформирован отчёт. 

На основе этого отчёта нужно выполнить следующие задания.

### Задание 1

Опишите не менее семи таблиц, из которых состоит база данных:

- какие данные хранятся в этих таблицах;
- какой тип данных у столбцов в этих таблицах, если данные хранятся в PostgreSQL.

Приведите решение к следующему виду:

Сотрудники (

- идентификатор, первичный ключ, serial,
- фамилия varchar(50),
- ...
- идентификатор структурного подразделения, внешний ключ, integer).


# Домашнее задание: проектирование схемы БД по Excel-отчёту

## Исходные данные

В исходном Excel-отчёте есть следующие поля:

- ФИО сотрудника;
- оклад;
- должность;
- тип подразделения;
- структурное подразделение;
- дата найма;
- адрес филиала;
- проект, на который назначен сотрудник.

В отчёте одна строка описывает сотрудника и его текущие параметры. При этом поле с проектами может содержать несколько проектов через запятую, например: `{Ростелеком. Гончарная,ВТБ Башня PM}`. Поэтому проекты нельзя хранить одним текстовым полем внутри таблицы сотрудников. Для этого нужна отдельная таблица проектов и связующая таблица назначений.

---

## Итоговая модель данных

Для нормализации отчёта исходные данные разбиты на 8 таблиц:

1. `employees` — сотрудники;
2. `positions` — должности;
3. `department_types` — типы подразделений;
4. `departments` — структурные подразделения;
5. `branches` — филиалы / офисы;
6. `employee_salaries` — оклады сотрудников;
7. `projects` — проекты;
8. `employee_projects` — назначения сотрудников на проекты.

---

## Таблица 1. `employees` — сотрудники

Хранит основную информацию о сотрудниках.

| Столбец | Тип PostgreSQL | Назначение |
|---|---:|---|
| `employee_id` | `BIGSERIAL` | Первичный ключ сотрудника |
| `full_name` | `VARCHAR(255)` | ФИО сотрудника |
| `position_id` | `BIGINT` | Ссылка на должность |
| `department_id` | `BIGINT` | Ссылка на структурное подразделение |
| `branch_id` | `BIGINT` | Ссылка на филиал / офис |
| `hire_date` | `DATE` | Дата найма |

Первичный ключ: `employee_id`.

---

## Таблица 2. `positions` — должности

Хранит справочник должностей: инженер, старший инженер, ведущий разработчик и т.д.

| Столбец | Тип PostgreSQL | Назначение |
|---|---:|---|
| `position_id` | `BIGSERIAL` | Первичный ключ должности |
| `position_name` | `VARCHAR(150)` | Название должности |

Первичный ключ: `position_id`.

Ограничение: `position_name` уникально.

---

## Таблица 3. `department_types` — типы подразделений

Хранит справочник типов подразделений: `Группа`, `Отдел`, `Департамент`.

| Столбец | Тип PostgreSQL | Назначение |
|---|---:|---|
| `department_type_id` | `SMALLSERIAL` | Первичный ключ типа подразделения |
| `type_name` | `VARCHAR(50)` | Название типа подразделения |

Первичный ключ: `department_type_id`.

Ограничение: `type_name` уникально.

---

## Таблица 4. `departments` — структурные подразделения

Хранит названия подразделений: `Группа CRM 2`, `Департамент FBF`, `Центр разработки Medio` и т.д.

| Столбец | Тип PostgreSQL | Назначение |
|---|---:|---|
| `department_id` | `BIGSERIAL` | Первичный ключ подразделения |
| `department_type_id` | `SMALLINT` | Ссылка на тип подразделения |
| `department_name` | `VARCHAR(255)` | Название структурного подразделения |

Первичный ключ: `department_id`.

Внешний ключ: `department_type_id` → `department_types.department_type_id`.

---

## Таблица 5. `branches` — филиалы / офисы

Хранит адреса филиалов из отчёта.

| Столбец | Тип PostgreSQL | Назначение |
|---|---:|---|
| `branch_id` | `BIGSERIAL` | Первичный ключ филиала |
| `full_address` | `TEXT` | Полный адрес филиала |

Первичный ключ: `branch_id`.

Ограничение: `full_address` уникален.

---

## Таблица 6. `employee_salaries` — оклады сотрудников

Хранит оклады сотрудников. Оклад вынесен в отдельную таблицу, потому что в реальной системе он может изменяться со временем. Так можно хранить историю изменений зарплаты.

| Столбец | Тип PostgreSQL | Назначение |
|---|---:|---|
| `salary_id` | `BIGSERIAL` | Первичный ключ записи об окладе |
| `employee_id` | `BIGINT` | Ссылка на сотрудника |
| `salary_amount` | `NUMERIC(12,2)` | Размер оклада |
| `valid_from` | `DATE` | Дата начала действия оклада |
| `valid_to` | `DATE` | Дата окончания действия оклада |
| `is_current` | `BOOLEAN` | Признак текущего оклада |

Первичный ключ: `salary_id`.

Внешний ключ: `employee_id` → `employees.employee_id`.

---

## Таблица 7. `projects` — проекты

Хранит справочник проектов.

| Столбец | Тип PostgreSQL | Назначение |
|---|---:|---|
| `project_id` | `BIGSERIAL` | Первичный ключ проекта |
| `project_name` | `VARCHAR(255)` | Название проекта |

Первичный ключ: `project_id`.

Ограничение: `project_name` уникально.

---

## Таблица 8. `employee_projects` — назначения сотрудников на проекты

Связующая таблица между сотрудниками и проектами.

Она нужна, потому что связь между сотрудниками и проектами — многие-ко-многим:

- один сотрудник может быть назначен на несколько проектов;
- один проект может включать нескольких сотрудников.

| Столбец | Тип PostgreSQL | Назначение |
|---|---:|---|
| `employee_id` | `BIGINT` | Ссылка на сотрудника |
| `project_id` | `BIGINT` | Ссылка на проект |
| `assigned_at` | `DATE` | Дата назначения на проект |

Составной первичный ключ: `employee_id`, `project_id`.

Внешние ключи:

- `employee_id` → `employees.employee_id`;
- `project_id` → `projects.project_id`.

---

## Связи между таблицами

| Связь | Тип связи | Пояснение |
|---|---:|---|
| `department_types` → `departments` | 1 ко многим | Один тип подразделения может быть у многих подразделений |
| `departments` → `employees` | 1 ко многим | В одном подразделении может работать много сотрудников |
| `positions` → `employees` | 1 ко многим | Одна должность может быть у многих сотрудников |
| `branches` → `employees` | 1 ко многим | В одном филиале может работать много сотрудников |
| `employees` → `employee_salaries` | 1 ко многим | У сотрудника может быть история окладов |
| `employees` → `employee_projects` | 1 ко многим | Один сотрудник может иметь несколько назначений |
| `projects` → `employee_projects` | 1 ко многим | Один проект может иметь несколько сотрудников |
| `employees` ↔ `projects` | многие ко многим | Реализовано через `employee_projects` |

---

## Почему нельзя оставить всё в одной таблице

Если оставить исходный Excel как одну таблицу, возникнут проблемы:

1. Повторяются названия должностей, подразделений и адресов филиалов.
2. При переименовании подразделения пришлось бы менять много строк.
3. Нельзя нормально хранить несколько проектов у одного сотрудника.
4. Сложно контролировать целостность данных.
5. Нельзя удобно хранить историю изменения оклада.

Поэтому данные разбиты на справочники и основные таблицы.

---

## Схема модели данных

<img width="1676" height="647" alt="image" src="https://github.com/user-attachments/assets/9916d086-0f0a-4b3b-944c-6679cdb2a7d1" />


На схеме показаны все таблицы, первичные ключи `PK`, внешние ключи `FK` и связи между таблицами.

---

## SQL-скрипт

SQL-скрипт для создания схемы БД находится в файле:

```
-- =========================================================
-- Схема БД по Excel-отчёту hw-12-1.xlsx
-- PostgreSQL
-- =========================================================
-- Рекомендуемый порядок запуска:
-- 1) Создать БД отдельно, например:
--    CREATE DATABASE company_report_db;
-- 2) Подключиться к company_report_db и выполнить этот скрипт.
-- =========================================================

DROP TABLE IF EXISTS employee_projects CASCADE;
DROP TABLE IF EXISTS employee_salaries CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS branches CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS department_types CASCADE;
DROP TABLE IF EXISTS positions CASCADE;

-- 1. Типы подразделений: Отдел, Группа, Департамент
CREATE TABLE department_types (
    department_type_id SMALLSERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE
);

-- 2. Должности сотрудников
CREATE TABLE positions (
    position_id BIGSERIAL PRIMARY KEY,
    position_name VARCHAR(150) NOT NULL UNIQUE
);

-- 3. Филиалы / офисы по адресам из отчёта
CREATE TABLE branches (
    branch_id BIGSERIAL PRIMARY KEY,
    full_address TEXT NOT NULL UNIQUE
);

-- 4. Структурные подразделения
CREATE TABLE departments (
    department_id BIGSERIAL PRIMARY KEY,
    department_type_id SMALLINT NOT NULL REFERENCES department_types(department_type_id),
    department_name VARCHAR(255) NOT NULL,
    UNIQUE (department_type_id, department_name)
);

-- 5. Сотрудники
CREATE TABLE employees (
    employee_id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    position_id BIGINT NOT NULL REFERENCES positions(position_id),
    department_id BIGINT NOT NULL REFERENCES departments(department_id),
    branch_id BIGINT NOT NULL REFERENCES branches(branch_id),
    hire_date DATE NOT NULL
);

-- 6. Оклады сотрудников.
-- Вынесены отдельно, чтобы в будущем хранить историю изменения оклада.
CREATE TABLE employee_salaries (
    salary_id BIGSERIAL PRIMARY KEY,
    employee_id BIGINT NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    salary_amount NUMERIC(12,2) NOT NULL CHECK (salary_amount > 0),
    valid_from DATE NOT NULL,
    valid_to DATE,
    is_current BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (valid_to IS NULL OR valid_to >= valid_from)
);

-- 7. Проекты
CREATE TABLE projects (
    project_id BIGSERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL UNIQUE
);

-- 8. Назначение сотрудников на проекты.
-- Нужна отдельная таблица, потому что один сотрудник может быть назначен на несколько проектов,
-- и на одном проекте могут работать несколько сотрудников.
CREATE TABLE employee_projects (
    employee_id BIGINT NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    project_id BIGINT NOT NULL REFERENCES projects(project_id) ON DELETE RESTRICT,
    assigned_at DATE,
    PRIMARY KEY (employee_id, project_id)
);

-- Индексы для ускорения выборок по внешним ключам
CREATE INDEX idx_employees_position_id ON employees(position_id);
CREATE INDEX idx_employees_department_id ON employees(department_id);
CREATE INDEX idx_employees_branch_id ON employees(branch_id);
CREATE INDEX idx_employee_salaries_employee_id ON employee_salaries(employee_id);
CREATE INDEX idx_employee_projects_project_id ON employee_projects(project_id);


---

## Команды для проверки через Docker

```bash
docker run --name pg-hw-12 \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=company_report_db \
  -p 5432:5432 \
  -d postgres:16
```

Затем выполнить скрипт:

```bash
docker cp company_report_schema.sql pg-hw-12:/company_report_schema.sql

docker exec -it pg-hw-12 psql -U postgres -d company_report_db -f /company_report_schema.sql
```

Проверить созданные таблицы:

```bash
docker exec -it pg-hw-12 psql -U postgres -d company_report_db -c "\dt"
```

---

## Выводы:

Исходный Excel-отчёт я разбил на нормализованную модель из восьми таблиц. Основная таблица — `employees`, в ней хранятся сотрудники и ссылки на должность, подразделение и филиал. Должности, типы подразделений, подразделения, филиалы и проекты вынесены в отдельные справочники, чтобы не дублировать данные. Оклад вынесен в отдельную таблицу `employee_salaries`, потому что в реальной системе он может изменяться и важно хранить историю. Связь сотрудников с проектами реализована через таблицу `employee_projects`, так как один сотрудник может участвовать в нескольких проектах, а один проект может включать нескольких сотрудников.


## Дополнительные задания (со звёздочкой*)
Эти задания дополнительные, то есть не обязательные к выполнению, и никак не повлияют на получение вами зачёта по этому домашнему заданию. Вы можете их выполнить, если хотите глубже шире разобраться в материале.


### Задание 2*

Перечислите, какие, на ваш взгляд, в этой денормализованной таблице встречаются функциональные зависимости и какие правила вывода нужно применить, чтобы нормализовать данные.
