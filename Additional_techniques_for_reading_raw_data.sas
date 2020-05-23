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
The way data is organized in a raw data file determines which input style you should use to read the data.
You can use LIST INPUT to read standard or nonstandard data that is separated by delimiters.
You can use COLUMN INPUT to read standard data that is arranged in columns or fixed fields.

INPUT variable <$> startcol-endcol . . . ;


Standard data is data that SAS can read without any special instructions.

Standard data values can contain only numbers, decimal points, numbers in scientific or E-notation, plus signs, and minus signs.

Nonstandard data (e.g. "9/22/07", "10%") is data that SAS cannot read without special instructions. Nonstandard data also includes date and time values as well as data in fraction, integer binary, real binary, and hexadecimal forms.
Nonstandard data values require an input style that has more flexibility than column input.

1.2 formatted input

You can use formatted input, which combines the features of column input with the ability to read both standard and nonstandard data in fixed fields.

INPUT column-pointer-control variable informat . . . ;

When you use formatted input, you specify the starting position of a field using a column pointer control, name the variable, and specify an informat. An informat is the special instruction that specifies how SAS reads raw data.
https://support.sas.com/edu/OLTRN/ECPRG293/eclibjr/sasinformats.htm


1.3 Using the @n Column Pointer Control

There are two choices for column pointer control: absolute and relative.
With absolute pointer control, @n , you specify the column in which the field begins. SAS moves the input pointer directly to column n, which is the first column of the field that you want to read.
INPUT @n variable informat . . . ;

Relative pointer control, +n , moves the input pointer from left to right, to a column position that is relative to the current position. The + sign moves the pointer forward n columns.
INPUT +n variable informat . . . ;

With this style of pointer control, it's important to understand the position of the input pointer after a data value is read. With formatted input, the input pointer moves to the first column following the field that was just read.

The informat indicates the type and length of the variable to be created. It also tells SAS the width of the input field in the raw data file, and how to convert the data value before copying it to the program data vector.

/*---PRACTICE 1---*/
/*
Use Formatted Input

Task:
In this practice, you create a new data set that contains data from selected fields in a raw data file.
The raw data file sales1.dat contains employee information for Orion Star sales staff in Australia and the United States.
120102 Tom          Zhou               M  Sales Manager        $108,255 AU 08/11/1973 06/01/1993
120103 Wilson       Dawes              M  Sales Manager         $87,975 AU 01/22/1953 01/01/1978
120121 Irenie       Elvish             F  Sales Rep. II         $26,600 AU 08/02/1948 01/01/1978
...

Reminder: Make sure you've defined the Orion library.
1. Write a DATA step to create a new data set named salesstaff.
The data set needs to contain data from the following fields:
Employee_ID, Last_Name, Job_Title, Salary, and Hire_Date.
2. Print the new data set with an appropriate title
and then view your results.

The resulting data set contains 5 variables and 165 observations.
*/

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

/* Use Formatted Input and a Subsetting IF Statement

Task:
In this practice, you create two data sets from a raw data file.
The raw data file sales1.dat contains employee information
for Orion Star sales staff in Australia and the United States.
120102 Tom          Zhou               M  Sales Manager        $108,255 AU 08/11/1973 06/01/1993
120103 Wilson       Dawes              M  Sales Manager         $87,975 AU 01/22/1953 01/01/1978
120121 Irenie       Elvish             F  Sales Rep. II         $26,600 AU 08/02/1948 01/01/1978
...
Reminder: Make sure you've defined the Orion library.
1. Use the data in the raw data file sales1.dat to create two SAS data sets
based on the country of the employee. Name the data sets us_trainees and au_trainees.
2. The us_trainees data set should only contain data for trainees based in the United States.
The au_trainees data set should only contain data for trainees based in Australia.
3. A trainee is anyone that has the job title of Sales Rep. I .
4. Each data set should contain data from the following fields:
Employee_ID, Last_Name, Job_Title, Salary, and Hire_Date.
5. Print both of the data sets with appropriate titles and then view your results.

Results:
The au_trainees data set contains 5 variables and 21 observations.
The us_trainees data set contains 5 variables and 42 observations.
*/

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

/* Create a Single Observation from Multiple Records

Task:
In this practice, you create a new data set from a raw data file that contains multiple records for each observation.
The raw data file sales2.dat contains Orion Star employee information for sales staff in Australia and the United States. Information for each employee spans three lines of raw data.
120102 Tom          Zhou
Sales Manager        06/01/1993 $108,255
M 08/11/1973 AU
120103 Wilson       Dawes
Sales Manager        01/01/1978  $87,975
M 01/22/1953 AU
120121 Irenie       Elvish
Sales Rep. II        01/01/1978  $26,600
F 08/02/1948 AU
...

Reminder: Make sure you've defined the Orion library.
1. Use sales2.dat to create a new data set named sales_staff2.
2. The data set needs to contain data from the following fields:
Employee_ID, Last_Name, Job_Title, Hire_Date, and Salary.
Use a single INPUT statement.
3. Print the new data set with an appropriate title and then view your results.

The resulting data set contains 5 variables and 165 observations. A final forward slash is required in the INPUT statement. The final forward slash loads the last record into the input buffer without reading any values and moves the line pointer to the first record of the next observation.
*/

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

/* Control When a Record Loads

Task:

In this practice, you create two data sets from a raw data file.
The information for each observation spans two lines of raw data.
The raw data file sales3.dat contains Orion Star employee information
for sales staff in Australia and the United States.
Information for each employee spans two lines of raw data.
120102 Tom          Zhou                  Sales Manager
$108.255 AU 11/08/1973 01/06/1993
120103 Wilson       Dawes                 Sales Manager
 $87.975 AU 22/01/1953 01/01/1978
120121 Irenie       Elvish                Sales Rep. II
 $26.600 AU 02/08/1948 01/01/1978
...
121023 Shawn        Fuller                Sales Rep. I
 $26,010 US 03/13/1968 05/01/2011
...

Reminder: Make sure you've defined the Orion library.
1. Use the data in sales3.dat to create two SAS data sets
based on the country of the employee.
2. Name the data sets au_sales and us_sales.
3. The au_sales data set should only contain data for employees based in Australia.
4. The us_sales data set should only contain data for employees based in the United States.
5. Each data set should contain data from the following fields:
Employee_ID, Last_Name, Job_Title, Salary, and Hire_Date.
6. Note: The Salary and Hire_Date values are different for Australian and U.S. employees.
Be sure to use the correct informats in each INPUT statement.
7. Print the new data sets with appropriate titles and then view your results.

Results:
The au_sales data set contains 5 variables and 63 observations.
The us_sales data set contains 5 variables and 102 observations.*/

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
