class SentenceChip {
  final int id;
  final String word;
  final String? imageUrl;
  final String color;
  final bool isTyped;

  const SentenceChip({
    required this.id,
    required this.word,
    this.imageUrl,
    this.color = '#FFD700',
    this.isTyped = false,
  });
}
