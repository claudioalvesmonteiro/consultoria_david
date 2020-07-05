# -------------------------------------- #
#  ANALYITQUE CONSULTORIA | julho/2020   #
#        Consultoria David Beltrao       #
#            @georgiaribeiro             #
# -------------------------------------- #
#- - - - Analise Dados UNComtrade - - - -#

#Carregar pacote
library(tidyverse)
library(dplyr)
library(plyr)
library(readxl)

library(ggplot2)
library(plotly)
library(wesanderson)

#Juntar todos os csv
df = list.files(path="dados/dados-comercio", full.names = TRUE) %>% 
  lapply(read_csv) %>%
  lapply(function(x) x[!(names(x) %in% c("Qty", "Netweight (kg)"))]) #Excluir essas variaveis (Nulas)

df = bind_rows(df) 

#Definir paises PALOP
PALOP = c("Cape Town","Guinea-Bissau","Equatorial Guinea","Sao Tome and Principe","Angola","Mozambique")

#=====================================================================================#
# Analise 1:  ~ Grafico de linha~ % de comercio com paises PALOP do total de comercio #
# internacional X numero de projetos de cooperação com o Brasil, por pais, no tempo.  #               #
#=====================================================================================#

#Variável 1 - % de comercio
#checar nome dos parceiros 
t = table(df$Partner)

a1 = df %>% filter(!grepl(", nes",Partner)) %>% #excluir agrupados por continente
  group_by(Year, Reporter, Partner) %>% summarise(Freq=n())

a = filter(a1, Partner %in% PALOP)
a$Condicao = "PALOP"
b = filter(a1, !Partner %in% PALOP)
b$Condicao = "Outros países"
a1=rbind(a,b)
rm(a,b)

a1 = a1 %>% group_by(Year, Reporter, Condicao) %>% summarise(Freq=n()) %>%
  spread(Condicao, Freq) #mudar formato do banco

#calcular percentual PALOP
a1$perc_palop = round((a1$PALOP/a1$`Outros países`)*100,2)

#Variável 2 - num. projetos brasil
df2 = read_excel("dados/projetos_brasil.xlsm")

df2$ano_inicio = str_sub(df2$Início, end=4) #data completa -> somente ano

#Separar paises (ver obs 30)
df2$País = gsub("\\; ", ",", df2$País)
df2=df2 %>% 
  mutate(País=strsplit(País, ",")) %>% 
  unnest(País)

#calcular numero de projetos
df2 = df2 %>% select(ano_inicio, País) %>%
  filter(País %in% c("Etiópia", "Quênia", "Nigéria", "África do Sul", "Tanzânia")) %>%
  group_by(ano_inicio, País) %>%
  summarise(num_projetos=n())
  
#traduzir nomes
a1$Reporter = mapvalues(a1$Reporter, c("Ethiopia", "Kenya", "Nigeria", "South Africa", "United Rep. of Tanzania"),
                                      c("Etiópia", "Quênia", "Nigéria", "África do Sul", "Tanzânia"))
df2$Reporter = df2$País

#visualizar
ggplot() + 
  geom_line(data = a1, aes(x=Year, y=perc_palop), color='#2D93AD', size=1) + 
  geom_line(data = df2,aes(x=as.numeric(ano_inicio), y=num_projetos), color='#DE8F6E', size=1) +
  geom_point(data = df2,aes(x=as.numeric(ano_inicio), y=num_projetos), color='#DE8F6E', size = 2) +
  facet_wrap(~Reporter) +
  scale_x_continuous(breaks = seq(1992, 2017, by = 5)) +
  labs(x = "", y = "") +
  theme_minimal()  +
  theme(         panel.border = element_rect(fill = NA, color = "#E6E6E6", size = 1.25, linetype = "solid"),
                 axis.ticks = element_line(colour = '#E6E6E6', size = 1, linetype = 'solid'))
