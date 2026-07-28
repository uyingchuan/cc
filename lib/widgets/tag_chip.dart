import 'package:flutter/material.dart';

import '../models/tag.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool compact;
  final VoidCallback? onTap;
  final bool selected;

  const TagChip({
    super.key,
    required this.tag,
    this.compact = false,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(tag.color);
    final child = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: selected ? bgColor.withAlpha(40) : bgColor.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: selected
            ? Border.all(color: bgColor, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            tag.name,
            style: TextStyle(
              fontSize: compact ? 11 : 13,
              color: bgColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: child);
    }
    return child;
  }
}
