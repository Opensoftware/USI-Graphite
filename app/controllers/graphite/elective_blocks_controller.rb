require 'has_scope'

class Graphite::ElectiveBlocksController < GraphiteController

  include ActionController::Live

  has_scope Graphite::ElectiveBlock, :by_studies, :as => :studies_id
  has_scope Graphite::ElectiveBlock, :by_semester, :as => :semester_number
  has_scope Graphite::ElectiveBlock, :by_annual, :as => :annual_id

  DEFAULT_FILTERS = {:studies => :studies_id, :semester => :semester_number, :annual => :annual_id}.freeze

  authorize_resource except: [:index, :enroll, :check_enrollment, :event_pipe]
  skip_authorization_check [:event_pipe]

  helper_method :pipe_name

  respond_to :html, :js, :json

  def index
    authorize! :manage, Graphite::ElectiveBlock
    @elective_blocks = apply_scopes(Graphite::ElectiveBlock, params)
    .select("lower(#{Graphite::ElectiveBlock.table_name}.name), #{Graphite::ElectiveBlock.table_name}.*")
    .include_peripherals
    .order("lower(#{Graphite::ElectiveBlock.table_name}.name) ASC")
    @filters = DEFAULT_FILTERS

    if exportable_format?
      @cache_key = fragment_cache_key_for(@elective_blocks)
    else
      @elective_blocks = @elective_blocks.paginate(:page => params[:page].to_i < 1 ? 1 : params[:page],
        :per_page => params[:per_page].to_i < 1 ? 10 : params[:per_page])
    end

    respond_with @elective_blocks do |f|
      f.js { render :layout => false }
      [:xlsx, :pdf].each do |format|
        f.send(format) do

        end
      end
    end
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

  def event_pipe
    raise CanCan::AccessDenied unless current_user
    response.headers["Content-Type"] = "text/event-stream"
    stream_error = false; # used by flusher thread to determine when to stop
    redis = Redis.new

    # Subscribe to our events
    redis.subscribe(pipe_name) do |on|
      on.message do |event, data| # when message is received, write to stream
        response.stream.write("event: refresh\n")
        response.stream.write("data: #{data}\n\n")
      end

      # This is the monitor / connection poker thread
      # Periodically poke the connection by attempting to write to the stream
      Thread.new do
        while !stream_error
          $redis.publish pipe_name, {}.to_json
          sleep 2.seconds
        end
      end
    end
    render nothing: true
  rescue IOError
    logger.info "Stream closed"
    stream_error = true
  ensure
    logger.info "Events action is quitting redis and closing stream!"
    redis.quit if redis
    response.stream.close  if response
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

  def pipe_name
    "graphite.enrollments.student_id.#{current_user.verifable_id}"
  end
end
