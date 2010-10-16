class Api::V1::ProjectsController < Api::BaseController
  respond_to :json
  
  before_filter :current_project, :only => [:github]
  
  def github
    payload = JSON.parse params["payload"]
    if payload && payload["commits"].count > 0
      payload["commits"].each do |commit|
        user = User.where(:email => commit["author"]["email"]).first
        status = @project.statuses.new(:link => commit["url"], :text => commit["message"], :source => "GitHub")
        status.user = user if user
        status.save
      end
    end
    head 200
  end
  
  private
  
  def current_project
    unless @project = Project.where(:id => params[:id], :api_token => params[:token]).first
      raise ActiveRecord::RecordNotFound
    end
  end
end
