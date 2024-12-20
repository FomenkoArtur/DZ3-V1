-- Создание таблицы сотрудников
CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL
);

-- Создание таблицы проектов
CREATE TABLE projects (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    budget DECIMAL(10, 2) NOT NULL
);

-- Создание таблицы назначений сотрудников на проекты
CREATE TABLE employee_projects (
    employee_id INT REFERENCES employees(id) ON DELETE CASCADE,
    project_id INT REFERENCES projects(id) ON DELETE CASCADE,
    role_in_project VARCHAR(100) NOT NULL,
    PRIMARY KEY (employee_id, project_id)
);


--Реализация ролей и уровней доступа
CREATE ROLE admin;
CREATE ROLE manager;
CREATE ROLE analyst;

CREATE USER admin_user WITH PASSWORD 'admin_password';
CREATE USER manager_user WITH PASSWORD 'manager_password';
CREATE USER analyst_user WITH PASSWORD 'analyst_password';

GRANT admin TO admin_user;
GRANT manager TO manager_user;
GRANT analyst TO analyst_user;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;

GRANT SELECT ON employees TO manager;
GRANT SELECT ON projects TO manager;
GRANT INSERT ON employee_projects TO manager;

GRANT SELECT ON employees TO analyst;
GRANT SELECT ON projects TO analyst;
GRANT SELECT ON employee_projects TO analyst;



--Обновление бюджета проекта
CREATE OR REPLACE FUNCTION update_project_budget(project_id INT, new_budget DECIMAL) 
RETURNS VOID AS $$
BEGIN
    UPDATE projects SET budget = new_budget WHERE id = project_id;
END;
$$ LANGUAGE plpgsql;


--Добавление сотрудника в проект
CREATE OR REPLACE FUNCTION add_employee_to_project(employee_id INT, project_id INT, role VARCHAR) 
RETURNS VOID AS $$
BEGIN
    INSERT INTO employee_projects (employee_id, project_id, role_in_project) 
    VALUES (employee_id, project_id, role);
END;
$$ LANGUAGE plpgsql;


--Удаление сотрудника из проекта
CREATE OR REPLACE FUNCTION remove_employee_from_project(employee_id INT, project_id INT) 
RETURNS VOID AS $$
BEGIN
    DELETE FROM employee_projects 
    WHERE employee_id = employee_id AND project_id = project_id;
END;
$$ LANGUAGE plpgsql;


--Создание нового проекта
CREATE OR REPLACE FUNCTION create_project(name VARCHAR, budget DECIMAL, employee_ids INT[]) 
RETURNS VOID AS $$
DECLARE
    new_project_id INT;
    emp_id INT;  -- Объявляем переменную для использования в цикле
BEGIN
    -- Вставка нового проекта и получение его идентификатора
    INSERT INTO projects (name, budget) 
    VALUES (name, budget) RETURNING id INTO new_project_id;

    -- Проходим по массиву employee_ids
    FOREACH emp_id IN ARRAY employee_ids
    LOOP
        INSERT INTO employee_projects (employee_id, project_id, role_in_project) 
        VALUES (emp_id, new_project_id, 'Разработчик'); -- Замените роль, если необходимо
    END LOOP;
END;
$$ LANGUAGE plpgsql;



--Удаление проекта
CREATE OR REPLACE FUNCTION delete_project(project_id INT) 
RETURNS VOID AS $$
BEGIN
    DELETE FROM employee_projects WHERE project_id = project_id;
    DELETE FROM projects WHERE id = project_id;
END;
$$ LANGUAGE plpgsql;

