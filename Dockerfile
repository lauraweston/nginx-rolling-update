FROM nginx:1.17.6-alpine

RUN apk add --no-cache bash

COPY load_balancer/ /etc/nginx/

CMD ["/bin/bash"]