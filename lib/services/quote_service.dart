import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class QuoteService {
  static Future<Map<String, String>> fetchQuote(String language) async {
    try {
      final response = await http.get(Uri.parse('https://zenquotes.io/api/random'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body)[0];
        String quote = data['q'];
        String author = data['a'];
        String translatedQuote = await _translateQuote(quote, language);

        return {'quote': translatedQuote, 'author': author};
      } else {
        throw Exception('Erro ao obter nova frase');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<String> _translateQuote(String text, String language) async {
    try {
      final translator = GoogleTranslator();
      var translation = await translator.translate(text, to: language);
      return translation.text;
    } catch (e) {
      throw Exception(e);
    }
  }
}
