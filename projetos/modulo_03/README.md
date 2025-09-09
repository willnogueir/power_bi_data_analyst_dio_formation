# 📑 Documentação do Projeto: Análise de Dados da Empresa com Power BI - Módulo 03

![Power BI](https://img.shields.io/badge/Power%20BI-FFB900?style=for-the-badge&logo=power-bi&logoColor=white)
![Business](https://img.shields.io/badge/Business%20Intelligence-Sales%20%26%20Revenue-blue?style=for-the-badge)
![PDF](https://img.shields.io/badge/Report-PDF-critical?style=for-the-badge)

---

## 1. Descrição do Desafio

Este projeto tem como objetivo a construção de um painel de análise de dados no Power BI, utilizando uma base de dados MySQL. O processo inclui a criação do banco de dados na nuvem, a integração entre as ferramentas e uma série de transformações para garantir a consistência e a qualidade dos dados.

### Objetivos do Projeto
* Criação de uma instância para MySQL na nuvem.
* Implementação do banco de dados com base no esquema fornecido.
* Integração do Power BI com o MySQL.
* Realização de processos de ETL (Extração, Transformação e Carga) para preparar os dados para análise.

---

## 2. Recursos e Tecnologias

* **Banco de Dados:** MySQL
* **Plataforma de Hosting:** Railway.app (alternativa ao Azure)
* **Ferramenta de BI:** Power BI Desktop
* **Drivers de Conexão:** MySQL ODBC Driver

### Esquema do Banco de Dados
O banco de dados foi criado a partir do seguinte script SQL:

```sql
CREATE SCHEMA IF NOT EXISTS azure_company;
USE azure_company;

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
```

## 3. Conexão com o Power BI

A conexão com o banco de dados MySQL foi realizada através de uma fonte de dados ODBC, já que a opção nativa do Power BI não permitiu a conexão devido à limitação de parâmetros e à falta de configuração SSL.
Para a conexão, foi utilizado o seguinte formato de string:

DRIVER={MySQL ODBC 9.4 Unicode Driver};SERVER=seu_host;PORT=porta_utilizada;DATABASE=banco_de_dados;

---

## 4. Processo de ETL (Extração, Transformação e Carga)

O processo de ETL foi realizado no Power Query do Power BI, seguindo as diretrizes do projeto.

### 4.1. Remoção de Colunas Desnecessárias
As seguintes colunas de relacionamento foram removidas para evitar redundância de dados, já que as tabelas relacionadas foram carregadas separadamente.

* **Tabela departament:** Apagadas colunas de relacionamento com "dept_locations", "employee" e "project".
* **Tabela dept_locations:** Apagada coluna de relacionamento "department".
* **Tabela dependent:** Apagada coluna de relacionamento "employee".
* **Tabela employee:** Apagadas colunas de relacionamento com "department", "dependent", "employee(Ssn)", "employee(Super_ssn)" e "works_on".
* **Tabela project:** Apagadas colunas de relacionamento com "project" e "works_on".
* **Tabela works_on:** Apagadas colunas de relacionamento com "employee" e "project".

### 4.2. Alteração de Tipos de Dados
O tipo de dados das chaves primárias e estrangeiras foi alterado de número inteiro para texto, por se tratar de uma boa prática em modelagem de dados para análise.

* **Tabela departament:** Coluna Dnumber alterada para texto.
* **Tabela employee:** Colunas Ssn e Dno alteradas para texto.
* **Tabela project:** Colunas Pnumber e Dnum alteradas para texto.
* **Tabela works_on:** Colunas Essn e Pno alteradas para texto.

### 4.3. Divisão e Mesclagem de Colunas
Endereço do Funcionário: A coluna Address da tabela employee foi dividida em quatro novas colunas (Número, Rua, Cidade, Estado) usando o delimitador -.

* **Nome Completo:** As colunas Fname e Lname da tabela employee foram mescladas para criar uma única coluna com o nome completo do colaborador.
* **Departamentos e Gerentes:** A tabela employee foi mesclada com a tabela departament para incluir o nome dos departamentos. A junção foi baseada no Dno.
* **Colaboradores e Gerentes:** Foi realizada uma junção Left Outer Join da tabela employee com ela mesma, utilizando o Super_ssn e Ssn para associar cada colaborador ao nome de seu gerente. A nova coluna com o nome do gerente foi renomeada para Manager.
* **Combinação Departamento-Local:** As colunas de Dname (nome do departamento) e Dlocation (localização) foram mescladas para criar uma chave única, auxiliando a modelagem em um esquema estrela.

### 4.4. Agrupamento e Agregação
Os dados da tabela employee foram agrupados pelo nome do gerente (Manager) para contar o número de colaboradores que cada gerente supervisiona.

### 4.5. Por que usar Mesclar e não Atribuir?
A escolha da operação de mesclagem se baseou na direção da combinação dos dados.
* **Mesclar (Merge Queries)** e **Combinar Colunas** são operações que combinam dados **horizontalmente**, adicionando colunas a uma tabela existente. Isso foi o que fizemos para enriquecer a tabela employee com dados de outras tabelas e para unir o Fname e o Lname.
* **Atribuir (Append Queries)** é uma operação que empilha dados **verticalmente**, adicionando linhas de uma tabela a outra que tenha a mesma estrutura. Não foi a operação adequada para este projeto, pois o objetivo era enriquecer as tabelas com novas colunas, e não adicionar novos registros.

---

## 5. Modelagem de Dados

As relações entre as tabelas foram criadas no modelo de dados do Power BI, utilizando as chaves primárias e estrangeiras definidas no script SQL original. Isso garante a correta interconexão das tabelas para a criação de visualizações dinâmicas e interativas.

---

## 6. Relatório

Ao final do processo de ETL e modelagem, foram criados visuais simples para exemplificar a análise de dados. O relatório tem como objetivo apresentar informações relevantes para a tomada de decisões, como o número de funcionários por gerente e a distribuição de colaboradores por departamento e localização.

O Relatório final pode ser acessado via Power BI Online Service através do link abaixo:
[Desafio de Projeto - Azure Company - Módulo 03](https://app.powerbi.com/groups/me/reports/6d3954b5-2468-4f8e-b5ec-6c5415a5c207/176374f352259e24fcdb?experience=power-bi)

---

## 📂 Estrutura do Repositório
```bash
modulo_03/
│── Desafio de Projeto - Azure Company - Módulo 03.pbix # Relatório editável no Power BI
│── Desafio de Projeto - Azure Company - Módulo 03.pdf # Versão estática para visualização
│── bd_azure_company_railwayapp.sql # Script para a criação do Banco de Dados no MySQL
│── bd_azure_company_railwayapp_adding_data.sql # Script para a ingestão dos dados na base criada no MySQL
│── README.md                # Documentação principal
