import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/classifier_service.dart';
import '../widgets/image_preview.dart';
import '../widgets/image_picker_buttons.dart';
import '../widgets/prediction_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final ClassifierService _classifier = ClassifierService();

  File? _selectedImage;

  String? _predictedLabel;
  double? _confidence;
  bool _isClassifying = false;

  // Memuat model ketika halaman utama dibuka
  @override
  void initState() {
    super.initState();
    _initializeClassifier();
  }

  // Inisialisasi model TensorFlow Lite
  Future<void> _initializeClassifier() async {
    try {
      await _classifier.loadModel();
    } catch (e) {
      debugPrint('Gagal memuat model: $e');
    }
  }

  // Memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
      _predictedLabel = null;
      _confidence = null;
    });

    await _testPreprocessing(_selectedImage!);
  }

  // Mengambil foto menggunakan kamera
  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
      _predictedLabel = null;
      _confidence = null;
    });
  }

  // Menguji proses preprocessing gambar
  Future<void> _testPreprocessing(File imageFile) async {
    try {
      final input = await ClassifierService.preprocessImage(imageFile);

      debugPrint('=== HASIL PREPROCESSING ===');
      debugPrint('Batch Size : ${input.length}');
      debugPrint('Height     : ${input[0].length}');
      debugPrint('Width      : ${input[0][0].length}');
      debugPrint('Channel    : ${input[0][0][0].length}');
      debugPrint('Pixel RGB  : ${input[0][0][0]}');

      debugPrint('Preprocessing berhasil.');
    } catch (e) {
      debugPrint('Preprocessing gagal: $e');
    }
  }

  // Menguji inferensi model
  Future<void> _testInference() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu.')),
      );
      return;
    }

    if (_isClassifying) return;

    setState(() {
      _isClassifying = true;
    });

    try {
      final scores = await _classifier.classify(_selectedImage!);

      int predictedIndex = 0;

      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > scores[predictedIndex]) {
          predictedIndex = i;
        }
      }

      final labels = ['Pisang', 'Jeruk', 'Mangga', 'Apel'];

      setState(() {
        _predictedLabel = labels[predictedIndex];
        _confidence = scores[predictedIndex] * 100;
      });
    } catch (e) {
      debugPrint('Inferensi gagal: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isClassifying = false;
        });
      }
    }
  }

  // Melepaskan sumber daya ketika halaman ditutup
  @override
  void dispose() {
    _classifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header aplikasi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22),
              color: Colors.green.shade700,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, color: Colors.white, size: 30),
                  SizedBox(width: 10),
                  Text(
                    'KLASIFIKASI BUAH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ImagePreview(imageFile: _selectedImage),

                    const SizedBox(height: 20),

                    ImagePickerButtons(
                      onGalleryPressed: _pickImageFromGallery,
                      onCameraPressed: _takePhoto,
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _isClassifying ? null : _testInference,
                        icon: const Icon(Icons.search),
                        label: const Text(
                          'Klasifikasikan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    PredictionResult(
                      predictedLabel: _predictedLabel,
                      confidence: _confidence,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
