class DateHelper {
  static int calcularUltimoDiaDelMes(DateTime fecha) {
    DateTime primerDiaMesSiguiente = (fecha.month < 12)
        ? DateTime(fecha.year, fecha.month + 1, 1)
        : DateTime(fecha.year + 1, 1, 1);

    DateTime ultimoDia = primerDiaMesSiguiente.subtract(Duration(days: 1));
    return ultimoDia.day;
  }

  static String formatearFecha(DateTime fecha) {
    final String monthNumberText = fecha.month < 10
        ? "0${fecha.month}"
        : "${fecha.month}";
    final String dayNumberText = fecha.day < 10
        ? "0${fecha.day}"
        : "${fecha.day}";
    return "$dayNumberText/$monthNumberText/${fecha.year}";
  }
}
