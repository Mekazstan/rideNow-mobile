import 'package:ridenowappsss/modules/ride/data/models/place_prediction.dart';

class LocationSuggestionsState {
  final List<PlacePrediction> suggestions;
  final bool isVisible;
  final bool isLoading;

  LocationSuggestionsState({
    this.suggestions = const [],
    this.isVisible = false,
    this.isLoading = false,
  });

  LocationSuggestionsState copyWith({
    List<PlacePrediction>? suggestions,
    bool? isVisible,
    bool? isLoading,
  }) {
    return LocationSuggestionsState(
      suggestions: suggestions ?? this.suggestions,
      isVisible: isVisible ?? this.isVisible,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
