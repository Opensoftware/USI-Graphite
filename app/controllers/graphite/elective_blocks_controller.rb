class Graphite::ElectiveBlocksController < GraphiteController

  authorize_resource except: [:index, :enroll, :check_enrollment]

  def index
    authorize! :manage, Graphite::ElectiveBlock
    @elective_blocks = Graphite::ElectiveBlock.all
  end

  def new
    @elective_block = Graphite::ElectiveBlock.new
    preload
  end

  def create
    @elective_block = Graphite::ElectiveBlock.new(elective_block_params)

    if @elective_block.save
      redirect_to elective_blocks_path
    end
  end

  def create_and_edit
    @elective_block = Graphite::ElectiveBlock.new(elective_block_params)

    if @elective_block.save
      redirect_to edit_elective_block_path(@elective_block)
    end
  end

  def show
    @elective_block = Graphite::ElectiveBlock.include_peripherals.find(params[:id])
    @studies = @elective_block.studies.sort
    @modules = @elective_block.modules.sort
    @student_enrollments = Graphite::ElectiveBlock::Enrollment.for_student(current_user.student)
    .for_subject(@modules).include_peripherals
    @enrollments = @modules.reduce([]) do |sum, mod|
      sum << (@student_enrollments.detect {|enrollment| enrollment.elective_module == mod } ||
          mod.enrollments.build(:elective_module_id => mod.id,
          :elective_block_id => @elective_block.id,
          :student_id => current_user.verifable_id))
      sum
    end
  end

  def edit
    @elective_block = Graphite::ElectiveBlock
    .includes(:modules => [:translations, :employee => :employee_title])
    .find(params[:id])
    preload
  end

  def update
    @elective_block = Graphite::ElectiveBlock.find(params[:id])

    if @elective_block.update(elective_block_params)
      redirect_to elective_blocks_path
    end
  end

  def enroll
    @elective_block = Graphite::ElectiveBlock.find(params[:id])
    authorize! :update, @elective_block

    if @elective_block.update(elective_block_params)
      Resque.enqueue(Graphite::EnrollmentsDequeue, @elective_block.id, current_user.id)
      redirect_to main_app.dashboard_index_path
    end

  end

  private

  def preload
    @studies = Studies.for_annual(current_annual).includes(course: :translations,
      study_type: :translations, study_degree: :translations)
    .load.sort {|s1, s2| s1.course.name <=> s2.course.name}
    @block_types = Graphite::ElectiveBlock::BlockType.all
    @modules = @elective_block.modules.sort
  end

  def elective_block_params
    attrs = [:name, :block_type_id, :min_modules_amount, :min_ects_amount,
      :annual_id, :semester_id, :study_ids => [],
      :modules_attributes => [:id, :name, :www, :owner_id, :student_amount,
        :ects_amount, :semester_number]
    ]
    if params[:action] =~ /enroll/
      attrs |= [:enrollments_attributes => [:id, :elective_module_id,
          :student_id, :elective_block_id, :enroll, :_destroy]]
    end
    params.require(:elective_block).permit(attrs)
  end
end
