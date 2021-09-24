FROM alpine:3.14 as build

ARG version

RUN apk add --no-cache \
    # Compile-time dependencies
    build-base \
    ldns-dev \
    libidn-dev \
    make \
    openssl-dev \
    perl-app-cpanminus \
    perl-dev \
    perl-devel-checklib \
    perl-module-install \
    perl-test-fatal \
 && cpanm --notest --no-wget \
    Module::Install::XSUtil

COPY ./Zonemaster-LDNS-${version}.tar.gz ./Zonemaster-LDNS-${version}.tar.gz

RUN cpanm --notest --no-wget --configure-args="--no-internal-ldns" \
    ./Zonemaster-LDNS-${version}.tar.gz

FROM alpine:3.14

# Include only Zonemaster LDNS modules
COPY --from=build /usr/local/lib/perl5/site_perl/auto/Zonemaster /usr/local/lib/perl5/site_perl/auto/Zonemaster
COPY --from=build /usr/local/lib/perl5/site_perl/Zonemaster /usr/local/lib/perl5/site_perl/Zonemaster

RUN apk add --no-cache \
    # Run-time dependencies
    ldns \
    libidn
