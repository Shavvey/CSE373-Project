-- NOTE: This is so I can so dbms output commands
-- that can be displayed in the interactive session
SET SERVEROUTPUT ON;
/**
* PROCEDURE 1: find_id_name(last): display the ID, first and last name of all members 
* (regardless of their membership standing) whose last name contains 
* last (the parameter!) as a substring. Print a message if there is
* no such member.
**/
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

CREATE OR REPLACE PROCEDURE procedure_1
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
execute procedure_1('holmes');

SET SERVEROUTPUT OFF;
