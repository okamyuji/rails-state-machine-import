# 開発環境ですぐにアプリを試せるようにするダミーデータです。
# db:seed を実行すると各状態のサンプルジョブが揃います。
# 冪等性を保つため find_or_create_by! で重複作成を避けています。

samples = [
  {
    name: "顧客マスタ取込（初回登録直後）",
    total_rows: 1_500,
    processed_rows: 0,
    status: "registered",
    error_message: nil,
  },
  {
    name: "商品マスタ取込（モーダルとオーバーレイ競合）",
    total_rows: 800,
    processed_rows: 240,
    status: "importing_modal_queued",
    error_message: nil,
  },
  {
    name: "在庫データ取込（インポート中）",
    total_rows: 5_000,
    processed_rows: 3_200,
    status: "importing",
    error_message: nil,
  },
  {
    name: "注文履歴取込（一時停止中）",
    total_rows: 12_000,
    processed_rows: 4_800,
    status: "paused",
    error_message: nil,
  },
  {
    name: "売上データ取込（完了）",
    total_rows: 2_500,
    processed_rows: 2_500,
    status: "completed",
    error_message: nil,
  },
  {
    name: "取引先データ取込（失敗）",
    total_rows: 900,
    processed_rows: 120,
    status: "failed",
    error_message: "CSV 7行目: email カラムが不正です",
  },
  {
    name: "未登録のひな形ジョブ",
    total_rows: 300,
    processed_rows: 0,
    status: "idle",
    error_message: nil,
  },
]

samples.each do |attrs|
  ImportJob.find_or_create_by!(name: attrs[:name]) do |job|
    job.assign_attributes(attrs)
  end
end

puts "投入されたジョブ: #{ImportJob.count} 件"
