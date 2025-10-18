// functions/src/index.ts - Firebase Functions v2 with Environment Variables
import * as dotenv from "dotenv";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { setGlobalOptions } from "firebase-functions/v2";
import * as admin from "firebase-admin";
import {
  PollyClient,
  SynthesizeSpeechCommand,
  DescribeVoicesCommand,
  OutputFormat,
  Engine,
  VoiceId,
  TextType,
} from "@aws-sdk/client-polly";
import { Readable } from "stream";

// ✅ Încarcă .env DOAR pentru emulator
if (process.env.FUNCTIONS_EMULATOR === "true") {
  dotenv.config();
  console.log("🔧 Loaded .env for emulator");
}

// Setări globale pentru toate Functions
setGlobalOptions({
  maxInstances: 10,
  timeoutSeconds: 300,
  memory: "512MiB",
  region: "us-central1",
});

// Inițializare Firebase Admin
admin.initializeApp();

// Helper: Convert stream to string
const streamToString = async (stream: any): Promise<string> => {
  const chunks: Uint8Array[] = [];
  const readable = Readable.from(stream);

  for await (const chunk of readable) {
    chunks.push(chunk);
  }

  return Buffer.concat(chunks).toString("utf-8");
};

// Helper: Convert stream to Buffer
const streamToBuffer = async (stream: any): Promise<Buffer> => {
  const chunks: Uint8Array[] = [];
  const readable = Readable.from(stream);

  for await (const chunk of readable) {
    chunks.push(chunk);
  }

  return Buffer.concat(chunks);
};

// AWS Polly Client Factory
const getPollyClient = (): PollyClient => {
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
      "https://sonant.nairdah.me", // ✅ Domeniul tău custom
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
        .trim()
        .split("\n")
        .map((line) => JSON.parse(line));

      console.log(`   ✅ Generated ${speechMarks.length} speech marks`);

      // 🎵 Step 2: Generare Audio (MP3)
      const audioCommand = new SynthesizeSpeechCommand({
        Text: text,
        OutputFormat: OutputFormat.MP3,
        VoiceId: voiceId as VoiceId,
        Engine: engine as Engine,
        TextType: TextType.TEXT,
      });

      const audioResponse = await pollyClient.send(audioCommand);

      // Convertim stream în Buffer
      const audioBuffer = await streamToBuffer(audioResponse.AudioStream);
      const audioBase64 = audioBuffer.toString("base64");

      console.log(`   ✅ Generated audio: ${audioBuffer.length} bytes`);

      // ✅ Return rezultat
      return {
        success: true,
        audioUrl: `data:audio/mpeg;base64,${audioBase64}`, // ✅ audioUrl în loc de audioBase64
        speechMarks: speechMarks,
        voiceId: voiceId,
        engine: engine,
      };
    } catch (error: any) {
      console.error("❌ Error synthesizing speech:", error);
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
      "https://sonant.nairdah.me", // ✅ Domeniul tău custom
    ],
  },
  async (request) => {
    // ✅ Verificare autentificare
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "User must be authenticated");
    }

    try {
      const pollyClient = getPollyClient();

      console.log(`🎤 Listing voices for user ${request.auth.uid}`);

      const command = new DescribeVoicesCommand({
        Engine: "neural",
      });

      const response = await pollyClient.send(command);

      console.log(`   ✅ Found ${response.Voices?.length || 0} voices`);

      return {
        success: true,
        voices: response.Voices || [],
      };
    } catch (error: any) {
      console.error("❌ Error listing voices:", error);
      throw new HttpsError(
        "internal",
        `Failed to list voices: ${error.message}`
      );
    }
  }
);
