#!/bin/bash
BASE_URL="http://127.0.0.1:8000/api"

echo "Testing Login..."
LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"pelanggan1","password":"password"}')

echo "Response: $LOGIN_RESPONSE"

TOKEN=$(echo $LOGIN_RESPONSE | grep -oP '(?<="access_token":")[^"]*')

if [ -z "$TOKEN" ]; then
  echo "Failed to get token"
  exit 1
fi

echo "Token obtained. Testing Current Tagihan..."
curl -s -X GET "$BASE_URL/tagihan/current?id_pelanggan=1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
