class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :watchlists, dependent: :destroy
  has_many :user_histories, dependent: :destroy

  has_one_attached :avatar

  # after_commit :add_default_avatar, on: %i[create]

  def avatar_thumbnail
    avatar.attached? ? avatar.variant(resize_and_pad: [100, 100]).processed.url : ''
  end

  def jwt_payload # rubocop:disable Lint/UselessMethodDefinition
    super
  end
end
