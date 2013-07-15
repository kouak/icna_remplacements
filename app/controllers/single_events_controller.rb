class SingleEventsController < ApplicationController
  load_and_authorize_resource
  # CanCan CRUD Magic ...

  def stub
    @single_events = SingleEvent.all
    respond_to do |format|
      format.json { render :json => @single_events }
    end
  end
end
