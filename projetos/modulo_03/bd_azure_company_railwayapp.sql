show databases;

-- Cria o banco de dados (esquema) se ele não existir
CREATE SCHEMA IF NOT EXISTS azure_company;
USE azure_company;

-- Consulta as restrições existentes (aqui é só para referência, não é necessário para a lógica)
SELECT * FROM information_schema.table_constraints
WHERE constraint_schema = 'azure_company';

-- Criação da tabela de funcionários
CREATE TABLE employee(
Fname VARCHAR(15) NOT NULL,
Minit CHAR,
Lname VARCHAR(15) NOT NULL,
Ssn CHAR(9) NOT NULL,
Bdate DATE,
Address VARCHAR(30),
Sex CHAR,
Salary DECIMAL(10,2),
Super_ssn CHAR(9),
Dno INT NOT NULL DEFAULT 1,
CONSTRAINT chk_salary_employee CHECK (Salary > 2000.0),
CONSTRAINT pk_employee PRIMARY KEY (Ssn)
);

-- Criação da tabela de departamentos
CREATE TABLE departament(
Dname VARCHAR(15) NOT NULL,
Dnumber INT NOT NULL,
Mgr_ssn CHAR(9) NOT NULL,
Mgr_start_date DATE,
Dept_create_date DATE,
CONSTRAINT chk_date_dept CHECK (Dept_create_date < Mgr_start_date),
CONSTRAINT pk_dept PRIMARY KEY (Dnumber),
CONSTRAINT unique_name_dept UNIQUE(Dname)
);

-- Criação da tabela de localizações de departamentos
CREATE TABLE dept_locations(
Dnumber INT NOT NULL,
Dlocation VARCHAR(15) NOT NULL,
CONSTRAINT pk_dept_locations PRIMARY KEY (Dnumber, Dlocation)
);

-- Criação da tabela de projetos
CREATE TABLE project(
Pname VARCHAR(15) NOT NULL,
Pnumber INT NOT NULL,
Plocation VARCHAR(15),
Dnum INT NOT NULL,
PRIMARY KEY (Pnumber),
CONSTRAINT unique_project UNIQUE (Pname)
);

-- Criação da tabela works_on (funcionários em projetos)
CREATE TABLE works_on(
Essn CHAR(9) NOT NULL,
Pno INT NOT NULL,
Hours DECIMAL(3,1) NOT NULL,
PRIMARY KEY (Essn, Pno)
);

-- Criação da tabela de dependentes
CREATE TABLE dependent(
Essn CHAR(9) NOT NULL,
Dependent_name VARCHAR(15) NOT NULL,
Sex CHAR,
Bdate DATE,
Relationship VARCHAR(8),
PRIMARY KEY (Essn, Dependent_name)
);

-- Adicionando as restrições de chave estrangeira após a criação das tabelas
ALTER TABLE employee
ADD CONSTRAINT fk_employee FOREIGN KEY(Super_ssn) REFERENCES employee(Ssn)
ON DELETE SET NULL
ON UPDATE CASCADE;

ALTER TABLE departament
ADD CONSTRAINT fk_dept FOREIGN KEY(Mgr_ssn) REFERENCES employee(Ssn);

ALTER TABLE dept_locations
ADD CONSTRAINT fk_dept_locations FOREIGN KEY (Dnumber) REFERENCES departament(Dnumber)
ON DELETE CASCADE
ON UPDATE CASCADE;

ALTER TABLE project
ADD CONSTRAINT fk_project FOREIGN KEY (Dnum) REFERENCES departament(Dnumber);

ALTER TABLE works_on
ADD CONSTRAINT fk_employee_works_on FOREIGN KEY (Essn) REFERENCES employee(Ssn),
ADD CONSTRAINT fk_project_works_on FOREIGN KEY (Pno) REFERENCES project(Pnumber);

ALTER TABLE dependent
ADD CONSTRAINT fk_dependent FOREIGN KEY (Essn) REFERENCES employee(Ssn);

-- Comandos de descrição das tabelas
DESCRIBE employee;
DESCRIBE departament;
DESCRIBE dept_locations;
DESCRIBE project;
DESCRIBE works_on;
DESCRIBE dependent;