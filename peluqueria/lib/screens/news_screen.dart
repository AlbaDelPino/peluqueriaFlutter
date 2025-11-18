import 'package:flutter/material.dart';


class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  final List<Map<String, String>> newsItems = const [
    {
      "title": "Últimas noticias sobre Depilación - 20minutos",
      "url": "https://www.20minutos.es/tags/temas/depilacion.html",
    },
    {
      "title": "Depilación: métodos, consejos y tendencias - ABC",
      "url": "https://www.abc.es/noticias/depilacion/",
    },
    {
      "title": "Depilación en Vogue España",
      "url": "https://www.vogue.es/tags/depilacion",
    },
    {
      "title": "Noticias de Peluquería Profesional - BeautyMarket",
      "url":
          "https://www.beautymarket.es/peluqueria/noticias-y-actualidad-de-peluqueria.php",
    },
    {
      "title": "Peluquería en EL PAÍS",
      "url": "https://elpais.com/noticias/peluqueria/",
    },
  ];

  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Noticias de Belleza")),
      body: ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (ctx, i) {
          final item = newsItems[i];
          
        },
      ),
    );
  }
}
