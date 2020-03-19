/*
QUIZ 5

Lancione, Samantha (300140003)
*/

/*SET UP*/
/*Library pointing to data that WON'T be modified*/
libname ldata '/folders/myfolders/largedata';

/*Library pointing to what will be used to modify*/
libname class '/folders/myfolders/largedata/workfolder/Data';

/*Sorting NHRABSTRACTS dataset by encounter ID and saving it in class library*/
proc sort data=ldata.nhrabstracts out=class.nhrabstracts;
	by hraEncWID;
run;

/*
STEP 1
Creating the spine dataset - spine

Sorting by encounter ID
Delete missing admission dates
Selecting admission dates between 2003-2004
*/

data class.spine;
	set class.nhrabstracts;
	by hraEncWID;
	if hraAdmDtm =. then delete;
	if year(datepart(hraAdmDtm)) in (2003, 2004);
run;
/*The dataset CLASS.SPINE has 2230 observations*/


/*Sorting NHRDIAGNOSIS dataset by encounter ID and saving it in class library*/
proc sort data=ldata.nhrdiagnosis out=class.nhrdiagnosis;
	by hdghraencwid;
run;

/*
STEP 2
Creating the rib dataset - diabetes

Sorting by encounter ID
Create an indicator variable DM and counter variable
Flatfilling the NHRDIAGNOSIS dataset
Selecting only diagnosis codes for diabetes 
*/

data class.diabetes;
	set class.nhrdiagnosis;
	by hdghraencwid;
	if first.hdghraencwid then do;
	DM=0;
	count=0;
end;
	if hdgcd in:('250' 'E10' 'E11') then do;
	DM=1;
	count=count+1;
end;
	if last.hdghraencwid then output;
	retain DM count;
run;
/*The dataset CLASS.DIABETES has 32844 observations*/


/*
STEP 3
Merging the 2 datasets - Left Join
Final dataset will have same number of observations as spine dataset

Renaming the encounter ID variables to ID to match in both datasets
Deleting patients with missing diagnosis codes
*/

data class.merged;
	merge class.spine (in=a rename=(hraEncWID=ID))
	class.diabetes (rename=hdghraencwid=ID);
	if hdgcd ne '';
	by ID;
	if a;
run;
/*The data set CLASS.MERGED has 1981 observations*/

/*
STEP 4
Creating frequency table of diabetes diagnoses
*/

proc freq data=class.merged;
tables DM;
run;
