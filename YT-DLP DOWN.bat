@echo off
chcp 65001 >nul

:: Путь к текущей папке, где лежит батник
set "BIN_DIR=%~dp0"

:: Проверяем, существует ли yt-dlp.exe рядом
if not exist "%BIN_DIR%yt-dlp.exe" (
    echo [!] Ошибка: Не найден файл yt-dlp.exe в папке со скриптом!
    echo [!] Убедитесь, что утилита лежит рядом с этим батником.
    pause
    exit /b
)

:: Извлекаем ссылку из буфера обмена
for /f "delims=" %%i in ('mshta "javascript:var s=clipboardData.getData('Text');if(s)new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(s);close();"') do set "ClipboardData=%%i"

:: Удаляем пробелы по краям
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
"%BIN_DIR%yt-dlp.exe" --rm-cache-dir >nul 2>&1

:: Запуск скачивания и склейки
"%BIN_DIR%yt-dlp.exe" ^
  -f "bv*+ba/b" ^
  --ffmpeg-location "%BIN_DIR%" ^
  --merge-output-format mp4 ^
  --concurrent-fragments 10 ^
  --file-access-retries 5 ^
  --fragment-retries 10 ^
  --extractor-args "youtube:player-client=ios,web_embedded" ^
  --no-mtime ^
  -o "%%(title)s.%%(ext)s" ^
  "%ClipboardData%"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Ошибка при скачивании.
    pause
) else (
    echo.
    echo [+] Готово! Видео успешно скачано и сохранено в MP4.
    timeout /t 3 >nul
)
