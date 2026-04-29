/**
* CSE373 - Introduction to Databases
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
  street VARCHAR(100), -- NOTE: Maybe variable string is not needed here?
  city VARCHAR(100),  
  fname VARCHAR(100),
  lname VARCHAR(100),
  member_expr DATE, -- NOTE: When the member's expiration date is
  is_parent boolean,
  is_educator boolean,
  CONSTRAINT member_pk PRIMARY KEY (member_id) -- primary key constraint
);


create table school(
  name VARCHAR(100),
  principle VARCHAR(100),
  is_highschool boolean,
  is_middleschool boolean,
  CONSTRAINT school_pk PRIMARY KEY (name) -- school name is unique
);


