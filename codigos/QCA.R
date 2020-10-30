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

# importar dados
data <- read_csv("resultados/preprocessed_data/DATASET_V3.csv")

# contagem de anos ate primeiro projeto, por pais
data_qca = data[data$inicio_projeto == 1,][,c(2:5,7,9,12,14,16)]


#=====================
# QCA
#====================

library(QCA)
install.packages('QCA', dependencies = T)

