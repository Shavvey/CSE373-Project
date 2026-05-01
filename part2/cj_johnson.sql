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
-- NOTE: From ER diagram, this relationship has all partial participation
-- so we need to invest in a separate a
create table liason(
  member_id   DECIMAL(4,0) NOT NULL,
  school_name VARCHAR(100) NOT NULL,
  CONSTRAINT liason_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT liason_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name),
  CONSTRAINT liason_pk PRIMARY KEY (member_id),
  CONSTRAINT school_name_unique UNIQUE(school_name) -- NOTE: constraint is to limit multiple associations
);
  
create table parent(
  member_id DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  CONSTRAINT parent_pk PRIMARY KEY (member_id),
  CONSTRAINT parent_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
);

create table member_child(
  member_id      DECIMAL(4,0) NOT NULL, 
  child_fname    VARCHAR(100) NOT NULL,
  child_lname    VARCHAR(100) NOT NULL,
  school_name    VARCHAR(100) NOT NULL,
  date_of_record DATE NOT NULL, -- NOTE: When this info was learned and put inside database
  CONSTRAINT member_child_pk PRIMARY KEY(child_fname, child_lname, member_id),
  CONSTRAINT member_child_member_fk FOREIGN KEY (member_id) REFERENCES parent(member_id),
  CONSTRAINT member_child_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name)
);

/**
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
  member_id   DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  is_teacher  CHAR(1) NOT NULL CHECK (is_teacher in ('Y', 'N')), -- NOTE: collasping educator subclasses via boolean flags
  is_admin    CHAR(1) NOT NULL CHECK (is_admin in ('Y', 'N')),
  school_name VARCHAR(100) NOT NULL,
  teach_sci_or_math VARCHAR(100) NOT NULL CHECK (subject in ('SCIENCE', 'MATH', 'BOTH', 'NONE')),
  CONSTRAINT educator_pk PRIMARY KEY (member_id),
  CONSTRAINT educator_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT educator_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name),
  CONSTRAINT admin_teaher_disjoint_and_total_coverage CHECK ((is_teacher = 'N' AND is_admin = 'Y') 
    OR (is_teacher = 'Y' AND is_admin = 'N')), -- NOTE: each educator instance must either be admin or teacher, cannot overlap and cannot be a different instance
  CONSTRAINT admin_does_not_teach CHECK(is_admin = 'Y' AND subject = 'NONE')) -- NOTE: administrators do not teach subjects, must be none
);


-- TODO: Create integrity constraint that says only one role can be occupied at a time
create table board_member(
  member_id DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  role      VARCHAR(13) CHECK (role in ('PRESIDENT', 'SECRETARY', 'TREASURER', 'DATA MANAGER')),
  CONSTRAINT board_mem_pk PRIMARY KEY (member_id),
  CONSTRAINT board_mem_member_fk FOREIGN KEY (member_id) REFERENCES member(member_id),
  CONSTRAINT board_mem_role_unique UNIQUE(role) -- NOTE: ensures there is only one board member assigned to a role
);

create table meeting(
  meet_location VARCHAR(100) NOT NULL,
  meet_date     VARCHAR(100) NOT NULL,
  member_id     DECIMAL(4,0) NOT NULL,
  CONSTRAINT meeting_pk PRIMARY KEY (meet_location, meet_date),
  CONSTRAINT meeting_board_mem_fk FOREIGN KEY (member_id) REFERENCES board_member(member_id)
);

create table non_member(
  fname   VARCHAR(100) NOT NULL, -- NOTE: Maybe I should prefix this to avoid unwanted natural joins
  lname  VARCHAR(100) NOT NULL,
  email  VARCHAR(100) NOT NULL,
  zip    DECIMAL(5,0) NOT NULL, -- NOTE: VARCHAR might also be acceptable, but decimal is easier for comparison
  date_of_record DATE NOT NULL, -- NOTE: When we first learned this info
  street VARCHAR(100) NOT NULL,
  city   VARCHAR(100) NOT NULL,  
  CONSTRAINT non_member_pk PRIMARY KEY (fname, lname, email)
);

create talbe non_member_child(
  child_fname VARCHAR(100) NOT NULL,
  child_lname VARCHAR(100) NOT NULL,
  school_name VARCHAR(100) NOT NULL,
  CONSTRAINT non_member_child_school_fk FOREIGN KEY (school_name)
    REFERENCES school(school_name)
);

create table visitor(
  fname         VARCHAR(100) NOT NULL, -- NOTE: maybe I should prefix this to avoid unwanted natural joins
  lname         VARCHAR(100) NOT NULL,
  email         VARCHAR(100) NOT NULL,
  meet_location VARCHAR(100) NOT NULL,
  meet_date     VARCHAR(100) NOT NULL,
  member_id     DECIMAL(4,0) NOT NULL,
  CONSTRAINT visitor_non_mem_fk FOREIGN KEY (fname, lname, email) 
    REFERENCES non_member(fname, lname, email),
  CONSTRAINT visitor_meeting_fk FOREIGN KEY (meet_location, meet_date) 
    REFERENCES meeting(meet_location, meet_date),
   -- NOTE: This is a very big and complex primary key
  CONSTRAINT visitor_pk PRIMARY KEY (fname, lname, email, meet_date, meet_location)
  -- TODO: This relation needs two inclusion dependencies, likely deferrable until commit
);

