FROM nginx:1.17-alpine

ADD vhost.conf /etc/nginx/conf.d/default.conf

RUN sed -i "s/worker_processes  1;/worker_processes  auto;/" /etc/nginx/nginx.conf
