require("dotenv").config();

const fs = require("node:fs/promises");
const path = require("node:path");
const cors = require("cors");
const express = require("express");
const multer = require("multer");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const { GoogleAIFileManager } = require("@google/generative-ai/server");
const googleTts = require("google-tts-api");

const app = express();
const port = Number(process.env.PORT || 3000);
const uploadDirectory = path.join(__dirname, "uploads");
const maxFileSize = 20 * 1024 * 1024;
const ttsChunkSize = 200;
const processingTimeoutMs = 45_000;
const geminiRetries = 2;
const modelName = process.env.GEMINI_MODEL || "gemini-flash-lite-latest";
const accessibilityPrompt =
  "Actúa como un intérprete de accesibilidad. Transcribe el texto de este documento de forma fluida. Si hay imágenes, tablas o gráficas, explícalas descriptivamente. Entrega solo el texto final, sin formato Markdown, sin asteriscos y sin caracteres especiales, listo para ser leído por un motor de voz.";

const apiKey = process.env.GEMINI_API_KEY;

if (!apiKey) {
  throw new Error("Falta la variable de entorno GEMINI_API_KEY.");
}

const allowedOrigins = (process.env.FRONTEND_ORIGIN || "*")
  .split(",")
  .map((origin) => origin.trim());

app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || allowedOrigins.includes("*") || allowedOrigins.includes(origin)) {
        return callback(null, true);
      }

      return callback(new Error("Origen no permitido por CORS."));
    },
  }),
);
app.use(express.json({ limit: "1mb" }));

const upload = multer({
  dest: uploadDirectory,
  limits: { fileSize: maxFileSize, files: 1 },
  fileFilter: (_request, file, callback) => {
    const allowedMimeTypes = new Set([
      "application/pdf",
      "application/vnd.openxmlformats-officedocument.presentationml.presentation",
      "image/jpeg",
      "image/png",
      "image/webp",
    ]);

    if (!allowedMimeTypes.has(file.mimetype)) {
      return callback(new Error("Solo se aceptan imágenes, PDF o PowerPoint."));
    }

    callback(null, true);
  },
});

const fileManager = new GoogleAIFileManager(apiKey);
const generativeAI = new GoogleGenerativeAI(apiKey);
const model = generativeAI.getGenerativeModel({ model: modelName });

function splitText(text, maxLength) {
  const normalizedText = text.replace(/\s+/g, " ").trim();
  const chunks = [];

  for (let start = 0; start < normalizedText.length; start += maxLength) {
    chunks.push(normalizedText.slice(start, start + maxLength));
  }

  return chunks;
}

async function textToMp3(text) {
  const chunks = splitText(text, ttsChunkSize);
  const audioChunks = await Promise.all(
    chunks.map(async (chunk) => {
      const base64Audio = await googleTts.getAudioBase64(chunk, {
        lang: "es",
        slow: false,
        host: "https://translate.google.com",
      });

      return Buffer.from(base64Audio, "base64");
    }),
  );

  return Buffer.concat(audioChunks);
}

function withTimeout(promise, timeoutMs, message) {
  let timeoutId;
  const timeout = new Promise((_, reject) => {
    timeoutId = setTimeout(() => reject(new Error(message)), timeoutMs);
  });

  return Promise.race([promise, timeout]).finally(() => clearTimeout(timeoutId));
}

async function generateDescription(fileUri, mimeType) {
  for (let attempt = 0; attempt <= geminiRetries; attempt += 1) {
    try {
      return await withTimeout(
        model.generateContent([
          { fileData: { mimeType, fileUri } },
          accessibilityPrompt,
        ]),
        processingTimeoutMs,
        "Gemini tardó demasiado en responder.",
      );
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const isTemporary = message.includes("[503 ") || message.includes("high demand");
      if (!isTemporary || attempt === geminiRetries) throw error;

      await new Promise((resolve) => setTimeout(resolve, 2_000 * (attempt + 1)));
    }
  }
}

async function generateImageDescription(filePath, mimeType) {
  const imageData = (await fs.readFile(filePath)).toString("base64");

  for (let attempt = 0; attempt <= geminiRetries; attempt += 1) {
    try {
      return await withTimeout(
        model.generateContent([
          {
            inlineData: {
              mimeType,
              data: imageData,
            },
          },
          accessibilityPrompt,
        ]),
        processingTimeoutMs,
        "Gemini tardó demasiado en responder.",
      );
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error);
      const isTemporary = message.includes("[503 ") || message.includes("high demand");
      if (!isTemporary || attempt === geminiRetries) throw error;

      await new Promise((resolve) => setTimeout(resolve, 2_000 * (attempt + 1)));
    }
  }
}

app.get("/api/health", (_request, response) => {
  response.json({ ok: true });
});

app.post("/api/convertir", upload.single("documento"), async (request, response) => {
  if (!request.file) {
    return response.status(400).json({
      error: "Debes enviar una imagen, PDF o PowerPoint en el campo documento.",
    });
  }

  let uploadedGeminiFile;

  try {
    let result;
    if (request.file.mimetype.startsWith("image/")) {
      result = await generateImageDescription(
        request.file.path,
        request.file.mimetype,
      );
    } else {
      const uploadResult = await fileManager.uploadFile(request.file.path, {
        mimeType: request.file.mimetype,
        displayName: request.file.originalname,
      });
      uploadedGeminiFile = uploadResult.file;
      result = await generateDescription(
        uploadedGeminiFile.uri,
        uploadedGeminiFile.mimeType,
      );
    }
    const text = result.response.text().trim();

    if (!text) {
      throw new Error("Gemini no devolvió texto para convertir.");
    }

    const audioBuffer = await withTimeout(
      textToMp3(text),
      processingTimeoutMs,
      "La conversión de texto a audio tardó demasiado.",
    );
    response.setHeader("Content-Type", "audio/mpeg");
    response.setHeader("Content-Disposition", 'inline; filename="visiondesc.mp3"');
    response.setHeader("Cache-Control", "no-store");
    return response.send(audioBuffer);
  } catch (error) {
    console.error("Error procesando el documento:", error);
    return response.status(502).json({
      error: "No fue posible procesar el documento.",
      detail: error instanceof Error ? error.message : "Error desconocido.",
    });
  } finally {
    if (uploadedGeminiFile?.name) {
      try {
        await fileManager.deleteFile(uploadedGeminiFile.name);
      } catch (error) {
        console.error("No fue posible borrar el archivo de Gemini:", error);
      }
    }

    try {
      await fs.unlink(request.file.path);
    } catch (error) {
      if (error.code !== "ENOENT") {
        console.error("No fue posible borrar el archivo temporal:", error);
      }
    }
  }
});

app.use((error, _request, response, _next) => {
  if (error instanceof multer.MulterError && error.code === "LIMIT_FILE_SIZE") {
    return response.status(413).json({
      error: "El archivo supera el límite de 20 MB.",
    });
  }

  if (error.message === "Solo se aceptan imágenes, PDF o PowerPoint.") {
    return response.status(415).json({ error: error.message });
  }

  console.error("Error inesperado del servidor:", error);
  return response.status(500).json({ error: "Error interno del servidor." });
});

async function startServer() {
  await fs.mkdir(uploadDirectory, { recursive: true });
  app.listen(port, () => {
    console.log(`VisionDesc backend escuchando en http://localhost:${port}`);
  });
}

startServer().catch((error) => {
  console.error("No fue posible iniciar el servidor:", error);
  process.exitCode = 1;
});
