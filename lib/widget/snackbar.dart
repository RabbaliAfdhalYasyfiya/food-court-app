import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void snackBarCustom(
  BuildContext context,
  Color backgroundColor,
  String? message,
  Color? messageColor,
) async {
  await Flushbar(
    duration: const Duration(seconds: 4),
    animationDuration: const Duration(milliseconds: 400),
    backgroundColor: backgroundColor,
    flushbarPosition: FlushbarPosition.TOP,
    flushbarStyle: FlushbarStyle.GROUNDED,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    message: message,
    messageColor: messageColor,
    messageSize: 16,
  ).show(context);
}
