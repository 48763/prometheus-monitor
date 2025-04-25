FROM alpine

WORKDIR /app

RUN set -x \
    apk update\
    && apk add --no-cache \
        bash \
        curl \
        jq
 
COPY . .

CMD ["./main.sh", "gen"]
