@echo off
setlocal

cd /d "%~dp0"

title YouTube Heatmap Clipper Launcher
cls

echo ===================================================
echo   YouTube Heatmap Clipper - Auto Launcher
echo ===================================================
echo(

set "VENV_DIR=venv"
set "PYTHON_CMD="

if exist "%VENV_DIR%\Scripts\python.exe" set "PYTHON_CMD=%VENV_DIR%\Scripts\python.exe"
if defined PYTHON_CMD goto :DEPS

echo [*] Virtual Environment tidak ditemukan.
echo [*] Mencari Python yang tersedia...

rem --- Probe preferred versions in order: 3.12 -> 3.13 -> 3.11 ---
set "PY_VER="
for %%V in (3.12 3.13 3.11) do (
    if not defined PY_VER (
        py -%%V --version >nul 2>nul
        if not errorlevel 1 set "PY_VER=%%V"
    )
)

if defined PY_VER (
    echo [OK] Python %PY_VER% ditemukan. Membuat venv...
    py -%PY_VER% -m venv "%VENV_DIR%"
    if errorlevel 1 goto :VENV_FAIL
    goto :SET_PY
)

rem --- Fallback to default 'python' on PATH ---
echo [WARN] Tidak ada py -3.12/3.13/3.11 yang valid.
echo [*] Menggunakan default 'python' system...
python --version >nul 2>nul
if errorlevel 1 goto :NO_PY
python -m venv "%VENV_DIR%"
if errorlevel 1 goto :VENV_FAIL

:SET_PY
if not exist "%VENV_DIR%\Scripts\python.exe" goto :VENV_FAIL
set "PYTHON_CMD=%VENV_DIR%\Scripts\python.exe"
echo [OK] Venv berhasil dibuat.

:DEPS
echo(
echo [*] Checking ^& Installing dependencies...
"%PYTHON_CMD%" -m pip install --upgrade pip >nul
"%PYTHON_CMD%" -m pip install -r requirements.txt
if errorlevel 1 goto :REQ_FAIL

echo [*] Checking AI Subtitle dependencies (faster-whisper)...
"%PYTHON_CMD%" -c "import faster_whisper" >nul 2>nul
if errorlevel 1 goto :INSTALL_FWHISPER
echo [OK] faster-whisper already installed.
goto :RUN

:INSTALL_FWHISPER
echo [*] Installing faster-whisper...
"%PYTHON_CMD%" -m pip install faster-whisper
if errorlevel 1 (
    echo [WARN] Gagal install faster-whisper. Fitur subtitle mungkin tidak jalan.
    echo        (Biasanya karena versi Python tidak kompatibel/preview version^)
) else (
    echo [OK] faster-whisper installed.
)

:RUN
echo(
echo ===================================================
echo   PENTING:
echo   Pastikan FFmpeg sudah terinstall agar fungsi crop jalan.
echo   Jika belum, install manual via PowerShell (Administrator^):
echo       winget install Gyan.FFmpeg
echo.
echo   Semua siap! Menjalankan Web App...
echo   Buka browser di: http://127.0.0.1:5000
echo   Atau via Tailscale/LAN di: http://100.81.63.42:5000
echo ===================================================
echo(

if defined YHC_CHECK_ONLY goto :DONE

"%PYTHON_CMD%" -u webapp.py
goto :DONE

:NO_PY
echo [X] Python tidak ditemukan sama sekali!
echo     Install Python 3.11 dari python.org atau Microsoft Store.
goto :FAIL

:VENV_FAIL
echo [X] Gagal membuat venv.
goto :FAIL

:REQ_FAIL
echo [X] Gagal install basic dependencies. Cek koneksi internet.
goto :FAIL

:FAIL
echo(
echo [INFO] Aplikasi berhenti.
echo Tekan sembarang tombol untuk menutup jendela ini...
pause
exit /b 1

:DONE
echo(
echo [INFO] Aplikasi berhenti.
echo Tekan sembarang tombol untuk menutup jendela ini...
pause
exit /b 0
