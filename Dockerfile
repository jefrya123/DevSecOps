# Use an official Nginx image as a base
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
