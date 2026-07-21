class ParseError {
  final int rowNumber;
  final String message;

  ParseError(this.rowNumber, this.message);

  @override
  String toString() => 'Row $rowNumber: $message';
}