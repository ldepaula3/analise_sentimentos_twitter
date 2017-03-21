
library(RMySQL)
library(dplyr)
library(data.table)
library(stringr)
library(tm)
library(lubridate)

allTweets <- matrix(1,1)
allTweets$text <- c($$param_tweet_text)

v <- VectorSource(allTweets$text)

docs <- Corpus(v)
allTweets$text <- as.character(unlist(sapply(docs, `[`, "content")))
total <- read.csv($$param_arquivo_weight_words, stringsAsFactors = F,sep = ",",header = TRUE)



valence <- dplyr::filter(total, V.Mean.Sum <= 4 | V.Mean.Sum >= 6)
allTweets <- as.data.frame(allTweets)

# Classificacao Sentimento
measures <- allTweets %>% 
  rowwise() %>% 
  do({
    tweets <- unlist(str_split(.$text, boundary("word")))
    dplyr::filter(valence, Word %in% tweets) %>%
      summarise_each(funs(mean), which(sapply(., is.numeric))) %>%
      as.data.frame()
  })
codedTweets <- bind_cols(allTweets, measures)
codedTweets <- data.table(codedTweets)

tweetSalvar <- subset(codedTweets,select = c('text', 'V.Mean.Sum'))
tweetSalvar$tweet_id <- c($$param_tweet_id)
tweetSalvar$tweet <- c($$param_tweet_tweet)
tweetSalvar$user_name <- c($$param_tweet_user_name)
tweetSalvar$user_screen_name <- c($$param_tweet_user_screen_name)
tweetSalvar$lang <- c($$param_tweet_lang)

setnames(tweetSalvar,c('V.Mean.Sum'), c('valencia'))

con <- dbConnect(MySQL(),
                 user = "root", password = $$param_bd_password,
                 dbname = "tweets", host = "localhost", unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")

dbGetQuery(con, 'set character set utf8')
insertSQL <- paste("INSERT INTO ", $$param_tweet_table, " (tweet_id, user_name, user_screen_name, lang, text, valencia, tweet) VALUES (")
insertSQL <- paste(insertSQL, "'", tweetSalvar$tweet_id, "',")
insertSQL <- paste(insertSQL, "'", tweetSalvar$user_name, "',")
insertSQL <- paste(insertSQL, "'", tweetSalvar$user_screen_name, "',")
insertSQL <- paste(insertSQL, "'", tweetSalvar$lang, "',")
insertSQL <- paste(insertSQL, "'", tweetSalvar$text, "',")
insertSQL <- paste(insertSQL, "'", tweetSalvar$valencia, "',")
insertSQL <- paste(insertSQL, "'", tweetSalvar$tweet, "');")

dbSendQuery(con, insertSQL)

dbDisconnect(con)
rm(list=ls())


