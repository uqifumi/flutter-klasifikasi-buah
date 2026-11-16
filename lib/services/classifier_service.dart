import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ClassifierService {
  Interpreter? _interpreter;

  List<String> _labels = [];

  bool get isInitialized => _interpreter != null;

  // Memuat model dan label
  Future<void> loadModel() async {
    // Memuat model TensorFlow Lite
    _interpreter = await Interpreter.fromAsset(
      'assets/model/model_unquant.tflite',
    );

    // Mengalokasikan tensor
    _interpreter!.allocateTensors();

    // Membaca file labels.txt
    final labelData = await rootBundle.loadString('assets/model/labels.txt');

    // Mengambil nama kelas dari file label
    _labels = labelData.split('\n').where((line) => line.trim().isNotEmpty).map(
      (line) {
        final parts = line.trim().split(RegExp(r'\s+'));
        return parts.length > 1 ? parts.sublist(1).join(' ') : parts.first;
      },
    ).toList();

    // Menampilkan informasi model
    print('=== MODEL BERHASIL DIMUAT ===');
    print('Jumlah kelas : ${_labels.length}');
    print('Label        : $_labels');
    print('Input Shape  : ${_interpreter!.getInputTensor(0).shape}');
    print('Output Shape : ${_interpreter!.getOutputTensor(0).shape}');
  }

  // Image preprocessing
  static Future<List<List<List<List<double>>>>> preprocessImage(
    File imageFile,
  ) async {
    final imageBytes = await imageFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    if (originalImage == null) {
      throw Exception('Gambar tidak dapat dibaca.');
    }

    final resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          final pixel = resizedImage.getPixel(x, y);

          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    return input;
  }

  // Menjalankan inferensi gambar
  Future<List<double>> classify(File imageFile) async {
    // Memastikan model sudah dimuat
    if (_interpreter == null) {
      throw Exception('Model belum dimuat.');
    }

    // Melakukan preprocessing gambar
    final input = await preprocessImage(imageFile);

    // Menyiapkan tempat untuk menampung output
    final output = List.generate(1, (_) => List.filled(4, 0.0));

    // Menjalankan inferensi
    _interpreter!.run(input, output);

    // Mengambil empat nilai output
    final scores = output[0];

    print('=== HASIL INFERENSI ===');
    print('Output model: $scores');

    return scores;
  }

  // Melepaskan sumber daya model
  void close() {
    _interpreter?.close();
    _interpreter = null;
  }
}
