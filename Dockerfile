FROM quay.io/kwiksand/cryptocoin-base:latest

RUN useradd -m eternity

ENV DAEMON_RELEASE="v0.12.1.6"
ENV E_COIN_CURRENCY="eternity"
ENV E_COIN_SYMBOL="ENT"
ENV E_COIN_DAEMON="/usr/bin/eternity-cli -conf=/home/eternity/.eternity/eternity.conf"
ENV E_GET_BLOCKCOUNT='/usr/bin/curl -s https://chainz.cryptoid.info/ent/api.dws?q=getblockcount'
ENV E_MASTERNODE_CONF="eternitynode"
ENV ETERNITY_DATA=/home/eternity/.eternity

USER eternity

RUN cd /home/eternity && \
    mkdir /home/eternity/bin && \
    mkdir .ssh && \
    chmod 700 .ssh && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts && \
    ssh-keyscan -t rsa bitbucket.org >> ~/.ssh/known_hosts && \
    git clone --branch $DAEMON_RELEASE https://github.com/eternity-group/eternity.git eternityd && \
    cd /home/eternity/eternityd && \
    ./autogen.sh && \
    ./configure LDFLAGS="-L/home/eternity/db4/lib/" CPPFLAGS="-I/home/eternity/db4/include/" && \
    make && \
    strip src/eternityd && \
    strip src/eternity-cli && \
    strip src/eternity-tx && \
    mv src/eternityd src/eternity-cli src/eternity-tx /home/eternity/bin && \
    rm -rf /home/eternity/eternityd
    
EXPOSE 4854 4855

#VOLUME ["/home/eternity/.eternity"]

USER root

COPY docker-entrypoint.sh /entrypoint.sh

RUN chmod 777 /entrypoint.sh && \
    echo "\n# Some aliases to make the eternity clients/tools easier to access\nalias eternityd='/usr/bin/eternityd -conf=/home/eternity/.eternity/eternity.conf'\nalias eternity-cli='/usr/bin/eternity-cli -conf=/home/eternity/.eternity/eternity.conf'\n" >> /etc/bash.bashrc && \
    echo "Eternity (ENT) Cryptocoin Daemon\n\nUsage:\n eternity-cli help - List help options\n eternity-cli listtransactions - List Transactions\n\n" > /etc/motd && \
    chmod 755 /home/eternity/bin/eternityd && \
    chmod 755 /home/eternity/bin/eternity-cli && \
    chmod 755 /home/eternity/bin/eternity-tx && \
    mv /home/eternity/bin/eternityd /usr/bin/eternityd && \
    mv /home/eternity/bin/eternity-cli /usr/bin/eternity-cli && \
    mv /home/eternity/bin/eternity-tx /usr/bin/eternity-tx 

COPY node-status.sh /usr/bin/node-status

ENTRYPOINT ["/entrypoint.sh"]

CMD ["eternityd"]
