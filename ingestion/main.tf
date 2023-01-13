# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

####################################################################################################
# Ingestion module manages all resources related to the logs ingestion up to the events publishing.#
####################################################################################################

# Pub/sub topic receiving events message from Logs
resource "google_pubsub_topic" "topic" {
  project = var.project_id
  name    = "${var.resource_name}-topic"

  message_storage_policy {
    allowed_persistence_regions = [
      var.region,
    ]
  }
}

# Sink publishing Logs events on a pub/sub topic
resource "google_logging_organization_sink" "sink" {
  name        = "${var.resource_name}-sink"
  description = "Sink Admin logs to a dedicated topic for ${var.description_name}"
  org_id      = var.organization_id
  destination = "pubsub.googleapis.com/${google_pubsub_topic.topic.id}"
  filter      = var.sink_filter
}

# To allow the sink to publish on a pub/sub topic
resource "google_project_iam_member" "sink-log-writer" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = google_logging_organization_sink.sink.writer_identity
}