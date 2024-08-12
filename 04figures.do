/*
********************************************************************************
REPLICATION FILE:
PAPER: Personalizing or Reminding? How to Better Incentivize Savings 
among Underbanked Individuals

DATASETS NEEDED:
 	baseline_charac_ready.dta???????
	main_regressions_ready.dta???????
	
FIGURES:

Figure 1: Savings Target by Initial Budget Balance
Figure 2: Impact of Salience, Personalization and Their Combination on Whether 
Individuals Saved During Each Month of Intervention
Figure 3: Impact of Combined Treatments on Whether Individuals Saved During Each 
Month of Intervention (As Compared to the Control Group)
Figure 4: Impact on Amount Saved During the Intervention
Figure 5: Impact of Treatments on Savings Target in Endline

Figure B1: Impact of Treatments on Whether Individuals Saved During Each Month 
of Intervention (only T1-T4)
Figure B2: Impact on Amount Saved During the Intervention (only T1-T4)
Figure B3: Impact of Treatments on Savings Target In Endline (only T1-T4) 
*/



*-------------------------------------------------------------------------------
*Starting:
clear all
cd "C:\Users\Ruben\RA team Dropbox\RUBEN JARA\Analisis experiment\replication_file"

*Independent variables for regressions:
global C_general _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito d_month_* _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog _c_13_meses_dif

global C_general_withoutmonths _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog _c_13_meses_dif

	
	
	
	
*-------------------------------------------------------------------------------	
*Figure 1
*-------------------------------------------------------------------------------
*Savings Target by Initial Budget Balance
*-------------------------------------------------------------------------------
clear all
use "data/base.dta", clear

*Generate
gen		goal = .
replace goal = Tratamiento_3_obbjetivo	if Tratamiento==3
replace goal = T4A_Monto				if Tratamiento==4
replace goal = T6_Ahorro_B1 | T6_Ahorro_A	if Tratamiento==6
gen		posi = 0 
replace posi = 1 if _c_ingreso_gasto>0

*Label
label variable posi "Positive balance dummy"
label define posi 0 "0 or less balance" 1 "positive balance"
label values posi posi
replace goal=goal/1000
label var goal "Savings goals in 000s of Guaranies"

*Graph
twoway (histogram goal if goal<=1000 & posi==0, width(50) color(gray)) ///
       (histogram goal if goal<=1000 & posi==1, width(50) ///
	   fcolor(none) lcolor(black)),  legend(order(1 "0 or less balance" 2 "Positive balance" ) pos(2) ring(0) col(1)) scheme(s2mono) 
graph export "figures/fig_1.pdf", as(pdf) replace





*-------------------------------------------------------------------------------	
*Figure 2
*-------------------------------------------------------------------------------
/*Impact of Salience, Personalization and Their Combination on Whether 
Individuals Saved During Each Month of Intervention*/
*-------------------------------------------------------------------------------

clear all
use "data/base.dta", clear

*use "$datadir/base.dta", clear

*Global controls for regression	
global C_general _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito d_month_* _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog _c_13_meses_dif

*Regressions
foreach var in ahorro_1_mes ahorro_2_mes ahorro_3_mes ahorro_4_mes ahorro_5_mes ahorro_6_mes ahorro_7_mes {
	reg   `var' S P SxP $C_general , robust cluster(_3_5_barrio)
foreach x in S P SxP {
	test `x'
	local N_`var'_`x': di %12.0fc e(N)
	local s_`var'_`x'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x': di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x': di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x': di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x': di %12.2fc _se[`x']
		}
	}
lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))	
	local s_`var'_Agg=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg: di %12.2fc r(se)
		}
}

*Matrices for graphs
foreach x in S P SxP {
matrix `x'		= J(1,7,.)
	forvalues j = 1/7 {
		 matrix `x'[1,`j']= `b_ahorro_`j'_mes_`x''
	}
matrix `x'_ci		= J(2,7,.)
	forvalues j = 1/7 {
		 matrix `x'_ci[1,`j']= `b_ahorro_`j'_mes_`x'' - 1.645*`se_ahorro_`j'_mes_`x''
	}
	forvalues j = 1/7 {
		 matrix `x'_ci[2,`j']= `b_ahorro_`j'_mes_`x'' + 1.645*`se_ahorro_`j'_mes_`x''
	}
matrix colnames `x'		= First Second Third Fourth Fifth Sixth Seventh
matrix rownames `x'_ci	= ll90 ul90
matrix list `x'
matrix list `x'_ci
}

*Graph
coefplot (matrix(S), ci(S_ci) label(Salience) msymbol(S) ciopts(lpattern(dot) color(black)) offset(0.07)) (matrix(P), ci(P_ci) label(Personalization) msymbol(D) offset(-0.07)) (matrix(SxP), ci(SxP_ci) label(Interaction) msymbol(C) ciopts(lpattern(dash)) offset(0)), vertical yline(0) legend(rows(1)) byopts(Title(Effects of treatment)) scheme(s2mono)
graph export "figures/fig_2.pdf", as(pdf) replace





*-------------------------------------------------------------------------------	
*Figure 3
*-------------------------------------------------------------------------------
/*Impact of Combined Treatments on Whether Individuals Saved During Each Month 
of Intervention (As Compared to the Control Group)*/
*-------------------------------------------------------------------------------

clear all
use "data\base.dta", clear

*Global controls for regression 	
global C_general _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito d_month_* _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog _c_13_meses_dif

*All treatments
gen SO=0
replace SO=1 if Tratamiento==2
gen PO=0
replace PO=1 if Tratamiento==3
gen SP=0
replace SP=1 if Tratamiento==4
gen TG=0
replace TG=1 if Tratamiento==5
gen PS=0
replace PS=1 if Tratamiento==6

*Regressions
foreach var in ahorro_1_mes ahorro_2_mes ahorro_3_mes ahorro_4_mes ahorro_5_mes ahorro_6_mes ahorro_7_mes {
	reg   `var' SO PO SP TG PS $C_general , robust cluster(_3_5_barrio)
foreach x in SO PO SP TG PS {
	test `x'
	local N_`var'_`x': di %12.0fc e(N)
	local s_`var'_`x'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x': di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x': di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x': di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x': di %12.2fc _se[`x']
		}
	}
}

*Matrices for graphs
foreach x in SO PO SP TG PS {
matrix `x'		= J(1,7,.)
	forvalues j = 1/7 {
		 matrix `x'[1,`j']= `b_ahorro_`j'_mes_`x''
	}
matrix `x'_ci		= J(2,7,.)
	forvalues j = 1/7 {
		 matrix `x'_ci[1,`j']= `b_ahorro_`j'_mes_`x'' - 1.645*`se_ahorro_`j'_mes_`x''
	}
	forvalues j = 1/7 {
		 matrix `x'_ci[2,`j']= `b_ahorro_`j'_mes_`x'' + 1.645*`se_ahorro_`j'_mes_`x''
	}
matrix colnames `x'		= First Second Third Fourth Fifth Sixth Seventh
matrix rownames `x'_ci	= ll90 ul90
matrix list `x'
matrix list `x'_ci
}

*Graph
coefplot (matrix(SP), ci(SP_ci) label(Basic) msymbol(C) offset(0)) (matrix(TG), ci(TG_ci) label(Tangible) msymbol(triangle) ciopts(lpattern(dash_dot)) offset(0.12)) (matrix(PS), ci(PS_ci) label(Precautionary) msymbol(X) ciopts(lpattern(dash_dot_dot)) offset(0.24)), vertical yline(0) legend(rows(1)) byopts(Title(Effects of treatment)) scheme(s2mono)
graph export "figures/fig_3.pdf", as(pdf) replace





*-------------------------------------------------------------------------------	
*Figure 4
*-------------------------------------------------------------------------------
*Impact on Amount Saved During the Intervention
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta"

reg ahorro_suma_meses S P SxP $C_general, robust

*Categorize
gen ahorro_cat=0
replace ahorro_cat=1 if D_13>0 & D_13<=100000
replace ahorro_cat=2 if D_13>100000 & D_13<=200000
replace ahorro_cat=3 if D_13>200000 & D_13<=300000
replace ahorro_cat=4 if D_13>300000 & D_13<=400000
replace ahorro_cat=5 if D_13>400000

*Main data for the graph
gen Tratamiento_ag=Tratamiento
replace Tratamiento_ag=4 if Tratamiento==5 | Tratamiento==6 
tab ahorro_cat Tratamiento_ag if e(sample)==1, col 

*Significance
gen ahorro_cat0=(D_13==0)
gen ahorro_cat1=(D_13>0 & D_13<=100000)
gen ahorro_cat2=(D_13>100000 & D_13<=200000)
gen ahorro_cat3=(D_13>200000 & D_13<=300000)
gen ahorro_cat4=(D_13>300000 & D_13<=400000)
gen ahorro_cat5=(D_13>400000)

forval i=0/5{
replace ahorro_cat`i'=. if D_13==.
}

forval i=0/5{
reg ahorro_cat`i' S P SxP, robust
lincom _b[S]+_b[P]+_b[SxP]
di abs(r(estimate)/r(se))
}

*Only the aggregate in 0 (5%) and 5 (1%) is significant.





*-------------------------------------------------------------------------------	
*Figure 5
*-------------------------------------------------------------------------------
*Impact of Treatments on Savings Target in Endline
*-------------------------------------------------------------------------------

reg D_1 S P SxP $C_general, robust
lincom _b[S]+_b[P]+_b[SxP]

reg lnD_2 S P SxP $C_general, robust
lincom _b[S]+_b[P]+_b[SxP]

reg dum_pct1_D_2 S P SxP $C_general, robust
lincom _b[S]+_b[P]+_b[SxP]





*-------------------------------------------------------------------------------	
*Figure B1
*-------------------------------------------------------------------------------
/*Impact of Treatments on Whether Individuals Saved During Each Month of 
Intervention (only T1-T4)*/
*-------------------------------------------------------------------------------

clear all
use "data/base.dta", clear

drop if Tratamiento>4
*use "$datadir/base.dta", clear

*Global controls for regression	
global C_general _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito d_month_* _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog _c_13_meses_dif

*Regressions
foreach var in ahorro_1_mes ahorro_2_mes ahorro_3_mes ahorro_4_mes ahorro_5_mes ahorro_6_mes ahorro_7_mes {
	reg   `var' S P SxP $C_general , robust cluster(_3_5_barrio)
foreach x in S P SxP {
	test `x'
	local N_`var'_`x': di %12.0fc e(N)
	local s_`var'_`x'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x': di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x': di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x': di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x': di %12.2fc _se[`x']
		}
	}
lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))	
	local s_`var'_Agg=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg: di %12.2fc r(se)
		}
}

*Matrices for graphs
foreach x in S P SxP {
matrix `x'		= J(1,7,.)
	forvalues j = 1/7 {
		 matrix `x'[1,`j']= `b_ahorro_`j'_mes_`x''
	}
matrix `x'_ci		= J(2,7,.)
	forvalues j = 1/7 {
		 matrix `x'_ci[1,`j']= `b_ahorro_`j'_mes_`x'' - 1.645*`se_ahorro_`j'_mes_`x''
	}
	forvalues j = 1/7 {
		 matrix `x'_ci[2,`j']= `b_ahorro_`j'_mes_`x'' + 1.645*`se_ahorro_`j'_mes_`x''
	}
matrix colnames `x'		= First Second Third Fourth Fifth Sixth Seventh
matrix rownames `x'_ci	= ll90 ul90
matrix list `x'
matrix list `x'_ci
}

*Graph
coefplot (matrix(S), ci(S_ci) label(Salience) msymbol(S) ciopts(lpattern(dot) color(black)) offset(0.07)) (matrix(P), ci(P_ci) label(Personalization) msymbol(D) offset(-0.07)) (matrix(SxP), ci(SxP_ci) label(Interaction) msymbol(C) ciopts(lpattern(dash)) offset(0)), vertical yline(0) legend(rows(1)) byopts(Title(Effects of treatment)) scheme(s2mono)
graph export "figures/fig_b1.pdf", as(pdf) replace





*-------------------------------------------------------------------------------	
*Figure B2
*-------------------------------------------------------------------------------
*Impact on Amount Saved During the Intervention (only T1-T4)
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta"

reg ahorro_suma_meses S P SxP $C_general if Tratamiento<5, robust

*Categorize
gen ahorro_cat=0
replace ahorro_cat=1 if D_13>0 & D_13<=100000
replace ahorro_cat=2 if D_13>100000 & D_13<=200000
replace ahorro_cat=3 if D_13>200000 & D_13<=300000
replace ahorro_cat=4 if D_13>300000 & D_13<=400000
replace ahorro_cat=5 if D_13>400000

*Main data for the graph
tab ahorro_cat Tratamiento if e(sample)==1, col 

*Significance
gen ahorro_cat0=(D_13==0)
gen ahorro_cat1=(D_13>0 & D_13<=100000)
gen ahorro_cat2=(D_13>100000 & D_13<=200000)
gen ahorro_cat3=(D_13>200000 & D_13<=300000)
gen ahorro_cat4=(D_13>300000 & D_13<=400000)
gen ahorro_cat5=(D_13>400000)

forval i=0/5{
replace ahorro_cat`i'=. if D_13==.
}

forval i=0/5{
reg ahorro_cat`i' S P SxP if Tratamiento<5, robust
lincom _b[S]+_b[P]+_b[SxP]
di abs(r(estimate)/r(se))
}

*Only the aggregate in 0 (5%) and 5 (5%) is significant.





*-------------------------------------------------------------------------------	
*Figure B3
*-------------------------------------------------------------------------------
*Impact of Treatments on Savings Target In Endline (only T1-T4)
*-------------------------------------------------------------------------------

reg D_1 S P SxP $C_general if Tratamiento<5, robust
lincom _b[S]+_b[P]+_b[SxP]

reg lnD_2 S P SxP $C_general if Tratamiento<5, robust
lincom _b[S]+_b[P]+_b[SxP]

reg dum_pct1_D_2 S P SxP $C_general if Tratamiento<5, robust
lincom _b[S]+_b[P]+_b[SxP]
