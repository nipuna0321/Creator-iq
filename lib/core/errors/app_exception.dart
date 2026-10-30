/// Base exception class for CreatorIQ errors.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class ValidationException extends AppException {
  final List<String> errors;
  ValidationException(String message, {this.errors = const []})
      : super(message, code: 'VALIDATION_ERROR', details: errors);
}

class ImportException extends AppException {
  final int? rowNumber;
  ImportException(String message, {this.rowNumber})
      : super(message, code: 'IMPORT_ERROR', details: {'row': rowNumber});
}

class StorageException extends AppException {
  StorageException(String message) : super(message, code: 'STORAGE_ERROR');
}

