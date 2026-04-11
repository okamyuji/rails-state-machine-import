require "rails_helper"

RSpec.describe "Api::ImportJobs", type: :request do
  describe "POST /api/import_jobs" do
    it "新規ジョブを登録するとregistered状態で返る" do
      post "/api/import_jobs", params: { import_job: { name: "顧客データ", total_rows: 500 } }, as: :json
      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["status"]).to eq("registered")
      expect(body["available_events"]).to include("START_IMPORT")
    end
  end

  describe "POST /api/import_jobs/:id/events/:event" do
    it "登録直後にSTART_IMPORTを送ると複合状態に遷移しUI層がoverlayになる" do
      post "/api/import_jobs", params: { import_job: { name: "商品データ", total_rows: 200 } }, as: :json
      job_id = response.parsed_body["id"]

      post "/api/import_jobs/#{job_id}/events/START_IMPORT", as: :json
      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body["status"]).to eq("importing_modal_queued")
      expect(body["ui_layer"]).to eq("overlay")
    end

    it "不正な遷移は422とエラーメッセージを返す" do
      post "/api/import_jobs", params: { import_job: { name: "失敗テスト", total_rows: 10 } }, as: :json
      job_id = response.parsed_body["id"]

      post "/api/import_jobs/#{job_id}/events/COMPLETE", as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["error"]).to eq("invalid_transition")
    end
  end
end
