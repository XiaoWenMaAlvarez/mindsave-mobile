class DateHelper {
  static int calcularUltimoDiaDelMes(DateTime fecha) {
    final local = fecha.toLocal();
    return DateTime(local.year, local.month + 1, 0).day;
  }

  static String formatearFecha(DateTime fecha) {
    final local = fecha.toLocal();
    final String monthNumberText = local.month < 10
        ? "0${local.month}"
        : "${local.month}";
    final String dayNumberText = local.day < 10
        ? "0${local.day}"
        : "${local.day}";
    return "$dayNumberText/$monthNumberText/${local.year}";
  }
}
