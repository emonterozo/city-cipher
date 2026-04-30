import '../../models/store/store_model.dart';

class TimeUtils {
  static String getStatus(List<OpeningHours> hours) {
    final now = DateTime.now();

    final weekdays = {
      1: "mon",
      2: "tue",
      3: "wed",
      4: "thu",
      5: "fri",
      6: "sat",
      7: "sun",
    };

    final todayKey = weekdays[now.weekday];

    final today = hours.where((h) => h.day == todayKey).toList();

    if (today.isEmpty) {
      return "Closed store";
    }

    final schedule = today.first;

    return "Open until ${formatTime(schedule.close)}";
  }

  static String formatTime(int minutes) {
    final hour = minutes ~/ 60;
    final min = minutes % 60;

    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;

    final minuteStr = min.toString().padLeft(2, '0');

    return "$hour12:$minuteStr $period";
  }
}
