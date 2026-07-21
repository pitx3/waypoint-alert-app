
class ParseWarning {
  final int rowNumber;
  final String message;
  final List<int>? duplicateRowNumbers;

  ParseWarning(this.rowNumber, this.message, [this.duplicateRowNumbers]);

  @override
  String toString() {
    if (duplicateRowNumbers != null) {
      return 'Rows ${duplicateRowNumbers!.join(', ')}: $message';
    }
    return 'Row $rowNumber: $message';
  }
}