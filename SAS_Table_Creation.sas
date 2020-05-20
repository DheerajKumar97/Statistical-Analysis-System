/*======================================================================================================================*/
/* 1)  SIMPLE TABLE */
/*======================================================================================================================*/

data SimpleTable;
input Name$ Age Qualification$  Sex$; 
if Age < 20 then Age = 0; else if Age > 20 then Age = 1; else Age = 2;  
datalines;
Dheeraj    25    BTech   Male  
RajKumar   18    BTech   Male     
Rahul      20    BTech   Male     
Nandhinee  21    BTech   Female 
;
run;

proc print data=SimpleTable;



/*======================================================================================================================*/
/* 2) TABLE with dates format */
/*======================================================================================================================*/

data dheeraj;
input Name$15.  Age   Qualification$    Sex$    BirthDate;
informat BirthDate ddmmyy10.;
format BirthDate ddmmyy10.;
datalines;
Dheeraj         25      BTech     Male         20/12/1997
RajKumar        18      BTech     Male         12/02/1997
Rahul           20      BTech     Male         02/07/1997
Nandhinee       21      BTech     Female       06/04/1997
Bhuvanesh       .       BTech     Male         10/05/1997
;
run;

proc print data=dheeraj;

/*======================================================================================================================*/
/* 3)  CLASS TABLE */
/*======================================================================================================================*/

title Student_DataBase;
data Class;
input Course_Name$15.  Student_Name$15.  Age  Qualification$10.  Sex$  Join_Date   End_Date;
informat Join_Date ddmmyy10.;
format Join_Date ddmmyy10.;
informat End_Date ddmmyy10.;
format End_Date ddmmyy10.;
datalines;
Data_Analytics   Dheeraj       25    BTech    Male      20/12/2017      20/12/2019
Data_Analytics   RajKumar      18    BTech    Male      12/02/2017      12/02/2019
Data_Analytics   Rahul         20    BTech    Male      02/07/2017      02/07/2019
Data_Analytics   Chandhini    21    BTech    Female    06/04/2017      06/04/2019
Data_Analytics   Bhuvanesh     .       .      Male      10/05/2017      10/05/2019
;
run;

proc print data=Class;

/*======================================================================================================================*/
/* 4)  INFILE IRIS DATA FROM LOCAL SYSTEM */
/*======================================================================================================================*/

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

/*======================================================================================================================*/
/* 5)  PROC CONTENTS */
/*======================================================================================================================*/

proc contents data = Iris;
run;

proc contents data = Iris nods;
run;

proc data = Iris;
by Species;

