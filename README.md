# analise_sentimentos_twitter
Repositório que contém os códigos e conjuntos de dados do trabalho de conclusão de curso desenvolvido por Lucas Augusto Moreira de Paula




IndexController.java
  Código que possui a chamada para a coleta dos perfis de cada empresa.
  
PreprocessadorUtil.java	
  Código utilizado para preprocessamento de textos utilizando REGEX.

TwitterUtil.java
  Classe gerada para atualizar o arquivo classificacao_twitter.r para execução da análise de sentimentos.
  
analiseData.r
  Análises gerais cruzando tabelas e gerando gráficos de densidade do dicionrio de palavras em inglês.

classificacao_twitter.r
  Algoritmo é executado para se salvar a análise de sentimentos dos tweets no banco de dados. Este algoritmo é preenchido dinamicamente pelo Java.

salva_tweet_airbnb.py
  Coleta tweets do airbnb.

salva_tweet_uber.py
  Coleta tweets do uber.

scriptAirbnbValencia.r
  Análise dos sentimentos dos tweets do Airbnb já classificados e salvos em banco de dados. Análise por quadrantes, etc.
  
scriptTweets.r e scriptTweetsUber.r
  Pequenos testes de validação dos tweets como limpezas, etc.

scriptTwitter.r e scriptTwitterUber.r
  Análises dos perfis, divisão em qudarantes, cálculo dos perfis influentes, etc.

scriptUberValencia.r
  Análises dos sentimentos extraídos, análise final.
  
  
  
