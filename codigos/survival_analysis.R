#---------------------------
# ANALYITQUE CONSULTORIA
# Consultoria David Beltrao
#
# analise de sobrevivencia 
# @rodrigolins
# @claudiomonteiro
# Mar 2020
#-------------------------

# importar pacotes
#options(scipen = 999)
library(ggplot2)
library(survival)
library(spduration)
library(stargazer)
library(simPH)
library(readr)

# importar dados
DATASET <- read_csv("resultados/DATASET_V3.csv")

# criando a variavel "inicio" 
DATASET$inicio <- as.numeric(as.factor(DATASET$anos))

# criando a variavel 'fim'
DATASET$fim <- DATASET$inicio + 1

## analise sobrevivencia ##
modelo1 <- coxph(Surv(inicio, fim,inicio_projeto) ~ distancia_2palop + 
                                                    semelhanca_quali_institucional_icrg + 
                                                    regiao_proj_acumulados +
                                                    instituicoes_com_palop, 
                                                    data = DATASET)
coxph(Surv(inicio, fim,inicio_projeto) ~ distancia_2palop + 
        semelhanca_quali_institucional_icrg + 
        regiao_proj_acumulados +
        instituicoes_com_palop, 
      data = DATASET)

## Adaptando resultados do modelo de Cox para poder reproduzi-lo no stargazer ##
modelo2 <- modelo1
modelo2$coefficients <- exp(modelo2$coefficients)

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

stargazer(modelo1, modelo2, dep.var.labels=c(""),
          column.labels = c("Coefficient", "Exp(Coef)"), column.separate = c(1,1),
          omit.stat = c("max.rsq", "wald"), intercept.bottom = FALSE, intercept.top=TRUE,
          type = "latex", style = "apsr")  ## Stargazer output ##

