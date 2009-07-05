# Raised when user tries to access page he/she has no access to
class PermissionDenied < Exception
end

ActionController::Base.rescue_responses['PermissionDenied'] = :forbidden
