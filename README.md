# VisionDesc UdeA

App **Android** en Flutter que generará **descripciones accesibles del material visual de clase** (diagramas UML, ER, de flujo y de redes, mapas mentales, diapositivas, fotos de la pizarra, código y tablas) para estudiantes ciegos de Ingeniería de Sistemas que usan TalkBack.

La accesibilidad (WCAG 2.2 AA) es el requisito central de cada pantalla.

## Estado actual

**Frontend responsivo + backend local de procesamiento.** La cámara web muestra
video en vivo y envía la captura al backend para obtener una descripción de
accesibilidad en audio. También se pueden importar imágenes, PDF y PowerPoint.
El backend envía el material a Gemini y no conserva los archivos después de
procesarlos.

| Pantalla | Qué se puede probar |
|---|---|
| Inicio | 4 botones grandes |
| Capturar | Guía visible y leída por TalkBack, interruptores; "Tomar foto" abre un resultado de ejemplo |
| Importar archivo | Imagen, PDF y PowerPoint |
| Resultado | Diagrama UML de ejemplo con secciones navegables por encabezados, barra de lectura (sección anterior, leer sección, siguiente), velocidad, código línea por línea |
| Historial | Ejemplos agrupados por materia, con búsqueda que anuncia el número de resultados |
| Ajustes | Tema (claro, oscuro, alto contraste), nivel de detalle, velocidad y vibración; **se guardan** |

### Ejecutar el backend de reconocimiento

En otra terminal, configura `backend/.env` con tu clave de Google AI Studio:

```env
GEMINI_API_KEY=tu_clave_de_google_ai_studio
FRONTEND_ORIGIN=http://127.0.0.1:8080
```

Después ejecuta:

```bash
cd backend
npm install
npm start
```

El endpoint `POST /api/convertir` recibe el archivo en el campo `documento` y
devuelve audio MP3. Consulta [backend/README.md](backend/README.md) para probar
el endpoint con `curl`.

## Documentación

| Documento | Contenido |
|---|---|
| [docs/ARQUITECTURA.md](docs/ARQUITECTURA.md) | Requisitos, arquitectura limpia, stack, prompts de Gemini, errores, privacidad y registro de decisiones |
| [docs/UI.md](docs/UI.md) | Wireframes, orden de foco, etiquetas, anuncios y gestos de cada pantalla |
| [docs/FIREBASE.md](docs/FIREBASE.md) | Configuración de Firebase y Gemini, para cuando se conecte la IA |

## Probarlo en Android Studio

### 1. Preparar Android Studio (una sola vez)

1. **Plugins:** *File → Settings → Plugins* → instala **Flutter** (instala también **Dart**) y reinicia.
2. **SDK de Flutter:** *File → Settings → Languages & Frameworks → Flutter* → **Flutter SDK path**: `C:\Users\USUARIO\flutter`.
   - En *Languages & Frameworks → Dart*, el **Dart SDK path** debe ser `C:\Users\USUARIO\flutter\bin\cache\dart-sdk`, **no** `C:\dart`: en este equipo hay una instalación de Dart antigua aparte que no sirve para este proyecto.
3. **Herramientas de Android:** *Tools → SDK Manager → SDK Tools* → marca **Android SDK Command-line Tools (latest)** → *Apply*. Luego, en una terminal: `flutter doctor --android-licenses` (acepta con `y`).

### 2. Abrir y ejecutar

1. *File → Open* → elige la carpeta `visiondesc-udea`.
2. Si aparece el aviso **"Pub get has not been run"**, pulsa **Get dependencies** (o *Tools → Flutter → Flutter Pub Get*). Los textos en español (`lib/l10n`) se generan solos al compilar.
3. **Crear un emulador:** *Tools → Device Manager → +  Create Virtual Device* → un teléfono (p. ej. *Pixel 8*) → una imagen de sistema **con Google Play** (icono de Play Store; trae TalkBack) → *Finish*.
4. Elige el emulador en la barra superior, configuración **main.dart**, y pulsa **Run ▶**. La primera compilación tarda varios minutos.

> También puedes usar un teléfono real: activa *Opciones de desarrollador → Depuración por USB* y conéctalo.

### 3. Probar la accesibilidad

| Qué | Cómo |
|---|---|
| **TalkBack** | En el emulador: *Ajustes → Accesibilidad → TalkBack → Activar*. Si no aparece, actualiza **Android Accessibility Suite** en Play Store. Con el ratón: arrastrar = deslizar, doble clic = tocar dos veces. |
| Navegar por encabezados | Con TalkBack, desliza arriba o abajo para elegir **Encabezados** y luego desliza a la derecha o a la izquierda para saltar de sección (útil en Resultado e Historial). |
| Texto grande | *Ajustes → Pantalla → Tamaño de fuente* al máximo: los botones del inicio pasan a una columna sin cortarse. |
| Alto contraste | En la app: *Ajustes → Apariencia → Alto contraste*. |
| Horizontal / tablet | Gira el emulador o crea uno de tablet: el contenido se reorganiza y no supera los 720 dp de ancho. |
| Auditoría | Instala **Accessibility Scanner** (Google) desde Play Store y analiza cada pantalla. |

### 4. Tests

Clic derecho sobre la carpeta `test` → **Run 'tests in test'**, o en la terminal:

```powershell
flutter analyze
flutter test
```

Los 121 tests comprueban, en **todas las pantallas**, las guías de accesibilidad de Flutter (`androidTapTargetGuideline`, `labeledTapTargetGuideline`, `textContrastGuideline`) en los temas claro, oscuro y alto contraste, con texto al 100 % y al 200 %, además del orden de foco y de que no haya desbordamientos en teléfono ni en tablet horizontal.

## Estructura

```text
lib/
├── main.dart, app.dart     Arranque, temas, localización y anuncios accesibles
├── core/
│   ├── accessibility/      Botón accesible, encabezados, banners, valores ajustables, anuncios, vibración
│   ├── layout/             Cuerpo y cuadrícula responsivos
│   ├── theme/              Colores con contraste verificado, tipografía, medidas
│   └── router/             Rutas (go_router)
├── features/               home, capture, import, result, history, settings
└── l10n/app_es.arb         Todo el texto de la interfaz (español)
```

Solo Android: `minSdk` 24 (Android 7.0), paquete `co.edu.udea.visiondesc`.

## Seguridad

- No hay claves ni configuración de Firebase en el repositorio. Cuando se conecte la IA, `google-services.json`, `firebase_options.dart` y `dart_defines.json` ya están en `.gitignore`.
- La copia de seguridad automática de Android está desactivada (`android:allowBackup="false"`) para que el historial no salga del teléfono.
