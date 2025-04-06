FROM node:18-slim

RUN npm install -g @bitwarden/cli && \
    apt update

COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]