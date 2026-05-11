FROM nginx:alpine

COPY index.html /usr/share/nginx/html/index.html
COPY ostanek_app_logo.png /usr/share/nginx/html/ostanek_app_logo.png
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
