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

###########
# Project #
###########

resource "google_project" "alternate_email_sync" {
  name            = var.project_id
  project_id      = var.project_id
  folder_id       = data.google_folder.folder.name
  billing_account = data.google_billing_account.ba.id
}

module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.0"

  project_id  = google_project.alternate_email_sync.project_id
  enable_apis = var.enable_apis

  activate_apis = [
    "eventarc.googleapis.com",
    "workflows.googleapis.com",
    "workflowexecutions.googleapis.com",
    "admin.googleapis.com", # For user management
    "logging.googleapis.com",
    "pubsub.googleapis.com",
  ]
  disable_services_on_destroy = false
}

#############
# Ingestion #
#############

# Create the infrastructure/services for the ingestion of user creation events 
module "user-creation-ingestion" {
  source = "./ingestion"

  resource_name    = "user-creation"
  description_name = "user creation events"
  region           = var.region
  project_id       = google_project.alternate_email_sync.project_id
  organization_id  = var.organization_id
  sink_filter      = "protoPayload.serviceName=\"admin.googleapis.com\" AND protoPayload.methodName=\"google.admin.AdminService.createUser\""

  depends_on = [
    module.project-services
  ]
}

# Create the infrastructure/services for the ingestion of user creation events 
module "externalid-update-ingestion" {
  source = "./ingestion"

  resource_name    = "externalid-update"
  description_name = "externalId update events"
  region           = var.region
  project_id       = google_project.alternate_email_sync.project_id
  organization_id  = var.organization_id
  sink_filter      = "protoPayload.serviceName=\"admin.googleapis.com\" AND protoPayload.methodName:\"google.admin.AdminService.changeUserExternalId\" AND protoPayload.metadata.event.parameter.value=~\"LOGIN_ID:\""

  depends_on = [
    module.project-services
  ]
}

##############
# Processing #
##############
module "user-creation-processing" {
  source = "./processing"

  resource_name    = "user-creation"
  description_name = "user creation events"
  region           = var.region
  project_id       = google_project.alternate_email_sync.project_id
  topic_id         = module.user-creation-ingestion.topic_id
  workflow_definition_filename = "worflows/user-creation.yaml"

  depends_on = [
    module.project-services,
    module.user-creation-ingestion
  ]
}

module "externalid-update-processing" {
  source = "./processing"

  resource_name    = "externalid-update"
  description_name = "externalId update events"
  region           = var.region
  project_id       = google_project.alternate_email_sync.project_id
  topic_id         = module.externalid-update-ingestion.topic_id
  workflow_definition_filename = "worflows/externalid-update.yaml"

  depends_on = [
    module.project-services,
    module.externalid-update-ingestion
  ]
}