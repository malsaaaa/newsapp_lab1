// lib/article.dart

class Article {
  final String title;
  final String description;
  final String urlToImage;
  final String url;

  Article({
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.url,
  });

  /// Truncates text to a maximum length with ellipsis
  static String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    // Truncate to maxLength and add ellipsis, but try to cut at a word boundary
    String truncated = text.substring(0, maxLength);
    int lastSpace = truncated.lastIndexOf(' ');
    if (lastSpace > 0 && maxLength - lastSpace < 20) {
      truncated = text.substring(0, lastSpace);
    }
    return '$truncated...';
  }

  /// Get truncated description for list view (max 200 characters)
  String get truncatedDescription => _truncateText(description, 200);

  /// Get image URL with fallback to Placeholder service
  String get imageUrl {
    if (urlToImage.isNotEmpty) {
      return urlToImage;
    }
    // Fallback: Use Picsum for a generic news-related image
    return 'https://picsum.photos/400/300?random=${title.hashCode}';
  }

  /// Removes HTML tags from text
  static String _stripHtmlTags(String text) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    return text.replaceAll(exp, '');
  }

  /// Decodes HTML entities in text
  static String _decodeHtmlEntities(String text) {
    // First strip HTML tags
    String cleaned = _stripHtmlTags(text);
    
    // Then decode HTML entities
    return cleaned
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#x27;', "'")
        .replaceAll('&#46;', '.')
        .replaceAll('&#44;', ',')
        .replaceAll('&#33;', '!')
        .replaceAll('&#58;', ':')
        .replaceAll('&#59;', ';')
        .replaceAll('&#63;', '?')
        .replaceAll(RegExp(r'&#\d+;'), '') // Remove any remaining numeric entities
        .replaceAll(RegExp(r'&[a-z]+;'), '') // Remove any remaining named entities
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    final String rawTitle = json['title'] ?? 'No Title';
    final String rawDescription = json['description'] ?? 'No Description';
    
    return Article(
      title: _decodeHtmlEntities(rawTitle),
      description: _decodeHtmlEntities(rawDescription),
      urlToImage: json['urlToImage'] ?? json['image'] ?? json['image_url'] ?? '',
      url: json['url'] ?? json['link'] ?? '',
    );
  }
}
