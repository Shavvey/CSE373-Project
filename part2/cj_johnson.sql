/**
* CSE373 - Introduction to Databases - Project
* ============================================
* Name: Cole Johnson
* Due Date: 5/2/2026
*
* I certify that this assignment has been
* completed by myself.
**/

-- set up spooling
set echo ON
set spool cj_johnson

-- FIX: You need subclassing relations here (parents, educators, at least...)
create table member(
  member_id    DECIMAL(4,0) NOT NULL, -- 4 digits, no digits after the decimal place
  zip          DECIMAL(5,0) NOT NULL, -- NOTE: VARCHAR might also be acceptable
  street       VARCHAR(100) NOT NULL,
  city         VARCHAR(100) NOT NULL,  
  fname        VARCHAR(100) NOT NULL,
  lname        VARCHAR(100) NOT NULL,
  email        VARCHAR(100) NOT NULL,
  member_expr  DATE, -- NOTE: When the member's expiration date is
  CONSTRAINT member_pk PRIMARY KEY (member_id) -- primary key constraint
  -- NOTE: last name and first can also be used for identification, put ID is preferred and designated as key
);

create table school(
  school_name      VARCHAR(100) NOT NULL,
  principle_lname  VARCHAR(100) NOT NULL,
  principle_fname  VARCHAR(100) NOT NULL,
  is_middleschool  CHAR(1) NOT NULL CHECK (is_middleschool in ('Y', 'N')), 
  is_highschool    CHAR(1) NOT NULL CHECK (is_highschool in ('Y', 'N')),
  CONSTRAINT school_pk PRIMARY KEY (school_name) -- school name is unique
);

-- Tracks volunteered members to be a school liason
create table volunteer_liason(
  member_id   DECIMAL(4,0) NOT NULL,
  school_name VARCHAR(100) NOT NULL,
  CONSTRAINT volunteer_liason_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT volunteer_liason_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name),
  CONSTRAINT volunteer_liason_pk PRIMARY KEY (member_id, school_name)
);

-- Tracks appointed member to be a school liason
create table liason(
  member_id   DECIMAL(4,0) NOT NULL,
  school_name VARCHAR(100) NOT NULL,
  CONSTRAINT liason_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT liason_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name),
  CONSTRAINT liason_pk PRIMARY KEY (member_id, school_name)
);
  
create table parent(
  member_id DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  CONSTRAINT parent_pk PRIMARY KEY (member_id),
  CONSTRAINT parent_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
);

create table member_child(
  member_id      DECIMAL(4,0) NOT NULL, 
  fname          VARCHAR(100) NOT NULL,
  lname          VARCHAR(100) NOT NULL,
  school_name    VARCHAR(100) NOT NULL,
  date_of_record DATE NOT NULL, -- NOTE: When this info was learned and put inside database
  CONSTRAINT member_child_pk PRIMARY KEY(fname, lname, member_id),
  CONSTRAINT member_child_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT member_child_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name)
);

create table educator(
  member_id  DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  is_teacher CHAR(1) NOT NULL CHECK (is_teacher in ('Y', 'N')), -- NOTE: collasping educator subclasses via boolean flags
  is_admin   CHAR(1) NOT NULL CHECK (is_admin in ('Y', 'N')),
  CONSTRAINT educator_pk PRIMARY KEY (member_id),
  CONSTRAINT educator_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
);


-- TODO: Create integrity constraint that says only one role can be occupied at a time
create table board_member(
  member_id DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  role      VARCHAR2(13) CHECK (role in ('PRESIDENT', 'SECRETARY', 'TREASURER', 'DATA MANAGER')),
  CONSTRAINT board_mem_pk PRIMARY KEY (member_id),
  CONSTRAINT board_mem_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
);


