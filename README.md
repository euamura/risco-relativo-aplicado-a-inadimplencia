# 📊 Projeto: Risco Relativo - Super Caja

Este projeto apresenta uma análise didática e prática sobre **risco relativo aplicado ao contexto bancário**, identificando quais perfis de clientes possuem **maior probabilidade de inadimplência**.  
Diferente do uso tradicional em epidemiologia, aqui o **risco relativo** mede **a chance de um cliente se tornar inadimplente em relação a outros grupos**, com base em variáveis financeiras e comportamentais.

---

## 💡 Contexto

Com a queda das taxas de juros, o banco fictício **Super Caja** viu crescer o número de pedidos de crédito.  
No entanto, o processo manual de análise de risco tornou-se **lento e ineficiente**, aumentando as chances de conceder crédito a maus pagadores.

Para resolver isso, o banco propôs **automatizar a análise de crédito** usando dados históricos de clientes e técnicas estatísticas — entre elas, o **risco relativo**.

---

## 🎯 Objetivo

Identificar **quais grupos de clientes têm maior risco de inadimplência**, com base em indicadores como:

- Idade  
- Salário mensal  
- Relação dívida/renda (*debt ratio*)  
- Uso de linhas de crédito sem garantia  
- Atrasos acima de 90 dias  

Com isso, o banco pode **criar regras de aprovação mais precisas** e **reduzir perdas financeiras**.

---

## 🧠 Metodologia

1. **Coleta e tratamento de dados**:  
   Importação, limpeza de valores nulos, tratamento de duplicados e padronização das variáveis.

2. **Análise exploratória (EDA)**:  
   Correlação entre variáveis, identificação de outliers e construção de quartis.

3. **Cálculo do Risco Relativo (RR)**:  
   Avaliação da taxa de inadimplência em grupos (quartis e decis) para encontrar padrões.

4. **Criação de Score de Crédito**:  
   A partir das variáveis mais relevantes (idade, salário, atrasos e uso de crédito), foi criado um **score de risco**.

5. **Segmentação de clientes**:  
   Classificação dos clientes como “**baixo risco**” ou “**alto risco**”, além da geração de uma **pontuação final** de 200 a 1000.

---

## 🧮 Interpretação do Risco Relativo

- **RR > 1** → maior risco de inadimplência  
- **RR < 1** → menor risco  
- **RR = 1** → risco equivalente

Exemplo:  
Um RR de **1.85** para o grupo “salário baixo” significa que esses clientes têm **85% mais chance** de inadimplir em comparação ao grupo de referência.

---

## 🛠️ Ferramentas Utilizadas

- **Google BigQuery (SQL)** → tratamento e análise dos dados  
- **Google Colab (Python)** → visualizações complementares  
- **Looker Studio** → dashboards interativos  
- **Google Sheets / Docs** → apoio e documentação

---

## 📁 Estrutura do Projeto

```
📦 risco-relativo-super-caja
 ┣ 📄 README.md
 ┣ 💾 risco_relativo.sql
 ┗ 📊 dashboard_looker.png
```

---

## 📈 Principais Insights

- Clientes **mais jovens** apresentaram maior taxa de inadimplência.  
- **Baixo salário** e **alta relação dívida/renda** aumentam consideravelmente o risco.  
- O **uso de linhas de crédito sem garantia** está fortemente associado ao não pagamento.  
- O **modelo final** consegue identificar grupos de risco com alta precisão, auxiliando o banco na decisão de crédito.

---

## 🔗 Referências e Recursos

- Dataset original (Google Drive): [super_caja dataset](https://drive.google.com/file/d/bc1qf92drq0wwm8w7rnw9d8p4wjvaut2csdd5sg2cx/view)
- Documento de apoio: [Plano de análise completo](https://docs.google.com/document/d/1q6UPnF3SMgHFcuAsy5DrRsiHGHBxb0qA1aut1Y9daEE/edit)

---

## ✨ Autor(a)

Projeto desenvolvido para fins educacionais e de portfólio.  
Demonstra a aplicação de técnicas de análise de dados e estatística ao **contexto financeiro**.  
