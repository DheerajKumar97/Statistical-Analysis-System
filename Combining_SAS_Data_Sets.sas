/*******************************************************************************

Combining SAS Data Sets - a collection of snippets

from Summary of Lesson 9: Combining SAS Data Sets
SAS Programing 2 course focuses on using the SAS DATA step

- use data manipulation techniques in a DATA step to perform a match-merge
- perform a match-merge on three SAS data sets that lack a common variable
- perform a match-merge on a SAS data set and a Microsoft Excel workbook
- perform a match-merge on SAS data sets that have identically named variables other than the BY variables
*******************************************************************************/


/*******************************************************************************
1. Match-Merging SAS Data Sets
*******************************************************************************/
/* 1. Match-Merging SAS Data Sets */
/*
In a process called match-merging, you use the MERGE statement in a DATA step to combine SAS data sets with related data into a new data set, based on the values of one or more common variables. Each observation in the new data set contains data from multiple input data sets. Before the merge, each input data set must be sorted by the common variable(s).

A match-merge produces matches (observations containing data from both input data sets) and non-matches (observations containing data from only one input data set) by default. You can control this by identifying data set contributors and using explicit OUTPUT or subsetting IF statements.
  DATA SAS-data-set;
          MERGE SAS-data-set1 SAS-data-set2 . . . ;
          BY <DESCENDING> BY-variable(s);
         <additional SAS statements>
  RUN;


proc sort data=orion.customer
     out=orion.customer;
   by Customer_ID;
run;
proc sort data=orion.order_fact
     out=work.orders_2007;
   by Customer_ID;
   where year(Order_Date)=2007;
run;

data custord;
   merge orion.customer
         work.orders_2007;
   by Customer_ID;
run;
proc print data=custord;
run;

1.2 Identifying Data Set Contributors
To identify the data sets that contribute data to an observation, you use the IN= data set option following the input data set name in the MERGE statement.

SAS creates a temporary variable with the name you specify, and assigns a value of 1 or 0 to indicate whether or not the data set contributed data to the observation in the program data vector.
You can use a subsetting IF statement to output only those observations that contain data from all the input data sets or from just one data set.

data custord;
   merge orion.customer(in=cust)
         work.orders_2007(in=order);
   by Customer_ID;
   if cust=1 and order=1;
run;

In the code, you can use two IN= data set options and a subsetting IF statement to determine whether an observation contains data from both input data sets.

In this example, the first IN= option creates the temporary variable cust.
This temporary variable is set to 1 when an observation from the orion.customer data set contributes to the current observation; otherwise, it is set to 0.
The second IN= option creates the temporary variable order. T
he value of order depends on whether the orders_2007 data set contributes to an observation.

The subsetting IF statement controls which observations will be in the output.
Once SAS reaches the IF statement in the DATA step shown here, the only processing that remains is the implicit output at the bottom of the DATA step.

So, if both of the IN= values equal 1, the condition in the IF statement evaluates to true and SAS writes the data that's currently in the PDV to the output data set.
If one of the IN= values is 0, the condition evaluates to false and SAS does not write the observation to the output data set.
Because SAS considers any numeric value other than 0 or missing as true, you can also write the IF statement as 'IF cust and order;'.

data custord;
   merge orion.customer(in=cust)
         work.orders_2007(in=order);
   by Customer_ID;
   if cust and order;
run;

  SAS-data-set (IN=variable)


Question
Which of the following IF statements creates the non-matches seen in the combine data set?
data combine;
   merge products(in=InProd) costs(in=InCost);
   by ID;
   _________________________________
run;

a.  if InProd=1 or InCost=1;
OK --> b.  if InProd=0 or InCost=0;
c.  if InProd=0 and InCost=0;
Correct.
If the IN= variables equal zero, the data sets didn't contribute to the current observation. You use the "or" logical operator in the IF statement.
Neither data set contributes to the new data set if you use the "and" operator.
*/

/*******************************************************************************
2. Using Data Manipulation Techniques with a Match-Merge
*******************************************************************************/
/* 2.1 Using explicit OUTPUT with KEEP or DROP statement*/
/*
You can use explicit OUTPUT statements in a match-merge to control your output. For example, you can direct the matches (observations containing data from both input data sets) to one data set, and non-matches (observations containing data from only one input data set) to another data set.

  OUTPUT <SAS-data-set(s)>;

To control which variables appear in your output, you can use the KEEP= or DROP= data set option, or the KEEP or DROP statement.

data orderdata(keep=Customer_Name Product_ID Quantity Total_Retail_Price)
     noorders(keep=Customer_Name Birth_Date);
   merge orion.customer
         work.orders_2007(in=order);
   by Customer_ID;
   if order=1 then output orderdata;
   else output noorders;
run;
*/

/* 2.2 Using FIRST. and LAST. processing and sum statement and functions/
/*
You can summarize merged data by using FIRST. and LAST. processing along with a sum statement.

data orderdata(keep=Customer_Name Quantity
                 Total_Retail_Price)
     noorders(keep=Customer_Name Birth_Date)
     summary(keep=Customer_Name NumOrders
                  NameNumber);
   merge orion.customer
      work.orders_2007(in=order);
   by Customer_ID;
   if order=1 then do;
      output orderdata;
      if first.Customer_ID then NumOrders=0;
      NumOrders+1;
      NameNumber=catx('',Customer_LastName,NumOrders);
      if last.Customer_ID then output summary;
   end;
   else output noorders;
run;
*/

/*******************************************************************************
3. Match-Merging SAS Data Sets That Lack a Common Variable
*******************************************************************************/
/* 3. Match-Merging SAS Data Sets That Lack a Common Variable */
/*
If you need to merge three or more data sets that don’t share a common variable, you can use multiple separate DATA steps. Remember, the data sets must be sorted by the appropriate BY variable, so you may need to sort the intermediate data sets in this process.

You need to find a common variable to complete the sort and match-merge.
*/

/*******************************************************************************
4. Match-Merging SAS Data Sets That Lack a Common Variable
*******************************************************************************/
/* 4. Match-Merging SAS Data Sets That Lack a Common Variable */
/*
Match-Merging with an Excel Worksheet and Renaming Variables
You can access an Excel workbook in SAS using the SAS/ACCESS LIBNAME statement. This assigns a libref to the Excel workbook, allowing SAS to access the workbook as if it were a SAS library, and each worksheet as if it were a SAS data set.

  LIBNAME libref 'physical-file-name';

You can also merge a SAS data set with an Excel workbook. You need to identify the common variable, and may need to use the RENAME= data set option to complete the merge.

You use a SAS name literal to refer to an Excel worksheet in SAS code. You enclose the name of the worksheet, including the dollar sign, in quotation marks followed by the letter n.

Remember to clear the libref to unlock the Excel workbook when you are finished accessing it.

When you match-merge data sets that contain same-named variables (other than the BY variables), the data value from the second and subsequent data sets overwrites the value of the same-named variable from the first data set in the program data vector. You can use the RENAME= data set option to rename the variable(s) to unique names to avoid overwriting.

SAS-data-set (RENAME = (old-name-1 = new-name-1
                                            <…old-name-n = new-name-n>)
*/

/*******************************************************************************
    Sample Programs
*******************************************************************************/
/* 1. Match-Merging SAS Data Sets */
proc sort data=orion.order_fact
     out=work.orders_2007;
   by Customer_ID;
   where year(Order_Date)=2007;
run;
data custord;
   merge orion.customer(in=cust)
         work.orders_2007(in=order);
   by Customer_ID;
   if cust and order;
run;
proc print data=custord;
run;

/* 2. Controlling Match-Merge with explicit Output */
proc sort data=orion.order_fact
          out=work.orders_2007;
   by Customer_ID;
   where year(Order_Date)=2007;
run;
data orderdata(keep=Customer_Name Product_ID Quantity Total_Retail_Price)
     noorders(keep=Customer_Name Birth_Date);
   merge orion.customer
         work.orders_2007(in=order);
   by Customer_ID;
   if order=1 then output orderdata;
   else output noorders;
run;
proc print data=orderdata;
run;
proc print data=noorders;
run;

/* 3. Summarizing Merged Data */
proc sort data=orion.order_fact
          out=work.orders_2007;
   by Customer_ID;
   where year(Order_Date)=2007;
run;
data orderdata(keep=Customer_Name Quantity
                 Total_Retail_Price)
     noorders(keep=Customer_Name Birth_Date)
     summary(keep=Customer_Name NumOrders
                  NameNumber);
   merge orion.customer
      work.orders_2007(in=order);
   by Customer_ID;
   if order=1 then do;
      output orderdata;
      if first.Customer_ID then NumOrders=0;
      NumOrders+1;
      NameNumber=catx('',Customer_LastName,NumOrders);
      if last.Customer_ID then output summary;
   end;
   else output noorders;
run;
title 'Summary';
proc print data=summary;
run;
title;

/* 4.1. Match-Merging Multiple Data Sets: Step 1 */
proc sort data=orion.order_fact
          out=work.orders_2007;
   by Customer_ID;
   where year(Order_Date)=2007;
run;
data custord;
   merge orion.customer(in=cust)
         work.orders_2007(in=order);
   by Customer_ID;
   if cust=1 and order=1;
   keep Customer_ID Customer_Name Quantity
        Total_Retail_Price Product_ID;
run;
proc print data=custord;
run;

/* 4.2. Match-Merging Multiple Data Sets: Step 2  */
proc sort data=custord;
   by Product_ID;
run;
data custordprod;
   merge custord(in=ord)
         orion.product_dim(in=prod);
   by Product_ID;
   if ord=1 and prod=1;
   Supplier=catx(' ',Supplier_Country,Supplier_ID);
   keep Customer_Name Quantity
        Total_Retail_Price Product_ID Product_Name Supplier;
run;
proc print data=custordprod(obs=15) noobs;
run;

/* 5. Match-Merging with an Excel Worksheet and Renaming Variables */
proc sort data=custordprod;
      by Supplier;
run;
libname bonus pcfiles path="&path/BonusGift.xls";
data custordprodGift;
   merge custordprod(in=c)
         bonus.'Supplier$'n(in=s
               rename=(SuppID=Supplier
                    Quantity=Minimum));
   by Supplier;
   if c=1 and s=1 and Quantity >= Minimum;
run;

libname bonus clear;
proc sort data=custordprodGift;
   by Customer_Name;
run;
proc print data=custordprodGift;
   var Customer_Name Gift;
run;
