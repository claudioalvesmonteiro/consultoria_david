'''
ANALYITQUE CONSULTORIA
Consultoria David Beltrao

@ claudioalvesmonteiro
@ rodrigolins

Mar-Abr 2020
'''

pd.set_option('display.max_rows', 500)
pd.set_option('display.max_columns', 500)


# import pacotes
import pandas as pd

# importar dados
proj = pd.read_csv('dados/projetos_cooperacao_brasil_africa.csv')

#======================================
# variavel dependente:
# tempo ate inicio do primeiro projeto
#======================================

# trasnformar em datime 
proj['data'] = proj['Término'].astype('datetime64[ns]') 

# capturar data do primeiro projeto por país
dic_init = dict()
for ind in range(len(proj)):
    paises = proj['País'][ind].split(';')
    for pais in paises:
        if pais[0] == ' ':
            pais = pais[1:]
        if pais in dic_init:
            if dic_init[pais] > proj['data'][ind]:
                dic_init[pais] = proj['data'][ind]
        else:
            dic_init[pais] = proj['data'][ind]

# transformar dicionario em DF
pais = []
data_primeiro_proj = []
for i in dic_init:
    pais.append(i)
    data_primeiro_proj.append(dic_init[i])

projeto_init = pd.DataFrame(pais, data_primeiro_proj)

