import 'package:flutter/material.dart';

class Topic {
  final String id;
  final String name;
  final String icon;
  final bool isActive;
  final Color primaryColor;
  final Color secondaryColor;

  Topic({
    required this.id,
    required this.name,
    required this.icon,
    required this.isActive,
    required this.primaryColor,
    required this.secondaryColor,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      isActive: json['isActive'] as bool,
      primaryColor: Color(_parseColorString(json['primary-color'] as String)),
      secondaryColor: Color(_parseColorString(json['secondary-color'] as String)),
    );
  }

  static int _parseColorString(String colorString) {
    // Remove the '#' and convert to int
    return int.parse(colorString.replaceFirst('#', ''), radix: 16) + 0xFF000000;
  }

  IconData get iconData {
    // Map string icon names to IconData
    switch (icon.toLowerCase()) {
      case 'account_balance':
        return Icons.account_balance;
      case 'computer':
        return Icons.computer;
      case 'attach_money':
        return Icons.attach_money;
      case 'eco':
        return Icons.eco;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'favorite':
        return Icons.favorite;
      case 'school':
        return Icons.school;
      case 'business':
        return Icons.business;
      case 'movie':
        return Icons.movie;
      case 'restaurant':
        return Icons.restaurant;
      case 'flight':
        return Icons.flight;
      case 'home':
        return Icons.home;
      case 'directions_car':
        return Icons.directions_car;
      case 'brush':
        return Icons.brush;
      case 'science':
        return Icons.science;
      case 'gavel':
        return Icons.gavel;
      case 'public':
        return Icons.public;
      case 'psychology':
        return Icons.psychology;
      default:
        return Icons.article; // Default fallback icon
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'isActive': isActive,
      'primary-color': '#${primaryColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      'secondary-color': '#${secondaryColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
    };
  }
}
