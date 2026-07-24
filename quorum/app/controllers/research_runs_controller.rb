class ResearchRunsController < ApplicationController
  before_action :set_lunch_room
  before_action :set_research_run, only: :show

  def create
    if @lunch_room.participants.empty?
      redirect_to lunch_room_path(@lunch_room, anchor: "people"), alert: "Add at least one person before finding lunch."
      return
    end

    @research_run = @lunch_room.research_runs.create!(
      query: LunchResearch::PromptBuilder.new(@lunch_room).query,
      started_at: Time.current
    )
    LunchResearch::Orchestrator.new(@research_run).start!
    redirect_to lunch_room_research_run_path(@lunch_room, @research_run)
  rescue YouCom::ConfigurationError, YouCom::RequestError => error
    @research_run&.update(status: :failed, error_message: error.message)
    redirect_to lunch_room_path(@lunch_room), alert: error.message
  end

  def show
    LunchResearch::Orchestrator.new(@research_run).poll! unless @research_run.terminal?
    @research_run.reload

    respond_to do |format|
      format.html
      format.json do
        render json: {
          status: @research_run.status,
          message: progress_message,
          room_url: @research_run.completed? ? lunch_room_path(@lunch_room) : nil,
          error: @research_run.error_message
        }
      end
    end
  rescue YouCom::RequestError => error
    @research_run.update!(status: :failed, error_message: error.message)
    respond_to do |format|
      format.html { redirect_to lunch_room_path(@lunch_room), alert: error.message }
      format.json { render json: { status: "failed", error: error.message }, status: :bad_gateway }
    end
  end

  private

  def set_research_run
    @research_run = @lunch_room.research_runs.find(params[:id])
  end

  def progress_message
    {
      "queued" => "Gathering everyone’s non-negotiables…",
      "searching" => "Checking what is actually nearby…",
      "reading" => "Reading menus, hours, and prices…",
      "reasoning" => "Finding the place nobody has to compromise on…",
      "completed" => "Your shortlist is ready.",
      "failed" => @research_run.error_message
    }.fetch(@research_run.status)
  end
end
