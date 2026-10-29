# Backend de VisionDesc

Servidor Express que recibe un PDF, lo procesa con Gemini File API, convierte la
descripción a MP3 y la devuelve directamente al frontend. El archivo temporal
local y el archivo remoto de Gemini se eliminan al terminar cada petición.

## Requisitos

- Node.js 18 o superior.
- Una API key de Google AI Studio con acceso a Gemini.

## Instalación y ejecución

```bash
cd backend
cp .env.example .env
# Edita .env y define GEMINI_API_KEY
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

## Endpoint

```bash
curl -X POST http://localhost:3000/api/convertir \
  -F "documento=@./documento.pdf" \
  --output resultado.mp3
```

El campo multipart debe llamarse `documento` y contener una imagen, PDF o PPTX. El endpoint
responde `audio/mpeg`. Los errores se devuelven como JSON.

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
