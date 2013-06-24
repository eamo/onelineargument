class User < ActiveRecord::Base
  
  def self.create_with_omniauth(auth)
    user = User.new()
    user.provider = auth['provider']
    user.uid = auth['uid']
    if auth['info']
       user.name = auth['info']['name'] || ""
       user.email = auth['info']['email'] || ""
       user.token = auth['credentials']['token']
       user.secret = auth['credentials']['secret']
    end
    user.save!
    return user
  end

end
