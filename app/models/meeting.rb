class Meeting < ApplicationRecord
	has_many :bookings

	validates :topic, presence: true, length: {maximum: 50}
	validates :image, presence: true
	validates :start_time, presence: true
	validates :duration, presence: true

end
