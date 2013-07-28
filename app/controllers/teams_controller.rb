class TeamsController < ApplicationController
  before_filter :authenticate_user!

  before_action :prepare_date, :only => [:who_can_replace_on, :who_can_permute_on]

  def index
    @teams = Team.paginate(:page => params[:page])
  end

  def show
    @team = Team.find_by_team(params[:id])
  end

  def who_can_replace_on
    @teams = current_user.team.who_can_replace_on(@date).paginate(:page => params[:page])
    render 'index'
  end

  def who_can_permute_on
    @teams = current_user.team.who_can_permute_on(@date).paginate(:page => params[:page])
    render 'index'
  end

  private
  # POST who_could_X_on date => YYYYMMDD
  def prepare_date
    raise ActionController::RoutingError.new('Not Found') if params[:date].nil?
    @date = Time.strptime(params[:date], '%Y%m%d')
    puts @date
  end
end
