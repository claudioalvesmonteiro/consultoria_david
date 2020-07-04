# -------------------------------------- #
#  ANALYITQUE CONSULTORIA | julho/2020   #
#        Consultoria David Beltrao       #
#            @georgiaribeiro             #
# -------------------------------------- #
#- - - - Analise Dados UNComtrade - - - -#

#Carregar pacote
library(tidyverse)
library(dplyr)
library(readxl)

#Juntar todos os csv
df = list.files(path="dados/dados-comercio", full.names = TRUE) %>% 
  lapply(read_csv) %>%
  lapply(function(x) x[!(names(x) %in% c("Qty", "Netweight (kg)"))]) #Excluir essas variaveis (Nulas)

df = bind_rows(df) 

#Definir paises PALOP
PALOP = c("Cape Town","Guinea-Bissau","Equatorial Guinea","Sao Tome and Principe","Angola","Mozambique")

#=====================================================================================#
# Analise 1:  ~ Grafico de linha~ % de comércio com países PALOP do total de comércio #
# internacional X número de projetos de cooperação com o Brasil, por país, no tempo   #               #
#=====================================================================================#

#checar nome dos parceiros 
t = table(df$Partner)
View(table)

a1 = df %>% filter(!grepl(", nes",Partner)) %>% #excluir agrupados por continente
  group_by(Year, Reporter, Partner) %>% summarise(Freq=n())

a = filter(a1, Partner %in% PALOP)
a$Condicao = "PALOP"
b = filter(a1, !Partner %in% PALOP)
b$Condicao = "Outros países"

a1=rbind(a,b)
rm(a,b)

a1 = a1 %>% group_by(Year, Reporter, Condicao) %>% summarise(Freq=n()) %>%
  spread(Condicao, Freq)                
a1$perc_palop = round((a1$PALOP/a1$`Outros países`)*100,2)
