$SUCCESS = "SUCCESS"
$ERR_USER_NOT_IN_CARAVAN = "ERR_USER_NOT_IN_CARAVAN"
$ERR_USER_ALREADY_INVITED = "ERR_USER_ALREADY_INVITED"
$ERR_USER_ALREADY_HOSTING = "ERR_USER_ALREADY_HOSTING"
$ERR_CARAVAN_DOESNT_EXIST = "ERR_CARAVAN_DOESNT_EXIST"
$ERR_NO_EXISTING_INVITATION = "ERR_NO_EXISTING_INVITATION"
$ERR_USER_DOESNT_EXIST = "ERR_USER_DOESNT_EXIST"
$ERR_HOST_CANNOT_BE_REMOVED = "ERR_HOST_CANNOT_BE_REMOVED"

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
      
    caravan = Caravan.create(host_user_id: host_id, is_active: true, 
                             dest_latitude: 0.0, dest_longitude: 0.0)
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
    users = CaravanUser.where(caravan_id: caravan_id, 
                              accepted_invitation: true).map{|user| user.user_id}

    participants = {}
    for i in 0..(users.length - 1)
      user = User.find_by(user_id: users[i])
      participants[Integer(users[i])] = {:latitude => user.latitude, :longitude => user.longitude}
    end

    return participants
  end

  def self.set_destination(caravan_id, destination)
    caravan = Caravan.find_by(caravan_id: caravan_id)
    if !caravan
      return $ERR_CARAVAN_DOESNT_EXIST
    end

    destination = destination.split('+')
    lat, lng = destination.map{|s| Float(s)}

    caravan.dest_latitude = lat
    caravan.dest_longitude = lng
    caravan.save

    return $SUCCESS
  end
    
  
end
