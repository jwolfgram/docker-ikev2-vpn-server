FROM ubuntu:16.04

RUN mkdir /TEMP && cd /TEMP

ADD https://download.strongswan.org/strongswan-5.8.3.tar.bz2 /TEMP

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install wget build-essential make gcc libgmp3-dev bzip2 iptables uuid-runtime ndppd openssl \
    && cd /TEMP \
    && bzip2 -dc /TEMP/strongswan-5.8.3.tar.bz2 | tar xvf - \
    && ls \
    && cd /TEMP/strongswan-5.8.3 \
    && ./configure --prefix=/usr --sysconfdir=/etc --enable-dhcp --enable-farp \
    && make \
    && make install \
    && cd / \
    && rm -rf /TEMP \
    && rm -rf /var/lib/apt/lists/* # cache busted 20160406.1

RUN rm /etc/ipsec.secrets
RUN mkdir /config
RUN (cd /etc && ln -s /config/ipsec.secrets .)

ADD ./etc/* /etc/
ADD ./bin/* /usr/bin/

VOLUME /etc
VOLUME /config

# http://blogs.technet.com/b/rrasblog/archive/2006/06/14/which-ports-to-unblock-for-vpn-traffic-to-pass-through.aspx
EXPOSE 500/udp 4500/udp

CMD /usr/bin/start-vpn
