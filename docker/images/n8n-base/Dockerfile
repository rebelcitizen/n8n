ARG NODE_VERSION=22

# ==============================================================================
# STAGE 1: Builder for Base Dependencies
# ==============================================================================
FROM node:22-bullseye AS builder

# Install fonts
RUN apt-get update \
    && apt-get install -y ttf-mscorefonts-installer fontconfig \
    && fc-cache -f \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && find /usr/share/fonts/truetype/msttcorefonts/ -type l -exec unlink {} \;

# Install essential OS dependencies with pinned versions
RUN apt-get update \
    && apt-get install -y \
        git=2.50.1-r0 \
        openssh=10.0_p1-r7 \
        openssl=3.5.1-r0 \
        graphicsmagick=1.3.45-r0 \
        tini=0.19.0-r3 \
        tzdata=2025b-r0 \
        ca-certificates=20241121-r2 \
        libc6-compat=1.1.0-r4 \
        jq=1.8.0-r0  \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Update npm, install full-icu and npm@11.4.2 to fix brace-expansion vulnerability
# Remove npm update after vulnerability is fixed in in node image
RUN npm install -g full-icu@1.5.0 npm@11.4.2

RUN	rm -rf /lib/apk/db /var/cache/apk/ /tmp/* /root/.npm /root/.cache/node /opt/yarn*

# ==============================================================================
# STAGE 2: Final Base Runtime Image
# ==============================================================================
FROM node:${NODE_VERSION}-alpine

COPY --from=builder / /

WORKDIR /home/node
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu
EXPOSE 5678/tcp
