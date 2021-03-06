class YachtsController < ApplicationController
  skip_before_action :configure_permitted_parameters, only: [:index, :show]

  def index

    if params[:query].present?
      @yachts = Yacht.search_by_title_and_description(params[:query])
    else
      @yachts = Yacht.all
    end
    @markers = @yachts.geocoded.map do |yacht|
      {
        lat: yacht.latitude,
        lng: yacht.longitude,
        infoWindow: render_to_string(partial: "info_window", locals: { yacht: yacht }),
        image_url: helpers.asset_url('ly_map_pin.png'),
        yachtId: yacht.id
      }
    end
  end

  def new
    @yacht = Yacht.new
  end

  def show
    id = params[:id]
    @yacht = Yacht.find(id)
    @photos = @yacht.photos
    @booking = Booking.new
    @markers = [
      {
        lat: @yacht.latitude,
        lng: @yacht.longitude,
        image_url: helpers.asset_url('ly_map_pin.png'),
        yachtId: @yacht.id
      }
    ]
    @review = Review.new
  end

  def create
    # byebug
    @yacht = Yacht.new(yacht_params)
    @yacht.toys = join_toys
    @yacht.user = current_user
    if @yacht.save # ensures validations pass
      redirect_to yacht_path(@yacht.id)
    else
      render :new
    end
  end

  def edit
    @yacht = Yacht.find(params[:id])
  end

  def update
    @yacht = Yacht.find(params[:id])
    @yacht.update(yacht_params)
    if @yacht.save
      redirect_to yacht_path(@yacht.id)
    else
      render :edit
    end
  end

  def destroy
    @yacht = Yacht.find(params[:id])
    @yacht.destroy
    redirect_to dashboard_path
  end

  private

  def yacht_params
    params.require(:yacht).permit(:title, :description, :weekly_price, :address,
                                  :length, :number_of_crew, :number_of_guests,
                                  :number_of_cabins, :beam, :cruising_speed, :build, :year, :toys, photos: [])
  end

  def join_toys
    toys = params.require(:yacht).require(:toys)
    toys.shift
    return toys.join(", ")
  end
end
