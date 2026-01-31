#!/bin/bash
# Google Cloud Run deployment script for OCL Network Landing Page
# Prerequisites: gcloud CLI installed and authenticated

set -e

PROJECT_ID="${GOOGLE_CLOUD_PROJECT:-gemini-ocl-network}"
SERVICE_NAME="ocl-network-landing"
REGION="${REGION:-us-central1}"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

echo "🚀 Deploying OCL Network Landing Page to Google Cloud Run"
echo "Project: ${PROJECT_ID}"
echo "Service: ${SERVICE_NAME}"
echo "Region: ${REGION}"
echo ""

# Check if gcloud is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" > /dev/null 2>&1; then
    echo "❌ Error: gcloud is not authenticated"
    echo "Please run: gcloud auth login"
    exit 1
fi

# Set the project
echo "🔧 Setting GCP project..."
gcloud config set project ${PROJECT_ID}

# Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable cloudbuild.googleapis.com run.googleapis.com --quiet

# Build Docker image using Cloud Build
echo "📦 Building Docker image with Cloud Build..."
gcloud builds submit --tag ${IMAGE_NAME}:latest .

# Deploy to Cloud Run
echo "🌐 Deploying to Cloud Run..."
gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME}:latest \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  --port 8080 \
  --memory 128Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 10 \
  --timeout 300

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Your landing page is now live at:"
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)')
echo "${SERVICE_URL}"
echo ""
echo "📋 Next steps:"
echo "1. Test the deployment: curl ${SERVICE_URL}/health"
echo "2. View in browser: open ${SERVICE_URL}"
echo "3. To map a custom domain (ocl.network), run:"
echo "   gcloud run domain-mappings create --service=${SERVICE_NAME} --domain=ocl.network --region=${REGION}"
echo "4. Update DNS records in GoDaddy:"
echo "   - Type: CNAME"
echo "   - Name: @"
echo "   - Value: ghs.googlehosted.com"
echo ""
