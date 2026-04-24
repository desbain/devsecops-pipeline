from flask import Flask, jsonify
import os

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "status": "ok",
        "message": "DevSecOps Pipeline App",
        "version": os.getenv("APP_VERSION", "1.0.0"),
        "environment": os.getenv("APP_ENV", "production")
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/ready")
def ready():
    return jsonify({"status": "ready"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
