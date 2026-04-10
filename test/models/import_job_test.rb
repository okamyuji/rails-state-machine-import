require "test_helper"

class ImportJobTest < ActiveSupport::TestCase
  # ImportJobモデルが状態遷移テーブルを経由して正しくステータスを進めるかを検証します。

  test "idleのジョブはSUBMITとSUBMIT_DONEを連続適用するとregisteredになる" do
    job = ImportJob.create!(name: "テストジョブ", total_rows: 100, status: "idle")
    job.apply_event!(:SUBMIT)
    assert_equal "submitting", job.status
    job.apply_event!(:SUBMIT_DONE)
    assert_equal "registered", job.status
  end

  test "registeredでSTART_IMPORTを受けるとオーバーレイ優先の複合状態に入る" do
    job = import_jobs(:registered_job)
    job.apply_event!(:START_IMPORT)
    assert_equal "importing_modal_queued", job.status
    assert_equal :overlay, job.ui_layer
  end

  test "importing中の進捗更新は状態を変えずに属性だけを更新する" do
    job = import_jobs(:importing_job)
    job.apply_event!(:PROGRESS, processed_rows: 1200)
    assert_equal "importing", job.status
    assert_equal 1200, job.processed_rows
  end

  test "不正な遷移を試みるとInvalidTransitionが発生しステータスは変わらない" do
    job = import_jobs(:idle_job)
    original = job.status
    assert_raises(ImportJobMachine::InvalidTransition) do
      job.apply_event!(:COMPLETE)
    end
    assert_equal original, job.reload.status
  end

  test "progress_ratioはtotal_rowsがゼロでも例外を投げず0を返す" do
    job = ImportJob.new(name: "空ジョブ", total_rows: 0, processed_rows: 0, status: "idle")
    assert_equal 0.0, job.progress_ratio
  end
end
