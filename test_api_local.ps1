$BASE_URL = "http://127.0.0.1:8000/api"

Write-Host "Testing Login..." -ForegroundColor Yellow
$loginBody = @{
    username = "andi"
    password = "123456"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "$BASE_URL/login" -Method Post -Body $loginBody -ContentType "application/json"
    Write-Host "Login successful!" -ForegroundColor Green
    
    $token = $loginResponse.data.access_token
    
    if (-not $token) {
        Write-Host "Failed to get access_token from response" -ForegroundColor Red
        return
    }

    $headers = @{
        "Authorization" = "Bearer $token"
        "Accept"        = "application/json"
    }

    Write-Host "Testing Current Tagihan..." -ForegroundColor Yellow
    $currentResponse = Invoke-RestMethod -Uri "$BASE_URL/tagihan/current" -Method Get -Headers $headers
    $currentResponse | ConvertTo-Json -Depth 3

    Write-Host "`nTesting History Tagihan..." -ForegroundColor Yellow
    $historyResponse = Invoke-RestMethod -Uri "$BASE_URL/tagihan/history" -Method Get -Headers $headers
    $historyResponse | ConvertTo-Json -Depth 3

}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
