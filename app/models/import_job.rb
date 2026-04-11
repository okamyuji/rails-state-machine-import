class ImportJob < ApplicationRecord
  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: ImportJobMachine::STATES.map(&:to_s) }
  validates :total_rows, numericality: { greater_than_or_equal_to: 0 }
  validates :processed_rows, numericality: { greater_than_or_equal_to: 0 }

  # 遷移テーブルに従ってステータスを進めます。
  # 不正な遷移はImportJobMachine::InvalidTransitionとして送出されます。
  def apply_event!(event, attrs = {})
    next_status = ImportJobMachine.next_state(status, event)
    assign_attributes(attrs)
    self.status = next_status.to_s
    save!
    self
  end

  def available_events
    ImportJobMachine.available_events(status)
  end

  def ui_layer
    ImportJobMachine.ui_layer(status)
  end

  def progress_ratio
    return 0.0 if total_rows.to_i.zero?

    (processed_rows.to_f / total_rows).clamp(0.0, 1.0)
  end
end
