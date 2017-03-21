package controllers;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;

import com.mysql.jdbc.Statement;

import models.TwitterUser;
import play.data.DynamicForm;
import play.data.Form;
import play.libs.Json;
import play.mvc.Controller;
import play.mvc.Result;
import twitter4j.PagableResponseList;
import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.User;
import twitter4j.auth.OAuthAuthorization;
import twitter4j.conf.ConfigurationBuilder;
import util.TwitterUtil;

public class IndexController extends Controller {

	// Twitter
	private static final String TWITTER_CONSUMER_KEY = "";
	private static final String TWITTER_SECRET_KEY = "";
	private static final String TWITTER_ACCESS_TOKEN = "";
	private static final String TWITTER_ACCESS_TOKEN_SECRET = "";
    
	public static Result index(){
    	return ok(views.html.index.render());
    }

     public static Result logarSistema() throws Exception {
    	 ConfigurationBuilder cb = new ConfigurationBuilder();
  		cb.setDebugEnabled(true)
  		    .setOAuthConsumerKey(TWITTER_CONSUMER_KEY)
  		    .setOAuthConsumerSecret(TWITTER_SECRET_KEY)
  		    .setOAuthAccessToken(TWITTER_ACCESS_TOKEN)
  		    .setOAuthAccessTokenSecret(TWITTER_ACCESS_TOKEN_SECRET);
  		
  	    OAuthAuthorization auth = new OAuthAuthorization(cb.build());
  	    Twitter twitter = new TwitterFactory().getInstance(auth);
  	    
  	    
  		try {
  			User user = twitter.showUser("uber"); // Pega usuario
  			PagableResponseList<User> followersList;	// Declara lista de seguidores 
  			int cont = 1;
  			int contProximo = 15;
  			long cursor = 1549675014691658924L;
  			
  			
  			do{
  				followersList = twitter.getFollowersList("uber", cursor); //Recebe seguidores deste usuario
  				cursor = followersList.getNextCursor();
  				
  				if(cont == contProximo ) {
  					contProximo = cont + 15; // Atualiza o proximo limite para o dobro do inicio
  					Thread.sleep(900 * 1000); // Espera 15 min
  				}
  				for (int i = 0; i < followersList.size(); i++){
  		            User user1 = followersList.get(i);
  		            if(!user1.isProtected()){
  		            System.out.println("@" + user1.getScreenName() + 
  	    					"\n Descricao - " + (user1.getDescription() != "" ? user1.getDescription().replaceAll("'", "") : "") + 
  	    					"\n # Seguidores - " + user1.getFollowersCount() + 
  	    					"\n # Amigos - " + user1.getFriendsCount() +
  	    					"\n # Status - " + user1.getStatusesCount() +
  	    					"\n # Likes - " + user1.getFavouritesCount() +
  	    					"\n Criado em - " + user1.getCreatedAt() +
  	    					"\n Foto Perfil - " + user1.getOriginalProfileImageURL() + 
  	    					"\n Linguagem Preferida - " + user1.getLang() + 
  	    					"\n Localizacao - " + user1.getLocation().replaceAll("\\s+","") + 
  	    					"\n isVerified - " + user1.isVerified() + 
  	    					"\n lastStatus - " + (user1.getStatus() != null ? user1.getStatus().getText().replaceAll("'", "") : "") + 
  	    					"\n numberOfLists - " + user1.getListedCount() + "\n");
  		            }
  		            
  		            TwitterUser userModel = new TwitterUser();
  		            

  		            userModel.setScreenName(user1.getScreenName().toString());
  		            userModel.setDescription(user1.getDescription().toString());
  		            userModel.setFollowersCount(user1.getFollowersCount());
  		            userModel.setFollowingCount(user1.getFriendsCount());
  		            userModel.setStatusCount(user1.getStatusesCount());
  		            userModel.setLikesCount(user1.getFavouritesCount());
  		            userModel.setCreatedAt(user1.getCreatedAt().toString());
  		            userModel.setProfileImageUrl(user1.getOriginalProfileImageURL().toString());
  		            userModel.setPreferredLanguage(user1.getLang().toString());
  		            userModel.setLocation(user1.getLocation().toString().replaceAll("\\s+",""));
  		            userModel.setIsVerified(user1.isVerified() == true ? 1 : 0);
  		            userModel.setLastStatus(user1.getStatus() != null ? user1.getStatus().getText().replaceAll("'", "") : "");
  		            userModel.setNumberOfLists(user1.getListedCount());
  		            userModel.setNextCursor(cursor);

  		            userModel.save();
  		        }
  				cont++;
  				System.out.println("Contador: " + cont + " Cursor: " + cursor);
  			} while(cursor !=0);
  			
  		} catch (TwitterException te) {
  		    te.printStackTrace();
  		    System.out.println("Failed to search tweets: " + te.getMessage());
  		    System.exit(-1);
  		}
    	 return ok();
     }
     
     public static Result classificadorMicrosoft() throws Exception {
    	 return ok();
     }
    
     public static Result coletaTweets() throws Exception {
    	 return ok();
     }
    		
     public static Result calculaValencia() {
    	 System.out.println("Calcula Valencia");
    	 try {
			TwitterUtil.calculaValencia();
		} catch (IOException | InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	 return ok();
     }
}
