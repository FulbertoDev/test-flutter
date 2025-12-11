import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_live_shopping/widgets/common/banner.dart';
import 'package:flutter_live_shopping/widgets/common/cart_preview_widget.dart';
import 'package:flutter_live_shopping/widgets/common/empty_state_view.dart';
import 'package:flutter_live_shopping/widgets/common/error_state_view.dart';
import 'package:flutter_live_shopping/widgets/navigation/app_drawer.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../config/theme_config.dart';
import '../../providers/live_event_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_enums.dart';
import '../../widgets/common/event_card.dart';
import '../../widgets/common/footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  LiveEventStatus? _selectedStatus;
  String _selectedDateFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiveEventProvider>().loadEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Live Shopping'),
          ],
        ),
        centerTitle: false,
        actions: [
          const SizedBox.shrink(),
          Consumer<CartProvider>(
            builder: (context, cart, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => _showCartDrawer(context),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: themeProvider.isDarkMode
                    ? 'Mode clair'
                    : 'Mode sombre',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => context.read<LiveEventProvider>().loadEvents(),
        child: Consumer<LiveEventProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.events.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.events.isEmpty) {
              return ErrorStateView(provider: provider);
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Banner(),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Rechercher un événement...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value.toLowerCase());
                          },
                        ),
                        const SizedBox(height: 16),
                        ResponsiveBuilder(
                          builder: (context, sizingInformation) {
                            final isMobile =
                                sizingInformation.deviceScreenType ==
                                DeviceScreenType.mobile;

                            final categoryFilter = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filtrer par catégorie',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusM,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.borderColor,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCategory,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.category,
                                        size: 20,
                                      ),
                                    ),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('Toutes les catégories'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Mode',
                                        child: Text('👗 Mode'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Beauté',
                                        child: Text('💄 Beauté'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Électronique',
                                        child: Text('📱 Électronique'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(
                                          () => _selectedCategory = value,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );

                            final statusFilter = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filtrer par statut',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusM,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.borderColor,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child:
                                      DropdownButtonFormField<LiveEventStatus?>(
                                        value: _selectedStatus,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          border: InputBorder.none,
                                          prefixIcon: Icon(
                                            Icons.filter_list,
                                            size: 20,
                                          ),
                                        ),
                                        icon: const Icon(Icons.arrow_drop_down),
                                        isExpanded: true,
                                        items: const [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text('Tous les statuts'),
                                          ),
                                          DropdownMenuItem(
                                            value: LiveEventStatus.live,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.circle,
                                                  size: 12,
                                                  color: AppTheme.errorColor,
                                                ),
                                                SizedBox(width: 8),
                                                Text('En direct'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: LiveEventStatus.scheduled,
                                            child: Row(
                                              children: [
                                                Icon(Icons.schedule, size: 12),
                                                SizedBox(width: 8),
                                                Text('À venir'),
                                              ],
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: LiveEventStatus.ended,
                                            child: Row(
                                              children: [
                                                Icon(Icons.replay, size: 12),
                                                SizedBox(width: 8),
                                                Text('Replays'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(
                                            () => _selectedStatus = value,
                                          );
                                        },
                                      ),
                                ),
                              ],
                            );

                            final dateFilter = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Filtrer par date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusM,
                                    ),
                                    border: Border.all(
                                      color: AppTheme.borderColor,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedDateFilter,
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      border: InputBorder.none,
                                      prefixIcon: Icon(
                                        Icons.date_range,
                                        size: 20,
                                      ),
                                    ),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'all',
                                        child: Text('Toutes les dates'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'today',
                                        child: Row(
                                          children: [
                                            Icon(Icons.today, size: 14),
                                            SizedBox(width: 8),
                                            Text('Aujourd\'hui'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'week',
                                        child: Row(
                                          children: [
                                            Icon(Icons.date_range, size: 14),
                                            SizedBox(width: 8),
                                            Text('Cette semaine'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'month',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_month,
                                              size: 14,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Ce mois'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(
                                          () => _selectedDateFilter = value,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );

                            if (isMobile) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  categoryFilter,
                                  const SizedBox(height: 16),
                                  statusFilter,
                                  const SizedBox(height: 16),
                                  dateFilter,
                                ],
                              );
                            } else {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: categoryFilter),
                                  const SizedBox(width: 16),
                                  Expanded(child: statusFilter),
                                  const SizedBox(width: 16),
                                  Expanded(child: dateFilter),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  if (_getFilteredEvents(provider.liveEvents).isNotEmpty) ...[
                    Section(
                      context: context,
                      title: '🔴 En Direct',
                      events: _getFilteredEvents(provider.liveEvents),
                    ),
                  ],
                  if (_getFilteredEvents(
                    provider.scheduledEvents,
                  ).isNotEmpty) ...[
                    Section(
                      context: context,
                      title: '📅 À venir',
                      events: _getFilteredEvents(provider.scheduledEvents),
                    ),
                  ],
                  if (_getFilteredEvents(provider.endedEvents).isNotEmpty) ...[
                    Section(
                      context: context,
                      title: '🎬 Replays',
                      events: _getFilteredEvents(provider.endedEvents),
                    ),
                  ],
                  if (_getFilteredEvents(provider.events).isEmpty &&
                      (_searchQuery.isNotEmpty ||
                          _selectedCategory != 'all' ||
                          _selectedStatus != null ||
                          _selectedDateFilter != 'all')) ...[
                    EmptyStateView(),
                  ],
                  const SizedBox(height: AppTheme.paddingXL),
                  const Footer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<dynamic> _getFilteredEvents(List events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    return events.where((event) {
      if (_searchQuery.isNotEmpty) {
        final matchesSearch =
            event.title.toLowerCase().contains(_searchQuery) ||
            event.description.toLowerCase().contains(_searchQuery) ||
            event.seller.name.toLowerCase().contains(_searchQuery);
        if (!matchesSearch) return false;
      }

      if (_selectedCategory != 'all') {
        final hasMatchingProduct = event.products.any(
          (product) => product.category == _selectedCategory,
        );
        if (!hasMatchingProduct) return false;
      }

      if (_selectedStatus != null && event.status != _selectedStatus) {
        return false;
      }

      if (_selectedDateFilter != 'all') {
        final eventDate = DateTime(
          event.startTime.year,
          event.startTime.month,
          event.startTime.day,
        );

        switch (_selectedDateFilter) {
          case 'today':
            if (eventDate != today) return false;
            break;
          case 'week':
            if (eventDate.isBefore(weekStart) ||
                eventDate.isAfter(today.add(const Duration(days: 6)))) {
              return false;
            }
            break;
          case 'month':
            if (eventDate.isBefore(monthStart) ||
                eventDate.month != now.month) {
              return false;
            }
            break;
        }
      }

      return true;
    }).toList();
  }

  void _showCartDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return CartPreviewWidget(scrollController: scrollController);
        },
      ),
    );
  }
}

class Section extends StatelessWidget {
  const Section({
    super.key,
    required this.context,
    required this.title,
    required this.events,
  });

  final BuildContext context;
  final String title;
  final List events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.paddingL,
            AppTheme.paddingL,
            AppTheme.paddingL,
            AppTheme.paddingM,
          ),
          child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
        ),
        ResponsiveBuilder(
          builder: (context, sizingInformation) {
            int crossAxisCount;
            double childAspectRatio;

            switch (sizingInformation.deviceScreenType) {
              case DeviceScreenType.desktop:
                crossAxisCount = 4;
                childAspectRatio = .98;
                break;
              case DeviceScreenType.tablet:
                crossAxisCount = 2;
                childAspectRatio = 1.1;
                break;
              case DeviceScreenType.mobile:
              default:
                crossAxisCount = 1;
                childAspectRatio = 1;
                break;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingL,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: AppTheme.paddingM,
                  mainAxisSpacing: AppTheme.paddingM,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return EventCard(event: events[index]);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
