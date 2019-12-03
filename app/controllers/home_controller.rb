MetaTags = Struct.new(:title, :image, :description)

# Handles static pages
class HomeController < ApplicationController
  def index
    @meta = MetaTags.new
    listings_scope = @group.listings_for_self_and_descendants

    if request.path.include?('listings/')
      listing = listings_scope.find_by_id(request.path.split('/')[2])
      if listing
        @meta.title = listing.building_name
        @meta.image = listing.image_url
        @meta.description = "Apply for affordable housing at #{listing.building_name} on #{@group.name}'s Housing Portal"
      end
    end

    if @meta.title.nil?
      @meta.title = "#{@group.name} Affordable Housing Portal"
      @meta.image = 'https://' + @group.domain + ActionController::Base.helpers.asset_path("#{@group.slug}-banner.jpg", type: :image)
      @meta.description = "Search and apply for affordable housing on #{@group.name}'s Housing Portal"
    end
  end
end
