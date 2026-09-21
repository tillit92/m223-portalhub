class Admin::ActivitiesController < Admin::BaseController
  LIMIT = 200

  def index
    @activities = Activity.for_action(params[:aktion]).by_user(params[:benutzer]).latest.limit(LIMIT)
    @users = User.order(:name)
  end
end
