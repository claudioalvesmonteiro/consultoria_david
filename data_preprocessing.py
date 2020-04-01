'''
ANALYITQUE CONSULTORIA
Consultoria David Beltrao

Preprocessamento 
@ claudioalvesmonteiro
Mar 2020
'''

# import pacotes
import pandas as pd

# importar dados
proj = pd.read_csv('dados/projetos_cooperacao_brasil_africa.csv')

# substituir nomes
proj['País'] = [x.replace('Burquina Faso', 'Burkina-Faso') for x in proj['País']]
proj['País'] = proj['País'].replace('Guiné-Equatorial', 'Guiné Equatorial')

#======================================
# variavel dependente:
# tempo ate inicio do primeiro projeto
#======================================

# trasnformar em datime 
proj['data'] = proj['Início'].astype('datetime64[ns]') 

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

projeto_init = pd.DataFrame(pais, data_primeiro_proj).reset_index()
projeto_init.columns = ['data_inicio', 'pais']

# criar variavel ano
projeto_init['ano_inicio'] = projeto_init['data_inicio'].map(lambda x: x.year )

# criar dataframe com anos ate data de inicio do primeiro projeto
dataset = pd.DataFrame(columns=['pais', 'anos', 'inicio_projeto'])

for i in range(len(projeto_init)):
    # criar listas de cada pais
    anos = list(range(1999,int( str(projeto_init['ano_inicio'][i]))+1 ))
    pais = (( projeto_init['pais'][i]+';') * len(anos)).split(';')[:-1]
    contagem_anos = list(range(len(anos))) ############################ VERFIFICAR 01 ############# VERFIFICAR 01 ############# VERFIFICAR 01 ########################
    interv = list([0]*(len(anos)-1))
    interv.append(1)

    # criar dataframe e adicionar 
    dt_pais = pd.DataFrame(
        {'pais': pais,
        'anos': anos,
        'inicio_projeto': interv ,
        'anos_contagem' : contagem_anos
        })

    dataset = pd.concat([dataset, dt_pais], )


#=======================================================
# n de adesoes anteriores aos projetos por regiao       
#=======================================================

# importar dados
regioes = pd.read_csv('dados/regioes_africa.csv')
regioes.columns = ['regiao', 'País']

# criar variavel ano
proj['ano_inicio'] = proj['data'].map(lambda x: x.year )

### separar projetos em mais de um pais
def splitIndividualCountries():
    ''' identificar os projetos em mais de um pais,
        duplicar as informacoes do projeto identificando e separando os paises
    '''
    proj_long = proj[False == proj['País'].str.contains(';')]
    for i in range(len(proj)):
        if ';' in proj['País'][i]:
            paises = proj['País'][i].split(';')
            for j in range(len(paises)):
                pais = paises[j] 
                if j != 0:
                    pais = pais[1:]
                row = proj[i:i+1]  
                row['País'] = pais
                proj_long = pd.concat([proj_long, row])


splitIndividualCountries()

# combinar regioes com projetos
data_regiao = pd.merge(proj, regioes, on='País', how='left')

# contagem de projeto iniciados por cada ano
reg_cont = data_regiao.groupby(['regiao', 'ano_inicio']).size().reset_index()
reg_cont.columns = ['regiao', 'anos', 'regiao_proj_noano']

### contagem de projeto acumulados em cada ano
def projAcumulados(): 
    projetos_acumulados = []
    for i in reg_cont['regiao'].unique():
        reg = reg_cont[reg_cont.regiao == i].reset_index()
        idi = 0
        for i in range(len(reg)):
            idi = idi + reg['regiao_proj_noano'][i]
            projetos_acumulados.append(idi)
    return projetos_acumulados

    
reg_cont['regiao_proj_acumulados'] = projAcumulados()

### combinar bases de dados 
regioes.columns = ['regiao', 'pais']
dataset = pd.merge(dataset, regioes, on = ['pais'])
dataset = pd.merge(dataset, reg_cont, on = ['regiao','anos'], how = 'left')

# substitui NA por 0 no numero de projetos por ano
dataset['regiao_proj_noano'] = dataset['regiao_proj_noano'].fillna(0)
dataset['regiao_proj_acumulados'] = dataset['regiao_proj_acumulados'].fillna(0)

# salvar
dataset.to_csv('resultados/DATASET.csv')
print(dataset.head())
print('dataset saved')

#=======================================================
# Velocidade de adesao aos projetos de cooperacao 
# brasileiros nos paises africanos
#=======================================================



