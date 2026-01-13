#!/usr/bin/env python3
"""
Example Python script for using Salt API
This demonstrates how to interact with Salt API from Python applications
"""

import requests
import json
import os

# Configuration
API_URL = "http://localhost:8000"
USERNAME = "salt"
PASSWORD = os.environ.get("SALT_SHARED_SECRET", "changeme_insecure_default")
AUTH_METHOD = "sharedsecret"


class SaltAPIClient:
    """Simple Salt API client"""
    
    def __init__(self, api_url, username, password, eauth="sharedsecret"):
        self.api_url = api_url
        self.username = username
        self.password = password
        self.eauth = eauth
        self.token = None
    
    def login(self):
        """Authenticate and get token"""
        response = requests.post(
            f"{self.api_url}/login",
            data={
                "username": self.username,
                "password": self.password,
                "eauth": self.eauth
            },
            verify=False  # Use verify=True with proper SSL certificates in production
        )
        response.raise_for_status()
        data = response.json()
        self.token = data["return"][0]["token"]
        return self.token
    
    def execute(self, client="local", tgt="*", fun="test.ping", arg=None):
        """Execute a Salt command"""
        if not self.token:
            raise Exception("Not authenticated. Call login() first.")
        
        payload = {
            "client": client,
            "tgt": tgt,
            "fun": fun
        }
        
        if arg:
            if isinstance(arg, list):
                payload["arg"] = arg
            else:
                payload["arg"] = [arg]
        
        response = requests.post(
            self.api_url,
            headers={"X-Auth-Token": self.token},
            data=payload,
            verify=False  # Use verify=True with proper SSL certificates in production
        )
        response.raise_for_status()
        return response.json()


def main():
    """Example usage of Salt API client"""
    print("=" * 50)
    print("Salt API Python Example")
    print("=" * 50)
    print()
    
    # Create client and login
    client = SaltAPIClient(API_URL, USERNAME, PASSWORD, AUTH_METHOD)
    
    print("1. Authenticating...")
    token = client.login()
    print(f"✓ Authenticated successfully")
    print(f"Token: {token[:20]}...")
    print()
    
    # Test ping
    print("2. Testing minion connectivity (test.ping)...")
    result = client.execute(fun="test.ping")
    print(f"Response: {json.dumps(result, indent=2)}")
    print()
    
    # Get OS information
    print("3. Getting minion OS information...")
    result = client.execute(
        fun="grains.item",
        arg=["os", "osrelease", "osfinger"]
    )
    print(f"Response: {json.dumps(result, indent=2)}")
    print()
    
    # Run a command
    print("4. Running shell command (cmd.run)...")
    result = client.execute(
        fun="cmd.run",
        arg=["uname -a"]
    )
    print(f"Response: {json.dumps(result, indent=2)}")
    print()
    
    print("=" * 50)
    print("Example complete!")
    print("=" * 50)
    print()
    print("You can extend this client for your automation needs.")
    print("See Salt API documentation for more functions:")
    print("https://docs.saltproject.io/en/latest/ref/netapi/all/salt.netapi.rest_cherrypy.html")


if __name__ == "__main__":
    # Suppress SSL warnings (remove in production with proper certificates)
    import urllib3
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    
    try:
        main()
    except Exception as e:
        print(f"ERROR: {e}")
        exit(1)
