require "test_helper"

module Api
  class ImportJobsControllerTest < ActionDispatch::IntegrationTest
    # APIコントローラが遷移テーブルを介してジョブを操作できるかを検証します。

    test "POST /api/import_jobsで新規ジョブを登録するとregisteredで返る" do
      post api_import_jobs_url, params: { import_job: { name: "顧客データ", total_rows: 500 } }, as: :json
      assert_response :created
      body = JSON.parse(response.body)
      assert_equal "registered", body["status"]
      assert_includes body["available_events"], "START_IMPORT"
    end

    test "登録直後にSTART_IMPORTを送ると複合状態に遷移しUI層はoverlayになる" do
      post api_import_jobs_url, params: { import_job: { name: "商品データ", total_rows: 200 } }, as: :json
      job_id = JSON.parse(response.body)["id"]

      post event_api_import_job_url(job_id, event: :START_IMPORT), as: :json
      assert_response :success
      body = JSON.parse(response.body)
      assert_equal "importing_modal_queued", body["status"]
      assert_equal "overlay", body["ui_layer"]
    end

    test "不正な遷移は422とエラーメッセージを返す" do
      post api_import_jobs_url, params: { import_job: { name: "失敗テスト", total_rows: 10 } }, as: :json
      job_id = JSON.parse(response.body)["id"]

      post event_api_import_job_url(job_id, event: :COMPLETE), as: :json
      assert_response :unprocessable_content
      body = JSON.parse(response.body)
      assert_equal "invalid_transition", body["error"]
    end
  end
end
