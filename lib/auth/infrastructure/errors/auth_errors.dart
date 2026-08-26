class WrongCredentials implements Exception {}

class InvalidTokens implements Exception {}

class ConnectionTimeout implements Exception {}

class EmailNotVerified implements Exception {}

class CustomError implements Exception {
  final String message;
  final int errorCode;

  CustomError(this.message, this.errorCode);
}
