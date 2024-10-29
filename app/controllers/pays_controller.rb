class PaysController < ApplicationController
  before_action :authenticate_user!, except: [:webhook]
  before_action :set_meeting, except: [:webhook]

  def purchase
    # Check if user already joined
    if Booking.exists?(user_id: current_user.id, meeting_id: @meeting.id)
      return redirect_to dashboard_path, alert: "You already joined this meeting"
    end

    # Create Stripe Checkout session
    checkout_session = Stripe::Checkout::Session.create({
      customer: current_user.stripe_customer_id,
      client_reference_id: @meeting.id,
      mode: "payment",
      payment_method_types: ["card"],
      line_items: [
        {
          ""
            "product_data": {
              "name": @meeting.topic,
              "description": @meeting.description,
              "images": [@meeting.image],
            },
            "unit_amount": @meeting.price * 100,
            "currency": "usd",
          },
          "quantity": 1 , 
        }
      ],
      payment_intent_data: {
        "description": @meeting.topic
      },
      success_url: thank_you_url,
      cancel_url: root_url
    })

    return redirect_to checkout_session.url, allow_other_host: true

  end

  def join_free
    # Check if user already joined
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

  protect_from_forgery except: :webhook
  def webhook
    endpoint_secret = "whsec_298d500b68eaeb892411e2cd4d695dd04d47a21e6124a3e9a81416a3086be5f3"
    event = nil

    begin
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      payload = request.body.read
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      # Invalid payload
      render json: {message: e}, status: 400
      return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: {message: e}, status: 400
      return
    end

    if event['type'] == 'checkout.session.completed'
      create_booking(event.data.object)
    end

    render json: {message: "Success"}, status: 200
  end

  private
  def set_meeting
    @meeting = Meeting.find(params[:meeting_id])
  end

  def create_booking(checkout_session)
    # Get meeting
    meeting = Meeting.find(checkout_session.client_reference_id)

    # Get user
    user = User.find_by(stripe_customer_id: checkout_session.customer)

    # Create a new booking
    Booking.create(
      user_id: user.id,
      meeting_id: meeting.id,
      price: meeting.price
    )
  end
end