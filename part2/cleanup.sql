/* NOTE: This script is to quickly cleanup the schema so that the
 script file `cj_johnson.sql` can run again. */

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

drop table volunteer_liason
;

drop table liason
;
