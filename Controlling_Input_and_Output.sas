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
