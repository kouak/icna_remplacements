class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_team, :except => [:show]

  def index
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  private
  def fetch_team
    @team = Team.find(params[:team_id])
  end

end
