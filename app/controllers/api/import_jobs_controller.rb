module Api
  class ImportJobsController < ActionController::API
    rescue_from ImportJobMachine::InvalidTransition, with: :render_invalid_transition
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error

    def index
      jobs = ImportJob.order(created_at: :desc).limit(50)
      render json: jobs.map { |job| serialize(job) }
    end

    def show
      render json: serialize(ImportJob.find(params[:id]))
    end

    # 新規登録はSUBMITイベントを発火する起点です。
    # 登録成功後は自動でSUBMIT_DONEを送り、registered状態に進めます。
    def create
      job = ImportJob.new(job_params.merge(status: "idle"))
      job.save!
      job.apply_event!(:SUBMIT)
      job.apply_event!(:SUBMIT_DONE)
      render json: serialize(job), status: :created
    end

    # 汎用イベントエンドポイントです。
    # どのイベントを受理するかは遷移テーブルが決めるため、
    # コントローラはイベント名を渡すだけで分岐を持ちません。
    def event
      job = ImportJob.find(params[:id])
      job.apply_event!(params[:event], permitted_event_attrs)
      render json: serialize(job)
    end

    private

    def job_params
      params.require(:import_job).permit(:name, :total_rows)
    end

    def permitted_event_attrs
      params.permit(:processed_rows, :error_message).to_h.symbolize_keys
    end

    def serialize(job)
      {
        id: job.id,
        name: job.name,
        status: job.status,
        total_rows: job.total_rows,
        processed_rows: job.processed_rows,
        progress: job.progress_ratio,
        error_message: job.error_message,
        ui_layer: job.ui_layer,
        available_events: job.available_events
      }
    end

    def render_invalid_transition(error)
      render json: { error: "invalid_transition", message: error.message }, status: :unprocessable_content
    end

    def render_not_found
      render json: { error: "not_found" }, status: :not_found
    end

    def render_validation_error(error)
      render json: { error: "validation_failed", messages: error.record.errors.full_messages }, status: :unprocessable_content
    end
  end
end
