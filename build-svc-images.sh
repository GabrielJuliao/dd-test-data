#!/bin/bash
# This script builds Docker images for multiple services.
(cd svc-images/svc-a && docker build -t svc-a:1.0.0 .)

(cd svc-images/svc-b && docker build -t svc-b:2.0.1 .)

(cd svc-images/svc-c && docker build -t svc-c:2.0.2 .)


# mkdir -p va-scans
# rm -rf va-scans/*

# trivy image svc-a:1.0.0 -f json -o va-scans/svc-a-1.0.0-199-trivy.json
# trivy image svc-b:2.0.1 -f json -o va-scans/svc-b-2.0.1-199-trivy.json
# trivy image svc-c:2.0.2 -f json -o va-scans/svc-c-2.0.2-199-trivy.json

# grype svc-a:1.0.0 -o json --file va-scans/svc-a-1.0.0-199-grype.json
# grype svc-b:2.0.1 -o json --file va-scans/svc-b-2.0.1-199-grype.json
# grype svc-c:2.0.2 -o json --file va-scans/svc-c-2.0.2-199-grype.json