import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScannedItem {
  final String name;
  final double price;

  ScannedItem({required this.name, required this.price});
}

class OcrService {
  final ImagePicker _picker = ImagePicker();

  Future<List<ScannedItem>> scanReceiptFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return [];
      return await _processImage(image);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScannedItem>> scanReceiptFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return [];
      return await _processImage(image);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ScannedItem>> _processImage(XFile image) async {
    String recognizedRawText;

    // Google ML Kit SOLO funciona en Android e iOS Nativo. 
    // Para Web o MacOS local, usaremos tu boleta de prueba de "Ruca Bar" ya descifrada.
    bool isUnsupportedPlatform = kIsWeb;
    if (!kIsWeb) {
       isUnsupportedPlatform = Platform.isMacOS || Platform.isWindows || Platform.isLinux;
    }

    if (isUnsupportedPlatform) {
      await Future.delayed(const Duration(seconds: 1)); // Simulate processing delay
      recognizedRawText = '''
      CANT   ARTICULO
      2      GIN ERVA                  \$ 13,800
      1      DaVinci                   \$ 6,500
      1      Champiñones al Ajillo     \$ 14,600
      2      Hummus de Beterraga       \$ 6,500
      1      Ruca Special              \$ 6,500
      1      LIMONADA                  \$ 3,500
      SUBTOTAL \$   53,000
      Dscto.   \$        0
      Recargo  \$        0
      -------------------
      TOTAL A PAGAR \$ 53,000
      PROPINA SUGERIDA 10% \$  5,300
      TOTAL CON PROPINA    \$ 58,300
      NO VALIDO COMO BOLETA
      ''';
    } else {
      // Real Mobile Flow (Android/iOS)
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      recognizedRawText = recognizedText.text;
      textRecognizer.close();
    }

    return _parseReceiptText(recognizedRawText);
  }

  List<ScannedItem> _parseReceiptText(String text) {
    final List<ScannedItem> items = [];
    final lines = text.split('\n');

    // RegEx parametrizado para atrapar precios (con o sin simbolo $, con separadores)
    final priceRegex = RegExp(r'[$€]?\s?(\d{1,3}(?:[.,]\d{3})*(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?)');
    
    // Stopwords para descartar falsos positivos matemáticos (totales)
    final stopWords = ['total', 'subtotal', 'tax', 'iva', 'propina', 'tip', 'cash', 'efectivo', 'tarjeta', 'vuelto', 'cambio', 'dscto', 'recargo', 'valido'];

    for (var line in lines) {
      final cleanLine = line.trim().toLowerCase();
      
      // Saltar líneas vacías o de puro formato (---===)
      if (cleanLine.isEmpty || cleanLine.replaceAll(RegExp(r'[-=.]+'), '').isEmpty) continue;
      
      // Filtrar palabras prohibidas
      bool isStopWord = stopWords.any((word) => cleanLine.contains(word));
      if (isStopWord) continue;

      final matches = priceRegex.allMatches(line);
      if (matches.isNotEmpty) {
        // En boletas, el precio final real del item casi siempre es el último número detectado en la línea
        final matchStr = matches.last.group(1) ?? "0";
        
        // Estrategia de sanitización de formato latino
        String cleanNumberStr = matchStr.replaceAll(RegExp(r'[^0-9.,]'), '');
        cleanNumberStr = cleanNumberStr.replaceAll(',', '.');
        
        // Si tiene un punto y separa miles (chile/colombia), lo quitamos
        if (cleanNumberStr.contains('.') && cleanNumberStr.split('.').last.length == 3) {
            cleanNumberStr = cleanNumberStr.replaceAll('.', '');
        }

        final double price = double.tryParse(cleanNumberStr) ?? 0.0;

        if (price > 0) {
          // Extraemos el nombre asumiendo que es todo el texto excepto el número que acabamos de aislar
          String name = line.replaceFirst(matches.last.group(0)!, '').trim();
          
          // Limpiar caracteres residuales en el nombre
          name = name.replaceAll(RegExp(r'^[-+*=x\s\$]+|[-+*=x\s\$]+$'), '').trim();
          // Quitar numeros iniciales que suelen ser cantidades (ej: "1x ")
          name = name.replaceFirst(RegExp(r'^\d+\s*x?\s*'), '').trim();

          if (name.isNotEmpty) {
             items.add(ScannedItem(name: name, price: price));
          }
        }
      }
    }

    return items;
  }
}
