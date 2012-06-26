module Etsy
  class FeaturedTreasury

    include Etsy::Model

    attribute :id, :from => :treasury_id
    attribute :owner_id, :from => :treasury_owner_id
    attributes :url, :region, :active_date


    def self.find_all(options={})
      get_all('/featured_treasuries', options)
    end

    def self.find(*identifiers_and_options)
      find_one_or_more('featured_treasuries', identifiers_and_options)
    end

    def self.find_all_by_owner(user_id, options = {})
      get_all("/featured_treasuries/owner/#{user_id}", options)
    end

    def owner(*options)
      Etsy::User.find(owner_id, *options)
    end

    def listings(*options)
      Etsy::Listing.get_all("/featured_treasuries/#{id}/listings", *options)
    end

    def treasury(*options)
      Etsy::Treasury.find(URI(url).path.split('/').last, *options)
    end

    def activated_at
      Time.at(active_date)
    end
  end
end
