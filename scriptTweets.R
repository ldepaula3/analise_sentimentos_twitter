library("RMySQL")
library("ggplot2")
library("data.table")
library("lubridate")
library("stringr")
library("NLP")
library("tm")
library("wordcloud")
library("stringi")
library("plyr")
library("dplyr")
library("textcat")
#Windows
#con <- dbConnect(MySQL(),
#                 user = "root", password = "",
#                 dbname = "contasTwitter", host = "localhost")

#Mac
con <- dbConnect(MySQL(),
                 user = "root", password = "root",
                 dbname = "tweets", host = "localhost",
                 unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")

#Pega os tweets do airbnb apenas. Adiciona o quadrante para analise.
rs <- dbSendQuery(con, "SELECT C.screenName, T.tweet, C.quadrante, T.lang
                  FROM tweetAirbnbLang T 
                  INNER JOIN contasTweet C on C.screenName = T.screenName
                  AND T.tweet like '%airbnb%'")
tweets <- fetch(rs, n=-1)


#Remove duplicados
tweets <- tweets %>% distinct(tweet, .keep_all = TRUE)
tweetsContasDistintasAirbnb <- tweets %>% distinct(screenName, .keep_all = TRUE)

#Contagem de Idiomas
#ggplot(tweets, aes(lang)) + geom_histogram(stat = "count")

#Prepara as informações vindas da consulta principal do MySQL
tweetsAirbnb <- data.table(tweets)

contas <- dbSendQuery(con, "SELECT C.screenName, C.quadrante, A.followersCount, A.statusCount, A.likesCount 
                  FROM contasTweet C
                  INNER JOIN Accounts A on A.screenName = C.screenName ")

contasAirbnb <- fetch(contas, n=-1)
#Prepara as informações vindas da consulta principal do MySQL
contasAirbnb <- data.table(contasAirbnb)
contasAirbnb <- contasAirbnb %>% distinct(screenName, .keep_all = TRUE)

q1Total <- contasAirbnb[quadrante == 'Q1']
q2Total <- contasAirbnb[quadrante == 'Q2']
q3Total <- contasAirbnb[quadrante == 'Q3']
q4Total <- contasAirbnb[quadrante == 'Q4']

dbDisconnect(con)



#Retira conta do Airbnb Secundaria
tweetsAirbnb <- tweetsAirbnb[screenName != 'AirbnbHelp']

# Limpando tweets
clean_tweet = gsub("&amp", "", tweetsAirbnb$tweet)
clean_tweet = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", clean_tweet)
clean_tweet = gsub("RT ", "", clean_tweet)
clean_tweet <- str_replace_all(clean_tweet,"#[a-z,A-Z]*"," ") # Hashtags
clean_tweet <- str_replace_all(clean_tweet,"@[a-z,A-Z]*"," ")  # Arrobas
clean_tweet <- str_replace_all(clean_tweet, "http://t.co/[a-z,A-Z,0-9]*{10}","") # URL
clean_tweet <- str_replace_all(clean_tweet,"�","")
#clean_tweet = gsub("@", "", tweetsAirbnb$tweet)
clean_tweet = gsub('\x85', '', clean_tweet)
clean_tweet = gsub('(http[^ ]*)', '', clean_tweet)
clean_tweet = gsub("[[:punct:]]", " ", clean_tweet)
clean_tweet = gsub("[[:digit:]]", " ", clean_tweet)
clean_tweet = gsub("http\\w+", " ", clean_tweet)
clean_tweet = gsub("[ \t]{2,}", " ", clean_tweet)
clean_tweet = gsub("^\\s+|\\s+$", " ", clean_tweet) 
clean_tweet = gsub("\n", "", clean_tweet)
clean_tweet <- str_replace_all(clean_tweet," "," ") # Espacos
clean_tweet <- gsub("?","",clean_tweet, fixed = TRUE)  # Interrogacoes

#clean_tweet <- data.table(clean_tweet)

#Atribui limpeza ao dataset
tweetsAirbnb$limpo <- ''
tweetsAirbnb$tamanho <- 0
tweetsAirbnb$language <- ''
tweetsAirbnb$semSW <- ''
tweetsAirbnb$tamSW <- 0
count = 1

rm_words <- function(string, words) {
  stopifnot(is.character(string), is.character(words))
  spltted <- strsplit(string, " ", fixed = TRUE) # fixed = TRUE for speedup
  vapply(spltted, function(x) paste(x[!tolower(x) %in% words], collapse = " "), character(1))
}

spanish = "spanish"

for (t in clean_tweet){
  tweetsAirbnb[count]$limpo <- tolower(t)
  tweetsAirbnb[count]$tamanho <- nchar(t)
  tweetsAirbnb[count]$language <- textcat(t)
  #tweetsAirbnb[count]$semSW <- rm_words(tweetsAirbnb[count]$limpo, tm::stopwords("spanish"))[1] #Tira Stop Words  
  tweetsAirbnb[count]$semSW <- rm_words(tweetsAirbnb[count]$limpo, tm::stopwords("english"))[1] #Tira Stop Words 
  tweetsAirbnb[count]$tamSW <- nchar(tweetsAirbnb[count]$semSW)
  count = count + 1
}

mediaComSW <- mean(tweetsAirbnb$tamanho)
mediaSemSW <- mean(tweetsAirbnb$tamSW)

tweetsAirbnb[, c("tweet","limpo","semSW")][20:25]

#Verifica tweets 
tweetsAirbnb[, c("tweet","language")]
tweetsAirbnb[, c("tweet","limpo","semSW","language")][1:30]

userTweet <- merge(tweetsAirbnb, contasAirbnb, by=c("screenName"))
userTweet <- userTweet[, c("limpo","quadrante.x", "screenName")]

userTweet <- userTweet %>% distinct(limpo, .keep_all = TRUE)

write.table(userTweet, "contasAirbnbQuadrantes.csv", sep = "^")
df2 <- count(tweetsAirbnb, screenName)

# Maiores faladores do airbnb
qtds <- data.table(merge(df2,contasAirbnb,by=c("screenName")))[order(-n)]

write.table(qtds, "contasAirbnbQuadrantes.csv")

# Quem sao os 10 maiores em numeros de seguidores e quanto eles postaram.
q1 <- qtds[quadrante == 'Q1'][order(c(-n))]
somaQ1 <- sum(q1$n) #numero de tweets distintos

q2 <- qtds[quadrante == 'Q2'][order(c(-n))]
somaQ2 <- sum(q2$n)

q3 <- qtds[quadrante == 'Q3' & screenName != 'AirbnbHelp'][order(c(-n))]
somaQ3 <- sum(q3$n)

q4 <- qtds[quadrante == 'Q4'][order(c(-n))]
somaQ4 <- sum(q4$n) 

ggplot(qtds,aes(log(1+followersCount),log(1+n), color=log(statusCount/followersCount))) +geom_point()

tweetsCountQuadrante <- merge(q1,q2,q3,q4)

razaoQ1 <- somaQ1 / count(q1Total)$n
razaoQ2 <- somaQ2 / count(q2Total)$n
razaoQ3 <- somaQ3 / count(q3Total)$n
razaoQ4 <- somaQ4 / count(q4Total)$n
# Remover tweets repetidos
##### Pesquisar

# Media de tamanho dos tweets
mean(tweetsAirbnb$tamanho)

ggplot(tweetsAirbnb, aes(log(1+tamanho))) + geom_histogram(stat = "count")


#Quadrantes
q1ab <- airbnb[quadrante == 'Q1']
q1ab$dt <- substr(q1ab$data, 0, 10)
  #occurences <- data.table(table(unlist(q1ab$screenName)))
  #occurences[N > 10]
ggplot(q1ab, aes(dt)) + geom_histogram(stat = "count", bins=10)


q2ab <- airbnb[quadrante == 'Q2']
q3ab <- airbnb[quadrante == 'Q3']
q4ab <- airbnb[quadrante == 'Q4']

