// models/crossword.dart

class CrossWord {
  final int? id;
  final String word;
  final String clue;
  final String date;

  CrossWord(
      {this.id, required this.word, required this.clue, required this.date});

  // Convert a CrossWord into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'clue': clue,
      'date': date,
    };
  }

  // Implement toString to make it easier to see information about each word when using the print statement.
  @override
  String toString() {
    return 'CrossWord{id: $id, word: $word, clue: $clue, date: $date}';
  }
}
