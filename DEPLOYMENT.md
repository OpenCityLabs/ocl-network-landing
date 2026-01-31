# OCL Network Landing Page - Cloud Run Deployment

## Deployment Summary

**Status:** ✅ Successfully deployed to Google Cloud Run

**Service Details:**
- Service Name: `ocl-network-landing`
- Project: `gemini-ocl-network`
- Region: `us-central1`
- Cloud Run URL: https://ocl-network-landing-280959614840.us-central1.run.app
- Custom Domain: `ocl.network` (pending DNS configuration)

**Resources:**
- Memory: 128Mi
- CPU: 1
- Min Instances: 0
- Max Instances: 10
- Port: 8080

## Testing

The deployment has been verified:

```bash
# Health check endpoint
curl https://ocl-network-landing-280959614840.us-central1.run.app/health
# Response: healthy

# Main page
curl https://ocl-network-landing-280959614840.us-central1.run.app/
# Response: Full HTML page loads correctly
```

## DNS Configuration Required

To make the landing page accessible at `ocl.network`, you need to update DNS records in GoDaddy.

### Current DNS Status

```
✔ api.ocl.network      → ocl-python-api          (active)
✔ demo.ocl.network     → ocl-python-api          (active)
✔ docs.ocl.network     → ocl-ai-governance-docs  (active)
… ocl.network          → ocl-network-landing     (waiting for DNS)
✔ staging.ocl.network  → ocl-python-api-staging  (active)
```

### GoDaddy DNS Configuration Steps

1. Log in to GoDaddy DNS Management for `ocl.network`
2. **Update or add the following A records for the root domain (@):**

   **Replace existing GitHub Pages A records with Cloud Run A records:**

   | Type | Name | Value           | TTL |
   |------|------|-----------------|-----|
   | A    | @    | 216.239.32.21   | 600 |
   | A    | @    | 216.239.34.21   | 600 |
   | A    | @    | 216.239.36.21   | 600 |
   | A    | @    | 216.239.38.21   | 600 |

3. **Optionally add AAAA records (IPv6):**

   | Type | Name | Value                   | TTL |
   |------|------|-------------------------|-----|
   | AAAA | @    | 2001:4860:4802:32::15  | 600 |
   | AAAA | @    | 2001:4860:4802:34::15  | 600 |
   | AAAA | @    | 2001:4860:4802:36::15  | 600 |
   | AAAA | @    | 2001:4860:4802:38::15  | 600 |

4. **Keep existing CNAME records:**

   | Type  | Name    | Value                 | Purpose |
   |-------|---------|-----------------------|---------|
   | CNAME | api     | ghs.googlehosted.com | API     |
   | CNAME | demo    | ghs.googlehosted.com | Demo    |
   | CNAME | docs    | ghs.googlehosted.com | Docs    |
   | CNAME | staging | ghs.googlehosted.com | Staging |

### SSL Certificate Provisioning

After DNS records are updated:

1. **DNS Propagation:** 10-15 minutes
2. **SSL Certificate:** Google will automatically provision an SSL certificate
3. **Certificate Issuance:** 15-30 minutes after DNS propagation

**Monitor SSL certificate status:**
```bash
watch -n 30 'gcloud beta run domain-mappings list --region=us-central1'
```

The `…` symbol will change to `✔` once the SSL certificate is provisioned.

### Verify DNS Configuration

After updating DNS records:

```bash
# Check DNS resolution
dig ocl.network +short

# Test HTTPS (after SSL is provisioned)
curl https://ocl.network/health
```

## Redeployment

To update the landing page in the future:

```bash
cd /Users/Owner/opencitylabs/ocl-network-landing
./deploy-cloud-run.sh
```

Or manually:

```bash
# Build and push
gcloud builds submit --tag gcr.io/gemini-ocl-network/ocl-network-landing:latest .

# Deploy
gcloud run deploy ocl-network-landing \
  --image gcr.io/gemini-ocl-network/ocl-network-landing:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --port 8080 \
  --memory 128Mi \
  --cpu 1
```

## Rollback

If needed, rollback to a previous revision:

```bash
# List revisions
gcloud run revisions list --service=ocl-network-landing --region=us-central1

# Rollback
gcloud run services update-traffic ocl-network-landing \
  --to-revisions=<REVISION>=100 \
  --region=us-central1
```

## Files Created

1. **Dockerfile** - Multi-stage build using nginx:alpine
2. **nginx.conf** - Nginx configuration for serving static content on port 8080
3. **deploy-cloud-run.sh** - Automated deployment script
4. **DEPLOYMENT.md** - This file

## Architecture

```
┌─────────────────────────────────────┐
│         Google Cloud Run             │
├─────────────────────────────────────┤
│  Service: ocl-network-landing       │
│  Image: nginx:alpine                │
│  Port: 8080                         │
│  Memory: 128Mi                      │
│  CPU: 1                             │
└─────────────────────────────────────┘
                 ▲
                 │
                 │ HTTPS
                 │
┌────────────────┴────────────────────┐
│        DNS (GoDaddy)                │
├─────────────────────────────────────┤
│  ocl.network → A Records            │
│  SSL by Google (auto-provisioned)   │
└─────────────────────────────────────┘
```

## Cost Estimate

**Monthly Cost (Approximate):**
- Cloud Run: $0-5 (with generous free tier)
- Container Registry Storage: $0.10/GB
- Egress: Minimal for static landing page
- **Total:** ~$1-5/month

## Notes

- The landing page is a static HTML file served by nginx
- No authentication required (public landing page)
- Auto-scaling from 0 to 10 instances
- Health check endpoint available at `/health`
- Gzip compression enabled for faster loading
- Security headers configured (X-Frame-Options, X-Content-Type-Options, X-XSS-Protection)

## Support

For deployment issues:
- View Cloud Run logs: `gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=ocl-network-landing" --limit=50`
- Check service status: `gcloud run services describe ocl-network-landing --region=us-central1`
- Monitor domain mapping: `gcloud beta run domain-mappings list --region=us-central1`
