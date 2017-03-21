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
                 dbname = "contasTwitterUber", host = "localhost",
                 unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")

#Pega os tweets do airbnb apenas. Adiciona o quadrante para analise.
rs <- dbSendQuery(con, "SELECT C.screenName, T.tweet, C.quadrante
                  FROM tweetUberLang T 
                  INNER JOIN UberAccountsTweet C on C.screenName = T.screenName
                  AND T.tweet like '%uber %' AND T.tweet not like '%youtuber%'")
tweets <- fetch(rs, n=-1)


#Remove duplicados
tweets <- tweets %>% distinct(tweet, .keep_all = TRUE)
tweetsContasDistintasUber <- tweets %>% distinct(screenName, .keep_all = TRUE)

#Prepara as informações vindas da consulta principal do MySQL
tweetsUber <- data.table(tweets)

contas <- dbSendQuery(con, "SELECT C.screenName, C.quadrante, A.followersCount, A.statusCount, A.likesCount 
                      FROM UberAccountsTweet C
                      INNER JOIN Accounts A on A.screenName = C.screenName")

contasUber <- fetch(contas, n=-1)
#Prepara as informações vindas da consulta principal do MySQL
contasUber <- data.table(contasUber)
contasUber <- contasUber %>% distinct(screenName, .keep_all = TRUE)
contasUber <- contasUber[screenName != 'Uber_Actualite']
contasUber <- contasUber[screenName != 'Uber_ARG']

q1Total <- contasUber[quadrante == 'Q1']
q2Total <- contasUber[quadrante == 'Q2']
q3Total <- contasUber[quadrante == 'Q3']
q4Total <- contasUber[quadrante == 'Q4']

dbDisconnect(con)



#Retira conta do Airbnb Secundaria
tweetsUber <- tweetsUber[screenName != 'Uber_Actualite']
tweetsUber <- tweetsUber[screenName != 'Uber_ARG']

# Limpando tweets
clean_tweet = gsub("&amp", "", tweetsUber$tweet)
clean_tweet = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", clean_tweet)
clean_tweet = gsub("RT ", "", clean_tweet)
clean_tweet <- str_replace_all(clean_tweet,"#[a-z,A-Z]*"," ") # Hashtags
clean_tweet <- str_replace_all(clean_tweet,"@[a-z,A-Z]*"," ")  # Arrobas
clean_tweet <- str_replace_all(clean_tweet, "http://t.co/[a-z,A-Z,0-9]*{10}","") # URL
clean_tweet <- str_replace_all(clean_tweet,"�","")
#clean_tweet = gsub("@", "", tweetsUber$tweet)
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
tweetsUber$limpo <- ''
tweetsUber$tamanho <- 0
tweetsUber$language <- ''
tweetsUber$semSW <- ''
tweetsUber$tamSW <- 0
count = 1

rm_words <- function(string, words) {
  stopifnot(is.character(string), is.character(words))
  spltted <- strsplit(string, " ", fixed = TRUE) # fixed = TRUE for speedup
  vapply(spltted, function(x) paste(x[!tolower(x) %in% words], collapse = " "), character(1))
}

spanish = "spanish"

for (t in clean_tweet){
  tweetsUber[count]$limpo <- tolower(t)
  tweetsUber[count]$tamanho <- nchar(t)
  tweetsUber[count]$language <- textcat(t)
  #tweetsUber[count]$semSW <- rm_words(tweetsUber[count]$limpo, tm::stopwords("spanish"))[1] #Tira Stop Words  
  tweetsUber[count]$semSW <- rm_words(tweetsUber[count]$limpo, tm::stopwords("english"))[1] #Tira Stop Words 
  #tweetsUber[count]$semSW <- rm_words(tweetsUber[count]$semSW, tm::stopwords("spanish")) #Tira Stop Words 
  tweetsUber[count]$tamSW <- nchar(tweetsUber[count]$semSW)
  count = count + 1
}


  
mediaComSW <- mean(tweetsUber$tamanho)
mediaSemSW <- mean(tweetsUber$tamSW)

tweetsUber[, c("tweet","limpo","semSW")][20:25]

#Verifica tweets 
tweetsUber[, c("tweet","language")]
tweetsUber[, c("tweet","limpo","semSW","language")][1:30]

userTweet <- merge(tweetsUber, contasUber, by=c("screenName"))
userTweet <- userTweet[, c("limpo","quadrante.x", "screenName")]

userTweet <- userTweet %>% distinct(limpo, .keep_all = TRUE)

write.table(userTweet, "contasUberQuadrantes.csv", sep = "^")
df2 <- count(tweetsUber, screenName)

# Maiores faladores do airbnb
qtds <- data.table(merge(df2,contasUber,by=c("screenName")))[order(-n)]

write.table(qtds, "contasUberQuadrantes.csv")

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
mean(tweetsUber$tamanho)

ggplot(tweetsUber, aes(log(1+tamanho))) + geom_histogram(stat = "count")


#Quadrantes
q1ab <- airbnb[quadrante == 'Q1']
q1ab$dt <- substr(q1ab$data, 0, 10)
#occurences <- data.table(table(unlist(q1ab$screenName)))
#occurences[N > 10]
ggplot(q1ab, aes(dt)) + geom_histogram(stat = "count", bins=10)


q2ab <- airbnb[quadrante == 'Q2']
q3ab <- airbnb[quadrante == 'Q3']
q4ab <- airbnb[quadrante == 'Q4']

#WordCloud
wordcloudUberCorpus = ''
for (s in tweetsUber$semSW) {
  wordcloudUberCorpus = paste(wordcloudUberCorpus, s, collapse = " ")
}
wordcloudUberClean <- str_replace_all(wordcloudUberCorpus,"uber"," ")
wordCloud <- Corpus (VectorSource(wordcloudUberClean))
wordCloud <- tm_map(wordCloud, stemDocument)
wordcloud(wordCloud, scale=c(5,0.5), max.words=100, random.order=FALSE, rot.per=0.35, use.r.layout=FALSE, colors=brewer.pal(8, "Dark2"))
