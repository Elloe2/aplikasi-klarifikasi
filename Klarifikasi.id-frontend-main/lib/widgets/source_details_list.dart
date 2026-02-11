import 'package:flutter/material.dart';
import '../models/source_analysis.dart';
import '../theme/app_theme.dart';

/// Widget untuk menampilkan list detail sumber
/// Menampilkan setiap sumber dengan stance, reasoning, dan quote
class SourceDetailsList extends StatelessWidget {
  final List<SourceAnalysis> sources;

  const SourceDetailsList({
    super.key,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Sumber (${sources.length})',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sources.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final source = sources[index];
            return _SourceDetailCard(source: source);
          },
        ),
      ],
    );
  }
}

class _SourceDetailCard extends StatelessWidget {
  final SourceAnalysis source;

  const _SourceDetailCard({required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStanceColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Index + Stance Badge
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getStanceColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${source.index}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  source.stanceText,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getStanceColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Reasoning
          Text(
            source.reasoning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.subduedGray,
              height: 1.4,
            ),
          ),

          // Quote (if available)
          if (source.hasQuote) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
                border: Border(
                  left: BorderSide(
                    color: _getStanceColor(),
                    width: 3,
                  ),
                ),
              ),
              child: Text(
                '"${source.quote}"',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mutedGray,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStanceColor() {
    switch (source.stance) {
      case 'SUPPORT':
        return const Color(0xFF10B981); // Green
      case 'OPPOSE':
        return const Color(0xFFEF4444); // Red
      case 'NEUTRAL':
        return const Color(0xFFF59E0B); // Yellow
      default:
        return Colors.grey;
    }
  }
}
