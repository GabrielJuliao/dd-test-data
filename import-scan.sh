#!/bin/bash

# Function to import scan results into DefectDojo
import_scan_to_defectdojo() {
  local DEFECTDOJO_URL="$1"
  local API_TOKEN="$2"
  local PRODUCT_NAME="$3"
  local ENGAGEMENT_NAME="$4"
  local SCAN_FILE="$5"
  local SCAN_TYPE="$6"
  local SERVICE="$7"

  # Check if the scan file exists
  if [ ! -f "$SCAN_FILE" ]; then
    echo "Error: Scan file $SCAN_FILE not found."
    return 1
  fi

   # Determine endpoint based on isFirstImport
  local endpoint
  if [ "$IS_FIRST_IMPORT" = "true" ]; then
    endpoint="$DEFECTDOJO_URL/api/v2/import-scan/"
  else
    endpoint="$DEFECTDOJO_URL/api/v2/reimport-scan/"
  fi

  # Send POST request to import or reimport scan
  curl -s --fail \
    -X POST "$endpoint" \
    -H "Authorization: Token $API_TOKEN" \
    -H "Content-Type: multipart/form-data" \
    -F "scan_date=$(date +%Y-%m-%d)" \
    -F "minimum_severity=Info" \
    -F "active=true" \
    -F "verified=true" \
    -F "scan_type=$SCAN_TYPE" \
    -F "product_name=$PRODUCT_NAME" \
    -F "engagement_name=$ENGAGEMENT_NAME" \
    -F "service=$SERVICE" \
    -F "tags=$SERVICE" \
    -F "file=@$SCAN_FILE" \
    -F "close_old_findings=false" \
    -F "push_to_jira=false"

  if [ $? -eq 0 ]; then
    echo "Imported $SCAN_FILE (service: $SERVICE) successfully."
    return 0
  else
    echo "Failed to import $SCAN_FILE (service: $SERVICE)."
    return 1
  fi
}

# Configuration
DEFECTDOJO_URL="https://demo.defectdojo.org/"  # Replace with your DefectDojo URL
API_TOKEN=""                       # Replace with your API token
PRODUCT_NAME="My Product"                     # Replace with your product name
ENGAGEMENT_NAME="My Product CI/CD Engagement"               # Replace with your engagement name
SCAN_FOLDER="va-scans"                               # Folder with scan files
IS_FIRST_IMPORT="true"                              # Set to "true" for import-scan, "false" for reimport-scan

# Check if folder exists
if [ ! -d "$SCAN_FOLDER" ]; then
  echo "Error: Folder $SCAN_FOLDER not found."
  exit 1
fi

# Initialize counters
imported=0
failed=0

# Process Trivy files first
for scan_file in "$SCAN_FOLDER"/*-trivy.json; do
  if [ -f "$scan_file" ]; then
    # Extract service name (e.g., 'svc-a' from 'svc-a-1.0.0-199-trivy.json')
    service=$(basename "$scan_file" | sed -E 's/(svc-[^-]+)-.+-.+\.json/\1/')
    echo "Processing Trivy scan: $scan_file (service: $service)..."
    import_scan_to_defectdojo "$DEFECTDOJO_URL" "$API_TOKEN" "$PRODUCT_NAME" \
      "$ENGAGEMENT_NAME" "$scan_file" "Trivy Scan" "$service"
    if [ $? -eq 0 ]; then
      ((imported++))
    else
      ((failed++))
    fi
  fi
done

# Process Grype files next
for scan_file in "$SCAN_FOLDER"/*-grype.json; do
  if [ -f "$scan_file" ]; then
    # Extract service name (e.g., 'svc-a' from 'svc-a-1.0.0-199-grype.json')
    service=$(basename "$scan_file" | sed -E 's/(svc-[^-]+)-.+-.+\.json/\1/')
    echo "Processing Grype scan: $scan_file (service: $service)..."
    import_scan_to_defectdojo "$DEFECTDOJO_URL" "$API_TOKEN" "$PRODUCT_NAME" \
      "$ENGAGEMENT_NAME" "$scan_file" "Anchore Grype" "$service"
    if [ $? -eq 0 ]; then
      ((imported++))
    else
      ((failed++))
    fi
  fi
done

# Check if any files were processed
if [ $imported -eq 0 ] && [ $failed -eq 0 ]; then
  echo "No *-trivy.json or *-grype.json files found in $SCAN_FOLDER."
  exit 1
fi

# Summary
echo "Test import completed: $imported files imported, $failed files failed."