$SUCCESS = 1
$ERR_USER_NOT_IN_CARAVAN = -1
$ERR_USER_ALREADY_INVITED = -1
$ERR_USER_ALREADY_HOSTING = -1
$ERR_CARAVAN_DOESNT_EXIST = -1
$ERR_NO_EXISTING_INVITATION = -1
$ERR_USER_DOESNT_EXIST = -2
$ERR_HOST_CANNOT_BE_REMOVED = -3

class Caravan < ActiveRecord::Base
  has_many :caravan_users
  
  def self.create_caravan(host_id)
    if User.where(user_id: host_id).empty?
      return $ERR_USER_DOESNT_EXIST
    end
    
    if Caravan.where(host_user_id: host_id, is_active: true).exists?
      # host cannot host more than one active caravan
      return $ERR_USER_ALREADY_HOSTING
    end
      
    caravan = Caravan.create(host_user_id: host_id, is_active: true)
    CaravanUser.create(caravan_id: caravan.caravan_id, is_host: true, 
                       user_id: host_id, accepted_invitation: true)
    return caravan
  end

  def self.invite_user(caravan_id, user_id)
    if User.where(user_id: user_id).empty?
      return $ERR_USER_DOESNT_EXIST
    end
    if CaravanUser.where(caravan_id: caravan_id, user_id: user_id).exists?
      return $ERR_USER_ALREADY_INVITED
    end
    
    CaravanUser.create(caravan_id: caravan_id, user_id: user_id,
                       accepted_invitation: false, is_host: false)
    return $SUCCESS
  end

  def self.accept_invitation(caravan_id, user_id)
    if User.where(user_id: user_id).empty?
      return $ERR_USER_DOESNT_EXIST
    end
    
    cu = CaravanUser.find_by(caravan_id: caravan_id, user_id: user_id)
    if !cu || cu.accepted_invitation == true
      return $ERR_NO_EXISTING_INVITATION
    end
      
    cu.accepted_invitation = true
    cu.save
    return $SUCCESS
  end

  def self.deny_invitation(caravan_id, user_id)
    if User.where(user_id: user_id).empty?
      return $ERR_USER_DOESNT_EXIST
    end
    
    cu = CaravanUser.find_by(caravan_id: caravan_id, user_id: user_id)
    if !cu || cu.accepted_invitation == true
      return $ERR_NO_EXISTING_INVITATION
    end

    cu.destroy
    return $SUCCESS
  end
  
  def self.remove_user(caravan_id, user_id)
    if User.where(user_id: user_id).empty?
      return $ERR_USER_DOESNT_EXIST
    end
    
    cu = CaravanUser.find_by(caravan_id: caravan_id, user_id: user_id)
    if !cu
      return $ERR_USER_NOT_IN_CARAVAN
    elsif cu.is_host
      return $ERR_HOST_CANNOT_BE_REMOVED
    end
    
    cu.destroy
    return $SUCCESS
  end

  def self.end_caravan(caravan_id)
    # TODO: handle past caravan viewing
    caravan = Caravan.find_by(caravan_id: caravan_id)
    caravan.is_active = false
    caravan.ended_at = DateTime.now
    caravan.save
  end

  def self.get_caravan(caravan_id)
    caravan = Caravan.find_by(caravan_id: caravan_id)
    if !caravan
      return $ERR_CARAVAN_DOESNT_EXIST
    end
    
    return caravan
  end

  def self.get_participants(caravan_id)
    return CaravanUser.where(caravan_id: caravan_id, 
                             accepted_invitation: true).map{|user| user.user_id}
  end
  
end
