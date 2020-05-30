/****************************************************
Controlling Input and Output - a collection of snippets

from Summary of Lesson 1: Controlling Input and Output
SAS Programing 2 course focuses on using the SAS DATA step

- explicitly control the output of multiple observations to a SAS data set
- create multiple SAS data sets in a single DATA step
- use conditional processing to control the data set or sets to which an observation is written
- control which variables are written to an output data set during a DATA step
- control which variables are read from an input data set during a DATA step
- control how many observations are processed from an input data set during a DATA or PROC step
*******************************************************************************/


/*******************************************************************************
1. Outputting Multiple Observations
*******************************************************************************/

/* You can control when SAS writes an observation to a SAS data set by using explicit OUTPUT statements in a DATA step. When an explicit OUTPUT statement is used, implicit output does not occur at the bottom of the DATA step.

OUTPUT <SAS-data-set(s)>;

The syntax for the OUTPUT statement begins with the keyword OUTPUT. Optionally, the keyword can be followed by the data set name to which the observation should be written. If you do not specify a data set name in the OUTPUT statement, the observation is written to the data set named in the DATA statement.*/

data forecast;
   /*The SET statement reads the first observation in the SAS data set growth into the program data vector.*/
   set orion.growth;

   /*Additional programming statements create the variable Year and calculate the total number of employees at the end of the first year. */
   year=1;
   Total_Employees=Total_Employees*(1+Increase);

   /*The first OUTPUT statement directs SAS to write the contents of the PDV to the output data set. No data set is listed in the OUTPUT statement, so SAS writes the observation to the 'forecast' data set.*/
   output;

   /*Processing continues with the additional programming statements that assign a new value to Year and calculate the total number of employees at the end of the second year.*/
   Year=2;
   Total_Employees=Total_Employees*(1+Increase);

   /*The second OUTPUT statement directs SAS to write the contents of the PDV to the forecast data set. Now there are two observations in the forecast data set from one observation that SAS read from the growth data set.*/
   output;

   /*An implicit RETURN statement returns processing to the top of the DATA step, and SAS reads the next observation from the growth data set.*/
run;

/*---PRACTICE 1---*/
/*read orion.prices and create a new data set named work.price_increase*/
DATA work.price_increase;
   SET orion.prices;
   /*use explicit OUTPUT statements to output three observations for each input observation*/

   /*create the variable Year to indicate year 1, 2, or 3.*/
   /* use the variable Unit_Price to forecast unit prices for the next three years, using Factor as the annual rate of increase.*/
   Year=1;
   Unit_Price=Unit_Price * Factor;
   OUTPUT;

   Year=2;
   Unit_Price=Unit_Price * Factor;
   OUTPUT;

   Year=3;
   Unit_Price=Unit_Price * Factor;
   OUTPUT;
RUN;

/*Print the new data set and include only Product_ID, Unit_Price, and Year in the report*/
PROC PRINT DATA=work.price_increase;
   VAR Product_ID Unit_Price Year;
RUN;

/*---PRACTICE 2---*/
/*Read orion.discount and use explicit OUTPUT statements to create a data set, work.extended, that lists all discounts for the Happy Holidays promotion. Output two observations for each observation read from the input data.*/
DATA work.extended;
	SET orion.discount;

	/** First obs - copy and modify December2011 discount **/
	/*Read only discounts with a Start_Date value of 01Dec2011*/
	WHERE Start_Date='01Dec2011'd;/*use 'd' as date type after parameter*/
	/*Drop the Unit_Sales_Price variable*/
	DROP Unit_Sales_Price;
	/*Create a variable, Promotion, that has the value Happy Holidays for each observation.*/
	Promotion = 'Happy Holidays';
	/*Create a variable, Season, that has a value of Winter for the December observations */
	Season = 'Winter';
	OUTPUT;

	/** Sec obs - create a new July2012 discount **/
	/*Create a variable, Season, that has a value of for the July observations.*/
	Season = 'Summer';
	/*Set new Start_Date and End_Date */
	Start_Date = '01Jul2012'd;
	End_Date = '31Jul2012'd;
	OUTPUT;
RUN;

/*Print the new data set with an appropriate title and view the results.
 */
title 'the Happy Holidays promotion products';
proc print data=work.extended;
   /* var Product_ID Unit_Price Year;*/
run;
title;



/*******************************************************************************
2. Writing to Multiple SAS Data Sets
*******************************************************************************/

/* 2.1 To create more than one data set, you specify the names of the SAS data sets you want to create in the DATA statement. Separate the data set names with a space.

DATA <SAS-data-set-name-1 SAS-data-set-name-2 ... SAS-data-set-name-n>;


2.2 OUTPUT statements with IF-THEN-ELSE

You can use OUTPUT statements with IF-THEN-ELSE statements to conditionally write observations to a specific data set based on the value of a variable in the input data set.

IF expression THEN statement;
ELSE IF expression THEN statement;
<ELSE IF expression THEN statement;>
<...>
<ELSE statement;>

DATA usa australia other;
   SET orion.employee_addresses;
   IF Country='AU' THEN
      OUTPUT australia;
   ELSE IF Country='US' THEN
      OUTPUT usa;
   ELSE
      OUTPUT other;
RUN;

For conditional processing, it's most efficient to check for values in order of decreasing frequency. Revise the program, as shown below, to check Country='US' first.

data usa australia other;
   set orion.employee_addresses;
   if Country='US' then output usa;
   else if Country='AU' then output australia;
   else output other;
run;
title 'Employees in the United States';
proc print data=usa;
run;

title 'Employees in Australia';
proc print data=australia;
run;

title 'Non US and AU Employees';
proc print data=other;
run;
title;

The values of Country were miscoded as lowercase. Now that you've seen the data in the other data set, you could fix the data or revise the conditional logic to look for both uppercase and lowercase values, or you could use a function in the IF statement to change the values of Country to uppercase.


2.3 OUTPUT statements with SELECT group

Another way to perform conditional processing in a DATA step is to use a SELECT group. It's more efficient to use a SELECT group rather than a series of IF-THEN statements when you have a long series of mutually exclusive conditions.

A SELECT group contains these statements:
- a SELECT statement that begins the group, followed by an optional SELECT expresion
- one or more WHEN statements that identify statements to execute when a condition is true
- an optional OTHERWISE statement that specifies a statement to execute if none of the WHEN conditions are true
- an END statement that ends the group.

SELECT <(select-expression)>;
        WHEN-1 (when-expression-1 <…, when-expression-n>) statement;
        WHEN-n (when-expression-1 <…, when-expression-n>) statement;
<OTHERWISE statement;>
END;

DATA usa australia other;
   SET orion.employee_addresses;
   SELECT (Country);
      WHEN ('US','us') OUTPUT usa;
      WHEN ('AU','au') OUTPUT australia;
      OTHERWISE OUTPUT other;
   END;
RUN;

The optional SELECT expression specifies any valid SAS expression. Often a variable name is used as the SELECT expression. When you specify a SELECT expression, SAS evaluates the expression and then compares the result to each when-expression. When a true condition is encountered, the associated statement is executed and the remaining WHEN statements are skipped.

If you omit the SELECT expression, SAS evaluates each when-expression until it finds a true condition, then behaves as described above. This form of SELECT is useful when you want to check the value of more than one variable using a compound condition, or check for an inequality. One thing to keep in mind is that SAS executes WHEN statements in the order that you write them and once a when-expression is true, no other when-expressions are evaluated.


2.3.2 null OTHERWISE

Although the OTHERWISE statement is optional, omitting it will result in an error if all when-expressions are false. You can use OTHERWISE with a null statement to prevent SAS from issuing an error message.

data usa australia other;
   set orion.employee_addresses;
   select (Country);
      when ('US') output usa;
      when ('AU') output australia;
      otherwise;
   end;
run;

A null OTHERWISE statement can be useful when you want to ignore certain values. For example,  if you only want to create data sets for employees in the United States and Australia, then you would want to ignore values for other countries.


2.3.3. DO-END groups in a SELECT Group

You can execute multiple statements when a when-expression is true by using DO-END groups in a SELECT Group.

DATA usa australia other;
	SET orion.employee_addresses;

	SELECT (UPCASE (Country));
		WHEN ('US')
			DO;/*execute multiple statements*/
				Benefits=1;
				OUTPUT usa;
			END;
		WHEN ('AU')
			DO;
				Benefits=2;
				OUTPUT australia;
			END;
		OTHERWISE
			DO;
				Benefits=0;
				OUTPUT other;
			END;
	END;
RUN;



2.3.4. Omitting the SELECT Expression

SELECT expression is optional.

The way SAS evaluates a WHEN expression in a SELECT group depends on whether or not you specify a SELECT expression. When you specify a SELECT expression in the SELECT statement, SAS finds the value of the SELECT expression and then compares the value to each WHEN expression to return a value of true or false.

SELECT (Country);
   WHEN ('US') OUTPUT usa;
   WHEN ('AU') OUTPUT australia;
   OTHERWISE OUTPUT other;
END;

/*less efficient*/
SELECT; /*Omitting the SELECT Expression*/
   WHEN (Country='US') OUTPUT usa;
   WHEN (Country='AU') OUTPUT australia;
   OTHERWISE OUTPUT other;
END;

There are times when you cannot use a SELECT expression. For example, you might want to check the condition of more than one variable in a WHEN expression. One thing to keep in mind is that SAS executes WHEN statements in the order that you write them and once a WHEN expression is true, no other WHEN expressions are evaluated.

SELECT;
   WHEN (Country='US') OUTPUT usa;
   WHEN (Country='AU' and City='Melbourne') OUTPUT newOffice;
   WHEN (Country='AU') OUTPUT australia;
   OTHERWISE OUTPUT other;
END;

The australia data set will contain all observations in which Country is Australia and City is NOT Melbourne. This is the result that we want. If you reverse the order of these two WHEN statements, all observations in which Country=AU will be written to the australia data set and no observations will be written to the newoffice data set.


/*---PRACTICE 3---*/
/* Read orion.employee_organization and create the data sets work.admin, work.stock, and work.purchasing.*/
DATA work.admin work.stock work.purchasing;
	SET orion.employee_organization;

	/* Output to these data sets depending on whether the value of Department is
	Administration, Stock & Shipping, or Purchasing, respectively. Ignore all other Department values.*/
	SELECT (Department);
		WHEN ('Administration')
			DO;
				OUTPUT work.admin;
			END;
		WHEN ('Stock & Shipping')
			DO;
				OUTPUT work.stock;
			END;
		WHEN ('Purchasing')
			DO;
				OUTPUT work.purchasing;
			END;
		OTHERWISE ;

		/*Ignore all other Department values*/
	END;
RUN;

/* Print each data set with an appropriate title. View your results and verify the output. */
TITLE 'Administration Department';
PROC PRINT DATA=work.admin;
RUN;
TITLE 'Stock & Shipping Department';
PROC PRINT DATA=work.stock;
RUN;
TITLE 'Purchasing Department';
PROC PRINT DATA=work.purchasing;
RUN;
TITLE;

/* or */
data work.admin work.stock work.purchasing;
   set orion.employee_organization;
   if Department='Administration' then output work.admin;
   else if Department='Stock & Shipping' then output work.stock;
   else if Department='Purchasing' then output work.purchasing;
run;

/*---PRACTICE 4---*/
/* Read orion.orders and create three data sets named work.fast, work.slow, and work.veryslow. */
DATA work.fast work.slow work.veryslow;
	SET orion.orders;

	/* Write a WHERE statement to read only the observations with Order_Type equal to 2 (catalog) or 3 (Internet). */
	WHERE Order_Type=2 OR Order_Type=3;

	/*Create a variable ShipDays that is the number of days between when the order was placed and when the order was delivered.*/
	ShipDays=Delivery_Date-Order_Date;

	/* Use IF-THEN statements to do the following:*/
	/* Output to work.fast when the value of ShipDays is less than 3*/
	IF ShipDays < 3 THEN
		OUTPUT work.fast;

	/* Output to work.slow when the value of ShipDays is 5 to 7 */
	ELSE IF ShipDays >=5 AND ShipDays <=7 THEN
		OUTPUT work.slow;

	/* Output to work.veryslow when the value of ShipDays is greater than 7.*/
	ELSE IF ShipDays > 7 THEN
		OUTPUT work.veryslow;

	/* Do not output an observation when the value of ShipDays is 3 or 4.*/
	/* Drop the variable Employee_ID.*/
	DROP Employee_ID;
RUN;

/* Print your results from work.veryslow with an appropriate title.*/
TITLE 'List of very slow deliveries (more than 7 days)';
PROC PRINT DATA=work.veryslow;
RUN;
TITLE;

/* The SAS data set work.fast has 80 observations, work.slow has 69 observations, and work.veryslow has 5 observations.*/



/*******************************************************************************
*   3. Controlling Variable Input and Output
*******************************************************************************/

/* By default, SAS writes all variables from the input data set to every data set listed in the DATA statement.
You can use DROP and KEEP statements (1) to control which variables are written to output data sets. DROP and KEEP statements affect all output data sets listed in the DATA statement. */

data usa australia other;
   drop Street_ID; /*(1)*/
   set orion.employee_addresses;
   if Country='US' then output usa;
   else if Country='AU' then output australia;
   else output other;
run;

/* When you use the DROP= or KEEP= data set options in a DATA statement,
the DROP= and KEEP= data set options specify the variables to drop or keep
in each output data set.
Remember, the dropped variables are still in the program data vector, and therefore available for processing in the DATA step.

When you use the DROP= or KEEP= data set options in a SET statement,
the variables are dropped on input.
In other words, they are not read into the program data vector, therefore they are not available for processing.

SAS_data_set_name(DROP=variable_1 variable_2 ... variable_n)
SAS_data_set_name(KEEP=variable_a variable_b ... variable_z)

/* The KEEP= option specifies only 3 variables
to keep in the 'usa' output data set.*/
data  usa(keep=Employee_Name City State) /* drop 6 of the variables from the  'usa' output data set, so it's easier to use a KEEP= option*/
      australia(drop=Street_ID State Country) /*keep 6 variables for the 'australia' output data set, so it's easier to use a DROP= option */
      other; /*keep all 9 variables for the 'other' output data set*/

   set orion.employee_addresses;
   if Country='US' then
      output usa;
   else if Country='AU' then
      output australia;
   else
      output other;
run;

/* You can use both DROP and KEEP statements and DROP= and KEEP= options in the same step, but do not try to drop and keep the same variable.
If you use a DROP or KEEP statement at the same time as a data set option, the statement is applied first.*/


/* 3.2 Controlling Variable Input Using the DROP= and KEEP= options
in the SET statement (an input data set) */

DATA usa;
  SET orion.employee_addresses (DROP=
      Street_ID Street_Number Street_Name Country);
  <additional SAS statements>;
run;

/* Remember that when you associate the DROP= and KEEP= data set options with an output data set, the variables are still available for processing.

In contrast, when you associate these options with an input data set in a SET statement, the variables are not read into the program data vector, and therefore they are not available for processing.

For cases where you don't need all the variables in an input data set, this is an efficient way to drop them so that they aren't processed at all. */

/* Example
You want to drop 'Employee_ID' and 'Country' from every data set, and you want to drop 'State' from the australia data set. You can do this by using a combination of options and statements. Let's start over with the code that creates the three data sets with all nine variables.

You can use the DROP= data set option (1) in the SET statement to drop Employee_ID from the input data because it's not used for processing in the DATA step. */

data  usa
      australia(DROP=State) /* (3)*/
      other;
   DROP Country; /* (2) */
   set orion.employee_addresses
      (DROP=Employee_ID); /* (1) */
   if Country='US' then
      output usa;
   else if Country='AU' then
      output australia;
   else
      output other;
run;

/* Next you want to drop Country from every output data set, but the variable needs to be available for processing.

Here's a question: What's the simplest way to drop Country from all three output data sets? It’s easiest to use a DROP statement (2).

You could use the DROP= data set option to drop the variable from each output data set individually
data usa(DROP=Country) australia(DROP=State, Country) otherDROP=Country);
but it's more concise to use a DROP statement.

Finally, you use the DROP= data set option (3) to drop 'State' from the australia data set.

When the code compiles, only the Employee_ID variable is dropped from the input data, and all other variables are included in the program data vector and are available for processing. */

/* Other Example:
The SAS data set car has the variables CarID, CarType, Miles, and Gallons. Select the DATA step or steps that creates the ratings data set with the variables CarType and MPG. */

data ratings(keep=CarType MPG);
   set car(drop=CarID);
   MPG=Miles/Gallons;
run;

/* or this way */

data ratings;
   set car(drop=CarID);
   drop Miles Gallons;
   MPG=Miles/Gallons;
run;



/******************************************************************************
*   4. Controlling Which Observations Are Read
******************************************************************************/

/* 4.1 use FIRSTOBS= and OBS= options in an SET statement

You can use the OBS= and FIRSTOBS= data set options to limit the number of observations that SAS processes.

The FIRSTOBS= data set option specifies a starting point for processing an input data set. By default, FIRSTOBS=1.

The OBS= data set option specifies the number of the last observation to process. It does not specify how many observations should be processed.

You can use FIRSTOBS= and OBS= together to define a range of observations for SAS to process.

SAS_data_set_name(OBS=n)
  E.g. (OBS=100) data set option in this SET statement causes the DATA step to stop processing after observation 100.
SAS_data_set_name(FIRSTOBS=n)
  E.g. (FIRSTOBS=20) data set option to specify a starting point for processing an input data set, so the SET statement starts reading observations from the input data set at observation number 20 and continues processing until the last observation is read.
SAS_data_set_name(FIRSTOBS=n OBS=n)
  Used together to define a range of observations in the data set.
  E.g. (FIRSTOBS=50 OBS=100) - these data set options cause the SET statement to read 51 observations from the data set. Processing begins with observation 50 and ends after observation 100.

Both the FIRSTOBS= and the OBS= options are used with input data sets - SET statement. You cannot use either option with output data sets.
When you limit the number of observations that SAS reads from input data, the number of observations in your output data is also limited.


4.2 Use FIRSTOBS= and OBS= options in an INFILE statement

You can also use FIRSTOBS= and OBS= options in an INFILE statement to control which records are read when you read raw data files.

DATA employees;
  INFILE 'emps.dat' FIRSTOBS=11 and OBS=15;
  INPUT @1 EmpID 8. @9 EmpName $40. @153 Country $2.;
RUN;
PROC PRINT DATA=employees;
RUN;

Notice that the syntax is different. In an INFILE statement, the options follow the filename, but they are not enclosed in parentheses.

4.3 Use FIRSTOBS= and OBS= options in an SAS procedures (e.g. PROC PRINT step)

You can also use FIRSTOBS= and OBS= in a procedure step, to limit the number of observations that are processed.

DATA new;
   SET old(FIRSTOBS=100 OBS=200);
RUN;
PROC PRINT DATA=new(OBS=50);
RUN;

The data set options in the SET statement direct SAS to begin reading at observation 100 and stop after observation 200. The data set option in the PROC PRINT step directs SAS to stop printing after 50 observations.

PROC PRINT DATA=orion.employee_addresses(OBS=10);
  WHERE Country='AU';
  VAR Employee_Name City State Country;
RUN;

If a WHERE statement is used to subset the observations, it is applied before the FIRSTOBS= and OBS= data set options. */

/*---PRACTICE 5---*/
/*
 * Practice L1-5: Specify Variables and Observations
 */


/*
Task
In this practice, you create two data sets based on the value of a variable in the input data. You specify which variables to include in the output data sets and you specify the observations to print.
The data set orion.employee_organization contains information on employee job titles, departments, and managers. Create two data sets: one for the Sales department and another for the Executive department.

Reminder: Make sure you've defined the Orion library.
1.Read orion.employee_organization and create the output data sets work.salesinfo and work.execinfo.
2.Output to these data sets depending on whether the value of Department is Sales or Executives, respectively. Ignore all other values of Department.
3.The work.salesinfo data set should contain three variables (Employee_ID, Job_Title, and Manager_ID).
4.The work.execinfo data set should contain two variables (Employee_ID and Job_Title).
5.Print only the first six observations from work.salesinfo. Add an appropriate title.
6.Print only the second and third observations from work.execinfo. Add an appropriate title.
 */

DATA work.saleinfo work.execinfo(DROP=Manager_ID);
	SET orion.employee_organization;
	WHERE Department IN('Sales','Executives');
	DROP Department;
RUN;
TITLE 'only the first six observations from the Sales department';
PROC PRINT DATA=work.saleinfo (OBS=6);
RUN;
TITLE 'only the second and third observations from the Executive department';
PROC PRINT DATA=work.execinfo (FIRSTOBS=2 OBS=3);
RUN;
TITLE;

/*---PRACTICE 6---*/
/*
 * Practice L1-6: Specify Variables and Observations
 */
 DATA work.instore (KEEP=Order_ID Customer_ID Order_Date)
 		work.delivery (KEEP=Order_ID Customer_ID Order_Date ShipDays);
 	SET orion.orders;
 	WHERE Order_Type=1;
 	ShipDays=Delivery_Date - Order_Date;

 	IF ShipDays=0 THEN
 		OUTPUT work.instore;
 	ELSE IF ShipDays>0 THEN
 		OUTPUT work.delivery;
 RUN;


 TITLE 'Deliveries from In-store Purchases';

 PROC PRINT DATA=work.delivery;
 RUN;

 TITLE 'In-Store Purchases, By Year';
 PROC FREQ DATA=work.instore;
    TABLES Order_Date;
    FORMAT Order_Date year.;
 RUN;
 TITLE;



/*********************************************************
*   Sample Programs
**********************************************************/

Outputting Multiple Observations

data forecast;
   set orion.growth;
   year=1;
   Total_Employees=Total_Employees*(1+Increase);
   output;
   Year=2;
   Total_Employees=Total_Employees*(1+Increase);
   output;
run;

Writing to Multiple SAS Data Sets (Using a SELECT Group)
data usa australia other;
   set orion.employee_addresses;
   select (Country);
     when ('US') output usa;
     when ('AU') output australia;
     otherwise output other;
   end;
run;

Writing to Multiple Data Sets (Using a SELECT Group with DO-END Group in the WHEN statement)
data usa australia other;
   set orion.employee_addresses;
   select (upcase(Country));
      when ('US') do;
         Benefits=1;
         output usa;
      end;
      when ('AU') do;
         Benefits=2;
         output australia;
      end;
      otherwise do;
         Benefits=0;
         output other;
      end;
   end;
run;

Controlling Variable Input and Output
data usa australia(drop=State) other;
   drop Country;
   set orion.employee_addresses
      (drop=Employee_ID);
   if Country='US' then output usa;
   else if Country='AU' then output australia;
   else output other;
run;

Controlling Observation Input and Output
data australia;
   set orion.employee_addresses
      (firstobs=50 obs=100);
   if Country='AU' then output;
run;

proc print data=orion.employee_addresses
           (obs=10);
   where Country='AU';
   var Employee_Name City State Country;
run;
