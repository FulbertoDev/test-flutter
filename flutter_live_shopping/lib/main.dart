import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

void main() {
  usePathUrlStrategy();
  initializeDateFormatting("fr_FR");
  runApp(const MyApp());
}
