/**
* CSE373 - Introduction to Databases
* =======================================
* I certify that this assignment has been
* completed by myself.
**/

-- set up spooling
set echo ON
set spool cj_johnson

-- FIX: You need subclassing relations here (parents, educators, at least...)
create table member(
  member_id DECIMAL(4,0) NOT NULL,
  zip DECIMAL(5,0) NOT NULL,
  street VARCHAR2(100) NOT NULL,
  city VARCHAR2(100) NOT NULL,  
  fname VARCHAR2(100) NOT NULL,
  lname VARCHAR2(100) NOT NULL,
  member_expr DATE, -- NOTE: When the member's expiration date is
  CONSTRAINT member_pk PRIMARY KEY (member_id) -- primary key constraint
);

create table parent(
  member_id DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  CONSTRAINT parent_pk PRIMARY KEY (member_id),
  CONSTRAINT parent_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
);

create table educator(
  member_id DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  CONSTRAINT parent_pk PRIMARY KEY (member_id),
  CONSTRAINT parent_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
);

create table board_member(
  member_id DECIMAL(4,0) NOT NULL, -- parent id references foregin key of memeber
  role VARCHAR2(13) CHECK (role in ('PRESIDENT', 'SECRETARY', 'TREASURER' 'DATA MANAGER')),
  CONSTRAINT board_mem_pk PRIMARY KEY (member_id),
  CONSTRAINT board_mem_fk FOREIGN KEY (member_id) REFERENCES member(member_id)
);


create table school(
  name VARCHAR(100) NOT NULL,
  principle VARCHAR(100) NOT NULL,
  is_middleschool CHAR(1) CHECK (is_middleschool in ('Y', 'N')),
  is_highschool CHAR(1) CHECK (is_highschool in ('Y', 'N')),
  CONSTRAINT school_pk PRIMARY KEY (name) -- school name is unique
);


