class TypingText {
  final String originalText;
  final String typedText;
  
  const TypingText({
    required this.originalText, 
    this.typedText = '',
  });
  
  TypingText copyWith({
    String? originalText,
    String? typedText,
  }) {
    return TypingText(
      originalText: originalText ?? this.originalText,
      typedText: typedText ?? this.typedText,
    );
  }
}
