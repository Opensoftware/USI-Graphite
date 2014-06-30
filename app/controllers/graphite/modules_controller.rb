class Graphite::ModulesController < GraphiteController

  authorize_resource :class => "Graphite::ElectiveBlock::ElectiveModule"

  def new
    preload
    @module = Graphite::ElectiveBlock::ElectiveModule.new(elective_block: @elective_block)
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  def create
    @module = Graphite::ElectiveBlock::ElectiveModule.create(module_params)
    preload
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  def edit
    @module = Graphite::ElectiveBlock::ElectiveModule.find(params[:id])
    preload
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  def update
    @module = Graphite::ElectiveBlock::ElectiveModule.find(params[:id])
    @module.update(module_params)
    preload
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  def destroy
    old_mod = Graphite::ElectiveBlock::ElectiveModule.find(params[:id])
    @module = old_mod.elective_block.modules.build
    old_mod.destroy
    preload
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  private

  def module_params
    params.require(:elective_block).permit(:modules_attributes => [:id, :name,
        :www, :owner_id, :student_amount, :ects_amount, :semester_number, :elective_block_id])
    .values.first.values.first
  end

  def preload
    @elective_block = Graphite::ElectiveBlock
    .includes(:modules => [:translations, :employee => :employee_title])
    .find(params[:elective_block_id])
    @modules = @elective_block.modules.sort
    if (block_id = params[:elective_block][:elective_blocks_attributes].values.first['id']).present?
      @block = Graphite::ElectiveBlock::Block.find(block_id)
    end
  end
end
