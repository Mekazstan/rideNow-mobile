import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

abstract class PolylineDecoder {
  Future<List<LatLng>> decode(String encoded);
}

class PolylineDecoderImpl implements PolylineDecoder {
  @override
  Future<List<LatLng>> decode(String encoded) async {
    if (encoded.isEmpty) return [];
    return compute(_decodePoints, encoded);
  }

  static List<LatLng> _decodePoints(String encoded) {
    final points = <LatLng>[];
    int index = 0;
    final len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      lat += _decodePointStatic(encoded, index, (newIndex) => index = newIndex);
      lng += _decodePointStatic(encoded, index, (newIndex) => index = newIndex);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  static int _decodePointStatic(
    String encoded,
    int index,
    void Function(int) updateIndex,
  ) {
    int b;
    int shift = 0;
    int result = 0;

    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1F) << shift;
      shift += 5;
    } while (b >= 0x20);

    updateIndex(index);

    return (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
  }
}
