import 'package:flutter/material.dart';
import '../../models/topic_category.dart';
import '../../theme/artistic_palettes.dart';

class SubtopicChipBar extends StatelessWidget {
  final TopicCategory? currentCategory;
  final String? selectedSubtopic;
  final ArtisticPalette palette;
  final bool isDark;
  final Function(String?) onSelectSubtopic;
  final VoidCallback onAddSubtopic;

  const SubtopicChipBar({
    super.key,
    required this.currentCategory,
    required this.selectedSubtopic,
    required this.palette,
    required this.isDark,
    required this.onSelectSubtopic,
    required this.onAddSubtopic,
  });

  @override
  Widget build(BuildContext context) {
    if (currentCategory == null) return const SizedBox.shrink();

    final catColor = currentCategory!.color;
    final subtopics = currentCategory!.subtopics;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // "Todos los subtemas" chip
          _buildChip(
            label: 'Todos',
            icon: Icons.grid_view,
            isSelected: selectedSubtopic == null,
            color: catColor,
            onTap: () => onSelectSubtopic(null),
          ),

          ...subtopics.map((subtopic) {
            final isSelected = selectedSubtopic?.toLowerCase() == subtopic.toLowerCase();
            return _buildChip(
              label: subtopic,
              icon: null,
              isSelected: isSelected,
              color: catColor,
              onTap: () => onSelectSubtopic(isSelected ? null : subtopic),
            );
          }),

          // "+ Nuevo subtema" button
          Container(
            margin: const EdgeInsets.only(left: 6, top: 4, bottom: 4),
            child: InkWell(
              onTap: onAddSubtopic,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: catColor.withAlpha(isDark ? 90 : 60),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 14, color: catColor),
                    const SizedBox(width: 4),
                    Text(
                      'Subtema',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: catColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha(isDark ? 210 : 230)
                : (isDark ? Colors.white : Colors.black).withAlpha(12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? Colors.white : Colors.black).withAlpha(25),
              width: 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withAlpha(80),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
