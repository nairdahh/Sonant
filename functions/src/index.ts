// functions/src/index.ts - Firebase Functions v2 API cu dotenv
import * as dotenv from "dotenv";

// ✅ Încarcă .env pentru emulator
if (process.env.FUNCTIONS_EMULATOR === "true") {
  dotenv.config();
  console.log("🔧 Loaded .env for emulator");
}

import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import * as admin from "firebase-admin";
import {
  PollyClient,
  SynthesizeSpeechCommand,
  OutputFormat,
  Engine,
  VoiceId,
  TextType,
} from "@aws-sdk/client-polly";

// Setări globale pentru toate Functions
setGlobalOptions({
  maxInstances: 10,
  timeoutSeconds: 300,
  memory: "512MiB",
  region: "us-central1",
  // Note: CORS se setează per-function în onCall options
});

// Inițializare Firebase Admin
admin.initializeApp();

// AWS Polly Client
const getPollyClient = () => {
  // Pentru emulator, folosim .env
  // Pentru production, folosim Firebase Secrets (automat în process.env)
  const config = process.env;

  console.log("🔍 AWS Config Check:");
  console.log(
    "   Environment:",
    process.env.FUNCTIONS_EMULATOR ? "Emulator" : "Production"
  );
  console.log(
    "   AWS_ACCESS_KEY_ID:",
    config.AWS_ACCESS_KEY_ID
      ? `✅ ${config.AWS_ACCESS_KEY_ID.substring(0, 8)}...`
      : "❌ Missing"
  );
  console.log(
    "   AWS_SECRET_ACCESS_KEY:",
    config.AWS_SECRET_ACCESS_KEY ? "✅ Present" : "❌ Missing"
  );
  console.log(
    "   AWS_REGION:",
    config.AWS_REGION || "❌ Missing (using default: us-east-1)"
  );

  if (!config.AWS_ACCESS_KEY_ID || !config.AWS_SECRET_ACCESS_KEY) {
    throw new Error("AWS credentials not configured!");
  }

  return new PollyClient({
    region: config.AWS_REGION || "us-east-1",
    credentials: {
      accessKeyId: config.AWS_ACCESS_KEY_ID,
      secretAccessKey: config.AWS_SECRET_ACCESS_KEY,
    },
  });
};

// 🎯 FUNCTION 1: Generare Audio + Speech Marks
export const synthesizeSpeech = onCall(
  {
    cors: [
      /http:\/\/localhost(:\d+)?/,
      /http:\/\/127\.0\.0\.1(:\d+)?/,
      "https://sonant-c81f1.web.app",
      "https://sonant-c81f1.firebaseapp.com",
    ],
  },
  async (request) => {
    // ✅ Verificare autentificare
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    // ✅ Validare input
    const { text, voiceId = "Joanna", engine = "neural" } = request.data;

    if (!text || typeof text !== "string") {
      throw new HttpsError(
        "invalid-argument",
        "Text is required and must be a string"
      );
    }

    if (text.length > 3000) {
      throw new HttpsError(
        "invalid-argument",
        "Text too long (max 3000 characters)"
      );
    }

    try {
      const pollyClient = getPollyClient();

      console.log(`🎵 Synthesizing speech for user ${request.auth.uid}`);
      console.log(`   Text length: ${text.length} chars`);
      console.log(`   Voice: ${voiceId}`);

      // 🎵 Step 1: Generare Speech Marks (pentru word highlighting)
      const speechMarksCommand = new SynthesizeSpeechCommand({
        Text: text,
        OutputFormat: OutputFormat.JSON,
        VoiceId: voiceId as VoiceId,
        Engine: engine as Engine,
        SpeechMarkTypes: ["word"],
        TextType: TextType.TEXT,
      });

      const speechMarksResponse = await pollyClient.send(speechMarksCommand);

      // Convertim stream în text
      const speechMarksData = await streamToString(
        speechMarksResponse.AudioStream
      );
      const speechMarks = speechMarksData
        .split("\n")
        .filter((line) => line.trim())
        .map((line) => JSON.parse(line));

      console.log(`   ✅ Speech marks: ${speechMarks.length} words`);

      // 🎵 Step 2: Generare Audio MP3
      const audioCommand = new SynthesizeSpeechCommand({
        Text: text,
        OutputFormat: OutputFormat.MP3,
        VoiceId: voiceId as VoiceId,
        Engine: engine as Engine,
        TextType: TextType.TEXT,
      });

      const audioResponse = await pollyClient.send(audioCommand);

      // Convertim stream în Base64
      const audioBuffer = await streamToBuffer(audioResponse.AudioStream);
      const audioBase64 = audioBuffer.toString("base64");

      console.log(`   ✅ Audio generated: ${audioBuffer.length} bytes`);

      // 📊 Log usage pentru monitoring
      //  await admin.firestore().collection("usage_logs").add({
      //    userId: request.auth.uid,
      //    action: "synthesize_speech",
      //    textLength: text.length,
      //    voiceId,
      //    timestamp: admin.firestore.FieldValue.serverTimestamp(),
      //  });

      return {
        audioUrl: `data:audio/mpeg;base64,${audioBase64}`,
        speechMarks,
        duration: audioResponse.RequestCharacters,
      };
    } catch (error: any) {
      console.error("❌ Polly error:", error);
      throw new HttpsError(
        "internal",
        `Failed to synthesize speech: ${error.message}`
      );
    }
  }
);

// 🎯 FUNCTION 2: Lista vocilor disponibile
export const listVoices = onCall(
  {
    cors: [
      /http:\/\/localhost(:\d+)?/,
      /http:\/\/127\.0\.0\.1(:\d+)?/,
      "https://sonant-c81f1.web.app",
      "https://sonant-c81f1.firebaseapp.com",
    ],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    try {
      // Lista statică de voci (pentru a evita apeluri inutile la AWS)
      const voices = [
        { id: "Joanna", language: "en-US", gender: "Female", engine: "neural" },
        { id: "Matthew", language: "en-US", gender: "Male", engine: "neural" },
        { id: "Ivy", language: "en-US", gender: "Female", engine: "neural" },
        { id: "Justin", language: "en-US", gender: "Male", engine: "neural" },
        { id: "Kendra", language: "en-US", gender: "Female", engine: "neural" },
        {
          id: "Kimberly",
          language: "en-US",
          gender: "Female",
          engine: "neural",
        },
        { id: "Salli", language: "en-US", gender: "Female", engine: "neural" },
        { id: "Joey", language: "en-US", gender: "Male", engine: "neural" },
        { id: "Amy", language: "en-GB", gender: "Female", engine: "neural" },
        { id: "Emma", language: "en-GB", gender: "Female", engine: "neural" },
        { id: "Brian", language: "en-GB", gender: "Male", engine: "neural" },
      ];

      return { voices };
    } catch (error: any) {
      console.error("❌ List voices error:", error);
      throw new HttpsError(
        "internal",
        `Failed to list voices: ${error.message}`
      );
    }
  }
);

// 🛠️ Helper: Stream to String
async function streamToString(stream: any): Promise<string> {
  const chunks: Buffer[] = [];
  return new Promise((resolve, reject) => {
    stream.on("data", (chunk: Buffer) => chunks.push(chunk));
    stream.on("error", reject);
    stream.on("end", () => resolve(Buffer.concat(chunks).toString("utf-8")));
  });
}

// 🛠️ Helper: Stream to Buffer
async function streamToBuffer(stream: any): Promise<Buffer> {
  const chunks: Buffer[] = [];
  return new Promise((resolve, reject) => {
    stream.on("data", (chunk: Buffer) => chunks.push(chunk));
    stream.on("error", reject);
    stream.on("end", () => resolve(Buffer.concat(chunks)));
  });
}
