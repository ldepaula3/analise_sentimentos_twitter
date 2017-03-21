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
                 dbname = "TCC_Final", host = "localhost",
                 unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")


#Pega os tweets do airbnb apenas. Adiciona o quadrante para analise.
rs <- dbSendQuery(con, "SELECT trim(T.screenName) as screenName, T.lang, T.text, trim(T.valencia) as valencia, A.quadrante as quadrante
                  FROM uberTweetValencia T 
                  INNER JOIN AccountsTweet_Uber A on A.screenName = trim(T.screenName)
                  AND valencia != ' NaN '")
valencias <- fetch(rs, n=-1)
valencias <- data.table(valencias)
valencias <- valencias %>% distinct(text, .keep_all = TRUE)
valencias$valencia <- as.double(valencias$valencia)


ValQ1 <- valencias[valencias$quadrante == "Q1"]
ValQ2 <- valencias[valencias$quadrante == "Q2"]
ValQ3 <- valencias[valencias$quadrante == "Q3"]
ValQ4 <- valencias[valencias$quadrante == "Q4"]


rsContas <- dbSendQuery(con, "SELECT followersCount, statusCount, screenName
                  FROM Accounts_Uber")

contas <- fetch(rsContas, n=-1)

contasValencias <- merge(contas, valencias, by="screenName")
contasValenciasUber <- contasValencias
contasValenciasUber$empresa <- "uber"

ggplot(contasValencias,aes(log(1+statusCount),log(1+followersCount), color=valencia, shape = factor(quadrante))) +
  scale_shape(solid = FALSE) +
  labs(color = "Sentimento", shape="Quadrante") +
  geom_point() + 
  geom_vline(xintercept = 7.5) +
  geom_hline(yintercept = 10)

mediaGeral <- mean(valencias$valencia)
mediaQ1 <- mean(valencias[quadrante == 'Q1']$valencia)
mediaQ2 <- mean(valencias[quadrante == 'Q2']$valencia)
mediaQ3 <- mean(valencias[quadrante == 'Q3']$valencia)
mediaQ4 <- mean(valencias[quadrante == 'Q4']$valencia)

uberQ1 <- valencias[quadrante == "Q1"]
uberQ2 <- valencias[quadrante == "Q2"]
uberQ3 <- valencias[quadrante == "Q3"]
uberQ4 <- valencias[quadrante == "Q4"]

ggplot(uberQ1, aes(valencia), stat = "count") + geom_histogram(bins = 100)
ggplot(uberQ2, aes(valencia), stat = "count") + geom_histogram(bins = 100)
ggplot(uberQ3, aes(valencia), stat = "count") + geom_histogram(bins = 100)
ggplot(uberQ4, aes(valencia), stat = "count") + geom_histogram(bins = 100)


uberQ1[valencia < 3]


dbDisconnect(con)

ggplot(contasValenciasAirbnbUber, aes(valencia, colour=quadrante)) + 
  facet_wrap(~ empresa) + 
  geom_density() +
  ylab("Densidade") +
  xlab("Sentimento") +
  geom_hline(aes(yintercept = 0.025))
ggplot(airQ2, aes(valencia)) + geom_histogram()
ggplot(airQ3, aes(valencia)) + geom_histogram()
ggplot(airQ4, aes(valencia)) + geom_histogram()

uber <- data.table(contasValenciasUber)
uber[lang == ' pt ']


contasValenciasAirbnbUber <- rbind(contasValenciasUber, contasValenciasAirbnb)

ggplot(contasValenciasAirbnbUber,aes(log(1+statusCount),log(1+followersCount), size=valencia, color=empresa)) +
  scale_shape(solid = FALSE) +
  labs(color = "Empresa", shapre="Valencia") +
  geom_point() + 
  geom_vline(xintercept = 7.5) +
  geom_hline(yintercept = 10)