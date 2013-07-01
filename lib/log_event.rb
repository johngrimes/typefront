module LogEvent
  def log_event(*args)
    return if RAILS_ENV == 'test'
    user = current_user
    if args.last.is_a?(Hash) and args.last[:user].present?
      user = args.last.delete(:user)
    end
    KM.identify(user.email)
    KM.record(*args)
    KM.set('Name' => user.full_name)
  end
end
