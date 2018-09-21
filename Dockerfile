FROM php:7.1

ADD ./build /build

RUN bash /build/build.sh && rm -rf /build
