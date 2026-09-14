@echo off
cd /d "%~dp0"
echo Lifex-AI — flutter pub get then test
flutter pub get
flutter test
echo If Android wrapper is missing: flutter create . --project-name lifex_ai --org com.lifex_ai --platforms android
pause
