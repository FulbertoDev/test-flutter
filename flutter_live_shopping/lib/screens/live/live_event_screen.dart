import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/providers/chat_provider.dart';
import 'package:flutter_live_shopping/widgets/live/video_player_widget.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../config/theme_config.dart';
import '../../providers/live_event_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/live/chat_widget.dart';
import '../../widgets/common/product_card.dart';

class LiveEventScreen extends StatefulWidget {
  final String eventId;

  const LiveEventScreen({super.key, required this.eventId});

  @override
  State<LiveEventScreen> createState() => _LiveEventScreenState();
}

class _LiveEventScreenState extends State<LiveEventScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveEventProvider>().joinEvent(widget.eventId);
      context.read<ChatProvider>().loadMessages(widget.eventId);
    });
  }

  @override
  void dispose() {
    context.read<LiveEventProvider>().leaveEvent();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<LiveEventProvider>(
        builder: (context, provider, _) {
          final event = provider.currentEvent;

          if (event == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return ScreenTypeLayout.builder(
            mobile: (context) => _buildMobileLayout(event),
            tablet: (context) => _buildDesktopLayout(event),
            desktop: (context) => _buildDesktopLayout(event),
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(event) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(flex: 3, child: VideoPlayerWidget(event: event)),
              Expanded(flex: 2, child: _buildProductsSection(event)),
            ],
          ),
        ),
        SizedBox(
          width: 400,
          child: Container(
            color: Colors.white,
            child: const Column(children: [Expanded(child: ChatWidget())]),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(event) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        final screenHeight = sizingInformation.screenSize.height;
        final overlayHeight = screenHeight * 0.4;

        return Stack(
          children: [
            Positioned.fill(child: VideoPlayerWidget(event: event)),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: overlayHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildProductsSection(event, horizontal: true),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: overlayHeight + 16,
              child: FloatingActionButton(
                onPressed: () => _showChatModal(context),
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.chat_bubble_outline),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsSection(event, {bool horizontal = false}) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingM),
            child: Row(
              children: [
                Text(
                  'Produits',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const Spacer(),
                if (event.featuredProduct != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'En vedette',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: event.products.isEmpty
                ? const Center(child: Text('Aucun produit'))
                : ResponsiveBuilder(
                    builder: (context, sizingInformation) {
                      int crossAxisCount;
                      double childAspectRatio;

                      if (sizingInformation.isDesktop) {
                        crossAxisCount = 3;
                        childAspectRatio = 0.68;
                      } else if (sizingInformation.isTablet) {
                        crossAxisCount = 2;
                        childAspectRatio = 0.68;
                      } else {
                        crossAxisCount = 1;
                        childAspectRatio = 0.68;
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(AppTheme.paddingM),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: AppTheme.paddingM,
                          mainAxisSpacing: AppTheme.paddingM,
                        ),
                        itemCount: event.products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(
                            product: event.products[index],
                            showFeaturedBadge: true,
                            onAddToCart: () {
                              context.read<CartProvider>().addItem(
                                event.products[index],
                                1,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Produit ajouté au panier'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusL),
              ),
            ),
            child: const ChatWidget(),
          );
        },
      ),
    );
  }
}
