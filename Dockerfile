FROM caddy:alpine

RUN apk add --no-cache redsocks iptables bash

COPY --chmod=755 usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /srv

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]