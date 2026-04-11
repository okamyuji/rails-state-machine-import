# 状態遷移テーブルを用いた有限状態機械です。
# 行(STATES)と列(EVENTS)が2次元マトリクスとして定義されています。
# TRANSITIONS[state][event] が存在すればそのイベントで遷移し、
# 存在しなければそのイベントは無視されます。
module ImportJobMachine
  module_function

  STATES = %i[idle submitting registered importing importing_modal_queued paused completed failed].freeze

  EVENTS = %i[
    SUBMIT
    SUBMIT_DONE
    SUBMIT_ERROR
    START_IMPORT
    DISMISS_MODAL
    PROGRESS
    COMPLETE
    FAIL
    PAUSE
    RESUME
    RESET
  ].freeze

  # 遷移テーブルは state => { event => target_state } の二次元構造です。
  # 記事本文のマトリクスと1対1で対応しています。
  TRANSITIONS = {
    idle: {
      SUBMIT: :submitting,
    },
    submitting: {
      SUBMIT_DONE: :registered,
      SUBMIT_ERROR: :failed,
    },
    registered: {
      START_IMPORT: :importing_modal_queued,
      DISMISS_MODAL: :idle,
    },
    importing: {
      PROGRESS: :importing,
      COMPLETE: :completed,
      FAIL: :failed,
      PAUSE: :paused,
    },
    importing_modal_queued: {
      DISMISS_MODAL: :importing,
      PROGRESS: :importing_modal_queued,
      COMPLETE: :completed,
      FAIL: :failed,
      PAUSE: :paused,
    },
    paused: {
      RESUME: :importing,
    },
    completed: {
      RESET: :idle,
    },
    failed: {
      RESET: :idle,
    },
  }.freeze

  # 現在の状態から発火可能なイベント一覧を返します。
  # UIのボタン出し分けやAPIのレスポンスに利用します。
  def available_events(state)
    (TRANSITIONS[state.to_sym] || {}).keys
  end

  # 現在の状態に対してイベントを適用し、次の状態を返します。
  # 未定義の遷移はInvalidTransitionを送出して不正な遷移を構造的に排除します。
  def next_state(state, event)
    table = TRANSITIONS[state.to_sym] || {}
    target = table[event.to_sym]
    raise InvalidTransition, "#{state} cannot accept #{event}" unless target

    target
  end

  # UI層がモーダルとオーバーレイのどちらを前面に出すかを決定します。
  # オーバーレイの優先度がモーダルより高いため、両方必要な状態では
  # importing_modal_queuedを用意して優先順位を型として表現しています。
  def ui_layer(state)
    case state.to_sym
    when :registered
      :modal
    when :importing, :importing_modal_queued, :paused
      :overlay
    else
      :none
    end
  end

  class InvalidTransition < StandardError
  end
end
