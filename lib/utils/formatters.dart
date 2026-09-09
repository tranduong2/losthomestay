import 'package:intl/intl.dart';

class Formatters {
  static final _currencyFmt = NumberFormat.decimalPattern('vi_VN');
  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _dateTimeFmt = DateFormat('HH:mm dd/MM/yyyy');

  static String currency(num value) => '${_currencyFmt.format(value)} đ';

  static String date(DateTime d) => _dateFmt.format(d);

  static String dateTime(DateTime d) => _dateTimeFmt.format(d);
}

