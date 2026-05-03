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

SPOOL OFF
set echo OFF
