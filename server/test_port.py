import requests
import sys

print("--- GODZ AI PORT DIAGNOSTIC ---")
try:
    print("Testing connection to http://127.0.0.1:5000/health ...")
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
