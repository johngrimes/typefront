module LogEvent
  def log_event(*args)
    return if RAILS_ENV == 'test'
    user = current_user
    if args.last.is_a?(Hash) and args.last[:user].present?
      user = args.last.delete(:user)
    end
    KM.identify(user.email)
    KM.record(*args)
  end

  def set_logged_name
    if current_user and current_user.full_name.present?
      KM.set('Name' => current_user.full_name)
    end
  end
end
