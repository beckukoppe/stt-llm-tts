#!/bin/bash

set -e  # Exit on error
set -m  # Enable job control

echo "[INFO] Running setup..."
git pull
git submodule update --init --recursive
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

# Example: start another background process (e.g., dummy log monitor)
echo "[INFO] Starting auxiliary process..."
#python3 monitor_logs.py &  # Replace with real command/script

# Wait for all background jobs to complete
wait

docker stop coqui-tts
echo "[INFO] All processes finished."
