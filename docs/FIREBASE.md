# Configurar Firebase y Gemini

Guía paso a paso para conectar VisionDesc (Android) con Gemini mediante **Firebase AI Logic** y **App Check**, en el **plan gratuito (Spark)**.

> **La demostración actual no usa Firebase.** El front de demostración funciona sin ninguna configuración (README.md). Esta guía sirve para cuando se conecte el análisis con IA, **si se confirma Firebase AI Logic como backend** (decisión D11 de ARQUITECTURA.md, pendiente frente a un proxy propio con Dart Frog). Los pasos de consola (1, 2, 4 y 5) se pueden adelantar; los que dependen del código se indican.

**Tiempo estimado:** 30-45 minutos.

---

## Qué se configura y por qué

| Pieza | Para qué sirve |
|---|---|
| **Proyecto de Firebase** | Contenedor de la configuración de la app. |
| **Firebase AI Logic** con la **Gemini Developer API** | Permite llamar a Gemini desde la app **sin poner ninguna clave de API en el código**. |
| **App Check** | Comprueba que las peticiones vienen de la app auténtica y no de un script que robe tu cuota. **Será obligatorio para AI Logic desde el 2 de noviembre de 2026.** |
| **Remote Config** (opcional) | Permite cambiar el modelo de Gemini sin publicar una nueva versión. |

Los archivos que se generan (`google-services.json`, `firebase_options.dart`) **ya están en `.gitignore`**. No los subas al repositorio.

---

## 0. Requisitos previos

### 0.1 Corregir el `dart` del PATH (importante en este equipo)

`flutter doctor` avisa de que el comando `dart` del PATH apunta a una instalación antigua (`C:\dart\bin`, Dart 3.11), distinta de la que trae Flutter (Dart 3.13). Con la antigua, `flutterfire` y `build_runner` fallan.

En **Configuración de Windows → Sistema → Información → Configuración avanzada del sistema → Variables de entorno → Path** (de tu usuario):

1. Sube `C:\Users\USUARIO\flutter\bin` **por encima** de `C:\dart\bin`, o elimina `C:\dart\bin` si no la usas.
2. Añade también `%LOCALAPPDATA%\Pub\Cache\bin` (ahí se instala `flutterfire`).
3. Cierra y vuelve a abrir la terminal y comprueba:

```powershell
dart --version      # debe decir 3.13.x
```

### 0.2 Herramientas

```powershell
# Firebase CLI (requiere Node.js LTS: https://nodejs.org)
npm install -g firebase-tools
firebase login

# FlutterFire CLI
dart pub global activate flutterfire_cli
flutterfire --version
```

### 0.3 Android: componentes que faltan

`flutter doctor` también indica que faltan las *cmdline-tools* de Android y que no se han aceptado las licencias. Sin ellas no se puede compilar para Android:

1. Android Studio → **More Actions → SDK Manager → SDK Tools** → marca **Android SDK Command-line Tools (latest)** → **Apply**.
2. Luego:

```powershell
flutter doctor --android-licenses   # acepta con "y"
flutter doctor                      # el apartado de Android debe quedar en verde
```

---

## 1. Crear el proyecto de Firebase

1. Entra en <https://console.firebase.google.com> con tu cuenta de Google.
2. **Crear un proyecto** → nombre, por ejemplo, `visiondesc-udea`.
3. **Google Analytics: desactívalo.** La app no recoge analítica (ARQUITECTURA.md §6.5).
4. Al terminar, el proyecto queda en el plan **Spark (gratuito)**. No hace falta añadir un método de pago.

## 2. Activar Firebase AI Logic con la Gemini Developer API

1. En el menú de la izquierda: **AI Services → AI Logic** → **Comenzar** (*Get started*).
2. Cuando pregunte por el proveedor de la API de Gemini, elige **Gemini Developer API** (la opción sin costo).
3. Sigue el asistente hasta el final. Activa las APIs necesarias y **deja App Check aplicado (*enforced*)** para AI Logic. Por eso, en el paso 5 hay que configurar el modo de depuración.

> **No copies ninguna clave de API a la app.** Con Firebase AI Logic la clave de Gemini queda en el servidor de Firebase; la app no la necesita ni debe tenerla.

## 3. Conectar la app con `flutterfire configure`

Desde la carpeta del proyecto:

```powershell
flutterfire configure `
  --project=<ID-de-tu-proyecto> `
  --platforms=android `
  --android-package-name=co.edu.udea.visiondesc
```

(El ID del proyecto aparece en la consola, en **Configuración del proyecto → General**; suele terminar en números, por ejemplo `visiondesc-udea-1a2b3`.)

Esto hace lo siguiente:
- Registra la app Android en el proyecto.
- Descarga `android/app/google-services.json`.
- Añade el plugin de Gradle `com.google.gms.google-services` a Android.
- Genera `lib/firebase_options.dart` (está en `.gitignore`). El diseño previsto es leer la configuración nativa (`Firebase.initializeApp()` sin opciones), para que el proyecto compile aunque Firebase no esté configurado.

**Comprueba** que se añadió el plugin:

```powershell
Select-String -Path android\settings.gradle.kts, android\app\build.gradle.kts -Pattern "google-services"
```

Deben aparecer dos líneas: una con `version "…" apply false` en `settings.gradle.kts` y otra con `id("com.google.gms.google-services")` en `app/build.gradle.kts`.

## 4. Huella SHA-256 (Android)

Play Integrity (el proveedor de App Check en producción) necesita la huella del certificado con el que se firma la app.

```powershell
keytool -list -v -alias androiddebugkey -storepass android -keypass android `
  -keystore "$env:USERPROFILE\.android\debug.keystore"
```

(`keytool` viene con Android Studio, en `C:\Program Files\Android\Android Studio\jbr\bin`.)

Copia la línea **SHA256** y añádela en la consola: **Configuración del proyecto → General → Tus apps → app Android → Agregar huella digital**.

Cuando publiques en Google Play, añade también la huella de **firma de la app** que aparece en Play Console (**Integridad de la app**).

## 5. App Check en desarrollo: token de depuración

En las compilaciones de depuración, la app usará el **proveedor de depuración** de App Check (`AndroidDebugProvider`, que lee el token de `--dart-define=APP_CHECK_DEBUG_TOKEN`). La consola tiene que reconocer el token del equipo de desarrollo. *(El paso 3 de la opción A depende del código de la integración, aún no implementado.)*

### Opción A (recomendada): generar el token en la consola

1. Consola → **Seguridad → App Check → Apps** → menú ⋮ de la app Android → **Administrar tokens de depuración** → **Agregar token de depuración** → **Generar**. Ponle un nombre (por ejemplo, "Mi portátil") y copia el valor.
2. En la raíz del proyecto crea el archivo `dart_defines.json` (**ya está en `.gitignore`**):

```json
{ "APP_CHECK_DEBUG_TOKEN": "pega-aquí-el-token" }
```

3. Ejecuta la app así:

```powershell
flutter run --dart-define-from-file=dart_defines.json
```

### Opción B: leer el token de los registros

Ejecuta `flutter run` sin el archivo. En la consola aparece una línea de `DebugAppCheckProvider` que dice *"Enter this debug secret into the allow list…"*. Copia ese valor y regístralo en **Administrar tokens de depuración**. (Cambia si desinstalas la app o borras sus datos.)

> ⚠️ **El token de depuración da acceso a tu cuota.** No lo subas al repositorio ni lo compartas. Si se filtra, bórralo en **Administrar tokens de depuración** y genera otro.

## 6. Verificar App Check y activar la protección contra repetición

1. Consola → **Seguridad → App Check → APIs → Firebase AI Logic**: debe decir **Aplicado** (*Enforced*). Si dice *Unenforced*, pulsa **Aplicar**.
2. Haz algunos análisis desde la app (cuando esté implementada la feature de análisis) y revisa las métricas: las solicitudes deben aparecer como **verificadas**.
3. **Protección contra repetición:** el diseño pide tokens de **uso limitado** (`useLimitedUseAppCheckTokens: true`, ARQUITECTURA.md §3.4), así que podrás activarla en la misma pantalla. Antes, comprueba que la métrica *"Unverified: Reused token"* esté en cero. Si tras activarla aparecen errores 403 en la app, desactívala y revisa la configuración.

## 7. (Opcional) Remote Config y límites

### Remote Config

Consola → **Run → Remote Config** → **Crear configuración** y añade estos parámetros (la integración usará estos mismos valores por defecto si no existen):

| Parámetro | Tipo | Valor |
|---|---|---|
| `gemini_model` | Cadena | `gemini-3.8-flash` |
| `gemini_fallback_model` | Cadena | `gemini-3.5-flash-lite` |
| `app_check_limited_use_tokens` | Booleano | `true` |
| `request_timeout_seconds` | Número | `45` |
| `chat_max_turns` | Número | `10` |

Pulsa **Publicar cambios**. Si Google retira un modelo, basta con cambiar `gemini_model` aquí.

### Límite por usuario

La cuota gratuita de Gemini es **del proyecto completo y se comparte entre todos los estudiantes**. Para que un solo teléfono no la agote:

- En la página de **AI Logic → Configuración**, o en Google Cloud Console → **APIs y servicios → Firebase AI Logic API → Cuotas y límites del sistema**, reduce el límite de solicitudes **por minuto y por usuario** (por ejemplo, a 10).
- Las cuotas gratuitas vigentes de cada modelo se consultan en <https://aistudio.google.com/rate-limit>.

### Restringir la clave de API de Firebase

Los archivos de configuración contienen una clave de API de Firebase (identifica el proyecto; no es la clave de Gemini). Como buena práctica, restríngela: Google Cloud Console → **APIs y servicios → Credenciales** → la clave *Android key (auto created by Firebase)* → **Restricciones de aplicación: apps de Android** (paquete `co.edu.udea.visiondesc` + SHA-256 del paso 4).

## 8. Comprobar que todo funciona *(cuando la integración esté implementada)*

```powershell
flutter run --dart-define-from-file=dart_defines.json
```

- Al analizar una imagen debe llegar una descripción.
- Si Firebase no arranca, revisa que exista `google-services.json` y el plugin de Gradle (paso 3).
- Si al analizar aparece *"La app no pudo verificar su autenticidad"* (error 403), el token de depuración no está registrado o la protección contra repetición rechaza la petición (paso 6).

---

## Resumen de archivos que nunca van al repositorio

| Archivo | Lo genera |
|---|---|
| `android/app/google-services.json` | `flutterfire configure` |
| `lib/firebase_options.dart`, `firebase.json` | `flutterfire configure` |
| `dart_defines.json` | Tú (paso 5) |

Antes de cada commit, `git status` no debe mostrar ninguno de ellos.
