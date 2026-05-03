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

