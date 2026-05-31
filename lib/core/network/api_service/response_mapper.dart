class ResponseMapper {
  const ResponseMapper._();

  static Map<String, dynamic> toMap(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> toList(
    dynamic raw, {
    List<String> candidateKeys = const <String>['data'],
  }) {
    if (raw is List) return _castList(raw);
    if (raw is Map) {
      for (final key in candidateKeys) {
        final value = raw[key];
        if (value is List) return _castList(value);
      }
    }
    return <Map<String, dynamic>>[];
  }

  static Map<String, dynamic> toBundle(dynamic raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is List) {
      return <String, dynamic>{
        'data': _castList(raw),
        'meta': <String, dynamic>{},
      };
    }
    return <String, dynamic>{
      'data': <Map<String, dynamic>>[],
      'meta': <String, dynamic>{},
    };
  }

  static List<Map<String, dynamic>> _castList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
