$SUCCESS = 1
$ERR_USER_DOESNT_EXIST = -2
$ERR_CARAVAN_ALREADY_EXISTS = -11
$ERR_CARAVAN_DOESNT_EXIST = -12
$ERR_CARAVAN_USER_ALREADY_EXISTS = -13
$ERR_CARAVAN_USER_DOESNT_EXIST = -14
$ERR_ALREADY_A_HOST = -15

class Caravan < ActiveRecord::Base
  has_many :caravan_users
  
  def self.invite_user(caravan_id, user_id)
    if CaravanUser.where(caravan_id: caravan_id, user_id: user_id).empty?
      CaravanUser.create(caravan_id: caravan_id, user_id: user_id,
                         accepted_invitation: false, is_host: false)
    end
  end

  def self.user_accept_invitation(caravan_id, user_id)
    cu = CaravanUser.find_by(caravan_id: caravan_id, user_id: user_id)
    if cu
      cu.accepted_invitation = true
      cu.save
    end
  end

  def self.remove_user(caravan_id, user_id)
    cu = CaravanUser.find_by(caravan_id: caravan_id, user_id: user_id)
    if cu && !cu.is_host     # host cannot leave
      cu.destroy
    end
  end

  def self.add_caravan(host_id)
    # host cannot host more than one caravan
    already_hosting = Caravan.where(host_user_id: host_id,
                                    is_active: true).exists?
    if !already_hosting
      caravan = Caravan.create(host_user_id: host_id, is_active: true)
      cu = CaravanUser.create(caravan_id: caravan.caravan_id, is_host: true, 
                              user_id: host_id, accepted_invitation: true)
      return cu
    else
      # already hosting, what to return?
    end
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
    return CaravanUser.where(caravan_id: id, accepted_invitation: true).map{|user| user.user_id}
  end
  
end
