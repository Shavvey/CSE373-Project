/**
* CSE373 - Introduction to Databases - Project
* ============================================
* Name: Cole Johnson
* Due Date: 5/2/2026
*
* I certify that this assignment has been
* completed by myself.
**/

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
