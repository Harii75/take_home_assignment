FROM alpine:3.23

ARG TARGETARCH

RUN addgroup -S app && adduser -S app -G app

WORKDIR /app

COPY bin/rest_1.0_linux_${TARGETARCH} ./rest

RUN chmod +x ./rest

USER app

EXPOSE 8080

ENTRYPOINT ["./rest"]
