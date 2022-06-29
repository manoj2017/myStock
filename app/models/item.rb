class Item < ActiveRecord::Base

	validates :name,  presence: true

	# An item will either be in listed OR delisted state. 
	# When a file is uploaded and a record is created/ updated, the record must be in 'listed' state
	# If the user syncronizes their inventory then any item that's not present in the file must be moved to "delisted" state
	# DONT DESTROY AN ITEM
	#  - Old items should be in "delisted" state
	#  - Current items should be in "listed"
	STATE_OPTIONS = %w(delisted listed)
  	validates :state, :inclusion => {:in => STATE_OPTIONS, message: "Expecting value of state is in #{STATE_OPTIONS} but got '%{value}'."}
  	
  	validates :weight, numericality: true
  	validates :price, numericality: true

	# Use Case - Item.import(file)
	# Description - Used to import items from an csv file and save that into database
	# @param [file] file <file should be in csv format>
	# @return nil
	def self.import(file)
		return if file.blank?
		# TODO: New features to be added
		added_item_ids = []
		CSV.foreach(file.path, headers: true) do |row|
			row_hash = row.to_hash
			item = Item.find_or_initialize_by(name: row_hash["name"])
			item.state = "listed"
			item.weight = row_hash["weight"]

			### If only get price per unit present then update price = price_per_unit * weight. If both price and price per unit present then use price field
			if !row_hash["price"].present?
				item.price = (row_hash["price_per_unit"].to_f * row_hash["weight"].to_f).round(4)
			else
				item.price = row_hash["price"].round(4)
			end

			item.save
			added_item_ids << item.id
		end
		## once we update all csv will move the items to not prresent in csv to delisted state
		Item.where.not(id: added_item_ids).update_all({state: "delisted"})
	end
end
