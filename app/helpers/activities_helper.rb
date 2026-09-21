module ActivitiesHelper
  def activity_time(activity)
    activity.created_at.strftime("%d.%m.%Y, %H:%M:%S")
  end
end
