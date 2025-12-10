import 'package:flutter/material.dart';
import 'package:flutter_live_shopping/utils/app_enums.dart';

class HomeScreen extends StatefulWidget {
  final LiveEventStatus? filterStatus;
  const HomeScreen({super.key, this.filterStatus});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
