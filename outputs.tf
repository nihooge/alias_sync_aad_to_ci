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

output "project_id" {
  value       = google_project.alternate_email_sync.name
  description = "Project resource id"
}

# User Creation Outputs
output "user-creation-topic_id" {
  value       = module.user-creation-ingestion.topic_id
  description = "User Creation topic resource id"
}

output "user-creation-eventarc_trigger_sa_mail" {
  value       = module.user-creation-processing.eventarc_trigger_sa_mail
  description = "Service Account email running on the Eventarc trigger used on user creation events"
}

output "user-creation-worflow_sa_mail" {
  value       = module.user-creation-processing.workflow_sa_mail
  description = "Service Account email running on the Eventarc trigger used on user creation events"
}

output "user-creation-workflow_id" {
  value       = module.user-creation-processing.workflow_id
  description = "User Creation workflow resource id"
}


# ExternalId update Outputs
output "externalid-update-topic_id" {
  value       = module.externalid-update-ingestion.topic_id
  description = "External Id update topic resource id"
}

output "externalid-update-eventarc_trigger_sa_mail" {
  value       = module.externalid-update-processing.eventarc_trigger_sa_mail
  description = "Service Account email running on the Eventarc trigger used on externalid update events"
}

output "externalid-update-worflow_sa_mail" {
  value       = module.externalid-update-processing.workflow_sa_mail
  description = "Service Account email running on the Eventarc trigger used on externalid update events"
}

output "externalid-update-workflow_id" {
  value       = module.externalid-update-processing.workflow_id
  description = "External Id update workflow resource id"
}