class User < ApplicationRecord
  has_secure_password

  has_many :messages

  attr_accessor :reset_token

  friendly_id :username

  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }, on: :create
  validates :username, presence: true, uniqueness: true, length: { minimum: 5 }, on: :update, if: -> (obj) { !obj.new_record? }
  validates :password, length: { minimum: 8 }

  before_create :assign_username

  # after_create :send_welcome_email

  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end
  end

  def new_token
    Digest::MD5.hexdigest [self.email, Time.zone.now.to_i].join('-')
  end

  def reset_token_expired?
    self.reset_token_sent_at < 6.hours.ago
  end

  def authentic_reset_token?(token)
    BCrypt::Password.new(self.reset_token_digest) == token
  end

  def create_reset_token
    self.reset_token = self.new_token
    assign_attributes(reset_token_digest: User.digest(self.reset_token), reset_token_sent_at: Time.zone.now)
    save(validate: false)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver
  end

  def send_welcome_email
    UserMailer.welcome(self).deliver
  end

  private

  def assign_username
    self.username = self.email.scan(/[^@]+/).first
  end
end
