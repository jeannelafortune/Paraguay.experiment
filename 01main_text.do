/*
********************************************************************************
MAIN TEXT

REPLICATION FILE:
PAPER: Personalizing or Reminding? How to Better Incentivize Savings 
among Underbanked Individuals

DATASETS NEEDED:
 	baseline_charac_ready.dta
	main_regressions_ready.dta
	
TABLA INDEX:
Table 1: Experimental Framework (NO REPLICATION)
Table 2: Experimental Design (NO REPLICATION)
Table 3: Balance
Table 4: Impact on Savings During the Intervention Period
Table 5: Impact of Treatment Assignment on Treatment Perception
Table 6: Impact on Savings at Endline
Table 7: Impact on Other Financial Outcomes
Table 8: Impact on Savings by Financial Sophistication at Baseline
Table 9: Impact on Savings by Budget Management Coherence
*/





*-------------------------------------------------------------------------------
*working directory 
clear all
cd "C:\Users\Ruben\RA team Dropbox\RUBEN JARA\Analisis experiment\replication_file"
*texdoc do do/01main_text

*independent variables
global C_general _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito d_month_* _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog _c_13_meses_dif



	

*-------------------------------------------------------------------------------	
*Table 3
*-------------------------------------------------------------------------------
*Balance
*-------------------------------------------------------------------------------

use "data/baseline_charac_ready.dta", clear	
label var ln_ahorro_ind "Individual savings (ln)"

*generate data
foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total  _c_ingreso_gasto _c_8_gastos_total savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}
	if abs(el(e(sd),1,1))>100{
		local sd_`var': di %12.0fc el(e(sd),1,1)
		}
	else{
		local sd_`var': di %12.2fc el(e(sd),1,1)
		}
		
*regression
	qui reg `var' S P SxP , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
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
	test S P SxP
	local F_`var': di %12.2fc r(F)
	local s_F_`var'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 

*combine regression coefficients
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
preserve
clear
set obs 1
gen n=1 
save test_f, replace 

local i=0
use "data/baseline_charac_ready.dta", clear
	
replace ln_ahorro_ind=. if _c_11_ahorroind==.
foreach var of varlist _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total  _c_ingreso_gasto _c_8_gastos_total savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {
keep `var' S P SxP 
rename `var' outcome
local i=`i'+1
gen dum`i'=1
rename S S_`i'
rename P P_`i'
rename SxP SxP_`i'
append using test_f
save test_f, replace
restore
preserve 
}

use test_f, clear
drop if n==1
drop n

forvalues i=1/14{
replace dum`i'=0 if dum`i'==.
replace S_`i'=0 if S_`i'==.
replace P_`i'=0 if P_`i'==.
replace SxP_`i'=0 if SxP_`i'==.
}

reg outcome dum* S_* P_* SxP_*, robust nocons
test S_1 S_2 S_3 S_4 S_5 S_6 S_7 S_8 S_9 S_10 S_11 S_12 S_13 S_14

local F_S: di %12.2fc r(F)
display `F_S'	

test P_1 P_2 P_3 P_4 P_5 P_6 P_7 P_8 P_9 P_10 P_11 P_12 P_13 P_14
local F_P: di %12.2fc r(F)
display `F_P'

test SxP_1 SxP_2 SxP_3 SxP_4 SxP_5 SxP_6 SxP_7 SxP_8 SxP_9 SxP_10 SxP_11 SxP_12 SxP_13 SxP_14
local F_SP: di %12.2fc r(F)
display `F_SP'

*generate Table 3
texdoc init tables\table_3.tex, replace
tex \begin{table}[h]
tex \caption{"Balance"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}ccccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{C. Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{Both}  	& Joint F-test & \multicolumn{1}{c}{Agg. Effect}	& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {
	tex   `:var label `var'' &	`mean_`var'' & `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `F_`var''`s_F_`var'' & `b_`var'_Agg'`s_`var'_Agg'		& `N_`var''					\\
	tex               			&	(`sd_`var'') & (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			&  & (`se_`var'_Agg')					&							\\
	}
	tex F-test: &  &  `F_S' & `F_P' & `F_SP' &  & \\
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close

estimates clear





*-------------------------------------------------------------------------------	
*Table 4 and Table 6
*-------------------------------------------------------------------------------
*Impact on Savings During the Intervention Period
*Impact on Savings at Endline
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*generate data with baseline variables
foreach var in dumB_11 lnB_11 household_expenses div_ves_o_expenses {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression		
	reg   `var' S P SxP $C_general `var'_lb, robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
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

*combine regression coefficients
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

*generate data without baseline variables
foreach var in ahorro_suma_meses dum_pct1_D_13 lnD_13 dumB_10 lnB_10 dum_pct1_B_11 {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}		

*regression
	reg   `var' S P SxP $C_general , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
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

*combine regression coefficients
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

*generate Table 4 and Table 6
texdoc init tables\table_4and6.tex, replace
tex \begin{table}[h]
tex \caption{"Impact on Savings During the Intervention Period and at Endline"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}cccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{C. Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{Both}  	& \multicolumn{1}{c}{Agg.}		& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	tex \multicolumn{7}{c}{"Impact on Savings During the Intervention Period"} \\
	foreach var in ahorro_suma_meses lnD_13 dum_pct1_D_13 {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'	&	`N_`var''				\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')				& 							\\
	}
	tex \\
	tex \multicolumn{7}{c}{"Impact on Savings at Endline"} \\
	foreach var in dumB_11 lnB_11 dum_pct1_B_11 dumB_10 lnB_10 household_expenses div_ves_o_expenses {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'	&	`N_`var''				\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')				& 							\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close





*-------------------------------------------------------------------------------	
*Table 5
*-------------------------------------------------------------------------------
*Impact of Treatment Assignment on Treatment Perception
*-------------------------------------------------------------------------------

*generate data
foreach var in D_3 D_4_1 D_4_2 D_4_3 D_4_5 D_6 dumD_71 dumD_72 {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg  `var' S P SxP $C_general , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
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

*combine regression coefficients
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

*generate Table 5
texdoc init tables\table_5.tex, replace
tex \begin{table}[h]
tex \caption{"Impact of Treatment Assignment on Treatment Perception"}
tex \begin{center}
	tex \begin{tabular}{p{9cm}cccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{C. Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{Both}  	& \multicolumn{1}{c}{Agg. Effect}	& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule \\
	tex \multicolumn{5}{l}{Individual remembers receiving SMS...} \\
	foreach var in D_6 dumD_71 dumD_72 {
	tex		`:var label `var''	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	&	`b_`var'_Agg'`s_`var'_Agg'		& `N_`var''					\\
	tex							&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			&	(`se_`var'_Agg')				&							\\
	}
	tex \\
	tex \multicolumn{5}{l}{Individual remembers...} \\
	foreach var in D_3 D_4_1 D_4_2 D_4_3 D_4_5 {
	tex		`:var label `var''	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	&	`b_`var'_Agg'`s_`var'_Agg'		& `N_`var''					\\
	tex							&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			&	(`se_`var'_Agg')				&							\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close





*-------------------------------------------------------------------------------	
*Table 7
*-------------------------------------------------------------------------------
*Impact on Other Financial Outcomes
*-------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
*Panel ABC
*-------------------------------------------------------------------------------

*independent variables
global Covariates _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito d_month_* _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog

*generate data
foreach var in B_13_num_mon dumB_17 index_endline C_11 dumC_1 C_3_montototalaprob dumC_3_nopag {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg `var' S P SxP $Covariates `var'_lb , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
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

*combine regression coefficients
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

*generate Table 7
texdoc init tables\table_7abc.tex, replace
tex \begin{table}[h]
tex \caption{"Impact on Other Financial Outcomes"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}cccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{C. Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{Both}  	& \multicolumn{1}{c}{Agg. Effect}	& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	tex
	tex 		       			&	\multicolumn{6}{c}{Panel A: Credit market}																																					\\
	foreach var in dumC_1 C_3_montototalaprob dumC_3_nopag {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'		& `N_`var''					\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')					&							\\
	}
	tex 		       			&	\multicolumn{6}{c}{Panel B: Financial resilience}																																					\\
	foreach var in B_13_num_mon dumB_17 {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'		& `N_`var''					\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')					&							\\
	}
	tex
	tex 		       			&	\multicolumn{6}{c}{Panel C: Financial well-being}																																					\\
	foreach var in index_endline C_11 {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'		& `N_`var''					\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')					&							\\
	}
	tex
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close


*-------------------------------------------------------------------------------
*Panel D: Outcomes from Credit Bureau
*-------------------------------------------------------------------------------
	
*generate data without baseline variables
foreach var in S_After new_score_2020 {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg   `var' S P SxP $C_general  , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
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

*combine regression coefficients
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

*generate data with baseline variables
foreach var in M_tau0 A_tau0 {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg   `var' S P SxP $C_general `var'_lb , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
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

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_`t'_Agg=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
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

*generate Table 7 

label var S_After "Requests per 100 days"
label var new_score_2020 "Credit score"
label var M_tau0 "Probability of having unpaid debt"
label var A_tau0 "Total unpaid debt (’000s Gs)"

texdoc init tables\table_7d.tex, replace
tex \begin{table}[h]
tex \caption{"Outcomes from Credit Bureau"}
tex \begin{center}
	tex \begin{tabular}{p{9cm}cccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{C. Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{SxP}  	& \multicolumn{1}{c}{Agg. Effect}	& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule \\
	foreach var in S_After new_score_2020 M_tau0 A_tau0 {
	tex		`:var label `var''	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	&	`b_`var'_Agg'`s_`var'_Agg'		& `N_`var''					\\
	tex							&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			&	(`se_`var'_Agg')				&							\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close





*-------------------------------------------------------------------------------	
*Table 8
*-------------------------------------------------------------------------------
*Impact on Savings by Financial Sophistication at Baseline
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Panel A: By financial literacy
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*interaction
gen gr1		= no_litt
gen gr2		= litt
gen Sx1		= S*gr1
gen Px1		= P*gr1
gen SxPx1	= SxP*gr1
gen Sx2		= S*gr2
gen Px2		= P*gr2
gen SxPx2	= SxP*gr2

*N by group
count if gr1==1 & _merge==3 
	local N_gr1: di %12.0fc r(N)
count if gr2==1 & _merge==3 
	local N_gr2: di %12.0fc r(N)
count if (gr1==1 | gr2==1) & _merge==3
	local N_all: di %12.0fc r(N)

*first set of columns
*generate data without baseline variables
foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 {

*regression
	reg   `var' S P SxP gr2 Sx2 Px2 SxPx2 $C_general , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'1=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'1: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'1: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'1: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'1: di %12.2fc _se[`x']
		}
	}
*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg1=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg1: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg1: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg1: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg1: di %12.2fc r(se)
		}
}

*generate data with baseline variables
foreach var in lnB_11 div_ves_o_expenses {

*regression
	reg   `var' S P SxP gr2 Sx2 Px2 SxPx2 $C_general `var'_lb , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'1=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'1: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'1: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'1: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'1: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg1=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg1: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg1: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg1: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg1: di %12.2fc r(se)
		}
}

*second set of columns
*generate data without baseline variables
foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 {

*regression
	reg   `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general , robust
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'2=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'2: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'2: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'2: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'2: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg2=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg2: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg2: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg2: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg2: di %12.2fc r(se)
		}
}

*generate data without baseline variables
foreach var in lnB_11 div_ves_o_expenses {

*regression
	reg   `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general `var'_lb , robust
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'2=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'2: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'2: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'2: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'2: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg2=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg2: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg2: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg2: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg2: di %12.2fc r(se)
		}
}

*generate Table 8
texdoc init tables\table_8.tex, replace
tex \begin{table}[h]
tex \caption{"Impact on Savings by Financial Sophistication at Baseline"}
tex \begin{center}
	tex \begin{tabular}{p{4cm}cccccccc}
	tex \toprule
	tex 		       			&	\multicolumn{1}{c}{Sal.}		&	\multicolumn{1}{c}{Per.}	&	\multicolumn{1}{c}{SxP}  		&	\multicolumn{1}{c}{Agg.}  		&	\multicolumn{1}{c}{Sal.}  	&	\multicolumn{1}{c}{Per.}  	&	\multicolumn{1}{c}{SxP}  		&	\multicolumn{1}{c}{Agg.}  		\\
	tex \midrule
	tex & \multicolumn{8}{c}{Panel: By financial literacy}\\
	tex 		       			&	\multicolumn{4}{c}{not litterate (N=`N_gr1')}																							&	\multicolumn{4}{c}{Litterate (N=`N_gr2')}																							\\
	foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 lnB_11 div_ves_o_expenses {
	tex   `:var label `var'' 	&	`b_`var'_S1'`s_`var'_S1'		&	`b_`var'_P1'`s_`var'_P1'	&	`b_`var'_SxP1'`s_`var'_SxP1'	&	`b_`var'_Agg1'`s_`var'_Agg1'	&	`b_`var'_S2'`s_`var'_S2'	&	`b_`var'_P2'`s_`var'_P2'	&	`b_`var'_SxP2'`s_`var'_SxP2'	&	`b_`var'_Agg2'`s_`var'_Agg2'	\\
	tex               			&	(`se_`var'_S1')       			&	(`se_`var'_P1')				&	(`se_`var'_SxP1')				&	(`se_`var'_Agg1')				&	(`se_`var'_S2')       		&	(`se_`var'_P2')				&	(`se_`var'_SxP2')				&	(`se_`var'_Agg2')				\\
	}
texdoc close


*-------------------------------------------------------------------------------
*Panel B: By baseline savings behavior
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*interaction
gen gr1		= 1-savings
gen gr2		= savings
gen Sx1		= S*gr1
gen Px1		= P*gr1
gen SxPx1	= SxP*gr1
gen Sx2		= S*gr2
gen Px2		= P*gr2
gen SxPx2	= SxP*gr2


*N by group
count if gr1==1 & _merge==3 
	local N_gr1: di %12.0fc r(N)
count if gr2==1 & _merge==3 
	local N_gr2: di %12.0fc r(N)
count if (gr1==1 | gr2==1) & _merge==3
	local N_all: di %12.0fc r(N)
	
*first set of columns
*generate data without baseline variables 
foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 {

*regression
	reg   `var' S P SxP gr2 Sx2 Px2 SxPx2 $C_general , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'1=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'1: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'1: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'1: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'1: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg1=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg1: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg1: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg1: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg1: di %12.2fc r(se)
		}
}

*generate data with baseline variables 
foreach var in lnB_11 div_ves_o_expenses {

*regression
	reg   `var' S P SxP gr2 Sx2 Px2 SxPx2 $C_general `var'_lb , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'1=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'1: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'1: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'1: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'1: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg1=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg1: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg1: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg1: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg1: di %12.2fc r(se)
		}
}

*second set of columns
*generate data without baseline variables
foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 {

*regression
	reg   `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general , robust
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'2=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'2: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'2: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'2: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'2: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg2=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg2: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg2: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg2: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg2: di %12.2fc r(se)
		}
}

*generate data with baseline variables
foreach var in lnB_11 div_ves_o_expenses {

*regression
	reg   `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general `var'_lb , robust
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'2=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'2: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'2: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'2: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'2: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg2=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg2: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg2: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg2: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg2: di %12.2fc r(se)
		}
}

*generate Table 8
texdoc init tables\table_8.tex, append
	tex & \multicolumn{8}{c}{Panel: By baseline savings behavior} \\
	tex 		       			&	\multicolumn{4}{c}{No savings (N=`N_gr1')}																								&	\multicolumn{4}{c}{Positive savings (N=`N_gr2')}																					\\
	foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 lnB_11 div_ves_o_expenses {
	tex   `:var label `var'' 	&	`b_`var'_S1'`s_`var'_S1'		&	`b_`var'_P1'`s_`var'_P1'	&	`b_`var'_SxP1'`s_`var'_SxP1'	&	`b_`var'_Agg1'`s_`var'_Agg1'	&	`b_`var'_S2'`s_`var'_S2'	&	`b_`var'_P2'`s_`var'_P2'	&	`b_`var'_SxP2'`s_`var'_SxP2'	&	`b_`var'_Agg2'`s_`var'_Agg2'	\\
	tex               			&	(`se_`var'_S1')       			&	(`se_`var'_P1')				&	(`se_`var'_SxP1')				&	(`se_`var'_Agg1')				&	(`se_`var'_S2')       		&	(`se_`var'_P2')				&	(`se_`var'_SxP2')				&	(`se_`var'_Agg2')				\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close





*-------------------------------------------------------------------------------	
*Table 9
*-------------------------------------------------------------------------------
*Impact on Savings by Budget Management Coherence
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Panel A: By discrepancy between savings and budget balance
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*interaction
gen gr1		= discrepancy
gen gr2		= 1-discrepancy
gen Sx1		= S*gr1
gen Px1		= P*gr1
gen SxPx1	= SxP*gr1
gen Sx2		= S*gr2
gen Px2		= P*gr2
gen SxPx2	= SxP*gr2

*N by group
count if gr1==1 & _merge==3 
	local N_gr1: di %12.0fc r(N)
count if gr2==1 & _merge==3 
	local N_gr2: di %12.0fc r(N)
count if (gr1==1 | gr2==1) & _merge==3 
	local N_all: di %12.0fc r(N)
	
*first set of columns
*generate data without baseline variables
foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 {

*regression
	reg   `var' S P SxP gr2 Sx2 Px2 SxPx2 $C_general , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'1=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'1: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'1: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'1: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'1: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg1=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg1: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg1: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg1: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg1: di %12.2fc r(se)
		}
}

*generate data with baseline variables
foreach var in lnB_11 div_ves_o_expenses {

*regression
	reg   `var' S P SxP gr2 Sx2 Px2 SxPx2 $C_general `var'_lb , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'1=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'1: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'1: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'1: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'1: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg1=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg1: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg1: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg1: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg1: di %12.2fc r(se)
		}
}

*second set of columns
*generate data without baseline variables
foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 {

*regression
	reg   `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general  , robust
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'2=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'2: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'2: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'2: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'2: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg2=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg2: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg2: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg2: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg2: di %12.2fc r(se)
		}
}

*generate data with baseline variables
foreach var in lnB_11 div_ves_o_expenses {

*regression
	reg   `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general `var'_lb , robust
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'2=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'2: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'2: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'2: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'2: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg2=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg2: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg2: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg2: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg2: di %12.2fc r(se)
		}
}

*generate Table 9 
texdoc init tables\table_9.tex, replace
tex \begin{table}[h]
tex \caption{"Impact on Savings by Budget Management Coherence"}
tex \begin{center}
	tex \begin{tabular}{p{4cm}cccccccc}
	tex \toprule
	tex 		       			&	\multicolumn{1}{c}{Sal.}		&	\multicolumn{1}{c}{Per.}	&	\multicolumn{1}{c}{SxP}  		&	\multicolumn{1}{c}{Agg.}  		&	\multicolumn{1}{c}{Sal.}  	&	\multicolumn{1}{c}{Per.}  	&	\multicolumn{1}{c}{SxP}  		&	\multicolumn{1}{c}{Agg.}  		\\
	tex \midrule
	tex & \multicolumn{8}{c}{Panel: By discrepancy between savings and budget balance} \\
	tex 		       			&	\multicolumn{4}{c}{Large discrepancy (N=`N_gr1')}																								&	\multicolumn{4}{c}{small discrepancy (N=`N_gr2')}																					\\
	foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 lnB_11 div_ves_o_expenses {
	tex   `:var label `var'' 	&	`b_`var'_S1'`s_`var'_S1'		&	`b_`var'_P1'`s_`var'_P1'	&	`b_`var'_SxP1'`s_`var'_SxP1'	&	`b_`var'_Agg1'`s_`var'_Agg1'	&	`b_`var'_S2'`s_`var'_S2'	&	`b_`var'_P2'`s_`var'_P2'	&	`b_`var'_SxP2'`s_`var'_SxP2'	&	`b_`var'_Agg2'`s_`var'_Agg2'	\\
	tex               			&	(`se_`var'_S1')       			&	(`se_`var'_P1')				&	(`se_`var'_SxP1')				&	(`se_`var'_Agg1')				&	(`se_`var'_S2')       		&	(`se_`var'_P2')				&	(`se_`var'_SxP2')				&	(`se_`var'_Agg2')				\\
	}
texdoc close




*-------------------------------------------------------------------------------
*Panel B: Took loan in year before baseline
*-------------------------------------------------------------------------------

clear all
use "data/main_regressions_ready.dta", clear

*br _d_2_7_cuotas_1 Ammount Loan if _lb_key=="uuid:8da3895b-27e9-4d35-93a9-bec1ea556cbe" | _lb_key=="uuid:bc2a800a-a119-402a-99bc-12a844e904ef" | _lb_key=="uuid:d14de025-0c8f-4c18-87b4-65b52cc222ef" | _lb_key=="uuid:ed73c02d-5f60-49d4-890b-a565aafbdef1"

*interaction
gen gr1		= Loan
gen gr2		= 1-Loan
gen Sx1		= S*gr1
gen Px1		= P*gr1
gen SxPx1	= SxP*gr1
gen Sx2		= S*gr2
gen Px2		= P*gr2
gen SxPx2	= SxP*gr2

*N by group
count if gr1==1 & _merge==3
	local N_gr1: di %12.0fc r(N)
count if gr2==1 & _merge==3 
	local N_gr2: di %12.0fc r(N)
count if (gr1==1 | gr2==1) & _merge==3 
	local N_all: di %12.0fc r(N)
	
*first set of columns
*generate data without baseline variables
foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 {

*regression
	reg   `var' S P SxP gr2 Sx2 Px2 SxPx2 $C_general , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'1=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'1: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'1: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'1: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'1: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg1=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg1: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg1: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg1: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg1: di %12.2fc r(se)
		}
}

*generate data with baseline variables
foreach var in lnB_11 div_ves_o_expenses {

*regression
	reg   `var' S P SxP gr2 Sx2 Px2 SxPx2 $C_general `var'_lb , robust
	local N_`var': di %12.0fc e(N)
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'1=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'1: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'1: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'1: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'1: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg1=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg1: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg1: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg1: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg1: di %12.2fc r(se)
		}
}

*second set of columns
*generate data without baseline variables
foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 {

*regression
	reg   `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general , robust
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'2=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'2: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'2: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'2: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'2: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg2=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg2: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg2: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg2: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg2: di %12.2fc r(se)
		}
}

*generate data with baseline variables 
foreach var in lnB_11 div_ves_o_expenses {

*regression
	reg   `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general `var'_lb , robust
	foreach x in S P SxP {
	test `x'
	local s_`var'_`x'2=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[`x'])>100{
		local b_`var'_`x'2: di %12.0fc _b[`x']
		}
	else{
		local b_`var'_`x'2: di %12.2fc _b[`x']
		}
	if abs(_se[`x'])>100{
		local se_`var'_`x'2: di %12.0fc _se[`x']
		}
	else{
		local se_`var'_`x'2: di %12.2fc _se[`x']
		}
	}

*combine regression coefficients
	lincom _b[S]+_b[P]+_b[SxP]
	local t_value: di abs(r(estimate)/r(se))
	local s_`var'_Agg2=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
	if abs(r(estimate))>100{
		local b_`var'_Agg2: di %12.0fc r(estimate)
		}
	else{
		local b_`var'_Agg2: di %12.2fc r(estimate)
		}
	if abs(r(se))>100{
		local se_`var'_Agg2: di %12.0fc r(se)
		}
	else{
		local se_`var'_Agg2: di %12.2fc r(se)
		}
}

*generate Table 9
texdoc init tables\table_9.tex, append
	tex 		       			&	\multicolumn{8}{c}{Panel B: Took loan in year before baseline.}																																																						\\
	tex 		       			&	\multicolumn{4}{c}{Yes (N=`N_gr1')}																										&	\multicolumn{4}{c}{No (N=`N_gr2')}																									\\
	foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 lnB_11 div_ves_o_expenses {
	tex   `:var label `var'' 	&	`b_`var'_S1'`s_`var'_S1'		&	`b_`var'_P1'`s_`var'_P1'	&	`b_`var'_SxP1'`s_`var'_SxP1'	&	`b_`var'_Agg1'`s_`var'_Agg1'	&	`b_`var'_S2'`s_`var'_S2'	&	`b_`var'_P2'`s_`var'_P2'	&	`b_`var'_SxP2'`s_`var'_SxP2'	&	`b_`var'_Agg2'`s_`var'_Agg2'	\\
	tex               			&	(`se_`var'_S1')       			&	(`se_`var'_P1')				&	(`se_`var'_SxP1')				&	(`se_`var'_Agg1')				&	(`se_`var'_S2')       		&	(`se_`var'_P2')				&	(`se_`var'_SxP2')				&	(`se_`var'_Agg2')				\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close