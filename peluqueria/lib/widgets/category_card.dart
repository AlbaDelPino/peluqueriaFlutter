import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String nombre;
  final IconData icon;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.nombre,
    required this.icon,
    required this.onTap,
  });

  static const primary = Color(0xFFFF8B00);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: primary, size: 40),
            const SizedBox(height: 12),
            Text(
              nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
