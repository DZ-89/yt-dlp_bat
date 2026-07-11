@echo off
chcp 65001 >nul

set "BIN_DIR=%~dp0yt-dlp"

:: Проверяем, существует ли папка с утилитой
if not exist "%BIN_DIR%\yt-dlp.exe" (
    echo [!] Ошибка: Не найден файл yt-dlp.exe по пути: "%BIN_DIR%"
    echo [!] Убедитесь, что утилита лежит в папке "yt-dlp" рядом с этим батником.
    pause
    exit /b
)

:: Извлекаем ссылку из буфера обмена через mshta
for /f "delims=" %%i in ('mshta "javascript:var s=clipboardData.getData('Text');if(s)new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(s);close();"') do set "ClipboardData=%%i"

:: Удаляем возможные пробелы по краям ссылки
if defined ClipboardData (
    for /f "tokens=* delims= " %%a in ("%ClipboardData%") do set "ClipboardData=%%a"
)

if "%ClipboardData%"=="" (
    echo [!] Буфер обмена пуст!
    pause
    exit /b
)

echo [+] Ссылка: "%ClipboardData%"

:: Чистим кэш перед стартом
"%BIN_DIR%\yt-dlp.exe" --rm-cache-dir >nul 2>&1

:: Запуск на максималках без прокси
"%BIN_DIR%\yt-dlp.exe" ^
  -f "bestvideo+bestaudio/best" ^
  --concurrent-fragments 10 ^
  --buffer-size 1M ^
  --extractor-args "youtube:player_client=ios,android,web" ^
  --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36" ^
  --no-mtime ^
  -o "%%(title)s.%%(ext)s" ^
  "%ClipboardData%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Ошибка при скачивании.
    pause
) else (
    echo.
    echo [+] Готово! Файл сохранен в оригинальном формате.
    timeout /t 3 >nul
)