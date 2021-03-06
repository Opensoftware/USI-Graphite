require 'has_scope'

class Graphite::ElectiveBlocksController < GraphiteController

  include ActionController::Live

  has_scope Graphite::ElectiveBlock, :by_studies, :as => :studies_id
  has_scope Graphite::ElectiveBlock, :by_semester, :as => :semester_number
  has_scope Graphite::ElectiveBlock, :by_semester_season, :as => :semester_id
  has_scope Graphite::ElectiveBlock, :by_annual, :as => :annual_id
  has_scope Graphite::ElectiveBlock, :by_block_type, :as => :block_type_id

  DEFAULT_FILTERS = {:block_type => :block_type_id, :studies => :studies_id,
                     :semester_studies => :semester_number, :semester_season => :semester_id,
                     :annual => :annual_id }.freeze

  authorize_resource except: [:index, :enroll, :check_enrollment, :event_pipe, :perform_scheduling]
  skip_authorization_check [:event_pipe]

  helper_method :pipe_name

  respond_to :html, :js, :json

  def index
    authorize! :manage, Graphite::ElectiveBlock
    @elective_blocks = apply_scopes(Graphite::ElectiveBlock, params)
    .select("lower(#{Graphite::ElectiveBlock.table_name}.name), #{Graphite::ElectiveBlock.table_name}.*")
    .include_peripherals
    .preload(:annual_studies => [:course => :translations, :study_type => :translations,
                                 :study_degree => :translations])
    .parents_only
    .order("lower(#{Graphite::ElectiveBlock.table_name}.name) ASC")
    @filters = DEFAULT_FILTERS

    if exportable_format?
      @cache_key = fragment_cache_key_for(@elective_blocks)
      @elective_blocks = @elective_blocks
      .preload(:annual, :block_type, :modules, :semester => :translations,
               :annual_studies => [:specialization => :translations])
    else
      @elective_blocks = @elective_blocks
      .paginate(:page => params[:page].to_i < 1 ? 1 : params[:page],
                :per_page => params[:per_page].to_i < 1 ? 10 : params[:per_page])
    end


    respond_with @elective_blocks do |f|
      f.js { render :layout => false }
      [:xlsx, :pdf].each do |format|
        f.send(format) do
          data = Rails.cache.fetch(@cache_key) do
            file = format.to_s.classify.constantize::ElectiveBlocksList
            .new(current_user, @elective_blocks)
            data = file.send("to_#{format}")
            Rails.cache.write(@cache_key, data)
            data
          end

          send_data(data,
                    :filename => "#{t(:label_elective_block_list)}.#{format}",
                    :type => "application/#{format}",
                    :disposition => "inline")
        end
      end
    end
  end

  def new
    @elective_block = Graphite::ElectiveBlock.new
    preload
    @elective_block.block_type = @block_types.first
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
    @elective_block = Graphite::ElectiveBlock
    .include_peripherals
    send("#{current_user.verifable_type.downcase}_#{Graphite::ElectiveBlock
    .find(params[:id]).block_type.const_name}")
    @studies = @elective_block.annual_studies.sort
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

  def destroy
    @elective_block = Graphite::ElectiveBlock.find(params[:id])
    authorize! :destroy, @elective_block

    @elective_block.destroy
    respond_with @elective_block do |f|
      f.html do
        redirect_to elective_blocks_path
      end
      f.js do
        render :layout => false
      end
    end
  end

  def collection_destroy
    @elective_blocks = Graphite::ElectiveBlock.where(:id => params[:elective_block_ids])
    authorize! :destroy, Graphite::ElectiveBlock
    @action_performed = true

    Graphite::ElectiveBlock.transaction do
      begin
        @elective_block_ids = @elective_blocks.reduce({}) {|sum, el| sum[el.id] = el.id; sum }
        @elective_blocks.destroy_all
      rescue
        @action_performed = false
        raise ActiveRecord::Rollback
      end
    end
    respond_with @elective_blocks do |f|
      f.json do
        render :layout => false
      end
    end
  end

  def perform_scheduling
    @elective_block = Graphite::ElectiveBlock.find(params[:id])
    authorize! :update, @elective_block

    Resque.enqueue(Graphite::EnrollmentsScheduler, @elective_block.id)
    @elective_block.schedule! if @elective_block.can_schedule?

    redirect_to graphite.elective_blocks_path
  end

  def enroll
    @elective_block = Graphite::ElectiveBlock.find(params[:id])
    authorize! :update, @elective_block

    if @elective_block.update(elective_block_params)
      unless @elective_block.enroll_by_average_grade?
        Resque.enqueue(Graphite::EnrollmentsDequeue, @elective_block.id, current_user.id)
      end
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
    .load.sort_by {|s| [s.course.name, s.study_type_id, s.study_degree_id] }
    @block_types = Graphite::ElectiveBlock::BlockType.all.sort
    @modules = @elective_block.modules.sort
    @blocks = @elective_block.elective_blocks.sort
    @semesters = Semester.includes(:translations).all.sort
    @annuals = Annual.all
  end

  def elective_block_params
    attrs = [:name, :block_type_id, :min_modules_amount, :min_ects_amount,
             :annual_id, :semester_id, :enroll_by_avg_grade, :study_ids => [],
             :modules_attributes => [:id, :name, :www, :owner_id, :student_amount,
                                     :ects_amount, :semester_number],
             :elective_blocks_attributes => [:id, :name, :min_ects_amount,
                                             :elective_block_id, :module_ids => []
                                             ]
             ]
    if params[:action] =~ /enroll/
      attrs |= [:enrollments_attributes => [:id, :elective_module_id,
                                            :student_id, :state, :elective_block_id, :block_id, :enroll,
                                            :priority, :_destroy]]
    end
    params.require(:elective_block).permit(attrs)
  end

  def pipe_name
    "graphite.enrollments.student_id.#{current_user.verifable_id}"
  end

  def student_elective_block_block_of_subjects
    @elective_block = @elective_block.find(params[:id])
    blocks = @elective_block.elective_blocks
    .includes(:translations, :modules => :translations)
    .sort
    @student_block_enrollments = Graphite::ElectiveBlock::Enrollment
    .for_student(current_user.student)
    .for_block(blocks).include_peripherals
    .not_versioned
    .includes(:block => [:translations, :modules => :translations])
    @enrollments = blocks.reduce([]) do |sum, block|
      sum << (@student_block_enrollments.detect {|enrollment| enrollment.block == block } ||
              block.enrollments.build({:block => block,
                                       :elective_block => @elective_block,
                                       :student => current_user.student }
                                      .merge(@elective_block.enroll_by_average_grade? ? {state: :queued} : {})))
      sum
    end
  end

  def student_elective_block_n_from_m_subjects
    @elective_block = @elective_block.find(params[:id])
    modules = @elective_block.modules.sort
    student_module_enrollments = Graphite::ElectiveBlock::Enrollment
    .for_student(current_user.student)
    .for_subject(modules).include_peripherals
    @enrollments = modules.reduce([]) do |sum, mod|
      sum << (student_module_enrollments.detect {|enrollment| enrollment.elective_module == mod } ||
              mod.enrollments.build(:elective_module => mod,
                                    :elective_block => @elective_block,
                                    :student => current_user.student))
      sum
    end
  end

  def employee_elective_block_block_of_subjects
    @elective_block = @elective_block.includes(:elective_blocks =>
                                               [:translations, :modules => :translations]).find(params[:id])
  end

  def employee_elective_block_n_from_m_subjects
    @elective_block = @elective_block.find(params[:id])
  end

end
