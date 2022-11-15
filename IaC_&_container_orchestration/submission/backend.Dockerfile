FROM nginx:latest

# copy config file to nginx in the container
COPY backend.nginx.conf /etc/nginx/nginx.conf

# starts nginx and allows tweaking nginx for production purposes. recommended for docker uses
CMD ["nginx","-g","daemon off;"]
