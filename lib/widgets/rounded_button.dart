import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String name;
  final double height;
  final double width;
  final Function onPressed;

  const RoundedButton({
    required this.name,
    required this.height,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(
          0,
          82,
          218,
          1.0,
        ), // ✅ moved inside decoration
        borderRadius: BorderRadius.circular(height * 0.25),
      ),
      child: TextButton(
        onPressed: () => onPressed(), // ✅ now actually uses the passed function
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            height: 0.1,
          ),
        ),
      ),
    );
  }
}
