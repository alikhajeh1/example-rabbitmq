FROM anapsix/alpine-java:latest

RUN apk update && \
    apk add ca-certificates && \
    update-ca-certificates && apk add openssl

RUN wget http://github.com/rabbitmq/rabbitmq-perf-test/releases/download/v1.2.0/rabbitmq-perf-test-1.2.0-bin.tar.gz && \
    tar -xzf rabbitmq-perf-test-1.2.0-bin.tar.gz && rm rabbitmq-perf-test-1.2.0-bin.tar.gz && \
    chmod +x ./rabbitmq-perf-test-1.2.0/bin/runjava

ENV PATH /rabbitmq-perf-test-1.2.0/bin:$PATH

ADD run.sh .

RUN chmod +x ./run.sh

CMD ["./run.sh"]
