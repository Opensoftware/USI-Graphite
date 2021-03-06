class Graphite::ElectiveBlock::Enrollment < ActiveRecord::Base

  attr_accessor :enroll

  include ::Workflow

  workflow_column :state
  # States:
  # - pending: newly created enrollment gets this status by default unless
  # state set manually
  # - queued: state reserved for block enrollments with 'avg. grade' condition. Such
  # enrollments are not mantained by 'enrollment dequeue' workers. However, when
  # enrollments are done, a prioritize worker runs and enroll students
  workflow do
    state :pending do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
      event :queue, :transitions_to => :queued
    end
    state :queued do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
    end
    state :accepted
    state :rejected
    state :archived
  end

  belongs_to :elective_block
  belongs_to :elective_module, :class_name => "Graphite::ElectiveBlock::ElectiveModule"
  belongs_to :block, :class_name => "Graphite::ElectiveBlock::Block"
  belongs_to :student

  scope :pending, -> { where(:state => "pending") }
  scope :accepted, -> { where(:state => "accepted") }
  scope :queued, -> { where(:state => "queued") }
  scope :queued_or_accepted, -> { where(:state => ["queued", "accepted"]) }
  scope :not_versioned, -> {where("version" => nil)}
  scope :for_student, ->(student) { where(:student_id => student) }
  scope :for_elective_block, ->(block) { where(:elective_block_id => block) }
  scope :for_subject, ->(subject) {
    where("#{Graphite::ElectiveBlock::Enrollment.table_name}.elective_module_id" => subject) }
  scope :for_block, ->(block) {
    where("#{Graphite::ElectiveBlock::Enrollment.table_name}.block_id" => block) }

  def self.include_peripherals
    includes(:elective_module => [:translations, :employee => :employee_title])
  end
end
