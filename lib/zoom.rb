require 'http'
require 'base64'

module Zoom
  class MeetingService
    ACCOUNT_ID =  Rails.application.credentials.zoom.account_id
    CLIENT_ID =  Rails.application.credentials.zoom.client_id
    CLIENT_SECRET =  Rails.application.credentials.zoom.client_secret
    USER_ID =  Rails.application.credentials.zoom.user_id

    
    def create_meeting(payload)
      begin
        access_token = get_access_token
        response = HTTP.post(
          "https://api.zoom.us/v2/users/#{USER_ID}/meetings",
          headers: {
            authorization: access_token
          },
          json: payload
        )
      rescue Exception => e
        puts e.message
      end
    end

    def update_meeting(meeting_id, payload)
      begin
        access_token = get_access_token
        response = HTTP.patch(
          "https://api.zoom.us/v2/meetings/#{meeting_id}",
          headers: {
            authorization: access_token
          },
          json: payload
        )
      rescue Exception => e
        puts e.message
      end
    end

    private

    def get_access_token
      auth = "Basic " + Base64.encode64("#{CLIENT_ID}:#{CLIENT_SECRET}").delete("\n")

      # Get access token
      response = HTTP.post(
        "https://zoom.us/oauth/token",
        headers: { authorization: auth },
        params: {
          grant_type: "account_credentials",
          account_id: ACCOUNT_ID
        }
      )
      data = response.parse
      access_token = "Bearer " + data["access_token"]
    end
  end
end
