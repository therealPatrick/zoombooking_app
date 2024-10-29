class PaysController < ApplicationController
  before_action :authenticate_user!
  before_action :set_meeting

  def purchase
    # Check if user already joined
    if Booking.exists?(user_id: current_user.id, meeting_id: @meeting.id)
      return redirect_to dashboard_path, alert: "You already joined this meeting"
    end

    # Create checkout session
    checkout_session = Stripe::Checkout::Session.create(
      {
        customer: current_user.stripe_customer_id,
        client_reference_id: @meeting.id,
        mode: "payment",
        payment_method_types: ["card"],
        line_items: [
          {
            price_data: {
              product_data: {
                name: @meeting.topic,
                description: @meeting.description,
                images: [@meeting.image]
              },
              unit_amount: @meeting.price * 100,
              currency: "usd"
            },
            quantity: 1
          }
        ],
        payment_intent_data: {
          description: @meeting.topic
        },
        success_url: thank_you_url,
        cancel_url: root_url
      }
    )
    return redirect_to checkout_session.url, allow_other_host: true
  end

  def join_free
    # Check if user already exists
    if Booking.exists?(user_id: current_user.id, meeting_id: @meeting.id)
      flash[:alert] = "You already joined this meeting"
    else
      # Create a new booking
      Booking.create(
        user_id: current_user.id,
        meeting_id: @meeting.id,
        price: @meeting.price
      )
      flash[:notice] = "Joined successfully"
    end

    redirect_to dashboard_path
  end

  private

  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end
end
