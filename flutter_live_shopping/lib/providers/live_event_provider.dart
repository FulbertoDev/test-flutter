import 'package:flutter/foundation.dart';
import '../models/live_event.dart';
import '../services/mock_api_service.dart';
import '../services/mock_socket_service.dart';
import '../utils/app_enums.dart';

class LiveEventProvider extends ChangeNotifier {
  final MockApiService _apiService = MockApiService();
  final MockSocketService _socketService = MockSocketService();

  LiveEvent? _currentEvent;
  List<LiveEvent> _events = [];
  bool _isLoading = false;
  String? _error;

  LiveEvent? get currentEvent => _currentEvent;
  List<LiveEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<LiveEvent> get liveEvents =>
      _events.where((e) => e.status == LiveEventStatus.live).toList();
  List<LiveEvent> get scheduledEvents =>
      _events.where((e) => e.status == LiveEventStatus.scheduled).toList();
  List<LiveEvent> get endedEvents =>
      _events.where((e) => e.status == LiveEventStatus.ended).toList();

  LiveEventProvider() {
    _setupSocketListeners();
    loadEvents();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _apiService.getLiveEvents();
      _error = null;
    } catch (e) {
      if (e is TypeError) {
        _error =
            "Une erreur est survenue lors de la récupération des événements:${e.stackTrace}";
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinEvent(String eventId) async {
    try {
      _currentEvent = await _apiService.getLiveEventById(eventId);
      if (_currentEvent != null) {
        await _socketService.joinLiveEvent(eventId);

        final messages = await _apiService.getChatMessages(eventId);
        _socketService.loadChatHistory(messages);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void leaveEvent() {
    if (_currentEvent != null) {
      _socketService.leaveLiveEvent(_currentEvent!.id);
      _currentEvent = null;
      notifyListeners();
    }
  }

  void _setupSocketListeners() {
    _socketService.viewerCount.listen((count) {
      if (_currentEvent != null) {
        _currentEvent = _currentEvent!.copyWith(viewerCount: count);
        notifyListeners();
      }
    });

    _socketService.productFeatured.listen((productId) {
      if (_currentEvent != null) {
        final product = _currentEvent!.products.firstWhere(
          (p) => p.id == productId,
          orElse: () => _currentEvent!.products.first,
        );
        _currentEvent = _currentEvent!.copyWith(featuredProduct: product);
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    leaveEvent();
    super.dispose();
  }
}
