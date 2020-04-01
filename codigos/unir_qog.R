# -------------------------------------- #
# ANALYITQUE CONSULTORIA | Mar-abr/2020  #
#        Consultoria David Beltrao       #
#            @georgiaribeiro             #
# -------------------------------------- #

# - - Incluir variaveis QOG no Banco - - #

#Carregar pacote
library(tidyverse)

#Carregar bancos
DATASET = read.csv("resultados/DATASET.csv")
QOG = read.csv("dados/qog_bas_ts_jan20.csv")

#selecionar variaveis escolhidas do QOG
QOG = select(QOG, cname, year, icrg_qog, ht_region)

#filtrar paises africanos entre 1999 e 2010
QOG = QOG %>% filter((between(year, 1999,2010)),
                     (between(ht_region, 3,4)))

#Juntar bancos
left_join(DATASET, QOG %>% select(cname, icrg_qog), 
                    by = c("cname" = "paises"))