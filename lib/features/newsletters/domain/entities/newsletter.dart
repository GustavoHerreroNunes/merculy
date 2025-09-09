import 'package:flutter/material.dart';
import 'package:merculy/main.dart';
import 'news_headline.dart';

class Newsletter {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final DateTime date;
  final bool hasNewData;
  final bool saved;
  final List<NewsHeadline> headlines;
  final Color primaryColor;
  final Color secondaryColor;

  Newsletter({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.date,
    this.hasNewData = false,
    this.saved = false,
    required this.headlines,
    required this.primaryColor,
    required this.secondaryColor,
  });

  List<NewsHeadline> get mainNews => 
      headlines.take(3).toList();

  List<NewsHeadline> get otherNews => 
      headlines.where((headline) => !mainNews.contains(headline)).toList();

  factory Newsletter.fromJson(Map<String, dynamic> json) {
    return Newsletter(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      date: DateTime.parse(json['date'] as String),
      hasNewData: json['hasNewData'] as bool? ?? false,
      saved: json['saved'] as bool? ?? false,
      headlines: (json['headlines'] as List<dynamic>)
          .map((headline) => NewsHeadline.fromJson(headline as Map<String, dynamic>))
          .toList(),
      primaryColor: Color(json['primaryColor'] as int),
      secondaryColor: Color(json['secondaryColor'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconCodePoint': icon.codePoint,
      'date': date.toIso8601String(),
      'hasNewData': hasNewData,
      'saved': saved,
      'headlines': headlines.map((headline) => headline.toJson()).toList(),
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
    };
  }
}
