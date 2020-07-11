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

#Definir listas
PALOP = c("Cape Town","Guinea-Bissau","Equatorial Guinea","Sao Tome and Principe","Angola","Mozambique")
Africa = c()

#=====================================================================================#
# Analise 1:  ~ Grafico de linha~ % de comercio com paises PALOP do total de comercio #
# internacional X numero de projetos de cooperação com o Brasil, por pais, no tempo.  #               #
#=====================================================================================#

#Variável 1 - % de comercio
#checar nome dos parceiros 
t = table(df$Partner)
rm(t)

a1 = df %>% filter(!grepl(", nes",Partner)) %>% #excluir agrupados por continente
  select(Year, Reporter, Partner, `Trade Flow`,`Trade Value (US$)`)
#%>% summarise(Freq=n())

#calcular balança comercial
a1 = spread(a1, `Trade Flow`,`Trade Value (US$)`) #1. mudar formato do banco
a1[is.na(a1)] = 0 #NA para 0

a1 = a1 %>% mutate(Exports= Export+`Re-Export`)#2. somar RE-...
a1 = a1 %>% mutate(Imports= Import+`Re-Import`)
a1 = a1[,-c(4:7)] #3. excluir variaveis antigas

a1 = a1 %>% mutate(BlCom= Exports-Imports) #calcular balança

#agrupar PALOP
a = filter(a1, Partner %in% PALOP)
a$Condicao = "PALOP"
b = filter(a1, !Partner %in% PALOP)
b$Condicao = "Outros países"
a1=rbind(a,b)
rm(a,b)

a1 = a1[,-c(4:5)] #excluir exp. e imp.

teste = a1 %>%  group_by(Year, Reporter, Condicao) %>%
  summarise_at(vars(BlCom), list(BlCom = sum)) %>%
  spread(Condicao, BlCom) #mudar formato do banco

#calcular percentual PALOP
a1$perc_palop = round((a1$PALOP/a1$`Outros países`)*100,2)

#Variável 2 - num. projetos brasil
df2 = read_excel("dados/projetos_brasil.xlsm")

df2$ano_inicio = str_sub(df2$Início, end=4) #data completa -> somente ano

#Separar paises (ver obs. 30)
df2$País = gsub("\\; ", ",", df2$País)
df2=df2 %>% 
  mutate(País=strsplit(País, ",")) %>% 
  unnest(País)

#calcular numero de projetos
df2 = df2 %>% select(ano_inicio, País) %>%
  filter(País %in% c("Etiópia", "Quênia", "Nigéria", "África do Sul", "Tanzânia")) %>%
  group_by(ano_inicio, País) %>% summarise(num_projetos=n())
  
#para unir bancos
#1. traduzir nomes
a1$Reporter = mapvalues(a1$Reporter, c("Ethiopia", "Kenya", "Nigeria", "South Africa", "United Rep. of Tanzania"),
                                      c("Etiópia", "Quênia", "Nigéria", "África do Sul", "Tanzânia"))
#2. renomear colunas
colnames(df2) = c("Year", "Reporter", "num_projetos")
#3. transformar anos em numerico
df2$Year = as.numeric(df2$Year)
df_all = full_join(a1[,-c(3:4)], df2, by = c('Year','Reporter')) #unir

df_all = gather(df_all, "Variavel", "Valor", 3:4) #formato tidy

#visualizar
ggplot(df_all, aes(Year, Valor, group=Variavel)) + 
  geom_line(aes(colour=Variavel)) +
  geom_point(data = pick(~Variavel == "num_projetos"), colour = "#DE8F6E", size=0.8)+
  facet_wrap(~Reporter, scales = 'free_x') +
  scale_x_continuous(breaks = seq(1992, 2017, by = 3)) + ylim(0,10) +
  scale_color_manual(labels = c("Número de projeto com o Brasil",
                                "% de comércio com PALOP do total"),
                     values = c("#DE8F6E", "#2D93AD")) +
  labs (x="", y="", colour="") +
  theme_minimal() + theme(axis.text.x = element_text(size=8), legend.position="bottom",
                         strip.background = element_rect(color="#E6E6E6", fill="white", size=1))+
  ggsave("graf1.png", path = "resultados", width = 7, height = 4, units = "in")
                      
  
#======================================#
# Analise 2:  mesma análise 1 com log  #
#======================================#

#visualizar
ggplot(df_all, aes(Year, log(Valor), group=Variavel)) + 
  geom_line(aes(colour=Variavel)) +
  facet_wrap(~Reporter, scales = 'free_x') +
  scale_x_continuous(breaks = seq(1992, 2017, by = 3)) + 
  geom_point(data = pick(~Variavel == "num_projetos"), colour = "#DE8F6E", size=0.8)+
  scale_color_manual(labels = c("Número de projeto com o Brasil (log)",
                                "% de comércio com PALOP do total (log)"),
                     values = c("#DE8F6E", "#2D93AD")) +
  labs (x="", y="", colour="") +
  theme_minimal() + theme(axis.text.x = element_text(size=8), legend.position="bottom",
                        strip.background = element_rect(color="#E6E6E6", fill="white", size=1)) +
  ggsave("graf2.png", path = "resultados", width = 7, height = 4, units = "in")

#======================================================================#
# Analise 3: ~Teste de correlação de Pearson, % de comércio com PALOP  #
# do total X número de projetos de cooperação com o Brasil, por país.  #
#======================================================================#

#banco
df3 = full_join(a1[,-c(3:4)], df2, by = c('Year','Reporter'))

cor.test(df3$perc_palop, df3$num_projetos)




#rascunho
projetos_br = read_excel("dados/projetos_brasil.xlsm")
projetos_br = filter(projetos_br, Região == "África")

#Separar paises (ver obs. 30)
projetos_br$País = gsub("\\; ", ",", projetos_br$País)
projetos_br=projetos_br %>% 
  mutate(País=strsplit(País, ",")) %>% 
  unnest(País)

projetos_br$ano_inicio = str_sub(projetos_br$Início, end=4)
projetos_br = projetos_br %>% select(ano_inicio, País) %>%
  group_by(ano_inicio, País) %>% summarise(num_projetos=n())
