# Bibliotecas que vamos usar no Projeto
library(dplyr)
library(tidyr)
library(tidyverse)
library(gmodels)
library(matrixStats)
library(car)
library(lmtest)
library(tseries)
library(ggplot2)
library(MASS)
library(corrplot)
library(rlang)
library(Metrics)
library(olsrr)
library(gvlma)
library(caTools)
library(lubridate)
library(openxlsx)
library(descr)
library(flextable)
library(moments)
library(ggplot2)
library(IRdisplay)
library(knitr)

# Ler a Base de Dados do csv (Database)
db <- read.csv("listings_Boston.csv", header=TRUE, sep=",")

# Apenas para cerificar que começamos com as variáveis em chr que 
# potencialmente poderiam ser automaticamente consideradas factor pelo R
db$neighbourhood <- as.character(db$neighbourhood)
db$room_type <- as.character(db$room_type)
db$license <- as.character(db$license)

# Estrutura da Tabela de Dados
str(db)

# Estatística Descritiva Básica das Variáveis
summary(db)

# Verificar duplicados
sum(duplicated(db))

# Verificámos e Retirámos desde logo as linhas com price a 0, uma vez que é 
# inbubitávelmente um erro, para o qual não conseguimos usar esses dados
# dado que o objetivo é prever o preço
db[which(db$price == 0),]
db <- db[-which(db$price == 0),]

# Ordenar o price por ordem decrescente para verificar o valor 10 000$
db_order_p <- order(db$price, decreasing = TRUE)
db[head(db_order_p, n = 5),] # Apresenta os 5 anúncios com preço mais elevado

# Ordenar as minimum_nights por ordem decrescente para verificar o valor 730.00
db_order_mn <- order(db$minimum_nights, decreasing = TRUE)
db[head(db_order_mn, n = 5),] # Apresenta os 5 anúncios com maior nº de noites min.

# Ordenar o calculated_host_listings_count por ordem decrescente para verificar o valor 477
db_order_chlc <- order(db$calculated_host_listings_count, decreasing = TRUE)       
db[head(db_order_chlc, n = 2),] # Apresenta os 5 anúncios com calculated_host_listings_count mais elevado

# Primeiras observações da base de dados
head(db)

# Últimas observações da base de dados
tail(db)

print(paste("Nº de Observações:", nrow(db)))
print(paste("Nº de IDs de Anúncios Únicos:", length(unique(db$id))))
print(paste("Nomes Anúncios Únicos:", length(unique(db$name))))
print(paste("Nº de Host_IDs Únicos:", length(unique(db$host_id))))
print(paste("Nº de Host_Names Únicos:", length(unique(db$host_name))))

# Uniformizar e Visualizar as variáveis, o nº de observações e o tipo de dado
db_clean <- db
db_clean[db_clean == ''] <- NA

# Definir o tamanho do gráfico e Representação do tipo de dados e os NAs
options(repr.plot.width = 10, repr.plot.height = 10)
visdat::vis_dat(db_clean, sort_type = FALSE)

# Listar o número de NAs de cada variável
print(paste("NAs: "))
map(db_clean, ~sum(is.na(.)))

# % de NAs do Last_Review e Reviews_per_Month
paste("A % de NAs da variável Last_Review na amostra é de ",
      round((sum(is.na(db_clean$last_review))/nrow(db_clean))*100, 2),"%.")
paste("A % de NAs da variável Reviews_per_Month na amostra é de ",
      round((sum(is.na(db_clean$reviews_per_month))/nrow(db_clean))*100, 2),"%.")

# Estrutura da Tabela de Dados Limpa
str(db_clean)

# Estatística Descritiva Básica das Variáveis Limpas
summary(db_clean)

# Eliminar as variáveis id[1], name[2], host_name[4], neighbourhood_group[5],
# latitude[7], longitude[8], last_review[13], reviews_per_month[14] e 
# number_of_reviews_ltm[17]
db_clean <- db[-c(1,2,4,5,7,8,13,14,17)]

# Estrutura da Tabela de Dados (caracteriza o tipo de cada variável)
str(db_clean)

# Uniformizar South Boston Waterfront em South Boston
db_clean$neighbourhood <- ifelse(db_clean$neighbourhood == 'South Boston Waterfront',
                                 yes = 'South Boston',
                                 no = db_clean$neighbourhood)

# Uniformizar Longwood Medical Area em Mission Hill
db_clean$neighbourhood <- ifelse(db_clean$neighbourhood == 'Longwood Medical Area',
                                 yes = 'Mission Hill',
                                 no = db_clean$neighbourhood)

# Agrupar os Bairros(Neighbourhood) em Regiões
db_clean$neighbourhood <- ifelse(db_clean$neighbourhood == 'Charlestown',
                                 yes = 'North Boston',
                                 no = db_clean$neighbourhood)

db_clean$neighbourhood <- ifelse(db_clean$neighbourhood == 'South End' |
                                 db_clean$neighbourhood == 'Mission Hill' |
                                 db_clean$neighbourhood == 'South Boston' |
                                 db_clean$neighbourhood == 'Roxbury' |
                                 db_clean$neighbourhood == 'Dorchester' |
                                 db_clean$neighbourhood == 'Jamaica Plain' |
                                 db_clean$neighbourhood == 'Roslindale' |
                                 db_clean$neighbourhood == 'Mattapan' |
                                 db_clean$neighbourhood == 'Hyde Park' |
                                 db_clean$neighbourhood == 'South Boston Waterfront',
                                 yes = 'South Boston',
                                 no = db_clean$neighbourhood)

db_clean$neighbourhood <- ifelse(db_clean$neighbourhood == 'Allston' |
                                 db_clean$neighbourhood == 'Brighton' |
                                 db_clean$neighbourhood == 'West End' |
                                 db_clean$neighbourhood == 'West Roxbury',
                                 yes = 'West Boston',
                                 no = db_clean$neighbourhood)


db_clean$neighbourhood <- ifelse(db_clean$neighbourhood == 'Fenway' |
                                 db_clean$neighbourhood == 'Back Bay' |
                                 db_clean$neighbourhood == 'Bay Village' |
                                 db_clean$neighbourhood == 'Chinatown' |
                                 db_clean$neighbourhood == 'West End' |
                                 db_clean$neighbourhood == 'North End' |
                                 db_clean$neighbourhood == 'Downtown' |
                                 db_clean$neighbourhood == 'Leather District' |
                                 db_clean$neighbourhood == 'Beacon Hill',
                                 yes = 'Center Boston',
                                 no = db_clean$neighbourhood)

# Tranformar a variável neighbourhood categórica e verificar os seus níveis
db_clean$neighbourhood <- as.factor(db_clean$neighbourhood)
levels(db_clean$neighbourhood)
str(db_clean$neighbourhood)

# Transformar chr em fator
db_clean$room_type <- as.factor(db_clean$room_type)

# Variável room_type
str(db_clean$room_type)
levels(db_clean$room_type)

# Transformar chr em binária
db_clean$license <- ifelse(db_clean$license == '', 0, 1)
str(db_clean$license)

# Uniformizar os IDs
# Lista de IDs únicos
unique_ids <- unique(db_clean$host_id)

# Nº Máximo de IDs Únicos
max_id <- length(unique_ids)

# Sequência de IDs uniformizados
uniformized_ids <- seq(1, max_id)

# Combinação entre o ID Original e o Uniformizado, usando a função
original_to_uniformized <- data.frame(unique_ids, uniformized_ids)

# Nova lista para os ids_uniformizados
transformed_numbers <- c()

# Alterar os IDs - Iterar a lista original e alterar pela nova
for (id in db_clean$host_id) {
    transformed_numbers <- c(transformed_numbers, original_to_uniformized[which(original_to_uniformized[1] == id), 2])
}

# Confirmar se a uniformização está correta

# Primeiro verificamos quantos host_id com o nº 107434423 existem 
sum(db_clean$host_id == 107434423)

# De seguida verificamos o novo id corresponder ao antigo 107434423
original_to_uniformized[which(original_to_uniformized[1] == 107434423), ]

# E por último verificamos a sua frequencia no data.frame transformado
table(transformed_numbers)[986]

# Por fim substituimos o host_id no data.frame pelo uniformizado
length(transformed_numbers)
length(db_clean$host_id)

db_clean$host_id <- transformed_numbers

# Sumário com Informação Estatística acerca das Variáveis Selecionadas

# summary(db_clean)
summary(db_clean[4])      # Variável Target
summary(db_clean[-c(4)])  # Variáveis Independetes

# Limpeza concluida | Verificação do Nº de Linhas, Colunas e Nomes das Colunas
nrow(db_clean)
ncol(db_clean)
names(db_clean)

summary(db_clean)
str(db_clean)

scatterplotMatrix(db_clean, smooth=FALSE, main="Scatter Plot Matrix")

pairs(db_clean, main = "Scatter Plot Matrix")

# Definir o Tamanho da Figura
options(repr.plot.width = 5, repr.plot.height = 5)

# Boxplot - Caixa de Bigodes da Variável 
boxplot(db_clean$price ~ db_clean$room_type, ylab = 'Preço ($)', col=c('#ffc40c', '#007474', '#6f2da8','#ce2029'))

hist(db_clean$price, 
     freq=FALSE, 
     main = "Histograma da Variável Preço",
     xlab='Preço ($)', 
     ylim = c(0,0.004),
     col = "#d3d3d3")

lines(density(db_clean$price), 
      lwd=2, 
      col='#a40000')

hist(log(db_clean$price), 
     main = "Histograma da Variável Preço Logaritmizada",
     freq=FALSE, 
     xlab='Preço ($)', 
     xlim = c(2, 10),
     ylim = c(0,0.6),
     col = "#d3d3d3")

lines(density(log(db_clean$price)), 
      lwd=2, 
      col='#a40000')

ggplot(db_clean, aes(x = neighbourhood, 
                     y = price, 
                     col = license)) + geom_point( size = 2) + theme_minimal()

# Definir o Tamanho da Figura
options(repr.plot.width = 10, repr.plot.height = 10)

p <- ggplot(db_clean, aes(x = neighbourhood, y = price, fill = neighbourhood)) + 
     geom_violin(trim=FALSE, color="grey")+ 
     geom_boxplot(width=0.15,  position=position_dodge(1), fill = "white") + 
     theme_minimal()+ xlab("Bairro") + ylab("Preço")
     # facet_zoom(ylim = c(0, 1000), show.area = TRUE, zoom.size=10, shrink = TRUE)
    
p + guides(fill = guide_legend(title="Bairro"))

# Zoom do gráfico entre y = 0 e y = 1300
p <- ggplot(db_clean, aes(x = neighbourhood, y = price, fill = neighbourhood)) + 
     geom_violin(trim=FALSE, color="grey")+ 
     geom_boxplot(width=0.15,  position=position_dodge(1), fill = "white") + 
     theme_minimal()+ xlab("Bairro") + ylab("Preço") + 
     coord_cartesian(ylim=c(0,1300))

p + guides(fill = guide_legend(title="Bairro"))

Room_Type <- c("Entire home/Apt", "Hotel Room", "Private Room","Shared Room")
Room_Type_tab <- table(db_clean$room_type)
Room_Type_p <- round((prop.table(Room_Type_tab)*100),1)

n <- c(as.numeric(Room_Type_tab[1]),as.numeric(Room_Type_tab[2]),
                 as.numeric(Room_Type_tab[3]),as.numeric(Room_Type_tab[4]))
Percentagem <- c(as.numeric(Room_Type_p[1]),as.numeric(Room_Type_p[2]),
                 as.numeric(Room_Type_p[3]),as.numeric(Room_Type_p[4]))
table1 <- data.frame(Room_Type,n,Percentagem)
ftable_1 <- flextable(head(table1))

ftable_1 <- bg(ftable_1, bg = "#ce2029", part = "header")
ftable_1 <- color(ftable_1, color = "white", part = "header")
ftable_1 <- bold(ftable_1, bold = TRUE, part="header")
ftable_1 <- set_header_labels(ftable_1,Room_Type = 'Tipo de Alojamento',n = 'n',Percentagem = '%')
ftable_1 <- autofit(ftable_1)
# ftable_1 # -> Ver output no RStudio
table1

levels(db_clean$neighbourhood)

Neighbourhood <- c("Center Boston", "East Boston", "Harbor Islands","North Boston","South Boston","West Boston")
Neighbourhood_tab <- table(db_clean$neighbourhood)
Neighbourhood_p <- round((prop.table(Neighbourhood_tab)*100),1)
n <- c(as.numeric(Neighbourhood_tab[1]),as.numeric(Neighbourhood_tab[2]),
       as.numeric(Neighbourhood_tab[3]),as.numeric(Neighbourhood_tab[4]),
       as.numeric(Neighbourhood_tab[5]),as.numeric(Neighbourhood_tab[6]))
Percentagem <- c(as.numeric(Neighbourhood_p[1]),as.numeric(Neighbourhood_p[2]),
                 as.numeric(Neighbourhood_p[3]),as.numeric(Neighbourhood_p[4]),
                 as.numeric(Neighbourhood_p[5]),as.numeric(Neighbourhood_p[6]))
table2 <- data.frame(Neighbourhood,n,Percentagem)
ftable_2 <- flextable(head(table2))

ftable_2 <- bg(ftable_2, bg = "#ce2029", part = "header")
ftable_2 <- color(ftable_2, color = "white", part = "header")
ftable_2 <- bold(ftable_2, bold = TRUE, part="header")
ftable_2 <- set_header_labels(ftable_2, Neighbourhood = 'Bairros (por Regiões)',n = 'n',Percentagem = '%')
ftable_2 <- autofit(ftable_2)
# ftable_2 # -> Ver output no RStudio
table2

# Todos os boxplots das variáveis numéricas 
par(mfrow = c(2, 3))
boxplot(db_clean$host_id, main = "Boxplot Host_ID", xlab = "Host_ID")
boxplot(db_clean$price, main = "Boxplot Price", xlab = "Price")
boxplot(db_clean$minimum_nights, main = "Boxplot Minimum_Nights", xlab = "Minimum_Nights")
boxplot(db_clean$number_of_reviews, main = "Boxplot Number_of_Reviews", xlab = "Number_of_Reviews")
boxplot(db_clean$calculated_host_listings_count, main = "Boxplot Calculated_Host_Listings", xlab = "Calculated_Host_Listings")
boxplot(db_clean$availability_365, main = "Boxplot Availability_365", xlab = "Availability_365")

# Todos os histograma das variáveis numéricas 
par(mfrow = c(2, 3))
hist(db_clean$host_id, freq = FALSE, main = "Histograma Host_ID", xlab = "Host_ID")
lines(density(db_clean$host_id), lwd = 2, col = '#a40000')

hist(db_clean$price, freq = FALSE, main = "Histograma Price", xlab = "Price")
lines(density(db_clean$price), lwd = 2, col = '#a40000')

hist(db_clean$minimum_nights, freq = FALSE, main = "Histograma Minimum_Nights", xlab = "Minimum_Nights")
lines(density(db_clean$minimum_nights), lwd=2, col='#a40000')

hist(db_clean$number_of_reviews, freq = FALSE, main = "Histograma Number_of_Reviews", xlab = "Number_of_Reviews")
lines(density(db_clean$number_of_reviews), lwd = 2, col = '#a40000')

hist(db_clean$calculated_host_listings_count, freq = FALSE, main = "Histograma Calculated_Host_Listings", xlab = "Calculated_Host_Listings")
lines(density(db_clean$calculated_host_listings_count), lwd = 2, col = '#a40000')

hist(db_clean$availability_365, freq = FALSE, main = "Histograma Availability_365", xlab = "Availability_365")
lines(density(db_clean$availability_365), lwd=2, col = '#a40000')

# Correlação de Pearson entre as variáveis

# Para calcular a correlação transformámos as variáveis todas em númericas, 
# criando um novo data.frame, ao qual designamos db_clean_cor
db_clean_cor <- db_clean
db_clean_cor$neighbourhood <- as.numeric(db_clean_cor$neighbourhood)
db_clean_cor$room_type <- as.numeric(db_clean_cor$room_type)

cor <- round(cor(db_clean_cor), digits = 2) 
cor

# Representação da Matriz de Correlação
corrplot(cor, 
         method = "number",
         tl.col = "black",
         type = "upper")

# Eliminar NAs
db_model <- na.omit(db_clean)
nrow(db_clean) # Não há NAs para eliminar

# Homogenizar os índices das linhas sem os NAs
rownames(db_clean) <- c(1:nrow(db_clean))

# Modelo de Regressão Linear Múlipla com todas as variáveis
fit <- lm(price ~., data = db_clean)
summary(fit)

# Verificamos se temos Multicolinearidade
vif(fit)

# Escolha do Modelo de Regressão que melhor se ajusta aos dados com base no p-value
ols_step_both_p(fit)

# Escolha do Modelo de Regressão que melhor se ajusta aos dados com base no AIC
ols_step_both_aic(fit)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit$residuals)              # Média Nula
bptest(fit)                      # Variância Constante
bgtest(fit)                      # Ausência de Correlação
jarque.bera.test(fit$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
par(mfrow=c(2,2)) 
plot(fit)

# Verificar os valores destacados nos gráficos acima
db_clean[c(2356,4510,4255, 1997,2001),]

# Vamos fazer um Teste de Outlier para o modelo
outlierTest(fit)

db_clean[c(2356,4513,4258,317,1040,4495,4436,834,307,967),]

# Vamos ver se existem Elementos Influenciadores 
influenceIndexPlot(fit)

# Distância de Cook
cooksd <- cooks.distance(fit)

# Detetar se existem Influenciadores
influential <- as.numeric(names(cooksd)[(cooksd > 4*mean(cooksd, na.rm=T))])

# Visualizar os Influenciadores
head(db_clean[influential, ])

# Antes de eliminar
nrow(db_clean)

# Eliminar os Outliers influencers e criar um novo data.frame, db_model
db_model <- db_clean[-influential, ]

# Confirmação
nrow(db_clean) - nrow(as.data.frame(influential))
nrow(db_model)

rownames(db_model) <- c(1:nrow(db_model))
names(db_model)

# Retirar a variável availability_365
db_model <- db_model[-c(8)]

# Variável Neighbourhood - factor para chr  
db_model$neighbourhood <- as.character(db_model$neighbourhood)
db_model <- as.data.frame(db_model)

db_model[db_model$neighbourhood == 'Harbor Islands', ]

# Apagar o termo "Harbor Islands"
db_model[db_model$neighbourhood == 'Harbor Islands', ] <- NA

# chr para factor novamente, e confirmação dos novos níveis
db_model$neighbourhood <- as.factor(db_model$neighbourhood)
levels(db_model$neighbourhood)

# Eliminar NAs
db_model <- na.omit(db_model)
nrow(db_model) # Não há NAs para eliminar

# Homogenizar os índices das linhas sem os NAs
rownames(db_model) <- c(1:nrow(db_model))

# Fit 2 - Modelo de Regressão Linear Múlipla para a base de dados sem outliers
#         e sem as variáveis não significativas
fit2 <- lm(price ~., data = db_model)
summary(fit2)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit2$residuals)              # Média Nula
bptest(fit2)                      # Variância Constante
bgtest(fit2)                      # Ausência de Correlação
jarque.bera.test(fit2$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
par(mfrow=c(2,2)) 
plot(fit2)

crPlots(fit2)

# Fit 3 | Adicionámos um termo de não-linearidade na variável minimum_nights
#         e logaritmizámos o preço e o calculated_host_listings_count
fit3 <- lm(log(price) ~ host_id + neighbourhood + room_type +
            number_of_reviews + poly(minimum_nights, 3, raw=FALSE) +
            log(calculated_host_listings_count) + license, data = db_model)
summary(fit3)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit3$residuals)              # Média Nula
bptest(fit3)                      # Variância Constante
bgtest(fit3)                      # Ausência de Correlação
jarque.bera.test(fit3$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
par(mfrow=c(2,2)) 
plot(fit3)

# Verificar os valores destacados nos gráficos acima
db_model[c(2079,1869,598,2219,2462,4403),]

# Gráficos com a componente resídual de cada variável
crPlots(fit3)

# Retirar a variável host_id do data.frame db_model
db_model_2 <- db_model[-1]

# Ver os fatores da variável room_type
levels(db_model_2$room_type)

# Variável Room_Type - factor para chr  
db_model_2$room_type <- as.character(db_model_2$room_type)
db_model_2 <- as.data.frame(db_model_2)

db_model_hotel_room <- db_model[db_model$room_type == 'Hotel room', ]
db_model_hotel_room

# Apagar o fator "Hotel room"
db_model_2[db_model_2$room_type == 'Hotel room', ] <- NA

# chr para factor novamente, e confirmação dos novos níveis
db_model_2$room_type <- as.factor(db_model_2$room_type)
levels(db_model_2$room_type)

# Eliminar NAs
db_model_2 <- na.omit(db_model_2)
nrow(db_model_2) # Não há NAs para eliminar

# Homogenizar os índices das linhas sem os NAs
rownames(db_model_2) <- c(1:nrow(db_model_2))

# Fit 4 | Adicionámos um termo de não-linearidade 
#         (para a variável number_of_reviews)
fit4 <- lm(log(price) ~ neighbourhood + room_type +
           poly(number_of_reviews, 3, raw=FALSE) +
           poly(minimum_nights, 3, raw=FALSE) +
           log(calculated_host_listings_count) + license, data = db_model_2)
summary(fit4)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit4$residuals)              # Média Nula
bptest(fit4)                      # Variância Constante
bgtest(fit4)                      # Ausência de Correlação
jarque.bera.test(fit4$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
par(mfrow=c(2,2)) 
plot(fit4)

# Verificar os valores destacados nos gráficos acima
db_model_2[c(250,202,2216, 3381),]

crPlots(fit4)

# Definimos os pesos - Termo que vai dividir os dois lados da equação
N <- length(db_model_2$price) # Pesos

# Modelo de Regressão - para adicionar os pesos usamos a opção "weights=..."
fit_c_pesos <- lm(log(price) ~ neighbourhood + room_type +
                  poly(number_of_reviews, 3, raw=FALSE) +
                  poly(minimum_nights, 3, raw=FALSE) +
                  log(calculated_host_listings_count) + license, 
                  data = db_model_2,
                  weights = 1/((1:N)^0.5))
summary(fit_c_pesos)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit_c_pesos$residuals)              # Média Nula
bptest(fit_c_pesos)                      # Variância Constante
bgtest(fit_c_pesos)                      # Ausência de Correlação
jarque.bera.test(fit_c_pesos$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
par(mfrow=c(2,2)) 
plot(fit_c_pesos)

# Alterando os pesos usados
h <- sqrt(fit4$residuals^2)

# Modelo de Regressão - para adicionar os pesos usamos a opção "weights=..."
fit_c_pesos_2 <- lm(log(price) ~ neighbourhood + room_type +
                    poly(number_of_reviews, 3, raw=FALSE) +
                    poly(minimum_nights, 3, raw=FALSE) +
                    log(calculated_host_listings_count) + license,
                    data = db_model_2,
                    weights = 1/h)

summary(fit_c_pesos_2)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit_c_pesos_2$residuals)              # Média Nula
bptest(fit_c_pesos_2)                      # Variância Constante
bgtest(fit_c_pesos_2)                      # Ausência de Correlação
jarque.bera.test(fit_c_pesos_2$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
par(mfrow=c(2,2)) 
plot(fit_c_pesos_2)

# Distância de Cook
cooksd <- cooks.distance(fit_c_pesos_2)

# Detetar se existem influenciadores
influential <- as.numeric(names(cooksd)[(cooksd > 4*mean(cooksd, na.rm=T))])

nrow(db_model_2)- nrow(as.data.frame(influential))

# Visualizar os influenciadores
head(db_model_2[influential, ])

# Eliminar os Outliers influencers
db_model_3 <- db_model_2[-influential, ]

nrow(db_model_3)

# Eliminar NAs
db_model_3 <- na.omit(db_model_3)

# Homogenizar os índices das linhas sem os NAs
rownames(db_model_3) <- c(1:nrow(db_model_3))

# Repetir o Fit 6, mas com menos outliers

# Alterando os pesos usado
fit4 <- lm(log(price) ~ neighbourhood + room_type +
           poly(number_of_reviews, 3, raw=FALSE) +
           poly(minimum_nights, 3, raw=FALSE) +
           log(calculated_host_listings_count) + license, data = db_model_3)

h <- sqrt(fit4$residuals^2)

# Modelo de Regressão - para adicionar os pesos usamos a opção "weights=..."
fit_c_pesos_3 <- lm(log(price) ~ neighbourhood + room_type +
                    poly(number_of_reviews, 3, raw=FALSE) +
                    poly(minimum_nights, 3, raw=FALSE) +
                    log(calculated_host_listings_count) + license,
                    data = db_model_3,
                    weights = 1/h)

summary(fit_c_pesos_3)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit_c_pesos_3$residuals)              # Média Nula
bptest(fit_c_pesos_3)                      # Variância Constante
bgtest(fit_c_pesos_3)                      # Ausência de Correlação
jarque.bera.test(fit_c_pesos_3$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
par(mfrow=c(2,2)) 
plot(fit_c_pesos_3)

# Última tentativa, alterando os pesos

# Alterando os pesos usados
resi1 <- fit_c_pesos_3$residuals
varfunc.ols <- lm((resi1^2) ~ ., data = db_model_3)
varfunc1 <- (varfunc.ols$fitted.values)

fit_c_pesos_4 <- lm(log(price) ~ neighbourhood + room_type +
                   poly(number_of_reviews, 3, raw=FALSE) +
                   poly(minimum_nights, 3, raw=FALSE) +
                   log(calculated_host_listings_count) + license,
                   data = db_model_3, 
                   weights = 1/sqrt((varfunc1^8)))

summary(fit_c_pesos_4)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit_c_pesos_4$residuals)              # Média Nula
bptest(fit_c_pesos_4)                      # Variância Constante
bgtest(fit_c_pesos_4)                      # Ausência de Correlação
jarque.bera.test(fit_c_pesos_4$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
par(mfrow=c(2,2)) 
plot(fit_c_pesos_4)

# Plot numa matriz 4*2
options(repr.plot.width = 10, repr.plot.height = 15)
par(mfrow = c(4, 2))

# ------------------------------ Fit 1  --------------------------------------
# Gráfico comparativo entre o Valor Verdadeiro e o Valor Predito e MAPE 
pr1 <-predict(fit, db_clean)
plot(pr1, type = "b", frame = FALSE, pch = 19, 
     col = "red", xlab = "x", ylab = "y", xlim=c(0,200))
lines(db_clean$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão 
actual1<-db_clean$price
prediction1 <- (fit$fitted.values)
n<-length(db_clean$price)
MAPE1 <- (1/n) * sum(abs((actual1 - prediction1)/actual1))
# ----------------------------------------------------------------------------

# ------------------------------ Fit 2  --------------------------------------
# Gráfico comparativo entre o Valor Verdadeiro e o Valor Predito e MAPE 
pr2 <-predict(fit2, db_model)
plot(pr2, type = "b", frame = FALSE, pch = 19, 
     col = "red", xlab = "x", ylab = "y",xlim=c(0,200))
lines(db_model$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual2<-db_model$price
prediction2 <- (fit2$fitted.values)
n<-length(db_model$price)
MAPE2 <- (1/n) * sum(abs((actual2 - prediction2)/actual2))
# ----------------------------------------------------------------------------

# ------------------------------ Fit 3  --------------------------------------
# Gráfico comparativo entre o Valor Verdadeiro e o Valor Predito e MAPE 
pr3 <-predict(fit3,db_model)
plot(exp(pr3), type = "b", frame = FALSE, pch = 19, 
     col = "red", xlab = "x", ylab = "y",xlim=c(0,200))
lines(db_model$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual3<-db_model$price
prediction3 <- exp(fit3$fitted.values)
n<-length(db_model$price)
MAPE3 <- (1/n) * sum(abs((actual3 - prediction3)/actual3))
# ----------------------------------------------------------------------------

# ------------------------------ Fit 4  --------------------------------------
# Gráfico comparativo entre o Valor Verdadeiro e o Valor Predito e MAPE 
pr4 <-predict(fit4,db_model_3)
plot(exp(pr4), type = "b", frame = FALSE, pch = 19, 
     col = "red", xlab = "x", ylab = "y",xlim=c(0,200))
lines(db_model_3$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual4<-db_model_3$price
prediction4 <- exp(fit4$fitted.values)
n<-length(db_model_3$price)
MAPE4 <- (1/n) * sum(abs((actual4 - prediction4)/actual4))
# ----------------------------------------------------------------------------


# ------------------------------ Fit 5  --------------------------------------
pr5 <-predict(fit_c_pesos, db_model_2)
plot(exp(pr5), type = "b", frame = FALSE, pch = 19, 
     col = "red", xlab = "x", ylab = "y", xlim=c(0,200))
lines(db_model_2$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual5<-db_model_2$price
prediction5 <- (fit_c_pesos$fitted.values)
n<-length(db_model_2$price)
MAPE5 <- (1/n) * sum(abs((actual5 - prediction5)/actual5))
# ----------------------------------------------------------------------------


# ------------------------------ Fit 6  --------------------------------------
pr6 <-predict(fit_c_pesos_2,db_model_2)
plot(exp(pr6), type = "b", frame = FALSE, pch = 19, 
     col = "red", xlab = "x", ylab = "y",xlim=c(0,200))
lines(db_model_2$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual6<-db_model_2$price
prediction6 <- exp(fit_c_pesos_2$fitted.values)
n<-length(db_model_2$price)
MAPE6 <- (1/n) * sum(abs((actual6 - prediction6)/actual6))
# ----------------------------------------------------------------------------

# ------------------------------ Fit 7  --------------------------------------
pr7 <-predict(fit_c_pesos_3, db_model_3)
plot(exp(pr7), type = "b", frame = FALSE, pch = 19, 
     col = "red", xlab = "x", ylab = "y",xlim=c(0,200))
lines(db_model_3$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual7<-db_model_3$price
prediction7 <- exp(fit_c_pesos_3$fitted.values)
n<-length(db_model_3$price)
MAPE7 <- (1/n) * sum(abs((actual7 - prediction7)/actual7))
# ----------------------------------------------------------------------------

# ------------------------------ Fit 8  --------------------------------------
pr8 <-predict(fit_c_pesos_4,db_model_3)
plot(exp(pr8), type = "b", frame = FALSE, pch = 19, 
     col = "red", xlab = "x", ylab = "y",xlim=c(0,200))
lines(db_model_3$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual8<-db_model_3$price
prediction8 <- exp(fit_c_pesos_4$fitted.values)
n<-length(db_model_3$price)
MAPE8 <- (1/n) * sum(abs((actual8 - prediction8)/actual8))
# ----------------------------------------------------------------------------

# Data.Frame (Fit, Erros Residuais, R^2 , AIC, BIC e MAPE)
fits <- c("fit1","fit2","fit3","fit4","fit_c_pesos","fit_c_pesos_2","fit_c_pesos_3","fit_c_pesos_4")

AIC <- round(c(AIC(fit), AIC(fit2), AIC(fit3), AIC(fit4), AIC(fit_c_pesos), 
         AIC(fit_c_pesos_2), AIC(fit_c_pesos_3), AIC(fit_c_pesos_4)),0)

BIC <- round(c(BIC(fit), BIC(fit2), BIC(fit3), BIC(fit4), BIC(fit_c_pesos), 
         BIC(fit_c_pesos_2), BIC(fit_c_pesos_3), BIC(fit_c_pesos_4)),0)

Erros_Residuais <-round(c(summary(fit)$sigma, summary(fit2)$sigma, 
               summary(fit3)$sigma, summary(fit4)$sigma, 
               summary(fit_c_pesos)$sigma, summary(fit_c_pesos_2)$sigma, 
               summary(fit_c_pesos_3)$sigma, summary(fit_c_pesos_4)$sigma),3)

R_quadrado <- round(c(summary(fit)$r.squared, summary(fit2)$r.squared, 
               summary(fit3)$r.squared,summary(fit4)$r.squared, 
               summary(fit_c_pesos)$r.squared, summary(fit_c_pesos_2)$r.squared, 
               summary(fit_c_pesos_3)$r.squared, summary(fit_c_pesos_4)$r.squared),3)

MAPE <- round(c(MAPE1,MAPE2,MAPE3,MAPE4,MAPE5,MAPE6,MAPE7,7.11e+23),3)

table3 <- data.frame(fits, Erros_Residuais, R_quadrado, AIC, BIC, MAPE)

ftable_3 <- flextable(head(table3))

ftable_3 <- bg(ftable_3, bg = "#ce2029", part = "header")
ftable_3 <- color(ftable_3, color = "white", part = "header")
ftable_3 <- bold(ftable_3, bold = TRUE, part="header")
ftable_3 <- set_header_labels(ftable_3,
                              fits = 'Modelo',
                              Erros_Residuais = 'Erro Residual',
                              R_quadrado = 'R Quadrado',
                              AIC = 'AIC',
                              BIC = 'BIC',
                              MAPE = 'MAPE')

ftable_3 <- autofit(ftable_3) # -> Ver output no RStudio
# ftable_3
table3 

# Criamos um novo data.frame com base no db_clean
db_model_final <- db_clean[-c(1,6,7,8)]

# Variável Room_Type e Neighbourhood - factor para chr  
db_model_final$room_type <- as.character(db_model_final$room_type)
db_model_final$neighbourhood <- as.character(db_model_final$neighbourhood)
db_model_final <- as.data.frame(db_model_final)

# Restringir às zonas de South Boston e Center Boston (as que têm mais obs.)
#               e aos room_type de Entire home/apt e Private room
db_model_final <- db_model_final[which(
    db_model_final$neighbourhood == "South Boston" & db_model_final$room_type == "Entire home/apt"|
    db_model_final$neighbourhood == "South Boston" & db_model_final$room_type == "Private room" |
    db_model_final$neighbourhood == "West Boston" & db_model_final$room_type == "Private room" |
    db_model_final$neighbourhood == "West Boston" & db_model_final$room_type == "Entire home/apt" |
    db_model_final$neighbourhood == "Center Boston" & db_model_final$room_type == "Private room" |
    db_model_final$neighbourhood == "Center Boston" & db_model_final$room_type == "Entire home/apt"),]

# chr para factor novamente, e confirmação dos novos níveis
db_model_final$room_type <- as.factor(db_model_final$room_type)
db_model_final$neighbourhood <- as.factor(db_model_final$neighbourhood)

levels(db_model_final$room_type)
levels(db_model_final$neighbourhood)

# Eliminar NAs
db_model_final <- na.omit(db_model_final)

# Homogenizar os índices das linhas sem os NAs
rownames(db_model_final) <- c(1:nrow(db_model_final))
nrow(db_model_final)

# Proporção em % de linhas comparada com o dataset orignal
paste(round((((nrow(db_model_final))/nrow(db))*100),1),"%")

# Primeiras observações do data.frame db_model_final
head(db_model_final)

# Usamos a biblioteca "caTools" para fazer o split (divisão) 
# da amostra em conjunto de treino e teste
set.seed(123)
separar <- sample.split(db_model_final, SplitRatio = 0.90)
train <- db_model_final[separar,]
test <- db_model_final[!(separar),]

# Eliminar NAs do Conjunto de Treino e do Conjunto de Teste
train <- na.omit(train)
test <- na.omit(test)

# Homogenizar os índices das linhas sem os NAs
rownames(train) <- c(1:nrow(train))
rownames(test) <- c(1:nrow(test))

# Verificar o nº de observações de cada conjunto
# Conjunto de Treino
paste("O Conjunto de Treino tem", nrow(train),"observações.")

# Conjunto de Teste
paste("O Conjunto de Teste tem", nrow(test),"observações.")

# Confirmação das Variáveis em Estudo
names(db_model_final)

# Modelo Final - Utilizámos já o log nas variáveis númericas, pois sabemos de
#                antemão que estas são deveras simétricas 
fit_f <- lm(log(price) ~ neighbourhood + room_type + 
            log(minimum_nights) + license ,data = train)
summary(fit_f)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit_f$residuals)              # Média Nula
bptest(fit_f)                      # Variância Constante
bgtest(fit_f)                      # Ausência de Correlação
jarque.bera.test(fit_f$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
options(repr.plot.width = 10, repr.plot.height = 10)
par(mfrow=c(2,2)) 
plot(fit_f)

train[c(1565,728,581,3245,2858), ]

# Visualização do Boxplot da Variável Price e Minimum Nights
options(repr.plot.width = 10, repr.plot.height = 6)
par(mfrow=c(1,2)) 
outliers_price <- boxplot(train$price, 
                          xlab = "$",
                          main = "Boxplot da Variável Price")
outliers_minimum_nights <- boxplot(train$minimum_nights, 
                                   xlab = "Número de Noites",
                                   main = "Boxplot da Variável Minimum Nights")

# Eliminar os Outliers (da Variável Price)
outliers_price <- boxplot(train$price, plot=FALSE)$out
# train[which(train$price %in% outliers_price),]
train2 <- train[-which(train$price %in% outliers_price),]

# Eliminar os Outliers (da Variável Minimum Nights)
outliers_minimum_nights <- boxplot(train2$minimum_nights, plot=FALSE)$out
# train[which(train$minimum_nights %in% outliers_minimum_nights),]
train2 <- train2[-which(train2$minimum_nights %in% outliers_minimum_nights),]

# Visualização do Boxplot da Variável Price sem Outliers significativos
options(repr.plot.width = 10, repr.plot.height = 6)
par(mfrow=c(1,2)) 

boxplot(train2$price, 
        xlab = "$",
        main = "Boxplot da Variável Price")

boxplot(train2$minimum_nights, 
        xlab = "Número de Noites", 
        main = "Boxplot da Variável Minimum Nights")

# Modelo Final 2 | Igual ao anterior, mas sem os outliers
fit_f_2 <- lm(log(price) ~ neighbourhood + room_type + 
              log(minimum_nights) + license ,data = train2)
summary(fit_f_2)

# Verificação dos Pressupostos dos Resíduos (Testes e Gráficos)
mean(fit_f_2$residuals)              # Média Nula
bptest(fit_f_2)                      # Variância Constante
bgtest(fit_f_2)                      # Ausência de Correlação
jarque.bera.test(fit_f_2$residuals)  # Distribuição Normal

# Representação Gráfica sobre os Resíduos
options(repr.plot.width = 10, repr.plot.height = 10)
par(mfrow=c(2,2)) 
plot(fit_f_2)

# Média dos Resíduos
mean(fit_f$residuals)

# Teste de Breusch-Pagan (H0: Resíduos Homocedásticos)
bptest(fit_f)

# Teste de Breusch-Godfrey (H0: Resíduos Independentes)
bgtest(fit_f)

# Teste de Jarque-Bera (H0: Distribuição Normal)
jarque.bera.test(fit_f$residuals)

# Previsão sobre o db_model_final | Previsão in-sample
pr_f <-predict(fit_f,train)

options(repr.plot.width = 10, repr.plot.height = 8)
plot(exp(pr_f), type = "b", frame = FALSE, pch = 19,
     col = "red", xlab = "x", ylab = "y", xlim=c(0,200),
     main = "Previsão In-Sample")
lines(train$price, pch = 18, col = "blue", 
      type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual_f<-train$price
prediction_f <- exp(fit_f$fitted.values)
n<-length(train$price)
MAPE_f_is <- (1/n) * sum(abs((actual_f - prediction_f)/actual_f))
MAPE_f_is

# Previsão sobre o Conjunto de Teste | Previsão out-of-sample
pr_f_ofs <-predict(fit_f,test)
plot(exp(pr_f_ofs), type = "b", frame = FALSE, pch = 19, xlim=c(0,200),
     col = "red", xlab = "x", ylab = "y", main = "Previsão Out-of-Sample")
lines(test$price, pch = 18, col = "blue", type = "b", lty = 2, xlim=c(0,200))
legend("topleft", legend=c("Prediction", "True value"), 
       col=c("red", "blue"), lty = 1:2, cex=0.8)

# Erro de Previsão
actual_f_ofs<-test$price
prediction_f_ofs <- exp(pr_f_ofs)
n<-length(test$price)

# o MAPE é uma das melhores métricas, pois é dada por uma percentagem (não é dependente de escala)
MAPE_f_ofs <- (1/n) * sum(abs((actual_f_ofs - prediction_f_ofs)/actual_f_ofs))
MAPE_f_ofs

# Data.Frame (Fit, Erros Residuais, R^2 , AIC, BIC e MAPE) do Modelo Final
fits <- c("fit_f")
AIC <- round(c(AIC(fit_f)),0)
BIC <- round(c(BIC(fit_f)),0)
Erros_Residuais <-round(c(summary(fit_f)$sigma),3)
R_quadrado <- round(c(summary(fit_f)$r.squared),3)
MAPE_IS <- round(c(MAPE_f_is),3)
MAPE_OFS <- round(c(MAPE_f_ofs),3)

table_f <- data.frame(fits, Erros_Residuais, R_quadrado, AIC, BIC, MAPE_IS, MAPE_OFS)

ftable_f <- flextable(head(table_f))

ftable_f <- bg(ftable_f, bg = "#ce2029", part = "header")
ftable_f <- color(ftable_f, color = "white", part = "header")
ftable_f <- bold(ftable_f, bold = TRUE, part="header")
ftable_f <- set_header_labels(ftable_f,
                              fits = 'Modelo',
                              Erros_Residuais = 'Erro Residual',
                              R_quadrado = 'R Quadrado',
                              AIC = 'AIC',
                              BIC = 'BIC',
                              MAPE_IS = 'MAPE IS',
                              MAPE_OFS = "MAPE OFS")

ftable_f <- autofit(ftable_f) # -> Ver output no RStudio
# ftable_f
table_f 
