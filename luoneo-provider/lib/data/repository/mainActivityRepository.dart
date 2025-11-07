import 'package:shared_preferences/shared_preferences.dart';

class MainActivityRepository {
  static const String key = 'grid_items';

  // Save grid item IDs to SharedPreferences
  static Future<void> savePositions(
    List<({String name, String icon})> items,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      items.map((item) => '${item.name}*${item.icon}').toList(),
    );
  }

  // Load grid item IDs from SharedPreferences
  static Future<List<({String name, String icon})>> loadPositions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> items = prefs.getStringList(key) ?? <String>[];

    return items.map((i) {
      final parts = i.split('*');
      return (name: parts.first, icon: parts.last);
    }).toList();
  }
}
