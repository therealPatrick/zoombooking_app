class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :meeting

  def show_purchased_at
    "#{self.created_at.to_datetime.strftime('%a, %b %d - %I:%M %p')} (AEDT)"
  end
end
