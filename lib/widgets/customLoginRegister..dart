import 'package:flutter/material.dart';


class CustomLoginRegisterContainer extends StatelessWidget {
  const CustomLoginRegisterContainer({super.key, required this.containerContent});

  final Widget containerContent;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30)
        ),
        child: Container(
          height: double.infinity,
          color:  Theme.of(context).colorScheme.surface,
          child: containerContent,
        ),
      );
  }
}