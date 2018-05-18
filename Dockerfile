FROM postgres:10
RUN apt-get -y update && apt-get -y install iptables
