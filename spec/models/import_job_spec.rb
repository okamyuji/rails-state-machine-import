require "rails_helper"

RSpec.describe ImportJob do
  describe "#apply_event!" do
    it "idleのジョブはSUBMITとSUBMIT_DONEを連続適用するとregisteredになる" do
      job = described_class.create!(name: "テストジョブ", total_rows: 100, status: "idle")
      job.apply_event!(:SUBMIT)
      expect(job.status).to eq("submitting")
      job.apply_event!(:SUBMIT_DONE)
      expect(job.status).to eq("registered")
    end

    it "registeredでSTART_IMPORTを受けるとオーバーレイ優先の複合状態に入る" do
      job = described_class.create!(name: "商品マスタ取込", total_rows: 500, status: "registered")
      job.apply_event!(:START_IMPORT)
      expect(job.status).to eq("importing_modal_queued")
      expect(job.ui_layer).to eq(:overlay)
    end

    it "importing中の進捗更新は状態を変えずに属性だけを更新する" do
      job = described_class.create!(name: "在庫データ取込", total_rows: 2000, processed_rows: 800, status: "importing")
      job.apply_event!(:PROGRESS, processed_rows: 1200)
      expect(job.status).to eq("importing")
      expect(job.processed_rows).to eq(1200)
    end

    it "不正な遷移を試みるとInvalidTransitionが発生しステータスは変わらない" do
      job = described_class.create!(name: "顧客マスタ取込", total_rows: 100, status: "idle")
      expect { job.apply_event!(:COMPLETE) }.to raise_error(ImportJobMachine::InvalidTransition)
      expect(job.reload.status).to eq("idle")
    end
  end

  describe "#progress_ratio" do
    it "total_rowsがゼロでも例外を投げず0を返す" do
      job = described_class.new(name: "空ジョブ", total_rows: 0, processed_rows: 0, status: "idle")
      expect(job.progress_ratio).to eq(0.0)
    end

    it "進捗があれば割合を返す" do
      job = described_class.new(name: "サンプル", total_rows: 200, processed_rows: 50, status: "importing")
      expect(job.progress_ratio).to eq(0.25)
    end
  end
end
