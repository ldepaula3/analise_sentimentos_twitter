package util;

import java.io.BufferedReader;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.tika.language.*;
import org.jsoup.Jsoup;

public class PreprocessadorUtil {

	
	public static String removeHtml(String mensagemHtml) {

		String mensagem = Jsoup.parse(mensagemHtml).text();
		return Jsoup.parse(mensagem).text();
	}
	
	public static String limparMensagem(String mensagem) {
		
		mensagem = mensagem.toLowerCase();
		mensagem = removeEspacosBrancos(mensagem);
		mensagem = removeNumeros(mensagem);
		mensagem = removeAcentuacao(mensagem);
		mensagem = removePontuacao(mensagem, true, true);
		mensagem = removePalavrasTamanho(mensagem, 4);
		mensagem = removeEspacosBrancos(mensagem);
		
		return mensagem;
	}
	
	public static String removeEspacosBrancos(String palavra) {
		
		palavra = palavra.trim();
		palavra = palavra.replaceAll("\\s+", " ");
		palavra = palavra.replaceAll("\n", " ");
		palavra = palavra.replaceAll("	", " ");
		palavra = palavra.trim();
		
		return palavra;
	}
	
	public static String removePalavrasTamanho(String palavra, int tamanho) {
		
		StringBuilder retorno = null;
		
		if(palavra != null && !palavra.isEmpty()) {
			String tokens [] = palavra.split(" ");
			retorno = new StringBuilder();
			for(String token : tokens) {
				if(token.length() > tamanho) {
					retorno.append(token);
					retorno.append(" ");
				}
			}
			
			return retorno.toString().trim();
		}
		return "";
	}
	
	public static String removePalavrasTamanhoMenor(String palavra, int tamanho) {
		
		StringBuilder retorno = null;
		
		if(palavra != null && !palavra.isEmpty()) {
			String tokens [] = palavra.split(" ");
			retorno = new StringBuilder();
			for(String token : tokens) {
				if(token.length() < tamanho) {
					retorno.append(token);
					retorno.append(" ");
				}
			}
			
			return retorno.toString().trim();
		}
		return "";
	}
	
	public static String removeWordsInFile(String instancia, String caminhoArquivoWords) {
		
		BufferedReader stopWords = FileUtil.lerArquivo(caminhoArquivoWords);
		String strLine;
		String tokens [] = null;

		if(instancia != null && !instancia.isEmpty()) {
			tokens = instancia.split(" ");
		}
		
		if(tokens != null && tokens.length > 0) {
			try {
				while ((strLine = stopWords.readLine()) != null) {
	
					for(int i = 0; i < tokens.length; i++) {
						if(tokens[i].isEmpty() || tokens[i].equals(strLine)) {
							tokens[i] = "";
						}
					}
				}
			} catch(Exception e) {
				e.printStackTrace();
			}
		}
		StringBuilder retornoLimpo = new StringBuilder();
		
		if(tokens != null) {
			
			for(String token : tokens) {
				token = token.trim();
				if(!token.isEmpty()) {
					retornoLimpo.append(token);
					retornoLimpo.append(" ");				
				}
			}
		}
		
		return retornoLimpo.toString();
	}
	
	
	public static String removeAcentuacao(String palavra) {
		
		palavra = palavra.replace('á', 'a');
		palavra = palavra.replace('â', 'a');
		palavra = palavra.replace('ã', 'a');
		palavra = palavra.replace('à', 'a');
		
		palavra = palavra.replace('ç', 'c');
		
		palavra = palavra.replace('é', 'e');
		palavra = palavra.replace('ê', 'e');
		palavra = palavra.replace('è', 'e');
		
		palavra = palavra.replace('í', 'i');
		
		palavra = palavra.replace('ó', 'o');
		palavra = palavra.replace('ô', 'o');
		palavra = palavra.replace('õ', 'o');
		palavra = palavra.replace('ö', 'o');
		
		palavra = palavra.replace('ú', 'u');
		palavra = palavra.replace('ü', 'u');
		
		palavra = palavra.replace('ñ', 'n');
		
		return palavra;
	}
	
	public static String removePontuacao(String palavra, boolean removeHashtag, boolean removeArroba) {
		
		palavra = palavra.replace('!', ' ');
		palavra = palavra.replace('?', ' ');
		palavra = palavra.replace('.', ' ');
		palavra = palavra.replace(':', ' ');
		palavra = palavra.replace(';', ' ');
		palavra = palavra.replace(',', ' ');
		palavra = palavra.replace('/', ' ');
		palavra = palavra.replace('\\', ' ');
		palavra = palavra.replace('\'', ' ');
		palavra = palavra.replace('\"', ' ');
		palavra = palavra.replace('-', ' ');
		palavra = palavra.replace('+', ' ');
		palavra = palavra.replace('=', ' ');
		palavra = palavra.replace('*', ' ');
		palavra = palavra.replace('%', ' ');
		palavra = palavra.replace('_', ' ');
		palavra = palavra.replace(')', ' ');
		palavra = palavra.replace('(', ' ');
		palavra = palavra.replace(']', ' ');
		palavra = palavra.replace('[', ' ');
		palavra = palavra.replace('{', ' ');
		palavra = palavra.replace('}', ' ');
		palavra = palavra.replace('<', ' ');
		palavra = palavra.replace('>', ' ');
		palavra = palavra.replace('&', ' ');
		palavra = palavra.replace('$', ' ');
		if(removeHashtag) {
			palavra = palavra.replace('#', ' ');
		}
		if(removeArroba) {
			palavra = palavra.replace('@', ' ');
			
		}
		palavra = palavra.replace('\'', ' ');
		palavra = palavra.replace('\'', ' ');
		palavra = palavra.replace('|', ' ');
		palavra = palavra.replace('ª', ' ');
		palavra = palavra.replace('º', ' ');
		palavra = palavra.replace('°', ' ');
		palavra = palavra.replace('§', ' ');
		palavra = palavra.replace('“', ' ');
		palavra = palavra.replace('’', ' ');
		palavra = palavra.replace('‘', ' ');
		palavra = palavra.replace('”', ' ');
		palavra = palavra.replace('–', ' ');
		palavra = palavra.replace('€', ' ');
		palavra = palavra.replace('', ' ');
		palavra = palavra.replace('', ' ');
		palavra = palavra.replace('£', ' ');
		palavra = palavra.replace('©', ' ');
		palavra = palavra.replace('®', ' ');
		palavra = palavra.replace('œ', ' ');
		palavra = palavra.replace('™', ' ');
		palavra = palavra.replace('³', ' ');
		palavra = palavra.replace('¬', ' ');

		return palavra;
	}
	
	public static String removeNumeros(String palavra) {
		
		palavra = palavra.replace('0', ' ');
		palavra = palavra.replace('1', ' ');
		palavra = palavra.replace('2', ' ');
		palavra = palavra.replace('3', ' ');
		palavra = palavra.replace('4', ' ');
		palavra = palavra.replace('5', ' ');
		palavra = palavra.replace('6', ' ');
		palavra = palavra.replace('7', ' ');
		palavra = palavra.replace('8', ' ');
		palavra = palavra.replace('9', ' ');
		
		return palavra;
	}

	public static String removeUrl(String url) {
		try {
			
			url = url.replace(")","").replace("(", "");
	        String urlPattern = "((https?|ftp|gopher|telnet|file|Unsure|http):((//)|(\\\\))+[\\w\\d:#@%/;$()~_?\\+-=\\\\\\.&]*)";
	        Pattern p = Pattern.compile(urlPattern,Pattern.CASE_INSENSITIVE);
	        Matcher m = p.matcher(url);
	        int i = 0;
	        while (m.find()) {
	        	url = url.replaceAll(m.group(i),"").trim();
	            i++;
	        }
		} catch(Exception e) {
			System.out.println("*****removeURL " + url);
			e.printStackTrace();
		}
        return url;
    }
	
	public static String identifyLanguage(String text) {
	    LanguageIdentifier identifier = new LanguageIdentifier(text);
	    return identifier.getLanguage();
	}
	
	public static String caracterEspecialToAcento(String text) {
		 
		text = text.replace("&ordm;","º");
		text = text.replace("&#160;"," ");
		text = text.replace("&rsquo;","’");
		text = text.replace("&lsquo;","‘");
		text = text.replace("&nbsp;"," ");
		text = text.replace("&ndash;","–");
		text = text.replace("&rdquo;","”");
		text = text.replace("&ldquo;","“");
		text = text.replace("&Aacute;","Á");
		text = text.replace("&aacute;","á");
		text = text.replace("&Acirc;","Â");
		text = text.replace("&acirc;","â");
		text = text.replace("&Agrave;","À");
		text = text.replace("&agrave;","à");
		text = text.replace("&Aring;","Å");
		text = text.replace("&aring;","å");
		text = text.replace("&Atilde;","Ã");
		text = text.replace("&atilde;","ã");
		text = text.replace("&Auml;","Ä");
		text = text.replace("&auml;","ä");
		text = text.replace("&AElig;","Æ");
		text = text.replace("&aelig;","æ");
		text = text.replace("&Eacute;","É");
		text = text.replace("&eacute;","é");
		text = text.replace("&Ecirc;","Ê");
		text = text.replace("&ecirc;","ê");
		text = text.replace("&Egrave;","È");
		text = text.replace("&egrave;","è");
		text = text.replace("&Euml;","Ë");
		text = text.replace("&euml;","ë");
		text = text.replace("&ETH;","Ð");
		text = text.replace("&eth;","ð");
		text = text.replace("&Iacute;","Í");
		text = text.replace("&iacute;","í");
		text = text.replace("&Icirc;","Î");
		text = text.replace("&icirc;","î");
		text = text.replace("&Igrave;","Ì");
		text = text.replace("&igrave;","ì");
		text = text.replace("&Iuml;","Ï");
		text = text.replace("&iuml;","ï");
		text = text.replace("&Oacute;","Ó");
		text = text.replace("&oacute;","ó");
		text = text.replace("&Ocirc;","Ô");
		text = text.replace("&ocirc;","ô");
		text = text.replace("&Ograve;","Ò");
		text = text.replace("&ograve;","ò");
		text = text.replace("&Oslash;","Ø");
		text = text.replace("&oslash;","ø");
		text = text.replace("&Otilde;","Õ");
		text = text.replace("&otilde;","õ");
		text = text.replace("&Ouml;","Ö");
		text = text.replace("&ouml;","ö");
		text = text.replace("&Uacute;","Ú");
		text = text.replace("&uacute;","ú");
		text = text.replace("&Ucirc;","Û");
		text = text.replace("&ucirc;","û");
		text = text.replace("&Ugrave;","Ù");
		text = text.replace("&ugrave;","ù");
		text = text.replace("&Uuml;","Ü");
		text = text.replace("&uuml;","ü");
		text = text.replace("&Ccedil;","Ç");
		text = text.replace("&ccedil;","ç");
		text = text.replace("&Ntilde;","Ñ");
		text = text.replace("&ntilde;","ñ");
		text = text.replace("&lt;","<");
		text = text.replace("&gt;",">");
		text = text.replace("&amp;","&");
		text = text.replace("&quot;","\"");
		text = text.replace("&reg;","®");
		text = text.replace("&copy;","©");
		text = text.replace("&Yacute;","Ý");
		text = text.replace("&yacute;","ý");
		text = text.replace("&THORN;","Þ");
		text = text.replace("&thorn;","þ");
		text = text.replace("&szlig;","ß");

		return text;
    }
}
