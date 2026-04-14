import 'package:flutter/material.dart';
import '../ui/ui.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  final String title;
  final String description;

  const FeaturePlaceholderPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppEmptyState(
        icon: Icons.architecture_outlined,
        title: title,
        description: description,
        actionLabel: 'Back',
        onAction: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
