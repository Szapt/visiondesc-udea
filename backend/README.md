# Backend de VisionDesc

Servidor Express que recibe un PDF, lo procesa con Gemini File API, convierte la
descripción a MP3 y la devuelve directamente al frontend. El archivo temporal
local y el archivo remoto de Gemini se eliminan al terminar cada petición.

## Requisitos

- Node.js 22 o superior.
- Una API key de Google AI Studio con acceso a Gemini.
- Un proyecto de Supabase con la tabla `audios` (para el historial).

## Instalación y ejecución

```bash
cd backend
cp .env.example .env
# Edita .env y define GEMINI_API_KEY, SUPABASE_URL y SUPABASE_KEY
npm install
npm start
```

El servidor queda disponible en `http://localhost:3000`.

Variables opcionales:

- `PORT`: puerto del servidor, por defecto `3000`.
- `GEMINI_MODEL`: modelo de Gemini, por defecto `gemini-flash-lite-latest`.
- `FRONTEND_ORIGIN`: origen permitido por CORS. Puede ser una lista separada por
  comas; por defecto es `*`. Para el frontend local:
  `http://127.0.0.1:8080,http://localhost:8080`.

## Historial (Supabase)

Cada conversión exitosa se guarda en la tabla `audios`:

| Columna  | Tipo        | Contenido                                        |
| -------- | ----------- | ------------------------------------------------ |
| `id`     | int8        | Identity (autoincremental)                       |
| `creado` | timestamptz | Fecha de la consulta                             |
| `audio`  | text        | Descripción generada por Gemini                  |

Se guarda el texto y no el MP3: ocupa mucho menos y el audio se vuelve a
generar al escucharlo. Variables:

- `SUPABASE_URL`: URL del proyecto, `https://<ref>.supabase.co`
  (Project Settings → Data API). No es el host `db.<ref>.supabase.co`.
- `SUPABASE_KEY`: clave **secreta** (`sb_secret_…` o `service_role`), de
  Project Settings → API Keys. Solo vive en el backend; con ella no hace falta
  configurar políticas RLS.

Si faltan, el servidor sigue convirtiendo documentos y el historial responde
`503`.

## Endpoints

```bash
curl -X POST http://localhost:3000/api/convertir \
  -F "documento=@./documento.pdf" \
  --output resultado.mp3
```

El campo multipart debe llamarse `documento` y contener una imagen, PDF o PPTX. El endpoint
responde `audio/mpeg`. Los errores se devuelven como JSON.

```bash
# Lista del historial, de la consulta más reciente a la más antigua
curl http://localhost:3000/api/historial
# [{ "id": 3, "creado": "2026-10-29T14:00:00+00:00", "descripcion": "..." }]

# MP3 de una consulta del historial
curl http://localhost:3000/api/historial/3/audio --output consulta.mp3
```

## Uso desde el frontend

```javascript
const formData = new FormData();
formData.append("documento", pdfFile);

const response = await fetch("http://localhost:3000/api/convertir", {
  method: "POST",
  body: formData,
});

if (!response.ok) {
  throw new Error((await response.json()).error);
}

const audioUrl = URL.createObjectURL(await response.blob());
new Audio(audioUrl).play();
```

La API key solo debe existir en `backend/.env`; nunca debe ponerse en el
frontend ni subirse al repositorio.
