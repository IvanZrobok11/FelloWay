/// Shared API error envelope (`shared/api-contracts/common/openapi.yaml`).
class ErrorResponse {
  const ErrorResponse({
    required this.code,
    required this.message,
    this.details = const [],
  });

  final String code;
  final String message;
  final List<FieldError> details;

  static ErrorResponse? tryParse(Object? data) {
    if (data is! Map<String, dynamic>) return null;
    final message = data['message'];
    if (message is! String || message.isEmpty) return null;
    final code = data['code'] as String? ?? 'error';
    final rawDetails = data['details'] as List<dynamic>? ?? const [];
    final details = rawDetails
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => FieldError(
            field: e['field'] as String? ?? '',
            message: e['message'] as String? ?? '',
          ),
        )
        .toList();
    return ErrorResponse(code: code, message: message, details: details);
  }

  String get displayMessage {
    if (details.isEmpty) return message;
    final first = details.firstWhere(
      (e) => e.message.isNotEmpty,
      orElse: () => details.first,
    );
    return first.message.isNotEmpty ? first.message : message;
  }
}

class FieldError {
  const FieldError({required this.field, required this.message});

  final String field;
  final String message;
}
