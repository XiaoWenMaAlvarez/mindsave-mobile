# AGENTS.md

## Alcance y fuente de verdad

Estas instrucciones se aplican a todo el repositorio. Si aparece un `AGENTS.md`
en un subdirectorio, el archivo más cercano al código modificado tiene prioridad
en ese ámbito.

- El producto se presenta como **Mind Save** o **Mindsave**, pero el paquete Dart
  aún se llama `prueba`. Conserva los imports `package:prueba/...` hasta que exista
  una migración explícita y completa del nombre.
- El código, `pubspec.yaml`, `analysis_options.yaml` y los tests son la fuente de
  verdad. `README.md` todavía es el placeholder de Flutter y no describe el
  producto.
- Preserva los cambios ajenos del worktree. Limita el diff al objetivo solicitado
  y revísalo antes de entregar.
- No edites artefactos generados o efímeros: `.dart_tool/`, `build/`, `coverage/`,
  `.flutter-plugins-dependencies`, cachés ni salidas de compilación. Modifica
  Android/iOS solo cuando el requisito sea específicamente nativo.

## Resumen del proyecto

Mind Save es una aplicación móvil Flutter de bienestar emocional y Terapia
Cognitivo-Conductual (TCC/CBT). Están configurados Android e iOS; no hay carpetas
de plataforma para web o escritorio.

Stack comprobado:

- Dart `^3.12.2`; el proyecto fue creado en el canal estable de Flutter.
- Material 3, `google_fonts` y componentes visuales propios.
- Riverpod 3 con `Provider`, `Notifier` y `NotifierProvider`, sin codegen.
- `go_router` para navegación y guardias de autenticación.
- `dio` y `dio_cache_interceptor` para HTTP y caché GET en memoria.
- `shared_preferences` para token y preferencia de tema.
- `flutter_chat_ui`, `flutter_chat_core`, `flyer_chat_image_message` e
  `image_picker` para chat, imágenes y streaming de IA.
- `pdf`, `archive` y `file_saver` para exportar PDF/XLSX y guardar archivos.
- `fl_chart` para los gráficos del test breve.

`lib/main.dart` carga `.env`, monta `ProviderScope`, recupera el tema persistido y
crea `MaterialApp.router`. La configuración actual contiene una sola variable:

```env
API_URL_BASE=
```

`.env` está ignorado por Git pero se empaqueta como asset; no es un lugar seguro
para secretos de cliente. Mantén únicamente configuración pública, conserva
`.env.template` versionado y nunca confirmes tokens, contraseñas ni datos reales
de usuarios.

## Puesta en marcha y validación

Desde la raíz del repositorio:

```powershell
Copy-Item .env.template .env  # solo si .env no existe
flutter pub get
flutter run
```

Antes de entregar cambios Dart/Flutter, ejecuta:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Durante la iteración usa primero el test más cercano:

```powershell
flutter test test/nombre_del_test.dart
flutter test test/nombre_del_test.dart --plain-name "nombre exacto"
```

Si falla el formato, aplica `dart format lib test` y vuelve a validar. No uses
`flutter clean` rutinariamente; resérvalo para fallos confirmados de artefactos.
Modifica `pubspec.lock` solo cuando cambien dependencias o su resolución.

## Mapa de arquitectura

El código se organiza por funcionalidad y, en los módulos principales, por capas
`domain`, `infrastructure` y `presentation`:

- `lib/config/`: entorno, tema, menú, fechas y router.
- `lib/auth/`: login, registro, recuperación, token y estado de sesión.
- `lib/home/`: inicio, catálogo de módulos, menú lateral y tema persistente.
- `lib/registro_estado_animo/`: registro CBT de seis pasos, pendientes,
  completados y exportación individual.
- `lib/test_breve_estado_animo/`: cuestionario diario, resultados diarios y
  anuales, gráficos y exportación anual.
- `lib/externalizacion_de_voces/`: creación/listado de chats, historial, imágenes
  y respuestas de IA en streaming.
- `lib/shared/`: cliente HTTP autenticado, guardado de archivos y UI reutilizable.
- `test/`: tests unitarios, de providers, HTTP/caché, exportadores y widgets.

Flujo esperado de dependencias:

```text
presentation -> domain abstractions <- infrastructure implementations
       |                                      |
       +---------- Riverpod providers --------+
```

La separación es práctica, no Clean Architecture estricta. Las abstracciones del
chat exponen `XFile` y varios formularios CBT editan entidades mutables. No
extiendas estas excepciones ni emprendas una refactorización transversal salvo
que el requisito la necesite.

Los `local_datasource.dart` de registro CBT y test breve son implementaciones
alternativas conservadas. Los providers activos conectan los datasources de API;
no asumas soporte offline ni cambies la implementación activa accidentalmente.

## Contratos que deben preservarse

### Autenticación y navegación

- `AuthNotifier` persiste el token en `SharedPreferences` con la clave `token`.
- El arranque comienza en `/splash`. `GoRouterNotifier` escucha `authProvider` y
  redirige según `checking`, `authenticated` o `notAuthenticated`.
- Las rutas públicas son `/login`, `/register`, `/forgot-password` y
  `/successful-register`; un usuario autenticado que entra en ellas va a `/home`.
- Las rutas se centralizan en `lib/config/router/app_router.dart`. Si cambias una
  pantalla o ruta, revisa menú, navegación inferior, parámetros `idRegistro` o
  `idChat` y tests relacionados.
- Autenticación usa un `Dio` propio porque ocurre antes de disponer de sesión. Las
  funcionalidades autenticadas deben obtener el cliente mediante
  `authenticatedHttpClientProvider`, nunca construirlo dentro de widgets.
- La preferencia de tema usa la clave `isDarkMode`; cambiar claves persistidas
  requiere una migración compatible.

### HTTP, sesión y caché

`AuthenticatedHttpClient` agrega el bearer token, crea un `MemCacheStore` por
instancia y separa claves por `sessionId`. Normaliza la URI ordenando parámetros,
considera fresco un GET durante cinco minutos y permite usar una respuesta
vencida cuando falla la red.

Al tocar red:

- Usa rutas relativas a `API_URL_BASE` y conserva los contratos JSON existentes.
- Toda mutación que afecte lecturas cacheadas debe esperar la invalidación de la
  familia GET correspondiente.
- Mantén la invalidación selectiva mediante `RegExp`; evita limpiar todo el caché
  cuando basta con una familia de endpoints.
- Mantén métodos distintos de GET y `ResponseType.stream` fuera del caché.
- El datasource de chat convierte chunks UTF-8 en una respuesta acumulada; el
  provider reemplaza el mismo mensaje provisional mientras llega el stream.
- Cancela suscripciones antes de sustituirlas y libera clientes, timers y
  controladores con `ref.onDispose`.
- Conserva errores visibles en español y no conviertas silenciosamente un fallo de
  red en éxito.

### Estado con Riverpod

- Sigue el patrón actual: abstracción de repositorio inyectable, provider de la
  implementación y `Notifier` para estado/acciones.
- Usa `ref.watch` para dependencias reactivas y `ref.read` para acciones puntuales.
- Publica listas nuevas y estados con `copyWith` cuando la UI deba reaccionar.
- Los estados anulables de autenticación y chat usan un sentinel para distinguir
  "sin cambio" de `null` explícito; conserva esa semántica.
- Las cargas iniciales iniciadas en `build()` usan `unawaited` y microtasks. Evita
  futuros huérfanos y actualizaciones después de `dispose`.
- No mezcles `isInitialLoading`, `isLoading`, estado de streaming y error cuando
  la UI les da tratamientos diferentes.
- En tests, reemplaza repositorios/servicios con overrides de `ProviderContainer`
  o `ProviderScope`; no accedas a red ni almacenamiento reales.

### Reglas de negocio y datos sensibles

- El registro CBT visible tiene seis pasos. La creación agrupa los pasos 1-3 y
  los pasos 4-6 continúan en rutas que reciben `idRegistro`.
- No uniformes los rangos sin revisar el flujo: las intensidades emocionales usan
  `0..100`, pero un grupo seleccionado debe quedar sobre `0`; la creencia negativa
  posterior admite `0..100`, mientras que la creencia negativa inicial y la
  positiva deben quedar en `1..100`. `null` significa que un paso sigue pendiente
  y no equivale a una respuesta `0`.
- El test breve puntúa cada reactivo de `0` a `4`. Máximos: 20 para ansiedad
  emocional, 40 para ansiedad física, 20 para depresión y 8 para impulso suicida.
- No cambies preguntas, etiquetas, umbrales, interpretaciones, recomendaciones ni
  lógica de riesgo suicida sin un requisito explícito y tests de todos los límites.
- Registros CBT, notas, tests y conversaciones son datos de salud sensibles. No
  registres payloads, identidad, tokens o contraseñas ni agregues telemetría de
  contenido. Existe un `logJson` heredado en el datasource CBT de API; no lo copies
  ni amplíes y evita introducir nuevas impresiones del registro completo.

### UI, tema y accesibilidad

- Conserva Material 3 y usa `Theme.of(context)`/`AppTheme` antes de hardcodear
  colores o tipografías.
- Reutiliza primero `lib/shared/presentation/widgets/mindsave_ui.dart`, en
  particular loading, tarjetas, introducciones, módulos, navegación y progreso.
- El texto visible está en español. Mantén acentos, tono empático y terminología
  del módulo.
- Mantén `SafeArea`, scroll en formularios, objetivos táctiles cercanos a 48 dp y
  `Semantics` para controles/indicadores no autoexplicativos.
- Después de un `await`, verifica `mounted` o `context.mounted` antes de usar un
  contexto que pueda haberse desmontado.
- Los widget tests usan una ventana tipo Pixel 9 (`1080x2424`, DPR `2.625`).
  Restaura `tester.view` en teardown y comprueba que no haya overflows.

### Modelos, mappers y exportación

- Conserva nombres y tipos exactos de las claves JSON. Si cambia un contrato,
  actualiza entidad/response model, mapper, datasource, fake y tests en conjunto.
- `test_breve_estado_animo` traduce response models mediante un mapper explícito;
  no lleves DTOs de infraestructura a widgets.
- Las entidades CBT son mutables y usan `toJson`/`fromJson`. Preserva `null`,
  fechas ISO, listas anidadas y la clave `pensamientos`.
- Los XLSX son paquetes OOXML ZIP construidos con `archive`, no CSV renombrados.
  Los PDF se construyen con `pdf` y se guardan mediante `MindsaveFileSaver`.
- Cambios de exportación deben preservar extensión, MIME, nombre, estructura
  válida del PDF/ZIP y todos los datos clínicos esperados.

## Convenciones de código

- Usa `snake_case.dart`, `UpperCamelCase` para tipos y `lowerCamelCase` para
  miembros.
- Prefiere imports `package:prueba/...` entre módulos. Al exponer APIs de un
  módulo, actualiza sus barrel files (`screens.dart`, `providers.dart`,
  `widgets.dart`, `entities.dart`) si corresponde.
- Sigue `flutter_lints`; resuelve advertencias localmente y no desactives reglas
  globales por conveniencia.
- En código nuevo usa comillas simples y deja el layout a `dart format`.
- Añade `const` cuando sea semánticamente correcto, sin alterar identidad ni ciclo
  de vida de widgets/controladores solo por estilo.
- No agregues dependencias para utilidades pequeñas disponibles en el SDK o en los
  paquetes existentes.
- No renombres incidentalmente rutas, claves persistidas, endpoints, campos JSON
  ni textos clínicos.

## Estrategia de tests

Tests existentes por área:

- Autenticación, providers y chat: `migration_providers_test.dart` y
  `auth_screens_test.dart`.
- Sesión, caché e invalidación: `authenticated_http_client_test.dart`.
- Flujo, layouts y rangos CBT: `cbt_flow_ui_test.dart`.
- Exportación CBT: `cbt_record_exporter_test.dart`.
- Test breve y exportación anual: `test_breve_year_details_screen_test.dart`.
- UI compartida: `mindsave_loading_view_test.dart`,
  `mindsave_bottom_navigation_test.dart` y `test_breve_completed_card_test.dart`.

Para corregir un bug, añade una prueba que reproduzca la causa. Cubre éxito,
error y loading al cambiar providers; límites al cambiar lógica clínica;
invalidación al cambiar mutaciones; validez PDF/ZIP al cambiar exportadores; y
renderizado sin overflow al cambiar UI.

## Checklist de entrega

1. Revisa `git status --short` y confirma el alcance real del diff.
2. Actualiza todas las capas, rutas y barrel files afectados por el contrato.
3. Añade o ajusta el test de regresión más cercano.
4. Ejecuta formato, análisis, test focalizado y finalmente la suite completa.
5. Busca secretos, datos sensibles, logs accidentales, cambios de contrato y
   archivos generados en el diff.
6. Informa exactamente qué validaciones se ejecutaron y cuáles no pudieron
   completarse.

## Limitaciones conocidas

- `README.md`, el nombre nativo, `applicationId`/namespace Android y la firma
  release conservan valores de plantilla (`prueba`, `Prueba`,
  `com.example.prueba` o clave debug).
- No hay CI visible, pruebas de integración ni umbral automatizado de cobertura.
- Los datasources locales no forman parte del grafo activo de providers.
- La configuración nativa de release no está lista para producción hasta definir
  identificadores, firma y configuración por entorno.

No corrijas estas limitaciones de forma incidental: trátalas como tareas separadas
con alcance y validación propios.
