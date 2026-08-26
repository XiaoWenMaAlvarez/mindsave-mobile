import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String apiUrlBase = dotenv.env['API_URL_BASE'] ?? "";
}
