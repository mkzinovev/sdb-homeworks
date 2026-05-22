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
