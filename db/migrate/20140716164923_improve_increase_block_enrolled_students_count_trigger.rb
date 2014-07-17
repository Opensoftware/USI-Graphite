class ImproveIncreaseBlockEnrolledStudentsCountTrigger < ActiveRecord::Migration
  def up
    execute <<-SQL
DROP TRIGGER IF EXISTS increase_block_enrolled_students_count on graphite_elective_block_enrollments;
DROP FUNCTION IF EXISTS increase_block_enrolled_students_count_func();

CREATE OR REPLACE FUNCTION increase_block_enrolled_students_count_func()
RETURNS trigger AS $$
DECLARE i_enrolled_students integer;
DECLARE i_student_amount integer;
DECLARE i_student_enrollments integer;

BEGIN

-- Perform validation only for records having 'accepted' state
IF (NEW.state = 'accepted' AND NEW.block_id IS NOT NULL) THEN
  i_student_amount := (SELECT student_amount FROM graphite_elective_block_blocks WHERE id = NEW.block_id);
  -- Perform validation only for subjects having max student limit
  IF (i_student_amount IS NOT NULL) THEN
    i_enrolled_students := (SELECT count(*) FROM graphite_elective_block_enrollments WHERE block_id = NEW.block_id AND state = 'accepted');
    -- Let a student enroll if there're still free places and delete his enrollment otherwise
    IF (i_student_amount > i_enrolled_students) THEN
      i_student_enrollments := (SELECT count(*) FROM graphite_elective_block_enrollments WHERE block_id = NEW.block_id AND student_id = NEW.student_id AND state = 'accepted');
      -- Increase enrolled_students counter only if he hasn't been enrolled yet
      IF (i_student_enrollments = 0) THEN
        UPDATE graphite_elective_block_blocks SET enrolled_students = enrolled_students + 1 WHERE id = NEW.block_id;
	RETURN NEW;
      ELSIF (SELECT enroll_by_avg_grade FROM graphite_elective_blocks WHERE id = NEW.elective_block_id) THEN
        NEW.state = 'queued';
	RETURN NEW;
      ELSE
        RETURN NULL;
      END IF;
      RETURN NEW;
    ELSE
      -- Students limit for given subject has been reached; delete any other enrollments
      DELETE FROM graphite_elective_block_enrollments WHERE id = NEW.id;
      RETURN NULL;
    END IF;
  ELSE
    RETURN NEW;
  END IF;
ELSE
  RETURN NEW;
END IF;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increase_block_enrolled_students_count BEFORE INSERT OR UPDATE ON graphite_elective_block_enrollments FOR EACH ROW EXECUTE PROCEDURE increase_block_enrolled_students_count_func();
    SQL
  end

  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS increase_block_enrolled_students_count on graphite_elective_block_enrollments;
DROP FUNCTION IF EXISTS increase_block_enrolled_students_count_func();
    SQL
  end
end
