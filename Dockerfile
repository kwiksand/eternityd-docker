FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m eternity

ENV ETERNITY_DATA=/home/eternity/.eternity

USER eternity

RUN cd /home/eternity && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone https://github.com/eternity-group/eternity.git eternityd && \
    cd /home/eternity/eternityd && \
    ./autogen.sh && \
    ./configure LDFLAGS="-L/home/eternity/db4/lib/" CPPFLAGS="-I/home/eternity/db4/include/" && \
    make 
    
EXPOSE 5844 5845

#VOLUME ["/home/eternity/.eternity"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && cp /home/eternity/eternityd/src/eternity-cli /usr/bin/eternity-cli && chmod 755 /usr/bin/eternity-cli && \
    chmod 777 /entrypoint.sh && cp /home/eternity/eternityd/src/eternity-tx /usr/bin/eternity-tx && chmod 755 /usr/bin/eternity-tx && \
    chmod 777 /entrypoint.sh && cp /home/eternity/eternityd/src/eternityd /usr/bin/eternityd && chmod 755 /usr/bin/eternityd

ENTRYPOINT ["/entrypoint.sh"]

CMD ["eternityd"]
