FROM node:22-bullseye

RUN apt-get update && apt-get install -y openssh-client sudo passwd bash && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo node ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/node && chmod 0440 /etc/sudoers.d/node
RUN mkdir /workspaces && chown node:node /workspaces
RUN npm install -g pnpm

USER node
RUN mkdir -p ~/.pnpm-store && pnpm config set store-dir ~/.pnpm-store --global
