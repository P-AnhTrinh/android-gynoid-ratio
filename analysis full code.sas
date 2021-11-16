libname fn 'C:\SASUniversityEdition\myfolders\RESEARCH\andgyn'; 

proc sort data=fn.all; 
by nif; 
proc sort data=fn.dxa; 
by nif; 
proc sort data=fn.v1be; 
by nif; 
proc sort data=fn.v1fe; 
by nif; 
proc sort data=fn.variables;
by nif; 
run;

data allv1; 
merge fn.all fn.dxa fn.v1be fn.v1fe fn.variables;
by nif; 
run;

data fn.allv1; 
set allv1; 
run;

************************************************
************************************************
************************************************
******** v1 recodes and analysis ********
************************************************
************************************************
************************************************;

data allrc; 
set fn.allv1; 
andgyn= andfatv1/gynfatv1;

if BMIEFV1WHOP>= 85
then ovob=1;
if BMIEFV1WHOP<85 then ovob=0;

/*
protein_kcal=protein_g*4;
fat_kcal=fat_g*9;
sat_fat_kcal=saturated_fat_g*9;

sum=sum (of v1de5a, v1de5b, v1de5c);
perfat=(v1de5a/sum)*100;
perlean=(v1de5b/sum)*100;
perbone=(v1de5c/sum)*100;
andper=andfatv1/perfat;
gynper=gynfatv1/perfat;
perandgyn=andper/gynper;


BP = mean(v1fe19c, v1fe19d, v1fe19e);
BPdia = mean(v1fe21c, v1fe21d, v1fe21e);
BPsys = mean(v1fe20c, v1fe20d, v1fe20e);
*/

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

if andgyn=. then delete;


run;


proc ttest data=allrc; 
class sexef; 
var AGEEFV1 POIDSEFV1  v1be1a v1be1c v1be1d1 v1be3a v1be2a BMIEFV1WHOZ andgyn; 
run;

proc freq data=allrc; 
tables andgyn*pubertyv1 /chisq; run;

proc standard data=allrc out=standardizedv1 MEAN=0 STD=1; 
var   andgyn WHREFV1 CIRCTEFV1 waist_hipv1; 
run;


proc sort data=standardizedv1; 
by sexef; run;


%macro lreg (out, name);
proc reg data= standardizedv1;
title "&name";
by sexef;
where sexef^= .;
 model &out = AGEEFV1  pubertyv1 andgyn;
run;
title;
%mend;

proc reg data=standardizedv1; 
by sexef; 
where sexef^= .;
model v1be1a= AGEEFV1  pubertyv1 CIRCTEFV1;
run;

%lreg(v1be1a, cholesterol);
%lreg(v1be1c, HDL);
%lreg(v1be1d1, LDL);
%lreg(v1be3a, insulin);
%lreg(v1be2a, glucose);

******** v1 variables ********
* waist_hipv1 waist to hip
* WHREFV1 waist to height ratio;
* CIRCTEFV1 waist circumference; 


************************************************
************************************************
************************************************
******** v2 recodes and analysis ********
************************************************
************************************************
************************************************;

proc sort data=fnv2.v2be; 
by nif; 
proc sort data=fnv2.v2fe; 
by nif; 
proc sort data=fnv2.v2_derivees;
by nif; 
run;

data allv2; 
merge fnv2.v2be fnv2.v2fe fnv2.v2_derivees; 
by nif; 
run;

proc sort data=standardizedv1; 
by nif; run;

data allv1v2; 
merge standardizedv1 allv2;
by nif; 

if v2fe27 = 1 then pubertyv2 = 0;
if v2fe27 = 2 or v2fe27 = 3 or v2fe27 = 4 then pubertyv2 =1;
if andgyn=. then delete;

run;

proc sort data=allv1v2; 
by sexef;
run;

proc reg data=allv1v2; 
by sexef; 
where sexef^= .;
model v2be1a= AGEEFV1  pubertyv2 andgyn;
run;

******** v2 variables ********
WHIREFV2 waist to hip
WHREFV2 waist to HEIGHT
CIRCTEFV2 waist circumference
andgyn 
;


