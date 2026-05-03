/**
* CSE373 - Introduction to Databases - Project
* ============================================
* Name: Cole Johnson
* Due Date: 5/2/2026
*
* I certify that this assignment has been
* completed by myself.
**/

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

create table non_member_child(
  nm_fname          VARCHAR(20) NOT NULL, -- NOTE: Maybe I should prefix this to avoid unwanted natural joins
  nm_lname          VARCHAR(20) NOT NULL,
  nm_email          VARCHAR(20) NOT NULL,
  child_fname    VARCHAR(20) NOT NULL,
  child_lname    VARCHAR(20) NOT NULL,
  school_name    VARCHAR(20) NOT NULL,
  date_of_record DATE NOT NULL, -- NOTE: When this info was learned and put inside database
  CONSTRAINT non_member_child_pk PRIMARY KEY(child_fname, child_lname, nm_fname, nm_lname, nm_email),
  CONSTRAINT non_member_child_member_fk FOREIGN KEY (nm_fname, nm_lname, nm_email) 
  REFERENCES non_member(fname, lname, email)
    INITIALLY DEFERRED DEFERRABLE,
  CONSTRAINT non_member_child_school_fk FOREIGN KEY (school_name) REFERENCES school(school_name)
    INITIALLY DEFERRED DEFERRABLE
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
