import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class TextRecognitionScreen extends StatefulWidget {
  const TextRecognitionScreen({super.key});

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  File? _imageFile;
  String _recognizedText = '';
  final ImagePicker _picker = ImagePicker();

  // Function to pick an image from the camera
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _recognizeText(File(pickedFile.path));
    }
  }

  // Recognize text using Google ML Kit
  Future<void> _recognizeText(File image) async {
    final InputImage inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();

    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    String extractedText = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        extractedText += '${line.text}\n';
      }
    }

    setState(() {
      _recognizedText = extractedText;
    });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _imageFile == null
                ? const Text('No image selected.')
                : Image.file(
                    _imageFile!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomeElevatedButton(
                  onPressed: _pickImage,
                  text: 'Capture Image',
                ),
                const SizedBox(width: 20),
                CustomeElevatedButton(
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                      _recognizedText = '';
                    });
                  },
                  text: "Clear Image",
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _recognizedText));
                      },
                      icon: const Icon(Icons.copy),
                    ),
                    const Text("Copy Text to Clipboard"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _recognizedText.isEmpty ? 'Recognized text will appear here' : _recognizedText,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomeElevatedButton extends StatelessWidget {
  final void Function() onPressed;
  final String text;
  const CustomeElevatedButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
