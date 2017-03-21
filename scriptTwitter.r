library("RMySQL")
library("ggplot2")
library("data.table")
library("lubridate")
library("write.table")

#Windows
#con <- dbConnect(MySQL(),
#                 user = "root", password = "",
#                 dbname = "contasTwitter", host = "localhost")

#Mac
con <- dbConnect(MySQL(),
                 user = "root", password = "root",
                 dbname = "tweets", host = "localhost",
                 unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")


rs <- dbSendQuery(con, "SELECT * FROM Accounts")

data <- fetch(rs, n=-1)

dbDisconnect(con)

#Prepara as informações vindas da consulta principal do MySQL
DATA_DT <- data.table(data)
DATA_DT$created_at <- ymd_hms(DATA_DT$created_at)

#DATA_DT <- DATA_DT %>% distinct(screenName, .keep_all = TRUE)


# Gráfico de log comparando tweets com followers e likes para checar relação
# Abaixo da linha = pessoas com poucos seguidores, muitos tweets e alto numero de likes maior que numero de seguidores
# - pessoas que sejam acima da linha e azuis, são os possíveis influenciadores
# - pessoas que sejam acima da linha e pretos, são os possíveis falsos influenciadores (celebridades)
# Acima da linha = pessoas com muitos seguidores, poucos tweets e baixo numero de likes maior que numero de seguidores
# - pessoas que sejam abaixo da linha e pretos, são os possíveis atuais 
# Geral
#ggplot(DATA_DT,aes(log(1+statusCount),log(1+followersCount), color=log(1+likesCount/followersCount)))+geom_point()+geom_smooth()

# Excluindo zeros
# Remove 0s
semzero <- DATA_DT[followersCount > 10 & statusCount > 0]
ggplot(semzero,aes(log(1+statusCount),log(1+followersCount), color=log(1+likesCount/followersCount))) +
  labs(color = "Numero de Likes / Numero de Seguidores") +
  geom_point() + 
  geom_smooth() + 
  geom_vline(xintercept = 7.5) +
  geom_hline(yintercept = 10) +
  ylab("Log do Numero de Seguidores") +
  xlab("Log do Numero de Tweets")


igualazero <- DATA_DT[followersCount == 0]
menorigualdez <- DATA_DT[followersCount <= 10]
menorigualacem <- DATA_DT[followersCount <= 100]
maiorigualdoismil <- DATA_DT[followersCount >= 2000]

igualazeroPerc <- nrow(igualazero) / 255860
menorigualdezPerc <- nrow(menorigualdez) / 255860
menorigualacemPerc <- nrow(menorigualacem) / 255860
maiorigualdoismilPerc <- nrow(maiorigualdoismil) / 255860

# Teste para verificar registros outliers
foo <- DATA_DT[followersCount >= 1 & statusCount == 0][order(-statusCount)]

# Médias
mediaSeguidores <- mean(DATA_DT$followersCount)
mediaSeguindo <- mean(DATA_DT$followingCount)
mediaPostagens <- mean(DATA_DT$statusCount)


#
#foo <- DATA_DT[followersCount >= mediaSeguidores & statusCount >= mediaPostagens][order(-statusCount)]


#what <- foo[statusCount > 1000000]

#ggplot(foo,aes(log(statusCount),log(followersCount)))+geom_point()+geom_smooth()



ggplot(DATA_DT[followersCount > 100], aes(followersCount)) + geom_histogram(binwidth = 100) 


#> length(DATA_DT[followersCount==0]$followersCount)
#> length(DATA_DT[followersCount<=10]$followersCount)
#> length(DATA_DT[followersCount<=100]$followersCount)
#> mean(DATA_DT$followersCount)
#> length(DATA_DT[followersCount>=2000]$followersCount)

#ggplot(DATA_DT[followersCount < 10000], aes(followersCount)) + geom_histogram(bins = 100)
ggplot(DATA_DT[followersCount > 0], aes(log(1+followersCount))) + geom_histogram(bins = 100) + xlab("Log do Numero de Seguidores") + ylab("Quantidade")
# ggplot(DATA_DT[statusCount > 0], aes(log(1+statusCount))) + geom_histogram(bins = 100)
# ggplot(DATA_DT[likesCount > 0], aes(log(1+likesCount))) + geom_histogram(bins = 100)



### QUADRANTES

#Q1 - Status < 7.5 e Followers < 10
#Q2 - Status > 7.5 e Followers < 10
#Q3 - Status > 7.5 e Followers > 10
#Q4 - Status < 7.5 e Followers > 10


### Q1
q1 <- DATA_DT[(log(1+statusCount) <= 7.5 &  log(1+followersCount) <= 10)]

q1AcimaRazao <- q1[log(1+likesCount/followersCount) >= 4.1]
q1AbaixoRazao <- q1[log(1+likesCount/followersCount) <= 4]
q1MaisTweets <- q1[statusCount > 1700]
 ggplot(q1[statusCount > 1], aes(log(1+statusCount))) + 
   geom_histogram(bins = 100) + 
   geom_vline(data = q1, aes(xintercept = mean(log(1+statusCount))), linetype = "dashed") + 
   geom_vline(data = q1, aes(xintercept =  mean(log(1+statusCount)) + 1.4 * sd(log(1+statusCount))))  +
   ylab("Quantidade") +
   xlab("Log do Numero de Tweets")
q1MaisTweets <- q1[log(1+statusCount) >= 7.48]
q1MaisTweets$Quadrante <- "Q1"
q1Contas <- subset(q1MaisTweets, select=c("screenName","Quadrante"))


#em torno de status > 1770
#xlab("Q1 - Calda longa, porem com muitos registros.")

### Q2
q2 <- DATA_DT[(log(1+statusCount) >= 7.5 &  log(1+followersCount) <= 10)]
q2AcimaRazao <- q2[log(1+likesCount/followersCount) >= 4.1]
q2AbaixoRazao <- q2[log(1+likesCount/followersCount) <= 4]
q2MaisTweets <- q2[log(1+statusCount) > 6.25]
ggplot(q2[statusCount > 1], aes(log(1+statusCount))) + 
  geom_histogram(bins = 100) + 
  geom_vline(data = q2, aes(xintercept = mean(log(1+statusCount))), linetype = "dashed") + 
  geom_vline(data = q2, aes(xintercept =  mean(log(1+statusCount)) + 2.99 * sd(log(1+statusCount)))) +
  ylab("Quantidade") +
  xlab("Log do Numero de Tweets")
q2MaisTweets <- q2[log(1+statusCount) >= 11.7]
q2MaisTweets$Quadrante <- "Q2"
q2Contas <- subset(q2MaisTweets, select=c("screenName","Quadrante"))
#Em torno de status > 120000


### Q3
q3 <- DATA_DT[(log(1+statusCount) > 7.5 &  log(1+followersCount) > 10)]
q3AcimaRazao <- q3[log(1+likesCount/followersCount) >= 4.1]
q3AbaixoRazao <- q3[log(1+likesCount/followersCount) <= 4]
q3MaisTweets <- q3[statusCount > 300000]
 ggplot(q3[statusCount > 1], aes(log(1+statusCount))) + 
   geom_histogram(bins = 100) + 
   geom_vline(data = q3, aes(xintercept = mean(log(1+statusCount))), linetype = "dashed") + 
   geom_vline(data = q3, aes(xintercept =  mean(log(1+statusCount)) + sd(log(1+statusCount)))) +
   ylab("Quantidade") +
   xlab("Log do Numero de Tweets")
q3MaisTweets <- q3[log(1+statusCount) >= 11]
q3MaisTweets$Quadrante <- "Q3"
q3Contas <- subset(q3MaisTweets, select=c("screenName","Quadrante"))
#Em torno de status > 60000

### Q4
q4 <- DATA_DT[(log(1+statusCount) < 7.5 &  log(1+followersCount) > 10)]
q4AcimaRazao <- q4[log(1+likesCount/followersCount) >= 4.1]
q4AbaixoRazao <- q4[log(1+likesCount/followersCount) <= 4]
q4MaisTweets <- q4[statusCount > 1700]
 ggplot(q4[statusCount > 1], aes(log(1+statusCount)))+
    geom_histogram(bins = 100) +
    geom_vline(data = q4, aes(xintercept = mean(log(1+statusCount))), linetype = "dashed") + 
    geom_vline(data = q4, aes(xintercept =  mean(log(1+statusCount)) + 1 * sd(log(1+statusCount)))) +
  ylab("Quantidade") +
  xlab("Log do Numero de Tweets")
q4MaisTweets <- q4[log(1+statusCount) >= 6]
q4MaisTweets$Quadrante <- "Q4"
q4Contas <- subset(q4MaisTweets, select=c("screenName","Quadrante"))
#Em torno de status > 400


contas <- rbind(q1Contas,q2Contas,q3Contas,q4Contas)

write.csv(contas, "/Users/Lucas/Desktop/contas.csv")