import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quote_service.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String _quote = "Toque no botão para gerar uma frase.", _author = "";
  int _secondsRemaining = 0, _quoteCount = 0;
  Timer? _timer;
  String _selectedLanguage = 'pt';
  bool _isLanguageMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'pt';
    });
  }

  Future<void> _saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }

  Future<void> _getNewQuote() async {
    if (_quoteCount >= 5) return;
    try {
      var newQuote = await QuoteService.fetchQuote(_selectedLanguage);
      setState(() {
        _quote = newQuote['quote']!;
        _author = newQuote['author']!;
        if (++_quoteCount == 5) _startCooldown();
      });
    } catch (_) {
      setState(() {
        _quote = "Erro ao obter nova frase.";
        _author = "";
      });
    }
  }

  void _startCooldown() {
    _secondsRemaining = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_secondsRemaining-- <= 0) {
        setState(() {
          _quoteCount = 0;
          _quote = "Toque no botão para gerar uma frase.";
          _author = "";
        });
        timer.cancel();
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _languageMenu(double width) {
    return Positioned(
      top: 20,
      right: 20,
      child: GestureDetector(
        onTap: () => setState(() => _isLanguageMenuOpen = !_isLanguageMenuOpen),
        child: Container(
          width: width * 0.4,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.language, color: Colors.blueAccent),
              Text('Idioma', style: TextStyle(color: Colors.blueAccent)),
              Icon(
                _isLanguageMenuOpen
                    ? Icons.arrow_drop_up
                    : Icons.arrow_drop_down,
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageOptions(double width) {
    return Positioned(
      top: 60,
      right: 20,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: width * 0.4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children:
                ['pt', 'en', 'fr', 'es'].map((lang) {
                  return ListTile(
                    title: Text(lang.toUpperCase()),
                    onTap: () {
                      setState(() {
                        _selectedLanguage = lang;
                        _isLanguageMenuOpen = false;
                      });
                      _saveLanguage(lang);
                    },
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sábias Palavras",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.lightBlue.shade50),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _quote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _author.isNotEmpty ? "- $_author" : "",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _quoteCount < 5 ? _getNewQuote : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        shadowColor: Colors.blue.shade200,
                        elevation: 5,
                      ),
                      child: Text(
                        _quoteCount < 5
                            ? "Nova Frase"
                            : "$_secondsRemaining s para liberar",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _languageMenu(width),
          if (_isLanguageMenuOpen) _languageOptions(width),
        ],
      ),
    );
  }
}
