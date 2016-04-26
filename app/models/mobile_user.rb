class MobileUser < User
  def self.find_and_authenticate_by(arg = {})
    user = find_by phone: arg[:phone]
    raise AuthError, 'Invalid credential' unless user.try(:pin) == arg[:pin]
    user
  end
end
