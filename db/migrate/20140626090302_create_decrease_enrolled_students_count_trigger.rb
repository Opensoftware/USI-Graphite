class CreateDecreaseEnrolledStudentsCountTrigger < ActiveRecord::Migration
  def up
    execute <<-SQL
DROP TRIGGER IF EXISTS decrease_enrolled_students_count on graphite_elective_block_enrollments;
DROP FUNCTION IF EXISTS decrease_enrolled_students_count_func();

CREATE OR REPLACE FUNCTION decrease_enrolled_students_count_func()
RETURNS trigger AS $$
DECLARE i_enrolled_students integer;

BEGIN

IF (OLD.state = 'accepted') THEN
  i_enrolled_students := (SELECT enrolled_students FROM graphite_elective_block_elective_modules WHERE id = OLD.elective_module_id);
  IF (i_enrolled_students IS NOT NULL AND i_enrolled_students > 0) THEN
    UPDATE graphite_elective_block_elective_modules SET enrolled_students = enrolled_students - 1 WHERE id = OLD.elective_module_id;
  END IF;
END IF;

RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER decrease_enrolled_students_count BEFORE DELETE ON graphite_elective_block_enrollments FOR EACH ROW EXECUTE PROCEDURE decrease_enrolled_students_count_func();
    SQL
  end

  def down
    execute <<-SQL
DROP TRIGGER IF EXISTS decrease_enrolled_students_count on graphite_elective_block_enrollments;
DROP FUNCTION IF EXISTS decrease_enrolled_students_count_func();
    SQL
  end
end
