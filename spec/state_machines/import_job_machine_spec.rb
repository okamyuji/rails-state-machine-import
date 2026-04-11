require "rails_helper"

RSpec.describe ImportJobMachine do
  describe ".next_state" do
    it "idle状態はSUBMITでsubmittingに遷移する" do
      expect(described_class.next_state(:idle, :SUBMIT)).to eq(:submitting)
    end

    it "submitting状態はSUBMIT_DONEでregisteredに遷移する" do
      expect(described_class.next_state(:submitting, :SUBMIT_DONE)).to eq(:registered)
    end

    it "submitting状態はSUBMIT_ERRORでfailedに遷移する" do
      expect(described_class.next_state(:submitting, :SUBMIT_ERROR)).to eq(:failed)
    end

    it "registered状態はSTART_IMPORTでimporting_modal_queuedに遷移する" do
      expect(described_class.next_state(:registered, :START_IMPORT)).to eq(:importing_modal_queued)
    end

    it "importing_modal_queued状態はDISMISS_MODALでimportingに遷移する" do
      expect(described_class.next_state(:importing_modal_queued, :DISMISS_MODAL)).to eq(:importing)
    end

    it "importing状態はPROGRESSで自己遷移する" do
      expect(described_class.next_state(:importing, :PROGRESS)).to eq(:importing)
    end

    it "importing状態はCOMPLETEでcompletedに遷移する" do
      expect(described_class.next_state(:importing, :COMPLETE)).to eq(:completed)
    end

    it "importing状態はPAUSEでpausedに遷移する" do
      expect(described_class.next_state(:importing, :PAUSE)).to eq(:paused)
    end

    it "paused状態はRESUMEでimportingに戻る" do
      expect(described_class.next_state(:paused, :RESUME)).to eq(:importing)
    end

    it "completed状態はRESETでidleに戻る" do
      expect(described_class.next_state(:completed, :RESET)).to eq(:idle)
    end

    it "未定義の遷移はInvalidTransitionを送出する" do
      expect { described_class.next_state(:idle, :COMPLETE) }.to raise_error(ImportJobMachine::InvalidTransition)
    end
  end

  describe ".available_events" do
    it "idle状態はSUBMITだけを返す" do
      expect(described_class.available_events(:idle)).to eq(%i[SUBMIT])
    end

    it "registered状態はSTART_IMPORTとDISMISS_MODALを返す" do
      expect(described_class.available_events(:registered)).to eq(%i[START_IMPORT DISMISS_MODAL])
    end
  end

  describe ".ui_layer" do
    it "registered状態ではモーダルを優先する" do
      expect(described_class.ui_layer(:registered)).to eq(:modal)
    end

    it "importing_modal_queued状態ではオーバーレイを優先する" do
      expect(described_class.ui_layer(:importing_modal_queued)).to eq(:overlay)
    end

    it "idle状態ではUI層を表示しない" do
      expect(described_class.ui_layer(:idle)).to eq(:none)
    end
  end
end
