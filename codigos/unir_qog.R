# -------------------------------------- #
# ANALYITQUE CONSULTORIA | Mar-abr/2020  #
#        Consultoria David Beltrao       #
#            @georgiaribeiro             #
# -------------------------------------- #

# - - Incluir variaveis QOG no Banco - - #

#Carregar pacote
library(tidyverse)
library(dplyr)

#Carregar bancos
DATASET = read.csv("resultados/DATASET_pt-en.csv", sep=";")
QOG = read.csv("dados/qog_bas_ts_jan20.csv")

#selecionar variaveis escolhidas do QOG
QOG = select(QOG, cname, year, icrg_qog, ht_region)

#filtrar paises africanos entre 1999 e 2010
QOG = QOG %>% filter((between(year, 1999,2010)),
                     (between(ht_region, 3,4)))

#ajustar categoria da coluna
QOG$cname = as.character(QOG$cname)
QOG$cname = as.factor(QOG$cname)

#Juntar bancos
DATASET_qog = left_join(DATASET, QOG %>% select(cname, icrg_qog, year), 
                    by = c("cname", "anos" = "year"))

#salvar
write.csv(DATASET_qog,"resultados/DATASET_QOG.csv", row.names = FALSE)
