require "test_helper"

class ImportJobMachineTest < ActiveSupport::TestCase
  # 遷移テーブルの直接検証です。
  # マトリクスの各セルが仕様どおりの遷移先を返すかを網羅的に確認します。

  test "idle状態はSUBMITでsubmittingに遷移する" do
    assert_equal :submitting, ImportJobMachine.next_state(:idle, :SUBMIT)
  end

  test "submitting状態はSUBMIT_DONEでregisteredに遷移する" do
    assert_equal :registered, ImportJobMachine.next_state(:submitting, :SUBMIT_DONE)
  end

  test "submitting状態はSUBMIT_ERRORでfailedに遷移する" do
    assert_equal :failed, ImportJobMachine.next_state(:submitting, :SUBMIT_ERROR)
  end

  test "registered状態はSTART_IMPORTでimporting_modal_queuedに遷移する" do
    assert_equal :importing_modal_queued, ImportJobMachine.next_state(:registered, :START_IMPORT)
  end

  test "importing_modal_queued状態はDISMISS_MODALでimportingに遷移する" do
    assert_equal :importing, ImportJobMachine.next_state(:importing_modal_queued, :DISMISS_MODAL)
  end

  test "importing状態はPROGRESSで自己遷移する" do
    assert_equal :importing, ImportJobMachine.next_state(:importing, :PROGRESS)
  end

  test "importing状態はCOMPLETEでcompletedに遷移する" do
    assert_equal :completed, ImportJobMachine.next_state(:importing, :COMPLETE)
  end

  test "importing状態はPAUSEでpausedに遷移する" do
    assert_equal :paused, ImportJobMachine.next_state(:importing, :PAUSE)
  end

  test "paused状態はRESUMEでimportingに戻る" do
    assert_equal :importing, ImportJobMachine.next_state(:paused, :RESUME)
  end

  test "completed状態はRESETでidleに戻る" do
    assert_equal :idle, ImportJobMachine.next_state(:completed, :RESET)
  end

  test "未定義の遷移はInvalidTransitionを送出する" do
    assert_raises(ImportJobMachine::InvalidTransition) do
      ImportJobMachine.next_state(:idle, :COMPLETE)
    end
  end

  test "available_eventsは現在の状態で発火可能なイベントのみを返す" do
    assert_equal %i[SUBMIT], ImportJobMachine.available_events(:idle)
    assert_equal %i[START_IMPORT DISMISS_MODAL], ImportJobMachine.available_events(:registered)
  end

  test "ui_layerはregisteredでmodalを返す" do
    assert_equal :modal, ImportJobMachine.ui_layer(:registered)
  end

  test "ui_layerはimporting_modal_queuedでoverlayを返しオーバーレイを優先する" do
    assert_equal :overlay, ImportJobMachine.ui_layer(:importing_modal_queued)
  end

  test "ui_layerはidleでnoneを返す" do
    assert_equal :none, ImportJobMachine.ui_layer(:idle)
  end
end
