#---------------------------
# ANALYITQUE CONSULTORIA
# Consultoria David Beltrao
#
# analise de sobrevivencia 
# @rodrigolins
# @claudiomonteiro
# Mar 2020
#-------------------------
# https://rpubs.com/preimann/553549


#=====================
# preprocessar dados
#====================

# importar pacotes
library(readr)
library(dplyr)

# importar dados
data <- data.frame(read_csv("resultados/preprocessed_data/DATASET_V3.csv"))

# contagem de anos ate primeiro projeto, por pais
data_qca = data[data$inicio_projeto == 1,][,c(2:5,7,9,12,14,16)]

# funcao para range max e min
range01 <- function(x){(x-min(x))/(max(x)-min(x))}

# range para variaveis independentes
data_qca$regiao_proj_acumulados = range01(data_qca$regiao_proj_acumulados)
data_qca$distancia_2palop = range01(data_qca$distancia_2palop)
data_qca$semelhanca_quali_institucional_icrg = range01(data_qca$semelhanca_quali_institucional_icrg)
data_qca$instituicoes_com_palop = range01(data_qca$instituicoes_com_palop)

# criar variavel dependente
data_qca$anos_contagem_x = range01(data_qca$anos_contagem)
data_qca = mutate(data_qca, anos_surv = ifelse(anos_contagem_x >= 0.75, 1, 0))


#=====================
# QCA
#====================

library(QCA)
library(SetMethods)

# FUZZYFICATION
#mydata$MYFUZZYSET <- round(calibrate(mydata$rawvar, type = "fuzzy", thresholds = "e=300, c=600, i=800", logistic=TRUE), digits=2)
#mydata$MYFUZZYSET


# NECESSITY

conds <- subset(data_qca, select = c("regiao_proj_acumulados", 
                                   "distancia_2palop", 
                                   "semelhanca_quali_institucional_icrg", 
                                   "instituicoes_com_palop"))

pof(conds, 'anos_surv', data_qca, relation = "nec")


# SUFICIENCY

QCAfit(conds, 
       data_qca$anos_surv, 
       cond.lab= c("regiao_proj_acumulados", 
                    "distancia_2palop", 
                    "semelhanca_quali_institucional_icrg", 
                    "instituicoes_com_palop"),
       necessity=FALSE, neg.out=FALSE)


## TRUTH TABLE

ttSURV <- truthTable(data=data_qca, outcome = "anos_surv", conditions = "regiao_proj_acumulados, distancia_2palop, semelhanca_quali_institucional_icrg, instituicoes_com_palop",
                     incl.cut=1.00, sort.by="incl, n", complete=FALSE, show.cases=TRUE) 

ttSURV


###
ttsurv <- truthTable(data_qca, outcome="anos_surv", conditions ="regiao_proj_acumulados, distancia_2palop, semelhanca_quali_institucional_icrg, instituicoes_com_palop",
                     incl.cut=0.5, n.cut=1, sort.by="incl, n", decreasing=TRUE, complete=FALSE, show.cases=TRUE)
ttsurv
