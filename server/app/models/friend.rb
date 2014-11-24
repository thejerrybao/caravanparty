$SUCCESS = "SUCCESS"
$ERR_USER_ALREADY_FRIENDS = "ERR_USER_ALREADY_FRIENDS"
$ERR_USER_NOT_FRIENDS = "ERR_USER_NOT_FRIENDS"
$ERR_USER_DOESNT_EXIST = "ERR_USER_DOESNT_EXIST"
$ERR_USER_NO_REQUEST = "ERR_USER_NO_REQUEST"

class Friend < ActiveRecord::Base
  belongs_to :user, foreign_key: 'user_id'

  # Get all of my approved friends 
  def self.all_friends(id)
    return Friend.where(user_id: id, is_approved: true).to_a +
      Friend.where(other_user_id: id, is_approved: true).to_a
  end

  # Get all pending friend requests that others have made to me
  def self.get_pending_requests(id)
    return Friend.where(other_user_id: id, is_approved: false).to_a
  end

  def self.add(id1, id2)
    if User.where(user_id: id2).empty? # user_id2 doesn't exist
      return $ERR_USER_DOESNT_EXIST
    end

    if Friend.where(user_id: id1, other_user_id: id2).exists? ||
        Friend.where(user_id: id2, other_user_id: id1, is_approved: true).exists?
      # already friends
      return $ERR_USER_ALREADY_FRIENDS
    elsif Friend.where(user_id: id2, other_user_id: id1).exists?
      # other friend already made the request, not accepted yet
      return self.accept(id1, id2)
    else
      Friend.create(user_id: id1, other_user_id: id2, is_approved: false)
    end
    
    return $SUCCESS
  end

  def self.remove(id1, id2)
    if User.where(user_id: id2).empty? # user_id2 doesn't exist
      return $ERR_USER_DOESNT_EXIST
    end

    if Friend.where(user_id: id1, other_user_id: id2).blank? &&
        Friend.where(user_id: id2, other_user_id: id1).blank?
      # no friendship entry
      return $ERR_USER_NOT_FRIENDS
    end

    Friend.destroy_all(user_id: id2, other_user_id: id1)
    Friend.destroy_all(user_id: id1, other_user_id: id2)

    return $SUCCESS
  end
  
  def self.accept(id1, id2)
    err = self.check_request(id1, id2)
    if err != $SUCCESS
      return err
    end
    
    friend = Friend.where(user_id: id2, other_user_id: id1).first
    friend.is_approved = true
    friend.save
    return $SUCCESS
  end

  def self.deny(id1, id2)
    err = self.check_request(id1, id2)
    if err != $SUCCESS
      return err
    end
    
    self.remove(id1, id2)
    return $SUCCESS
  end

  def self.check_request(id1, id2)
    if User.where(user_id: id1).empty? || User.where(user_id: id2).empty?
      return $ERR_USER_DOESNT_EXIST
    end
    
    friend = Friend.where(user_id: id2, other_user_id: id1).first
    if !friend
      return $ERR_USER_NO_REQUEST
    elsif friend.is_approved
      return $ERR_USER_ALREADY_FRIENDS
    end
    
    return $SUCCESS
  end

end
