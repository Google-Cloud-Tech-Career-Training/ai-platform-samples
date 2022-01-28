#!/bin/bash
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This has to be run after train-cloud.sh is successfully executed

REGION="us-central1" # choose a GCP region, e.g. "us-central1". Choose from https://cloud.google.com/ai-platform/training/docs/regions
BUCKET_NAME="" # TODO Change BUCKET_NAME to your bucket name

MODEL_NAME="my_first_keras_model" # change to your model name, e.g. "estimator"
MODEL_VERSION="v1" # change to your model version, e.g. "v1"

# Model Binaries corresponds to the tf.estimator.FinalExporter configuration in trainer/experiment.py
MODEL_BINARIES=gs://${BUCKET_NAME}/keras-job-dir/keras_export/
PYTHON_VERSION=3.7
RUNTIME_VERSION=2.1

gsutil ls ${MODEL_BINARIES}

# Delete model version, if previous model version exist.
gcloud ai-platform versions delete ${MODEL_VERSION} --model=${MODEL_NAME} --region="${REGION}"

# Delete model, if previous model exist.
gcloud ai-platform models delete ${MODEL_NAME} --region="${REGION}"

# Deploy model to GCP using regional endpoints.
gcloud ai-platform models create "${MODEL_NAME}" --region="${REGION}"

# Deploy model version
gcloud beta ai-platform versions create ${MODEL_VERSION} \
 --model=${MODEL_NAME} \
 --region $REGION \
 --framework TENSORFLOW \
 --origin=${MODEL_BINARIES} \
 --python-version=${PYTHON_VERSION} \
 --runtime-version=${RUNTIME_VERSION} \
 --machine-type "n1-highcpu-2"

# Test predictions
gcloud ai-platform predict \
  --model tf2 \
  --version v1 \
  --json-instances ../data/input.json
