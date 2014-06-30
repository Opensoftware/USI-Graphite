class Graphite::ElectiveBlock::Enrollment < ActiveRecord::Base

  attr_accessor :enroll

  include ::Workflow

  workflow_column :state
  workflow do
    state :pending do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
    end
    state :accepted
    state :rejected
  end

  belongs_to :elective_block
  belongs_to :elective_module, :class_name => "Graphite::ElectiveBlock::ElectiveModule"
  belongs_to :block, :class_name => "Graphite::ElectiveBlock::Block"
  belongs_to :student

  scope :pending, -> { where(:state => "pending") }
  scope :accepted, -> { where(:state => "accepted") }
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
