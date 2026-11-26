import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../widgets/loader.dart';
import '../../widgets/lookout_app_bar.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final faqsStream = FirebaseFirestore.instance
        .collection('feedback_faqs')
        .where('type', isEqualTo: 'faq')
        .snapshots();

    return Scaffold(
      appBar: const LookOutAppBar(title: 'FAQs'),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: faqsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Unable to load FAQs: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) return const Loader.circular();

          final faqs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final questionA = a.data()['question']?.toString() ?? '';
              final questionB = b.data()['question']?.toString() ?? '';
              return questionA.toLowerCase().compareTo(questionB.toLowerCase());
            });

          if (faqs.isEmpty) {
            return const Center(child: Text('No FAQs available yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: faqs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = faqs[index].data();
              final question = data['question']?.toString() ?? '';
              final answer = data['answer']?.toString() ?? '';

              return Card(
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  title: Text(
                    question,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(answer, style: theme.textTheme.bodyMedium),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
