-- NOTE: This is so I can so dbms output commands
-- that can be displayed in the interactive session
SET SERVEROUTPUT ON;

/**
* PROCEDURE 1: find_id_name(last): display the ID, first and last name of all members 
* (regardless of their membership standing) whose last name contains 
* last (the parameter!) as a substring. Print a message if there is
* no such member.
**/
-- Help function
CREATE OR REPLACE PROCEDURE get_lname
  (last IN member.lname%type,
   mem_id OUT member.member_id%type,
   first_name OUT member.fname %type,
   last_name OUT member.lname%type,
   status OUT boolean)
IS
BEGIN
  SELECT member_id, fname, lname INTO mem_id, first_name, last_name
  FROM member WHERE lname = last;
  status := true;
EXCEPTION
  WHEN no_data_found THEN
    status := false;
END;
/
show errors

CREATE OR REPLACE PROCEDURE find_id_name
  (last IN member.lname%type)
IS
  first_name VARCHAR(20);
  last_name VARCHAR(20);
  mem_id number;
  status boolean;
BEGIN
  get_lname(last, mem_id, first_name, last_name, status);
  IF status THEN
    dbms_output.put_line('Member found: ' || mem_id || ',' || last_name || ',' || first_name);
  ELSE
    dbms_output.put_line('Member not found ');
  END IF;
END;
/
show errors
execute find_id_name('holmes');

/**
* PROCEDURE 2: enroll_or_renew(first, last, email): if a person with the
* given first name, last name, and email address is a member in good
* standing, then extend the membership by one year; if the membership
* has expired, then set the expiration date to one year from today.
* If no such person is found among the past or present members, then
* enroll this person as a new member.
**/

-- Helper function
CREATE OR REPLACE PROCEDURE get_standing_and_expiry
  (first IN member.fname%type,
   last IN member.lname%type,
   mem_email IN member.email%type, 
   mem_standing OUT member.standing%type,
   status OUT boolean, -- NOTE: Check if record exists
   is_expired OUT boolean)
IS
  mem_expr member.member_expr%type;
BEGIN
  SELECT member_expr, standing INTO mem_expr, mem_standing
  FROM member m
  WHERE first = fname
  AND last = lname
  AND mem_email = email;
  status := true;
  IF TRUNC(mem_expr) - TRUNC(SYSDATE) < 0 THEN
    is_expired := true;
  ELSE
    is_expired := false;
  END IF;
EXCEPTION
  WHEN no_data_found THEN
    status := false;
END;
/
show errors

CREATE OR REPLACE PROCEDURE enroll_or_renew
  (first IN member.fname%type,
   last IN member.lname%type,
   mem_email IN member.email%type)
IS
  status boolean;
  is_expired boolean;
  mem_standing member.standing%type;
BEGIN
  get_standing_and_expiry(first, last, mem_email, mem_standing, status, is_expired);
  IF status THEN
    IF is_expired AND mem_standing = 'good' THEN
      UPDATE member m
      -- Extend membership one year from today
      SET member_expr = ADD_MONTHS(SYSDATE, 12)
      WHERE first = fname
      AND last = lname
      AND mem_email = email;
    END IF;
    IF NOT is_expired AND mem_standing = 'good' THEN
      UPDATE member m
      SET member_expr = ADD_MONTHS(member_expr, 12)
      WHERE first = fname
      AND last = lname
      AND mem_email = email;
    END IF;
  ELSE
    -- If entry doesn't already exists, add it 
    IF NOT status THEN
      INSERT INTO member (member_id, fname, lname, 
        email, member_expr,
        date_joined, date_of_record, standing)
      VALUES(id_seq.NEXTVAL, first, last, mem_email,
        ADD_MONTHS(SYSDATE, 12), 
        SYSDATE, SYSDATE, 'good');
    END IF;
  END IF;
END;
/
show errors
execute enroll_or_renew('royal', 'tennenbaum', 'royalt@gmail.com');
commit;

/*
* PROCEDURE 3: flag_graduated_children( ): find members all of whose children
* should have graduated by now; list their ID, first and last name.
**/

-- Helper function
CREATE OR REPLACE PROCEDURE get_child_dor
  (mem_id IN member.member_id%type,
   status OUT boolean,
   is_graduated OUT boolean)
IS
  CURSOR child_cursor IS SELECT member_id, date_of_record FROM member_child;
  dor member_child.date_of_record%type;
  child_mem_id member_child.member_id%type;
BEGIN
  is_graduated := false;
  status := false;
  OPEN child_cursor;
  LOOP
    FETCH child_cursor into child_mem_id, dor;
    IF TRUNC(MONTHS_BETWEEN(SYSDATE, dor)/12) >= 4 
      AND child_mem_id = mem_id THEN
      is_graduated := true;
      status := true;
      EXIT;
    END IF;
    EXIT WHEN child_cursor%NOTFOUND;
  END LOOP;
  CLOSE child_cursor;
END;
/
show errors

CREATE OR REPLACE PROCEDURE flag_graduated_children
IS
  is_graduated BOOLEAN;
  status BOOLEAN;
  first_name member.fname%type;
  last_name member.lname%type;
  mem_id member.member_id%type;
BEGIN
  is_graduated := false;
  status := false;
  SELECT member_id, fname, lname INTO mem_id, first_name, last_name
  FROM member;
  get_child_dor(mem_id, status, is_graduated);
  IF status AND is_graduated THEN
    dbms_output.put_line('Flaged member for child grad: ' || mem_id || ', ' || first_name|| ', ' || last_name);
  END IF;
EXCEPTION
  -- NOTE: Hacky way to ingore duplicates
  WHEN too_many_rows THEN
    dbms_output.put_line('Flag member for child grad: ' || mem_id || ', ' || first_name|| ', ' || last_name);
END;

/
show errors
execute flag_graduated_children
SET SERVEROUTPUT OFF;
