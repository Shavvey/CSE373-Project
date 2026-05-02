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

SELECT COUNT(*) AS "Parent But Not Parent Count" from (
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
SELECT member_id, member_expr, SYSDATE, member_expr - SYSDATE
FROM member;

SELECT member_id, fname, lname, 'MONTH TO EXPIRY'
FROM member
WHERE member_expr - SYSDATE <= 28; -- NOTE: expr within a month
