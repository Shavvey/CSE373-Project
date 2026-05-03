/**
* CSE373 - Introduction to Databases - Project
* ============================================
* Name: Cole Johnson
* Due Date: 5/2/2026
*
* I certify that this assignment has been
* completed by myself.
*
* == WHAT DOESN'T WORK =======================
*
* - INCLUSION DEPENDENCIES: There isn't a good
* way to implement these in SQL. I tried using
* update triggers, but it was buggy and enforce
* particular insertion order. So, unfortunately
* I didn't have a good solution for implementing
* them into my schema. 
*
* - TRIGGER 2: I'm not sure why it's not working.
* I think dbms_output.put_line doesn't work in
* interactive sessions or can't be used in triggers.
*
**/

-- set up spooling, if not already enabled
set echo ON
SPOOL cj_johnson

-- STEP 1: Create relational schema
@schema

-- STEP 2: Hoist triggers
@triggers

-- STEP 3: Populate database
@populate

-- STEP 4: Display populated tables
@display

-- STEP 4: Execute queries
@queries

-- STEP 5: Load in procedures
@procedures

-- END: Cleanup by dropping all tables
@cleanup
-- epilog, turn off spool and echo
SPOOL OFF
set echo OFF
