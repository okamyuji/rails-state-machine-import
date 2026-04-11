class ImportJobsController < ApplicationController
  rescue_from ImportJobMachine::InvalidTransition, with: :handle_invalid_transition

  def index
    @jobs = ImportJob.order(created_at: :desc).limit(20)
    @matrix = build_matrix
  end

  def new
    @job = ImportJob.new(total_rows: 1000)
  end

  def show
    @job = ImportJob.find(params[:id])
  end

  def create
    @job = ImportJob.new(job_params.merge(status: "idle"))
    if @job.save
      @job.apply_event!(:SUBMIT)
      @job.apply_event!(:SUBMIT_DONE)
      redirect_to @job, notice: "登録が完了しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def event
    job = ImportJob.find(params[:id])
    job.apply_event!(params[:event], permitted_event_attrs)
    redirect_to job
  end

  private

  def job_params
    params.require(:import_job).permit(:name, :total_rows)
  end

  def permitted_event_attrs
    params.permit(:processed_rows, :error_message).to_h.symbolize_keys
  end

  def build_matrix
    ImportJobMachine::STATES.map do |state|
      row = ImportJobMachine::EVENTS.map { |event| ImportJobMachine::TRANSITIONS.dig(state, event) }
      [state, row]
    end
  end

  def handle_invalid_transition(error)
    redirect_to import_jobs_path, alert: "不正な遷移です: #{error.message}"
  end
end
