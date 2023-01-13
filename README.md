<!-- Copyright 2022 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     https://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. -->

# Alternate Email Sync 
This repository is provided as companion source code for the series of article published on Medium:
Alias synchronization from Azure Active Directory and Google Cloud Identity

## Disclaimer: 
This repository and its contents are not an official Google Product.

Please note that the proposed solution, the associated architecture and application code (Terraform/Workflow) are provided solely as an example and are not supported by Google in any way. It is not recommended to use this code as is in a production environment, as it has not been written or tested for this purpose. It is provided as a demonstration of a technical solution only. Its use or modification, in whole or in part, is your responsibility."

## Objectives
Get alternate email synchronization between Azure Active Directory and Google Cloud Identity

When new Azure Active Directories identities are synced to Cloud Identity, **there is no way to set up an mapping/sync for alias email as the AAD application does not support it.**

Thus the objective is to offer a workaround based on the following steps :

1. Detect identity creation / modification through Admin Logs
2. Filter and Sink the Admin Logs to a Pub/Sub topic
3. that launch an EventArc trigger
4. calling a Workflow 
5. where it gets externalIds["LOGIN_ID"] as mail value on AAD
6. and eventually set alias email with this value.

Please note that there are 2 different workflows:
- one when the identity is created : google.admin.AdminService.createUser event
- one when the externalIds["LOGIN_ID"] is changed : google.admin.AdminService.changeUserExternalId event

## Pre-requisites

### Activate Shared Data / Logs to GCP 
Follow [Share data with Google Cloud services - Google Workspace Admin Help](https://support.google.com/a/answer/9320190)
Logs store at organizations/{OrgId}/logs/cloudaudit.googleapis.com%2Factivity

### Create a custom role to read an User Identity and set the alias email
Follow [Create, edit, and delete custom admin roles](https://support.google.com/cloudidentity/answer/2406043?hl=en) to create a custom role with :
- Users>Read
- Users>Update>Add/Remove Aliases

### Custom role assignement to the service account executing the workflow
Assign this custom role to the executing workflow service account. Operation need to be done in the [admin console](https://admin.google.com/). 
Warning: this operation can be done only after deployment.

## How-to deploy
The terraform deployment create a new project and instanciate all the different components of the solution.

Thus, you should add a .tfvars file , with at least a value for :
- organization_id
- folder_id
- project_id
- billing_account_id

Please check and modify the backend.tf file to fill the correct value for your TFState backend.

Then you can proceed with the infrastructure definition like any other terraform code.

# License
All solutions within this repository are provided under the [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) license. Please see the [LICENSE](https://github.com/GoogleCloudPlatform/smart-expenses/blob/main/LICENSE) file for more detailed terms and conditions.