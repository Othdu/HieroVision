import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class FeatureService {
  static const String featuresPath = 'assets/models/features_trial1.npy';
  List<List<double>>? _features;
  List<String>? _labels;

  Future<void> loadFeatures() async {
    try {
      print('Starting to load features from $featuresPath');
      final ByteData data = await rootBundle.load(featuresPath);
      final buffer = data.buffer;
      final bytes = buffer.asUint8List();

      print('File size: ${bytes.length} bytes');

      // Parse NPY header
      int offset = 0;
      
      // Check magic string (0x93NUMPY)
      if (bytes[0] != 0x93 || bytes[1] != 0x4E || bytes[2] != 0x55 || bytes[3] != 0x4D || 
          bytes[4] != 0x50 || bytes[5] != 0x59) {
        throw Exception('Invalid NPY file format');
      }
      offset += 6;

      // Version
      final major = bytes[offset];
      final minor = bytes[offset + 1];
      print('NPY version: $major.$minor');
      offset += 2;

      // Header length
      int headerLen = bytes[offset] + (bytes[offset + 1] << 8);
      offset += 2;

      // Parse header
      final headerStr = String.fromCharCodes(bytes.sublist(offset, offset + headerLen));
      print('NPY Header: $headerStr');

      // Move past header
      offset += headerLen;

      // Print first few bytes of data for debugging
      print('First 32 bytes of data:');
      final dataPreview = bytes.sublist(offset, math.min(offset + 32, bytes.length));
      print(dataPreview.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' '));

      // Try to interpret as float32 array
      final floatBytes = bytes.sublist(offset);
      final floatsPerVector = 128; // Assuming 128-dimensional vectors
      final numVectors = floatBytes.length ~/ (4 * floatsPerVector);

      print('Attempting to load $numVectors vectors of dimension $floatsPerVector');

      // Create float array
      ByteData viewData = ByteData.view(floatBytes.buffer);
      List<List<double>> features = [];

      for (var i = 0; i < numVectors; i++) {
        List<double> vector = [];
        for (var j = 0; j < floatsPerVector; j++) {
          final byteOffset = (i * floatsPerVector + j) * 4;
          if (byteOffset + 4 <= floatBytes.length) {
            try {
              final value = viewData.getFloat32(byteOffset, Endian.little);
              if (value.isFinite) {
                vector.add(value);
              } else {
                print('Warning: Non-finite value at vector $i, position $j');
                vector.add(0.0);
              }
            } catch (e) {
              print('Error reading float at vector $i, position $j: $e');
              vector.add(0.0);
            }
          }
        }
        if (vector.length == floatsPerVector) {
          features.add(vector);
        }
      }

      if (features.isEmpty) {
        throw Exception('No valid feature vectors could be loaded');
      }

      _features = features;
      print('Successfully loaded ${_features!.length} feature vectors');
      
      // Print some statistics
      if (_features!.isNotEmpty) {
        var firstVector = _features!.first;
        print('First vector preview: ${firstVector.take(5)}...');
        print('Value range: ${_getValueRange(firstVector)}');
      }

    } catch (e) {
      print('Error loading features: $e');
      rethrow;
    }
  }

  Map<String, double> _getValueRange(List<double> vector) {
    if (vector.isEmpty) return {'min': 0, 'max': 0, 'mean': 0};
    var min = vector[0];
    var max = vector[0];
    var sum = 0.0;
    
    for (var value in vector) {
      if (value < min) min = value;
      if (value > max) max = value;
      sum += value;
    }
    
    return {
      'min': min,
      'max': max,
      'mean': sum / vector.length,
    };
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) {
      throw Exception('Vectors must have same length');
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    normA = math.sqrt(normA);
    normB = math.sqrt(normB);

    if (normA == 0 || normB == 0) {
      return 0.0;
    }

    return dotProduct / (normA * normB);
  }

  List<int> findMostSimilar(List<double> queryEmbedding, {int topK = 5}) {
    if (_features == null) {
      throw Exception('Features not loaded');
    }

    // Calculate similarities
    final similarities = List.generate(_features!.length, 
      (i) => _cosineSimilarity(queryEmbedding, _features![i]));

    // Sort indices by similarity
    final indices = List.generate(similarities.length, (i) => i);
    indices.sort((a, b) => similarities[b].compareTo(similarities[a]));

    // Return top K indices
    return indices.take(topK).toList();
  }

  bool get isLoaded => _features != null;
  int get numFeatures => _features?.first.length ?? 0;
} 