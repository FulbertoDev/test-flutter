import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/live_event.dart';
import '../../config/theme_config.dart';
import '../../utils/app_enums.dart';

class EventCard extends StatelessWidget {
  final LiveEvent event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/live/${event.id}'),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: event.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.borderColor,
                      child: const Icon(Icons.image, size: 48),
                    ),
                  ),
                ),
                Positioned(top: 12, left: 12, child: _buildStatusBadge()),
                if (event.status == LiveEventStatus.live)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.viewerCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(event.seller.avatar),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.seller.name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              event.seller.storeName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildEventTime(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (event.status) {
      case LiveEventStatus.live:
        badgeColor = AppTheme.errorColor;
        badgeText = 'EN DIRECT';
        badgeIcon = Icons.circle;
        break;
      case LiveEventStatus.scheduled:
        badgeColor = AppTheme.primaryColor;
        badgeText = 'À VENIR';
        badgeIcon = Icons.schedule;
        break;
      case LiveEventStatus.ended:
        badgeColor = AppTheme.textSecondaryColor;
        badgeText = 'REPLAY';
        badgeIcon = Icons.replay;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTime(BuildContext context) {
    if (event.status == LiveEventStatus.live) {
      return Row(
        children: [
          const Icon(
            Icons.access_time,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            'Commencé à ${DateFormat.Hm().format(event.startTime)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    } else if (event.status == LiveEventStatus.scheduled) {
      return Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            DateFormat('d MMM yyyy à HH:mm').format(event.startTime),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const Icon(
            Icons.history,
            size: 16,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            'Terminé le ${DateFormat('d MMM yyyy').format(event.startTime)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }
  }
}
