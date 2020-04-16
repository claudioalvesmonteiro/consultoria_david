'''
ANALYITQUE CONSULTORIA
Consultoria David Beltrao

Preprocessamento 
@ claudioalvesmonteiro
Mar 2020
'''

# import pacotes
import pandas as pd
import geopy.distance

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
def splitIndividualCountries(proj):
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
    return proj_long

proj_long = splitIndividualCountries(proj)

# combinar regioes com projetos
data_regiao = pd.merge(proj_long, regioes, on='País', how='left')

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

#=========================================================
# Associacao conjunta em instituicoes internacionais
#
# Para cada pais/ano verificar quantos projetos iniciaram 
# no bloco de paises a que ele faz parte 
#=========================================================

# importar instituicoes
inst = pd.read_csv('dados/institution_membership.csv', sep=';', encoding='unicode_escape')


def contagemInstituicao(dataset, proj_long, inst, instituicao):
    # selecionar instituicao e coluna de interesse
    inst = inst[inst[instituicao] == 1]
    inst = inst[['País', instituicao]]

    # reconfig nome da instituicao
    instituicao = instituicao.lower().replace(' ','_')

    # combinar com projetos
    inst_proj = pd.merge(proj_long, inst, on='País')

    # contagem de projetos iniciados por cada ano
    cont = inst_proj.groupby(['ano_inicio']).size().reset_index()
    cont.columns = ['anos', (instituicao+'_proj_noano')]

    ### contagem de projeto acumulados em cada ano
    projetos_acumulados = []
    idi = 0
    for i in range(len(cont)):
        idi = idi + cont[instituicao+'_proj_noano'][i]
        projetos_acumulados.append(idi)

    cont[(instituicao+'_proj_acumulados')] =  projetos_acumulados

    # criar base com paises/anos e as var de inti
    pais_inst =  pd.DataFrame({'anos' :[],  (instituicao+'_proj_noano'): [], (instituicao+'_proj_acumulados'):[], 'pais':[] }) 
    for pais in inst['País']:
        cont_pais = cont
        cont_pais['pais'] = pais
        pais_inst = pd.concat([pais_inst, cont_pais])

    # combinar dataset com instituicoes
    dataset = pd.merge(dataset, pais_inst, on = ['pais','anos'], how = 'left')

    # substitui NA por 0 no numero de projetos por ano
    dataset[(instituicao+'_proj_noano')] = dataset[(instituicao+'_proj_noano')].fillna(0)
    dataset[(instituicao+'_proj_acumulados')] = dataset[(instituicao+'_proj_acumulados')].fillna(0)

    return dataset

# executar e salvar
for i in inst.columns[2:]:
    dataset = contagemInstituicao(dataset, proj_long, inst, i)

# renomear columnas
dataset.columns = ['pais', 'anos', 'inicio_projeto', 'anos_contagem', 'regiao',
       'regiao_proj_noano', 'regiao_proj_acumulados',
       'african_union_proj_noano', 'african_union_proj_acumulados',
       'arab_maghreb_union_proj_noano', 'arab_maghreb_union_proj_acumulados',
       'common_market_for_eastern_and_southern_africa_proj_noano',
       'common_market_for_eastern_and_southern_africa_proj_acumulados',
       'community_of_sahel_saharan_states_proj_noano',
       'community_of_sahel_saharan_states_proj_acumulados',
       'east_african_community_proj_noano',
       'east_african_community_proj_acumulados',
       'economic_community_of_central_african_states_proj_noano',
       'economic_community_of_central_african_states_proj_acumulados',
       'economic_and_monetary_community_of_central_africa_proj_noano',
       'economic_and_monetary_community_of_central_africa_proj_acumulados',
       'economic_community_of_west_african_states_proj_noano',
       'economic_community_of_west_african_states_proj_acumulados',
       'intergovernmental_authority_for_development_proj_noano',
       'intergovernmental_authority_for_development_proj_acumulados',
       'southern_african_development_community_proj_noano',
       'southern_african_development_community_proj_acumulados',
       'southern_african_customs_union_proj_noano',
       'southern_african_customs_union_proj_acumulados', 'cotton4_proj_noano',
       'cotton4_proj_acumulados']

# criar soma das instituicoes
dataset['instituicoes_internacionais_proj_noano'] = dataset['african_union_proj_noano'] +  dataset['arab_maghreb_union_proj_noano'] + dataset['common_market_for_eastern_and_southern_africa_proj_noano'] +dataset['community_of_sahel_saharan_states_proj_noano'] + dataset['east_african_community_proj_noano'] + dataset['economic_community_of_central_african_states_proj_noano'] + dataset['economic_and_monetary_community_of_central_africa_proj_noano'] + dataset['economic_community_of_west_african_states_proj_noano'] + dataset['intergovernmental_authority_for_development_proj_noano'] + dataset['southern_african_development_community_proj_noano'] + dataset['southern_african_customs_union_proj_noano'] + dataset['cotton4_proj_noano'] 
dataset['instituicoes_internacionais_proj_acumulados'] = dataset['african_union_proj_acumulados'] +  dataset['arab_maghreb_union_proj_acumulados'] + dataset['common_market_for_eastern_and_southern_africa_proj_acumulados'] +dataset['community_of_sahel_saharan_states_proj_acumulados'] + dataset['east_african_community_proj_acumulados'] + dataset['economic_community_of_central_african_states_proj_acumulados'] + dataset['economic_and_monetary_community_of_central_africa_proj_acumulados'] + dataset['economic_community_of_west_african_states_proj_acumulados'] + dataset['intergovernmental_authority_for_development_proj_acumulados'] + dataset['southern_african_development_community_proj_acumulados'] + dataset['southern_african_customs_union_proj_acumulados'] + dataset['cotton4_proj_acumulados'] 

#=================================================
# Distancia de cada pais para os os dois paises 
# de lingua portuguesa mais proximos
# *ou faz fronteira com quantos 
#=================================================

# importar tabela de geolocalizacao
geo = pd.read_excel('dados/geo_cepii.xls')

# selecionar capitais e africanos
geo = geo[geo['cap'] == 1]
geo = geo[geo['continent'] == 'Africa']
geo.reset_index(inplace=True)

# paises palop
portugues = ['Angola', 
            'Cape Verde', 
            'Guinea-Bissau', 
            'Equatorial Guinea', 
            'Mozambique', 
            'Sao Tome and Principe']

# mensura a distancia entre cada pais 
# e os 2 palop mais proximos,
# usando a formula de vicenty
distancia_2palop = []
paises_2palop = []
for i in range(len(geo['country'])):
    coords_1 = (geo['lat'][i], geo['lon'][i])
    dists = []
    for palop in portugues:
        coords_2 = (float(geo['lat'][geo['country'] ==  palop]), float(geo['lon'][geo['country'] ==  palop]))
        print(coords_1, coords_2)
        dists.append(geopy.distance.vincenty(coords_1, coords_2).km)
    # identificar duas menores distancias
    sort_coord = sorted(dists)
    distancia_2palop.append(sort_coord[0] + sort_coord[1])
    paises_2palop.append(portugues[dists.index(sort_coord[0])]+';'+ portugues[dists.index(sort_coord[1])])

geo['distancia_2palop'] = distancia_2palop
geo['paises_2palop'] = paises_2palop

# combinar com instituicao para capturar coluna de pais
geo = pd.merge(geo[['country', 'distancia_2palop', 'paises_2palop']], inst[['País', 'country']], on='country')
geo.columns = ['country', 'distancia_2palop', 'paises_2palop', 'pais']

# combinar com dataset 
dataset = pd.merge(dataset, geo, on='pais')

# selecionar colunas de interesse
dataset = dataset[['pais', 
                    'country', 
                    'regiao',
                    'anos', 
                    'inicio_projeto', 
                    'anos_contagem', 
                    'regiao_proj_noano', 
                    'regiao_proj_acumulados',
                    'instituicoes_internacionais_proj_noano', 
                    'instituicoes_internacionais_proj_acumulados',
                    'distancia_2palop', 
                    'paises_2palop']]

# salvar base
dataset.to_csv('resultados/DATASET.csv')
print(dataset.head())
print('dataset saved')


#======================================================
# Associacao conjunta em comercios bilateriais
#
# pra cada pais/ano verificar quantos projetos iniciaram no bloco de paises a que ele faz comercio bilateral, 
# tirando os projetos que iniciaram no proprio pais
#=======================================================

# fazer bloco-ano-projs, pais-ano-projs : substrair o n de projs do proprio pais ao selecionar informacao 
