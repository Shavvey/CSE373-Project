/**
* CSE373 - Introduction to Databases - Project
* ============================================
* Name: Cole Johnson
* Due Date: 5/2/2026
*
* I certify that this assignment has been
* completed by myself.
**/

-- INSERT 1: Create a school
INSERT INTO school
VALUES('Abott Middle', 'George', 'Foreman', 'Y', 'N');

-- INSERT 2: Member that is only a parent
INSERT INTO member
VALUES(111, 'Daniel', 'Plainview', 87801, 
  '1 Leroy Dr.', 'Socorro', TO_DATE('2026-06-11', 'YYYY-MM-DD'));

-- Add to parent relation
INSERT INTO parent
VALUES(111);

-- Add child in member_child relation
INSERT INTO member_child
VALUES(111, 'H.W.', 'Plainview', 'Abott Middle', SYSDATE);
