#!/bin/bash

set -e  # Exit on error
set -m  # Enable job control

docker ps --filter "ancestor=coqui-tts" -q | xargs -r docker kill

echo "[INFO] Running setup..."
git pull
git submodule update --init --recursive
git submodule foreach git fetch
git submodule foreach 'git pull origin $(git rev-parse --abbrev-ref HEAD)'
git submodule foreach 'git checkout main && git pull origin main'

# Check for CUDA compiler (nvcc) to determine if CUDA is available
if command -v nvcc &> /dev/null; then
    echo "✅ CUDA detected..."
    COQUI_PATH="./coqui-gpu"
else
    echo "⚠️ CUDA not detected..."
    COQUI_PATH="./coqui"
fi

cd "$COQUI_PATH"
./setup.sh &  # Background job
cd ../
cd ./whisper
./build.sh &  # Background job
cd ../

wait
echo "[INFO] Finished setup..."

echo "[INFO] Starting Coqui TTS server..."
cd "$COQUI_PATH"
./start.sh &  # Background job
cd ../

if [ ! -d "venv" ]; then
  echo "Creating virtual environment..."
  python -m venv venv
fi

if [ -z "$VIRTUAL_ENV" ]; then
  echo "Activating virtual environment..."
  source venv/bin/activate
  pip install -r requirements.txt
fi

clear

echo "[INFO] Starting main application"
python ./source/main.py

wait

