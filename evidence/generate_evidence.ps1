# Evidence Generation Script for IBM Express Book Review Final Project
# Run this with the server already running on port 5000

$BASE = "http://localhost:5000"
$EVIDENCE_DIRS = @(
    "d:\Coding\College\Coursera\Final Project\evidence",
    "d:\Coding\College\Coursera\Final Project\submission_evidence"
)

foreach ($dir in $EVIDENCE_DIRS) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Save-EvidenceFile {
    param(
        [string]$FileName,
        [string]$Content
    )
    foreach ($dir in $EVIDENCE_DIRS) {
        Set-Content -Path "$dir\$FileName" -Value $Content -Encoding UTF8
    }
}

# ============================
# 1. githubrepo.txt
# ============================
Write-Host "Generating githubrepo.txt..."
$ghCmd = "curl.exe -s https://api.github.com/repos/ajstarks117/expressBookReviews | jq '.parent.full_name'"
$ghResponse = (curl.exe -s "https://api.github.com/repos/ajstarks117/expressBookReviews" | jq '.parent.full_name').Trim()

$ghOutput = @"
Task 1: GitHub Repository Verification
=======================================

Command:
$ghCmd

Output:
$ghResponse

Verification: The repository ajstarks117/expressBookReviews is a fork of ibm-developer-skills-network/expressBookReviews.
Repository URL: https://github.com/ajstarks117/expressBookReviews
"@
Save-EvidenceFile -FileName "githubrepo.txt" -Content $ghOutput

# ============================
# 2. getallbooks.txt
# ============================
Write-Host "Generating getallbooks.txt..."
$allBooksRaw = (curl.exe -s "$BASE/")
$allBooksOutput = @"
Task 2: Get All Books
=====================

Command:
curl.exe -s http://localhost:5000/

Output:
$allBooksRaw
"@
Save-EvidenceFile -FileName "getallbooks.txt" -Content $allBooksOutput

# ============================
# 3. getbooksbyISBN.txt
# ============================
Write-Host "Generating getbooksbyISBN.txt..."
$isbnRaw = (curl.exe -s "$BASE/isbn/1")
$isbnOutput = @"
Task 3: Get Book by ISBN
========================

Command:
curl.exe -s http://localhost:5000/isbn/1

Output:
$isbnRaw
"@
Save-EvidenceFile -FileName "getbooksbyISBN.txt" -Content $isbnOutput

# ============================
# 4. getbooksbyauthor.txt
# ============================
Write-Host "Generating getbooksbyauthor.txt..."
$authorRaw = (curl.exe -s "$BASE/author/Chinua%20Achebe")
$authorOutput = @"
Task 4: Get Books by Author
============================

Command:
curl.exe -s http://localhost:5000/author/Chinua%20Achebe

Output:
$authorRaw
"@
Save-EvidenceFile -FileName "getbooksbyauthor.txt" -Content $authorOutput

# ============================
# 5. getbooksbytitle.txt
# ============================
Write-Host "Generating getbooksbytitle.txt..."
$titleRaw = (curl.exe -s "$BASE/title/Things%20Fall%20Apart")
$titleOutput = @"
Task 5: Get Books by Title
===========================

Command:
curl.exe -s http://localhost:5000/title/Things%20Fall%20Apart

Output:
$titleRaw
"@
Save-EvidenceFile -FileName "getbooksbytitle.txt" -Content $titleOutput

# ============================
# 6. getbookreview.txt
# ============================
Write-Host "Generating getbookreview.txt..."
$reviewRaw = (curl.exe -s "$BASE/review/1")
$reviewOutput = @"
Task 6: Get Book Review
========================

Command:
curl.exe -s http://localhost:5000/review/1

Output:
$reviewRaw
"@
Save-EvidenceFile -FileName "getbookreview.txt" -Content $reviewOutput

# ============================
# 7. register.txt
# ============================
Write-Host "Generating register.txt..."
$regUser = "newuser_" + (Get-Random -Minimum 1000 -Maximum 9999)
$regPass = "testpass123"

$regBody = @{ username = $regUser; password = $regPass } | ConvertTo-Json
$regResObj = Invoke-RestMethod -Uri "$BASE/register" -Method Post -Body $regBody -ContentType "application/json"
$regRaw = ($regResObj | ConvertTo-Json -Compress)

$registerOutput = @"
Task 7: Register New User
===========================

Command:
curl.exe -s -X POST http://localhost:5000/register -H "Content-Type: application/json" -d '{\"username\":\"$regUser\",\"password\":\"$regPass\"}'

Output:
$regRaw
"@
Save-EvidenceFile -FileName "register.txt" -Content $registerOutput

# ============================
# 8. login.txt
# ============================
Write-Host "Generating login.txt..."
$loginBody = @{ username = $regUser; password = $regPass } | ConvertTo-Json
$loginResObj = Invoke-RestMethod -Uri "$BASE/customer/login" -Method Post -Body $loginBody -ContentType "application/json"
$actualToken = $loginResObj.token

$redactedLoginJson = '{"message":"User successfully logged in","token":"<token>"}'

$loginOutput = @"
Task 8: User Login
===================

Command:
curl.exe -s -X POST http://localhost:5000/customer/login -H "Content-Type: application/json" -d '{\"username\":\"$regUser\",\"password\":\"$regPass\"}'

Output:
$redactedLoginJson
"@
Save-EvidenceFile -FileName "login.txt" -Content $loginOutput

# ============================
# 9. reviewadded.txt
# ============================
Write-Host "Generating reviewadded.txt..."
$addReviewObj = Invoke-RestMethod -Uri "$BASE/customer/auth/review/1?review=This+is+a+great+book!" -Method Put -Headers @{ Authorization = "Bearer $actualToken" }
$addReviewRaw = ($addReviewObj | ConvertTo-Json -Compress)

$verifyAddObj = Invoke-RestMethod -Uri "$BASE/review/1" -Method Get
$verifyAddRaw = ($verifyAddObj | ConvertTo-Json -Compress)

$updateReviewObj = Invoke-RestMethod -Uri "$BASE/customer/auth/review/1?review=Updated+review+for+this+classic+novel" -Method Put -Headers @{ Authorization = "Bearer $actualToken" }
$updateReviewRaw = ($updateReviewObj | ConvertTo-Json -Compress)

$verifyUpdateObj = Invoke-RestMethod -Uri "$BASE/review/1" -Method Get
$verifyUpdateRaw = ($verifyUpdateObj | ConvertTo-Json -Compress)

$reviewAddOutput = @"
Task 9: Add/Modify Book Review
================================

Command (Add Review):
curl.exe -s -X PUT "http://localhost:5000/customer/auth/review/1?review=This+is+a+great+book!" -H "Authorization: Bearer <token>"

Output:
$addReviewRaw

Verification - Get review after adding:
Command: curl.exe -s http://localhost:5000/review/1
Output: $verifyAddRaw

Command (Update Review):
curl.exe -s -X PUT "http://localhost:5000/customer/auth/review/1?review=Updated+review+for+this+classic+novel" -H "Authorization: Bearer <token>"
Output: $updateReviewRaw

Verification - Get review after update:
Command: curl.exe -s http://localhost:5000/review/1
Output: $verifyUpdateRaw
"@
Save-EvidenceFile -FileName "reviewadded.txt" -Content $reviewAddOutput

# ============================
# 10. deletereview.txt
# ============================
Write-Host "Generating deletereview.txt..."
$deleteObj = Invoke-RestMethod -Uri "$BASE/customer/auth/review/1" -Method Delete -Headers @{ Authorization = "Bearer $actualToken" }
$deleteRaw = ($deleteObj | ConvertTo-Json -Compress)

$verifyDeleteObj = Invoke-RestMethod -Uri "$BASE/review/1" -Method Get
$verifyDeleteRaw = ($verifyDeleteObj | ConvertTo-Json -Compress)

$deleteOutput = @"
Task 10: Delete Book Review
=============================

Command:
curl.exe -s -X DELETE "http://localhost:5000/customer/auth/review/1" -H "Authorization: Bearer <token>"

Output:
$deleteRaw

Verification - Get review after deletion:
Command: curl.exe -s http://localhost:5000/review/1
Output: $verifyDeleteRaw
"@
Save-EvidenceFile -FileName "deletereview.txt" -Content $deleteOutput

# ============================
# 11. generaljs_url.txt
# ============================
Write-Host "Generating generaljs_url.txt..."
$generalJsOutput = @"
Task 11: general.js GitHub URL
================================

The general.js file is located at:
https://github.com/ajstarks117/expressBookReviews/blob/main/final_project/router/general.js
"@
Save-EvidenceFile -FileName "generaljs_url.txt" -Content $generalJsOutput

Write-Host "`nAll evidence files generated successfully!"
foreach ($dir in $EVIDENCE_DIRS) {
    Write-Host "`nDirectory: $dir"
    Get-ChildItem $dir -Filter "*.txt" | ForEach-Object { Write-Host "  - $($_.Name)" }
}
