
/*=============================================================================================*/
/* 1)  DATASET MANIPULATION */
/*=============================================================================================*/

data sample_char_num (rename=(gender_code=gender) drop=gender);
 input gender $; 
 if upcase(gender) = 'M' then gender_code=1;/*assign 1 to male*/ 
 if upcase(gender) = 'F' then gender_code=2;/*assign 0 to female*/ 
/*if gender_code = 1;/*to filter male(1) rows*/ 
datalines;
m 
F
M 
F
;
run;

data test;
set sample_char_num;
where gender eq 1;
run;

/*=============================================================================================*/
/* 2)  GETTING CUMMULATIVE SUM */
/*=============================================================================================*/

data have;
input ID  AMT;
cards;

10 150
10 100
25 150
25 150
25 150
30 600
30 300
;
run;
proc print data = have;


data want;
  set have;
  by id notsorted;
  if first.id then sumbyid+0;
    sumbyid+amt;
run;
proc print data = want;

/*=============================================================================================*/
/* 3)  FETCHING ODD AND EVEN ROWS FROM DATASET */
/*=============================================================================================*/

data Iris;
infile "/folders/myfolders/Iris.csv" DSD MISSOVER ;
format SP $15.;
input id    SL     SW     PL     PW    SP$;
if SL > 5 then Encode_SL = "Greater Than 5"; else if SL < 5 then Encode_SL = "Lesser Than 5"; else Encode_SL = "Equal to 5";
if PL > 4 then Encode_PL = "Greater Than 4"; else if PL < 4 then Encode_PL = "Lesser Than 4"; else Encode_PL = "Equal to 4";
IF ID < 1 THEN DELETE;
if SP = "Iris-setosa" then Encode_SP = 0; else if SP = "Iris-versicolor" then Encode_SP = 1; else Encode_SP = 2;
run;
proc print data= Iris;



data classSimple;
set Iris;
obs = _n_;
if mod(_n_,2) eq 0 then output;
run;
proc print data =classSimple;
var Id  SL     SW     PL     PW    SP;


data classSimple;
set Iris;
obs = _n_;
if mod(_n_,2) NE 0 then output;
run;
proc print data =classSimple;
var Id  SL     SW     PL     PW    SP;


/*=============================================================================================*/
/* 4)  REVERSING THE DATASET */
/*=============================================================================================*/


data Iris1 ;
 set Iris ;
 indx = _n_ ;
 proc sort data=Iris1 ;
 by descending indx ;
run ;
proc print data=Iris1;


/*=============================================================================================*/
/*=============================================================================================*/
