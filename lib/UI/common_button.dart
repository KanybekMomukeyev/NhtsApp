import 'package:flutter/material.dart';

class ErrorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double maxWidth;
  final double maxHeight;
  final _style = const TextStyle(fontFamily: 'Montserrat', fontSize: 18.0);

  ErrorButton(this.label, this.onPressed,
      {this.maxWidth = 270, this.maxHeight = 40});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Center(
        child: Material(
          elevation: 2.0,
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.blue[500],
          child: MaterialButton(
            height: 40.0,
            minWidth: 250.0,
            splashColor: Colors.orange[400],
            padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            onPressed: onPressed,
            child: Text(label,
                textAlign: TextAlign.center,
                style: _style.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}
