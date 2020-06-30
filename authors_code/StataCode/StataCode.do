**************************************************************************************
* General Sep-up
**************************************************************************************

clear
set more off

**************************************************************************************
* User needs to change XX to appropriate location
**************************************************************************************

global data  "XX:\20100346_data\Data"
cd "XX:\20100346_data\Data"

************************************************************************************
* Export data for matlab estimation
************************************************************************************

use $data\master_data, replace
sort S2 Period
keep e1
outsheet using "$data\e1.csv", replace

use $data\master_data, clear
sort S2 Period
keep e2
outsheet using "$data\e2.csv", replace

use $data\master_data, clear
sort S2 Period
keep prize
outsheet using "$data\prize.csv", replace

use $data\master_data, clear
sort S2 Period
keep S1
outsheet using "$data\S1.csv", replace

use $data\master_data, clear
sort S2 Period
keep S2
outsheet using "$data\S2.csv", replace


************************************************************************************
* Table 1
************************************************************************************

use $data\master_data,clear
drop if Sub==302
table Period, c(mean e1 sd e1 mean e2 sd e2) 
table Period, c(min e1 min e2 max e1 max e2)

************************************************************************************
* Reduced form modeling with 59 Second Movers 
************************************************************************************

use $data\master_data, clear
drop if Sub==302

************************************************************************************
* Random effects model (Pref. Sample in Table 2)
************************************************************************************

* With interaction term (Preferred Specification)
xtreg e2 e1 prize E1timesPrize TT*, i(Sub) re 
est sto esRE1

* Remove all controls for prize [Subject to simultaneity as e1 and e2 are both affected by prize]
xtreg e2 e1 TT*,i(Sub) re 
est sto esRE2

************************************************************************************
* Fixed effects model
************************************************************************************

* With interaction term (Preferred Specification)
xtreg e2 e1 prize E1timesPrize TT*, i(Sub) fe 
est sto esFE1

* Remove all controls for prize [Subject to simultaneity as e1 and e2 are both affected by prize]
xtreg e2 e1 TT*,i(Sub) fe 
est sto esFE2

************************************************************************************
* Hausman test for Random v. Fixed effects model
************************************************************************************

hausman esFE1 esRE1
hausman esFE2 esRE2

************************************************************************************
* Reduced form modeling with 60 Second Movers
************************************************************************************

use $data\master_data, clear

************************************************************************************
* Random effects model (Full Sample in Table 2)
************************************************************************************

* With interaction term (Preferred Specification)
xtreg e2 e1 prize E1timesPrize TT*, i(Sub) re 
est sto esRE1

* Remove all controls for prize [Subject to simultaneity as e1 and e2 are both affected by prize]
xtreg e2 e1 TT*,i(Sub) re 
est sto esRE2

************************************************************************************
* Fixed effects model
************************************************************************************

* With interaction term (Preferred Specification)
xtreg e2 e1 prize E1timesPrize TT*, i(Sub) fe 
est sto esFE1

* Remove all controls for prize [Subject to simultaneity as e1 and e2 are both affected by prize]
xtreg e2 e1 TT*,i(Sub) fe 
est sto esFE2

************************************************************************************
* Hausman test for Random v. Fixed effects model
************************************************************************************

hausman esFE1 esRE1
hausman esFE2 esRE2

*************************************************************************************************
* Disapointment coefficients vary over rounds (1st half/2nd half) - test for confusion+learning
*************************************************************************************************

use $data\master_data, clear
drop if Sub==302

ge i_FH=E1timesPrize if Period<6
replace i_FH=0 if i_FH==.

ge i_SH=E1timesPrize if Period>=6
replace i_SH=0 if i_SH==.

ge e1_FH=e1 if Period<6
replace e1_FH=0 if e1_FH==.

ge e1_SH=e1 if Period>=6
replace e1_SH=0 if e1_SH==.

xtreg e2 e1_* i_* prize TT*, i(Sub) re 

* Joint test (accumulate restrictions) 
test i_SH==i_FH
test e1_FH==e1_SH, ac

*************************************************************************************************
* remove low/high e1 values - test for probability weighting
*************************************************************************************************

use $data\master_data, clear
drop if Sub==302

* Set seed to keep tie breaks the same
set seed 273498273
ge rr=uniform()
sort rr

sort Period e1,stable
bys Period: gen nn=_n

ge e1_Le1=e1 if nn<=30
replace e1_Le1=0 if e1_Le1==.

ge e1_He1=e1 if nn>30
replace e1_He1=0 if e1_He1==.

ge i_Le1=E1timesPrize if nn<=30
replace i_Le1=0 if i_Le1==.

ge i_He1=E1timesPrize if nn>30
replace i_He1=0 if i_He1==.

xtreg e2 e1_Le1 e1_He1 i_Le1 i_He1 prize TT*, i(Sub) re 
test i_Le1==i_He1
test e1_Le1==e1_He1,ac

*************************************************************************************************
* split 40-60 (further test for probability weighting)
*************************************************************************************************

use $data\master_data, clear
drop if Sub==302

* Set seed to keep tie breaks the same
set seed 273498273
ge rr=uniform()
sort rr

sort Period e1,stable
bys Period: gen nn=_n

ge e1_Le1=e1 if nn<=47
replace e1_Le1=0 if e1_Le1==.

ge e1_He1=e1 if nn>47
replace e1_He1=0 if e1_He1==.

ge i_Le1=E1timesPrize if nn<=47
replace i_Le1=0 if i_Le1==.

ge i_He1=E1timesPrize if nn>47
replace i_He1=0 if i_He1==.

xtreg e2 e1_Le1 e1_He1 i_Le1 i_He1 prize TT*, i(Sub) 
test i_Le1==i_He1
test e1_Le1==e1_He1,ac

*************************************************************************************************
* Look for evidence of matching/beating (which may indicate behavioral effects of peer observation)
*************************************************************************************************

use $data\master_data, clear
drop if Sub==302
ge D=.
ge nn=_n
keep if nn==1
keep D
save "$data\bs.dta",replace
set seed 342795

forvalues j=1(1)2000{
use $data\master_data, clear
drop if Sub==302
ge diff=e2-e1
bsample, cluster(Sub)

ge Below2=1 if diff==-2
replace Below2=0 if Below2==.

ge Below1=1 if diff==-1
replace Below1=0 if Below1==.

ge Equal=1 if diff==0
replace Equal=0 if Equal==.

ge Above1=1 if diff==1
replace Above1=0 if Above1==.

ge Above2=1 if diff==2
replace Above2=0 if Above2==.

ge Above3=1 if diff==3
replace Above3=0 if Above3==.

egen mBelow2=mean(Below2)
egen mBelow1=mean(Below1)
egen mEqual=mean(Equal)
egen mAbove1=mean(Above1)
egen mAbove2=mean(Above2)
egen mAbove3=mean(Above3)

ge D_B2_B1=mBelow2-mBelow1
ge D_B1_E=mBelow1-mEqual
ge D_E_A1=mEqual-mAbove1
ge D_A1_A2=mAbove1-mAbove2
ge D_A2_A3=mAbove2-mAbove3


ge Bucket1=1 if D_B2_B1>0 & D_B1_E<0
replace Bucket1=0 if Bucket1==.
ge P_Bucket1=1-Bucket1

ge Bucket2=1 if D_E_A1<0 & D_B1_E>0
replace Bucket2=0 if Bucket2==.
ge P_Bucket2=1-Bucket2

ge Bucket3=1 if D_E_A1>0 & D_A1_A2<0
replace Bucket3=0 if Bucket3==.
ge P_Bucket3=1-Bucket3

ge Bucket4=1 if D_A2_A3<0 & D_A1_A2>0
replace Bucket4=0 if Bucket4==.
ge P_Bucket4=1-Bucket4

ge nn=_n
keep if nn==1
keep P_Bucket* m*
append using "$data\bs.dta"
save "$data\bs.dta",replace
}
drop D
su

******************************************************************************
* Additional Evidence on Peer Effects - do first movers respons to effot of 
* Second mover in previous round
******************************************************************************

use $data\master_data_FM, clear
ta period, gen(TT)
tsset subject period
* previous effort * previous prize
ge i=l.othereffort*l.prize
xtreg effort l.othereffort i TT* prize l.prize, i(subject)


******************************************************************************
* Reciprocity
******************************************************************************

use $data\master_data, clear

tsset Subject Period

* detrend first mover efforts
ge prizee1=prize*e1

* remove prize and round effects from e1
reg e1 prize TT*
predict e1r, resid

bys Subject: gen mothereffort=sum(e1r)
replace mothereffort=mothereffort/Period
ge rec=l.mothereffort

xtreg  Effort e1 prizee1 prize rec TT* if Subject!=302, i(Subject) re



