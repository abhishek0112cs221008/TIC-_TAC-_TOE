@echo off
echo Creating Keystore for Tic Tac Toe App...
echo.

REM Set variables
set KEYSTORE_PATH=d:\Flutter Projects\tic_tac_toe\android\app\upload-keystore.jks
set STORE_PASSWORD=8770321224
set KEY_PASSWORD=8770321224
set KEY_ALIAS=bsc
set VALIDITY=10000

echo Keystore will be created at: %KEYSTORE_PATH%
echo.

REM Find keytool
set KEYTOOL_PATH=

REM Check common Java locations
if exist "C:\Program Files\Java\jdk-*\bin\keytool.exe" (
    for /d %%i in ("C:\Program Files\Java\jdk-*") do set KEYTOOL_PATH=%%i\bin\keytool.exe
)

if exist "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" (
    set KEYTOOL_PATH=C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe
)

if "%KEYTOOL_PATH%"=="" (
    echo ERROR: keytool not found!
    echo Please install Java JDK or use Android Studio's JDK
    pause
    exit /b 1
)

echo Using keytool from: %KEYTOOL_PATH%
echo.

REM Create keystore
"%KEYTOOL_PATH%" -genkeypair -v -keystore "%KEYSTORE_PATH%" -storetype JKS -keyalg RSA -keysize 2048 -validity %VALIDITY% -alias %KEY_ALIAS% -storepass %STORE_PASSWORD% -keypass %KEY_PASSWORD% -dname "CN=Abhishek, OU=Personal, O=Personal, L=India, S=India, C=IN"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo SUCCESS! Keystore created successfully!
    echo ========================================
    echo.
    echo Location: %KEYSTORE_PATH%
    echo.
    echo Now you can build release APK/AAB with:
    echo flutter build appbundle --release
    echo.
) else (
    echo.
    echo ERROR: Failed to create keystore
    echo.
)

pause
