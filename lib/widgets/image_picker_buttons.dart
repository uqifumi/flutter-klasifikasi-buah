import 'package:flutter/material.dart';

class ImagePickerButtons extends StatelessWidget {
  final VoidCallback onGalleryPressed;
  final VoidCallback onCameraPressed;

  const ImagePickerButtons({
    super.key,
    required this.onGalleryPressed,
    required this.onCameraPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onGalleryPressed,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Pilih dari Galeri'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green.shade700,
              side: BorderSide(color: Colors.green.shade600),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onCameraPressed,
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Ambil Foto dengan Kamera'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green.shade700,
              side: BorderSide(color: Colors.green.shade600),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
