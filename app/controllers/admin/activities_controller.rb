class Admin::ActivitiesController < Admin::BaseController
  LIMIT = 200

  def index
    @activities = Activity.latest.limit(LIMIT)
  end
end
