# MindSave: especificación funcional y técnica derivada del código

## 1. Propósito y alcance de este documento

Este documento describe **qué funcionalidades provee actualmente la aplicación MindSave y cómo están implementadas en el repositorio**. Su contenido fue reconstruido a partir del código fuente, las rutas, las entidades de dominio, los providers, las fuentes de datos, los contratos HTTP y las pruebas automatizadas existentes.

El objetivo es que el documento sirva como fuente para:

- redactar casos de uso extendidos;
- identificar actores, precondiciones, flujos principales, alternativos y excepciones;
- construir diagramas UML de casos de uso, clases, secuencia, actividad, componentes y despliegue;
- preparar una descripción de arquitectura;
- separar el comportamiento implementado de las intenciones no terminadas o de los componentes alternativos que no están conectados al flujo de ejecución.

La descripción corresponde al estado observado del repositorio el **25 de agosto de 2026**. No se ha supuesto comportamiento del backend más allá de los contratos que consume el cliente Flutter.

### 1.1 Convenciones de lectura

- **Implementado y conectado**: el código forma parte del grafo de dependencias y es alcanzable desde las rutas de la aplicación.
- **Implementado pero no conectado**: existe código funcional, pero el provider activo utiliza otra implementación.
- **Parcial o simulado**: la interfaz existe, pero no persiste datos o no ejecuta la operación que su etiqueta sugiere.
- **Backend**: servicio HTTP externo configurado mediante `API_URL_BASE`; el backend no forma parte de este repositorio.

## 2. Identificación del producto

| Elemento | Valor observado |
|---|---|
| Producto mostrado al usuario | MindSave / Mind Save |
| Tipo de aplicación | Aplicación móvil Flutter |
| Plataformas presentes | Android e iOS |
| Paquete del proyecto | `mindsave` |
| Versión declarada | `0.1.0+1` |
| SDK Dart requerido | `^3.12.2` |
| Canal Flutter registrado | `stable` |
| Backend | API REST externa definida por `API_URL_BASE` |
| Persistencia principal de información clínica/funcional | Backend remoto autenticado |
| Persistencia local activa | Token de sesión y preferencia de modo oscuro en `SharedPreferences` |
| Administración de estado | Riverpod con `Provider` y `NotifierProvider` |
| Navegación | `go_router` con redirección basada en autenticación |

La aplicación está orientada al autocuidado y seguimiento de salud mental. Implementa dos herramientas estructuradas —un test breve diario y un registro cognitivo-conductual— y una herramienta conversacional asistida por IA.

## 3. Límite del sistema y actores

### 3.1 Actores humanos

| Actor | Capacidades |
|---|---|
| Visitante no autenticado | Iniciar sesión, crear una cuenta, reenviar el correo de activación, solicitar restablecimiento de contraseña y consultar la confirmación de registro. |
| Usuario autenticado | Acceder al inicio, cambiar el tema, cerrar sesión, realizar y consultar tests diarios, crear y completar registros CBT, exportar resultados, crear y usar chats asistidos por IA y adjuntar imágenes. |

No existe un rol administrativo, profesional clínico o cuidador en el cliente. Tampoco hay funcionalidad para compartir directamente resultados con otra cuenta.

### 3.2 Sistemas y dispositivos colaboradores

| Actor/sistema externo | Interacción |
|---|---|
| API REST de MindSave | Autenticación, CRUD de tests, CRUD de registros CBT y CRUD/streaming de chats. |
| Servicio de IA del backend | La interfaz lo denomina internamente Gemini; el cliente no se conecta directamente al proveedor de IA, sino al endpoint de chat de MindSave. |
| Almacenamiento de preferencias del sistema | Conserva token y modo oscuro mediante `SharedPreferences`. |
| Selector/galería de imágenes | Permite seleccionar hasta cuatro imágenes para un mensaje de chat. |
| Selector de guardado de archivos | Permite guardar exportaciones PDF y XLSX. |

## 4. Inventario de funcionalidades

| Área | Funcionalidad | Estado real |
|---|---|---|
| Autenticación | Inicio de sesión | Implementado y conectado |
| Autenticación | Registro de usuario y activación por correo | Registro implementado; la activación ocurre fuera de la app |
| Autenticación | Reenvío del correo de activación | Implementado desde la confirmación de registro |
| Autenticación | Restablecimiento de contraseña | Solicitud implementada; el cambio final ocurre fuera de la app |
| Autenticación | Recuperación automática de sesión | Implementado mediante token local y validación remota |
| Autenticación | Cierre de sesión | Implementado; puede iniciarse manualmente o automáticamente ante HTTP 401 y elimina el token local |
| Inicio | Saludo personalizado, fecha y accesos rápidos | Implementado |
| Inicio | Selector rápido “¿Cómo te sientes hoy?” | Solo interfaz local; no se persiste ni se envía al backend |
| Preferencias | Modo oscuro | Implementado y persistido localmente |
| Test breve | Crear una evaluación diaria de 22 ítems | Implementado |
| Test breve | Mostrar resultados y niveles por dimensión | Implementado |
| Test breve | Editar o eliminar la evaluación del día | Implementado |
| Test breve | Seguimiento anual mediante gráficos | Implementado |
| Test breve | Detalle por mes y día | Implementado |
| Test breve | Exportar un año a PDF o Excel | Implementado |
| Registro CBT | Crear registro en seis pasos | Implementado |
| Registro CBT | Guardar proceso pendiente y reanudarlo | Implementado |
| Registro CBT | Consultar registros pendientes/completados | Implementado con paginación |
| Registro CBT | Editar y eliminar registros | Implementado |
| Registro CBT | Ver cambio emocional y reestructuración | Implementado |
| Registro CBT | Exportar un registro a PDF o Excel | Implementado |
| Externalización | Crear, listar y eliminar chats | Implementado |
| Externalización | Enviar texto y recibir respuesta por streaming | Implementado |
| Externalización | Adjuntar imágenes | Implementado, hasta cuatro por selección |

## 5. Arquitectura de ejecución

### 5.1 Organización modular

El código se divide por capacidad funcional:

```text
lib/
├── auth/                         autenticación y sesión
├── config/                       entorno, rutas, menú, tema y utilidades
├── home/                         inicio, módulos, navegación y almacenamiento simple
├── registro_estado_animo/        registro CBT de seis pasos
├── test_breve_estado_animo/      evaluación diaria, resultados y seguimiento
├── externalizacion_de_voces/     chat asistido por IA
└── shared/                       cliente HTTP, guardado de archivos y widgets comunes
```

Los tres módulos de negocio principales usan una separación inspirada en arquitectura limpia:

```text
Presentación (pantallas, widgets, providers)
                ↓
Dominio (entidades, contratos de repositorio y datasource)
                ↓
Infraestructura (repositorio concreto, datasource HTTP, DTO/mappers)
                ↓
API REST de MindSave
```

El repositorio concreto actúa principalmente como delegador. La lógica de coordinación se concentra en los `Notifier` de Riverpod; las reglas de puntaje y de completitud se ubican en entidades de dominio.

### 5.2 Arranque de la aplicación

El flujo de `lib/main.dart` es:

1. Inicializar bindings de Flutter.
2. Cargar `.env` mediante `flutter_dotenv`.
3. Crear un `ProviderScope`, raíz del estado Riverpod.
4. Construir `MainApp`.
5. Después del primer frame, cargar desde `SharedPreferences` el valor `isDarkMode`.
6. Construir `MaterialApp.router` con el tema activo y el `GoRouter` observado.

Si `API_URL_BASE` no existe en `.env`, `Environment.apiUrlBase` queda como cadena vacía. No hay validación temprana de esta configuración.

### 5.3 Administración de estado con Riverpod

La UI usa `ref.watch` para reconstruirse cuando cambia un provider y `ref.read(...notifier)` para ejecutar operaciones. Los estados principales son:

| Provider | Estado | Responsabilidad |
|---|---|---|
| `authProvider` | `AuthState` | Sesión, usuario, estado de autenticación y mensaje de error. |
| `goRouterNotifierProvider` | `GoRouterNotifier` | Convierte cambios de autenticación en notificaciones para el router. |
| `authenticatedHttpClientProvider` | `AuthenticatedHttpClient` | Cliente Dio autenticado, caché por sesión y cierre automático de sesión ante HTTP 401. |
| `themeProvider` | `AppTheme` | Tema claro/oscuro y persistencia de la preferencia. |
| `selectedMenuItemProvider` | `int` | Índice seleccionado del menú lateral. |
| `registroEstadoDeAnimoProvider` | `RegistroEstadoAnimoState` | Listado paginado, carga, CRUD y acceso por id de registros CBT. |
| `nuevoRegistroEstadoDeAnimoProvider` | `RegistroEstadoAnimo` | Borrador mutable de un nuevo registro CBT. |
| `testBreveEstadoDeAnimoProvider` | `List<TestBreveEstadoDeAnimo>` | Tests cargados por año y operaciones de guardado/edición/eliminación. |
| `todayTestBreveEstadoDeAnimoProvider` | `TestBreveEstadoDeAnimo?` | Evaluación identificada como la del día actual. |
| `selectedYearProvider` | `int` | Año usado por seguimiento y detalle anual. |
| `isLoadingProvider` | `bool` | Indicador compartido de carga del módulo de test breve. |
| `chatListProvider` | `ChatsListState` | Lista, creación y eliminación de chats. |
| `chatProvider` | `ChatState` | Mensajes del chat activo, carga, streaming y errores. |
| `chatControllerProvider` | `InMemoryChatController` | Sincroniza `ChatState.messages` con `flutter_chat_ui`. |

Las entidades del registro CBT son mutables. Varios widgets modifican directamente sus campos y usan `setState` local para refrescar la interfaz; no se emite un nuevo objeto Riverpod por cada edición de campo. La persistencia remota ocurre al avanzar o guardar.

### 5.4 Navegación y control de acceso

El router inicia en `/splash`. `GoRouterNotifier` escucha `authProvider` y fuerza la reevaluación de `redirect` cuando cambia `AuthStatus`.

Reglas de redirección:

- Mientras el estado es `checking`, `/splash` permanece visible.
- Un usuario `notAuthenticated` puede acceder únicamente a `/login`, `/register`, `/forgot-password` y `/successful-register`; cualquier otra ruta redirige a `/login`.
- Un usuario `authenticated` que intenta ir a `/splash` o a una ruta pública es redirigido a `/home`.
- Las demás rutas autenticadas continúan sin redirección.

#### Catálogo de rutas

| Ruta | Pantalla | Propósito |
|---|---|---|
| `/splash` | `CheckAuthStatusScreen` | Validar sesión o permitir reintento ante error de conexión. |
| `/login` | `LoginScreen` | Inicio de sesión. |
| `/register` | `RegisterScreen` | Creación de cuenta. |
| `/successful-register` | `SuccessfulRegisterScreen` | Informar activación pendiente y permitir reenviar el correo al email registrado. |
| `/forgot-password` | `ForgotPasswordScreen` | Solicitar recuperación de contraseña. |
| `/home` | `HomeScreen` | Inicio personalizado y accesos rápidos. |
| `/registros` | `RegistrosScreen` | Registros CBT pendientes y completados. |
| `/modules` | `ModulesScreen` | Catálogo de herramientas. |
| `/testBreveEstadoAnimo/0` | `TestBreveEstadoAnimoCreateScreen` | Crear, editar o eliminar el test de hoy. |
| `/testBreveEstadoAnimo/1` | `TestBreveEstadoAnimoDailyResultsScreen` | Resultados del día. |
| `/testBreveEstadoAnimo/2` | `TestBreveEstadoAnimoYearResultsScreen` | Gráficos del año seleccionado. |
| `/testBreveEstadoAnimo/3` | `TestBreveEstadoAnimoDetailsYearResultsScreen` | Detalle anual y exportación. |
| `/registroEstadoAnimo/0` | `RegistroEstadoAnimoCreateScreen` | Pasos 1–3 de un nuevo registro. |
| `/registroEstadoAnimo/1` | `RegistroEstadoAnimoPendingViewScreen` | Listado con pestaña Pendientes. |
| `/registroEstadoAnimo/2` | `RegistroEstadoAnimoCompleteViewScreen` | Listado con pestaña Completados. |
| `/registroEstadoAnimo/3/:idRegistro` | `RegistroEstadoAnimoPendingViewStep4Screen` | Paso 4: distorsiones. |
| `/registroEstadoAnimo/4/:idRegistro` | `RegistroEstadoAnimoPendingViewStep5Screen` | Paso 5: reestructuración. |
| `/registroEstadoAnimo/5/:idRegistro` | `RegistroEstadoAnimoPendingViewStep6Screen` | Paso 6: revisión emocional. |
| `/registroEstadoAnimo/6/:idRegistro` | `RegistroEstadoAnimoPendingViewStep1To3Screen` | Editar pasos 1–3. |
| `/registroEstadoAnimo/7/:idRegistro` | `RegistroEstadoAnimoCompleteViewDetailsScreen` | Detalle, exportación, edición y eliminación. |
| `/externalizacionVoces/0` | `ExternalizacionVocesInitialScreen` | Listado y creación de chats. |
| `/externalizacionVoces/chat/:idChat` | `ExternalizacionVocesChatScreen` | Conversación seleccionada. |

La navegación usa mayoritariamente `context.push`, por lo que agrega destinos a la pila en vez de reemplazar sistemáticamente la ubicación actual.

### 5.5 Cliente HTTP autenticado y caché

Autenticación usa una instancia Dio propia. El resto de los módulos comparte conceptualmente `AuthenticatedHttpClient`, creado con:

- `baseUrl = API_URL_BASE`;
- encabezado `Authorization: Bearer <token>` cuando hay token;
- identificador de sesión igual al id del usuario;
- callback de sesión no autorizada conectado a `AuthNotifier.logout`;
- caché en memoria mediante `dio_cache_interceptor`.

Reglas de caché:

1. Solo se consideran solicitudes GET no streaming.
2. La clave contiene id de sesión, método GET y URI normalizada.
3. Los parámetros de consulta y sus valores se ordenan antes de construir la clave.
4. Un resultado con menos de cinco minutos se devuelve sin acceder a la red.
5. Al vencer, se intenta refrescar desde la red.
6. Si la red falla, el interceptor puede devolver la respuesta vencida.
7. POST, PUT y DELETE no se almacenan.
8. Cada mutación invalida las familias de lecturas relacionadas.
9. Un cambio de usuario, token o cierre de sesión recrea el cliente y separa la caché entre sesiones.

Antes de los interceptores de caché se instala un interceptor de sesión. Si cualquier solicitud realizada mediante `AuthenticatedHttpClient` recibe HTTP 401, el interceptor invoca el callback `onUnauthorized`. El provider conecta ese callback con `AuthNotifier.logout("Tu sesión expiró. Inicia sesión nuevamente.")`: se elimina `token`, el estado cambia a `notAuthenticated`, el router redirige al login y se cierra/recrea el cliente de la sesión anterior. Respuestas 401 concurrentes comparten la misma notificación mientras el cierre está en curso, y el `DioException` original continúa hacia el flujo que realizó la solicitud. No existe renovación automática del token; el comportamiento implementado es terminar la sesión expirada.

La caché es solo de memoria: no constituye almacenamiento offline persistente.

## 6. Funcionalidades de autenticación

### 6.1 Recuperación automática de sesión

**Disparador:** construcción de `authProvider` al iniciar la aplicación.

**Flujo implementado:**

1. `AuthNotifier.build` devuelve `AuthState(checking)` y programa `checkAuthStatus` en una microtarea.
2. Se lee `token` desde `SharedPreferences`.
3. Si no existe, se ejecuta `logout`, se elimina cualquier token residual y el estado pasa a `notAuthenticated`.
4. Si existe, se invoca `GET /api/auth/check-status` con Bearer token.
5. Una respuesta válida se transforma en `User`, vuelve a guardar el token retornado y marca el estado `authenticated`.
6. Un error interpretado como credencial inválida elimina el token y lleva al login.
7. Cualquier otro error mantiene el estado `checking` y registra el mensaje “Error al intentar conectarse a los servidores de Mindsave”.
8. `CheckAuthStatusScreen` convierte ese último estado en una vista “Sin conexión” con botón de reintento.

**Resultado:** el router envía al usuario a `/home`, `/login` o mantiene la pantalla de recuperación de conexión.

### 6.2 Inicio de sesión

**Entradas:** correo y contraseña.

**Validación local:**

- ambos campos son obligatorios;
- correo con expresión regular de formato básico;
- contraseña de al menos seis caracteres.

**Procesamiento:**

1. La UI deshabilita el botón y muestra un indicador de carga.
2. Se envía `POST /api/auth/login` con `{email, password}`.
3. La respuesta se interpreta como `{id, email, name, token}`; `password` es opcional y normalmente queda vacío.
4. El token se guarda en `SharedPreferences`.
5. Se actualiza `AuthState` con usuario y estado autenticado.
6. El router redirige automáticamente a `/home`.

**Excepciones tratadas:**

| Condición | Mensaje presentado |
|---|---|
| HTTP 400 | Credenciales incorrectas |
| HTTP 401 | Cuenta aún no activada; se solicita revisar el correo |
| `connectionTimeout` | Conexión perdida |
| Otro error | Error al iniciar sesión |

### 6.3 Creación de cuenta

**Entradas:** correo, nombre completo, contraseña y repetición de contraseña.

**Validación local:** correo válido, nombre mínimo de dos caracteres, contraseña mínima de seis caracteres y coincidencia de contraseñas.

**Procesamiento:** `POST /api/auth/register` con `{email, password, name}`. HTTP 201 representa éxito y conduce a `/successful-register`, transportando el correo registrado mediante `GoRouterState.extra`. HTTP 400 puede devolver `response.data["error"]`, que se muestra al usuario.

La pantalla de éxito conserva el correo recibido desde el registro y lo presenta como destino del mensaje de activación. Al pulsar “Reenviar”, deshabilita temporalmente el botón, invoca `AuthNotifier.resendValidationEmail` y envía `POST /api/auth/resend-validation-email` con `{email}`. Una respuesta exitosa muestra “Correo de activación reenviado.”; un fallo presenta el error devuelto por el backend cuando contiene `error`, “Conexión perdida” ante timeout o un mensaje genérico en los demás casos. Si la ruta se abre directamente sin un correo en `extra`, el reenvío no se ejecuta y se informa que no fue posible identificar la cuenta.

### 6.4 Restablecimiento de contraseña

**Entrada:** correo con la misma validación del login.

**Procesamiento:** `POST /api/auth/reset-password` con `{email}`. HTTP 200 muestra confirmación de que se enviaron instrucciones. HTTP 404 muestra el error devuelto por el backend. La aplicación no incluye una pantalla para definir la nueva contraseña; el flujo continúa externamente.

### 6.5 Cierre de sesión

Puede iniciarse manualmente desde el menú lateral o automáticamente cuando el cliente HTTP autenticado recibe una respuesta 401. En ambos casos, el notifier elimina `token`, borra el usuario del estado y cambia a `notAuthenticated`. El router redirige al login y el provider del cliente autenticado se recrea/cierra, aislando la caché de la sesión terminada. En el cierre automático se conserva como mensaje visible: “Tu sesión expiró. Inicia sesión nuevamente.”

## 7. Inicio, módulos, navegación y preferencias

### 7.1 Pantalla de inicio

`HomeScreen` muestra:

- fecha larga en español calculada localmente;
- saludo “Buenos días” más el primer nombre del usuario autenticado;
- selector visual de cinco estados: Muy mal, Mal, Regular, Bien y Muy bien;
- cantidad de registros CBT pendientes actualmente cargados en memoria;
- accesos a seguimiento anual, nuevo test y resultados del día.

El selector rápido de ánimo inicia en “Bien” (`_selectedMood = 3`). Al tocar otra opción solo cambia estado local del widget y muestra “Estado de ánimo registrado”. **No se llama a un provider, repositorio, almacenamiento local ni endpoint**, por lo que el dato desaparece al reconstruir la pantalla.

La cantidad de registros pendientes se obtiene del conjunto paginado ya cargado, no de un total independiente retornado por el backend.

### 7.2 Catálogo de módulos

`ModulesScreen` ofrece tarjetas para:

- Test breve de ánimo;
- Registro de pensamientos CBT;
- Externalización de voces;
- Seguimiento y gráficos.

Los chips “Todos”, “Evaluación”, “Reflexión” y “Apoyo” son visuales; no filtran las tarjetas.

### 7.3 Navegación persistente

La barra inferior común contiene cuatro destinos:

1. Inicio → `/home`;
2. Registros → `/registros`;
3. Seguimiento → `/testBreveEstadoAnimo/2`;
4. Test → `/testBreveEstadoAnimo/0`.

En el centro incorpora una acción flotante para crear un registro CBT en `/registroEstadoAnimo/0`.

El menú lateral agrega acceso a Inicio, Test breve, Registro CBT y Externalización de voces. También presenta nombre/correo del usuario, cambio de modo oscuro y cierre de sesión. El índice seleccionado del drawer se conserva solo en memoria y se modifica al usar el propio drawer; no se deriva automáticamente de la ruta actual.

### 7.4 Tema y diseño

La aplicación usa Material 3, paleta principal turquesa, tipografía Inter para texto general y Lora para títulos. `AppTheme` define variantes clara y oscura. La preferencia se guarda bajo `isDarkMode` en `SharedPreferences`.

Los componentes compartidos incluyen vistas de carga accesibles, tarjetas, encabezados, navegación y estados vacíos. Varias pantallas restringen el ancho a 720–820 px y usan contenido desplazable para adaptarse a móviles.

## 8. Test breve de estado de ánimo

### 8.1 Objetivo funcional

Permite registrar una evaluación por día, calcular cuatro dimensiones, mostrar interpretaciones, consultar evolución anual y exportar resultados.

### 8.2 Modelo de una evaluación

`TestBreveEstadoDeAnimo` contiene:

| Campo | Tipo | Descripción |
|---|---|---|
| `fechaCreacion` | `DateTime` | Fecha y hora de la evaluación. |
| `sentimientosAnsiedadEmocionalTestBreve` | Entidad | Cinco respuestas de ansiedad emocional. |
| `sentimientosAnsiedadFisicaTestBreve` | Entidad | Diez respuestas de síntomas físicos. |
| `depresionTestBreve` | Entidad | Cinco respuestas sobre ánimo/depresión. |
| `impulsoSuicidaTestBreve` | Entidad | Dos respuestas de seguridad personal. |
| `notas` | `String?` | Texto opcional. |

Cada ítem acepta valores enteros de 0 a 4:

| Valor | Etiqueta |
|---:|---|
| 0 | Nada en absoluto |
| 1 | Algo |
| 2 | Moderadamente |
| 3 | Mucho |
| 4 | Muchísimo |

Todas las respuestas se inicializan en 0. Por ello, es posible guardar una evaluación sin tocar explícitamente ningún selector; el sistema la interpreta como “Nada en absoluto” en todos los ítems.

### 8.3 Ítems evaluados

#### Ansiedad emocional, 0–20

1. Angustiado.
2. Nervioso.
3. Preocupado.
4. Asustado o aprensivo.
5. Tenso o con los nervios de punta.

#### Ansiedad física, 0–40

1. Palpitaciones, pulso acelerado o taquicardia.
2. Sudores, escalofríos o sofocos.
3. Temblores o estremecimientos.
4. Falta de aliento o dificultades para respirar.
5. Sensación de ahogo.
6. Dolor o tensión en el pecho.
7. Estómago revuelto o náuseas.
8. Sensación de mareo o de que todo da vueltas.
9. Sensación de irrealidad propia o del mundo.
10. Sensación de insensibilidad o de hormigueos.

#### Estado de ánimo/depresión, 0–20

1. Triste o decaído.
2. Desanimado o desesperanzado.
3. Autoestima baja.
4. Sensación de no valer o ser inadecuado.
5. Pérdida de placer o satisfacción con la vida.

#### Seguridad personal/impulso suicida, 0–8

1. ¿Tiene algún pensamiento de suicidarse?
2. ¿Quisiera poner fin a su vida?

### 8.4 Reglas de puntuación

La puntuación de cada dimensión es la suma directa de sus respuestas.

| Intervalo | Ansiedad emocional / depresión | Ansiedad física |
|---:|---|---|
| Mínimo | 0–1: pocos síntomas o ninguno | 0–2: pocos síntomas o ninguno |
| Marginal | 2–4 | 3–6 |
| Leve | 5–8 | 7–10 |
| Moderada | 9–12 | 11–20 |
| Grave/severa | 13–16 | 21–30 |
| Extrema | 17–20 | 31–40 |

Para seguridad personal se aplica precedencia:

1. Si `deseosDeMorir >= 1`, el resultado indica llamar a emergencias o acudir a un hospital.
2. En caso contrario, si `pensamientosSuicidas >= 1`, recomienda acudir a un profesional de salud.
3. Si ambas respuestas son 0, informa pocos síntomas o ninguno.

Las pantallas resaltan la tarjeta de seguridad cuando el total es mayor que cero. La aplicación muestra texto de orientación, pero no implementa llamada directa, geolocalización, selección de número por país ni contacto de emergencia.

### 8.5 Crear evaluación diaria

**Precondición:** usuario autenticado.

**Flujo:**

1. Al entrar, `todayTestBreveEstadoDeAnimoProvider` solicita `GET .../by-date/año/mes/día`.
2. Si no hay evaluación, se presentan los 22 selectores y notas opcionales.
3. El usuario puede cambiar cualquier respuesta entre 0 y 4.
4. Al guardar, la fecha se reemplaza por `DateTime.now()`.
5. Se envía `POST /api/test-breve-estado-de-animo/`.
6. Si el resultado es correcto, se actualiza el provider del test de hoy y se navega a resultados diarios.
7. Si falla, se muestra un mensaje genérico y el formulario permanece visible.

La restricción “una evaluación por día” se refleja en la consulta previa y en las operaciones específicas “de hoy”; la garantía definitiva de unicidad depende del backend.

### 8.6 Evaluación ya completada: consultar, editar y eliminar

Cuando existe una evaluación del día, la pantalla de creación cambia por una tarjeta resumen con:

- hora y puntuación total acumulada;
- barras de las cuatro dimensiones;
- acciones Ver resultados completos, Editar y Eliminar.

**Editar:** se clona la entidad mediante `toJson/fromJson`, se habilita el mismo formulario y se envía `PUT /api/test-breve-estado-de-animo/`.

**Eliminar:** solicita confirmación, limpia primero el estado local y luego ejecuta `DELETE /api/test-breve-estado-de-animo/año/mes/día` para la fecha actual.

### 8.7 Resultados del día

La pantalla muestra fecha, puntaje, barra relativa al máximo y descripción extensa para cada dimensión. Incluye notas si existen y un enlace al seguimiento anual. Se advierte que los valores son una guía y no un diagnóstico.

`TestBreveEstadoAnimoDailyResultsScreen` es un `ConsumerStatefulWidget`. Después de su primer frame invoca `setTestBreveRealizadoHoy` sobre `todayTestBreveEstadoDeAnimoProvider`, por lo que un acceso directo a `/testBreveEstadoAnimo/1` inicia autónomamente `GET /api/test-breve-estado-de-animo/by-date/:year/:month/:day`. Mientras se resuelve la operación muestra el indicador de carga compartido; luego presenta el resultado devuelto o la vista “Aún no hay resultados de hoy”. El notifier evita una nueva consulta cuando ya contiene una evaluación en memoria.

### 8.8 Seguimiento anual gráfico

El usuario selecciona un año entre 2024 y el año actual. El provider evita volver a solicitar un año cuando ya existe al menos una evaluación de ese año en memoria.

Se generan cuatro matrices de 12 meses × 31 posiciones. Cada evaluación ocupa la posición `[mes - 1][día - 1]`. Cada dimensión se presenta en un `LineChart` independiente:

- ansiedad emocional, eje 0–20 e intervalo 5;
- ansiedad física, eje 0–40 e intervalo 10;
- depresión, eje 0–20 e intervalo 5;
- impulsos suicidas, eje 0–8 e intervalo 2.

Cada gráfico permite avanzar o retroceder entre enero y diciembre y comienza en el mes calendario actual. Los días sin evaluación son `null`; el algoritmo divide la línea en segmentos, de modo que no une períodos separados por días sin datos.

### 8.9 Detalle anual y detalle diario

La vista detallada:

- ordena las evaluaciones de más reciente a más antigua;
- resume cantidad de evaluaciones, meses activos y fecha del último registro;
- agrupa resultados por mes;
- muestra primero meses con registros y después meses vacíos;
- permite abrir cada evaluación en una hoja modal de 92 % de alto;
- muestra puntuación, clasificación, descripción y notas por dimensión;
- agrega una advertencia destacada si la dimensión de seguridad es mayor que cero.

### 8.10 Exportación anual

El usuario puede descargar el año seleccionado:

**PDF:** A4 horizontal, tabla cronológica ascendente, cabecera, paginación, aviso de uso personal y columnas Fecha, Ansiedad emocional, Ansiedad física, Estado de ánimo, Seguridad personal y Notas.

**XLSX:** libro construido manualmente como un archivo ZIP OpenXML, hoja `Resultados`, encabezado congelado, autofiltro, anchos de columna y las mismas seis columnas. Los puntajes se guardan como números.

Los nombres son `mindsave_test_breve_<año>.pdf` y `mindsave_test_breve_<año>.xlsx`. `MindsaveFileSaver` abre el mecanismo de guardado ofrecido por la plataforma.

## 9. Registro de estado de ánimo CBT

### 9.1 Objetivo funcional

Implementa un registro cognitivo-conductual en seis pasos. Los primeros tres capturan situación, emociones y pensamientos automáticos. Los últimos tres identifican distorsiones, generan pensamientos alternativos y vuelven a medir la intensidad emocional.

### 9.2 Entidad principal y criterio de estado

`RegistroEstadoAnimo` contiene:

| Campo | Descripción |
|---|---|
| `id` | Identificador retornado por backend. |
| `fecha` | Fecha del suceso, no necesariamente fecha de creación. |
| `sucesoTrastornador` | Descripción libre de la situación. |
| `grupoEmociones1..9` | Nueve grupos predefinidos con selección e intensidad antes/después. |
| `grupoEmocionesPersonalizadas` | Emociones creadas por el usuario e intensidad común. |
| `listaPensamientos` | Uno o más pensamientos automáticos y su reestructuración. |

Un registro es **pendiente** si al menos un pensamiento carece de pensamiento alternativo, creencia posterior o creencia positiva, o si al menos un grupo emocional no posee intensidad posterior. Queda **completo** cuando todos esos campos dejan de ser nulos.

### 9.3 Catálogo de emociones

Cada grupo predefinido guarda una lista de booleanos seleccionados y dos intensidades: `porcentajeCreenciaAntes` y `porcentajeCreenciaDespues`.

| Grupo funcional | Emociones disponibles |
|---|---|
| Tristeza y ánimo bajo | Triste, Melancólico, Deprimido, Decaído, Infeliz |
| Ansiedad y miedo | Angustiado, Preocupado, Con pánico, Nervioso, Asustado |
| Culpa | Culpable, Con remordimiento, Malo, Avergonzado |
| Vergüenza/inadecuación | Inferior, Sin valor, Inadecuado, Deficiente, Incompetente |
| Soledad y rechazo | Solitario, No querido, No deseado, Rechazado, Solo, Abandonado |
| Incomodidad/turbación | Turbado, Tonto, Humillado, Apurado |
| Desesperanza | Desesperanzado, Desanimado, Pesimista, Descorazonado |
| Frustración | Frustrado, Atascado, Chasqueado, Derrotado |
| Ira y enojo | Airado, Enfadado, Resentido, Molesto, Irritado, Trastornado, Furioso |
| Personalizadas | Lista libre creada por el usuario |

Reglas de intensidad inicial:

- escala 0–100;
- los sliders predefinidos tienen 20 divisiones, es decir, pasos visuales de cinco puntos;
- si hay alguna emoción seleccionada, la intensidad debe ser mayor que cero;
- si no hay emociones seleccionadas, la intensidad debe ser cero;
- una emoción personalizada no puede estar vacía ni repetida exactamente;
- eliminar la última emoción personalizada restablece su intensidad a cero.

### 9.4 Modelo de pensamiento

Cada `Pensamiento` contiene:

| Campo | Momento | Regla |
|---|---|---|
| `pensamientoNegativo` | Paso 3 | Texto obligatorio. |
| `porcentajeCreenciaAntes` | Paso 3 | 1–100; un pensamiento nuevo comienza en 50. |
| `distorsion` | Paso 4 | Vector de diez booleanos. |
| `pensamientoPositivo` | Paso 5 | Texto alternativo obligatorio. |
| `porcentajeCreenciaPositivo` | Paso 5 | 1–100. |
| `porcentajeCreenciaDespues` | Paso 5 | 0–100. |

Distorsiones disponibles:

1. Pensamiento todo o nada.
2. Generalización excesiva.
3. Filtro mental.
4. Descartar lo positivo.
5. Saltar a conclusiones, incluyendo lectura del pensamiento o adivinación del porvenir.
6. Magnificación o minimización.
7. Razonamiento emocional.
8. Afirmaciones del tipo “debería”.
9. Poner etiquetas.
10. Inculpación propia o de los demás.

El código incluye una explicación extensa para cada distorsión y la presenta en el paso 4.

### 9.5 Paso 1: describir el suceso

**Datos:** fecha y descripción.

- La fecha inicial es hoy.
- El selector acepta fechas desde el 1 de enero de 2000 hasta hoy.
- La descripción del suceso es obligatoria y admite varias líneas.
- Los cambios se realizan sobre el borrador en memoria.

### 9.6 Paso 2: identificar emociones e intensidad inicial

La interfaz presenta los nueve grupos en paneles expandibles y un grupo adicional de emociones personalizadas. Antes de mostrar los grupos predefinidos, cualquier intensidad nula se inicializa en cero.

El usuario selecciona palabras e indica una intensidad común para cada grupo. El formulario no exige seleccionar al menos una emoción globalmente: un registro con todos los grupos en cero es válido si posteriormente contiene al menos un pensamiento.

### 9.7 Paso 3: registrar pensamientos automáticos

El usuario puede agregar múltiples pensamientos, modificar su texto e intensidad inicial o eliminarlos con confirmación. Se exige al menos un pensamiento antes de guardar.

Al finalizar:

1. se ejecuta la validación integral de `RegistroEstadoAnimo`;
2. se envía `POST /api/registro-estado-de-animo/`;
3. el backend retorna un `id`;
4. el registro se agrega al provider general;
5. el provider de borrador crea una nueva instancia vacía;
6. la aplicación navega al paso 4 usando el id retornado.

Como todas las intensidades posteriores y la reestructuración todavía son nulas, el registro queda persistido como pendiente.

### 9.8 Paso 4: identificar distorsiones cognitivas

La pantalla carga el registro por id si no está en memoria. Para cada pensamiento muestra las diez distorsiones como casillas. No exige seleccionar ninguna; continuar guarda el objeto mediante PUT y navega al paso 5.

También ofrece una guía expandible con la definición de cada distorsión.

### 9.9 Paso 5: reestructurar pensamientos

Para cada pensamiento se muestran:

- pensamiento negativo original;
- distorsiones seleccionadas;
- campo obligatorio de pensamiento alternativo positivo;
- porcentaje de creencia en la alternativa, 1–100;
- porcentaje posterior de creencia en el pensamiento negativo, 0–100.

Todos los formularios deben ser válidos antes de persistir por PUT y avanzar al paso 6.

### 9.10 Paso 6: reevaluar emociones

Solo se muestran grupos que contienen emociones seleccionadas. Para cada uno se presenta intensidad antes, campo después (0–100) y una comparación:

- si `antes - después >= 0`, muestra “Redujo N% · Buen progreso”;
- si el valor es negativo, muestra “Aumentó N% · Sigue observando”.

Al guardar, los grupos sin selección reciben intensidad posterior 0. Después se ejecuta PUT y se navega al detalle completo.

### 9.11 Volver, conservar o descartar cambios

En los pasos 4–6, volver abre un diálogo con Cancelar, No guardar y Guardar. “Guardar” ejecuta PUT antes de volver; “No guardar” evita el PUT.

Sin embargo, la entidad del provider se modifica directamente. Por ello, “No guardar” descarta la persistencia remota inmediata, pero las modificaciones pueden permanecer en la instancia en memoria durante la sesión. Esta diferencia debe considerarse al modelar el flujo alternativo.

### 9.12 Reanudación de registros pendientes

El listado calcula el punto de continuación:

1. Si ningún pensamiento tiene al menos una distorsión seleccionada → considera completado el paso 3 y dirige al paso 4.
2. Si hay distorsiones, pero algún pensamiento no tiene alternativa o porcentaje positivo → considera completado el paso 4 y dirige al paso 5.
3. En cualquier otro registro todavía pendiente → considera completado el paso 5 y dirige al paso 6.

La ausencia de una distorsión seleccionada se usa como señal de “paso 4 no completado”, aunque el paso permite continuar sin seleccionar ninguna. Por tanto, un usuario que conscientemente seleccionó cero distorsiones puede volver a ser dirigido al paso 4.

### 9.13 Listado y paginación

`RegistrosScreen` contiene pestañas Pendientes y Completados. Ambos conjuntos se ordenan localmente por fecha descendente.

El provider carga inicialmente:

1. página 1 de completos;
2. página 1 de pendientes.

Cada familia usa `page`, `limit = 10` y `isLastPage`. Si una página trae menos de diez elementos se marca como última. La acción “Cargar más registros” solicita la página siguiente. El gesto de actualizar no reinicia los contadores ni vuelve a cargar la primera página; solicita páginas aún no cargadas.

Las tarjetas pendientes muestran fecha, situación, hasta tres emociones, paso estimado, porcentaje de seis pasos y acción para continuar. Las completadas muestran reducción emocional, cantidad de pensamientos y primer grupo emocional seleccionado.

### 9.14 Detalle de registro completado

La pantalla presenta:

- situación y fecha;
- reducción emocional agregada;
- número de pensamientos trabajados;
- cantidad de grupos emocionales revisados;
- evolución antes/después por grupo;
- pensamiento negativo, creencia inicial/final, distorsiones y pensamiento alternativo;
- acciones Exportar, Editar y Eliminar.

La reducción emocional agregada se calcula solo con grupos cuya intensidad inicial es mayor que cero y cuya intensidad posterior existe:

```text
reducción = redondear(((sumaAntes - sumaDespués) / sumaAntes) × 100)
```

El valor se limita al intervalo 0–100; un aumento agregado se representa como 0 % y no como porcentaje negativo.

Editar conduce nuevamente a los pasos 1–3 del mismo registro y, al continuar, vuelve a recorrer pasos 4–6. Eliminar requiere confirmación y ejecuta DELETE.

### 9.15 Exportación individual

**PDF A4:** situación, tabla de evolución emocional, reestructuración de cada pensamiento, fecha, estado, paginación y aviso de que no reemplaza evaluación profesional.

**XLSX:** secciones Registro, Emociones y Pensamientos; incluye valores antes/después, cambio en puntos, distorsiones y alternativa. El archivo OpenXML se construye manualmente y se comprime con `archive`.

Nombres: `mindsave_registro_cbt_<AAAA-MM-DD>_<id-sanitizado>.pdf|xlsx`. El id se limita a ocho caracteres alfanuméricos, guion o guion bajo.

## 10. Externalización de voces mediante chat asistido

### 10.1 Modelo de datos

```text
ChatHistoryChatIa
├── id: String
├── title: String
└── mensajes: List<MensajeChatIa>
    ├── id: String
    ├── text: String
    ├── createdAt: DateTime
    ├── role: String
    └── archivos: List<ArchivoChatIa>
        ├── fileUri: String
        ├── mimeType: String
        └── fileUrl: String
```

Al leer mensajes, `createdAt` se convierte a hora local. Para la UI, un mensaje con `role == "user"` pertenece al usuario actual; cualquier otro rol se atribuye a MindSave.

### 10.2 Listar conversaciones

Al entrar en `/externalizacionVoces/0`, `chatListProvider` ejecuta `GET /api/chat-ia/get-chats-by-user`. La respuesta esperada es `{results: [chat...]}`.

Cada tarjeta presenta título y un mensaje usado como vista previa. El código toma `chat.mensajes.first`; no ordena los chats ni los mensajes en esta vista y contiene un TODO para ordenar por mensaje más reciente. El orden real depende de la respuesta del backend.

### 10.3 Crear conversación

1. El usuario abre “Nuevo chat”.
2. Ingresa un título.
3. La validación local solo exige texto no vacío después de `trim`.
4. Se envía `POST /api/chat-ia/new-chat` con `{title}`.
5. El id se toma de `response.data["result"]`.
6. El notifier envía automáticamente el prompt `Hola` al chat recién creado y consume el stream completo.
7. Agrega el nuevo chat, todavía con lista local de mensajes vacía, al inicio del listado.

La unicidad del título depende del backend. Cualquier excepción de creación o del saludo automático se presenta como “Nombre del chat ya usado”, incluso cuando la causa sea distinta.

### 10.4 Eliminar conversación

Una pulsación larga abre confirmación. Al aceptar, se ejecuta `DELETE /api/chat-ia/delete-chat/:idChat` y se elimina la conversación del estado local. Un error muestra “No se pudo eliminar el chat”.

### 10.5 Cargar mensajes

Al abrir `/externalizacionVoces/chat/:idChat`:

1. se ejecuta `GET /api/chat-ia/get-messages-from-chat/:idChat`;
2. se toma `response.data["result"]`;
3. los mensajes se ordenan por fecha ascendente;
4. cada archivo con MIME que comienza por `image` se convierte en `ImageMessage` usando `fileUrl`;
5. el texto no vacío se convierte en `TextMessage`;
6. `chatControllerProvider` inserta, actualiza o reemplaza mensajes en el controlador de `flutter_chat_ui`.

Archivos no considerados imágenes permanecen en la entidad, pero no se renderizan en la conversación.

### 10.6 Enviar texto e imágenes

La acción de adjuntar abre `ImagePicker.pickMultiImage(limit: 4)`. La UI muestra cuántas imágenes están seleccionadas y permite quitar el conjunto completo.

Al enviar:

1. se impiden envíos concurrentes mientras la IA está respondiendo;
2. se agregan a la UI mensajes locales de imagen y texto;
3. se agrega un mensaje temporal “Mindsave está pensando ...”;
4. se construye `multipart/form-data` con `prompt`, `chatId` y una entrada `files` por imagen;
5. se ejecuta `POST /api/chat-ia/send-message-to-chat/:idChat` con respuesta streaming;
6. cada fragmento UTF-8 se concatena al buffer completo;
7. el mensaje temporal se reemplaza repetidamente por el texto acumulado;
8. al finalizar se habilita un nuevo envío;
9. ante error, el mensaje de respuesta se reemplaza por una indicación de reintento y se muestra un SnackBar.

Las cachés del listado y de los mensajes del chat se invalidan al aceptar y al terminar la solicitud.

El módulo no expone una ruta o pantalla de guía. Su navegación autenticada se limita al listado `/externalizacionVoces/0` y a la conversación `/externalizacionVoces/chat/:idChat`.

## 11. Modelo de dominio y relaciones útiles para UML

### 11.1 Relaciones principales

| Origen | Relación | Destino | Multiplicidad |
|---|---|---|---|
| `AuthState` | contiene | `User` | 0..1 |
| `TestBreveEstadoDeAnimo` | compone | `SentimientosAnsiedadEmocionalTestBreve` | 1 |
| `TestBreveEstadoDeAnimo` | compone | `SentimientosAnsiedadFisicaTestBreve` | 1 |
| `TestBreveEstadoDeAnimo` | compone | `DepresionTestBreve` | 1 |
| `TestBreveEstadoDeAnimo` | compone | `ImpulsoSuicidaTestBreve` | 1 |
| `RegistroEstadoAnimo` | compone | `GrupoEmociones1..9` | 9 |
| `RegistroEstadoAnimo` | compone | `GrupoEmocionesPersonalizadas` | 1 |
| `RegistroEstadoAnimo` | compone | `Pensamiento` | 1..* por validación |
| `ChatHistoryChatIa` | compone | `MensajeChatIa` | 0..* |
| `MensajeChatIa` | compone | `ArchivoChatIa` | 0..* |
| `*Notifier` | depende de | repositorio de su módulo | 1 |
| repositorio concreto | delega en | datasource | 1 |
| datasource API | usa | `AuthenticatedHttpClient` | 1, salvo autenticación |

### 11.2 Contratos de repositorio

| Repositorio | Operaciones |
|---|---|
| `AuthRepository` | `login`, `register`, `checkAuthStatus`, `resetPassword` |
| `TestBreveEstadoDeAnimoRepository` | guardar, obtener por año, obtener hoy, editar hoy, eliminar hoy |
| `RegistroEstadoAnimoRepository` | guardar, listar completos, listar pendientes, obtener por id, editar, eliminar |
| `ExternalizacionDeVocesRepository` | crear chat, listar chats, obtener mensajes, eliminar chat, enviar mensaje como stream |

### 11.3 Mapeo DTO del test breve

El modelo de dominio usa nombres orientados a la aplicación; el contrato HTTP usa:

```json
{
  "fecha": "ISO-8601",
  "ansiedadEmocional": { "...": "cinco enteros" },
  "ansiedadFisica": { "...": "diez enteros" },
  "depresion": { "...": "cinco enteros" },
  "impulsoSuicida": { "...": "dos enteros" },
  "notas": "texto opcional"
}
```

`TestBreveEstadoDeAnimoMapper` transforma bidireccionalmente este DTO y las cinco entidades de dominio.

El registro CBT y los chats se serializan directamente desde sus entidades, sin una capa separada de DTO/mappers.

## 12. Contratos HTTP consumidos

Todas las rutas de test, registro y chat usan Bearer token y el cliente con caché. Las rutas de autenticación usan una instancia Dio separada.

| Método | Ruta | Solicitud | Respuesta esperada / efecto |
|---|---|---|---|
| GET | `/api/auth/check-status` | Bearer token | Objeto usuario |
| POST | `/api/auth/login` | `{email, password}` | Objeto usuario con token |
| POST | `/api/auth/register` | `{email, password, name}` | HTTP 201 o `{error}` |
| POST | `/api/auth/resend-validation-email` | `{email}` | Reenvía el correo de activación o devuelve `{error}` |
| POST | `/api/auth/reset-password` | `{email}` | HTTP 200 o `{error}` |
| POST | `/api/test-breve-estado-de-animo/` | DTO de test | HTTP 201 |
| GET | `/api/test-breve-estado-de-animo/by-year/:year` | — | Lista de DTO de test |
| GET | `/api/test-breve-estado-de-animo/by-date/:year/:month/:day` | — | DTO o `null` |
| PUT | `/api/test-breve-estado-de-animo/` | DTO de test | HTTP 200 |
| DELETE | `/api/test-breve-estado-de-animo/:year/:month/:day` | — | Elimina evaluación del día |
| POST | `/api/registro-estado-de-animo/` | JSON de registro | HTTP 201 y `{id}` |
| GET | `/api/registro-estado-de-animo/completos/?page=&limit=` | Paginación | `{results: [...]}` |
| GET | `/api/registro-estado-de-animo/pendientes/?page=&limit=` | Paginación | `{results: [...]}` |
| GET | `/api/registro-estado-de-animo/:id` | — | JSON de registro o `null` |
| PUT | `/api/registro-estado-de-animo/` | JSON de registro | HTTP 200 |
| DELETE | `/api/registro-estado-de-animo/:id` | — | Elimina registro |
| POST | `/api/chat-ia/new-chat` | `{title}` | `{result: idChat}` |
| GET | `/api/chat-ia/get-chats-by-user` | — | `{results: [chat...]}` |
| GET | `/api/chat-ia/get-messages-from-chat/:idChat` | — | `{result: chat}` o `null` |
| DELETE | `/api/chat-ia/delete-chat/:idChat` | — | Elimina chat |
| POST | `/api/chat-ia/send-message-to-chat/:idChat` | Multipart: `prompt`, `chatId`, `files*` | Stream de bytes UTF-8 |

No se configuran tiempos máximos explícitos en `BaseOptions`; el manejo de `connectionTimeout` existe en autenticación, pero depende de que Dio o la plataforma produzcan ese tipo de error.

## 13. Persistencia y ciclo de vida de datos

### 13.1 Datos persistidos localmente de forma activa

| Clave | Tipo | Contenido | Eliminación |
|---|---|---|---|
| `token` | String | Token Bearer de sesión | Cierre de sesión o token inválido |
| `isDarkMode` | bool | Preferencia de tema | No existe acción de eliminación; se sobrescribe |

`LocalStorageServiceImpl` solo soporta String y bool. Otros tipos lanzan `UnimplementedError`.

### 13.2 Datasources locales no conectados

Existen:

- `TestBreveEstadoDeAnimoLocalDatasource`, con clave `testsBreveEstadoDeAnimo`;
- `RegistroEstadoDeAnimoLocalDatasource`, con clave `registrosEstadosAnimo`.

Ambos serializan listas JSON en `SharedPreferences`, pero los providers de repositorio instancian actualmente las versiones API. Por tanto, estos datasources **no aportan funcionamiento offline al producto ejecutado**.

Además, el datasource CBT local clasifica pendiente/completo mirando únicamente `grupoEmociones1.porcentajeCreenciaDespues`, mientras la entidad activa usa todos los pensamientos y grupos; esa implementación alternativa no es semánticamente equivalente al flujo actual.

### 13.3 Datos remotos e información sensible

Los tests, situaciones, emociones, pensamientos, notas, mensajes e imágenes se transmiten al backend. El token se almacena en `SharedPreferences`, no en almacenamiento seguro cifrado. El repositorio no contiene política de privacidad, consentimiento explícito, borrado total de cuenta ni configuración de retención.

## 14. Manejo de errores y estados de carga

| Módulo | Estrategia observada |
|---|---|
| Autenticación | Traduce códigos específicos y mantiene una pantalla de reintento cuando no puede validar una sesión existente. |
| Test breve | Usa un `isLoadingProvider` compartido; guardar devuelve `"OK"` o texto de excepción, mientras otras operaciones propagan o atrapan errores en pantalla. |
| Registro CBT | Usa un único `isLoading` para paginación y CRUD; varias pantallas no muestran un estado de error explícito. |
| Chats | `ChatsListState` y `ChatState` contienen `error`; la UI lo consume en SnackBars y luego lo limpia. |
| Exportación | Bloquea botones mientras genera y muestra éxito, cancelación o error genérico. |
| Caché | Una falla al leer, invalidar o limpiar caché no bloquea la operación principal. |

Cuando `cargarRegistrosEstadoDeAnimoById` falla, el notifier atrapa el error sin exponerlo. Las pantallas que esperan el registro pueden seguir mostrando “Cargando tu registro…” aunque `isLoading` ya sea falso y el objeto no exista.

## 15. Dependencias y función arquitectónica

| Dependencia | Uso en el proyecto |
|---|---|
| `flutter_riverpod` | Estado reactivo, inyección de repositorios/cliente y coordinación. |
| `go_router` | Rutas declarativas, parámetros y guardas de autenticación. |
| `dio` | Cliente HTTP y streaming. |
| `dio_cache_interceptor` | Caché GET en memoria y fallback ante falla de red. |
| `shared_preferences` | Token, tema y datasources locales alternativos. |
| `flutter_dotenv` | Lectura de `API_URL_BASE`. |
| `fl_chart` | Gráficos de seguimiento mensual. |
| `flutter_chat_core` / `flutter_chat_ui` | Modelo/controlador e interfaz de conversación. |
| `flyer_chat_image_message` | Render de mensajes de imagen. |
| `image_picker` | Selección múltiple de imágenes. |
| `pdf` | Generación de reportes PDF. |
| `archive` | Creación manual de XLSX como ZIP OpenXML. |
| `file_saver` | Diálogo y escritura de exportaciones. |
| `google_fonts` | Tipografías Inter y Lora. |

## 16. Limitaciones, inconsistencias y funcionalidad incompleta

Esta sección describe comportamiento observable y no debe transformarse en requisito deseado sin una decisión explícita.

### 16.1 Funciones parciales

1. El selector rápido de ánimo del inicio no guarda datos.
2. Los chips de categorías de Módulos no filtran.
3. No existe gestión de perfil, cambio de contraseña autenticado ni eliminación de cuenta.

### 16.2 Tiempo y cambio de día

1. `TestBreveCompletedCard._formatTime` resta cuatro horas manualmente y no normaliza cambio de fecha. Esto puede mostrar horas negativas y produjo una divergencia con la prueba existente.
2. El timer de medianoche llama `setTestBreveRealizadoHoy`, pero este método retorna inmediatamente si el estado ya contiene un test. Si la app permanece abierta al cambiar de día, puede seguir considerando el test anterior como “de hoy”.
3. Otras partes usan `DateTime.now()` local y los mensajes de chat convierten fechas del backend con `toLocal`; no existe una política horaria centralizada.

### 16.3 Reglas y modelos

1. Los DTO `*Response` del test aceptan por aserción 0–5, mientras las entidades y la UI aceptan 0–4.
2. `SentimientosAnsiedadFisicaTestBreveResponse.result` repite `<= 30` para severa y extrema, por lo que su rama extrema es inalcanzable; el flujo principal usa el resultado de la entidad de dominio, que sí maneja hasta 40.
3. El progreso CBT confunde “no se seleccionó ninguna distorsión” con “paso 4 no realizado”.
4. “No guardar” en pasos CBT no revierte mutaciones en memoria.
5. La reducción emocional agregada se limita a cero ante empeoramiento, ocultando un valor negativo agregado.
6. Los formularios del test comienzan con todas las respuestas válidas en cero, sin exigir interacción explícita.

### 16.4 Red, caché y errores

1. No hay backend en este repositorio ni mock de ejecución para la aplicación completa.
2. `API_URL_BASE` vacío no detiene el arranque.
3. El caché es volátil y no permite operación offline completa.
4. Varios errores CBT se silencian o se convierten en mensajes genéricos.
5. La creación de chat presenta cualquier fallo como título duplicado.
6. La lista de chats no se ordena en el cliente y usa el primer mensaje como vista previa.
7. El saludo automático `Hola` de un chat nuevo no se agrega al objeto local; aparece después de recargar el historial.
8. Una respuesta HTTP 401 finaliza la sesión, pero no existe renovación automática del token ni reintento transparente de la solicitud original.

### 16.5 Seguridad y despliegue móvil

1. El token se guarda sin `flutter_secure_storage` ni mecanismo equivalente.
2. El manifest Android principal no declara `INTERNET`; la declaración existe solo en `debug` y `profile`, por lo que una compilación release puede carecer de permiso de red.
3. La configuración release Android firma con claves debug; el identificador está configurado como `applicationId = com.mindsave.app`.
4. `Info.plist` no declara descripciones de uso de galería/fotos requeridas habitualmente por `image_picker` en iOS.
5. Los nombres visibles de Android/iOS están configurados como “Mindsave”.
6. No se observa certificate pinning, cifrado de payload a nivel de aplicación ni sanitización clínica específica.
7. `.env` se declara como asset de Flutter. Es apropiado para una URL base, pero cualquier secreto añadido allí quedaría incluido en el paquete distribuido.
8. La entidad `User` contiene y serializa un campo `password`, aunque el flujo de sesión normalmente lo construye vacío y no lo persiste; mantener credenciales en una entidad de sesión amplía innecesariamente el modelo sensible.

### 16.6 Exportaciones

Los PDF usan fuentes Helvetica básicas sin soporte Unicode completo. El exportador reemplaza tildes/ñ por ASCII y caracteres no ASCII por `?`; por ello, el contenido del PDF puede perder fidelidad lingüística. El XLSX conserva texto Unicode mediante XML escapado.

## 17. Estado de calidad verificado

### 17.1 Análisis estático

Se ejecutó:

```text
flutter analyze
```

Resultado: **sin issues reportados**.

### 17.2 Pruebas automatizadas

La suite cubre:

- normalización, aislamiento, vigencia, fallback e invalidación de caché;
- recreación del cliente por cambio de token/usuario/sesión y cierre automático ante HTTP 401;
- validación y adaptabilidad de pantallas de autenticación;
- reenvío del correo de activación, incluyendo endpoint y body enviados;
- reintento de conexión;
- providers migrados a Riverpod `Notifier`;
- streaming y render de imágenes del chat;
- widgets y validaciones del flujo CBT;
- exportaciones PDF/XLSX de CBT y test anual;
- navegación inferior y vistas de carga;
- detalle anual y modal diario en tamaño Pixel 9;
- consulta autónoma y presentación del resultado de hoy al abrir la vista diaria.

Resultado de `flutter test`: **36 pruebas exitosas y 1 fallida**.

La falla está en `test_breve_completed_card_test.dart`: la prueba crea una evaluación a las 09:14 y espera “Respondido a las 09:14”, mientras la implementación resta cuatro horas y genera una hora diferente. Esta falla confirma la inconsistencia horaria descrita anteriormente; no es un fallo aleatorio de infraestructura.

Durante las pruebas de PDF también se muestran advertencias por falta de soporte Unicode de Helvetica; los archivos se generan y superan las validaciones estructurales existentes.

## 18. Trazabilidad de funcionalidades a archivos

| Funcionalidad | Archivos principales |
|---|---|
| Arranque y entorno | `lib/main.dart`, `lib/config/constants/environment.dart` |
| Rutas y guardas | `lib/config/router/app_router.dart`, `app_router_notifier.dart` |
| Tema | `lib/config/theme/app_theme.dart`, `lib/home/presentation/providers/theme_provider.dart` |
| Sesión | `lib/auth/presentation/providers/auth_provider.dart` |
| Endpoints auth | `lib/auth/infrastructure/datasources/auth_datasource_impl.dart` |
| Cliente, caché y manejo de HTTP 401 | `lib/shared/infrastructure/http/authenticated_http_client.dart`, `lib/shared/presentation/providers/authenticated_http_client_provider.dart` |
| Inicio y módulos | `lib/home/presentation/screens/home_screen.dart`, `lib/home/presentation/screens/modules_screen.dart` |
| Entidad test y puntuación | `lib/test_breve_estado_animo/domain/entities/` |
| CRUD test | `lib/test_breve_estado_animo/presentation/providers/`, `lib/test_breve_estado_animo/infrastructure/datasources/api_datasource.dart` |
| Formulario test | `lib/test_breve_estado_animo/presentation/screens/test_breve_estado_animo_create_screen.dart`, `lib/test_breve_estado_animo/presentation/widgets/shared/*_form.dart` |
| Seguimiento test | `lib/test_breve_estado_animo/presentation/screens/test_breve_estado_animo_year_results_screen.dart`, `lib/test_breve_estado_animo/presentation/widgets/shared/custom_histogram.dart` |
| Detalle/exportación test | `lib/test_breve_estado_animo/presentation/screens/test_breve_estado_animo_details_year_results_screen.dart`, `lib/test_breve_estado_animo/presentation/services/test_breve_results_exporter.dart` |
| Entidad CBT | `lib/registro_estado_animo/domain/entities/registro_estado_animo.dart`, `lib/registro_estado_animo/domain/entities/emociones.dart`, `lib/registro_estado_animo/domain/entities/pensamiento.dart` |
| Flujo CBT | `lib/registro_estado_animo/presentation/screens/registro_estado_animo_create_screen.dart`, `lib/registro_estado_animo/presentation/screens/registro_estado_animo_pending_view_step_*`, `lib/registro_estado_animo/presentation/widgets/cbt_flow_layout.dart` |
| Historial CBT | `lib/registro_estado_animo/presentation/screens/registros_screen.dart` |
| Detalle/exportación CBT | `lib/registro_estado_animo/presentation/screens/registro_estado_animo_complete_view_details_screen.dart`, `lib/registro_estado_animo/presentation/services/cbt_record_exporter.dart` |
| CRUD CBT | `lib/registro_estado_animo/presentation/providers/registro_estado_animo_provider.dart`, `lib/registro_estado_animo/infrastructure/datasources/api_datasource.dart` |
| Entidades/chat | `lib/externalizacion_de_voces/domain/entities/` |
| Lista de chats | `lib/externalizacion_de_voces/presentation/providers/chats_list_provider.dart`, `lib/externalizacion_de_voces/presentation/screens/externalizacion_voces_initial_screen.dart` |
| Conversación/streaming | `lib/externalizacion_de_voces/presentation/providers/chat_provider.dart`, `lib/externalizacion_de_voces/presentation/screens/externalizacion_voces_chat_screen.dart`, `lib/externalizacion_de_voces/infrastructure/datasources/externalizacion_de_voces_datasource_impl.dart` |
| Guardado de archivos | `lib/shared/infrastructure/files/mindsave_file_saver.dart` |

## 19. Base sugerida para casos de uso extendidos

Los siguientes casos de uso pueden derivarse directamente sin inventar capacidades:

### Visitante

- CU-AUT-01 Iniciar sesión.
- CU-AUT-02 Crear cuenta.
- CU-AUT-03 Solicitar restablecimiento de contraseña.
- CU-AUT-04 Recuperar sesión guardada.
- CU-AUT-05 Reintentar validación de sesión sin conexión.
- CU-AUT-06 Reenviar correo de activación.

### Usuario autenticado

- CU-USR-01 Cerrar sesión.
- CU-USR-02 Cambiar tema visual.
- CU-TST-01 Crear test breve del día.
- CU-TST-02 Consultar resultado diario.
- CU-TST-03 Editar test del día.
- CU-TST-04 Eliminar test del día.
- CU-TST-05 Consultar seguimiento anual.
- CU-TST-06 Consultar detalle de una evaluación histórica.
- CU-TST-07 Exportar resultados anuales.
- CU-CBT-01 Crear pasos 1–3 de un registro CBT.
- CU-CBT-02 Identificar distorsiones cognitivas.
- CU-CBT-03 Reestructurar pensamientos.
- CU-CBT-04 Reevaluar emociones y completar registro.
- CU-CBT-05 Reanudar registro pendiente.
- CU-CBT-06 Consultar registro completado.
- CU-CBT-07 Editar registro.
- CU-CBT-08 Eliminar registro.
- CU-CBT-09 Exportar registro individual.
- CU-CHAT-01 Listar conversaciones.
- CU-CHAT-02 Crear conversación.
- CU-CHAT-03 Enviar mensaje de texto.
- CU-CHAT-04 Enviar mensaje con imágenes.
- CU-CHAT-05 Recibir respuesta progresiva de IA.
- CU-CHAT-06 Eliminar conversación.

No deberían modelarse todavía como casos de uso implementados: registrar el selector rápido del inicio, filtrar módulos por chip, consultar una guía de externalización —no existe ruta ni pantalla para ella—, contactar automáticamente emergencias o trabajar offline.

## 20. Secuencias clave para diagramas

### 20.1 Secuencia de una operación autenticada

```text
Pantalla → Notifier → Repositorio → Datasource API
        → AuthenticatedHttpClient/Dio → Backend
        ← JSON/stream ← mapper o entidad ← estado Riverpod ← UI
```

Para GET, el cliente puede responder desde caché antes de llegar al backend. Para mutaciones, el datasource invalida la familia de caché después de una respuesta exitosa.

Ante una respuesta no autorizada, la secuencia alternativa es:

```text
Backend → HTTP 401 → _UnauthorizedInterceptor
        → onUnauthorized → AuthNotifier.logout
        → eliminar token + estado notAuthenticated
        → GoRouter redirige a /login
        → cerrar cliente/caché de la sesión anterior
        → propagar DioException original al solicitante
```

### 20.2 Secuencia de creación CBT

```text
Usuario completa pasos 1–3
→ widgets mutan borrador
→ validación de formularios y entidad
→ NuevoRegistroNotifier.guardar
→ RegistroNotifier.guardar
→ POST registro
→ backend retorna id
→ agregar registro pendiente al estado
→ navegar a paso 4
```

### 20.3 Secuencia de mensaje de chat

```text
Usuario envía texto/imágenes
→ ChatNotifier crea mensajes locales + placeholder
→ repositorio abre POST multipart streaming
→ datasource acumula fragmentos UTF-8
→ notifier reemplaza el placeholder por cada versión acumulada
→ controlador de chat actualiza el mensaje existente
→ UI renderiza la respuesta progresiva
```

### 20.4 Secuencia de recuperación de sesión

```text
Inicio → AuthNotifier lee token
  ├─ sin token → logout → router/login
  ├─ token válido → GET check-status → usuario → router/home
  ├─ token inválido → borrar token → router/login
  └─ error de red → mantener checking + error → splash offline → reintentar
```

## 21. Conclusión arquitectónica

El núcleo funcional está implementado como cliente Flutter modular conectado a un backend REST autenticado. Riverpod coordina estado y dependencias; GoRouter aplica la frontera entre rutas públicas y privadas; las entidades contienen cálculos clínicos/descriptivos y criterios de completitud; Dio implementa transporte, streaming y caché en memoria.

El módulo más elaborado es el registro CBT de seis pasos, seguido por el test diario con seguimiento y exportación. Externalización de voces implementa el ciclo de listado, creación, eliminación, conversación y adjuntos; no incluye una guía. Las principales brechas para una arquitectura de producción se concentran en seguridad y renovación del token, configuración release, permisos móviles, política horaria, tratamiento de situaciones de crisis, consistencia de algunos estados mutables y documentación del backend.
