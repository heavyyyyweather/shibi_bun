#----------------------------------------
# Stage 1: Builder
#----------------------------------------
FROM ruby:3.3.6 AS builder

# ビルド時だけのダミー鍵（assets:precompile 対策）
ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RAILS_ENV=production \
    SECRET_KEY_BASE=dummy

RUN apt-get update -y && apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      git \
      curl \
      ca-certificates \
      tzdata \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && corepack enable \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gem を先に入れてキャッシュ
COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
 && bundle config set path /bundle \
 && bundle config set without 'development test' \
 && bundle install --jobs=4 --retry=3

# アプリ本体をコピー
COPY . .

# 必要なら Linux プラットフォームを lock に追加（M2 開発→Linux 本番の食い違い対策）
# RUN bundle lock --add-platform x86_64-linux

# アセットを事前コンパイル（必要なければこの行はコメントアウト可）
RUN bundle exec rake assets:precompile

#----------------------------------------
# Stage 2: Runner
#----------------------------------------
FROM ruby:3.3.6 AS runner

ENV LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=8080 \
    BUNDLE_PATH=/bundle \
    BUNDLE_WITHOUT="development:test"

RUN apt-get update -y && apt-get install -y --no-install-recommends \
      libpq5 \
      tzdata \
      ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Bundle（gem）をコピー
COPY --from=builder /bundle /bundle
# アプリ本体をコピー
COPY --from=builder /app /app

EXPOSE 8080

CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "8080"]
