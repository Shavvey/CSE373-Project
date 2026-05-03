/**
* CSE373 - Introduction to Databases - Project
* ============================================
* Name: Cole Johnson
* Due Date: 5/2/2026
*
* I certify that this assignment has been
* completed by myself.
*
* == WHAT DOESN'T WORK =======================
*
* - INCLUSION DEPENDENCIES: There isn't a good
* way to implement these in SQL. I tried using
* update triggers, but it was buggy and enforce
* particular insertion order. So, unfortunately
* I didn't have a good solution for implementing
* them into my schema. 
*
* - TRIGGER 2: I'm not sure why it's not working.
* I think dbms_output.put_line doesn't work in
* interactive sessions or can't be used in triggers.
*
**/

-- set up spooling, if not already enabled
set echo ON
SPOOL cj_johnson

-- STEP 1: Create schema
CREATE SEQUENCE id_seq START WITH 9000001 INCREMENT BY 1;

create table member(
  member_id      DECIMAL(7,0) DEFAULT id_seq.NEXTVAL,
  fname          VARCHAR(20) NOT NULL,
  lname          VARCHAR(20) NOT NULL,
  email          VARCHAR(30) NOT NULL,
  zip            DECIMAL(5,0), -- NOTE: VARCHAR might also be acceptable
  street         VARCHAR(20),
  city           VARCHAR(20),
  member_expr    DATE NOT NULL, -- NOTE: When the member's expiration date is
  date_joined    DATE NOT NULL,
  date_of_record DATE NOT NULL, -- NOTE: When we first learned this info
  standing      CHAR(4) NOT NULL CHECK (standing in ('good', 'poor')),
  -- NOTE: Above tracks the standing of each member
  CONSTRAINT member_pk PRIMARY KEY (member_id), -- primary key constraint
  CONSTRAINT has_member_id_prefix CHECK (member_id LIKE '900%') -- make sure each ID has 900 prefix
  -- NOTE: last name and first can also be used for identification, put ID is preferred and designated as key
);

create table school(
  school_name      VARCHAR(20) NOT NULL,
  principle_lname  VARCHAR(20) NOT NULL,
  principle_fname  VARCHAR(20) NOT NULL,
  is_middleschool  CHAR(1) NOT NULL CHECK (is_middleschool in ('y', 'n')), 
  is_highschool    CHAR(1) NOT NULL CHECK (is_highschool in ('y', 'n')),
  CONSTRAINT school_pk PRIMARY KEY (school_name) -- school name is unique
);

-- Tracks volunteered members to be a school liason
create table volunteer_liason(
  member_id   DECIMAL(7,0) NOT NULL,
  school_name VARCHAR(20) NOT NULL,
  CONSTRAINT volunteer_liason_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT volunteer_liason_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name),
  CONSTRAINT volunteer_liason_pk PRIMARY KEY (member_id, school_name)
);

-- Tracks appointed member to be a school liason
-- NOTE: From ER diagram, this relationship has all partial participation
-- so we need to invest in a separate a
create table liason(
  member_id   DECIMAL(7,0) NOT NULL,
  school_name VARCHAR(20) NOT NULL,
  CONSTRAINT liason_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT liason_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name),
  CONSTRAINT liason_pk PRIMARY KEY (member_id),
  CONSTRAINT school_name_unique UNIQUE(school_name) -- NOTE: constraint is to limit multiple associations
);
  
create table parent(
  member_id DECIMAL(7,0) NOT NULL, -- parent id references foregin key of memeber
  CONSTRAINT parent_pk PRIMARY KEY (member_id),
  CONSTRAINT parent_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
    INITIALLY DEFERRED DEFERRABLE
);


create table member_child(
  member_id      DECIMAL(7,0) NOT NULL, 
  child_fname    VARCHAR(20) NOT NULL,
  child_lname    VARCHAR(20) NOT NULL,
  school_name    VARCHAR(20) NOT NULL,
  date_of_record DATE NOT NULL, -- NOTE: When this info was learned and put inside database
  CONSTRAINT member_child_pk PRIMARY KEY(child_fname, child_lname, member_id),
  CONSTRAINT member_child_member_fk FOREIGN KEY (member_id) REFERENCES parent(member_id)
    INITIALLY DEFERRED DEFERRABLE,
  CONSTRAINT member_child_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name)
    INITIALLY DEFERRED DEFERRABLE
);


/**
* Educator Relation
*
* == NOTES AND REASONING FOR THIS RELATIONAL SCHEMA == 
* I feel like collapsing the teacher and admin subclasses into
* single relation needs some further justification, since
* there are a other ways we could represent these entities.
*
* The main reason is decided to collapse the subclassing entities
* was to improve queries involving all educator, avoiding many joins
* on tables with few attributes.
*/
create table educator(
  member_id   DECIMAL(7,0) NOT NULL, -- parent id references foregin key of memeber
  is_teacher  CHAR(1) NOT NULL CHECK (is_teacher in ('y', 'n')), -- NOTE: collasping educator subclasses via boolean flags
  is_admin    CHAR(1) NOT NULL CHECK (is_admin in ('y', 'n')),
  school_name VARCHAR(20) NOT NULL,
  -- NOTE: Field is for educators that either teach or taught math or science, look at constraints to see how I enforce this
  teach_sci_or_math VARCHAR(20) NOT NULL CHECK (teach_sci_or_math in ('science', 'math', 'both', 'none')),
  CONSTRAINT educator_pk PRIMARY KEY (member_id),
  CONSTRAINT educator_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT educator_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name),
  CONSTRAINT admin_teaher_disjoint_and_total_coverage CHECK ((is_teacher = 'n' AND is_admin = 'y')
    OR (is_teacher = 'y' AND is_admin = 'n')), -- NOTE: each educator instance must either be admin or teacher, cannot overlap and cannot be a different instance
  -- NOTE: administrators do not teach subjects, must be none
  CONSTRAINT admin_does_not_teach CHECK 
  ((is_admin = 'y' AND teach_sci_or_math = 'none') 
    OR is_teacher = 'y')
);


-- TODO: Create integrity constraint that says only one role can be occupied at a time
create table board_member(
  member_id DECIMAL(7,0) NOT NULL, -- parent id references foregin key of memeber
  role      VARCHAR(13) CHECK (role in ('president', 'secretary', 'treasurer', 'data manager')),
  CONSTRAINT board_mem_pk PRIMARY KEY (member_id),
  CONSTRAINT board_mem_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
);

create table meeting(
  meet_location VARCHAR(20) NOT NULL,
  meet_date     VARCHAR(20) NOT NULL,
  member_id     DECIMAL(7,0) NOT NULL,
  CONSTRAINT meeting_pk PRIMARY KEY (meet_location, meet_date),
  CONSTRAINT meeting_board_mem_fk FOREIGN KEY (member_id) REFERENCES board_member(member_id)
);

create table non_member(
  fname          VARCHAR(20) NOT NULL, -- NOTE: Maybe I should prefix this to avoid unwanted natural joins
  lname          VARCHAR(20) NOT NULL,
  email          VARCHAR(20) NOT NULL,
  zip            DECIMAL(5,0) NOT NULL, -- NOTE: VARCHAR might also be acceptable, but decimal is easier for comparison
  street         VARCHAR(20) NOT NULL,
  city           VARCHAR(20) NOT NULL,  
  date_of_record DATE NOT NULL, -- NOTE: When we first learned this info
  CONSTRAINT non_member_pk PRIMARY KEY (fname, lname, email)
);


create table non_member_works_for(
  fname          VARCHAR(20) NOT NULL, -- NOTE: Maybe I should prefix this to avoid unwanted natural joins
  lname          VARCHAR(20) NOT NULL,
  email          VARCHAR(20) NOT NULL,
  school_name    VARCHAR(20) NOT NULL,
  teach_sci_or_math VARCHAR(20) NOT NULL CHECK (teach_sci_or_math in ('science', 'math', 'both', 'none')),
  CONSTRAINT non_member_works_for_pk PRIMARY KEY (fname, lname, email),
  CONSTRAINT non_member_works_non_men FOREIGN KEY (school_name) REFERENCES school(school_name),
  CONSTRAINT non_member_works_non_mem FOREIGN KEY (fname, lname, email)
    REFERENCES non_member(fname, lname, email)
);

create table non_member_child(
  non_mem_fname VARCHAR(20) NOT NULL,
  non_mem_lname VARCHAR(20) NOT NULL,
  non_mem_email VARCHAR(20) NOT NULL,
  child_fname   VARCHAR(20) NOT NULL,
  child_lname   VARCHAR(20) NOT NULL,
  school_name   VARCHAR(20) NOT NULL,
  CONSTRAINT non_member_child_school_fk FOREIGN KEY (school_name)
    REFERENCES school(school_name),
  CONSTRAINT non_member_non_member_child_fk FOREIGN KEY (non_mem_fname,
    non_mem_lname, non_mem_email) REFERENCES non_member(fname, lname, email)
);

create table visitor(
  fname         VARCHAR(20) NOT NULL, -- NOTE: maybe I should prefix this to avoid unwanted natural joins
  lname         VARCHAR(20) NOT NULL,
  email         VARCHAR(20) NOT NULL,
  meet_location VARCHAR(20) NOT NULL,
  meet_date     VARCHAR(20) NOT NULL,
  member_id     DECIMAL(7,0) NOT NULL,
  CONSTRAINT visitor_non_mem_fk FOREIGN KEY (fname, lname, email) 
    REFERENCES non_member(fname, lname, email),
  CONSTRAINT visitor_meeting_fk FOREIGN KEY (meet_location, meet_date) 
    REFERENCES meeting(meet_location, meet_date),
   -- NOTE: This is a very big and complex primary key
  CONSTRAINT visitor_pk PRIMARY KEY (fname, lname, email, meet_date, meet_location)
  -- TODO: This relation needs two inclusion dependencies, likely deferrable until commit
);

-- STEP 2: Hoist triggers

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

-- STEP 3: Populate database
SET AUTOCOMMIT OFF;


/* INSERT 1: Create a school */
INSERT INTO school
VALUES('abott middle', 'george', 'foreman','n', 'y');

INSERT INTO school
VALUES('abott high', 'joerge', 'beforeman', 'y', 'n');


/* INSERT 2: Member that is only a parent */
INSERT INTO member
VALUES(id_seq.NEXTVAL, 'daniel', 'plainview', 'dplain@gmail.com', 87801, 
  '1 leroy dr.', 'socorro', TO_DATE('2026-05-11', 'YYYY-MM-DD'), 
  TO_DATE('2023-05-11', 'YYYY-MM-DD'), SYSDATE, 'good');

-- Add to parent relation
INSERT INTO parent
VALUES(id_seq.CURRVAL);

-- Add child in member_child relation
INSERT INTO member_child
VALUES(id_seq.CURRVAL, 'h.w.', 'plainview',
  'abott middle', TO_DATE('2022-08-17', 'YYYY-MM-DD'));

/* INSERT 3: Another member that is only a parent */

INSERT INTO member
VALUES(id_seq.NEXTVAL, 'royal', 'tennenbaum', 'royalt@gmail.com', 87801, 
  '1 leroy dr.', 'socorro', TO_DATE('2026-04-01', 'YYYY-MM-DD'), 
  TO_DATE('2023-04-01', 'YYYY-MM-DD'), SYSDATE, 'good');

-- Add to parent relation
INSERT INTO parent
VALUES(id_seq.CURRVAL);

-- Add child in member_child relation
INSERT INTO member_child
VALUES(id_seq.CURRVAL, 'richie', 'tennenbaum', 'abott middle', SYSDATE);

/* INSERT 4: Member that is only an educator */

INSERT INTO member
VALUES(id_seq.NEXTVAL, 'gary', 'garyson', 'ggary@gary.com', 87801, '2 leroy dr.', 'socorro', 
 TO_DATE('2026-05-26', 'YYYY-MM-DD'), TO_DATE('2016-05-26', 'YYYY-MM-DD'),
 SYSDATE, 'good');

-- Insert educator portion, this time it's a school admin
INSERT INTO educator
VALUES(id_seq.CURRVAL, 'n', 'y', 'abott high', 'none');

/* INSERT 5: Member that is both a parent and an educator */
INSERT INTO member
VALUES(id_seq.NEXTVAL, 'john', 'johnson', 'jjohn@john.com', 87801, '3 leroy dr.', 'socorro', 
 TO_DATE('2026-11-11', 'YYYY-MM-DD'), TO_DATE('2016-11-11', 'YYYY-MM-DD'),
 SYSDATE, 'good');

-- Create parent info
INSERT INTO member_child
VALUES(id_seq.CURRVAL, 'john jr.', 'johnson', 'abott middle', SYSDATE);

-- Create parent info
INSERT INTO parent
VALUES(id_seq.CURRVAL);

-- Create educator info
INSERT INTO educator
VALUES(id_seq.CURRVAL, 'y', 'n', 'abott high', 'science');

/* INSERT 6: Member that is both a parent and an educator */

INSERT INTO member
VALUES(id_seq.NEXTVAL, 'cole', 'coleson', 'cole@c.com', 87801, '4 leroy dr.', 'socorro', 
 TO_DATE('2027-3-11', 'YYYY-MM-DD'), TO_DATE('2016-3-11', 'YYYY-MM-DD'),
 SYSDATE, 'good');

-- Create parent info
INSERT INTO member_child
VALUES(id_seq.CURRVAL, 'cole jr.', 'coleson', 'abott high', SYSDATE);

INSERT INTO member_child
VALUES(id_seq.CURRVAL, 'cole jr. II', 'coleson', 'abott high', SYSDATE);

-- Create parent info
INSERT INTO parent
VALUES(id_seq.CURRVAL);

-- Create educator info
INSERT INTO educator
VALUES(id_seq.CURRVAL, 'y', 'n', 'abott high', 'science');

/*INSERT 7: Create some board members */

INSERT INTO member
VALUES(id_seq.NEXTVAL, 'elizabeth', 'holmes', 'eholmes@theranos.com', 
  87801, '5 leroy dr.', 'socorro',
  TO_DATE('2026-05-05', 'YYYY-MM-DD'), TO_DATE('2022-05-05', 'YYYY-MM-DD'),
  SYSDATE, 'good');

INSERT INTO board_member
VALUES(id_seq.CURRVAL, 'president'); 

INSERT INTO educator
VALUES(id_seq.CURRVAL,'y', 'n', 'abott high', 'math');


/* INSERT 8: Create meeting organized by president holmes */
INSERT INTO meeting
VALUES('fire and ice coffee', TO_DATE('2026-05-03', 'YYYY-MM-DD'),
  id_seq.CURRVAL);

/* INSERT 9: Create non-member with the same name and email addr as member */
INSERT INTO non_member
VALUES('elizabeth', 'holmes', 'eholmes@theranos.com', 
  87801, '5 leroy dr.', 'socorro', SYSDATE);

-- IDK fake elizabeth holmes attends the meeting
INSERT INTO visitor
VALUES('elizabeth', 'holmes', 'eholmes@theranos.com',
  'fire and ice coffee', TO_DATE('2026-05-03', 'YYYY-MM-DD'),
  id_seq.CURRVAL);

/* INSERT 9: Create a member with the same name and addr as another */

INSERT INTO member
VALUES(id_seq.NEXTVAL, 'cole', 'coleson', 'cole@c.com', 87801, '5 leroy dr.', 'socorro', 
 TO_DATE('2027-3-11', 'YYYY-MM-DD'), TO_DATE('2016-3-11', 'YYYY-MM-DD'),
 SYSDATE, 'good');

INSERT INTO educator
VALUES(id_seq.CURRVAL,'n', 'y', 'abott high', 'none');

-- FAKE INSERTS: TEST OUT TRIGGER, THESE SHOULD NOT INSERT
-- (TESTED ON MARCH 2, 2025 -- PASSED)
INSERT INTO member
VALUES(id_seq.NEXTVAL, 'elliot', 'holmes', 'eholmes@theranos.com', 
  87801, '5 leroy dr.', 'socorro',
  TO_DATE('2026-05-05', 'YYYY-MM-DD'), TO_DATE('2022-05-05', 'YYYY-MM-DD'),
  SYSDATE, 'poor');

INSERT INTO board_member
VALUES(id_seq.CURRVAL, 'secretary'); 

INSERT INTO educator
VALUES(id_seq.CURRVAL,'y', 'n', 'abott high', 'math');

INSERT INTO member
VALUES(id_seq.NEXTVAL, 'elija', 'holmes', 'eholmes@theranos.com', 
  87801, '5 leroy dr.', 'socorro',
  TO_DATE('2026-05-05', 'YYYY-MM-DD'), TO_DATE('2022-05-05', 'YYYY-MM-DD'),
  SYSDATE, 'good');

INSERT INTO board_member
VALUES(id_seq.CURRVAL, 'president'); 

INSERT INTO educator
VALUES(id_seq.CURRVAL,'y', 'n', 'abott high', 'math');

/* INSERT 8: non member for is a teacher */
INSERT INTO non_member
VALUES('joe', 'joeson', 'jjoe@gmail.com', 87801, '3 leroy dr.',
  'socorro', SYSDATE);

INSERT INTO non_member_works_for
VALUES('joe', 'joeson', 'jjoe@gmail.com', 'abott high', 'math');

INSERT INTO meeting
VALUES('que suava cafe', TO_DATE('2026-05-03', 'YYYY-MM-DD'),
  9000006);

INSERT INTO visitor
VALUES('joe', 'joeson', 'jjoe@gmail.com','fire and ice coffee', TO_DATE('2026-05-03', 'YYYY-MM-DD'),
  9000006)

/* INSERT 9: Non member becomes a member, test out trigger */

INSERT INTO member
VALUES(id_seq.NEXTVAL, 'joe', 'joeson', 'jjoe@gmail.com', 87801, '3 leroy dr.',
  'socorro', TO_DATE('2026-08-16', 'YYYY-MM-DD'), TO_DATE('2025-08-16', 'YYYY-MM-DD'),
SYSDATE, 'good');

-- FINALLY commit to populate transaction
commit;

-- STEP 4: Display populated tables
SELECT * FROM member;
SELECT * FROM parent;
SELECT * FROM educator;
SELECT * FROM board_member;
SELECT * FROM member_child;
SELECT * FROM school;

SELECT * FROM non_member;
SELECT * FROM non_member_child;
SELECT * FROM volunteer_liason;
SELECT * FROM liason;
SELECT * FROM visitor;
SELECT * FROM meeting;
SELECT * FROM non_member_works_for;


-- STEP 4: Execute queries
/**
* QUERY 1: Display the following group name and number of members:
* (i) parent but not educator, (ii) educator but not parent,
* and (iii) both a parent and an educator
**/

SELECT COUNT(*) AS "Parent But Not Educator Count" from (
  SELECT member_id from parent
  MINUS -- set difference
  SELECT member_id from educator
);

SELECT COUNT(*) AS "Educator But Not Parent Count" from (
  SELECT member_id from educator
  MINUS -- set difference
  SELECT member_id from parent
);

SELECT COUNT(*) AS "Both Parent and Eduator Count" from (
  SELECT member_id from member
  INTERSECT
  SELECT member_id from parent
  INTERSECT
  SELECT member_id from educator
);

/**
* QUERY 2: Display the ID, first and last names, and membership
* expiration dates, of all the members whose member is going to expire within
* a month followed by those whose membershiop has 
**/

SELECT * FROM (
  SELECT member_id, fname, lname, 
    TRUNC(member_expr) - TRUNC(SYSDATE) as days, 'MONTH TO EXPIRY'
  FROM member
  )
WHERE days > 0 and days < 30;

SELECT * FROM (
  SELECT member_id, fname, lname, 
    TRUNC(member_expr) - TRUNC(SYSDATE) as days, 'EXPIRED'
  FROM member
  )
WHERE days < 0;

/**
* QUERY 3: list the ID, first, and last names of members who are (current or former) 
* teachers of science / math as well as parent and teach at a school
* attended by one or more of their children. (If a teacher has only one
* child, then that child must attend; if a teacher has two children, then both must attend.)
**/

-- NOTE: This is messy maybe rewrite with natural join?
SELECT m.member_id, fname, lname, e.teach_sci_or_math
FROM educator e, member m
WHERE e.school_name = all
  (SELECT mc.school_name
   FROM member_child mc
   WHERE mc.member_id = e.member_id
  )
AND (e.teach_sci_or_math != 'none') -- Must teach at least one
AND (e.member_id = m.member_id);

/**
* QUERY 4: if either two members have the same first name, last name, and email
* address, or a non-member and a member share those three items, then
* print those three items for each pair; add a string BOTH MEMBERS
* in the first case and ONE NON-MEMBER in the other. The items for
* BOTH-MEMBERS should appear first ordered by first name followed
* by the rest ordered similarly.
**/

SELECT fname, lname, email, 'ONE MEMBER'
FROM member m
WHERE EXISTS
  (SELECT *
  FROM non_member nm
  WHERE nm.fname = m.fname
  AND nm.lname = m.lname
  AND nm.email = m.email
  )
UNION ALL
SELECT fname, lname, email, 'BOTH MEMBER'
FROM member m1
WHERE EXISTS
  (SELECT *
  FROM member m2
  WHERE m1.fname = m2.fname
  AND m1.lname = m2.lname
  AND m1.email = m2.email
  AND m1.member_id != m2.member_id
  );

-- STEP 5: Load in procedures
-- NOTE: This is so I can so dbms output commands
-- that can be displayed in the interactive session
SET SERVEROUTPUT ON;

/**
* PROCEDURE 1: find_id_name(last): display the ID, first and last name of all members 
* (regardless of their membership standing) whose last name contains 
* last (the parameter!) as a substring. Print a message if there is
* no such member.
**/

CREATE OR REPLACE PROCEDURE find_id_name
  (last IN member.lname%type)
IS
  CURSOR mem_cursor IS SELECT member_id, fname, lname FROM member;
  mem_id member.member_id%type;
  mem_fname member.fname%type;
  mem_lname member.lname%type;
BEGIN
  OPEN mem_cursor;
  LOOP
    FETCH mem_cursor into mem_id, mem_fname, mem_lname;
      -- INSTR returns position of substring using 1-indexing, so any match is > 0
      IF INSTR(mem_lname, last) > 0 THEN
  dbms_output.put_line('Member found: ' || mem_id || ',' || mem_fname || ',' || mem_lname);
    END IF;
    EXIT WHEN mem_cursor%NOTFOUND;
  END LOOP;
  CLOSE mem_cursor;
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
  -- CHECK to see the membership is expired (should be non zero val)
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
  -- Use expiry and status flag to check expiry and existence of entry
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
    -- use cursor to fetch entries
    FETCH child_cursor into child_mem_id, dor;
    IF TRUNC(MONTHS_BETWEEN(SYSDATE, dor)/12) >= 4 
      AND child_mem_id = mem_id THEN
      -- If child should have graduated, trip boolean flags
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
  -- NOTE: Hacky way to ignore duplicates
  WHEN too_many_rows THEN
    dbms_output.put_line('Flag member for child grad: ' || mem_id || ', ' || first_name|| ', ' || last_name);
END;

/
show errors
execute flag_graduated_children
SET SERVEROUTPUT OFF;

-- FINAL STEP: cleanup 
drop sequence id_seq -- drop automatic ID sequence
;

drop table member cascade constraints -- drop MEMBER
;

drop table school cascade constraints -- drop SCHOOL
;
 
drop table parent cascade constraints -- drop PARENT
;

drop table board_member cascade constraints -- drop BOARD MEMBER
;

drop table member_child cascade constraints -- drop MEMBER CHILD
;

drop table educator cascade constraints -- drop EDUCATOR
;

drop table volunteer_liason cascade constraints -- drop VOLUNTEER LIASON
;

drop table liason -- drop LIASON
;

drop table visitor -- drop VISITOR
;

drop table non_member cascade constraints -- drop NON MEMBER
;

drop table non_member_works_for cascade constraints -- drop NON MEMBER WORKS FOR
;

drop table non_member_child cascade constraints -- drop NON MEMBER CHILD
;

drop table meeting cascade constraints -- drop MEMBER
;

SPOOL OFF
set echo OFF
