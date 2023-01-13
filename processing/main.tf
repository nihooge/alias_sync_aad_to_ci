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
# Processing module manages all resources related to the processing triggered by events.#
####################################################################################################

# Resources linked to the Eventarc Service Account
resource "google_service_account" "eventarc_trigger_sa" {
  project      = var.project_id
  account_id   = "eventarc-${var.resource_name}-sa"
  display_name = "Service Account listening to events and invoking the workflow on  ${var.description_name}"
}

resource "google_project_iam_member" "eventarc_user" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.eventarc_trigger_sa.email}"
}

resource "google_project_iam_member" "workflow_user" {
  project = var.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.eventarc_trigger_sa.email}"
}

# Eventarc
resource "google_eventarc_trigger" "trigger" {
  project  = var.project_id
  name     = "${var.resource_name}-trigger"
  location = var.region
  matching_criteria {
    attribute = "type"
    value     = "google.cloud.pubsub.topic.v1.messagePublished"
  }
  destination {
    workflow = google_workflows_workflow.worflow.id
  }
  transport {
    pubsub {
      topic = var.topic_id
    }
  }
  service_account = google_service_account.eventarc_trigger_sa.id

  depends_on = [
    google_workflows_workflow.worflow
  ]
}

# Resources linked to the Workflow Service Account
resource "google_service_account" "workflow_sa" {
  project      = var.project_id
  account_id   = "workflow-${var.resource_name}-sa"
  display_name = "Service Account executing the alternate email sync workflow processing on ${var.description_name} "
}

resource "google_project_iam_member" "log_user" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.workflow_sa.email}"
}

resource "google_workflows_workflow" "worflow" {
  project         = var.project_id
  name            = "set-alternate-email-from-${var.resource_name}-worflow"
  region          = var.region
  description     = "Workflow fixing the alias email based on ${var.description_name}"
  service_account = google_service_account.workflow_sa.id
  source_contents = file("${path.root}/${var.workflow_definition_filename}")
}