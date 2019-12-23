FROM nginx:1.17.6-alpine

RUN apk add --no-cache bash

CMD ["nginx", "-g", "daemon off;"]