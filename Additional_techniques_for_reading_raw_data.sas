/****************************************************
Additional techniques for reading raw data - a collection of snippets

from Summary of Lesson 2: Reading Raw Data using Formated Input
SAS Programing 2 course focuses on using the SAS DATA step

- use a subsetting IF statement to output selected observations
- read a raw data file with multiple records per observation
- read a raw data file with mixed record types
- subset from a raw data file with mixed record types
*******************************************************************************/


/*******************************************************************************
1. Using Formatted Input
*******************************************************************************/

/*---PRACTICE 1---*/

DATA SalesStaff;
   INFILE "&path/sales1.dat";
   INPUT @1 Employee_ID 6.
         @21 Last_Name $18.
         @43 Job_Title $20.
         @64 Salary Dollar8.
         @87 Hire_Date mmddyy10.;
RUN;

TITLE 'Australian and US Sales Staff';
PROC PRINT DATA=salesstaff;
RUN;
TITLE;

/*---PRACTICE 2---*/



DATA us_trainees au_trainees;
	DROP Country; /*(4)*/
   	INFILE "&path/sales1.dat";
   	INPUT @1 Employee_ID 6.
         @21 Last_Name $18.
         @43 Job_Title $20.
         @64 Salary Dollar8.
         @73 Country $2.
         @87 Hire_Date mmddyy10.;

	IF Job_Title = 'Sales Rep. I';/*(3)*/

	IF Country = 'US'
		THEN OUTPUT us_trainees;/*(2)*/
	ELSE IF Country = 'AU'
		THEN OUTPUT au_trainees;/*(2)*/

RUN;

TITLE 'Trainees based in the United States';
PROC PRINT DATA=us_trainees;
RUN;
TITLE 'Trainees based in the Australia';
PROC PRINT DATA=au_trainees;
RUN;
TITLE;



/*******************************************************************************
2. Creating a Single Observation from Multiple Records
*******************************************************************************/
You can use multiple INPUT statements to read a group of records and create a single observation. By default, SAS loads a new record into the input buffer when it encounters an INPUT statement.

DATA SAS-data-set;
       INFILE 'raw-data-file-name';
       INPUT specifications;
       INPUT specifications;
      <additional SAS statements>


As an alternative to writing multiple INPUT statements, you can write one INPUT statement that contains line pointer controls to specify the record(s) from which values are to be read. There are two line pointer controls, the forward slash and the #n.

DATA SAS-data-set;
      INFILE 'raw-data-file-name';
      INPUT specifications /
                 #n specifications;
      <additional SAS statements>


The forward slash moves the line pointer relative to the line on which it is currently positioned, causing it to read the next record. The forward slash only moves the input pointer forward and must be specified after the instructions for reading the values in the current record.

The #n line pointer control specifies the absolute number of the line to which you want to move the input pointer. The #n pointer control can read lines in any order. You must specify the #n before the instructions for reading the values.


/*---PRACTICE 3---*/



DATA sales_staff2;
	INFILE "&path/sales2.dat";
   	INPUT #1 @1 Employee_ID 6. @21 Last_Name $18.
          #2 @1 Job_Title $20. @22 Hire_Date mmddyy10. @33 Salary Dollar8.
          #3 ; /*do not read anything from 3rd line of raw data of the record*/
RUN;

TITLE 'Australian and US Sales Staff';
PROC PRINT DATA=sales_staff2;
RUN;
TITLE;



/*******************************************************************************
3. Controlling When a Record Loads
*******************************************************************************/

By default, each INPUT statement in a DATA step reads the next record into the input buffer, overwriting the previous contents of the buffer. You can use a line-hold specifier, the single trailing @, to prevent the second INPUT statement from reading a record.

INPUT specifications . . . @ ;


The single trailing @ holds the record in the input buffer, causing the next INPUT statement to read from the buffer, instead of loading a new record. The input buffer is held until an INPUT statement without a trailing @ executes or the next iteration of the DATA step begins.


/*---PRACTICE 4---*/



DATA au_sales us_sales; /*(2)*/
	DROP Country; /*(5)*/
	INFILE "&path/sales3.dat"; /*(1)*/
   	INPUT #1 @1 Employee_ID 6. @21 Last_Name $18. @43 Job_Title $20.
   	      #2 @10 Country $2.
          @ ; /*prevent the second INPUT statement from reading a record*/
    IF Country = 'US' /*(3)*/
      THEN
      	DO;
      		/* $26,010(dollarx8.)  US($2.)  03/13/1968(ddmmyy10.)  */
      		INPUT #2 @1 Salary dollarx8. @24 Hire_Date ddmmyy10.; /*(6)*/
      		OUTPUT us_sales;
      	END;
    ELSE IF Country = 'AU' /*(4)*/
      THEN
      	DO;
      		/* $26.600(dollar8.)  AU($2.)  02/08/1948(mmddyy10.)  */
      		INPUT #2 @1 Salary dollar8. @24 Hire_Date mmddyy10.; /*(6)*/
      		OUTPUT au_sales;
      	END;
RUN;

TITLE 'US Sales Staff';
PROC PRINT DATA=us_sales;
RUN;
TITLE 'Australian Sales Staff';
PROC PRINT DATA=au_sales;
RUN;
TITLE;



/*******************************************************************************
Sample Programs
*******************************************************************************/

/* Using Formatted Input  */
data work.discounts;
   infile "&path/offers.dat";
   input @1 Cust_type 4.
         @5 Offer_dt mmddyy8.
         +1 Item_gp $8.;
run;

/* Creating a Single Observation from Multiple Records  */
data mycontacts;
   infile "&path/address.dat";
   input FullName $30. / /
         Address2 $25. /
         Phone $8. ;
run;


data mycontacts;
   infile "&path/address.dat";
   input #1 FullName $30.
         #3 Address2 $25.
         #4 Phone $8. ;
run;

/* Controlling When a Record Loads */
data salesQ1;
   infile "&path/sales.dat";
   input SaleID $4. @6 Location $3. @;
   if Location='USA' then
      input @10 SaleDate mmddyy10.
            @20 Amount 7.;
   else if Location='EUR' then
      input @10 SaleDate date9.
            @20 Amount commax7.;
run;


data EuropeQ1;
  infile "&path/sales.dat";
  input @6 Location $3. @;
  if Location='EUR';
     input  @1 SaleID $4.
           @10 SaleDate date9.
           @20 Amount commax7.;
run;
