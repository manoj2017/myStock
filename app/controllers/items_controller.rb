class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]

  ITEMS_PER_PAGE = 50

  # GET /items
  # GET /items.json
  def index
    # @all_items = Item.all
    # @all_items_count = Item.count
    @items = Item.order("id DESC").paginate(page: params[:page], per_page: ITEMS_PER_PAGE)
  end

  # GET /items/1
  # GET /items/1.json
  def show
    @item = Item.find(params[:id])
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        flash[:notice] = 'Item was successfully created.'
        format.html { redirect_to item_path(@item) }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to @item }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      flash[:notice] = 'Item was successfully destroyed.'
      format.html { redirect_to items_url }
      format.json { head :no_content }
    end
  end

  # post method import
  # /items/import
  def import
    file_params = params[:csv_file]
    if file_params.blank?
      flash[:warning] = "Please select a file."
      redirect_to upload_path
      return
    end
    Item.import(file_params)
    redirect_to items_path, notice: 'Items uploaded successfully'
    return
  end

  # /upload/
  def upload
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:name, :weight, :price, :state)
    end
end
