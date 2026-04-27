import 'package:intl/intl.dart';

String formatDate(String date) {
  DateTime parsedDate = DateTime.parse(date).toLocal();
  return DateFormat('dd MMM yyyy').format(parsedDate);
}
