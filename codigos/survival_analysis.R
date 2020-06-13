## Pacotes ####

options(scipen = 999)
library(ggplot2)
library("survival")
library("spduration")
library(stargazer)
library("simPH")

## Dados ####
library(readr)
DATASET <- read_csv("DATASET.csv")
View(DATASET)

## Criando a variável "inicio" ##
DATASET$inicio <- as.numeric(as.factor(DATASET$anos))

## Criando a variável 'fim' ##
DATASET$fim <- DATASET$inicio + 1

## Análise ####


modelo1 <- coxph(Surv(inicio, fim,inicio_projeto) ~ distancia_2palop + icrg_qog + regiao_proj_noano +
                   instituicoes_internacionais_proj_noano, data = DATASET)

coxph(Surv(inicio, fim,inicio_projeto) ~ distancia_2palop + icrg_qog + regiao_proj_noano +
        instituicoes_internacionais_proj_noano, data = DATASET)

## Resíduos de Schoenfeld ##
res.modelo1 <- cox.zph(modelo1, transform = "identity")
res.modelo1
par(mfrow=c(1,1))

plot(res.modelo1[1])
abline(h=modelo1$coefficients[1], lty=4, col=2)
plot(res.modelo1[2])
abline(h=modelo1$coefficients[2], lty=4, col=2)
plot(res.modelo1[3])
abline(h=modelo1$coefficients[3], lty=4, col=2)
plot(res.modelo1[4])
abline(h=modelo1$coefficients[4], lty=4, col=2)

## Tabela com coeficientes (Stargazer) ####

## Adaptando resultados do modelo de Cox para poder reproduzi-lo no stargazer ##
modelo2 <- modelo1
modelo2$coefficients <- exp(modelo2$coefficients)

stargazer(modelo1, modelo2, dep.var.labels=c(""),
          column.labels = c("Coefficient", "Exp(Coef)", "Coefficient", "Exp(Coef)"), column.separate = c(1,1,1,1),
          omit.stat = c("max.rsq", "wald"), intercept.bottom = FALSE, intercept.top=TRUE,
          type = "latex", style = "apsr")  ## Stargazer output ##
