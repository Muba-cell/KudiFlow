import 'package:flutter/material.dart';

const expenseCategories = [
  "Food",
  "Transport",
  "Bills",
  "Shopping",
  "Entertainment",
  "Health",
  "Savings",
  "Other",
];

const incomeCategories = [
  "Salary",
  "Business",
  "Gift",
  "Other",
];

IconData categoryIcon(String category) {
  switch (category) {
    case "Food":
      return Icons.restaurant;
    case "Transport":
      return Icons.directions_bus;
    case "Bills":
      return Icons.receipt_long;
    case "Shopping":
      return Icons.shopping_bag;
    case "Entertainment":
      return Icons.movie;
    case "Health":
      return Icons.medical_services;
    case "Savings":
      return Icons.emoji_events_outlined;
    case "Salary":
      return Icons.work;
    case "Business":
      return Icons.business_center;
    case "Gift":
      return Icons.card_giftcard;
    default:
      return Icons.category;
  }
}

Color categoryColor(String category) {
  switch (category) {
    case "Food":
      return const Color(0xFFFF8A65);
    case "Transport":
      return const Color(0xFF64B5F6);
    case "Bills":
      return const Color(0xFFBA68C8);
    case "Shopping":
      return const Color(0xFFFFD54F);
    case "Entertainment":
      return const Color(0xFF4DB6AC);
    case "Health":
      return const Color(0xFFE57373);
    case "Savings":
      return const Color(0xFF8D6E63);
    case "Salary":
      return const Color(0xFF81C784);
    case "Business":
      return const Color(0xFF7986CB);
    case "Gift":
      return const Color(0xFFF06292);
    default:
      return const Color(0xFF90A4AE);
  }
}
