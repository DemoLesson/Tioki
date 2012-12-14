class PricingModel < ActiveRecord::Base
  validates_presence_of :country
  validates_presence_of :region
  validates_inclusion_of :cycle_length, :in => %w(Annually Quarterly Monthly)
  validates_presence_of :price_per_cycle
end
