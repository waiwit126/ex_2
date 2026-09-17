// lib/models/vocab.dart
class Vocab {
  final int? id;
  final String word;
  final String translation;
  final String wordType;
  final DateTime createdAt;

  Vocab({
    this.id,
    required this.word,
    required this.translation,
    required this.wordType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'word': word,
        'translation': translation,
        'wordType': wordType,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Vocab.fromMap(Map<String, dynamic> map) => Vocab(
        id: map['id'] as int?,
        word: map['word'] as String,
        translation: map['translation'] as String,
        wordType: map['wordType'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}