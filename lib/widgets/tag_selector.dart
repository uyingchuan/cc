import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tag.dart';
import '../providers/tag_providers.dart';
import 'tag_chip.dart';

class TagSelector extends ConsumerWidget {
  final List<Tag> selectedTags;
  final ValueChanged<List<Tag>> onChanged;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);

    return tagsAsync.when(
      data: (tags) => tags.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: Text('暂无标签，去设置页添加',
                  style: TextStyle(color: Colors.grey)),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags.map((tag) {
                final isSelected = selectedTags.any((t) => t.id == tag.id);
                return TagChip(
                  tag: tag,
                  selected: isSelected,
                  onTap: () {
                    final updated = isSelected
                        ? selectedTags.where((t) => t.id != tag.id).toList()
                        : [...selectedTags, tag];
                    onChanged(updated);
                  },
                );
              }).toList(),
            ),
      loading: () => const SizedBox(),
      error: (_, _) => const SizedBox(),
    );
  }
}
