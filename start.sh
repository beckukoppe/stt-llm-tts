#!/bin/bash

set -e  # Exit on error
set -m  # Enable job control

echo "[INFO] Running setup..."
git pull
git submodule update --init --recursive

cd ./coqui
./setup.sh &  # Background job
cd ../
cd ./whisper
./build.sh &  # Background job
cd ../

wait
echo "[INFO] Finished setup..."

echo "[INFO] Starting Coqui TTS server..."
cd ./coqui
./start.sh &  # Background job
cd ../

# Example: start another background process (e.g., dummy log monitor)
echo "[INFO] Starting auxiliary process..."
#python3 monitor_logs.py &  # Replace with real command/script

# Wait for all background jobs to complete
wait

docker stop coqui-tts
echo "[INFO] All processes finished."
