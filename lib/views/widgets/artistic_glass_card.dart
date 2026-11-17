import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/text_item.dart';
import '../../models/topic_category.dart';
import '../../theme/app_decorations.dart';
import '../../theme/artistic_palettes.dart';

class ArtisticGlassCard extends StatelessWidget {
  final TextItem item;
  final TopicCategory? category;
  final ArtisticPalette palette;
  final bool isDark;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final VoidCallback? onDelete;
  final VoidCallback? onRefreshUrl;

  const ArtisticGlassCard({
    super.key,
    required this.item,
    this.category,
    required this.palette,
    required this.isDark,
    this.isSelected = false,
    required this.onTap,
    required this.onToggleFavorite,
    this.onDelete,
    this.onRefreshUrl,
  });

  @override
  Widget build(BuildContext context) {
    final catColor = category?.color ?? palette.primary;
    final moodColor = item.analysis != null
        ? Color(item.analysis!.moodColorHex)
        : palette.secondary;
    final moodEmoji = item.analysis?.moodEmoji ?? '✨';

    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? palette.primary
              : catColor.withAlpha(isDark ? 60 : 40),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: palette.primary.withAlpha(60),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: AppDecorations.glassContainer(
        palette: palette,
        isDark: isDark,
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Category badge, Subtopic & Favorite button
            Row(
              children: [
                // Category Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withAlpha(isDark ? 45 : 30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: catColor.withAlpha(100), width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(category?.icon ?? Icons.auto_awesome,
                          size: 13, color: catColor),
                      const SizedBox(width: 5),
                      Text(
                        item.subtopic,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: catColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Mood Indicator Pill
                if (item.analysis != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: moodColor.withAlpha(isDark ? 40 : 25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: moodColor.withAlpha(80), width: 0.8),
                    ),
                    child: Text(
                      '$moodEmoji ${item.analysis!.mood}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: moodColor,
                      ),
                    ),
                  ),

                const Spacer(),

                // URL source icon
                if (item.isFromUrl)
                  Tooltip(
                    message: 'Sincronizado desde URL: ${item.sourceUrl}',
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: palette.secondary.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_done_outlined,
                        size: 14,
                        color: palette.secondary,
                      ),
                    ),
                  ),

                // Favorite button
                InkWell(
                  onTap: onToggleFavorite,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: item.isFavorite
                          ? const Color(0xFFE63946)
                          : (isDark ? Colors.white38 : Colors.black26),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Poem / Text Title
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.25,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            // Content excerpt (poetic lines)
            Text(
              item.content.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: 14.5,
                fontStyle: FontStyle.italic,
                height: 1.45,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),

            const SizedBox(height: 14),

            // Bottom Footer: Metrics, tags & action indicators
            Row(
              children: [
                // Verse / Word stats
                Icon(
                  Icons.notes_rounded,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                const SizedBox(width: 4),
                Text(
                  item.analysis != null
                      ? '${item.analysis!.verseCount} versos · ${item.analysis!.wordCount} palabras'
                      : '${item.content.split('\n').length} líneas',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),

                const Spacer(),

                // Tags preview (up to 2)
                ...item.tags.take(2).map(
                      (tag) => Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withAlpha(12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.05, end: 0);
  }
}
