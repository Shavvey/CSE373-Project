/**
* CSE373 - Introduction to Databases - Project
* ============================================
* Name: Cole Johnson
* Due Date: 5/2/2026
*
* I certify that this assignment has been
* completed by myself.
**/

-- NOTE: Needed for some insertions due to mutual constraints.
-- Mostly this is needed for inclusion dependency which
-- often create mutual constraints on some relations.
SET AUTOCOMMIT OFF;


/* INSERT 1: Create a school */
INSERT INTO school
VALUES('abott middle', 'george', 'foreman','n', 'y');

INSERT INTO school
VALUES('abott high', 'joerge', 'beforeman', 'y', 'n');


/* INSERT 2: Member that is only a parent */
INSERT INTO member
VALUES(900001, 'daniel', 'plainview', 'dplain@gmail.com', 87801, 
  '1 leroy dr.', 'socorro', TO_DATE('2026-05-11', 'YYYY-MM-DD'), 
  TO_DATE('2023-05-11', 'YYYY-MM-DD'), SYSDATE, 'good');

-- Add to parent relation
INSERT INTO parent
VALUES(900001);

-- Add child in member_child relation
INSERT INTO member_child
VALUES(900001, 'h.w.', 'plainview', 'abott middle', SYSDATE);

/* INSERT 3: Another member that is only a parent */

INSERT INTO member
VALUES(900002, 'royal', 'tennenbaum', 'royalt@gmail.com', 87801, 
  '1 leroy dr.', 'socorro', TO_DATE('2026-04-01', 'YYYY-MM-DD'), 
  TO_DATE('2023-04-01', 'YYYY-MM-DD'), SYSDATE, 'poor');

-- Add to parent relation
INSERT INTO parent
VALUES(900002);

-- Add child in member_child relation
INSERT INTO member_child
VALUES(900002, 'richie', 'tennenbaum', 'abott middle', SYSDATE);

/* INSERT 4: Member that is only an educator */

INSERT INTO member
VALUES(900003, 'gary', 'garyson', 'ggary@gary.com', 87801, '2 leroy dr.', 'socorro', 
 TO_DATE('2026-05-26', 'YYYY-MM-DD'), TO_DATE('2016-05-26', 'YYYY-MM-DD'),
 SYSDATE, 'good');

-- Insert educator portion, this time it's a school admin
INSERT INTO educator
VALUES(900003, 'n', 'y', 'abott high', 'none');

/* INSERT 5: Member that is both a parent and an educator */
INSERT INTO member
VALUES(900004, 'john', 'johnson', 'jjohn@john.com', 87801, '3 leroy dr.', 'socorro', 
 TO_DATE('2026-11-11', 'YYYY-MM-DD'), TO_DATE('2016-11-11', 'YYYY-MM-DD'),
 SYSDATE, 'good');

-- Create parent info
INSERT INTO member_child
VALUES(900004, 'john jr.', 'johnson', 'abott middle', SYSDATE);

-- Create parent info
INSERT INTO parent
VALUES(900004);

-- Create educator info
INSERT INTO educator
VALUES(900004, 'y', 'n', 'abott high', 'science');

/* INSERT 6: Member that is both a parent and an educator */

INSERT INTO member
VALUES(900005, 'cole', 'coleson', 'cole@c.com', 87801, '4 leroy dr.', 'socorro', 
 TO_DATE('2027-3-11', 'YYYY-MM-DD'), TO_DATE('2016-3-11', 'YYYY-MM-DD'),
 SYSDATE, 'good');

-- Create parent info
INSERT INTO member_child
VALUES(900005, 'cole jr.', 'coleson', 'abott high', SYSDATE);

INSERT INTO member_child
VALUES(900005, 'cole jr. II', 'coleson', 'abott high', SYSDATE);

-- Create parent info
INSERT INTO parent
VALUES(900005);

-- Create educator info
INSERT INTO educator
VALUES(900005, 'y', 'n', 'abott high', 'science');

/*INSERT 7: Create some board members */

INSERT INTO member
VALUES(900006, 'elizabeth', 'holmes', 'eholmes@theranos.com', 
  87801, '5 leroy dr.', 'socorro',
  TO_DATE('2026-05-05', 'YYYY-MM-DD'), TO_DATE('2022-05-05', 'YYYY-MM-DD'),
  SYSDATE, 'good');

INSERT INTO board_member
VALUES(900006, 'president'); 

INSERT INTO educator
VALUES(900006,'y', 'n', 'abott high', 'math');

/* INSERT 8: Create meeting organized by president holmes */
INSERT INTO meeting
VALUES('fire and ice coffee', TO_DATE('2026-05-03', 'YYYY-MM-DD'),
  900006);

/* INSERT 9: Create non-member with the same name and email addr as member */
INSERT INTO non_member
VALUES('elizabeth', 'holmes', 'eholmes@theranos.com', 
  87801, '5 leroy dr.', 'socorro', SYSDATE);

-- IDK fake elizabeth holmes attends the meeting
INSERT INTO visitor
VALUES('elizabeth', 'holmes', 'eholmes@theranos.com',
  'fire and ice coffee', TO_DATE('2026-05-03', 'YYYY-MM-DD'),
  900006);

/* INSERT 9: Create a member with the same name and addr as another */

INSERT INTO member
VALUES(900007, 'cole', 'coleson', 'cole@c.com', 87801, '5 leroy dr.', 'socorro', 
 TO_DATE('2027-3-11', 'YYYY-MM-DD'), TO_DATE('2016-3-11', 'YYYY-MM-DD'),
 SYSDATE, 'good');

INSERT INTO educator
VALUES(900007,'n', 'y', 'abott high', 'none');

-- FINALLY commit to populate transaction
commit;

