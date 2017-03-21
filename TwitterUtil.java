package util;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import models.Tweet147;
import models.TweetAirbnb;

import models.TweetUber;
import models.TweetUser;
import play.libs.F.Function0;
import play.libs.F.Promise;

public class TwitterUtil {
	
	private static String caminhoArquivosTwitter = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER);
	private static String caminhoEnglishWords = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER) + "english_words.csv";
	private static String caminhoEnglishStopWords = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER) + "stopwords.csv";
	private static String caminhoPortugueseWords = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER) + "portuguese_words.csv";
	private static String caminhoPortugueseStopWords = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER) + "stopwords_pt.csv";
	private static String caminhoSpanishWords = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER) + "spanish_words.csv";
	private static String caminhoSpanishStopWords = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER) + "stopwords_sp.csv";
	private static String arquivoRClassificacaoTwitter = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER) + "classificacao_airbnb_comparacao.r";
	public static void calculaValencia() throws IOException, InterruptedException {	
		//try {
		PreprocessadorUtil prep = new PreprocessadorUtil();
			List<Tweet147> statuses = null;
			
			statuses = Tweet147.findAll();
			
			int tamanho = statuses.size() ;
			
			System.out.println(tamanho);
			
			for(int i=0; i < tamanho; i++) {
				String tweet = statuses.get(i).getTweet();
				
				String caminhoWeightWords = caminhoEnglishWords;
				String textTweetLimpo = tweet;
				textTweetLimpo = textTweetLimpo.toLowerCase();
				textTweetLimpo = PreprocessadorUtil.removeUrl(textTweetLimpo);
				textTweetLimpo = PreprocessadorUtil.removeNumeros(textTweetLimpo);
				textTweetLimpo = PreprocessadorUtil.removeAcentuacao(textTweetLimpo);
				textTweetLimpo = PreprocessadorUtil.removePontuacao(textTweetLimpo, true, true);
				textTweetLimpo = PreprocessadorUtil.removeEspacosBrancos(textTweetLimpo);
				textTweetLimpo = PreprocessadorUtil.removePalavrasTamanho(textTweetLimpo, 3);
				textTweetLimpo = PreprocessadorUtil.removePalavrasTamanho(textTweetLimpo, 2);
				textTweetLimpo = PreprocessadorUtil.removePalavrasTamanho(textTweetLimpo, 1);
				
				String lang = statuses.get(i).getLang();
				
				if(lang.equalsIgnoreCase("en")) {
					textTweetLimpo = PreprocessadorUtil.removeWordsInFile(textTweetLimpo, caminhoEnglishStopWords);
					caminhoWeightWords = caminhoEnglishWords;
				} else if(lang.equalsIgnoreCase("pt")) {
					textTweetLimpo = PreprocessadorUtil.removeWordsInFile(textTweetLimpo, caminhoPortugueseStopWords);
					caminhoWeightWords = caminhoPortugueseWords;
				} else if(lang.equalsIgnoreCase("es")) {
					textTweetLimpo = PreprocessadorUtil.removeWordsInFile(textTweetLimpo, caminhoSpanishStopWords);
					caminhoWeightWords = caminhoSpanishWords;
				}

				textTweetLimpo = PreprocessadorUtil.removeEspacosBrancos(textTweetLimpo);
				
				String nomeTabela = "airbnb147_valencia";
		        				
				BufferedReader readerFileInput = FileUtil.lerArquivo(arquivoRClassificacaoTwitter);
				String lineFileInput = "";
				StringBuilder arquivoEditado = new StringBuilder();
				while( ( lineFileInput = readerFileInput.readLine() ) != null ) {

					
					lineFileInput = lineFileInput.replace("$$param_bd_password", "\""+ProjetoCIMConfig.getString(ProjetoCIMConfig.SCRIPT_R_PARAM_PASSWORD)+"\"");
					lineFileInput = lineFileInput.replace("$$param_arquivo_weight_words", "'"+caminhoWeightWords+"'");
					lineFileInput = lineFileInput.replace("$$param_tweet_table", "\""+nomeTabela+"\"");					
					lineFileInput = lineFileInput.replace("$$param_tweet_text", "'"+textTweetLimpo+"'");
					lineFileInput = lineFileInput.replace("$$param_tweet_tweet", "'"+tweet+"'");
					lineFileInput = lineFileInput.replace("$$param_tweet_lang", "'"+lang+"'");

					arquivoEditado.append(lineFileInput);
					arquivoEditado.append("\n");
				}
		
		    	String nomeArquivoEditado = nomeTabela+"_classificacao_twitter_editado_"+statuses.get(i).getId()+".r"; 
		    	
				FileUtil.salvarArquivoCriaPasta(arquivoEditado.toString(), ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER_TWEETS), nomeArquivoEditado, false);
				String arquivoREditado = ProjetoCIMConfig.getString(ProjetoCIMConfig.FOLDER_ARQUIVO_TWITTER_TWEETS) + nomeArquivoEditado;
				
				Process p;
				try {
					p = Runtime.getRuntime().exec("Rscript "+ arquivoREditado);
					p.waitFor();
				} catch (IOException e) {
					e.printStackTrace();
				}
				
				
				FileUtil.removeArquivo(arquivoREditado);
		    }
	}
}
