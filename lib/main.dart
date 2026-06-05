import 'package:flutter/material.dart';
import 'package:gowild_app/app.dart';
import 'package:gowild_app/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const GoWildApp());
}
