/*******************************************************************************

Debugging Techniques - a collection of snippets

from Summary of Lesson 6: Debugging Techniques
SAS Programing 2 course focuses on using the SAS DATA step

- use the PUTLOG statement to identify logic errors
*******************************************************************************/


/*******************************************************************************
1. Understanding Logic Errors
*******************************************************************************/
/*
Debugging is the process of identifying and removing logic errors from a program. Logic errors are different from syntax errors.

Syntax errors occur when programming statements don’t conform to the rules of the SAS language. When a syntax error occurs, SAS writes an error message to the log.

Logic errors occur when the programming statements follow the rules but the results are not correct. Since the statements conform to the rules, SAS continues to process the program and doesn't write an error message to the log. The lack of messages can make logic errors more difficult to detect and correct than syntax errors.
*/

/*******************************************************************************
2. Using PUTLOG Statements
*******************************************************************************/
/* 2.1 Using PUTLOG Statements */
/*
You can use PUTLOG statements to display messages, variable names, and variable values in the log. This technique is helpful when you suspect that the value of a variable might be causing a logic error.

By default, the PUTLOG statement writes character values with the standard character format $w. To use a different format, specify the name of the variable followed by the format name and width.

PUTLOG <specifications>;

a) To write a string of text to the log, you simply specify the keyword PUTLOG, followed by the quoted message text. The text must be enclosed in quotation marks.
PUTLOG 'text';

b) To write the name and value of a variable to the log.
This technique is helpful when you suspect that the value of a variable might be causing a logic error.
PUTLOG variable-name=;
e.g. PUTLOG State= Zip=;

/* 2.2 Formatting Character Values with the PUTLOG Statement */
/*
By default, the PUTLOG statement writes character values with the standard character format $w. This format left-justifies values and removes leading blanks. But, sometimes you might want to apply a different format.

For example, suppose your data values contain leading spaces. The leading spaces won't appear in the log message unless you specify a format that preserves leading spaces in the PUTLOG statement.

To add a format, you specify the name of the variable followed by the format name and width.
PUTLOG variable-name format-name__and__width.;

The format width must be wide enough to display the value of the variable, as well as any additional characters such as commas or quotation marks.

For example, the $QUOTEw. format writes a character value enclosed in double quotation marks and preserves any leading spaces.
PUTLOG City= $QUOTE22.;

If the value of the variable City is '  Philadelphia' with a leading space, the statement shown here writes , including the leading space, to the log.

You can increase the value of the format width beyond the minimum to ensure that you can see the full value of the variable in the log.
*/

/* 2.3 Viewing Automatic Variables with the PUTLOG Statement*/
/*
When you're debugging a program, it's often helpful to see what SAS has stored in the program data vector. To write the current contents of the PDV to the log, use the _ALL_ option in the PUTLOG statement.

PUTLOG _ALL_;

When you use the _ALL_ option, the values of the automatic variables _ERROR_ and _N_ are included in the log.

SAS creates an _ERROR_ variable for every DATA step. SAS changes the value of _ERROR_ from 0 to 1 when it encounters certain types of errors. For example, input data errors, conversion errors, and math errors are among the types of errors that cause the value of _ERROR_ to change. If the value of _ERROR_ changes to 1, SAS writes the contents of the PDV and a note to the log.

SAS also creates an _N_ variable for every DATA step. This variable represents the number of times that the DATA step has iterated. SAS initially sets the value of _N_ to 1. Each time the DATA step loops past the DATA statement, SAS increments _N_ by 1. SAS retains the value of _N_ between iterations, so you can use the value of _N_ to determine how many passes you’ve made through the data set.
*/

/* 2.4 Combining PUTLOG Statements with Conditional Logic */
/*
PUTLOG statements can be executed conditionally using IF-THEN statements.

For example, you might want to display the value of all variables when _ERROR_ is eqaul to 1, when _N_ is greater then 5000, or on the last iteration of the DATA step. But how do you know when the data step is on the last iteration?

You can use the END= option in the SET statement to create a temporary variable that acts as an end-of-file indicator.
SET SAS-data-set END=variable <options>;
e.g. SET orion.donate END=last;

You can also use the END= option in an INFILE statement to indicate the end of a raw data file.
INFILE 'raw-data-file' END=variable <options>;
e.g. INFILE catalog END=last;

The END= variable is initialized to 0 and is set to 1 when the last observation or record is read.
*/
DATA work.donate;
  SET orion.donate END=last; /* var last initialized to 0*/
  <additional SAS statements>
  /* then var last set to 1 */
  IF last=1
    THEN
      DO;
        <additional SAS statements>
      END;
RUN;

DATA work.donate;
  SET orion.donate END=last; /* var last initialized to 0*/
  IF _N_=1
    THEN
      /* write my comment to the log */
      PUTLOG 'First iteration';

  IF last=1 /*or it can be write: IF last */
    THEN
      DO;
        /* write my comment to the log */
        PUTLOG 'Final values of variables';
        /* write the values of all the variables to the log */
        PUTLOG _ALL_;
      END;
RUN;


/*******************************************************************************
    Sample Program
*******************************************************************************/

/*  */


data us_mailing;
   set orion.mailing_list (obs=10);
   drop Address3;
   length City $ 25 State $ 2 Zip $ 5;
   putlog _n_=;
   putlog "Looking for country";
   if find(Address3,'US');
     putlog "Found US";
     Name=catx(' ',scan(Name,2,','),scan(Name,1,','));
     City=scan(Address3,1,',');
     State=left(scan(address3,2,','));
     Zip=left(scan(Address3,3,','));
     putlog State=$quote4. Zip=$quote7.;
run;
