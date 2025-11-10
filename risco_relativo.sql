-- =============================================================
-- Projeto: Risco Relativo - Super Caja
-- Objetivo: Identificar perfis de inadimplência com base em indicadores financeiros
-- Linguagem: SQL (Google BigQuery)
-- =============================================================

-- =============================================================
-- 1. PROCESSAMENTO E PREPARAÇÃO DOS DADOS
-- =============================================================

-- Conectar e importar dados
-- Criação das tabelas principais no BigQuery
-- Tabelas: default, loans_detail, loans_outstanding, user_info


-- ===========
-- Identificar e tratar valores nulos
-- ===========


---planilha default
SELECT *
FROM `super_caja.default`
WHERE user_id IS NULL AND default_flag IS NULL;
----resultado da consulta: não há nulos na planilha default

---planilha loans_detail
SELECT * 
FROM `super_caja.loans_detail`
WHERE user_id IS NULL
OR more_90_days_overdue IS NULL
OR using_lines_not_secured_personal_assets IS NULL
OR number_times_delayed_payment_loan_30_59_days IS NULL
OR debt_ratio IS NULL
OR number_times_delayed_payment_loan_60_89_days IS NULL;
----resultado da consulta: não há nulos na planilha loans_detail

---planilha loans_outstanding
SELECT * 
FROM `super_caja.loans_outstanding`
WHERE loan_id IS NULL
OR user_id IS NULL
OR loan_type IS NULL;
----resultado da consulta: não há nulos na planilha loans_outstanding

---planilha user_info
SELECT * 
FROM `super_caja.user_info`
WHERE user_id IS NULL
OR age IS NULL
OR sex IS NULL
OR last_month_salary IS NULL
OR number_dependents IS NULL
----resultado da consulta: nas colunas last_month_salary e number_dependents há nulos. obs: os nulos de number_dependents são considerados que a pessoa não tem dependentes.

---contagem de nulos planilha user_info
SELECT
COUNT(*) AS nulls_count
FROM `super_caja.user_info`
WHERE last_month_salary IS NULL;
----resultado da consulta: há 7.199 nulos

CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS(
  SELECT 
    t.* EXCEPT (last_month_salary , number_dependents),
    COALESCE(number_dependents,0) AS number_dependents,
    COALESCE(last_month_salary,0) AS last_month_salary
  FROM `super_caja.super_caja_tabela_analise_completa` t
);

SELECT
  t.user_id,
  t.loan_id,
  t.default_flag
FROM `super_caja.super_caja_tabela_analise_completa` AS t
WHERE loan_id IS NULL AND  default_flag = 1;


-- ===========
-- Identificar e tratar valores duplicados
-- ===========

---planilha default
----criar tabela temporaria com contagem para identificar duplicados
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_default
  FROM `super_caja.default`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num_default = 1; 
----após confirmar a tabela_temp, usá-la para atualizar a planilha em questão removendo as duplicadas
  CREATE OR REPLACE TABLE `super_caja.default` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_default
  FROM `super_caja.default`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num_default = 1;

---planilha loans detail
----criar tabela temporaria com contagem para identificar duplicados
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_loans_detail
  FROM `super_caja.loans_detail`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num = 1;
----após confirmar a tabela_temp, usá-la para atualizar a planilha em questão removendo as duplicadas
  CREATE OR REPLACE TABLE `super_caja.loans_detail` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_numrow_num_loans_detail
  FROM `super_caja.loans_detail`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num_loans_detail = 1;

---planilha loans outstanding
----criar tabela temporaria com contagem para identificar duplicados
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_loans_outstanding
  FROM `super_caja.loans_outstanding`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num_loans_outstanding = 1;
----após confirmar a tabela_temp, usá-la para atualizar a planilha em questão removendo as duplicadas
  CREATE OR REPLACE TABLE `super_caja.loans_outstanding` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_loans_outstanding
  FROM `super_caja.loans_outstanding`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num_loans_outstanding = 1;

---planilha user_info
----criar tabela temporaria com contagem para identificar duplicados
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_user_info
  FROM `super_caja.user_info`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num_user_info = 1;
----após confirmar a tabela_temp, usá-la para atualizar a planilha em questão removendo as duplicadas
  CREATE OR REPLACE TABLE `super_caja.user_info` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY user_id) AS row_num_user_info
  FROM `super_caja.user_info`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num_user_info = 1;

---planilha loan_outstanding
---conferir duplicados da variavel loan_id
----criar tabela temporaria com contagem para identificar duplicados
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY loan_id ORDER BY loan_id) AS row_num_loan_id
  FROM `super_caja.loans_outstanding`
)
SELECT
  *
FROM
  tabela_temp
WHERE
  row_num_loan_id = 1;
----após confirmar a tabela_temp, usá-la para atualizar a planilha em questão removendo as duplicadas
  CREATE OR REPLACE TABLE `super_caja.loans_outstanding` AS
WITH tabela_temp AS (
  SELECT
    *,
    ROW_NUMBER() OVER (PARTITION BY loan_id ORDER BY loan_id) AS row_num_loan_id
FROM `super_caja.loans_outstanding`
)
SELECT
  * EXCEPT (row_num_loan_id)
FROM
  tabela_temp
WHERE
  row_num_loan_id = 1;

-- ===========
-- Identificar e gerenciar dados fora do escopo de análise
-- ===========

--- CORR entre variáveis: more_90_overdue e number_times_delayed_payment_loan_30_59_days
SELECT
  STDDEV_POP(more_90_days_overdue) AS desvio_padrao_more_90_days_overdue,
  STDDEV_POP(number_times_delayed_payment_loan_30_59_days) AS   desvio_padrao_number_times_delayed_payment_loan_30_59_days,
  CORR(more_90_days_overdue, number_times_delayed_payment_loan_30_59_days) AS correlacao_90_days_overdue_delayed_30_59_days
FROM 
  `super_caja.loans_detail`;
----resultado da consulta: há correlação de 0.98 entre as variáveis

--- CORR DE PEARSON entre variáveis: more_90_overdue e number_times_delayed_payment_loan_60_89_days
SELECT
  STDDEV_POP(more_90_days_overdue) AS desvio_padrao_more_90_days_overdue,
  STDDEV_POP(number_times_delayed_payment_loan_60_89_days) AS   desvio_padrao_number_times_delayed_payment_loan_60_89_days,
  CORR(more_90_days_overdue, number_times_delayed_payment_loan_60_89_days) AS correlacao_90_days_overdue_delayed_60_89_days
FROM 
  `super_caja.loans_detail`;
----resultado da consulta: há correlação de 0.99 entre as variáveis

--- CORR entre variáveis: debt_ratio e more_90_days_overdue
SELECT
  STDDEV(debt_ratio) AS desvio_padrao_debt_ratio,
  STDDEV(more_90_days_overdue) AS desvio_padrao_more_90_days_overdue,
  CORR(debt_ratio,more_90_days_overdue) AS corr_debt_ratio_more_90_days_overdue
FROM `super_caja.loans_detail`;
----resultado da consulta: correlação de  -0.008 entre as variáveis

---  CORR DE PEARSON entre variáveis: using_lines_not_secured_personal_assets e default_flag
SELECT
  STDDEV_POP(using_lines_not_secured_personal_assets) AS desvio_padrao_using_lines_not_secured_personal_assets,
  STDDEV_POP(default_flag) AS desvio_padrao_default,
  CORR(using_lines_not_secured_personal_assets, default_flag) AS corr_using_lines_not_secured_personal_assets_
FROM `super_caja.tabela_principal`;
----resultado da consulta: correlação de  -0.0029 entre as variáveis

--- CORR DE PEARSON entre variáveis: number_times_delayed_payment_loan_60_89_days e default_flag
SELECT
  STDDEV_POP(number_times_delayed_payment_loan_60_89_days) AS desvio_padrao_number_times_delayed_payment_loan_60_89_days,
  STDDEV_POP(default_flag) AS desvio_padrao_default_flag,
  CORR(number_times_delayed_payment_loan_60_89_days,default_flag) AS corr_number_times_delayed_payment_loan_60_89_day_default_flag
FROM `super_caja.tabela_principal`
----resultado da consulta: correlação de  0.27 entre as variáveis

-- ===========
-- Identificar e tratar dados discrepantes em variáveis categóricas
-- ===========

--Identificar e tratar dados discrepantes em variáveis categóricas
---Contagem de frequencias: default_flag
SELECT default_flag, COUNT(*) AS frequencia
FROM `super_caja.tabela_principal`
GROUP BY default_flag
ORDER BY frequencia ASC;
----resultado da consulta: defalt_flag 1 - 622 | defalt_flag 0 - 34953

---Contagem de frequencias: loan_type
SELECT loan_type, COUNT(*) AS frequencia
FROM `super_caja.tabela_principal`
GROUP BY loan_type
ORDER BY frequencia ASC;
----resultado da consulta: foi encontrado em uma das linhas REAL_STATE (em caixa alta).
----alterando linha em caixa alta:
SELECT
loan_id,
  LOWER(loan_type) AS loan_type
FROM `super_caja.tabela_principal`;
----alterando tabela principal
CREATE OR REPLACE TABLE `super_caja.tabela_principal` AS
SELECT 
  t1.* EXCEPT(loan_type),
  t2.* EXCEPT (loan_id)
FROM `super_caja.tabela_principal` AS t1
LEFT JOIN `super_caja.loan_type_tratado` AS t2
ON t1.loan_id = t2.loan_id;
----após atualizar a tabela. Refazer contagem.
----resultado da consulta de contagem: other - 13.119 | real estate - 22.456

---count de loan_type e default_flag
SELECT loan_type, default_flag, COUNT(*) AS frequencia
FROM `super_caja.tabela_principal`
GROUP BY loan_type, default_flag
ORDER BY loan_type, default_flag;
----resultado da consulta: loan_type other sem default_flag - 12.791 | loan_type other com default_flag - 328 | real estate sem default_flag 22.162 | real estate com default_flag 294

-- ===========
-- Identificar e tratar dados discrepantes em variáveis numéricas
-- ===========

--Identificar e tratar dados discrepantes em variáveis numéricas
---selecionando dados não nulos tabela user_info
SELECT 
  last_month_salary
FROM `super_caja.user_info`
WHERE last_month_salary IS NOT NULL;

---selecionando user_id com valores discrepantes tabela user_info
SELECT * 
FROM   `super_caja.user_info`
WHERE last_month_salary = 1.00E+05
----user_: 4931 | 9466 tem formato de número científico. Ao transformar em inteiro recebem o valor de 100.000


---reconhecendo outliers na variável salario da tabela user_info
SELECT *
FROM`super_caja.user_info`
WHERE last_month_salary > 100000;

--Identificar e tratar dados discrepantes em variáveis numéricas
---selecionando dados não nulos tabela user_info
SELECT 
  last_month_salary
FROM `super_caja.user_info`
WHERE last_month_salary IS NOT NULL;

---selecionando user_id com valores discrepantes tabela user_info
SELECT * 
FROM   `super_caja.user_info`
WHERE last_month_salary = 1.00E+05
----user_: 4931 | 9466 tem formato de número científico. Ao transformar em inteiro recebem o valor de 100.000


---reconhecendo outliers na variável salario da tabela user_info
SELECT *
FROM`super_caja.user_info`
WHERE last_month_salary > 100000;

-- ===========
-- Verificar e alterar o tipo de dados
-- ===========

--Verificar e alterar o tipo de dados

-- alterando tipo de dados planilha user_info
CREATE OR REPLACE TABLE `super_caja.user_info` AS
SELECT 
  t1.* EXCEPT(last_month_salary, last_month_salary_int),
  CAST(last_month_salary AS INT64) AS last_month_salary
FROM `super_caja.user_info` t1;

--convertendo nomes da variável loan_type com lower
CREATE OR REPLACE TABLE `super_caja.loans_outstanding` AS
SELECT
  loan_id,
  user_id,
  CASE
    WHEN LOWER(loan_type) IN ('real estate', 'real estate') THEN 'real estate'
    WHEN LOWER(loan_type) IN ('other', 'other', 'others') THEN 'other'
    ELSE loan_type
  END AS loan_type_corrigido
FROM
`super_caja.loans_outstanding`;


-- ===========
-- Criar novas variáveis I
-- ===========

--criar novas variáveis

--contagem de loan_type por categoria
SELECT
  loan_type_corrigido,
  COUNT(loan_type_corrigido) num_loans_category
FROM `super_caja.loans_outstanding`
GROUP BY loan_type_corrigido;

---criar variaveis: total_loan(mostrar soma de loans) | num_real_estate (quantidade de loans de imóveis) | num_outher (soma de outros emprestimos)
SELECT
  user_id,
  COUNT(DISTINCT loan_id) AS total_loan,
  SUM(CASE WHEN loan_type_corrigido = 'real estate' THEN 1 ELSE 0 END) AS num_real_estate,
  SUM (CASE WHEN loan_type_corrigido = 'other' THEN 1 ELSE 0 END) AS num_other,
FROM `super_caja.loans_outstanding`
GROUP BY user_id;

-- ===========
-- Unir tabelas / Criar tabelas auxiliares
-- ===========
-- Unir tabelas
CREATE OR REPLACE TABLE `super_caja.tabela_principal` AS
SELECT
  t1.* EXCEPT(sex),
  t2.loan_id,
  t2.loan_type_corrigido AS loan_type,
  t3.default_flag,
  t4.* EXCEPT(user_id, row_num),
  t5.* EXCEPT(user_id)

FROM `super_caja.user_info` AS t1
LEFT JOIN `super_caja.loans_outstanding` AS t2 ON t1.user_id = t2.user_id
LEFT JOIN `super_caja.default` AS t3 ON t3.user_id = t1.user_id
LEFT JOIN `super_caja.loans_detail` AS t4 ON t4.user_id = t1.user_id
LEFT JOIN `super_caja.loans_count` AS t5 ON t5.user_id = t1.user_id

-- Criar tabelas auxiliares

--Construir tabelas auxiliares

---last_month_salary nulls:
SELECT *
FROM `super_caja.tabela_principal`
WHERE last_month_salary IS NULL;
----salvar como view

--Construir tabelas auxiliares

---loan_id nulls:
SELECT * 
FROM `super_caja.tabela_principal`
WHERE loan_id IS NULL;
----salvar como view

--Construir tabelas auxiliares

---default_flag = 1:
SELECT * 
FROM `super_caja.tabela_principal`
WHERE default_flag = 1;
----salvar como view

-- =============================================================
-- 2. ANÁLISE EXPLORATÓRIA (EDA)
-- =============================================================

-- selecionar variaveis importantes
WITH ntile_vars AS (
  SELECT
    user_id,
    default_flag,
    debt_ratio,
    last_month_salary,
    age,
    using_lines_not_secured_personal_assets,
    more_90_days_overdue,
    total_loan,
    -- criar quartil para variaveis importantes 
    NTILE(4) OVER (ORDER BY debt_ratio) AS debt_ratio_ntile,
    NTILE(4) OVER (ORDER BY last_month_salary) AS last_month_salary_ntile,
    NTILE(4) OVER (ORDER BY age) AS age_ntile,
    NTILE(4) OVER (ORDER BY using_lines_not_secured_personal_assets) AS using_lines_ntile,
    NTILE(4) OVER (ORDER BY more_90_days_overdue) AS more_90_days_overdue_ntile,
    NTILE(4) OVER (ORDER BY total_loan) AS total_loan_ntile
  FROM `super_caja.super_caja_tabela_analise_completa`
)
  SELECT * FROM ntile_vars

--Calcular correlaçaõ de pearson de variáveis numéricas

---corr entre: more_90_days_overdue e default_flag
SELECT(
  CORR(default_flag,more_90_days_overdue)
)
FROM `super_caja.tabela_principal`;
----resultado corr: 0.30

---corr entre: number_times_delayed_payment_loan_30_59_days e default_flag
SELECT(
  CORR(t1.default_flag, t1.number_times_delayed_payment_loan_30_59_days)
)
FROM `super_caja.tabela_principal` AS t1;
----resultado corr: 0.29

---corr entre: number_times_delayed_payment_loan_60_89_days e default flag
SELECT(
    CORR(t1.default_flag, t1.number_times_delayed_payment_loan_60_89_days)
)
FROM `super_caja.tabela_principal` AS t1;
----resultado corr: 0.27

---corr entre last_month_salary e default_flag
SELECT
  CORR(last_month_salary, default_flag)
FROM `super_caja.tabela_principal` AS t1;
----resultado corr: -0.02

---corr entre default_flag e total_loan
SELECT
  CORR(default_flag, total_loan)
FROM `super_caja.tabela_principal` AS t1;
----resultado corr: -0.04

---corr entre last_month_salary e total_loan
SELECT
  CORR(last_month_salary, total_loan)
FROM `super_caja.tabela_principal` AS t1;
----resultado corr: -0.10

-- =============================================================
-- 3. CÁLCULO DO RISCO RELATIVO
-- =============================================================

-- RISCO RELATIVO COM QUARTIL

--- *debt_ratio*
-- Calcular quartil
WITH ntile_debt_ratio AS (
  SELECT
    user_id,
    default_flag,
    debt_ratio,
    NTILE(4) OVER (ORDER BY debt_ratio DESC) AS debt_ratio_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),

-- Unir quartil à tabela
data_with_ntile AS (
  SELECT
    u.*,
    n.debt_ratio_ntile
  FROM
    `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN
    ntile_debt_ratio AS n
    ON
    u.user_id = n.user_id
),

-- Selecionar variáveis para calcular risco relativo
risk_relative AS (
  SELECT
    debt_ratio_ntile, -- coluna de ntile
    COUNT(*) AS total_customers,  -- count de total user_id
    SUM(default_flag) AS total_default, -- soma de inadimplentes 
    AVG(default_flag) AS default_rate -- média de inadimplentes
  FROM
    data_with_ntile
  GROUP BY
    debt_ratio_ntile
)

-- Cálculo do risco relativo
SELECT
  debt_ratio_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM
  risk_relative
ORDER BY
  debt_ratio_ntile;
----- resultado da consula: quartil 1 e 2 tem RR > 1
---------------------------------------

--- *last_month_salary*
-- Calcular quartil
WITH ntile_last_month_salary AS (
  SELECT
    user_id,
    default_flag,
    last_month_salary,
    NTILE(4) OVER (ORDER BY last_month_salary) AS last_month_salary_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),

-- Unir quartil à tabela
data_with_ntile AS (
  SELECT
    u.*,
    n.last_month_salary_ntile
  FROM
    `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN
    ntile_last_month_salary AS n
    ON
    u.user_id = n.user_id
),

-- Selecionar variáveis para calcular risco relativo
risk_relative AS (
  SELECT
    last_month_salary_ntile, -- coluna de ntile
    COUNT(*) AS total_customers,  -- count de total user_id
    SUM(default_flag) AS total_default, -- soma de inadimplentes 
    AVG(default_flag) AS default_rate -- média de inadimplentes
  FROM
    data_with_ntile
  GROUP BY
    last_month_salary_ntile
)
-- Cálculo do risco relativo
SELECT
  last_month_salary_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM
  risk_relative
ORDER BY
  last_month_salary_ntile;
----- resultado da consula: quartil 1 e 2 tem RR > 1

-----------------------------------------------

--- *age*
-- Calcular quartil
WITH ntile_age AS (
  SELECT
    user_id,
    default_flag,
    age,
    NTILE(4) OVER (ORDER BY age) AS age_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),

-- Unir quartil à tabela
data_with_ntile AS (
  SELECT
    u.*,
    n.age_ntile
  FROM
    `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN
    ntile_age AS n
    ON
    u.user_id = n.user_id
),

-- Selecionar variáveis para calcular risco relativo
risk_relative AS (
  SELECT
    age_ntile, -- coluna de ntile
    COUNT(*) AS total_customers,  -- count de total user_id
    SUM(default_flag) AS total_default, -- soma de inadimplentes 
    AVG(default_flag) AS default_rate -- média de inadimplentes
  FROM
    data_with_ntile
  GROUP BY
    age_ntile
)
-- Cálculo do risco relativo
SELECT
  age_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM
  risk_relative
ORDER BY
  age_ntile;
----- resultado da consula: quartil 1 e 2 tem RR > 1
--------------------------------------------------

--- *using_lines_not_secured_personal_assets*
-- Calcular quartil
WITH ntile_using_lines_not_secured_personal_assets AS (
  SELECT
    user_id,
    default_flag,
    using_lines_not_secured_personal_assets,
    NTILE(4) OVER (ORDER BY using_lines_not_secured_personal_assets DESC) AS using_lines_not_secured_personal_assets_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),

-- Unir quartil à tabela
data_with_ntile AS (
  SELECT
    u.*,
    n.using_lines_not_secured_personal_assets_ntile
  FROM
    `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN
    ntile_using_lines_not_secured_personal_assets AS n
    ON
    u.user_id = n.user_id
),

-- Selecionar variáveis para calcular risco relativo
risk_relative AS (
  SELECT
    using_lines_not_secured_personal_assets_ntile, -- coluna de ntile
    COUNT(*) AS total_customers,  -- count de total user_id
    SUM(default_flag) AS total_default, -- soma de inadimplentes 
    AVG(default_flag) AS default_rate -- média de inadimplentes
  FROM
    data_with_ntile
  GROUP BY
    using_lines_not_secured_personal_assets_ntile
)
-- Cálculo do risco relativo
SELECT
  using_lines_not_secured_personal_assets_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM
  risk_relative
ORDER BY
  using_lines_not_secured_personal_assets_ntile;
----- resultado da consula: quartil 1 tem RR > 1

-------------------------------------------------

--- *total_loan*
-- Calcular quartil
WITH ntile_total_loan AS (
  SELECT
    user_id,
    default_flag,
    total_loan,
    NTILE(4) OVER (ORDER BY total_loan) AS total_loan_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),

-- Unir quartil à tabela
data_with_ntile AS (
  SELECT
    u.*,
    n.total_loan_ntile
  FROM
    `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN
    ntile_total_loan AS n
    ON
    u.user_id = n.user_id
),

-- Selecionar variáveis para calcular risco relativo
risk_relative AS (
  SELECT
    total_loan_ntile, -- coluna de ntile
    COUNT(*) AS total_customers,  -- count de total user_id
    SUM(default_flag) AS total_default, -- soma de inadimplentes 
    AVG(default_flag) AS default_rate -- média de inadimplentes
  FROM
    data_with_ntile
  GROUP BY
    total_loan_ntile
)
-- Cálculo do risco relativo
SELECT
  total_loan_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM
  risk_relative
ORDER BY
  total_loan_ntile;
----- resultado da consula: quartil 1 tem RR > 1

-------------------------------------------------
--- *more_90_days_overdue*
-- Calcular quartil
WITH ntile_more_90_days_overdue AS (
  SELECT
    user_id,
    default_flag,
    more_90_days_overdue,
    NTILE(4) OVER (ORDER BY more_90_days_overdue DESC) AS more_90_days_overdue_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),

-- Unir quartil à tabela
data_with_ntile AS (
  SELECT
    u.*,
    n.more_90_days_overdue_ntile
  FROM
    `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN
    ntile_more_90_days_overdue AS n
    ON
    u.user_id = n.user_id
),

-- Selecionar variáveis para calcular risco relativo
risk_relative AS (
  SELECT
    more_90_days_overdue_ntile, -- coluna de ntile
    COUNT(*) AS total_customers,  -- count de total user_id
    SUM(default_flag) AS total_default, -- soma de inadimplentes 
    AVG(default_flag) AS default_rate -- média de inadimplentes
  FROM
    data_with_ntile
  GROUP BY
    more_90_days_overdue_ntile
)
-- Cálculo do risco relativo
SELECT
  more_90_days_overdue_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM
  risk_relative
ORDER BY
  more_90_days_overdue_ntile;
----- resultado da consula: quartil 1 tem RR > 1

---------------------------------------

--- *quartil ordenado por varias variaveis ordenadas pela quantidade de defaults com RR superior a 1*
--- *using_lines_not_secured_personal_assets, more_90_days_overdue, age, last_month_salary, debt_ratio*
-- Calcular quartil
WITH ntile_geral AS (
  SELECT
    user_id,
    default_flag,
    using_lines_not_secured_personal_assets,
    more_90_days_overdue,
    age,
    last_month_salary,
    debt_ratio,
    NTILE(4) OVER (ORDER BY using_lines_not_secured_personal_assets DESC, more_90_days_overdue DESC, age, last_month_salary, debt_ratio DESC) AS geral_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),

-- Unir quartil à tabela
data_with_ntile AS (
  SELECT
    u.*,
    n.geral_ntile
  FROM
    `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN
    ntile_geral AS n
    ON
    u.user_id = n.user_id
),

-- Selecionar variáveis para calcular risco relativo
risk_relative AS (
  SELECT
    geral_ntile, -- coluna de ntile
    COUNT(*) AS total_customers,  -- count de total user_id
    SUM(default_flag) AS total_default, -- soma de inadimplentes 
    AVG(default_flag) AS default_rate -- média de inadimplentes
  FROM
    data_with_ntile
  GROUP BY
    geral_ntile
)
-- Cálculo do risco relativo
SELECT
  geral_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM
  risk_relative
ORDER BY
  geral_ntile;
----- resultado da consula: quartil 1 tem RR > 1


-------------------------------------------------

--- *decil ordenado por varias variaveis ordenadas pela quantidade de defaults com RR superior a 1*
--- *using_lines_not_secured_personal_assets, more_90_days_overdue, age, last_month_salary, debt_ratio*
-- Calcular quartil
WITH ntile_geral AS (
  SELECT
    user_id,
    default_flag,
    using_lines_not_secured_personal_assets,
    more_90_days_overdue,
    age,
    last_month_salary,
    debt_ratio,
    NTILE(10) OVER (ORDER BY using_lines_not_secured_personal_assets DESC, more_90_days_overdue DESC, age, last_month_salary, debt_ratio DESC) AS geral_ntile
  FROM `super_caja.tabela_de_analise_super_caja`
),

-- Unir quartil à tabela
data_with_ntile AS (
  SELECT
    u.*,
    n.geral_ntile
  FROM
    `super_caja.tabela_de_analise_super_caja` AS u
  LEFT JOIN
    ntile_geral AS n
    ON
    u.user_id = n.user_id
),

-- Selecionar variáveis para calcular risco relativo
risk_relative AS (
  SELECT
    geral_ntile, -- coluna de ntile
    COUNT(*) AS total_customers,  -- count de total user_id
    SUM(default_flag) AS total_default, -- soma de inadimplentes 
    AVG(default_flag) AS default_rate -- média de inadimplentes
  FROM
    data_with_ntile
  GROUP BY
    geral_ntile
)
-- Cálculo do risco relativo
SELECT
  geral_ntile,
  total_customers,
  total_default,
  default_rate,
  default_rate / (SELECT AVG(default_flag) FROM data_with_ntile) AS risk_relative
FROM
  risk_relative
ORDER BY
  geral_ntile;
----- resultado da consula: decil  1 e 2 tem RR > 1


-- =============================================================
-- 4. CLASSIFICAÇÃO E SEGMENTAÇÃO DE CLIENTES
-- =============================================================
-- classificando clientes em bom ou mal pagador -- 
SELECT
  t.*,
  CASE WHEN age_ntile <= 2 THEN 'mau pagador' ELSE 'bom pagador' END AS age_class,
  CASE WHEN using_lines_ntile = 4 THEN 'mau pagador' ELSE 'bom pagador' END AS using_lines_class,
  CASE WHEN more_90_days_overdue_ntile = 4 THEN 'mau pagador' ELSE 'bom pagador' END AS overdue_class,
  CASE WHEN last_month_salary_ntile <= 2 THEN 'mau pagador' ELSE 'bom pagador' END AS salary_class
FROM `super_caja.super_caja_tabela_analise_completa` AS t

-- atualizar tabela de analise completa com as novas colunas --
CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS
  SELECT
    t.*,
    CASE WHEN age_ntile <= 2 THEN 'mau pagador' ELSE 'bom pagador' END AS age_class,
    CASE WHEN using_lines_ntile = 4 THEN 'mau pagador' ELSE 'bom pagador' END AS using_lines_class,
    CASE WHEN more_90_days_overdue_ntile = 4 THEN 'mau pagador' ELSE 'bom pagador' END AS overdue_class,
    CASE WHEN last_month_salary_ntile <= 2 THEN 'mau pagador' ELSE 'bom pagador' END AS salary_class
  FROM `super_caja.super_caja_tabela_analise_completa` AS t

  
--- CRIAR VARIAVEIS DUMMY
-- Criar variáveis dummy para cada classificação
 WITH data_with_dummies AS (
  SELECT
    d.*,
    CASE WHEN age_class = 'mau pagador' THEN 1 ELSE 0 END AS age_dummy,
    CASE WHEN salary_class = 'mau pagador' THEN 1 ELSE 0 END AS salary_dummy,
    CASE WHEN overdue_class = 'mau pagador' THEN 1 ELSE 0 END AS overdue_dummy,
    CASE WHEN using_lines_class = 'mau pagador' THEN 1 ELSE 0 END AS using_line_dummy
  FROM `super_caja.super_caja_tabela_analise_completa` AS d
)
SELECT * FROM data_with_dummies;

-- Atualizar tabela com variaveis dummies
CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS
  SELECT
    d.*,
    CASE WHEN age_class = 'mau pagador' THEN 1 ELSE 0 END AS age_dummy,
    CASE WHEN salary_class = 'mau pagador' THEN 1 ELSE 0 END AS salary_dummy,
    CASE WHEN overdue_class = 'mau pagador' THEN 1 ELSE 0 END AS overdue_dummy,
    CASE WHEN using_lines_class = 'mau pagador' THEN 1 ELSE 0 END AS using_line_dummy
  FROM `super_caja.super_caja_tabela_analise_completa` AS d

--------------------------------------------------------
--- CALCULAR SCORE

-- Calcular score a partir das variaveis dummies
WITH score_dummies AS(
  SELECT
    t.*,
    (age_dummy + salary_dummy + overdue_dummy + using_line_dummy) AS score
FROM `super_caja.super_caja_tabela_analise_completa` AS t
)
SELECT * FROM score_dummies


-- Atualizar tabela com a coluna de score
CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS
  SELECT
    t.*,
    (age_dummy + salary_dummy + overdue_dummy + using_line_dummy) AS score
  FROM `super_caja.super_caja_tabela_analise_completa` AS t


---- segmentação de clientes

-- analisando distribuição de score
WITH score_distribution AS (
  SELECT
    score,
    COUNT(*) AS total_clients,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) AS total_defaulters,
    SUM(CASE WHEN default_flag = 1 THEN 1 ELSE 0 END) / COUNT(*) AS default_rate,
  FROM `super_caja.super_caja_tabela_analise_completa`
  GROUP BY score
)
SELECT * FROM score_distribution
ORDER BY score;

-- segmentando os clientes em alto e baixo risco com corte score 4
WITH segmentacao AS(
  SELECT
    t.*,
    CASE WHEN score =4 THEN 1 ELSE 0 END AS segmentacao_dummy
  FROM `super_caja.supercaja_quartile_dummy_score` AS t
),
------SELECT * FROM segmentacao;

classificacao AS(
  SELECT
  *,
  CASE WHEN segmentacao_dummy = 0 THEN 'baixo risco' ELSE 'alto risco' END AS classificacao
  FROM segmentacao
),
------SELECT * FROM classificacao;

-- CTE para calcular a matriz de confusão
matriz_confusao AS (
  SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN default_flag = 1 AND segmentacao_dummy = 1 THEN 1 ELSE 0 END) AS true_positives,
    SUM(CASE WHEN default_flag = 0 AND segmentacao_dummy = 1 THEN 1 ELSE 0 END) AS false_positives,
    SUM(CASE WHEN default_flag = 1 AND segmentacao_dummy = 0 THEN 1 ELSE 0 END) AS false_negatives,
    SUM(CASE WHEN default_flag = 0 AND segmentacao_dummy = 0 THEN 1 ELSE 0 END) AS true_negatives
  FROM classificacao
)

-- Selecionar a matriz de confusão
SELECT
  true_positives,
  false_positives,
  false_negatives,
  true_negatives
FROM matriz_confusao;

-- criação de pontuação positiva a partir do score

SELECT 
  t.*,
  CASE 
    WHEN score = 0 THEN 1000 
    WHEN score = 1 THEN 800 
    WHEN score = 2 THEN 600 
    WHEN score = 3 THEN 400 
    ELSE 200 
  END AS pontuacao
FROM 
  `super_caja.super_caja_tabela_analise_completa` AS t


-- atualizando tabela com a nova coluna

CREATE OR REPLACE TABLE `super_caja.super_caja_tabela_analise_completa` AS
  SELECT 
  t.*,
  CASE 
    WHEN score = 0 THEN 1000 
    WHEN score = 1 THEN 800 
    WHEN score = 2 THEN 600 
    WHEN score = 3 THEN 400 
    ELSE 200 
  END AS pontuacao
FROM 
  `super_caja.super_caja_tabela_analise_completa` AS t


