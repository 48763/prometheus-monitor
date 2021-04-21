docker stop prom-nginx
docker rm prom-nginx

docker run --name prom-nginx \
        -v /var/log/nginx:/var/log/nginx \
        -p 80:80 \
        -p 443:443 \
        -p 9090:9090 \
        -p 9093:9093 \
        --network monitor \
        -d nginx:1.0.1
