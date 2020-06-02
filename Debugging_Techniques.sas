/*******************************************************************************

Debugging Techniques - a collection of snippets

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
