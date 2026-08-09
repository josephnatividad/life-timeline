import 'package:flutter/material.dart';

final class AppDivider extends StatelessWidget {
  const AppDivider({this.indent = 0, this.endIndent = 0, super.key});

  final double endIndent;
  final double indent;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Divider(endIndent: endIndent, indent: indent),
  );
}
