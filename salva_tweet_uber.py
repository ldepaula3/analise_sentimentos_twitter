#!/usr/bin/env python
# encoding: utf-8

import tweepy #https://github.com/tweepy/tweepy
import csv
import pymysql.cursors
import simplejson
import preprocessor as p
import sys
import re
from langdetect import detect

FLAGS = re.MULTILINE | re.DOTALL

reload(sys)
sys.setdefaultencoding('utf-8')


# Credenciais 
consumer_key = ""
consumer_secret = ""
access_key = ""
access_secret = ""

def get_all_tweets(screen_name, cursor, idusur):
        print("coletando dados para " + screen_name + " \n ")
        auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
        auth.set_access_token(access_key, access_secret)
        api = tweepy.API(auth)
        
        alltweets = []  

        # Pega os 200 twets
        new_tweets = api.user_timeline(screen_name = screen_name,count=200)
        
        alltweets.extend(new_tweets)
        
        # Id do ultimo tweet
        oldest = alltweets[-1].id - 1
        
       
        while len(new_tweets) > 0:
                
                new_tweets = api.user_timeline(screen_name = screen_name,count=200,max_id=oldest)
                
                
                alltweets.extend(new_tweets)
                
                
                oldest = alltweets[-1].id - 1
                
                print ("...%s" % (len(alltweets)))
                
        
        with connection.cursor() as cursor:
                for tweet in alltweets:
                        
                        print (str(idusur) + " - " + screen_name )
                        
                        sql = "INSERT INTO tweetUberLang(tweetId,data,screenName,tweet,lang) VALUES (%s,%s,%s,%s,%s)"
                        cursor.execute(sql, (tweet.id_str, str(tweet.created_at), screen_name, (tweet.text).strip(), tweet.lang))
                        connection.commit()
        

if __name__ == '__main__':
    
        connection = pymysql.connect(host='127.0.0.1',
                             port=8889,
                             user='root',
                             password='root',
                             db='contasTwitterUber',
                             charset='utf8mb4',
                             cursorclass=pymysql.cursors.DictCursor)
         
        with connection.cursor() as cursor:
                sql = "SELECT id, screenName, quadrante FROM `UberAccountsTweet`"
                cursor.execute(sql)
                result = cursor.fetchall()
        
        for c in result:
                usuario = c[u'screenName']
                idusur = c[u'id']
                auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
                auth.set_access_token(access_key, access_secret)
                api = tweepy.API(auth)
                try:
                    
                    usr = api.get_user(screen_name=usuario)
 
                    if(not usr.protected):
                        get_all_tweets(usuario,connection, idusur)
                except tweepy.TweepError as e:

                    print "**********************************\n"
                    print "ERRO\n"
                    
                    print "**********************************\n"
                    pass
                
