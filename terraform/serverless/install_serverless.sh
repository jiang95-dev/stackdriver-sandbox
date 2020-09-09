# Copyright 2020 Google LLC
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
#!/bin/bash

upload_source_code(){
    if [[ -n $1 ]]; then
        source_name="ratingservice_code:$1.zip"
    else
        source_name="ratingservice_code:latest.zip"
    fi
    zip -j ${source_name} ../../src/ratingservice/main.py ../../src/ratingservice/requirements.txt ../../src/productcatalogservice/products.json
    gsutil cp ${source_name} "gs://$GOOGLE_CLOUD_PROJECT-bucket/${source_name}"
}

upload_source_code $1;