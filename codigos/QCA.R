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
library(QCA)

# importar dados
data <- data.frame(read_csv("resultados/preprocessed_data/DATASET_V3.csv"))

# contagem de anos ate primeiro projeto, por pais
data_qca = data[data$inicio_projeto == 1,][,c(2:5,7,9,12,14,16)]

# funcao para range max e min e logistic
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
range_logistic <- function(x){1/(1+exp(-x))}

# range calibration
#data_qca$regiao_proj_acumulados = range01(data_qca$regiao_proj_acumulados)
#data_qca$distancia_2palop = range01(data_qca$distancia_2palop)
#data_qca$semelhanca_quali_institucional_icrg = range01(data_qca$semelhanca_quali_institucional_icrg)
#data_qca$instituicoes_com_palop = range01(data_qca$instituicoes_com_palop)

# logistic, mean and percentil based calibration
summary(data_qca$regiao_proj_acumulados)
data_qca$cal_regiao_proj_acumulados = round(calibrate(data_qca$regiao_proj_acumulados, type = "fuzzy", thresholds = "e=10, c=35, i=63", logistic=TRUE), digits=2)

summary(data_qca$distancia_2palop)
data_qca$cal_distancia_2palop = round(calibrate(data_qca$distancia_2palop, type = "fuzzy", thresholds = "e=1425, c=2534, i=4054", logistic=TRUE), digits=2)

summary(data_qca$instituicoes_com_palop)
data_qca$cal_instituicoes_com_palop = round(calibrate(data_qca$instituicoes_com_palop, type = "fuzzy", thresholds = "e=2, c=2, i=3", logistic=TRUE), digits=2)

summary(data_qca$anos_contagem)
data_qca$cal_anos_contagem = round(calibrate(data_qca$anos_contagem, type = "fuzzy", thresholds = "e=6, c=8, i=9", logistic=TRUE), digits=2)

# criar variavel dependente
#data_qca$anos_contagem_x = range01(data_qca$anos_contagem)
#data_qca = mutate(data_qca, anos_surv = ifelse(anos_contagem_x >= 0.75, 1, 0))


#=====================
# QCA
#====================

library(QCA)
library(SetMethods)



#================= NECESSITY

conds <- subset(data_qca, select = c("cal_regiao_proj_acumulados", 
                                     "cal_distancia_2palop", 
                                     "semelhanca_quali_institucional_icrg", 
                                     "cal_instituicoes_com_palop"))

pof(conds, 'cal_anos_contagem', data_qca, relation = "nec")


xy.plot("cal_regiao_proj_acumulados", "cal_anos_contagem", data = data_qca, labs = rownames(data_qca), necessity=TRUE, 
        jitter = TRUE, main = "Projetos na Região como necessária para Velocidade", xlab = "Projetos na Região", ylab = "Velocidade de Adesão aos Projetos")


#================= NOT NECESSITY

conds_not <- data.frame(sapply(conds, function(x) 1-x))

pof(conds_not, 'cal_anos_contagem', data_qca, relation = "nec")



#=================== SUFICIENCY

QCAfit(conds, 
       data_qca$cal_anos_contagem, 
       cond.lab= c("cal_regiao_proj_acumulados", 
                    "cal_distancia_2palop", 
                    "semelhanca_quali_institucional_icrg", 
                    "cal_instituicoes_com_palop"),
       necessity=FALSE, neg.out=FALSE)


## TRUTH TABLE

ttSURV <- truthTable(data=data_qca, outcome = "cal_anos_contagem", conditions = "cal_regiao_proj_acumulados, cal_distancia_2palop, semelhanca_quali_institucional_icrg, cal_instituicoes_com_palop",
                     incl.cut=1.00, sort.by="incl, n", complete=FALSE, show.cases=TRUE) 

ttSURV


###
ttSURV <- truthTable(data=data_qca, outcome = "cal_anos_contagem", conditions = "cal_regiao_proj_acumulados, cal_distancia_2palop, semelhanca_quali_institucional_icrg, cal_instituicoes_com_palop",
                     incl.cut=0.8, sort.by="incl, n", complete=FALSE, show.cases=TRUE) 

ttSURV
