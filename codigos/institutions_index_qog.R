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
QOG = read.csv("dados/qog_std_ts_jan20.csv", sep=";")

#selecionar variaveis escolhidas do QOG
QOG = select(QOG, cname, year, ht_region, hf_govint, icrg_qog)

#filtrar paises africanos entre 1999 e 2010
QOG = QOG %>% filter((between(year, 1999,2010)),
                     (between(ht_region, 3,4)))

#salvar
write.csv(QOG,"resultados/institutions_index_QOG.csv", row.names = FALSE)

#Adicionei os nomes dos países em pt manualmente no excel.