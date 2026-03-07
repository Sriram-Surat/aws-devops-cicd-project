FROM nginx:latest

COPY Application/index.html /usr/share/nginx/html/index.html

EXPOSE 80