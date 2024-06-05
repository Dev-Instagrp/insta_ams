import 'package:flutter/material.dart';

class CircularButtons extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const CircularButtons({super.key, required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xFF3880EE).withOpacity(0.45),
              offset: Offset(3, 4),
              blurRadius: 10,
            )
          ],
          shape: BoxShape.circle,
          gradient: LinearGradient(
              colors: [
                Color(0xFF3680EB),
                Color(0xFFC087E5),
              ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white,),
            Text(title, style: TextStyle(fontSize: 20, color: Colors.white),)
          ],
        ),
      ),
    );
  }
}
