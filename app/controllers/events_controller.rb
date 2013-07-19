class EventsController < ApplicationController
  before_filter :authenticate_user!

  def index
    # parameters sanitization
    starttime = params[:start].to_i > 0 ? Time.at(params[:start].to_i) : Time.now - 30.days
    endtime = params[:end].to_i > 0 ? Time.at(params[:end].to_i) : Time.now + 30.days

    # model query
    @single_events = current_user.work_events_between(starttime, endtime)
    respond_to do |format|
      format.json
    end
  end
end