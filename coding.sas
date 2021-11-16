libname fn '/folders/myfolders/RESEARCH/andgyn'; 
options nofmterr; 

/* V1 DATA SET*/
proc sort data= fn.allv1;
by nif; 
run;

/* V2 DATA SET */
proc sort data = fn.allv2;
by nif;
run;
data newv2;
set fn.allv2;
drop sexef;
run;

proc sort data= newv2;
by nif; run;


/* MERGE V1 AND V2 */
data all;
merge fn.allv1 newv2;
by nif;
run;

/* data set to analyze --- baseline */
data baseline;
set all; 
andgyn= andfatv1/gynfatv1;

if BMIEFV1WHOP>= 85
then ovob=1;
if BMIEFV1WHOP<85 then ovob=0;

if v1fe27 = 1 then pubertyv1 = 0;
if v1fe27 = 2 or v1fe27 = 3 or v1fe27 = 4 then pubertyv1 =1;


if V1FE11C=. then CIRCHEFV1=MEAN(V1FE11A,V1FE11B);
if V1FE11C^=. then do;
	diff1=abs(V1FE11A-V1FE11B);
	diff2=abs(V1FE11A-V1FE11c);
	diff3=abs(V1FE11B-V1FE11c);
if (diff1<= diff2) and (diff1<= diff3) then CIRCHEFV1=mean(V1FE11A,V1FE11B);
if (diff2<= diff3) and (diff2<= diff1) then CIRCHEFV1=mean(V1FE11A,V1FE11c);
if (diff3<= diff1) and (diff3<= diff2) then CIRCHEFV1=mean(V1FE11b,V1FE11c);
end;

waist_hipv1=CIRCTEFV1/CIRCHEFV1;

if andgyn=. or WHREFV1=. or CIRCTEFV1=. or waist_hipv1=. 
or V1BE1A=. or V1BE1C=. or V1BE1D1=. or V1BE3A=. or V1BE2A=.
then delete;

run;

/* standardize new4 baseline */
proc standard data=baseline out=standardized_new4 MEAN=0 STD=1; 
var andgyn WHREFV1 CIRCTEFV1 waist_hipv1; 
run;
proc sort data=standardized_new4; 
by sexef; run;

/* check sample size => n= 619*/
proc means data = baseline;
 var sexef ageefv1 AGEEFV1 POIDSEFV1  v1be1a v1be1c v1be1d1 v1be3a 
v1be2a pubertyv1 BMIEFV1WHOZ andgyn WHREFV1 CIRCTEFV1 waist_hipv1;
 run;
 
 
 /* DATA FOLLOWUP BASED ON STANDARDIZED ANDGYN AT BASELINE */
data followup;
set all;
andgyn= andfatv1/gynfatv1; 
if BMIEFV1WHOP>= 85
then ovob=1;
if BMIEFV1WHOP<85 then ovob=0;
if v1fe27 = 1 then pubertyv1 = 0;
if v1fe27 = 2 or v1fe27 = 3 or v1fe27 = 4 then pubertyv1 =1;
if V1FE11C=. then CIRCHEFV1=MEAN(V1FE11A,V1FE11B);
if V1FE11C^=. then do;
	diff1=abs(V1FE11A-V1FE11B);
	diff2=abs(V1FE11A-V1FE11c);
	diff3=abs(V1FE11B-V1FE11c);
if (diff1<= diff2) and (diff1<= diff3) then CIRCHEFV1=mean(V1FE11A,V1FE11B);
if (diff2<= diff3) and (diff2<= diff1) then CIRCHEFV1=mean(V1FE11A,V1FE11c);
if (diff3<= diff1) and (diff3<= diff2) then CIRCHEFV1=mean(V1FE11b,V1FE11c);
end;
waist_hipv1=CIRCTEFV1/CIRCHEFV1;

/* add */

/* if BMIEFV2WHOP>= 85 */
/* then ovob=1; */
/* if BMIEFV2WHOP<85 then ovob=0; */
if v2fe27 = 1 then pubertyv2 = 0;
if v2fe27 = 2 or v2fe27 = 3 or v2fe27 = 4 then pubertyv2 =1;

if andgyn=. or WHREFV1=. or CIRCTEFV1=. or waist_hipv1=. 
or V2BE1A=. or V2BE1C=. or V2BE1D1=. or V2BE3A=. or V2BE2A=. or pubertyv2=.
then delete;

run;

proc means data = followup;
 var sexef AGEEFV1 POIDSEFV2  v2be1a v2be1c v2be1d1 v2be3a 
v2be2a pubertyv2  andgyn WHREFV1 CIRCTEFV1 waist_hipv1;
RUN;



 proc standard data=FOLLOWUP out=standardized_followup MEAN=0 STD=1; 
var andgyn WHREFV1 CIRCTEFV1 waist_hipv1; 
run;

 
 
/* check table 1 */
proc ttest data=baseline; 
class sexef; 
var AGEEFV1 POIDSEFV1  v1be1a v1be1c v1be1d1 v1be3a 
v1be2a pubertyv1 BMIEFV1WHOZ andgyn; 
run;

/* check table 2 */
proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 CIRCTEFV1 ; where sexef=1;
run; 
proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 andgyn ; where sexef=1;
run; 


/* BASELINE */
/* BOY */
proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 andgyn; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be1c = pubertyv1 ageefv1 andgyn; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be1d1 = pubertyv1 ageefv1 andgyn; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be3a = pubertyv1 ageefv1 andgyn; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be2a = pubertyv1 ageefv1 andgyn; where sexef = 1;
run;
/* GIRL */
proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 andgyn; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be1c = pubertyv1 ageefv1 andgyn; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be1d1 = pubertyv1 ageefv1 andgyn; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be3a = pubertyv1 ageefv1 andgyn; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be2a = pubertyv1 ageefv1 andgyn; where sexef = 2;
run;



/* FOLLOW UP */
/* BOY */
proc genmod data = standardized_FOLLOWUP;
model v2be1a = pubertyv2 ageefv1 andgyn; where sexef = 1;
run;
proc genmod data = standardized_FOLLOWUP;
model v2be1c = pubertyv2 ageefv1 andgyn; where sexef = 1;
run;
proc genmod data = standardized_FOLLOWUP;
model v2be1d1 = pubertyv2 ageefv1 andgyn; where sexef = 1;
run;
proc genmod data = standardized_FOLLOWUP;
model v2be3a = pubertyv2 ageefv1 andgyn; where sexef = 1;
run;
proc genmod data = standardized_FOLLOWUP;
model v2be2a = pubertyv2 ageefv1 andgyn; where sexef = 1;
run;
/* GIRL */
proc genmod data = standardized_FOLLOWUP;
model v2be1a = pubertyv2 ageefv1 andgyn; where sexef = 2;
run;
proc genmod data = standardized_FOLLOWUP;
model v2be1c = pubertyv2 ageefv1 andgyn; where sexef = 2;
run;
proc genmod data = standardized_FOLLOWUP;
model v2be1d1 = pubertyv2 ageefv1 andgyn; where sexef = 2;
run;
proc genmod data = standardized_FOLLOWUP;
model v2be3a = pubertyv2 ageefv1 andgyn; where sexef = 2;
run;
proc genmod data = standardized_FOLLOWUP;
model v2be2a = pubertyv2 ageefv1 andgyn; where sexef = 2;
run;


/* TABLE 3 */
proc genmod data = baseline;
model v1be1a = pubertyv1 ageefv1 CIRCTEFV1 ; where sexef=1;
run; 



/* BASELINE */

/* WAIST CIRCUM */
/* boy */
proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 CIRCTEFV1 ; where sexef=1;
run; 
proc genmod data = standardized_new4;
model v1be1c = pubertyv1 ageefv1 CIRCTEFV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be1d1 = pubertyv1 ageefv1 CIRCTEFV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be3a = pubertyv1 ageefv1 CIRCTEFV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be2a = pubertyv1 ageefv1 CIRCTEFV1; where sexef = 1;
run;
/* girl */
proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 CIRCTEFV1 ; where sexef=2;
run; 
proc genmod data = standardized_new4;
model v1be1c = pubertyv1 ageefv1 CIRCTEFV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be1d1 = pubertyv1 ageefv1 CIRCTEFV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be3a = pubertyv1 ageefv1 CIRCTEFV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be2a = pubertyv1 ageefv1 CIRCTEFV1; where sexef = 2;
run;

/* WAISTHIP */
proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 WAIST_HIPV1 ; where sexef=1;
run; 
proc genmod data = standardized_new4;
model v1be1c = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be1d1 = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be3a = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be2a = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 1;
run;

proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 WAIST_HIPV1 ; where sexef=2;
run; 
proc genmod data = standardized_new4;
model v1be1c = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be1d1 = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be3a = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be2a = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 2;
run;

/* 	WEIGHTHEIGHT */
proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 WHREFV1 ; where sexef=1;
run; 
proc genmod data = standardized_new4;
model v1be1c = pubertyv1 ageefv1 WHREFV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be1d1 = pubertyv1 ageefv1 WHREFV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be3a = pubertyv1 ageefv1 WHREFV1; where sexef = 1;
run;
proc genmod data = standardized_new4;
model v1be2a = pubertyv1 ageefv1 WHREFV1; where sexef = 1;
run;

proc genmod data = standardized_new4;
model v1be1a = pubertyv1 ageefv1 WHREFV1 ; where sexef=2;
run; 
proc genmod data = standardized_new4;
model v1be1c = pubertyv1 ageefv1 WHREFV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be1d1 = pubertyv1 ageefv1 WHREFV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be3a = pubertyv1 ageefv1 WHREFV1; where sexef = 2;
run;
proc genmod data = standardized_new4;
model v1be2a = pubertyv1 ageefv1 WHREFV1; where sexef = 2;
run;




/* FOLLOW UP */
/* WAIST CIRCUM */
/* boy */
proc genmod data = standardized_followup;
model v2be1a = pubertyv2 ageefv1 CIRCTEFV1 ; where sexef=1;
run; 
proc genmod data = standardized_followup;
model v2be1c = pubertyv2 ageefv1 CIRCTEFV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be1d1 = pubertyv2 ageefv1 CIRCTEFV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be3a = pubertyv2 ageefv1 CIRCTEFV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be2a = pubertyv2 ageefv1 CIRCTEFV1; where sexef = 1;
run;
/* girl */
proc genmod data = standardized_followup;
model v2be1a = pubertyv2 ageefv1 CIRCTEFV1 ; where sexef=2;
run; 
proc genmod data = standardized_followup;
model v2be1c = pubertyv2 ageefv1 CIRCTEFV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be1d1 = pubertyv2 ageefv1 CIRCTEFV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be3a = pubertyv2 ageefv1 CIRCTEFV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be2a = pubertyv2 ageefv1 CIRCTEFV1; where sexef = 2;
run;

/* WAISTHIP */
proc genmod data = standardized_followup;
model v2be1a = pubertyv2 ageefv1 WAIST_HIPV1 ; where sexef=1;
run; 
proc genmod data = standardized_followup;
model v2be1c = pubertyv2 ageefv1 WAIST_HIPV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be1d1 = pubertyv2 ageefv1 WAIST_HIPV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be3a = pubertyv2 ageefv1 WAIST_HIPV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be2a = pubertyv2 ageefv1 WAIST_HIPV1; where sexef = 1;
run;

proc genmod data = standardized_followup;
model v2be1a = pubertyv1 ageefv1 WAIST_HIPV1 ; where sexef=2;
run; 
proc genmod data = standardized_followup;
model v2be1c = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be1d1 = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be3a = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be2a = pubertyv1 ageefv1 WAIST_HIPV1; where sexef = 2;
run;

/* 	WEIGHTHEIGHT */
proc genmod data = standardized_followup;
model v2be1a = pubertyv2 ageefv1 WHREFV1 ; where sexef=1;
run; 
proc genmod data = standardized_followup;
model v2be1c = pubertyv2 ageefv1 WHREFV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be1d1 = pubertyv2 ageefv1 WHREFV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be3a = pubertyv2 ageefv1 WHREFV1; where sexef = 1;
run;
proc genmod data = standardized_followup;
model v2be2a = pubertyv2 ageefv1 WHREFV1; where sexef = 1;
run;

proc genmod data = standardized_followup;
model v2be1a = pubertyv2 ageefv1 WHREFV1 ; where sexef=2;
run; 
proc genmod data = standardized_followup;
model v2be1c = pubertyv2 ageefv1 WHREFV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be1d1 = pubertyv2 ageefv1 WHREFV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be3a = pubertyv2 ageefv1 WHREFV1; where sexef = 2;
run;
proc genmod data = standardized_followup;
model v2be2a = pubertyv2 ageefv1 WHREFV1; where sexef = 2;
run;
