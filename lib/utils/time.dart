/// format timestamp
String formatTimestamp({
  int? timestamp, // 为空则显示当前时间
  String? date, // 显示格式，比如：'YY年MM月DD日 hh:mm:ss'
  bool toInt = true, // 去除0开头
}) {
  if (timestamp == null) {
    timestamp = (new DateTime.now().millisecondsSinceEpoch / 1000).round();
  }
  String time_str =
      (DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)).toString();

  dynamic Date_arr = time_str.split(' ')[0];
  dynamic Time_arr = time_str.split(' ')[1];

  String YY = Date_arr.split('-')[0];
  String MM = Date_arr.split('-')[1];
  String DD = Date_arr.split('-')[2];

  String hh = Time_arr.split(':')[0];
  String mm = Time_arr.split(':')[1];
  String ss = Time_arr.split(':')[2];

  ss = ss.split('.')[0];

  // 去除0开头
  if (toInt) {
    MM = (int.parse(MM)).toString();
    DD = (int.parse(DD)).toString();
    hh = (int.parse(hh)).toString();
    mm = (int.parse(mm)).toString();
  }

  if (date == null) {
    return time_str;
  }

  date = date
      .replaceAll('YY', YY)
      .replaceAll('MM', MM)
      .replaceAll('DD', DD)
      .replaceAll('hh', hh)
      .replaceAll('mm', mm)
      .replaceAll('ss', ss);

  return date;
}

/// String formatDuration(int s) {
String formatDuration(int s) {
  final duration = Duration(seconds: s);
  String hours = duration.inHours.toString().padLeft(2, '0');
  String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

/// String formatDurationText(int s) {
String formatDurationText(int s) {
  final duration = Duration(seconds: s);
  String hours = duration.inHours.toString().padLeft(2, '');
  String minutes =
      (duration.inMinutes.remainder(60) + 1).toString().padLeft(2, '');
  return '${hours}h${minutes}min';
}
