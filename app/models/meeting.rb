class Meeting < ApplicationRecord
	include Zoom


	has_many :bookings

	validates :topic, presence: true, length: {maximum: 50}
	validates :image, presence: true
	validates :start_time, presence: true
	validates :duration, presence: true

	after_create :create_zoom_meeting
	after_update :update_zoom_meeting


	def create_zoom_meeting
		payload = {
			topic: self.topic,
			password: self.password,
			start_time: self.start_time.to_datetime.strftime("%Y-%m-%dT%H:%M:%S"),
			duration: self.duration,
			time_zone: "Zambia/Lusaka"
		}
		
		# create new meeting on zoom server
		zoom_meeting = Zoom::MeetingService.new.create_meeting(payload)
		data = JSON.parse(zoom_meeting)
		puts data

		# save zoom_id to database 
		self.zoom_id = data["id"].to_i
		self.save
	end

	def update_zoom_meeting
		payload = {
			topic: self.topic,
			password: self.password,
			start_time: self.start_time.to_datetime.strftime("%Y-%m-%dT%H:%M:%S"),
			duration: self.duration,
		}
		# update the existing meeting 
		Zoom::MeetingService.new.update_meeting(self.zoom_id,payload)
	end
end
