module Etsy
	class TreasuryListing

		include Etsy::Model

		attribute :created, :from => :creation_tsz

		def created_at
			Time.at(created)
		end

		def data
			TreasuryListingData.new(result['data'], token, secret)
		end
	end

	class TreasuryListingData

		include Etsy::Model

		attributes :title, :price, :state, :user_id, :shop_name, :listing_id,
							 :image_id

		def image(*options)
			Etsy::Image.find_by_listing_id_and_image_id(listing_id, image_id, *options)
		end

		def listing(*options)
			Etsy::Listing.find(listing_id, *options)
		end

		def user(*options)
			Etsy::User.find(user_id, *options)
		end

		def shop(*options)
			Etsy::Shop.find(shop_name, *options)
		end
	end
end