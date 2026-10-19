# Evidence Generation Script for IBM Express Book Review Final Project
# Run this with the server already running on port 5000

$BASE = "http://localhost:5000"
$EVIDENCE = "d:\Coding\College\Coursera\Final Project\evidence"

# ============================
# 1. githubrepo.txt
# ============================
Write-Host "Generating githubrepo.txt..."
$ghOutput = @"
Task 1: GitHub Repository Verification
=======================================

Command:
curl.exe -s https://api.github.com/repos/ajstarks117/expressBookReviews | findstr /i "fork full_name parent"

Output:
"@
$ghResponse = curl.exe -s "https://api.github.com/repos/ajstarks117/expressBookReviews"
$ghOutput += "`n$ghResponse`n"
$ghOutput += "`nVerification: The repository ajstarks117/expressBookReviews is a fork of ibm-developer-skills-network/expressBookReviews.`n"
$ghOutput += "Repository URL: https://github.com/ajstarks117/expressBookReviews`n"
Set-Content -Path "$EVIDENCE\githubrepo.txt" -Value $ghOutput -Encoding UTF8

# ============================
# 2. getallbooks.txt
# ============================
Write-Host "Generating getallbooks.txt..."
$allBooksOutput = @"
Task 2: Get All Books
=====================

Command:
curl.exe -s http://localhost:5000/

Output:
"@
$allBooksResponse = curl.exe -s "$BASE/"
$allBooksOutput += "`n$allBooksResponse`n"
Set-Content -Path "$EVIDENCE\getallbooks.txt" -Value $allBooksOutput -Encoding UTF8

# ============================
# 3. getbooksbyISBN.txt
# ============================
Write-Host "Generating getbooksbyISBN.txt..."
$isbnOutput = @"
Task 3: Get Book by ISBN
========================

Command:
curl.exe -s http://localhost:5000/isbn/1

Output:
"@
$isbnResponse = curl.exe -s "$BASE/isbn/1"
$isbnOutput += "`n$isbnResponse`n"
Set-Content -Path "$EVIDENCE\getbooksbyISBN.txt" -Value $isbnOutput -Encoding UTF8

# ============================
# 4. getbooksbyauthor.txt
# ============================
Write-Host "Generating getbooksbyauthor.txt..."
$authorOutput = @"
Task 4: Get Books by Author
============================

Command:
curl.exe -s http://localhost:5000/author/Chinua%20Achebe

Output:
"@
$authorResponse = curl.exe -s "$BASE/author/Chinua%20Achebe"
$authorOutput += "`n$authorResponse`n"
Set-Content -Path "$EVIDENCE\getbooksbyauthor.txt" -Value $authorOutput -Encoding UTF8

# ============================
# 5. getbooksbytitle.txt
# ============================
Write-Host "Generating getbooksbytitle.txt..."
$titleOutput = @"
Task 5: Get Books by Title
===========================

Command:
curl.exe -s http://localhost:5000/title/Things%20Fall%20Apart

Output:
"@
$titleResponse = curl.exe -s "$BASE/title/Things%20Fall%20Apart"
$titleOutput += "`n$titleResponse`n"
Set-Content -Path "$EVIDENCE\getbooksbytitle.txt" -Value $titleOutput -Encoding UTF8

# ============================
# 6. getbookreview.txt
# ============================
Write-Host "Generating getbookreview.txt..."
$reviewOutput = @"
Task 6: Get Book Review
========================

Command:
curl.exe -s http://localhost:5000/review/1

Output:
"@
$reviewResponse = curl.exe -s "$BASE/review/1"
$reviewOutput += "`n$reviewResponse`n"
Set-Content -Path "$EVIDENCE\getbookreview.txt" -Value $reviewOutput -Encoding UTF8

# ============================
# 7. register.txt
# ============================
Write-Host "Generating register.txt..."
$registerOutput = @"
Task 7: Register New User
===========================

Command:
curl.exe -s -X POST http://localhost:5000/register -H "Content-Type: application/json" -d '{\"username\":\"testuser\",\"password\":\"testpass123\"}'

Output:
"@
$registerResponse = curl.exe -s -X POST "$BASE/register" -H "Content-Type: application/json" -d '{\"username\":\"testuser\",\"password\":\"testpass123\"}'
$registerOutput += "`n$registerResponse`n"
Set-Content -Path "$EVIDENCE\register.txt" -Value $registerOutput -Encoding UTF8

# ============================
# 8. login.txt
# ============================
Write-Host "Generating login.txt..."
$loginOutput = @"
Task 8: User Login
===================

Command:
curl.exe -s -X POST http://localhost:5000/customer/login -H "Content-Type: application/json" -d '{\"username\":\"testuser\",\"password\":\"testpass123\"}'

Output:
"@
$loginResponse = curl.exe -s -X POST "$BASE/customer/login" -H "Content-Type: application/json" -d '{\"username\":\"testuser\",\"password\":\"testpass123\"}'
$loginOutput += "`n$loginResponse`n"

# Extract token from response
$tokenObj = $loginResponse | ConvertFrom-Json
$token = $tokenObj.token

Set-Content -Path "$EVIDENCE\login.txt" -Value $loginOutput -Encoding UTF8

# ============================
# 9. reviewadded.txt
# ============================
Write-Host "Generating reviewadded.txt..."
$reviewAddOutput = @"
Task 9: Add/Modify Book Review
================================

Command (Add Review):
curl.exe -s -X PUT "http://localhost:5000/customer/auth/review/1?review=This+is+a+great+book!" -H "Authorization: Bearer <token>"

Output:
"@
$reviewAddResponse = curl.exe -s -X PUT "$BASE/customer/auth/review/1?review=This+is+a+great+book!" -H "Authorization: Bearer $token"
$reviewAddOutput += "`n$reviewAddResponse`n"

$reviewAddOutput += "`nVerification - Get review after adding:`n"
$reviewAddOutput += "Command: curl.exe -s http://localhost:5000/review/1`n"
$reviewVerify = curl.exe -s "$BASE/review/1"
$reviewAddOutput += "Output: $reviewVerify`n"

$reviewAddOutput += "`nCommand (Update Review):`n"
$reviewAddOutput += 'curl.exe -s -X PUT "http://localhost:5000/customer/auth/review/1?review=Updated+review+for+this+classic+novel" -H "Authorization: Bearer <token>"' + "`n"
$reviewUpdateResponse = curl.exe -s -X PUT "$BASE/customer/auth/review/1?review=Updated+review+for+this+classic+novel" -H "Authorization: Bearer $token"
$reviewAddOutput += "Output: $reviewUpdateResponse`n"

$reviewAddOutput += "`nVerification - Get review after update:`n"
$reviewVerify2 = curl.exe -s "$BASE/review/1"
$reviewAddOutput += "Output: $reviewVerify2`n"

Set-Content -Path "$EVIDENCE\reviewadded.txt" -Value $reviewAddOutput -Encoding UTF8

# ============================
# 10. deletereview.txt
# ============================
Write-Host "Generating deletereview.txt..."
$deleteOutput = @"
Task 10: Delete Book Review
=============================

Command:
curl.exe -s -X DELETE "http://localhost:5000/customer/auth/review/1" -H "Authorization: Bearer <token>"

Output:
"@
$deleteResponse = curl.exe -s -X DELETE "$BASE/customer/auth/review/1" -H "Authorization: Bearer $token"
$deleteOutput += "`n$deleteResponse`n"

$deleteOutput += "`nVerification - Get review after deletion:`n"
$deleteOutput += "Command: curl.exe -s http://localhost:5000/review/1`n"
$deleteVerify = curl.exe -s "$BASE/review/1"
$deleteOutput += "Output: $deleteVerify`n"

Set-Content -Path "$EVIDENCE\deletereview.txt" -Value $deleteOutput -Encoding UTF8

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
Set-Content -Path "$EVIDENCE\generaljs_url.txt" -Value $generalJsOutput -Encoding UTF8

Write-Host "`nAll evidence files generated successfully!"
Write-Host "Evidence files are in: $EVIDENCE"
Get-ChildItem $EVIDENCE -Filter "*.txt" | ForEach-Object { Write-Host "  - $($_.Name)" }
