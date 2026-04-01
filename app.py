from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route("/")
def home():
    return "Agent AI Running"

@app.route("/ai", methods=["POST"])
def ai():
    data = request.json
    
    messages = data.get("messages")
    api_key = data.get("apiKey")

    if not messages or not api_key:
        return jsonify({"error": "Missing data"})

    try:
        response = requests.post(
            "https://api.groq.com/openai/v1/chat/completions",
            headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json"
            },
            json={
                "model": "llama3-70b-8192",
                "messages": messages,
                "temperature": 0.7
            }
        )

        return jsonify(response.json())

    except Exception as e:
        return jsonify({"error": str(e)})

app.run(host="0.0.0.0", port=3000)
