# README

## Fly.io 初回デプロイ手順
開発は Docker Compose（`Dockerfile.dev`）、本番は Fly.io（`Dockerfile`）で運用します。  
1回目のデプロイ（＝環境作成）用の手順です。2回目以降は `fly deploy` だけでOK。

### 1. アプリ作成（launch）

`fly launch --no-deploy`

- App name：任意
- Region：nrt
- Internal port：Dockerfile に合わせて 8080
- Postgres：None
- `.dockerignore`：Yes

### 2. Postgres を作成 & 接続

`fly postgres create --name <APP>-db --region nrt --volume-size 1 fly postgres attach --app <APP> <APP>-db`

これで `DATABASE_URL` が Fly Secrets に自動設定される。

### 3. Rails の master key を登録

`fly secrets set RAILS_MASTER_KEY=$(cat config/master.key)`

### 4. デプロイ

`fly deploy`

### 5. 動作確認

`https://<APP>.fly.dev/up   → 200 OK（ヘルスチェック） https://<APP>.fly.dev/     → アプリトップ`


---

## 2回目以降のデプロイ

`fly deploy`
