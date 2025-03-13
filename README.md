# Terraform Google Cloud BigQuery Module

Terraform module to deploy BigQuery resources in Google Cloud Platform (GCP), providing a foundation for data warehousing and analytics.

## Overview

This repository provides a Terraform module to easily set up the following BigQuery resources within a GCP project:

1.  **Google Cloud Project:** Creates a new GCP project (optional, you can use an existing project).
2.  **BigQuery Datasets:** Provisions two datasets:
    *   `staging_dataset_bitcoin`: Designed for staging data before transformation.
    *   `mart_dataset_bitcoin_cash`: Intended for your data mart, holding transformed and optimized data.
3.  **Service Account:** Creates a dedicated service account (`bigquery-service-account`) with the necessary permissions to interact with BigQuery:
    *   `roles/bigquery.jobUser`:  Allows the service account to run BigQuery jobs (queries, loads, etc.) within the project.
    *   `roles/bigquery.dataEditor`: Grants the service account permission to create, modify, and delete tables within both the staging and mart datasets.
4.  **Service Account Key (Optional):**  Provides an option to download the service account key file (disabled by default). This is crucial for applications like dbt that need to authenticate with BigQuery.

## Prerequisites

Before using this module, ensure you have the following:

1.  **Google Cloud Account:** A Google Cloud Platform account. If you don't have one, sign up for the [Google Cloud Free Tier](https://cloud.google.com/free).

2.  **Google Cloud SDK (gcloud):** The `gcloud` command-line interface installed and configured.  Follow the installation instructions for your operating system: [Install the Google Cloud SDK](https://cloud.google.com/sdk/docs/install).

    *   **Authentication:** Authenticate `gcloud` with an account that has sufficient permissions to create projects, service accounts, and BigQuery resources.  The "Project Owner" role is generally sufficient. If you are creating a *new* project, you will also need permissions at the organization or folder level:
        *   `resourcemanager.projects.create`
        *   `billing.resourceAssociations.create` (if you are associating a billing account during project creation)

    *   **Application Default Credentials:**  Set up Application Default Credentials so Terraform can authenticate:

        ```bash
        gcloud auth application-default login
        ```

3.  **Terraform:** Terraform version 1.3 or later installed on your system. Installation instructions: [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

## Usage

1.  **Clone the Repository:**

    ```bash
    git clone https://github.com/MohamedDiar/gcp-terraform-challenge.git 
    cd https://github.com/MohamedDiar/gcp-terraform-challenge.git
    ```

2.  **Terraform Backend (Choose One):**

    *   **Terraform Cloud (Default) or cloud backend such as AWS s3 or GCP GCS:** I used Terraform Cloud as a remote backend.  Ensure you are logged in to Terraform Cloud if you want to use it. [HCP Terraform Cloud](https://developer.hashicorp.com/hcp) :

        ```bash
        terraform login
        ```

    *   **Local Backend (Alternative):** If you prefer to manage state locally, comment out the `cloud` block in `backends.tf` and uncomment the `local` backend configuration.  Adjust the `path` in the `local` block if necessary.
       
3.  **Customize Variables:**

    You can customize the module's behavior by modifying the default variable values.  While you can directly edit the `variables.tf` file in the root directory, the recommended approach is to create a separate `terraform.tfvars` file (or a file with a `.tfvars` extension, like `my-project.tfvars`) to override the defaults.  This keeps your customizations separate from the module's core code and makes updates easier.

    Review and modify at least the following variables in your `.tfvars` file:

    *   `project_name`: (Default: `"astrafy-project"`)  A descriptive name for your GCP project.
    *   `project_id`: (Default: `"astrafy-challenge-0001"`) The unique ID for your project.  **This must be globally unique across all of Google Cloud.**
    *   `billing_account`: (Default: `null`) Your billing account ID. If left as `null`, you *must* manually link a billing account to the project after creation through the Google Cloud Console.
    *   `organization_id`: (Default: `null`)  The ID of your Google Cloud organization, if applicable.  Set to `null` if you are not using an organization.
    *   `deletion_policy`: (Default: `"DELETE"`)  Controls what happens to the project when you run `terraform destroy`.
        *   `"DELETE"`:  The project *will* be deleted.
        *   `"PREVENT"`: The project will *not* be deleted, preventing accidental deletion.
    *   `dataset_staging_id`: (Default: `"staging_dataset_bitcoin"`)  The ID for your staging dataset.
    *   `dataset_mart_id`: (Default: `"mart_dataset_bitcoin_cash"`) The ID for your data mart dataset.
    *   `dataset_location`: (Default: `"US"`) The geographic location for your BigQuery datasets (e.g., `"US"`, `"EU"`, `"asia-northeast1"`). Choose a location that meets your latency, compliance, and pricing requirements.
    *   `download_service_account_key`: (Default: `false`)  **Crucially for dbt users:** Set this to `true` if you need to download the service account key file.  This is required for dbt and other external applications to connect to BigQuery and being able write to it.
    *   `service_account_key_path`: (Default: `"~/.dbt/service-account-key.json"`)  If `download_service_account_key` is `true`, this specifies where the key file will be saved.  The default path is commonly used by dbt.

    **Example `terraform.tfvars`:**

    ```terraform
    project_id      = "my-unique-project-id"
    billing_account = "1234-5678-ABCD-EFGH"
    dataset_location = "EU"
    download_service_account_key = true
    ```

    When you run `terraform plan`, Terraform automatically loads variables from `terraform.tfvars`.  If you use a different filename (e.g., `my-project.tfvars`), you'll need to specify it using the `-var-file` option:

    ```bash
    terraform plan -var-file=my-project.tfvars
    terraform apply
    ```

    

4.  **Initialize and Apply:**

    Run the following commands to initialize Terraform and apply the configuration:

    ```bash
    terraform init
    terraform plan
    terraform apply
    ```

    Terraform will display a plan of the resources to be created.  Review the plan carefully.  Type `yes` and press Enter to confirm and create the resources.

5.  **Destroy Resources (Optional):**

    To remove all resources created by this module, run:

    ```bash
    terraform destroy
    ```

    **Important:** If `deletion_policy` is set to `"DELETE"` (the default), this will *permanently delete* the GCP project and all its contents.

## Important Notes

*   **Service Account Key Download (dbt Users):**  The `download_service_account_key` variable controls whether the service account key is downloaded.  By default, it's `false`. For dbt integration, set it to `true` and configure `service_account_key_path` to match your dbt profile (typically `~/.dbt/profiles.yml`).  **Store the downloaded key file securely; it grants access to your BigQuery data.**

*   **Deletion Policy:** Understand the `deletion_policy` variable.  The default (`"DELETE"`) means `terraform destroy` will delete the project.  Change it to `"PREVENT"` to avoid accidental project deletion.

*   **Project ID Uniqueness:** Your `project_id` *must* be globally unique.  If you encounter an error during `terraform apply` indicating the ID is already in use, choose a different one.

*   **Billing Account:** If you don't provide a `billing_account`, the project will be created, but you migh be restricted in terms ostorage for GCP BigQuery.

*   **Resource Naming:**  The default names (datasets, service account) are suggestions.  Customize them in `variables.tf` as needed (adjust dbt project as needed).


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.24.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.5.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.24.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp_bigquery"></a> [gcp\_bigquery](#module\_gcp\_bigquery) | ./modules/gcp-bigquery | n/a |
| <a name="module_gcp_project"></a> [gcp\_project](#module\_gcp\_project) | ./modules/gcp-project | n/a |

## Resources

## Resources

| Name | Type |
|------|------|
| [google_bigquery_dataset.mart_dataset](https://registry.terraform.io/providers/hashicorp/google/6.24.0/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset.staging_dataset](https://registry.terraform.io/providers/hashicorp/google/6.24.0/docs/resources/bigquery_dataset) | resource |
| [google_bigquery_dataset_iam_member.mart_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam) | resource |
| [google_bigquery_dataset_iam_member.staging_editor](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset_iam) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project.html) | resource |
| [google_project_iam_member.bigquery_job_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam) | resource |
| [google_project_service.bigquery](https://registry.terraform.io/providers/hashicorp/google/6.24.0/docs/resources/google_project_service) | resource |
| [google_service_account.bigquery_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account) | resource |
| [google_service_account_key.bigquery_key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_key) | resource |
| [local_file.bigquery_key_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The billing account ID to associate with the project | `string` | `null` | no |
| <a name="input_dataset_location"></a> [dataset\_location](#input\_dataset\_location) | Location for the BigQuery datasets | `string` | `"US"` | yes |
| <a name="input_dataset_mart_id"></a> [dataset\_mart\_id](#input\_dataset\_mart\_id) | ID for the data mart dataset | `string` | `"mart_dataset_bitcoin_cash"` | yes |
| <a name="input_dataset_staging_id"></a> [dataset\_staging\_id](#input\_dataset\_staging\_id) | ID for the staging dataset | `string` | `"staging_dataset_bitcoin"` | no |
| <a name="input_deletion_policy"></a> [deletion\_policy](#input\_deletion\_policy) | The deletion policy for the GCP project | `string` | `"DELETE"` | no |
| <a name="input_download_service_account_key"></a> [download\_service\_account\_key](#input\_download\_service\_account\_key) | Whether to download the service account key | `bool` | `false` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | The organization ID | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the GCP project to create | `string` | `"astrafy-challenge-0001"` | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the GCP project to create | `string` | `"astrafy-project"` | yes |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | ID for the BigQuery service account | `string` | `"bigquery-service-account"` | yes |
| <a name="input_service_account_key_path"></a> [service\_account\_key\_path](#input\_service\_account\_key\_path) | Path to save the service account key | `string` | `"~/.dbt/service-account-key.json"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_id_out"></a> [project\_id\_out](#output\_project\_id\_out) | n/a |
