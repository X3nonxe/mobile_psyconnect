// TimeSelect
import 'package:flutter/material.dart';
import 'package:psyconnect/config/color_pallate.dart';

class TimeSelect extends StatelessWidget {
  final String mainText;
  final bool isSelected;
  final VoidCallback onTap;

  const TimeSelect({super.key, 
    required this.mainText,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? bluePrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: bluePrimaryColor),
        ),
        child: Center(
          child: Text(
            mainText,
            style: TextStyle(
              color: isSelected ? Colors.white : bluePrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
