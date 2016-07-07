FROM node:latest
ENV NODE_PATH=/usr/local/lib/node_modules
RUN cd /usr/local \
        && git clone https://github.com/zilman/socket.io.git \
        && cd socket.io \
        && npm install \
        && cd examples/chat \
        && npm install \
        && npm install socket.io-redis --global \
        && npm install redis-sentinel --global

WORKDIR /usr/local/socket.io/examples/chat

ENTRYPOINT [ "/usr/local/bin/node" ]
CMD ["."]
