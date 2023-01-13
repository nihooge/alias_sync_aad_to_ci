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

variable "resource_name" {
  description = "Name used for naming resource definition"
  type        = string
}

variable "description_name" {
  description = "Name used for description on resource definition"
  type        = string
}

variable "sink_filter" {
  description = "Organization Sink filter definition"
  type        = string
}

variable "organization_id" {
  description = "The resource id of the targeted Organization"
  type        = string
}

variable "project_id" {
  description = "The resource id of the solution Project"
  type        = string
}

variable "region" {
  description = "The targeted region for deployement"
  type        = string
}