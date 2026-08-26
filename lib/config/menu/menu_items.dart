import 'package:flutter/material.dart';

class MenuItems {
  final String title;
  final String link;
  final IconData icon;

  const MenuItems({
    required this.title,
    required this.link,
    required this.icon,
  });
}

const List<MenuItems> appMenuItems = [
  MenuItems(title: "Inicio", icon: Icons.home_outlined, link: "/home"),

  MenuItems(
    title: "Test Breve de Estado de Ánimo",
    icon: Icons.calendar_month_outlined,
    link: "/testBreveEstadoAnimo/0",
  ),

  MenuItems(
    title: "Registro de Estado de Ánimo",
    icon: Icons.assignment_outlined,
    link: "/registroEstadoAnimo/0",
  ),

  MenuItems(
    title: "Externalización de voces",
    icon: Icons.chat_outlined,
    link: "/externalizacionVoces/0",
  ),
];
