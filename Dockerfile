# Dockerfile for OCL Network Landing Page
# Uses nginx to serve static HTML

FROM nginx:alpine

# Copy the landing page HTML to nginx's default serving directory
COPY index.html /usr/share/nginx/html/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 8080 (Cloud Run standard)
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
