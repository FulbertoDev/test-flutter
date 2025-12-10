import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/models/live_event.dart';

import '../../config/theme_config.dart';

class VideoPlayerWidget extends StatelessWidget {
  final LiveEvent event;
  const VideoPlayerWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingM),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundImage: CachedNetworkImageProvider(
                                event.seller.avatar,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              event.seller.name,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (event.status.name == 'live') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 8,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
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
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_circle_filled,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      event.status.name == 'live'
                          ? 'Vidéo en direct'
                          : 'Replay disponible',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
