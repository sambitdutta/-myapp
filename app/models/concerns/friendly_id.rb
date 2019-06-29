module FriendlyId
  extend ActiveSupport::Concern

  included do
    self.define_singleton_method :friendly_id do |friendly_id|
      public define_method(:to_param) { send(friendly_id) }

      (class << self; self; end).instance_eval do
        public define_method(:find_friendly) { |search|
          find_by(friendly_id => search) ||
          find_by(primary_key => search) ||
          raise(ActiveRecord::RecordNotFound, 'Unable find record')
        }
      end
    end
  end
end
