FROM alpine:3.8 as builder
MAINTAINER Jason Rivers <docker@jasonrivers.co.uk>

ARG NGINX_VERSION=1.24.0
ARG NGINX_RTMP_VERSION=1.2.11


RUN apk update      &&  \
    apk add             \
        git         \
        gcc         \
        binutils        \
        gmp         \
        isl         \
        libgomp         \
        libatomic       \
        libgcc          \
        openssl         \
        pkgconf         \
        pkgconfig       \
        mpfr3           \
        mpc1            \
        libstdc++       \
        ca-certificates     \
        libssh2         \
        curl            \
        expat           \
        pcre            \
        musl-dev        \
        libc-dev        \
        pcre-dev        \
        zlib-dev        \
        openssl-dev     \
        curl            \
        make


RUN cd /tmp/                                    &&  \
    curl --remote-name http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz          &&  \
    git clone https://github.com/winshining/nginx-http-flv-module.git -b v${NGINX_RTMP_VERSION}

RUN cd /tmp                                     &&  \
    tar xzf nginx-${NGINX_VERSION}.tar.gz                       &&  \
    cd nginx-${NGINX_VERSION}                           &&  \
    ./configure                                     \
        --prefix=/opt/nginx                             \
        --with-http_ssl_module                              \
        --add-module=../nginx-http-flv-module                   &&  \
    make                                        &&  \
    make install
RUN rm /opt/nginx/conf/nginx.conf

FROM alpine:3.8
RUN apk update      && \
    apk add            \
        openssl        \
        libstdc++      \
        ca-certificates    \
        pcre

COPY --from=0 /opt/nginx /opt/nginx
COPY --from=0 /tmp/nginx-http-flv-module/stat.xsl /opt/nginx/conf/stat.xsl
ADD run.sh /

EXPOSE 1935
EXPOSE 8080

CMD /run.sh

