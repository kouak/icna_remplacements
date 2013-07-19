class TeamsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @teams = Team.paginate(:page => params[:page])
  end

  def show
    @team = Team.find_by_team(params[:id])
  end
end
