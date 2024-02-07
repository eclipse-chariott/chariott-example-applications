#!/bin/bash
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.
# SPDX-License-Identifier: MIT

# After running build-all-containers.sh, this script can be used to run the demo with all services
# running as containers. **Note: you must build the intent_brokering container with tag "1" before
# running this script as well. It starts all services as containers, but runs local object
# detection and the Dog Mode UI locally (not in containers). Logs can be found in target/logs.

set -e

docker run --network=host intent_brokering:1 > target/logs/intent_brokering.txt 2>&1 &

sleep 2

docker run --network=host -e ANNOUNCE_URL=http://localhost:50051 mock-vas:1 > target/logs/mock_vas.txt 2>&1 & # DevSkim: ignore DS162092
docker run --network=host -e ANNOUNCE_URL=http://localhost:50064 kv-app:1 > target/logs/kv_app.txt 2>&1 & # DevSkim: ignore DS162092
docker run --network=host -e ANNOUNCE_URL=http://localhost:50066 simulated-camera-app:1 > target/logs/simulated_camera_app.txt 2>&1 & # DevSkim: ignore DS162092
TENSORFLOW_LIB_PATH="$(dirname $(find target -name libtensorflow.so -printf '%T@\t%p\n' | sort -nr | cut -f 2- | head -1))"
LIBRARY_PATH=$TENSORFLOW_LIB_PATH LD_LIBRARY_PATH=$TENSORFLOW_LIB_PATH CATEGORIES_FILE_PATH=./intent_brokering/dogmode/applications/local-object-detection/models/categories.json ANNOUNCE_URL=http://localhost:50061  ./target/debug/local-object-detection-app > target/logs/local_object_detection_app.txt 2>&1 & # DevSkim: ignore DS162092

sleep 5

docker run --network=host dog-mode-logic-app:1 > target/logs/dog_mode_logic_app.txt 2>&1 &

sleep 2

dotnet run --project ./intent_brokering/dogmode/applications/dog-mode-ui/src > ./target/logs/ui.txt 2>&1 &

