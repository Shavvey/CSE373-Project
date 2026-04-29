/* NOTE: This script is to quickly cleanup the schema so that the
 script file `schema.sql` can run again. */

drop table member cascade constraints -- drop MEMBER
;

drop table school cascade constraints -- drop SCHOOL
;

