class Source {
  final String websiteRoot;
  final String fantasyName;
  final String articleLink;
  final String? title;
  final String? quote;

  Source({
    required this.websiteRoot,
    required this.fantasyName,
    required this.articleLink,
    this.title,
    this.quote,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      websiteRoot: json['websiteRoot'] as String,
      fantasyName: json['fantasyName'] as String,
      articleLink: json['articleLink'] as String,
      title: json['title'] as String?,
      quote: json['quote'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteRoot': websiteRoot,
      'fantasyName': fantasyName,
      'articleLink': articleLink,
      'title': title,
      'quote': quote,
    };
  }
}
