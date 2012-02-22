module Etsy
	class Treasury

		include Etsy::Model

		attributes :id, :title, :description, :homepage, :mature, :locale, :hotness,
							 :hotness_color, :user_id, :user_name, :user_avatar_id,
							 :comment_count, :tags, :counts
		
		attribute :treasury_listings, :from => :listings
		attribute :created, :from => :creation_tsz

		def self.find(*identifiers_and_options)
			find_one_or_more('treasuries', identifiers_and_options)
		end

		def created_at
			Time.at(created)
		end

		def on_homepage_at
			Time.at(homepage)
		end

		def listings
			treasury_listings.map { |x| TreasuryListing.new(x, token, secret) }
		end
	end
end