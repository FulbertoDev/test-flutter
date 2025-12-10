import 'package:flutter/material.dart';

class LiveEventScreen extends StatefulWidget {
  final String eventId;
  const LiveEventScreen({super.key, required this.eventId});

  @override
  State<LiveEventScreen> createState() => _LiveEventScreenState();
}

class _LiveEventScreenState extends State<LiveEventScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
