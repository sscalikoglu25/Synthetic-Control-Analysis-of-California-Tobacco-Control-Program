# Synthetic-Control-Analysis-of-California-Tobacco-Control-Program


## Project Overview
This project applies synthetic control methods to evaluate the causal impact of California’s 1988 tobacco control program on cigarette consumption. Using state-level panel data, the analysis constructs a counterfactual “Synthetic California” to estimate what cigarette sales would have been in the absence of the policy.

This project is based on the methodology introduced in Abadie, Diamond, and Hainmueller (2010) and was completed as part of coursework in Applied Economics and Modeling STRT601

## Objective
The goal of this analysis is to:
- Estimate the causal effect of a large-scale public health policy  
- Compare synthetic control methods to traditional approaches like difference-in-differences  
- Evaluate statistical significance using placebo-style inference  

## Dataset
- State-level panel data on cigarette consumption and prices  
- Time period includes pre- and post-policy years (centered around 1988 intervention)  
- Key variables:
  - Cigarette sales per capita  
  - Retail price of cigarettes  
  - State identifiers and year  

## Methodology

### 1. Exploratory Analysis
- Plotted cigarette consumption trends for California vs. national average  
- Assessed whether pre-treatment trends support a difference-in-differences approach  

### 2. Synthetic Control Construction
- Built a synthetic version of California using a weighted combination of other states  
- Matched on:
  - Average cigarette prices (1980–1988)  
  - Cigarette sales in 1980 and 1988  
  - Pre-treatment trends (1980–1988)  
- Implemented using the `Synth` package in R  

### 3. Model Evaluation
- Compared California, Synthetic California, and national averages  
- Examined weights assigned to donor states and predictor variables  

### 4. Treatment Effect Estimation
- Plotted:
  - Cigarette sales over time  
  - Gap between California and Synthetic California  
- Identified divergence after 1988 as the estimated treatment effect  

### 5. Inference
- Conducted placebo-style tests to assess statistical significance  
- Evaluated whether observed effects are distinguishable from random variation  

## Key Insights
- Synthetic control provides a credible counterfactual when parallel trends may not hold  
- Post-1988 divergence suggests a significant reduction in cigarette consumption due to the policy  
- The method allows for transparent interpretation through weights and pre-treatment fit  

## Tools & Technologies
- R (Synth package)  
- Data visualization and panel data analysis  

## File
- Problem set and full analysis: :contentReference[oaicite:0]{index=0}  

## Key Takeaway
This project demonstrates how synthetic control methods can be used to estimate causal effects in policy analysis, particularly when traditional approaches like difference-in-differences may not be appropriate.
