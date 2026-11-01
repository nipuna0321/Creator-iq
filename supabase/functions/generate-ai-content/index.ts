// =============================================================================
// Supabase Edge Function: generate-ai-content
// Purpose: Authenticated Gemini AI co-pilot for CreateIQ content creators.
// Secrets required in Supabase dashboard:
//   GEMINI_API_KEY: Your Google Gemini API Key
// =============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface RequestPayload {
  action: "generate" | "chat" | "insights";
  // For 'generate':
  type?: "postIdea" | "caption" | "hashtags" | "calendar";
  topic?: string;
  tone?: string;
  niche?: string;
  // For 'chat':
  message?: string;
  summary?: any;
  answers?: any;
  lastPost?: any;
}

serve(async (req: Request) => {
  // 1. Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");

    // 2. Validate user authentication via Supabase JWT
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing Authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (supabaseUrl && supabaseAnonKey) {
      const supabase = createClient(supabaseUrl, supabaseAnonKey, {
        global: { headers: { Authorization: authHeader } },
      });
      const { data: { user }, error: authError } = await supabase.auth.getUser();
      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: "Invalid or expired session token", details: authError?.message }),
          { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }
    }

    const payload: RequestPayload = await req.json();
    const { action } = payload;

    if (!geminiApiKey) {
      return new Response(
        JSON.stringify({
          error: "GEMINI_API_KEY secret is not set in Supabase Edge Functions.",
          hint: "Run: supabase secrets set GEMINI_API_KEY=your_key",
        }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 3. Process actions
    if (action === "generate") {
      const { type = "postIdea", topic = "general", tone = "Casual", niche = "Creator" } = payload;
      const prompt = buildGeneratePrompt(type, topic, tone, niche);
      const geminiResponseText = await callGemini(geminiApiKey, prompt);
      const parsedItems = extractJsonArray(geminiResponseText, type);

      return new Response(
        JSON.stringify({ success: true, ideas: parsedItems }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (action === "chat") {
      const { message = "", summary = {}, answers = {}, lastPost = null } = payload;
      const prompt = buildChatPrompt(message, summary, answers, lastPost);
      const reply = await callGemini(geminiApiKey, prompt);

      return new Response(
        JSON.stringify({ success: true, reply }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (action === "insights") {
      const { summary = {}, answers = {} } = payload;
      const prompt = buildInsightsPrompt(summary, answers);
      const responseText = await callGemini(geminiApiKey, prompt);
      const parsedReport = extractJsonObject(responseText);

      return new Response(
        JSON.stringify({ success: true, report: parsedReport }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ error: `Unknown action: ${action}` }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});

// Helper: Call Gemini 1.5 Flash via REST
async function callGemini(apiKey: string, prompt: string): Promise<string> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`;

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts: [{ text: prompt }] }],
      generationConfig: {
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      },
    }),
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`Gemini API error (${response.status}): ${errorBody}`);
  }

  const result = await response.json();
  const text = result.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) {
    throw new Error("No text returned by Gemini");
  }
  return text.trim();
}

// Prompt builders
function buildGeneratePrompt(type: string, topic: string, tone: string, niche: string): string {
  return `You are CreateIQ's expert social media strategist and copywriter.
Niche: ${niche}
Topic: ${topic}
Tone: ${tone}
Requested format: ${type} (Options: postIdea, caption, hashtags, calendar)

Instructions:
Generate high-converting creator content in strict JSON format.
Output ONLY a valid JSON array of objects without Markdown code fences, conforming to this schema:

[
  {
    "id": "unique_string_id",
    "type": "${type}",
    "title": "Short punchy title",
    "body": "Full body text or hook description",
    "tags": ["tag1", "tag2"],
    "weekday": 0, // only for calendar: 0 for Mon to 6 for Sun, otherwise null
    "suggestedTime": "6:00 PM" // only for calendar, otherwise null
  }
]

For postIdea: Return 4 diverse, creative post concepts (Reels, Carousels, Stories) with hooks and key takeaways.
For caption: Return 3 viral-ready captions with hooks, value, and strong calls-to-action (CTAs).
For hashtags: Return 3 sets ("Broad reach", "Niche targeted", "Engagement boosters") with 8-10 targeted tags each.
For calendar: Return exactly 7 items (one for each day Monday to Sunday, weekday 0 to 6) with realistic posting times.`;
}

function buildChatPrompt(message: string, summary: any, answers: any, lastPost: any): string {
  return `You are CreateIQ's friendly, data-driven AI creator assistant.
The creator is asking: "${message}"

Here is the creator's current performance profile and analytics:
- Niche: ${answers?.niche || "General"}
- Goal: ${answers?.goal || "Grow engagement"}
- Target Audience: ${answers?.ageRange || "General"}
- Target Frequency: ${answers?.postsPerWeek || 4} posts/week
- Total Posts Analyzed: ${summary?.postCount || 0}
- Engagement Rate: ${summary?.engagementRate?.toFixed?.(2) || "3.5"}%
- Best Posting Day: Day index ${summary?.bestWeekday ?? 2}
- Best Posting Hour: ${summary?.bestHour ?? 18}:00
- Recent Post: ${lastPost ? `"${lastPost.caption}" (${lastPost.platform}, ${lastPost.type}, ${lastPost.likes} likes, ${lastPost.comments} comments)` : "None"}

Instructions:
Provide a concise, encouraging, and highly actionable response formatted with clean markdown bullets and emojis. Directly reference their analytics when relevant.`;
}

function buildInsightsPrompt(summary: any, answers: any): string {
  return `You are CreateIQ's growth analytics evaluator.
Analyze this creator profile:
- Niche: ${answers?.niche || "General"}
- Posts Count: ${summary?.postCount || 0}
- Engagement Rate: ${summary?.engagementRate?.toFixed?.(2) || "3.5"}%
- Period Growth Score: ${summary?.growthScore || 65}/100

Output ONLY a valid JSON object matching this schema:
{
  "headline": "Punchy trajectory headline with emoji",
  "summary": "2-3 sentence performance summary",
  "strengths": ["Strength 1", "Strength 2", "Strength 3"],
  "weaknesses": ["Area for improvement 1", "Area for improvement 2"],
  "recommendations": ["Actionable step 1", "Actionable step 2", "Actionable step 3"]
}`;
}

// JSON extraction helpers
function extractJsonArray(rawText: string, type: string): any[] {
  let cleaned = rawText.trim();
  if (cleaned.startsWith("```json")) cleaned = cleaned.slice(7);
  if (cleaned.startsWith("```")) cleaned = cleaned.slice(3);
  if (cleaned.endsWith("```")) cleaned = cleaned.slice(0, -3);
  cleaned = cleaned.trim();

  try {
    const parsed = JSON.parse(cleaned);
    if (Array.isArray(parsed)) {
      return parsed.map((item, idx) => ({
        id: item.id || `${Date.now()}_${idx}`,
        type: item.type || type,
        title: item.title || "Content Suggestion",
        body: item.body || "",
        tags: Array.isArray(item.tags) ? item.tags : [],
        weekday: item.weekday ?? null,
        suggestedTime: item.suggestedTime ?? null,
        createdAt: new Date().toISOString(),
      }));
    }
  } catch (_) {
    // Return empty array to trigger client fallback
  }
  return [];
}

function extractJsonObject(rawText: string): any {
  let cleaned = rawText.trim();
  if (cleaned.startsWith("```json")) cleaned = cleaned.slice(7);
  if (cleaned.startsWith("```")) cleaned = cleaned.slice(3);
  if (cleaned.endsWith("```")) cleaned = cleaned.slice(0, -3);
  cleaned = cleaned.trim();

  try {
    return JSON.parse(cleaned);
  } catch (_) {
    return {
      headline: "Solid foundation with room to grow 📈",
      summary: "Analytics indicate consistent engagement with opportunities to optimize format mix.",
      strengths: ["Consistent post frequency", "Strong engagement on video content"],
      weaknesses: ["Underutilized comment prompts", "Posting outside peak audience hours"],
      recommendations: ["Shift key posts to your peak engagement hours", "Incorporate direct CTAs to drive replies"],
    };
  }
}

