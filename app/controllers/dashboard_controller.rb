class DashboardController < ApplicationController
  before_filter :authenticate_user! # Only auth users can access dashboard
  def index
  end
end
