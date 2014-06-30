class Graphite::ElectiveBlock::BlocksController < GraphiteController

  authorize_resource :class => "Graphite::ElectiveBlock"

  def new
    preload
    @block = Graphite::ElectiveBlock::Block.new(elective_block: @elective_block)
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  def create
    new_block = Graphite::ElectiveBlock::Block.new(block_params)
    new_block.save
    preload
    @block = Graphite::ElectiveBlock::Block.new(elective_block: @elective_block)
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  def edit
    @block = Graphite::ElectiveBlock::Block.find(params[:id])
    preload
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  def update
    @block = Graphite::ElectiveBlock::Block.find(params[:id])
    @block.update(block_params)
    preload

    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  def destroy
    old_block = Graphite::ElectiveBlock::Block.find(params[:id])
    @block = old_block.elective_block.elective_blocks.build
    old_block.destroy
    preload
    respond_to do |f|
      f.js do
        render layout: false
      end
    end
  end

  private

  def block_params
    attrs = params.require(:elective_block).permit(:elective_blocks_attributes =>
        [:id, :name, :elective_block_id, :min_ects_amount, :student_amount,
        :module_ids => []])
    attrs.values.first.values.first
  end

  def preload
    @elective_block = Graphite::ElectiveBlock
    .includes(:translations, :modules => [:translations, :employee => :employee_title])
    .find(params[:elective_block_id])
    @blocks = @elective_block.elective_blocks.includes(:translations).sort
    @modules = @elective_block.modules.sort
  end
end
