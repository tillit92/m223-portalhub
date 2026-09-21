# Everything under /admin is for the Admin (Rick) only. The login check comes
# from ApplicationController; this adds the role check on the server, so
# hiding the navigation link is a convenience and not the protection.
class Admin::BaseController < ApplicationController
  before_action :require_admin

  private
    def require_admin
      redirect_to root_path, alert: "Berechtigung fehlt." unless Current.user&.admin?
    end
end
