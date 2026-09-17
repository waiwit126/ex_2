// lib/screens/widgets/item_vocab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/vocab.dart';

class ItemVocab extends StatelessWidget {
  final Vocab vocab;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ItemVocab({
    super.key,
    required this.vocab,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy, HH:mm');

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: const Color.fromARGB(226, 199, 195, 183), // สีพื้นหลัง Card
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vocab.word,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${vocab.wordType})',
                      style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(vocab.createdAt),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  vocab.translation,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            
            ],
          ),
        ),
      ),
    );
  }
}