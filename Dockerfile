FROM alpine:3.22 as build

RUN apk add --no-cache \
    # Compile-time dependencies
    build-base \
    libidn2-dev \
    make \
    openssl-dev \
    perl-app-cpanminus \
    perl-dev \
    perl-devel-checklib \
    perl-extutils-depends \
    perl-extutils-pkgconfig \
    perl-lwp-protocol-https \
    perl-mime-base32 \
    perl-module-install \
    perl-test-differences \
    perl-test-fatal \
    perl-test-nowarnings \
 && cpanm --notest --no-wget --from=https://cpan.metacpan.org/ \
    Module::Install::XSUtil

ARG version

COPY ./Zonemaster-LDNS-${version}.tar.gz ./Zonemaster-LDNS-${version}.tar.gz

RUN cpanm --notest --no-wget \
    ./Zonemaster-LDNS-${version}.tar.gz

FROM alpine:3.22

# Include only Zonemaster LDNS modules
COPY --from=build /usr/local/lib/perl5/site_perl/auto/Zonemaster /usr/local/lib/perl5/site_perl/auto/Zonemaster
COPY --from=build /usr/local/lib/perl5/site_perl/Zonemaster /usr/local/lib/perl5/site_perl/Zonemaster

RUN apk add --no-cache \
    # Run-time dependencies
    libidn2 \
    perl
