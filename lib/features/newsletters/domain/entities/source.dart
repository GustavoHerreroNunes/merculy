class Source {
  final String websiteRoot;
  final String fantasyName;
  final String articleLink;

  Source({
    required this.websiteRoot,
    required this.fantasyName,
    required this.articleLink,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      websiteRoot: json['websiteRoot'] as String,
      fantasyName: json['fantasyName'] as String,
      articleLink: json['articleLink'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'websiteRoot': websiteRoot,
      'fantasyName': fantasyName,
      'articleLink': articleLink,
    };
  }
}
