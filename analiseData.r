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
library("zoo")
#Windows
#con <- dbConnect(MySQL(),
#                 user = "root", password = "",
#                 dbname = "contasTwitter", host = "localhost")


#Mac
con <- dbConnect(MySQL(),
                 user = "root", password = "root",
                 dbname = "TCC_Final", host = "localhost",
                 unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")


#Pega os tweets do airbnb apenas. Adiciona o quadrante para analise.
rs <- dbSendQuery(con, "SELECT trim(T.screenName) as screenName, T.lang, T.text, trim(T.valencia) as valencia, A.quadrante as quadrante
                  FROM uberTweetValencia T 
                  INNER JOIN AccountsTweet_Uber A on A.screenName = trim(T.screenName)
                  AND valencia != ' NaN '")
valenciasUber <- fetch(rs, n=-1)
valenciasUber <- data.table(valencias)
valenciasUber <- valenciasUber %>% distinct(text, .keep_all = TRUE)
valenciasUber$valencia <- as.double(valenciasUber$valencia)

rs <- dbSendQuery(con, "SELECT T.data, T.screenName, T.tweetId
                  FROM tweetUberLang T where tweet like '%uber %' and tweet not like '%youtuber %'")
tweets <- fetch(rs, n=-1)
tweetsUber <- data.table(tweets)


rs <- dbSendQuery(con, "SELECT trim(T.screenName) as screenName, T.lang, T.text, trim(T.valencia) as valencia, A.quadrante as quadrante, trim(tweet_id) AS tweetId
                  FROM airbnbTweetValencia T 
                  INNER JOIN AccountsTweet_Airbnb A on A.screenName = trim(T.screenName)
                  AND valencia != ' NaN ' ")
valenciasAirbnb <- fetch(rs, n=-1)
valenciasAirbnb <- data.table(valenciasAirbnb)
valenciasAirbnb <- valenciasAirbnb %>% distinct(text, .keep_all = TRUE)
valenciasAirbnb$tweetId <- as.integer(valenciasAirbnb$tweetId)
valenciasAirbnb$valencia <- as.double(valenciasAirbnb$valencia)

rs <- dbSendQuery(con, "SELECT T.data, T.screenName, T.tweetId
                  FROM tweetAirbnbLang T where tweet like '%airbnb %'")
tweets <- fetch(rs, n=-1)
tweetsAirbnb <- data.table(tweets)

tweetsAirbnbData <- merge(valenciasAirbnb, tweetsAirbnb, by="screenName", all = TRUE)

cbind(valenciasAirbnb, tweetsAirbnb[, "tweetId", "data"][match(rownames(valenciasAirbnb), rownames(tweetsAirbnb))])

tweetsAirbnbData <- merge(valenciasAirbnb, tweetsAirbnb, by="tweetId")


# 
library('data.table')
data_words <- data.table(read.table('/Users/Lucas/Desktop/tcc_lucas/proj_cim_files/arquivos_twitter/english_words.csv', sep=",", header = TRUE))

data_words <- data_words %>% distinct(Word, .keep_all = TRUE)

ggplot(data_words, aes(V.Mean.Sum)) + geom_density()

# 



