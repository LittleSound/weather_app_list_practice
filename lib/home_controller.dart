import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ScrollController scrollController = ScrollController();

  final listViewTop = 0.0.obs;
  final listViewBottom = 0.0.obs;
  final listOffset = 0.0.obs;
}
