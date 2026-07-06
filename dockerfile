# syntax=docker/dockerfile:1.6
FROM hexpm/elixir:1.18.4-erlang-27.3.4.14-debian-bookworm-20260623-slim AS build

ENV MIX_ENV=prod \
  LANG=C.UTF-8

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock* ./
RUN mix deps.get --only prod

COPY config config
COPY lib lib
COPY priv priv

RUN mix deps.compile
RUN mix release

FROM debian:bookworm-slim AS app

ENV LANG=C.UTF-8 \
  MIX_ENV=prod \
  PORT=8080

WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates libstdc++6 openssl \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd --system appuser && useradd --system --gid appuser --shell /usr/sbin/nologin appuser

COPY --from=build /app/_build/prod/rel/radio_call_api ./radio_call_api

RUN chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

ENTRYPOINT ["./radio_call_api/bin/radio_call_api"]
CMD ["start"]
