class ApplicationRecord < ActiveRecord::Base
  include FriendlyId
  
  self.abstract_class = true
end
