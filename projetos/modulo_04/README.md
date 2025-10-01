# 📑 Documentação do Projeto: Análise de Docentes da Universidade com Banco de Dados em Star Schema - Módulo 04

![Power BI](https://img.shields.io/badge/Power%20BI-FFB900?style=for-the-badge&logo=power-bi&logoColor=white)
![Business](https://img.shields.io/badge/Business%20Intelligence-Sales%20%26%20Revenue-blue?style=for-the-badge)
![PDF](https://img.shields.io/badge/Report-PDF-critical?style=for-the-badge)

---

## 1. Introdução

Este documento detalha a implementação de um modelo de dados **Star Schema** para a análise das atribuições de docentes em uma instituição universitária. O projeto transforma um modelo relacional em um modelo dimensional, permitindo análises rápidas e intuitivas no Power BI.

O objetivo principal foi criar a **Tabela Fato** (`fato_professor`) e suas respectivas **Tabelas Dimensão**, simulando a realidade de um ambiente acadêmico com coerência lógica, incluindo restrições de tempo (como a data de contratação de um professor versus a data de início de uma disciplina).

---

## 2. Modelagem de Dados (Star Schema)

A arquitetura do projeto é baseada no modelo **Star Schema**, onde uma Tabela Fato central está ligada diretamente a todas as Tabelas Dimensão, otimizando o desempenho das consultas.

### 2.1. Tabelas Dimensão

As Tabelas Dimensão contêm os detalhes descritivos e foram preenchidas manualmente para estabelecer as entidades do contexto:

| Tabela Dimensão | Conteúdo | Chave Primária |
| :--- | :--- | :--- |
| `dim_professor` | Detalhes dos professores (nome, data de contratação). | `idProfessor` |
| `dim_departamento` | Unidades acadêmicas (nome, campus). | `idDepartamento` |
| `dim_disciplina` | Detalhes das disciplinas (nome, data de oferta). | `idDisciplina` |
| `dim_curso` | Cursos ofertados pela universidade (nome). | `idCurso` |
| `Data` | Tabela de suporte para inteligência de tempo (criada via DAX). | `Date` |

### 2.2. Tabela Fato (`fato_professor`)

A Tabela Fato é o coração do modelo. Ela armazena as chaves primárias das dimensões para criar o contexto de análise, além de uma métrica de tempo crucial.

| Coluna | Tipo | Descrição |
| :--- | :--- | :--- |
| `idFato` | `INT` | Chave primária artificial (Auto Incremento). |
| `idProfessor` | `INT` | Chave estrangeira para `dim_professor`. |
| `idDepartamento` | `INT` | Chave estrangeira para `dim_departamento`. |
| `idDisciplina` | `INT` | Chave estrangeira para `dim_disciplina`. |
| `idCurso` | `INT` | Chave estrangeira para `dim_curso`. |
| **`data_inicio_disciplina`** | `DATE` | **Métrica de Tempo**: Data em que o professor efetivamente começou a lecionar a disciplina. |

---

## 3. Implementação e Coerência Lógica (SQL)

A Tabela Fato foi populada com **200 registros** garantindo a coerência de dados através de um **Stored Procedure** no MySQL. Este procedimento foi necessário para realizar a inserção de forma iterativa e programática, respeitando as regras de negócio.

### 3.1. Regra de Negócio Central

A lógica de inserção na Tabela Fato foi construída em torno da seguinte regra de negócio fundamental para análise de tempo:

> A **`data_inicio_disciplina`** (o início da turma) deve ser sempre **maior ou igual** à **`data_contratacao`** do professor e à **`data_oferta_disciplina`** para evitar inconsistências.

### 3.2. Stored Procedure e Lógica de Data

O `Stored Procedure` (`PopularFatoProfessor`) utiliza a função `GREATEST` do MySQL para garantir que a `data_inicio_disciplina` seja lógica e simular um pequeno *delay* no início real da turma:

```sql
GREATEST(p.data_contratacao, di.data_oferta_disciplina) + INTERVAL FLOOR(RAND() * 60) DAY AS data_inicio_disciplina
```

* **`GREATEST(...)`**: Retorna a data mais recente entre a contratação do professor e a oferta da disciplina, estabelecendo a data mínima de início.
* **`+ INTERVAL FLOOR(RAND() * 60) DAY`**: Adiciona um número aleatório de dias (até 60) a essa data mínima, simulando o início real das atividades dentro de um prazo razoável.

---

## 4. Tabela de Dimensão de Datas (DAX)

A Tabela de Datas (`Data`) foi criada diretamente no Power BI usando a função DAX `CALENDARAUTO()` para cobrir de forma dinâmica o período de todas as datas existentes no modelo (`data_inicio_disciplina`, `data_contratacao`, etc.).

Esta tabela é o coração da **Time Intelligence** (Inteligência de Tempo).

### 4.1. Medida de Criação da Tabela

A tabela é gerada a partir da seguinte fórmula:

```dax
Tabela Data = CALENDARAUTO()
```

### 4.2. Colunas Essenciais

As seguintes colunas calculadas em DAX foram adicionadas à `Tabela Data` para permitir a segmentação e análise temporal em diferentes níveis (Ano, Trimestre, Mês):

| Coluna DAX | Fórmula | Propósito |
| :--- | :--- | :--- |
| `Ano` | `YEAR('Tabela Data'[Date])` | Agregação e filtragem anual. |
| `Mês` | `FORMAT('Tabela Data'[Date], "mmmm")` | Nome do mês para visualização amigável. |
| `Num Mês` | `MONTH('Tabela Data'[Date])` | Chave de ordenação numérica para que os meses sejam exibidos corretamente (Janeiro, Fevereiro, Março...) |
| `Trimestre` | `"Q" & QUARTER('Tabela Data'[Date])` | Agregação por trimestre. |
| `Dia da Semana` | `FORMAT('Tabela Data'[Date], "dddd")` | Agregação e filtragem por dia da semana. |

---

## 5. Medidas de Análise (DAX)

As métricas e indicadores-chave de desempenho (KPIs) do relatório foram construídos como **Medidas** em DAX, com o objetivo de contabilizar as atribuições de ensino na Tabela Fato.

### 5.1. Contagem Simples

Esta é a medida base para a contagem de todas as atribuições (cursos ministrados) em um determinado contexto (mês, professor, departamento, etc.).

```dax
Soma_Cursos = COUNT(fato_professor[idFato])
```

### 5.2. Somatória Cumulativa (Cursos Acumulados)
Esta medida utiliza a função de Time Intelligence (TOTALYTD) para calcular o número de cursos acumulado desde o início do ano até a data atual, o que é fundamental para o gráfico de área que totaliza os **200 registros** ao final do período.

```dax
Soma Cursos Acumulado = 
TOTALYTD(
    COUNT(fato_professor[idFato]),
    'Tabela Data'[Date]
)
```

---

## 6. Resultados e Relatório no Power BI

O modelo final de dados (conforme anexo de modelo) demonstra a estrutura Star Schema, com a Tabela Fato conectada a todas as dimensões de forma eficiente.

O relatório final (conforme anexo do relatório) apresenta os seguintes insights e resultados:

* **KPIs Superiores**: Confirmação das contagens totais no modelo (12 Professores, 6 Departamentos, 8 Disciplinas, 32 Cursos).
* **Cursos Ministrados por Mês e Departamento**: Visualização em barras empilhadas que mostra a distribuição das 200 atribuições por mês e a contribuição de cada Departamento.
* **Cursos Iniciados por Mês (Linha)**: Exibe a medida `Soma_Cursos` mostrando a variação das atribuições ao longo dos meses.
* **Turmas em Atividade por Ano e Trimestre (Acumulativo)**: Gráfico de área que utiliza a medida **`Soma Cursos Acumulado`**, mostrando o crescimento da base de 200 atribuições ao longo do tempo (Janeiro a Outubro de 2024).
* **Turmas Ativas por Professor**: Gráfico de barras que exibe a distribuição das 200 atribuições entre os 12 professores.
* **Disciplinas por Departamento (Radar)**: Gráfico de radar que mostra visualmente a predominância de Disciplinas por Departamento, confirmando a concentração em áreas como Ciência da Computação e Engenharia.

O Relatório final pode ser acessado via Power BI Online Service através do link abaixo:

[Desafio de Projeto - Universidade - Módulo 04](https://app.powerbi.com/groups/me/reports/b86348f8-8a2e-423c-9ce7-11f11f76ee90/268915dfbfb85af8d0ef?experience=power-bi)

### Próximos Passos:

O modelo está pronto para ser aprofundado com a inclusão de dados de alunos (`dim_aluno` e `Matriculado`), permitindo métricas de carga horária e desempenho.

---

## 📂 Estrutura do Repositório
```bash
modulo_04/
│── Desafio de Projeto - Universidade - Módulo 04.pbix # Relatório editável no Power BI
│── Desafio de Projeto - Universidade - Módulo 04.pdf # Versão estática para visualização
│── universidade_star_schema.sql # Script para a criação do Banco de Dados e ingestão dos dados no MySQL
│── README.md                # Documentação principal

