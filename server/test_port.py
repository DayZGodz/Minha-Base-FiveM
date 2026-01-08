import requests
import sys
import os

print("--- GODZ AI PORT DIAGNOSTIC ---")

# 1. Verify Voice Models
print("Checking Voice Models...")
PIPER_MODELS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "piper_models")
PIPER_MODEL_NAME = "pt_BR-thalita-medium.onnx"
PIPER_MODEL_PATH = os.path.join(PIPER_MODELS_DIR, PIPER_MODEL_NAME)

if os.path.exists(PIPER_MODEL_PATH):
    size = os.path.getsize(PIPER_MODEL_PATH)
    if size > 1000:
        print(f"✅ Voice Model Found: {PIPER_MODEL_NAME} ({size/1024/1024:.2f} MB)")
    else:
        print(f"⚠️ Voice Model Found but too small ({size} bytes). Download might have failed.")
else:
    print(f"❌ Voice Model NOT FOUND at: {PIPER_MODEL_PATH}")
    print("   The bridge script should download it automatically on startup.")

# 2. Verify Port
try:
    print("\nTesting connection to http://127.0.0.1:5000/health ...")
    response = requests.get('http://127.0.0.1:5000/health', timeout=5)
    
    if response.status_code == 200:
        print(f"✅ SUCCESS! Port 5000 is OPEN.")
        print(f"Response: {response.json()}")
        sys.exit(0)
    else:
        print(f"⚠️ WARNING! Port 5000 returned status {response.status_code}")
        print(f"Response: {response.text}")
        sys.exit(1)

except requests.exceptions.ConnectionError:
    print("❌ ERROR: Connection Refused. The server is likely NOT running or Firewall is blocking.")
    print("Ensure 'godz_ai_bridge.py' is running in a separate terminal.")
    sys.exit(1)
except Exception as e:
    print(f"❌ ERROR: Unexpected exception: {e}")
    sys.exit(1)
