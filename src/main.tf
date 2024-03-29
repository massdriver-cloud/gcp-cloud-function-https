locals {
  runtime = module.cloud_functions.runtime
}

module "cloud_functions" {
  source  = "github.com/massdriver-cloud/terraform-modules//gcp-cloud-function?ref=c336d59"
  runtime = var.cloud_function_configuration.runtime
}

resource "google_cloudfunctions_function" "main" {
  name                  = var.md_metadata.name_prefix
  labels                = var.md_metadata.default_tags
  runtime               = local.runtime
  trigger_http          = true
  entry_point           = var.cloud_function_configuration.entrypoint
  available_memory_mb   = var.cloud_function_configuration.memory_mb
  min_instances         = var.cloud_function_configuration.minimum_instances
  max_instances         = var.cloud_function_configuration.maximum_instances
  source_archive_bucket = google_storage_bucket.main.name
  source_archive_object = google_storage_bucket_object.main.name

  # not exposed only to make the bundle "simpler"
  # default: 60  (s)
  # max    : 540 (s)
  timeout = 120

  depends_on = [
    module.apis
  ]
}

# TODO: make configurable "enable_pubic,is_public"
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.main.project
  region         = google_cloudfunctions_function.main.region
  cloud_function = google_cloudfunctions_function.main.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
