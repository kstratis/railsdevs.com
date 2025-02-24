class Developer < ApplicationRecord
  include Availability
  include Avatarable
  include HasSocialProfiles

  enum search_status: {
    actively_looking: 1,
    open: 2,
    not_interested: 3
  }

  belongs_to :user
  has_many :conversations, -> { visible }
  has_one :location, dependent: :destroy, autosave: true
  has_one :role_type, dependent: :destroy, autosave: true
  has_one_attached :cover_image

  has_noticed_notifications

  accepts_nested_attributes_for :role_type, update_only: true
  accepts_nested_attributes_for :location, reject_if: :all_blank, update_only: true

  validates :name, presence: true
  validates :hero, presence: true
  validates :bio, presence: true
  validates :location, presence: true, on: :create
  validates :cover_image, content_type: ["image/png", "image/jpeg", "image/jpg"],
    max_file_size: 10.megabytes

  scope :filter_by_utc_offset, ->(utc_offset) do
    joins(:location).where(locations: {utc_offset:})
  end

  scope :filter_by_role_types, ->(role_types) do
    RoleType::TYPES.filter_map { |type|
      where(role_type: {type => true}) if role_types.include?(type)
    }.reduce(:or).joins(:role_type)
  end

  scope :available, -> { where(available_on: ..Time.current.to_date) }
  scope :newest_first, -> { order(created_at: :desc) }
  scope :available_first, -> { where.not(available_on: nil).order(:available_on) }

  after_create_commit :send_admin_notification

  def role_type
    super || build_role_type
  end

  def location
    super || build_location
  end

  private

  def send_admin_notification
    NewDeveloperProfileNotification.with(developer: self).deliver_later(User.admin)
  end
end
