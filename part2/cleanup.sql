/* NOTE: This script is to quickly cleanup the schema so that the
 script file `cj_johnson.sql` can run again. */

-- set up spooling, if not already enabled
set echo ON
set spool cj_johnson

drop table member cascade constraints -- drop MEMBER
;

drop table school cascade constraints -- drop SCHOOL
;
 
drop table parent cascade constraints -- drop PARENT
;

drop table board_member cascade constraints -- drop BOARD MEMBER
;

drop table member_child cascade constraints -- drop MEMBER CHILD
;

drop table educator cascade constraints -- drop EDUCATOR
;

drop table volunteer_liason cascade constraints -- drop VOLUNTEER LIASON
;

drop table liason -- drop LIASON
;

drop table visitor -- drop VISITOR
;

drop table non_member cascade constraints -- drop NON MEMBER
;

drop table non_member_child cascade constraints -- drop NON MEMBER CHILD
;

drop table meeting cascade constraints -- drop MEMBER
;

