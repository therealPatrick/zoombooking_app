class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  default_scope {order(created_at: :desc)}

  validates :full_name, presence: true, length: {maximum: 25}

  has_many :bookings

  after_save :assign_stripe_customer_id

   def assign_stripe_customer_id
    if self.stripe_customer_id.blank?
      customer = Stripe::Customer.create(name: self.full_name, email: self.email)
      self.update(stripe_customer_id: customer.id)
    end
  end
end
