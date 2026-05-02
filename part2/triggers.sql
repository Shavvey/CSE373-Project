/**
* TRIGGER 1: Ensure that only a member in 
* good standing can join the Board and also
* that there is never more than one president.
**/
CREATE OR REPLACE TRIGGER
  board_member_president_aiusd -- after insert or update, but before commit
BEFORE INSERT OR UPDATE
ON board_member
REFERENCING NEW AS n
for each row
DECLARE
  mem_standing member.standing%type;
  r_count number;
BEGIN
-- Get standing
 SELECT standing INTO mem_standing
 FROM member
 WHERE :n.member_id = member.member_id;
  -- Trigger exception if president candidate is in poor standing
  IF (mem_standing = 'poor') THEN
    raise_application_error(-20001, 'Board member must be in good standing');
  END IF;
  IF (:n.role = 'president') THEN
    SELECT COUNT(*) INTO r_count
    FROM board_member
    WHERE role = :n.role;
    IF r_count > 0 THEN
      raise_application_error(-20002, 'Can only be one president');
    END IF;
  END IF;
END;
/
show errors

/**
* TRIGGER 2: If a person becoming a member for the first time had attended a public
* meeting in the past, then print a thank-you message for attendance on
* that date.
**/
CREATE OR REPLACE TRIGGER
  member_thank_you_aird
AFTER INSERT
ON member
REFERENCING NEW as n
for each row
DECLARE
  CURSOR visitor_cursor IS SELECT fname, lname, email, meet_date FROM visitor;
  vis_fname visitor.fname%type;
  vis_lname visitor.lname%type;
  vis_email visitor.email%type;
  vis_meet_date visitor.meet_date%type;
BEGIN
  OPEN visitor_cursor;
  LOOP
    FETCH visitor_cursor INTO vis_fname, vis_lname, vis_email, vis_meet_date;
    IF (:n.fname = vis_fname) AND (:n.lname = vis_lname)
      AND (:n.email = vis_email) THEN
      dbms_output.put_line('Thank you for attending meet on: ' || vis_meet_date); 
    END IF;
    EXIT WHEN visitor_cursor%NOTFOUND;
  END LOOP;
  CLOSE visitor_cursor;
END;
/
show errors
