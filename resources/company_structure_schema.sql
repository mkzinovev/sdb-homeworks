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
