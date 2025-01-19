import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import '../services/tflite_service.dart';
import '../services/feature_service.dart';

// Events
abstract class HieroglyphicEvent extends Equatable {
  const HieroglyphicEvent();

  @override
  List<Object> get props => [];
}

class ProcessImageEvent extends HieroglyphicEvent {
  final File imageFile;

  const ProcessImageEvent(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

// States
abstract class HieroglyphicState extends Equatable {
  const HieroglyphicState();

  @override
  List<Object> get props => [];
}

class HieroglyphicInitial extends HieroglyphicState {}

class HieroglyphicProcessing extends HieroglyphicState {}

class HieroglyphicSuccess extends HieroglyphicState {
  final String text;
  final List<double>? embeddings;
  final List<int>? similarIndices;
  final List<double>? similarities;

  const HieroglyphicSuccess(
    this.text, {
    this.embeddings,
    this.similarIndices,
    this.similarities,
  });

  @override
  List<Object> get props => [
    text,
    embeddings ?? [],
    similarIndices ?? [],
    similarities ?? [],
  ];
}

class HieroglyphicError extends HieroglyphicState {
  final String message;

  const HieroglyphicError(this.message);

  @override
  List<Object> get props => [message];
}

// BLoC
class HieroglyphicBloc extends Bloc<HieroglyphicEvent, HieroglyphicState> {
  String _locale = 'en';
  final TFLiteService _tfliteService = TFLiteService();
  final FeatureService _featureService = FeatureService();
  bool _isModelLoaded = false;
  bool _areFeaturesLoaded = false;

  HieroglyphicBloc() : super(HieroglyphicInitial()) {
    on<ProcessImageEvent>(_processImage);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await Future.wait([
        _loadModel(),
        _loadFeatures(),
      ]);
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  Future<void> _loadModel() async {
    try {
      await _tfliteService.loadModel();
      _isModelLoaded = true;
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> _loadFeatures() async {
    try {
      await _featureService.loadFeatures();
      _areFeaturesLoaded = true;
    } catch (e) {
      print('Error loading features: $e');
    }
  }

  void updateLocale(String locale) {
    _locale = locale;
  }

  Future<void> _processImage(
    ProcessImageEvent event,
    Emitter<HieroglyphicState> emit,
  ) async {
    try {
      emit(HieroglyphicProcessing());

      if (!_isModelLoaded) {
        await _loadModel();
        if (!_isModelLoaded) {
          throw Exception('Failed to load TFLite model');
        }
      }

      if (!_areFeaturesLoaded) {
        await _loadFeatures();
        if (!_areFeaturesLoaded) {
          throw Exception('Failed to load feature vectors');
        }
      }

      // Process the image through the model
      final embeddings = await _tfliteService.processImage(event.imageFile);

      // Find similar hieroglyphs
      final similarIndices = _featureService.findMostSimilar(embeddings);

      // TODO: Implement proper translation based on similar hieroglyphs
      // For now, we'll use placeholder translations
      final Map<String, String> translations = {
        'en': "Found ${similarIndices.length} similar hieroglyphs",
        'es': "Se encontraron ${similarIndices.length} jeroglíficos similares",
        'ar': "تم العثور على ${similarIndices.length} نقوش هيروغليفية مماثلة",
        'fr': "Trouvé ${similarIndices.length} hiéroglyphes similaires",
        'nl': "Gevonden ${similarIndices.length} vergelijkbare hiërogliefen"
      };
      
      emit(HieroglyphicSuccess(
        translations[_locale] ?? translations['en']!,
        embeddings: embeddings,
        similarIndices: similarIndices,
      ));
    } catch (e) {
      emit(HieroglyphicError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _tfliteService.dispose();
    return super.close();
  }
} 