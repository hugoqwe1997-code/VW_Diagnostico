@echo off
title VW INFORMATICA - Diagnostico e Reparo v3.6
color 0B
echo.
echo   ===================================================
echo    VW INFORMATICA - Diagnostico e Reparo v3.6
echo    Xique-Xique/BA  -  (74) 99937-8375
echo   ===================================================
echo.
echo    Baixando e executando do GitHub...
echo    Aguarde...
echo.
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command \"iex ((New-Object Net.WebClient).DownloadString(''https://raw.githubusercontent.com/hugoqwe1997-code/VW_Diagnostico/main/VW_Diagnostico.ps1''))\"'"
