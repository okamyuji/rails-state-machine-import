# Rails 状態遷移テーブルでインポートジョブを設計するサンプル

Rails 8 と Ruby 3.4 で実装した、状態遷移テーブル駆動の有限状態機械（FSM）のサンプルアプリケーションです。
モーダルとオーバーレイの優先表示を含む複合状態を、フラグではなくテーブルで管理します。

## 何を学べるか

- 8 状態 11 イベントの遷移マトリクスを Ruby のハッシュにそのまま写す方法
- 「登録完了モーダル」と「インポート中オーバーレイ」が同時に必要なときの状態設計
- 不正な遷移をモデル層で構造的に拒否する仕組み
- API と ERB ビューの両方で同じ状態機械を共有する設計

## 必要環境

- Ruby 3.4.x
- Rails 8.1.x
- SQLite3

## 起動手順

```bash
bundle install
bin/rails db:migrate
bin/rails db:seed       # 全7状態のサンプルジョブを投入します
bin/rails server
```

ブラウザで http://localhost:3000 を開くと、ジョブ一覧と状態遷移マトリクスが表示されます。
`db:seed` で idle、registered、importing、importing_modal_queued、paused、completed、failed の各状態のジョブが揃うため、画面遷移を一通り試せます。

## サンプルデータ

`samples/` ディレクトリに以下を用意しています。

- `customers.csv` ... 10件の顧客ダミーデータ
- `products.csv` ... 10件の商品ダミーデータ
- `README.md` ... 使い方の説明

新規登録時の「対象行数」に各CSVの行数を入力すると、一連のインポートシナリオを現実的な数値で再現できます。

## テスト

```bash
bundle exec rspec
```

RSpec によるユニットテスト、API リクエストテスト、Capybara によるシステムテストを含みます。

## 品質検証

```bash
bin/quality
```

以下を一括で実行します。

- syntax_tree によるフォーマットチェック
- RuboCop（rubocop-rails-omakase ベース）による静的解析
- Brakeman によるセキュリティ解析
- bundler-audit による依存性監査
- Sorbet による型検査
- RSpec によるテスト

クローン直後に `bin/setup_hooks` を実行すると、`git commit` 前に自動で `bin/quality` が走るようになります。検証に失敗するとコミットは中断されます。

## ディレクトリ構成

```
app/
  models/import_job.rb
  state_machines/import_job_machine.rb   # 遷移テーブル本体
  controllers/
    import_jobs_controller.rb            # ERBビュー用
    api/import_jobs_controller.rb        # JSON API用
  views/import_jobs/                     # 一覧 / 新規 / 詳細
test/
  state_machines/import_job_machine_test.rb
  models/import_job_test.rb
  controllers/api/import_jobs_controller_test.rb
  system/import_jobs_flow_test.rb        # Capybara による E2E
```

## 状態遷移マトリクス

| 状態＼イベント | SUBMIT | SUBMIT_DONE | SUBMIT_ERROR | START_IMPORT | DISMISS_MODAL | PROGRESS | COMPLETE | FAIL | PAUSE | RESUME | RESET |
| ------------- | ------ | ----------- | ------------ | ------------ | ------------- | -------- | -------- | ---- | ----- | ------ | ----- |
| idle | submitting | — | — | — | — | — | — | — | — | — | — |
| submitting | — | registered | failed | — | — | — | — | — | — | — | — |
| registered | — | — | — | importing_modal_queued | idle | — | — | — | — | — | — |
| importing | — | — | — | — | — | importing | completed | failed | paused | — | — |
| importing_modal_queued | — | — | — | — | importing | importing_modal_queued | completed | failed | paused | — | — |
| paused | — | — | — | — | — | — | — | — | — | importing | — |
| completed | — | — | — | — | — | — | — | — | — | — | idle |
| failed | — | — | — | — | — | — | — | — | — | — | idle |

## ライセンス

MIT
