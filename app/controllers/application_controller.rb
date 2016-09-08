class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def check_logs
    @import_logs = ImportLog.where(user_id: current_user.id, seen: 0)
  end

end
