-- Criação do banco de dados (se não existir) e uso
CREATE SCHEMA IF NOT EXISTS universidade_star_schema;
USE universidade_star_schema;

-- Criação das tabelas (se não existirem)
CREATE TABLE IF NOT EXISTS dim_professor (
    idProfessor INT PRIMARY KEY,
    nome_professor VARCHAR(100),
    data_contratacao DATE
);

CREATE TABLE IF NOT EXISTS dim_departamento (
    idDepartamento INT PRIMARY KEY,
    nome_departamento VARCHAR(100),
    campus VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS dim_disciplina (
    idDisciplina INT PRIMARY KEY,
    nome_disciplina VARCHAR(100),
    data_oferta_disciplina DATE
);

CREATE TABLE IF NOT EXISTS dim_curso (
    idCurso INT PRIMARY KEY,
    nome_curso VARCHAR(100),
    data_oferta_curso DATE
);

-- Criação da Tabela Fato
CREATE TABLE IF NOT EXISTS fato_professor (
    idFato INT PRIMARY KEY AUTO_INCREMENT,
    idProfessor INT,
    idDepartamento INT,
    idDisciplina INT,
    idCurso INT,
    data_inicio_disciplina DATE,
    FOREIGN KEY (idProfessor) REFERENCES dim_professor(idProfessor),
    FOREIGN KEY (idDepartamento) REFERENCES dim_departamento(idDepartamento),
    FOREIGN KEY (idDisciplina) REFERENCES dim_disciplina(idDisciplina),
    FOREIGN KEY (idCurso) REFERENCES dim_curso(idCurso)
);

-- Inserção de dados nas tabelas de dimensão (garante que não haja duplicatas)
INSERT IGNORE INTO dim_professor (idProfessor, nome_professor, data_contratacao) VALUES
(1, 'João Silva', '2015-08-01'), (2, 'Maria Santos', '2018-02-15'), (3, 'Pedro Costa', '2019-07-20'),
(4, 'Ana Oliveira', '2016-11-10'), (5, 'Carlos Pereira', '2020-03-05'), (6, 'Juliana Almeida', '2017-09-22'),
(7, 'Ricardo Sousa', '2021-01-30'), (8, 'Fernanda Lima', '2014-05-18'), (9, 'Lucas Rocha', '2022-04-12'),
(10, 'Gabriela Fernandes', '2013-10-25'), (11, 'Rafaela Castro', '2019-12-01'), (12, 'Diego Martins', '2023-06-08');

INSERT IGNORE INTO dim_departamento (idDepartamento, nome_departamento, campus) VALUES
(1, 'Ciência da Computação', 'Campus Leste'), (2, 'Engenharia Elétrica', 'Campus Oeste'),
(3, 'Matemática', 'Campus Central'), (4, 'Física', 'Campus Leste'),
(5, 'Química', 'Campus Oeste'), (6, 'Biologia', 'Campus Central');

INSERT IGNORE INTO dim_disciplina (idDisciplina, nome_disciplina, data_oferta_disciplina) VALUES
(1, 'Algoritmos e Estruturas de Dados', '2024-03-01'), (2, 'Circuitos Digitais', '2024-03-01'),
(3, 'Cálculo I', '2024-03-01'), (4, 'Física Moderna', '2024-03-01'),
(5, 'Química Orgânica', '2024-08-01'), (6, 'Genética Molecular', '2024-08-01'),
(7, 'Banco de Dados', '2024-08-01'), (8, 'Redes de Computadores', '2024-08-01');

INSERT IGNORE INTO dim_curso (idCurso, nome_curso, data_oferta_curso) VALUES
(1, 'Bacharelado em Ciência da Computação', '2024-03-01'), (2, 'Engenharia de Software', '2024-03-01'),
(3, 'Análise e Desenvolvimento de Sistemas', '2024-03-01'), (4, 'Sistemas de Informação', '2024-03-01'),
(5, 'Engenharia Elétrica', '2024-03-01'), (6, 'Engenharia de Controle e Automação', '2024-03-01'),
(7, 'Técnico em Eletrônica', '2024-03-01'), (8, 'Automação Industrial', '2024-03-01'),
(9, 'Licenciatura em Matemática', '2024-08-01'), (10, 'Matemática Aplicada', '2024-08-01'),
(11, 'Estatística', '2024-08-01'), (12, 'Bacharelado em Astronomia', '2024-08-01'),
(13, 'Licenciatura em Física', '2024-08-01'), (14, 'Física Médica', '2024-08-01'),
(15, 'Engenharia Física', '2024-08-01'), (16, 'Física Computacional', '2024-08-01'),
(17, 'Bacharelado em Química', '2024-03-01'), (18, 'Química Industrial', '2024-03-01'),
(19, 'Licenciatura em Química', '2024-03-01'), (20, 'Química Ambiental', '2024-03-01'),
(21, 'Bacharelado em Ciências Biológicas', '2024-03-01'), (22, 'Licenciatura em Biologia', '2024-03-01'),
(23, 'Biomedicina', '2024-03-01'), (24, 'Ecologia', '2024-03-01'),
(25, 'Biologia Marinha', '2024-08-01'), (26, 'Química Forense', '2024-08-01'),
(27, 'Engenharia Civil', '2024-08-01'), (28, 'Engenharia Mecânica', '2024-08-01'),
(29, 'Arquitetura e Urbanismo', '2024-08-01'), (30, 'Administração', '2024-08-01'),
(31, 'Direito', '2024-08-01'), (32, 'Medicina', '2024-08-01');

---
### **Stored Procedure para População da Tabela Fato**

-- sql
DELIMITER //

CREATE PROCEDURE PopularFatoProfessor()
BEGIN
    DECLARE num_registros INT DEFAULT 0;
    
    -- Exclui registros existentes para garantir uma nova população
    TRUNCATE TABLE fato_professor;

    WHILE num_registros < 200 DO
        -- Combinações para Ciência da Computação (id 1)
        INSERT INTO fato_professor (idProfessor, idDepartamento, idDisciplina, idCurso, data_inicio_disciplina)
        SELECT p.idProfessor, d.idDepartamento, di.idDisciplina, c.idCurso, 
               GREATEST(p.data_contratacao, di.data_oferta_disciplina) + INTERVAL FLOOR(RAND() * 60) DAY AS data_inicio_disciplina
        FROM dim_professor p, dim_departamento d, dim_disciplina di, dim_curso c
        WHERE p.idProfessor IN (1, 2, 3) AND d.idDepartamento = 1 AND di.idDisciplina IN (1, 7, 8) AND c.idCurso IN (1, 2, 3, 4)
        ORDER BY RAND() LIMIT 1;

        -- Combinações para Engenharia Elétrica (id 2)
        INSERT INTO fato_professor (idProfessor, idDepartamento, idDisciplina, idCurso, data_inicio_disciplina)
        SELECT p.idProfessor, d.idDepartamento, di.idDisciplina, c.idCurso,
               GREATEST(p.data_contratacao, di.data_oferta_disciplina) + INTERVAL FLOOR(RAND() * 60) DAY AS data_inicio_disciplina
        FROM dim_professor p, dim_departamento d, dim_disciplina di, dim_curso c
        WHERE p.idProfessor IN (4, 5, 6) AND d.idDepartamento = 2 AND di.idDisciplina IN (2) AND c.idCurso IN (5, 6, 7, 8)
        ORDER BY RAND() LIMIT 1;

        -- Combinações para Matemática e Física (id 3 e 4)
        INSERT INTO fato_professor (idProfessor, idDepartamento, idDisciplina, idCurso, data_inicio_disciplina)
        SELECT p.idProfessor, d.idDepartamento, di.idDisciplina, c.idCurso,
               GREATEST(p.data_contratacao, di.data_oferta_disciplina) + INTERVAL FLOOR(RAND() * 60) DAY AS data_inicio_disciplina
        FROM dim_professor p, dim_departamento d, dim_disciplina di, dim_curso c
        WHERE p.idProfessor IN (7, 8, 9) AND d.idDepartamento IN (3, 4) AND di.idDisciplina IN (3, 4) AND c.idCurso IN (9, 10, 11, 12, 13, 14, 15, 16)
        ORDER BY RAND() LIMIT 1;

        -- Combinações para Química e Biologia (id 5 e 6)
        INSERT INTO fato_professor (idProfessor, idDepartamento, idDisciplina, idCurso, data_inicio_disciplina)
        SELECT p.idProfessor, d.idDepartamento, di.idDisciplina, c.idCurso,
               GREATEST(p.data_contratacao, di.data_oferta_disciplina) + INTERVAL FLOOR(RAND() * 60) DAY AS data_inicio_disciplina
        FROM dim_professor p, dim_departamento d, dim_disciplina di, dim_curso c
        WHERE p.idProfessor IN (10, 11, 12) AND d.idDepartamento IN (5, 6) AND di.idDisciplina IN (5, 6) AND c.idCurso IN (17, 18, 19, 20, 21, 22, 23, 24)
        ORDER BY RAND() LIMIT 1;
        
        SET num_registros = (SELECT COUNT(*) FROM fato_professor);
    END WHILE;
END //

DELIMITER ;

-- Chama o stored procedure para executar a população da tabela fato
CALL PopularFatoProfessor();

-- Opcional: Para remover o procedimento após o uso
-- DROP PROCEDURE PopularFatoProfessor;