import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImagePoint {
  final int x;
  final int y;
  ImagePoint(this.x, this.y);
}

class ImageRectangle {
  final int left;
  final int top;
  final int width;
  final int height;
  ImageRectangle(this.left, this.top, this.width, this.height);
}

class DetectedSymbol {
  final img.Image image;
  final List<double>? features;
  final List<Map<String, dynamic>>? matches;

  DetectedSymbol({
    required this.image,
    this.features,
    this.matches,
  });
}

class ImageProcessingService {
  // Parameters for image processing
  static const int gaussianKernelSize = 5;
  static const int cannyThreshold1 = 80;
  static const int cannyThreshold2 = 140;
  static const int minSymbolSize = 30;  // Minimum size for a valid symbol
  static const double maxAspectRatio = 2.5;  // Maximum width/height ratio

  /// Process an image and detect individual symbols
  Future<List<DetectedSymbol>> detectSymbols(File imageFile) async {
    try {
      // Load and decode the image
      final bytes = await imageFile.readAsBytes();
      var originalImage = img.decodeImage(bytes);
      if (originalImage == null) throw Exception('Failed to load image');

      // Convert to grayscale for better edge detection
      var grayscale = img.grayscale(originalImage);

      // Apply Gaussian blur to reduce noise
      var blurred = _applyGaussianBlur(grayscale, gaussianKernelSize);

      // Apply Canny edge detection
      var edges = _applyCanny(blurred, cannyThreshold1, cannyThreshold2);

      // Find contours and extract symbols
      return _findAndExtractSymbols(originalImage, edges);
    } catch (e) {
      print('Error in detectSymbols: $e');
      rethrow;
    }
  }

  /// Apply Gaussian blur to reduce noise
  img.Image _applyGaussianBlur(img.Image input, int kernelSize) {
    var output = img.Image.from(input);
    var radius = kernelSize ~/ 2;
    var sigma = 1.0;

    // Create Gaussian kernel
    var kernel = List.generate(kernelSize, (_) => List.filled(kernelSize, 0.0));
    var sum = 0.0;
    for (var x = -radius; x <= radius; x++) {
      for (var y = -radius; y <= radius; y++) {
        var value = (1 / (2 * 3.14159 * sigma * sigma)) *
            math.exp(-(x * x + y * y) / (2 * sigma * sigma));
        kernel[x + radius][y + radius] = value;
        sum += value;
      }
    }

    // Normalize kernel
    for (var x = 0; x < kernelSize; x++) {
      for (var y = 0; y < kernelSize; y++) {
        kernel[x][y] /= sum;
      }
    }

    // Apply convolution
    for (var x = radius; x < input.width - radius; x++) {
      for (var y = radius; y < input.height - radius; y++) {
        var sum = 0.0;
        for (var kx = -radius; kx <= radius; kx++) {
          for (var ky = -radius; ky <= radius; ky++) {
            var pixel = input.getPixel(x + kx, y + ky);
            sum += pixel.r * kernel[kx + radius][ky + radius];
          }
        }
        var value = sum.round().clamp(0, 255);
        output.setPixelRgba(x, y, value, value, value, 255);
      }
    }

    return output;
  }

  /// Apply Canny edge detection
  img.Image _applyCanny(img.Image input, int threshold1, int threshold2) {
    var output = img.Image.from(input);
    var gradientX = img.Image.from(input);
    var gradientY = img.Image.from(input);

    // Compute gradients using Sobel operators
    for (var x = 1; x < input.width - 1; x++) {
      for (var y = 1; y < input.height - 1; y++) {
        var gx = -input.getPixel(x - 1, y - 1).r +
                 input.getPixel(x + 1, y - 1).r +
                -2 * input.getPixel(x - 1, y).r +
                 2 * input.getPixel(x + 1, y).r +
                -input.getPixel(x - 1, y + 1).r +
                 input.getPixel(x + 1, y + 1).r;

        var gy = -input.getPixel(x - 1, y - 1).r +
                -2 * input.getPixel(x, y - 1).r +
                -input.getPixel(x + 1, y - 1).r +
                 input.getPixel(x - 1, y + 1).r +
                 2 * input.getPixel(x, y + 1).r +
                 input.getPixel(x + 1, y + 1).r;

        var magnitude = math.sqrt(gx * gx + gy * gy).round().clamp(0, 255);
        var angle = math.atan2(gy.toDouble(), gx.toDouble());

        var gxValue = gx.abs().clamp(0, 255);
        var gyValue = gy.abs().clamp(0, 255);
        gradientX.setPixelRgba(x, y, gxValue, 0, 0, 255);
        gradientY.setPixelRgba(x, y, gyValue, 0, 0, 255);

        // Apply double thresholding
        var color = 0;
        if (magnitude > threshold2) {
          color = 255;  // Strong edge
        } else if (magnitude > threshold1) {
          color = 128;  // Weak edge
        }
        output.setPixelRgba(x, y, color, color, color, 255);
      }
    }

    // Non-maximum suppression and hysteresis
    var result = img.Image.from(input);
    for (var x = 1; x < input.width - 1; x++) {
      for (var y = 1; y < input.height - 1; y++) {
        if (output.getPixel(x, y).r > 0) {
          var angle = math.atan2(
            gradientY.getPixel(x, y).r.toDouble(),
            gradientX.getPixel(x, y).r.toDouble()
          );
          
          // Check if it's a local maximum
          var isMax = true;
          if ((angle >= -math.pi/8 && angle <= math.pi/8) || angle >= 7*math.pi/8 || angle <= -7*math.pi/8) {
            if (output.getPixel(x-1, y).r > output.getPixel(x, y).r ||
                output.getPixel(x+1, y).r > output.getPixel(x, y).r) {
              isMax = false;
            }
          } else if ((angle >= math.pi/8 && angle <= 3*math.pi/8) || (angle >= -7*math.pi/8 && angle <= -5*math.pi/8)) {
            if (output.getPixel(x-1, y-1).r > output.getPixel(x, y).r ||
                output.getPixel(x+1, y+1).r > output.getPixel(x, y).r) {
              isMax = false;
            }
          }
          
          if (isMax) {
            result.setPixelRgba(x, y, 255, 255, 255, 255);
          }
        }
      }
    }

    return result;
  }

  /// Find contours and extract individual symbols
  List<DetectedSymbol> _findAndExtractSymbols(img.Image original, img.Image edges) {
    var symbols = <DetectedSymbol>[];
    var visited = List.generate(
      edges.width,
      (_) => List.filled(edges.height, false),
    );

    // Find connected components (contours)
    for (var x = 0; x < edges.width; x++) {
      for (var y = 0; y < edges.height; y++) {
        if (!visited[x][y] && edges.getPixel(x, y).r > 128) {
          var contour = _traceContour(edges, visited, x, y);
          if (contour.isNotEmpty) {
            var bounds = _getBoundingBox(contour);
            
            // Filter out symbols that are too small or have extreme aspect ratios
            if (_isValidSymbol(bounds)) {
              var symbolImage = _extractSymbol(original, bounds);
              symbols.add(DetectedSymbol(image: symbolImage));
            }
          }
        }
      }
    }

    return symbols;
  }

  /// Trace a contour starting from a point
  List<ImagePoint> _traceContour(img.Image edges, List<List<bool>> visited, int startX, int startY) {
    var contour = <ImagePoint>[];
    var stack = <ImagePoint>[];
    stack.add(ImagePoint(startX, startY));

    while (stack.isNotEmpty) {
      var point = stack.removeLast();
      var x = point.x;
      var y = point.y;

      if (x >= 0 && x < edges.width && y >= 0 && y < edges.height &&
          !visited[x][y] && edges.getPixel(x, y).r > 128) {
        visited[x][y] = true;
        contour.add(point);

        // Add neighbors (8-connectivity)
        for (var dx = -1; dx <= 1; dx++) {
          for (var dy = -1; dy <= 1; dy++) {
            if (dx != 0 || dy != 0) {
              stack.add(ImagePoint(x + dx, y + dy));
            }
          }
        }
      }
    }

    return contour;
  }

  /// Get the bounding box of a contour
  ImageRectangle _getBoundingBox(List<ImagePoint> contour) {
    var minX = contour.map((p) => p.x).reduce(math.min);
    var maxX = contour.map((p) => p.x).reduce(math.max);
    var minY = contour.map((p) => p.y).reduce(math.min);
    var maxY = contour.map((p) => p.y).reduce(math.max);
    
    return ImageRectangle(minX, minY, maxX - minX + 1, maxY - minY + 1);
  }

  /// Check if a symbol's bounding box meets size and aspect ratio criteria
  bool _isValidSymbol(ImageRectangle bounds) {
    if (bounds.width < minSymbolSize || bounds.height < minSymbolSize) {
      return false;
    }
    
    var aspectRatio = bounds.width / bounds.height;
    if (aspectRatio > maxAspectRatio || aspectRatio < 1/maxAspectRatio) {
      return false;
    }
    
    return true;
  }

  /// Extract a symbol from the original image using its bounding box
  img.Image _extractSymbol(img.Image original, ImageRectangle bounds) {
    var symbol = img.Image(width: bounds.width, height: bounds.height);
    
    for (var x = 0; x < bounds.width; x++) {
      for (var y = 0; y < bounds.height; y++) {
        var pixel = original.getPixel(bounds.left + x, bounds.top + y);
        symbol.setPixel(x, y, pixel);
      }
    }
    
    return symbol;
  }
} 