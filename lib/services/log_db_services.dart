import 'package:logger/logger.dart';

import 'http_servikes.dart';

class Log {

  static Logger _logger = Logger(
    printer: PrettyPrinter(),
  );

  static void d (String message) {
    if ( HttpServices.isTester ) _logger.d(message);
  }

  static void i (String message) {
    if (HttpServices.isTester) _logger.i(message);
  }

  static void w (String message) {
    if (HttpServices.isTester) _logger.w(message);
  }

  static void e (String message) {
    if (HttpServices.isTester) _logger.e(message);
  }

}