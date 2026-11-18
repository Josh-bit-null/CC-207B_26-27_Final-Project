import 'package:flutter/material.dart';

class FeedbackFaqsScreen extends StatelessWidget {
  const FeedbackFaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Expanded(
            child: Center(
              child: Text('Feedback and FAQs'),
            ),
          ),
        ],
      ),
    );
  }
}