## Google Cloud Functions - HTTPS

Google Cloud Functions is a serverless execution environment for building and connecting cloud services. With Cloud Functions, you can write simple, single-purpose functions that are attached to events emitted from your cloud infrastructure and services. The HTTPS trigger allows these functions to be accessed via HTTP requests, providing a flexible and scalable way to handle webhooks, APIs, or any other HTTP-based use case.

### Design Decisions

The following design decisions were made to ensure a smooth and efficient management of Google Cloud Functions with HTTPS triggers:

1. **Service Enablement**: This module automatically enables the necessary Google Cloud APIs (`cloudbuild.googleapis.com` and `cloudfunctions.googleapis.com`) to ensure all required services are available.
2. **Storage Provisioning**: A Google Cloud Storage (GCS) bucket is created to store the application code in a zip format, acting as a deployment source for the Cloud Function.
3. **DNS Management**: The module includes DNS setup to provide a custom domain for accessing the Cloud Function, utilizing Google Cloud DNS.
4. **SSL Configuration**: Automatic SSL certificate management is configured to secure the HTTPS endpoint.
5. **IAM Roles**: Public access is configured by assigning the `roles/cloudfunctions.invoker` role to `allUsers`, allowing anyone to invoke the function via the provided HTTPS endpoint.
6. **Resource Dependency Management**: Dependencies between resources are explicitly defined to ensure proper sequence in resource creation and configuration.

### Runbook

#### Issue: Function Deployment Failed

Deployment issues can occur due to various reasons such as missing required APIs or incorrect IAM roles. To investigate and resolve such issues, follow these steps:

Check the Cloud Build logs to identify deployment-related errors:

```sh
gcloud builds list --filter "source.repoSource.repoName=<REPO_NAME>"
```

Review the logs from a specific build:

```sh
gcloud builds log <BUILD_ID>
```

Look for errors related to permissions or configuration. If any service API is missing, ensure they are enabled:

```sh
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

#### Issue: Function Invocation Errors

If your Cloud Function returns errors when invoked, use the following steps to diagnose the issue:

1. **Check Logs in Google Cloud Console**:

Navigate to Cloud Functions in the Google Cloud Console, select your function, and go to the Logs tab. Look for specific errors or stack traces indicating what went wrong during invocation.

2. **Using `gcloud` CLI**:

Fetch the logs for your function using the `gcloud` CLI:

```sh
gcloud functions logs read <FUNCTION_NAME> --region=<REGION>
```

This will display the logs for your function, showing any errors that occurred during execution.

#### Issue: DNS Resolution Problems

If your custom domain is not resolving correctly to the Cloud Function, check the DNS record settings:

1. List DNS records for your managed zone:

```sh
gcloud dns record-sets list --zone=<ZONE_NAME>
```

Ensure that the A record is correctly pointing to the IP address of your Cloud Function's HTTPS forwarding rule.

2. Verify the forwarding rule's IP address:

```sh
gcloud compute forwarding-rules describe <FORWARDING_RULE_NAME> --global
```

Make sure the IP address matches the one in your DNS A record configuration.

#### Issue: SSL Certificate Errors

If there are issues with SSL certificate provisioning or validation, check the certificate status:

```sh
gcloud compute ssl-certificates list --filter="name=<CERTIFICATE_NAME>"
```

If the certificate is not active or has pending validation, ensure that the domain is correct and publicly accessible.

