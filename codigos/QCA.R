#---------------------------
# ANALYITQUE CONSULTORIA
# Consultoria David Beltrao
#
# QCA
# @claudiomonteiro
# Nov 2020
#-------------------------



#=====================
# preprocessar dados
#====================

# importar pacotes
library(readr)
library(dplyr)
library(QCA)
library(SetMethods)

# importar dados
data <- data.frame(read_csv("resultados/preprocessed_data/DATASET_V3.csv"))

# contagem de anos ate primeiro projeto, por pais
data_qca = data[data$inicio_projeto == 1,][,c(2:5,7,9,12,14,16)]

# funcao para range max e min e logistic
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
range_logistic <- function(x){1/(1+exp(-x))}


#==================================
# CALIBRAGEM
#==================================

summary(data_qca$regiao_proj_acumulados)
data_qca$cal_regiao_proj_acumulados = round(calibrate(data_qca$regiao_proj_acumulados, 
                                  type = "fuzzy", thresholds = "e=10, c=35, i=63", logistic=TRUE), digits=2)

summary(data_qca$distancia_2palop)
data_qca$cal_distancia_2palop = round(calibrate(data_qca$distancia_2palop,
                                    type = "fuzzy", thresholds = "e=1425, c=2534, i=4054", logistic=TRUE), digits=2)

summary(data_qca$instituicoes_com_palop)
data_qca$cal_instituicoes_com_palop = round(calibrate(data_qca$instituicoes_com_palop, 
                                          type = "fuzzy", thresholds = "e=2, c=2, i=3", logistic=TRUE), digits=2)

summary(data_qca$anos_contagem)
data_qca$cal_anos_contagem = round(calibrate(data_qca$anos_contagem, 
                                  type = "fuzzy", thresholds = "e=6, c=8, i=9", logistic=TRUE), digits=2)
data_qca$cal_anos_contagem = 1-data_qca$cal_anos_contagem 



#================= ANALISE DE NECESSIDADE ========================#

conds <- subset(data_qca, select = c("cal_regiao_proj_acumulados", 
                                     "cal_distancia_2palop", 
                                     "semelhanca_quali_institucional_icrg", 
                                     "cal_instituicoes_com_palop"))

pof(conds, 'cal_anos_contagem', data_qca, relation = "nec")


xy.plot("cal_instituicoes_com_palop", "cal_anos_contagem", data = data_qca, labs = rownames(data_qca), necessity=TRUE, 
        jitter = TRUE, main = "", xlab = "instituicoes_com_palop", ylab = "velocidade_adesao_projetos")


#================= ANALISE DE NEGACAO DA NECESSIDADE ==================#

conds_not <- data.frame(sapply(conds, function(x) 1-x))

pof(conds_not, 'cal_anos_contagem', data_qca, relation = "nec")



xy.plot("cal_regiao_proj_acumulados", "cal_anos_contagem", data = data_qca, labs = rownames(data_qca), necessity=TRUE, 
        jitter = TRUE, main = "", xlab = "regiao_proj_acumulados", ylab = "velocidade_adesao_projetos")

#==================== NECESSIDADE COMBINADA ======================#

super <- superSubset(data_qca, outcome = "cal_anos_contagem",
            conditions = "cal_regiao_proj_acumulados, cal_distancia_2palop, semelhanca_quali_institucional_icrg, cal_instituicoes_com_palop",
            incl.cut = 0.9, cov.cut = 0.6)
super


xy.plot("proj_acumulados__instituicoes_com_palop", "cal_anos_contagem", data = data_qca, necessity=TRUE,
        jitter = TRUE, main = "", xlab = "~regiao_proj_acumulados+instituicoes_com_palop", ylab = "velocidade_adesao_projetos")

#==================== TABELA DA VERDADE ======================#

truthTable(data=data_qca, outcome = "cal_anos_contagem", conditions = "cal_regiao_proj_acumulados, cal_distancia_2palop, semelhanca_quali_institucional_icrg, cal_instituicoes_com_palop",
                     incl.cut=0.8, sort.by="incl, n", complete=FALSE, show.cases=TRUE) 



#=============================================
#           ANALISE DA SUFICIENCIA
#=============================================

# configurar variaveis not
data_qca_not = data_qca[,c(1,12:13)]
data_qca_not = cbind(data_qca_not, conds_not[,1:3])

# gerar analise conservadora
pof("cal_regiao_proj_acumulados*cal_distancia_2palop*cal_instituicoes_com_palop => cal_anos_contagem", data = data_qca_not)
pof("cal_regiao_proj_acumulados*cal_distancia_2palop => cal_anos_contagem", data = data_qca_not)
pof("cal_regiao_proj_acumulados*cal_instituicoes_com_palop => cal_anos_contagem", data = data_qca_not)
pof("cal_distancia_2palop*cal_instituicoes_com_palop => cal_anos_contagem", data = data_qca_not)

# gerar analise intermediaria
pof("cal_regiao_proj_acumulados+cal_distancia_2palop+cal_instituicoes_com_palop => cal_anos_contagem", data = data_qca_not)






#pimplot(data=data_qca, results=super, outcome="cal_anos_contagem", necessity=TRUE, all_labels=TRUE, jitter=TRUE)