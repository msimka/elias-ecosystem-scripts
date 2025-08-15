#!/usr/bin/env python3
"""
Telnyx API Integration Test Script for CoolGirls Platform
Tests SMS, Voice, and eSIM capabilities
"""

import os
import sys
import json
import time
import requests
from typing import Dict, Any, Optional

class TelnyxIntegrationTester:
    """Test Telnyx API integration for CoolGirls platform"""
    
    def __init__(self, api_key: str):
        """Initialize with Telnyx API key"""
        self.api_key = api_key
        self.base_url = "https://api.telnyx.com/v2"
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
    
    def test_api_connection(self) -> Dict[str, Any]:
        """Test basic API connectivity"""
        print("🔌 Testing Telnyx API connection...")
        
        try:
            response = requests.get(
                f"{self.base_url}/available_phone_numbers",
                headers=self.headers,
                params={"filter[country_code]": "US", "filter[limit]": "1"}
            )
            
            if response.status_code == 200:
                print("✅ API connection successful")
                return {"success": True, "data": response.json()}
            else:
                print(f"❌ API connection failed: {response.status_code}")
                return {"success": False, "error": response.text}
                
        except Exception as e:
            print(f"❌ Connection error: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def test_sms_capability(self, test_phone: str) -> Dict[str, Any]:
        """Test SMS sending capability"""
        print(f"📱 Testing SMS capability to {test_phone}...")
        
        # First, check if we have a messaging profile
        try:
            profiles_response = requests.get(
                f"{self.base_url}/messaging_profiles",
                headers=self.headers
            )
            
            if profiles_response.status_code != 200:
                return {"success": False, "error": "No messaging profiles found"}
            
            profiles = profiles_response.json().get("data", [])
            if not profiles:
                return {"success": False, "error": "No messaging profiles configured"}
            
            # Use first available messaging profile
            messaging_profile_id = profiles[0]["id"]
            
            # Send test SMS
            sms_data = {
                "to": test_phone,
                "from": "+1234567890",  # Will need actual Telnyx number
                "text": "🧪 CoolGirls Platform Test - Your verification code is: 123456",
                "messaging_profile_id": messaging_profile_id
            }
            
            response = requests.post(
                f"{self.base_url}/messages",
                headers=self.headers,
                json=sms_data
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ SMS test successful")
                return {
                    "success": True,
                    "message_id": result["data"]["id"],
                    "status": result["data"]["to"][0]["status"]
                }
            else:
                print(f"❌ SMS test failed: {response.status_code}")
                return {"success": False, "error": response.text}
                
        except Exception as e:
            print(f"❌ SMS test error: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def test_voice_capability(self, test_phone: str) -> Dict[str, Any]:
        """Test voice calling capability"""
        print(f"📞 Testing Voice capability to {test_phone}...")
        
        try:
            # Check for call control connections
            connections_response = requests.get(
                f"{self.base_url}/connections",
                headers=self.headers
            )
            
            if connections_response.status_code != 200:
                return {"success": False, "error": "No call control connections found"}
            
            connections = connections_response.json().get("data", [])
            if not connections:
                return {"success": False, "error": "No call control connections configured"}
            
            connection_id = connections[0]["id"]
            
            # Initiate test call
            call_data = {
                "to": test_phone,
                "from": "+1234567890",  # Will need actual Telnyx number
                "connection_id": connection_id
            }
            
            response = requests.post(
                f"{self.base_url}/calls",
                headers=self.headers,
                json=call_data
            )
            
            if response.status_code == 200:
                result = response.json()
                print("✅ Voice test initiated successfully")
                return {
                    "success": True,
                    "call_id": result["data"]["call_control_id"],
                    "status": result["data"]["call_leg_id"]
                }
            else:
                print(f"❌ Voice test failed: {response.status_code}")
                return {"success": False, "error": response.text}
                
        except Exception as e:
            print(f"❌ Voice test error: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def test_esim_capability(self) -> Dict[str, Any]:
        """Test eSIM provisioning capability"""
        print("📶 Testing eSIM capability...")
        
        try:
            # Check for SIM card groups
            sim_groups_response = requests.get(
                f"{self.base_url}/sim_card_groups",
                headers=self.headers
            )
            
            if sim_groups_response.status_code != 200:
                return {"success": False, "error": "eSIM service not available"}
            
            sim_groups = sim_groups_response.json().get("data", [])
            if not sim_groups:
                return {"success": False, "error": "No SIM card groups configured"}
            
            print("✅ eSIM capability available")
            return {
                "success": True,
                "sim_groups": len(sim_groups),
                "message": "eSIM provisioning API accessible"
            }
            
        except Exception as e:
            print(f"❌ eSIM test error: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def check_account_balance(self) -> Dict[str, Any]:
        """Check account credit balance"""
        print("💰 Checking account balance...")
        
        try:
            response = requests.get(
                f"{self.base_url}/balance",
                headers=self.headers
            )
            
            if response.status_code == 200:
                result = response.json()
                balance = result["data"]["balance"]
                currency = result["data"]["currency"]
                print(f"✅ Account balance: {balance} {currency}")
                return {
                    "success": True,
                    "balance": balance,
                    "currency": currency
                }
            else:
                print(f"❌ Balance check failed: {response.status_code}")
                return {"success": False, "error": response.text}
                
        except Exception as e:
            print(f"❌ Balance check error: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def run_full_test_suite(self, test_phone: Optional[str] = None) -> Dict[str, Any]:
        """Run complete test suite"""
        print("🚀 Starting Telnyx Integration Test Suite")
        print("=" * 50)
        
        results = {}
        
        # Test 1: API Connection
        results["api_connection"] = self.test_api_connection()
        time.sleep(1)
        
        # Test 2: Account Balance
        results["account_balance"] = self.check_account_balance()
        time.sleep(1)
        
        # Test 3: SMS Capability (if test phone provided)
        if test_phone:
            results["sms_capability"] = self.test_sms_capability(test_phone)
            time.sleep(2)
            
            # Test 4: Voice Capability (if test phone provided)
            results["voice_capability"] = self.test_voice_capability(test_phone)
            time.sleep(2)
        else:
            print("⚠️  No test phone provided - skipping SMS/Voice tests")
            results["sms_capability"] = {"success": False, "error": "No test phone provided"}
            results["voice_capability"] = {"success": False, "error": "No test phone provided"}
        
        # Test 5: eSIM Capability
        results["esim_capability"] = self.test_esim_capability()
        
        # Summary
        print("\n📊 Test Results Summary:")
        print("=" * 30)
        
        for test_name, result in results.items():
            status = "✅ PASS" if result["success"] else "❌ FAIL"
            print(f"{test_name:20} {status}")
            if not result["success"] and "error" in result:
                print(f"{'':20} Error: {result['error']}")
        
        return results

def main():
    """Main function"""
    print("🧪 Telnyx API Integration Tester for CoolGirls Platform")
    print("=" * 60)
    
    # Get API key from environment or prompt
    api_key = os.getenv("TELNYX_API_KEY")
    if not api_key:
        api_key = input("Enter your Telnyx API key: ").strip()
        if not api_key:
            print("❌ API key is required")
            sys.exit(1)
    
    # Get test phone number (optional)
    test_phone = input("Enter test phone number (optional, format: +1234567890): ").strip()
    if test_phone and not test_phone.startswith("+"):
        print("⚠️  Phone number should include country code (e.g., +1234567890)")
    
    # Initialize tester
    tester = TelnyxIntegrationTester(api_key)
    
    # Run tests
    try:
        results = tester.run_full_test_suite(test_phone if test_phone else None)
        
        # Save results
        results_file = "/tmp/telnyx_test_results.json"
        with open(results_file, "w") as f:
            json.dump(results, f, indent=2)
        
        print(f"\n💾 Test results saved to: {results_file}")
        
        # Check if ready for CoolGirls integration
        api_ok = results["api_connection"]["success"]
        balance_ok = results["account_balance"]["success"]
        
        if api_ok and balance_ok:
            print("\n🎉 Ready for CoolGirls platform integration!")
            print("Next steps:")
            print("1. Add TELNYX_API_KEY to CoolGirls environment")
            print("2. Purchase phone numbers for SMS/Voice")
            print("3. Configure messaging profiles and connections")
            print("4. Test with real verification workflows")
        else:
            print("\n⚠️  Setup incomplete - please resolve API/balance issues")
            
    except KeyboardInterrupt:
        print("\n\n⏹️  Test interrupted by user")
    except Exception as e:
        print(f"\n❌ Test failed with error: {str(e)}")

if __name__ == "__main__":
    main()