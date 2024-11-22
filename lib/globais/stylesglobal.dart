import 'package:flutter/material.dart';
import 'colorsglobal.dart';

BoxBorder bordaFina = Border.all(
    width: 0.5,
    color: Colors.black
);

ButtonStyle buttonPrincipalRound = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(principal)
);

ButtonStyle buttonPrincipalSquare = ButtonStyle(
  backgroundColor: WidgetStateProperty.all(principal),
  shape: WidgetStateProperty.all(
    const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
  ),
);

ButtonStyle buttonRedSquare = ButtonStyle(
  backgroundColor: WidgetStateProperty.all(erro),
  shape: WidgetStateProperty.all(
    const RoundedRectangleBorder(
      borderRadius: BorderRadius.zero,
    ),
  ),
);