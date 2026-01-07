import os
import urllib.request
import zipfile
import shutil
import sys
import re

# Constants
ARTIFACTS_URL = "https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/"
ARTIFACTS_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "artifacts"))
ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))

def log(message):
    print(f"[GODZ UPDATER] {message}")

def get_recommended_link():
    log("Fetching artifacts list...")
    try:
        with urllib.request.urlopen(ARTIFACTS_URL) as response:
            html = response.read().decode('utf-8')
            
        # Find the RECOMMENDED link
        # Look for the structure that denotes recommended
        # Typically: <a class="panel-block is-active" ... href="./.../server.zip"> ... <span>...</span> ... <span class="tag is-success">RECOMMENDED</span> ... </a>
        # Or just search for the link that contains "RECOMMENDED" nearby or is marked.
        
        # Simple regex to find the link associated with "RECOMMENDED"
        # The HTML structure usually puts the link and the tag close.
        # We look for a link that ends in /server.zip and has "RECOMMENDED" after it in the source?
        # Actually, the RECOMMENDED tag is usually inside the <a> tag.
        
        # Example: <a href="./5848-4f71128ee48b07026d6d7229a60ebc5f40f2b9db/server.zip" ...> ... RECOMMENDED ... </a>
        
        # Let's try to split by 'RECOMMENDED' and look backwards for 'href="./'
        if "RECOMMENDED" not in html:
            log("No RECOMMENDED tag found. Defaulting to latest.")
            # Fallback to first link
            # match = re.search(r'href="\./(.*?/server\.zip)"', html)
            # if match:
            #     return ARTIFACTS_URL + match.group(1)
            return None

        # Extract the segment before "RECOMMENDED"
        pre_recommended = html.split("RECOMMENDED")[0]
        # Find the last href
        match = re.search(r'href="\./(.*?/server\.zip)"', pre_recommended.split('<a')[-1])
        
        if match:
            return ARTIFACTS_URL + match.group(1)
        else:
            log("Could not parse RECOMMENDED link.")
            return None
            
    except Exception as e:
        log(f"Error fetching URL: {e}")
        return None

def download_and_extract(url):
    if not url:
        log("Invalid URL.")
        return

    log(f"Downloading from {url}...")
    zip_path = os.path.join(ROOT_DIR, "server.zip")
    
    try:
        # Download
        with urllib.request.urlopen(url) as response, open(zip_path, 'wb') as out_file:
            shutil.copyfileobj(response, out_file)
        
        log("Download complete. Extracting...")
        
        # Ensure artifacts dir exists
        if not os.path.exists(ARTIFACTS_DIR):
            os.makedirs(ARTIFACTS_DIR)
            
        # Extract
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(ARTIFACTS_DIR)
            
        log("Extraction complete.")
        
        # Cleanup
        os.remove(zip_path)
        log("Cleanup complete.")
        
    except Exception as e:
        log(f"Error during download/extraction: {e}")

def main():
    log("Starting update process...")
    log(f"Artifacts directory: {ARTIFACTS_DIR}")
    
    # check if artifacts folder is empty or force update?
    # For now, just try to get recommended.
    
    url = get_recommended_link()
    if url:
        log(f"Found recommended version: {url}")
        # Only download if we want to force update or if check fails.
        # For this task, we download.
        download_and_extract(url)
    else:
        log("Could not find recommended version.")

if __name__ == "__main__":
    main()
