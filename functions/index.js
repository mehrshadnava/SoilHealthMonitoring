const functions = require("firebase-functions");
const express = require("express");
const cors = require("cors");
const axios = require("axios");

const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());


// Helper function to call Gemini AI
async function callGemini(prompt) {
  try {
    // MOVED FROM GLOBAL SCOPE: Access the API key only when the function is called.
    const GEMINI_API_KEY = functions.config().gemini.key;
    if (!GEMINI_API_KEY) {
        throw new Error("Gemini API Key is not configured. Run 'firebase functions:config:set gemini.key=...'");
    }
    const GEMINI_ENDPOINT = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GEMINI_API_KEY}`;
    
    const body = {
      contents: [{
        parts: [{
          text: prompt,
        }],
      }],
      generationConfig: {
        temperature: 0.5,
        maxOutputTokens: 1024,
      },
    };

    const response = await axios.post(GEMINI_ENDPOINT, body, {
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const generatedText = response.data?.candidates?.[0]?.content?.parts?.[0]?.text;

    if (!generatedText) {
      throw new Error('No generated text received from Gemini');
    }

    return generatedText;
  } catch (error) {
    console.error('Error calling Gemini:', error.response ? error.response.data : error.message);
    throw error;
  }
}

// POST /generateReport endpoint
app.post('/generateReport', async (req, res) => {
  try {
    const { current_reading, historical_average_30_days, crop_context } = req.body;

    if (!current_reading || !crop_context) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: current_reading and crop_context are required',
      });
    }

    const prompt = `Analyze the following soil health data for a ${crop_context} farm and generate a professional soil health report.
    Role: You are an expert agronomist.
    Format: Respond in a structured JSON format ONLY, with these exact keys: "soil_quality_status", "fertility_index_score", "key_observations", "crop_suitability_analysis", and "warnings".
    Data for Analysis:
    - Current Sensor Reading: ${JSON.stringify(current_reading)}
    - 30-Day Historical Average: ${JSON.stringify(historical_average_30_days || {})}
    - Intended Crop: ${crop_context}
    Instructions for Analysis:
    1. soil_quality_status: Give a one-word status: "Excellent", "Good", "Moderate", "Poor", or "Critical".
    2. fertility_index_score: Provide a score from 0 to 100.
    3. key_observations: Provide a bullet-point list of the most important findings in a single string with '\\n' for new lines.
    4. crop_suitability_analysis: Based on the data, analyze if the soil is suitable for growing ${crop_context}.
    5. warnings: List any critical issues or state "No critical warnings."
    Return raw JSON ONLY with no markdown formatting.`;

    const modelOutput = await callGemini(prompt);
    
    const cleanedOutput = modelOutput.replace(/```json|```/g, "").trim();
    const parsedJson = JSON.parse(cleanedOutput);

    return res.status(200).json({
      success: true,
      data: parsedJson,
    });

  } catch (err) {
    // eslint-disable-next-line no-console
    console.error('Error in generateReport:', err);
    return res.status(500).json({
      success: false,
      error: err.message,
    });
  }
});

// POST /generateRecommendation endpoint
app.post('/generateRecommendation', async (req, res) => {
    try {
        const { current_reading, crop_context } = req.body;

        if (!current_reading || !crop_context) {
            return res.status(400).json({
                success: false,
                error: 'Missing required fields: current_reading and crop_context are required'
            });
        }

        const prompt = `Based on the following soil data for a ${crop_context} farm, act as an expert agronomist and generate a detailed, actionable soil improvement plan.
        Format: JSON with the following exact keys: "identified_deficiencies", "fertilizer_recommendations", "step_by_step_guide".
        Data:
        Current Sensor Reading: ${JSON.stringify(current_reading)}
        Instructions:
        - identified_deficiencies: array of strings with parameter and status
        - fertilizer_recommendations: array of objects with {name, purpose, application_rate_kg_per_hectare}
        - step_by_step_guide: array of numbered steps as strings
        Return JSON ONLY.`;

        const modelOutput = await callGemini(prompt);
        const cleanedOutput = modelOutput.replace(/```json|```/g, "").trim();
        const parsedJson = JSON.parse(cleanedOutput);

        return res.status(200).json({
            success: true,
            data: parsedJson
        });
    } catch (err) {
        // eslint-disable-next-line no-console
        console.error('Error in generateRecommendation:', err);
        return res.status(500).json({
            success: false,
            error: err.message
        });
    }
});


// ** IMPORTANT **
// REMOVED the app.listen() block. Firebase handles this automatically.

// Export the Express app as a single Firebase Cloud Function named 'api'.
exports.api = functions.https.onRequest(app);