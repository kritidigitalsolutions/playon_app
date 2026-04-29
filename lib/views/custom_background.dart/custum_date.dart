import 'package:intl/intl.dart';

String formatDate(String? date) {
  if (date == null || date.isEmpty) return "";

  try {
    DateTime parsedDate = DateTime.parse(date).toLocal();
    return DateFormat('dd MMM yyyy').format(parsedDate);
  } catch (e) {
    return date;
  }
}
