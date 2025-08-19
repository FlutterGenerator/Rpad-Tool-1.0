@echo off
title PUBG RPAD TOOL LITE/MOBILE
setlocal enabledelayedexpansion
mode con: cols=120 lines=45

:: Set color scheme for a modern look
color 1F >nul :: Bright white text on dark blue background for main menu
set "header_color=echo [91m" :: Red for headers
set "option_color=echo [93m" :: Yellow for options
set "info_color=echo [92m" :: Green for informational messages
set "error_color=echo [91m" :: Red for errors
set "prompt_color=echo [96m" :: Cyan for prompts

:: Initialize log file for debugging
set "log_file=login_log.txt"
echo [%date% %time%] Script started > "!log_file!"

:: Check for credentials file
set "cred_file=credentials.dat"
if not exist "%cred_file%" (
  %error_color%ERROR: credentials.dat file not found. Please create the file.[0m
  echo [%date% %time%] ERROR: credentials.dat file not found >> "!log_file!"
  pause
  exit /b
)

:: Read credentials from file (format: username|password)
set "valid_username="
set "valid_password="
for /f "tokens=1,2 delims=|" %%a in (%cred_file%) do (
  set "valid_username=%%a"
  set "valid_password=%%b"
)

:: Trim any trailing/leading spaces from credentials
for /f "tokens=*" %%a in ("!valid_username!") do set "valid_username=%%a"
for /f "tokens=*" %%a in ("!valid_password!") do set "valid_password=%%a"

:: Check if credentials were read correctly
if not defined valid_username (
  %error_color%ERROR: Username could not be read from credentials.dat. Check file format.[0m
  echo [%date% %time%] ERROR: Username not read >> "!log_file!"
  pause
  exit /b
)
if not defined valid_password (
  %error_color%ERROR: Password could not be read from credentials.dat. Check file format.[0m
  echo [%date% %time%] ERROR: Password not read >> "!log_file!"
  pause
  exit /b
)

:: Log read credentials (for debugging, remove in production)
echo [%date% %time%] Read Username: !valid_username! >> "!log_file!"
echo [%date% %time%] Read Password: !valid_password! >> "!log_file!"

:: Login prompt
:LOGIN
cls
echo.
echo [97m========================================================================================================[0m
%header_color%          PUBG RPAD TOOL LITE/MOBILE - LOGIN[0m
echo [97m========================================================================================================[0m
echo.
%prompt_color%Enter Username: [0m
set "input_username="
set /p input_username=
if not defined input_username (
  %error_color%ERROR: Username cannot be empty. Try again.[0m
  echo [%date% %time%] ERROR: Username empty >> "!log_file!"
  pause
  goto LOGIN
)
%prompt_color%Enter Password: [0m
set "input_password="
set /p input_password=
if not defined input_password (
  %error_color%ERROR: Password cannot be empty. Try again.[0m
  echo [%date% %time%] ERROR: Password empty >> "!log_file!"
  pause
  goto LOGIN
)

:: Log input for debugging
echo [%date% %time%] Entered Username: !input_username! >> "!log_file!"
echo [%date% %time%] Entered Password: !input_password! >> "!log_file!"

:: Verify credentials
:: Username case-insensitive, password case-sensitive
set "login_success=0"
if /i "!input_username!"=="!valid_username!" (
  if "!input_password!"=="!valid_password!" (
    set "login_success=1"
  )
)

if !login_success! equ 1 (
  %info_color%Login successful! Proceeding to main menu...[0m
  echo [%date% %time%] Login successful >> "!log_file!"
  pause
  goto MENU
) else (
  %error_color%ERROR: Invalid username or password. Try again.[0m
  echo [%date% %time%] ERROR: Invalid username or password >> "!log_file!"
  pause
  goto LOGIN
)

:MENU
cls
echo.
echo [97m========================================================================================================[0m
%header_color%          PUBG RPAD TOOL LITE/MOBILE - v1.0[0m
%header_color%                TURKISH DEVELOPER[0m
%header_color%               TELEGRAM @RPADCOURSE[0m
echo [97m========================================================================================================[0m
echo.
%option_color%   [1] Unpack (QuickBMS)[0m
%option_color%   [2] Repack[0m
%option_color%   [3] Map Files Unpack (PUBG Mobile)[0m
%option_color%   [4] Map Files Repack (PUBG Mobile)[0m
%option_color%   [5] Map Tool[0m
%option_color%   [6] Zdisc Tool[0m
%option_color%   [7] Delete Map Folder[0m
%option_color%   [8] Delete Output Folder[0m
%option_color%   [9] Help[0m
%option_color%  [10] Join Telegram[0m
%option_color%  [11] Exit[0m
echo.
echo [97m========================================================================================================[0m
echo.
%prompt_color%Choose an option: [0m
set /p choice=
if "%choice%"=="1" goto UNPACK
if "%choice%"=="2" goto REPACK
if "%choice%"=="3" goto MAP_UNPACK
if "%choice%"=="4" goto MAP_REPACK_MENU
if "%choice%"=="5" goto MAP_TOOL_MENU
if "%choice%"=="6" goto ZDISC_TOOL
if "%choice%"=="7" goto CLEAN_MAP
if "%choice%"=="8" goto CLEAN_OUTPUT
if "%choice%"=="9" goto HELP
if "%choice%"=="10" goto JOIN_TELEGRAM
if "%choice%"=="11" exit
goto MENU

:UNPACK
cls
%header_color%--- Unpack (QuickBMS) ---[0m
echo.
%info_color%Listing .pak files in input\[0m
set i=0
for %%F in (input\*.pak) do (
  set /a i+=1
  set "file[!i!]=%%F"
  %option_color%    !i! - %%~nF%%~xF[0m
)
if %i%==0 (
  %error_color%ERROR: No .pak files found.[0m
  pause
  goto MENU
)
echo.
%prompt_color%Select file [1-%i%]: [0m
set /p idx=
if "%idx%"=="" goto MENU
if %idx% LSS 1 if %idx% GTR %i% goto MENU
set "pakfile=!file[%idx%]!"

%info_color%Select game version:[0m
%option_color%[1] PUBG Mobile[0m
%option_color%[2] PUBG Mobile Lite[0m
%option_color%[3] PUBG Mobile Zdisc[0m
echo.
%prompt_color%Choose an option [1-3]: [0m
set /p game_choice=
if "%game_choice%"=="1" (
  set "bms_script=bms\pubgm.bms"
  set "output_path=output_folder"
) else if "%game_choice%"=="2" (
  set "bms_script=bms\pubgl.bms"
  set "output_path=output_folder"
) else if "%game_choice%"=="3" (
  set "bms_script=bms\pubgmzdisc.bms"
  set "output_path=output_folderzdisc"
) else (
  %error_color%Invalid choice.[0m
  pause
  goto MENU
)

%info_color%Running QuickBMS...[0m
apps\quickbms.exe "!bms_script!" "%pakfile%" "!output_path!"
if errorlevel 1 (
  %error_color%ERROR: QuickBMS unpack failed.[0m
  pause
  goto MENU
)

%info_color%Checking for .dat files in !output_path!...[0m
cd "!output_path!"
if not exist *.dat (
  %error_color%ERROR: No .dat files found in !output_path!.[0m
  cd ..
  pause
  goto MENU
)

%info_color%Converting .dat -> .uasset/.uexp[0m
set count=0
for %%A in (*.dat) do (
  set /a count+=1
  set /a is_odd=count%%2
  if !is_odd!==1 (
    %info_color%Renaming %%A to %%~nA.uasset[0m
    ren "%%A" "%%~nA.uasset"
  ) else (
    %info_color%Renaming %%A to %%~nA.uexp[0m
    ren "%%A" "%%~nA.uexp"
  )
)
if !count!==0 (
  %error_color%ERROR: No .dat files found for renaming.[0m
  cd ..
  pause
  goto MENU
)
cd ..

%info_color%Unpack complete.[0m
pause
goto MENU

:REPACK
cls
%header_color%--- Repack ---[0m
echo.
if not exist repack (
  %error_color%ERROR: repack folder missing.[0m
  pause
  goto MENU
)
pushd repack
set count=0
for %%A in (*.uasset *.uexp) do (
  set /a count+=1
  if !count!==1 copy "%%A" "0000000.dat" >nul
  if !count!==2 copy "%%A" "0000001.dat" >nul
)
if %count%==0 (
  %error_color%ERROR: No .uasset/.uexp found.[0m
  popd
  pause
  goto MENU
)
del *.uasset *.uexp >nul 2>&1
popd

%info_color%Running reimport.bat...[0m
call apps\reimport.bat
if errorlevel 1 (
  cls
  %error_color%ERROR: reimport.bat failed.[0m
  echo.
  pause
  goto MENU
)

cls
%info_color%Repack complete.[0m
echo.
pause
goto MENU

:MAP_UNPACK
cls
%header_color%--- Map Files Unpack (PUBG Mobile) ---[0m
echo.
%info_color%Listing .pak files in input\[0m
set i=0
for %%F in (input\*.pak) do (
  set /a i+=1
  set "file[!i!]=%%F"
  %option_color%    !i! - %%~nF%%~xF[0m
)
if %i%==0 (
  %error_color%ERROR: No .pak files found.[0m
  pause
  goto MENU
)
echo.
%prompt_color%Select file [1-%i%]: [0m
set /p idx=
if "%idx%"=="" goto MENU
if %idx% LSS 1 if %idx% GTR %i% goto MENU
set "pakfile=!file[%idx%]!"

%info_color%Creating map output folders...[0m
if not exist output_folder\map mkdir output_folder\map
if not exist output_folder\map\extracted mkdir output_folder\map\extracted

%info_color%Running map unpack script...[0m
apps\quickbms.exe bms\unpack.bms "%pakfile%" output_folder\map
if errorlevel 1 (
  %error_color%ERROR: QuickBMS unpack.bms failed.[0m
  pause
  goto MENU
)
if not exist output_folder\map\decrypt_map.pak (
  %error_color%ERROR: decrypt_map.pak missing.[0m
  pause
  goto MENU
)

%info_color%Extracting with offzip...[0m
apps\offzip.exe -a "output_folder\map\decrypt_map.pak" "output_folder\map\extracted"
if errorlevel 1 (
  %error_color%ERROR: offzip failed.[0m
  pause
  goto MENU
)

%info_color%Map unpack complete.[0m
pause
goto MENU

:MAP_TOOL_MENU
cls
%header_color%--- Map Tool ---[0m
echo.
%option_color%1. White Map[0m
%option_color%2. No Grass[0m
%option_color%3. Dot Crosshair[0m
%option_color%4. Black Sky[0m
%option_color%5. Back to Main Menu[0m
echo.
%prompt_color%Choose an option [1-5]: [0m
set /p mt_choice=

if "%mt_choice%"=="1" goto MAP_TOOL_WHITE_MAP
if "%mt_choice%"=="2" goto MAP_TOOL_NO_GRASS
if "%mt_choice%"=="3" goto MAP_TOOL_DOT_CROSSHAIR
if "%mt_choice%"=="4" goto MAP_TOOL_BLACK_SKY
if "%mt_choice%"=="5" goto MENU
goto MAP_TOOL_MENU

:MAP_TOOL_WHITE_MAP
cls
%header_color%--- White Map Process ---[0m
echo.
%info_color%Starting White Map process...[0m
if not exist output_folder\map\extracted (
  %error_color%ERROR: output_folder\map\extracted folder not found.[0m
  pause
  goto MAP_TOOL_MENU
)

if not exist output_folder\map\White_Map mkdir output_folder\map\White_Map

setlocal enabledelayedexpansion
set count=0

for %%F in (output_folder\map\extracted\*.uasset) do (
  set filesize=0
  for %%I in ("%%F") do set filesize=%%~zI
  if !filesize! GEQ 0 if !filesize! LEQ 1000 (
    %info_color%Processing file: %%~nxF[0m
    copy /y nul "output_folder\map\White_Map\%%~nxF" >nul
    set /a count+=1
  )
)

if !count! EQU 0 (
  %error_color%No files found in size range 0-1000 bytes.[0m
) else (
  %info_color%!count! files processed and emptied in White Map folder.[0m
)

endlocal
pause
goto MAP_TOOL_MENU

:MAP_TOOL_NO_GRASS
cls
%header_color%--- No Grass ---[0m
echo.
%error_color%No Grass feature not implemented yet.[0m
pause
goto MAP_TOOL_MENU

:MAP_TOOL_DOT_CROSSHAIR
cls
%header_color%--- Dot Crosshair Process ---[0m
echo.
%info_color%Starting Dot Crosshair process...[0m
if not exist output_folder\map\extracted (
  %error_color%ERROR: output_folder\map\extracted folder not found.[0m
  pause
  goto MAP_TOOL_MENU
)

if not exist output_folder\Dot_Crosshair mkdir output_folder\Dot_Crosshair

setlocal enabledelayedexpansion
set "search_folder=output_folder\map\extracted"
set "output_folder=output_folder\map"
set "found_any=0"

for %%F in ("%search_folder%\*.uasset") do (
    findstr /m /i "T_CrossHairEmptyHandOrange T_CrossHairEmptyHand" "%%F" >nul 2>&1
    if !errorlevel! == 0 (
        set "found_any=1"
        %info_color%Processing file: %%~nxF[0m
        copy /y nul "%output_folder%\%%~nxF" >nul
    )
)

if !found_any! == 0 (
    %error_color%No matching files found.[0m
)

endlocal
%info_color%Dot Crosshair processing completed.[0m
pause
goto MAP_TOOL_MENU

:MAP_TOOL_BLACK_SKY
cls
%header_color%--- Black Sky ---[0m
echo.
%error_color%Black Sky feature not implemented yet.[0m
pause
goto MAP_TOOL_MENU

:CLEAN_MAP
cls
%header_color%--- Delete Map Folder ---[0m
echo.
%info_color%Deleting map folder...[0m
rmdir /s /q output_folder\map
%info_color%Map folder deleted.[0m
pause
goto MENU

:CLEAN_OUTPUT
cls
%header_color%--- Delete Output Folder ---[0m
echo.
%info_color%Deleting output folder...[0m
rmdir /s /q output_folder
%info_color%output_folder deleted.[0m
echo.
%info_color%Recreating output_folder...[0m
mkdir output_folder
%info_color%output_folder created.[0m
pause
goto MENU

:CLEAN_ZDISC
cls
%header_color%--- Delete Zdisc Folder ---[0m
echo.
%info_color%Deleting output_folderzdisc folder...[0m
rmdir /s /q output_folderzdisc
%info_color%Recreating output_folderzdisc folder...[0m
mkdir output_folderzdisc
%info_color%output_folderzdisc folder reset.[0m
pause
goto MENU

:MAP_REPACK_MENU
cls
%header_color%--- Map Files Repack (PUBG Mobile) ---[0m
echo.
%option_color%1. White Map[0m
%option_color%2. No Grass[0m
%option_color%3. Dot Crosshair[0m
%option_color%4. Black Sky[0m
%option_color%5. Back to Main Menu[0m
echo.
%prompt_color%Choose an option [1-5]: [0m
set /p repack_choice=

if "%repack_choice%"=="1" goto REPACK_WHITE_MAP
if "%repack_choice%"=="2" %error_color%Feature not implemented yet.[0m & pause & goto MAP_REPACK_MENU
if "%repack_choice%"=="3" %error_color%Feature not implemented yet.[0m & pause & goto MAP_REPACK_MENU
if "%repack_choice%"=="4" %error_color%Feature not implemented yet.[0m & pause & goto MAP_REPACK_MENU
if "%repack_choice%"=="5" goto MENU
goto MAP_REPACK_MENU

:REPACK_WHITE_MAP
cls
%header_color%--- Repacking White Map ---[0m
echo.
set "WHITE_MAP_DIR=output_folder\map\White_Map"
set "DECRYPT_FILE=output_folder\map\decrypt_map.pak"

if not exist "%WHITE_MAP_DIR%" (
    %error_color%ERROR: White_Map folder not found.[0m
    pause
    goto MAP_REPACK_MENU
)

dir /b "%WHITE_MAP_DIR%\*.uasset" >nul 2>&1
if errorlevel 1 (
    %error_color%ERROR: No .uasset files found in White_Map.[0m
    pause
    goto MAP_REPACK_MENU
)

if not exist "%DECRYPT_FILE%" (
    %error_color%ERROR: decrypt_map.pak not found in map folder.[0m
    pause
    goto MAP_REPACK_MENU
)

%info_color%Running offzip to repack files...[0m
apps\offzip.exe -a -r "%DECRYPT_FILE%" "%WHITE_MAP_DIR%"
if errorlevel 1 (
    %error_color%ERROR: offzip repack failed.[0m
    pause
    goto MAP_REPACK_MENU
)

%info_color%Running QuickBMS repack...[0m
apps\quickbms.exe bms\repack.bms "%DECRYPT_FILE%" "output_folder\map"
if errorlevel 1 (
    %error_color%ERROR: QuickBMS repack failed.[0m
    pause
    goto MAP_REPACK_MENU
)

%info_color%Repack complete! File saved as encrypt_map.pak in map folder.[0m
pause
goto MAP_REPACK_MENU

:ZDISC_TOOL
cls
%header_color%--- Launching Zdisc Tool ---[0m
echo.
%info_color%Checking Python installation...[0m
python --version >nul 2>&1
if errorlevel 1 (
    %error_color%ERROR: Python is not installed or not added to PATH.[0m
    echo Please install Python from https://www.python.org/downloads/
    pause
    goto MENU
)
echo Python is installed.
echo Launching Rpad Zdisc Tool...
python "Rpad Zdisc Tool.py"
pause
goto MENU

:HELP
cls
mode con: cols=120 lines=45
echo.
echo [97m========================================================================================================[0m
%header_color%          PUBG RPAD TOOL - HELP[0m
echo [97m========================================================================================================[0m
echo.
%option_color%[1] Unpack (QuickBMS)[0m
%info_color%- Extracts .pak files using QuickBMS.[0m
%info_color%- Supports PUBG Mobile, PUBG Lite, and Zdisc versions.[0m
%info_color%- Extracted files are saved into the appropriate output folders.[0m
echo.
%option_color%[2] Repack[0m
%info_color%- Converts .uasset/.uexp files into .dat format.[0m
%info_color%- Uses files from the "repack" folder.[0m
%info_color%- Repack process runs via reimport.bat.[0m
echo.
%option_color%[3] Map Files Unpack (PUBG Mobile)[0m
%info_color%- Extracts map .pak files using QuickBMS and offzip.[0m
%info_color%- Output is saved under: output_folder\map[0m
echo.
%option_color%[4] Map Files Repack (PUBG Mobile)[0m
%info_color%- Repackages modified map folders into new .pak files.[0m
%info_color%- Available map mods:[0m
%info_color%  * White Map[0m
%info_color%  * No Grass (coming soon)[0m
%info_color%  * Dot Crosshair[0m
%info_color%  * Black Sky (coming soon)[0m
echo.
%option_color%[5] Map Tool[0m
%info_color%- Tools for customizing map files:[0m
%info_color%  * White Map: Removes most content to simplify map.[0m
%info_color%  * No Grass: Removes grass files (coming soon).[0m
%info_color%  * Dot Crosshair: Replaces crosshair with a dot.[0m
%info_color%  * Black Sky: Darkens the sky (coming soon).[0m
echo.
%option_color%[6] Delete Map Folder[0m
%info_color%- Deletes the output_folder\map directory.[0m
echo.
%option_color%[7] Delete Output Folder[0m
%info_color%- Deletes the output_folder completely and recreates it.[0m
echo.
%option_color%[8] Delete Zdisc Folder[0m
%info_color%- Clears the output_folderzdisc directory.[0m
echo.
%option_color%[9] Help[0m
%info_color%- Displays this help information.[0m
echo.
%option_color%[10] Join Telegram[0m
%info_color%- Opens the Telegram channel for updates and support.[0m
echo.
%option_color%[11] Exit[0m
%info_color%- Closes the tool.[0m
echo.
echo [97m========================================================================================================[0m
pause
goto MENU

:JOIN_TELEGRAM
cls
%header_color%--- Join Telegram ---[0m
echo.
%info_color%Opening Telegram channel...[0m
start https://t.me/RPADCOURSE
pause
goto MENU