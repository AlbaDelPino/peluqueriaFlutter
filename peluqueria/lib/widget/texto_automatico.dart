import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class TextoAutomatico extends StatelessWidget {
  final String texto;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow; // <--- AÑADE ESTO

  const TextoAutomatico(
    this.texto, {
    this.style, 
    this.textAlign, 
    this.overflow, // <--- Y ESTO
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final translator = GoogleTranslator();
    String idiomaDestino = Localizations.localeOf(context).languageCode;

    if (idiomaDestino == 'es') {
      return Text(texto, style: style, textAlign: textAlign, overflow: overflow);
    }

    return FutureBuilder<Translation>(
      future: translator.translate(texto, to: idiomaDestino),
      builder: (context, snapshot) {
        // Mientras carga o si hay error, mostramos el texto original con el overflow
        String mostrar = snapshot.hasData ? snapshot.data!.text : texto;
        return Text(mostrar, style: style, textAlign: textAlign, overflow: overflow);
      },
    );
  }
}