FROM ubuntu:18.04
WORKDIR /usr/src
RUN apt-get update && apt-get -y install sysbench clang iperf3 bc make dnsutils
COPY benchmark.sh /usr/src
ENTRYPOINT ["sh", "benchmark.sh"]
