/**
* CSE373 - Introduction to Databases - Project
* ============================================
* Name: Cole Johnson
* Due Date: 5/2/2026
*
* I certify that this assignment has been
* completed by myself.
**/

-- set up spooling, if not already enabled
set echo ON
SPOOL cj_johnson

-- STEP 1: Create relational schema
@schema

-- STEP 2: Populate database
@populate

-- END: Cleanup by dropping all tables
@cleanup

SPOOL OFF
set echo OFF
