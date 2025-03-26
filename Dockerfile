FROM debian:trixie-slim

RUN apt update -y
RUN apt install -y racket openssl ca-certificates

RUN raco setup -D
RUN raco pkg install --auto --no-docs syntax-spec-v2

WORKDIR /app
RUN cd /app

RUN mkdir staged-miniKanren
ADD . staged-miniKanren

WORKDIR /app/staged-miniKanren

CMD ["racket"]