import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  static const String modelPath = 'assets/models/siamese_model.tflite';
  static const int inputSize = 299; // InceptionV3 input size
  Interpreter? _interpreter;

  Future<void> loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions();
      
      // Load model from assets
      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: interpreterOptions,
      );
      
      print('Model loaded successfully');
      print('Input shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('Error loading model: $e');
      rethrow;
    }
  }

  Future<List<double>> processImage(File imageFile) async {
    if (_interpreter == null) {
      throw Exception('Interpreter not initialized');
    }

    // Load and preprocess the image
    final imageBytes = await imageFile.readAsBytes();
    final image = img.decodeImage(imageBytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize image to match InceptionV3 input size
    final processedImage = img.copyResize(image, width: inputSize, height: inputSize);
    
    // Convert to uint8 array and normalize to 0-255 range
    var inputArray = Uint8List(1 * inputSize * inputSize * 3);
    var pixelIndex = 0;
    
    for (var y = 0; y < inputSize; y++) {
      for (var x = 0; x < inputSize; x++) {
        final pixel = processedImage.getPixel(x, y);
        // RGB order
        inputArray[pixelIndex++] = pixel.r.toInt();
        inputArray[pixelIndex++] = pixel.g.toInt();
        inputArray[pixelIndex++] = pixel.b.toInt();
      }
    }

    // Prepare output tensor
    var outputBuffer = Float32List(1 * 128); // 128-dimensional feature vector
    
    // Run inference
    try {
      _interpreter!.run(
        inputArray.reshape([1, inputSize, inputSize, 3]),
        outputBuffer.reshape([1, 128])
      );
      
      // Convert output buffer to List<double>
      return outputBuffer.toList();
    } catch (e) {
      print('Error during inference: $e');
      rethrow;
    }
  }

  void dispose() {
    _interpreter?.close();
  }
} 