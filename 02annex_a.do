/*
********************************************************************************
REPLICATION FILE:
PAPER: Personalizing or Reminding? How to Better Incentivize Savings 
among Underbanked Individuals

DATASETS NEEDED:
 	baseline_charac_ready.dta
	main_regressions_ready.dta
	
TABLA INDEX:
Table A1: Take-up Rates
Table A2: Take-up and baseline characteristics
Table A3: Minimum Detectable Effects by Outcome
Table A4: Seasonality
Table A5: Disaggregated Balance
Table A6: Attrition Test
Table A7: Balance Conditional on Answering the Endline
Table A8: Disaggregated Balance Conditional on Answering the Endline
Table A9: Effects on Savings (without baseline controls)
Table A10: Comparing Salience and Personalization Versus Interaction
Table A11: Comparing the Way Personalization and Salience are Combined
Table A12: Impact on Savings Compared to Stated Goal
Table A13: Impact on Savings Behavior
Table A14: Bounding “Salience Only" Effects Due to Attrition
Table A15: Bounding “Personalization Only" Effects Due to Attrition
Table A16: Bounding Aggregate Effects Due to Attrition
Table A17: Testing for Pleasing Surveyor
Table A18: Testing for Framing
Table A19: Impact on Savings by Budget Balance at Baseline
*/





*-------------------------------------------------------------------------------
*working directory
clear all
cd "C:\Users\Ruben\RA team Dropbox\RUBEN JARA\Analisis experiment\replication_file"

*independent variables
global C_general _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito d_month_* _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog _c_13_meses_dif

global C_general_withoutmonths _a_1_edad Female i._a_3_educacion i._a_4_estado i._a_8_categoria i._3_4_distrito _b_5_riesgo litt _c_1_personas ln_c_6_ingreso_total ln_c_8_gastos_total ln_c_ingreso_gasto ln_ahorro_ind ln_ahorro_hog _c_13_meses_dif


	

	
*-------------------------------------------------------------------------------	
*Table A1
*-------------------------------------------------------------------------------
*Take-up Rates
*-------------------------------------------------------------------------------

use "data/baseline_charac_ready.dta", clear	

*did the individual have a goal?
gen bin_sms=(SMS=="SI")
replace bin_sms=. if SMS=="NO APLICA" | SMS==""
tabstat bin_sms, stats(mean sd) by(Tratamiento)
tabstat bin_sms if Tratamiento>=4, stats(mean sd)

*did the individual accept SMS?
gen bin_goal=0
replace bin_goal=1 if Tratamiento_3_obbjetivo>0 & Tratamiento_3_obbjetivo!=.
replace bin_goal=1 if T4A_Monto>0 & T4A_Monto!=.
replace bin_goal=1 if T_5_opcion_Bien_Servicio==1
replace bin_goal=1 if T6_Ahorro_B1>0 & T6_Ahorro_B1!=. 
replace bin_goal=1 if T6_Ahorro_A>0 & T6_Ahorro_A!=. 
tabstat bin_goal, stats(mean sd) by(Tratamiento)
tabstat bin_goal if Tratamiento>=4, stats(mean sd)





*-------------------------------------------------------------------------------	
*Table A2
*-------------------------------------------------------------------------------
*Take-up and baseline characteristics
*-------------------------------------------------------------------------------

*interaction
gen literacy=(no_litt==0)
gen similar=(discrepancy==0)

tab bin_goal if Tratamiento>=3
replace bin_goal=. if Tratamiento<3
tab bin_goal

label variable literacy "Financial literacy"
label variable savings "Positive savings at baseline"
label variable discrepancy "Savings similar to budget balance"
label variable positive_balance "Positive balance"

gen sms_sp=bin_sms*SxP
gen goal_sp=bin_goal*SxP

*generate data
foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index literacy savings discrepancy positive_balance {

*control mean sms
	estpost summarize `var' if bin_sms==0 & SxP==0
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}
		
*control mean goal
	estpost summarize `var' if bin_goal==0 & SxP==0
	if abs(el(e(mean),1,1))>100{
		local gmean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local gmean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression sms
	reg `var' SxP bin_sms sms_sp, robust
	local N_`var': di %12.0fc e(N)
	foreach x in bin_sms sms_sp {
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
	
*regression goal
	reg `var' SxP bin_goal goal_sp, robust
	local N_`var': di %12.0fc e(N)	
	foreach x in bin_goal goal_sp {
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
}

*generate Table A2
texdoc init tables\table_a2.tex, replace
tex \begin{table}[h]
tex \caption{"Take-up and baseline characteristics"}
tex \begin{center}
	tex \begin{tabular}{p{4cm}cccccc}
	tex \toprule
	tex \multicolumn{1}{c}{}	&	\multicolumn{1}{c}{C. Mean} &	\multicolumn{1}{c}{Sms} & \multicolumn{1}{c}{SxP*Sms} &	\multicolumn{1}{c}{C. Mean} &	\multicolumn{1}{c}{Goal} & \multicolumn{1}{c}{SxP*Goal} 	\\
	tex \midrule
	foreach var in  _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index literacy savings discrepancy positive_balance {
	tex `:var label `var'' & `mean_`var'' & `b_`var'_bin_sms'`s_`var'_bin_sms' & `b_`var'_sms_sp'`s_`var'_sms_sp' & `gmean_`var'' & `b_`var'_bin_goal'`s_`var'_bin_goal' & `b_`var'_goal_sp'`s_`var'_goal_sp' \\ 
	tex & & (`se_`var'_bin_sms') & (`se_`var'_sms_sp') & & (`se_`var'_bin_goal') & (`se_`var'_goal_sp')  \\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close

*loan is in another database

use "data/main_regressions_ready.dta", clear

*sms
gen bin_sms=(SMS=="SI")
replace bin_sms=. if SMS=="NO APLICA" | SMS==""

*goal
gen bin_goal=0
replace bin_goal=1 if Tratamiento_3_obbjetivo>0 & Tratamiento_3_obbjetivo!=.
replace bin_goal=1 if T4A_Monto>0 & T4A_Monto!=.
replace bin_goal=1 if T_5_opcion_Bien_Servicio==1
replace bin_goal=1 if T6_Ahorro_B1>0 & T6_Ahorro_B1!=. 
replace bin_goal=1 if T6_Ahorro_A>0 & T6_Ahorro_A!=. 
replace bin_goal=. if Tratamiento<3

*interaction
gen sms_sp=bin_sms*SxP
gen goal_sp=bin_goal*SxP

*regressions
reg Loan SxP bin_sms sms_sp, robust
reg Loan SxP bin_goal goal_sp, robust





*-------------------------------------------------------------------------------	
*Table A3
*-------------------------------------------------------------------------------
*Minimum Detectable Effects by Outcome
*-------------------------------------------------------------------------------

*Parameters:

* alpha: 0.05
* power(1-beta): 0.8
* t(alpha/2)+t(power): 2.8
* baseline follow up correlation: 0.4
* sigma (standard deviation): 1
* c: share of subjects initially assigned to the treatment group who actually receive the treatment
* s: share of subjects initially assigned to the comparison group who receive the treatment 
* c-s: difference in the take-up between the treatment and control group 
* s: 0 

clear all	
use "data/main_regressions_ready.dta", clear 


*number of individuals treated and controls

*controls
count if Tratamiento==1 
local num: di %12.3f r(N)

*salience
*observations
count if Tratamiento==1 | Tratamiento==2 // 1,383
local den_S: di %12.3f r(N) 
local prop_control_S: di %12.3f `num'/`den_S'
*treaties
count if Tratamiento==2 // 671
local num_trat_S: di %12.3f r(N)
local prop_trat_S: di %12.3f`num_trat_S'/`den_S'
*attrition
sum attrition if Tratamiento==1 | Tratamiento==2 // .2603037
local att_rate_S: di %12.3f r(mean)
local no_att_rate_S: di %12.3f 1-`att_rate_S' // 0.7396963
*sample size
local sample_size_S: di %12.3f `den_S'
*take up (c-s)
sum Tratamiento_2_1_SMS if Tratamiento==2 & Tratamiento_2_1_SMS==1 // IF equals 1
local take_up_S: di %12.3f r(N)/`num_trat_S'  // (0.74) percentage of individuals who were assigned to the salience treatment and took it

*personalization 
*observations
count if Tratamiento==1 | Tratamiento==3 // 1,351
local den_P: di %12.3f r(N)
local prop_control_P: di %12.3f `num'/`den_P'
*treaties
count if Tratamiento==3
local num_trat_P: di %12.3f r(N)
local prop_trat_P: di %12.3f `num_trat_P'/`den_P'
*attrition
sum attrition if Tratamiento==1 | Tratamiento==3 // .2553664
local att_rate_P: di %12.3f r(mean)
local no_att_rate_P: di %12.3f 1-`att_rate_P' // 0.7446336
*sample size
local sample_size_P: di %12.3f `den_P' 
*take up (c-s)
sum Tratamiento_3_obbjetivo if Tratamiento==3 & Tratamiento_3_obbjetivo!=0 
local take_up_P: di %12.3f r(N)/`num_trat_P' // (0.8) percentage of individuals who were assigned to the personalization treatment and took it 



*salience and personalization
*observations
count if Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6 // 1,387
local den_SxP: di %12.3f r(N)
local prop_control_SxP: di %12.3f `num'/`den_SxP'
*treaties
count if Tratamiento==4 | Tratamiento==5 | Tratamiento==6
local num_trat_SxP: di %12.3f r(N)
local prop_trat_SxP: di %12.3f `num_trat_SxP'/`den_SxP'
*attrition
sum attrition if Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6 // .2819034
local att_rate_SxP: di %12.3f r(mean)
local no_att_rate_SxP: di %12.3f (1-`att_rate_SxP') // 0.7180966
*sample size
local sample_size_SxP: di %12.3f `den_SxP'
*take up (c-s)
sum Tratamiento if (Tratamiento_4_SMS==1 & T4A_Monto!=0) | T_5_opcion_Bien_Servicio==1 | T6_Ahorro_B1!=.
local take_up_SxP: di %12.3f r(N)/`num_trat_SxP' // (0.6) percentage of individuals who were assigned to the SxP treatment and took it


*correlations baseline follow up 

local outcomes_w_lb dumB_11 household_expenses div_ves_o_expenses lnB_11 B_13_num_mon dumB_17 index_endline C_11 dumC_1 C_3_montototal C_3_montototalaprob dumC_3_nopag D_9 total_expenses transport_expenses communica_expenses
foreach var of local outcomes_w_lb{
sum `var' if Tratamiento==1
local sd_`var'=r(sd)
reg `var' `var'_lb  if Tratamiento==1 // important: only for controls
local `var'_res_sd = round(sqrt(`e(rss)'/`e(df_r)'),0.0001)/`sd_`var''
local r2_`var'= e(r2)
local corr_`var': di %12.3f (`r2_`var'')^(1/2)
}

*mde (minimum detectable effects)
	
*salience 
	
*with baseline
*dumB_11 (Saved (dummy))
sum dumB_11 if (Tratamiento==1 | Tratamiento==2) // N for dumB_11 after attrition
local nats_dumB_11_S=r(N) // 1007 sample after attrition (dumB_11) 
*local emd_dumB_11_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`no_att_rate_S'*`sample_size_S')^(1/2)))* (`corr_dumB_11'/`take_up_S')
local emd2_dumB_11_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_dumB_11_S')^(1/2)))*(`dumB_11_res_sd'/`take_up_S')
*household_expenses (Expenses on household items)
sum household_expenses if (Tratamiento==1 | Tratamiento==2)
local nats_household_S=r(N) // 1007
local emd2_household_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_household_S')^(1/2)))*(`household_expenses_res_sd'/`take_up_S')
*div_ves_o_expenses (Expenses on fun, clothes, and co.)
sum div_ves_o_expenses if (Tratamiento==1 | Tratamiento==2)
local nats_div_ves_S=r(N) // 1018
local emd2_div_ves_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_div_ves_S')^(1/2)))*(`div_ves_o_expenses_res_sd'/`take_up_S')
*lnB_11 (Amount saved (log))
sum lnB_11 if (Tratamiento==1 | Tratamiento==2)
local nats_lnB_11_S=r(N)
local emd2_lnB_11_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_lnB_11_S')^(1/2)))*(`lnB_11_res_sd'/`take_up_S')
*B_13_num_mon (N months with financial problems )
sum B_13_num_mon if (Tratamiento==1 | Tratamiento==2)
local nats_B_13_S=r(N)
local emd2_B_13_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_B_13_S')^(1/2)))*(`B_13_num_mon_res_sd'/`take_up_S')
*dumB_17 (Thought of using savings next time?)
sum dumB_17 if (Tratamiento==1 | Tratamiento==2)
local nats_dumB_17_S=r(N)
local emd2_dumB_17_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_dumB_17_S')^(1/2)))*(`dumB_17_res_sd'/`take_up_S')
*index_endline (Index of well being)
sum index_endline if (Tratamiento==1 | Tratamiento==2)
local nats_index_S=r(N)
local emd2_index_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_index_S')^(1/2)))*(`index_endline_res_sd'/`take_up_S')
*C_11 (satisfaction with financial situation)
sum C_11 if (Tratamiento==1 | Tratamiento==2)
local nats_C_11_S=r(N)
local emd2_C_11_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_C_11_S')^(1/2)))*(`C_11_res_sd'/`take_up_S')
*dumC_1 (Requested credit)
sum dumC_1 if (Tratamiento==1 | Tratamiento==2) // 1,023
local nats_dumC_1_S=r(N)
local emd2_dumC_1_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_dumC_1_S')^(1/2)))*(`dumC_1_res_sd'/`take_up_S')
*C_3_montototal (Total amount requested (thousands))
sum C_3_montototal if (Tratamiento==1 | Tratamiento==2)
local nats_C_3_monto_S=r(N)
local emd2_C_3_monto_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_C_3_monto_S')^(1/2)))*(`C_3_montototal_res_sd'/`take_up_S')
*C_3_montototalaprob (Total amount approved (thousands))
sum C_3_montototalaprob if (Tratamiento==1 | Tratamiento==2)
local nats_C_3_montop_S=r(N)
local emd2_C_3_montop_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_C_3_montop_S')^(1/2)))*(`C_3_montototalaprob_res_sd'/`take_up_S')
*dumC_3_nopag (Defaulted)
sum dumC_3_nopag if (Tratamiento==1 | Tratamiento==2)
local nats_dumC_3_nopag_S=r(N)
local emd2_dumC_3_nopag_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_dumC_3_nopag_S')^(1/2)))*(`dumC_3_nopag_res_sd'/`take_up_S')

*without baseline
*ahorro_suma_meses (Num of months saved) 
sum ahorro_suma_meses if (Tratamiento==1 | Tratamiento==2) 
local nats_ahorro_suma_S=r(N)
local emd2_ahorro_suma_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_ahorro_suma_S')^(1/2)))*(1/`take_up_S')
*dum_pct1_D_13 (Saved > 5pct of baseline income)
sum dum_pct1_D_13 if (Tratamiento==1 | Tratamiento==2) 
local nats_dum_pct1_D_13_S=r(N)
local emd2_dum_pct1_D_13_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_dum_pct1_D_13_S')^(1/2)))*(1/`take_up_S')
*lnD_13 (Amount saved (log))
sum lnD_13 if (Tratamiento==1 | Tratamiento==2) 
local nats_lnD_13_S=r(N)
local emd2_lnD_13_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_lnD_13_S')^(1/2)))*(1/`take_up_S')
*dum_pct1_B_11 (Saved > 5pct of baseline income")
sum dum_pct1_B_11 if (Tratamiento==1 | Tratamiento==2) 
local nats_dum_pct1_B_11_S=r(N)
local emd2_dum_pct1_B_11_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_dum_pct1_B_11_S')^(1/2)))*(1/`take_up_S')
*dumB_10 (Positive balance (dummy))
sum dumB_10 if (Tratamiento==1 | Tratamiento==2) 
local nats_dumB_10_S=r(N)
local emd2_dumB_10_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_dumB_10_S')^(1/2)))*(1/`take_up_S')
*lnB_10 (Budget balance (log))
sum lnB_10  if (Tratamiento==1 | Tratamiento==2) 
local nats_lnB_10_S=r(N)
local emd2_lnB_10_S: di %12.3f (2.8/((`prop_trat_S'*`prop_control_S')^(1/2)))*(1/((`nats_lnB_10_S')^(1/2)))*(1/`take_up_S')

*personalization 

*with baseline
*dumB_11 (Saved (dummy))
sum dumB_11 if (Tratamiento==1 | Tratamiento==3)
local nats_dumB_11_P=r(N) // 1007 sample after attrition (dumB_11) 
local emd2_dumB_11_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_dumB_11_P')^(1/2)))*(`dumB_11_res_sd'/`take_up_P')
*household_expenses (Expenses on household items)
sum household_expenses if (Tratamiento==1 | Tratamiento==3)
local nats_household_P=r(N) // 1007
local emd2_household_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_household_P')^(1/2)))*(`household_expenses_res_sd'/`take_up_P')
*div_ves_o_expenses (Expenses on fun, clothes, and co.)
sum div_ves_o_expenses if (Tratamiento==1 | Tratamiento==3)
local nats_div_ves_P=r(N) // 1018
local emd2_div_ves_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_div_ves_P')^(1/2)))*(`div_ves_o_expenses_res_sd'/`take_up_P')
*lnB_11 (Amount saved (log))
sum lnB_11 if (Tratamiento==1 | Tratamiento==3)
local nats_lnB_11_P=r(N)
local emd2_lnB_11_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_lnB_11_P')^(1/2)))*(`lnB_11_res_sd'/`take_up_P')
*B_13_num_mon (N months with financial problems )
sum B_13_num_mon if (Tratamiento==1 | Tratamiento==3)
local nats_B_13_P=r(N)
local emd2_B_13_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_B_13_P')^(1/2)))*(`B_13_num_mon_res_sd'/`take_up_P')
*dumB_17 (Thought of using savings next time?)
sum dumB_17 if (Tratamiento==1 | Tratamiento==3)
local nats_dumB_17_P=r(N)
local emd2_dumB_17_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_dumB_17_P')^(1/2)))*(`dumB_17_res_sd'/`take_up_P')
*index_endline (Index of well being)
sum index_endline if (Tratamiento==1 | Tratamiento==3)
local nats_index_P=r(N)
local emd2_index_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_index_P')^(1/2)))*(`index_endline_res_sd'/`take_up_P')
*C_11 (satisfaction with financial situation)
sum C_11 if (Tratamiento==1 | Tratamiento==3)
local nats_C_11_P=r(N)
local emd2_C_11_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_C_11_P')^(1/2)))*(`C_11_res_sd'/`take_up_P')
*dumC_1 (Requested credit)
sum dumC_1 if (Tratamiento==1 | Tratamiento==3) // 1,023
local nats_dumC_1_P=r(N)
local emd2_dumC_1_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_dumC_1_P')^(1/2)))*(`dumC_1_res_sd'/`take_up_P')
*C_3_montototal (Total amount requested (thousands))
sum C_3_montototal if (Tratamiento==1 | Tratamiento==3)
local nats_C_3_monto_P=r(N)
local emd2_C_3_monto_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_C_3_monto_P')^(1/2)))*(`C_3_montototal_res_sd'/`take_up_P')
*C_3_montototalaprob (Total amount approved (thousands))
sum C_3_montototalaprob if (Tratamiento==1 | Tratamiento==3)
local nats_C_3_montop_P=r(N)
local emd2_C_3_montop_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_C_3_montop_P')^(1/2)))*(`C_3_montototalaprob_res_sd'/`take_up_P')
*dumC_3_nopag (Defaulted)
sum dumC_3_nopag if (Tratamiento==1 | Tratamiento==3)
local nats_dumC_3_nopag_P=r(N)
local emd2_dumC_3_nopag_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_dumC_3_nopag_P')^(1/2)))*(`dumC_3_nopag_res_sd'/`take_up_P')

*without baseline 
*ahorro_suma_meses (Num of months saved) 
sum ahorro_suma_meses if (Tratamiento==1 | Tratamiento==3) 
local nats_ahorro_suma_P=r(N)
local emd2_ahorro_suma_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_ahorro_suma_P')^(1/2)))*(1/`take_up_P')
*dum_pct1_D_13 (Saved > 5pct of baseline income)
sum dum_pct1_D_13 if (Tratamiento==1 | Tratamiento==3) 
local nats_dum_pct1_D_13_P=r(N)
local emd2_dum_pct1_D_13_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_dum_pct1_D_13_P')^(1/2)))*(1/`take_up_P')
*lnD_13 (Amount saved (log))
sum lnD_13 if (Tratamiento==1 | Tratamiento==3) 
local nats_lnD_13_P=r(N)
local emd2_lnD_13_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_lnD_13_P')^(1/2)))*(1/`take_up_P')
*dum_pct1_B_11 (Saved > 5pct of baseline income")
sum dum_pct1_B_11 if (Tratamiento==1 | Tratamiento==3) 
local nats_dum_pct1_B_11_P=r(N)
local emd2_dum_pct1_B_11_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_dum_pct1_B_11_P')^(1/2)))*(1/`take_up_P')
*dumB_10 (Positive balance (dummy))
sum dumB_10 if (Tratamiento==1 | Tratamiento==3) 
local nats_dumB_10_P=r(N)
local emd2_dumB_10_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_dumB_10_P')^(1/2)))*(1/`take_up_P')
*lnB_10 (Budget balance (log))
sum lnB_10  if (Tratamiento==1 | Tratamiento==3) 
local nats_lnB_10_P=r(N)
local emd2_lnB_10_P: di %12.3f (2.8/((`prop_trat_P'*`prop_control_P')^(1/2)))*(1/((`nats_lnB_10_P')^(1/2)))*(1/`take_up_P')


*Salience and personalization 

*with baseline
*dumB_11 (Saved (dummy))
sum dumB_11 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_dumB_11_SxP=r(N) // 1007 sample after attrition (dumB_11) 
local emd2_dumB_11_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_dumB_11_SxP')^(1/2)))*(`dumB_11_res_sd'/`take_up_SxP')
*household_expenses (Expenses on household items)
sum household_expenses if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_household_SxP=r(N) // 1007
local emd2_household_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_household_SxP')^(1/2)))*(`household_expenses_res_sd'/`take_up_SxP')
*div_ves_o_expenses (Expenses on fun, clothes, and co.)
sum div_ves_o_expenses if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_div_ves_SxP=r(N) // 1018
local emd2_div_ves_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_div_ves_SxP')^(1/2)))*(`div_ves_o_expenses_res_sd'/`take_up_SxP')
*lnB_11 (Amount saved (log))
sum lnB_11 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_lnB_11_SxP=r(N)
local emd2_lnB_11_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_lnB_11_SxP')^(1/2)))*(`lnB_11_res_sd'/`take_up_SxP')
*B_13_num_mon (N months with financial problems )
sum B_13_num_mon if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_B_13_SxP=r(N)
local emd2_B_13_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_B_13_SxP')^(1/2)))*(`B_13_num_mon_res_sd'/`take_up_SxP')
*dumB_17 (Thought of using savings next time?)
sum dumB_17 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_dumB_17_SxP=r(N)
local emd2_dumB_17_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_dumB_17_SxP')^(1/2)))*(`dumB_17_res_sd'/`take_up_SxP')
*index_endline (Index of well being)
sum index_endline if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_index_SxP=r(N)
local emd2_index_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_index_SxP')^(1/2)))*(`index_endline_res_sd'/`take_up_SxP')
*C_11 (satisfaction with financial situation)
sum C_11 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_C_11_SxP=r(N)
local emd2_C_11_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_C_11_SxP')^(1/2)))*(`C_11_res_sd'/`take_up_SxP')
*dumC_1 (Requested credit)
sum dumC_1 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6) 
local nats_dumC_1_SxP=r(N)
local emd2_dumC_1_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_dumC_1_SxP')^(1/2)))*(`dumC_1_res_sd'/`take_up_SxP')
*C_3_montototal (Total amount requested (thousands))
sum C_3_montototal if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_C_3_monto_SxP=r(N)
local emd2_C_3_monto_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_C_3_monto_SxP')^(1/2)))*(`C_3_montototal_res_sd'/`take_up_SxP')
*C_3_montototalaprob (Total amount approved (thousands))
sum C_3_montototalaprob if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_C_3_montop_SxP=r(N)
local emd2_C_3_montop_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_C_3_montop_SxP')^(1/2)))*(`C_3_montototalaprob_res_sd'/`take_up_SxP')
*dumC_3_nopag (Defaulted)
sum dumC_3_nopag if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6)
local nats_dumC_3_nopag_SxP=r(N)
local emd2_dumC_3_nop_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_dumC_3_nopag_SxP')^(1/2)))*(`dumC_3_nopag_res_sd'/`take_up_SxP')

*without baseline
*ahorro_suma_meses (Num of months saved) 
sum ahorro_suma_meses if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6) 
local nats_ahorro_suma_SxP=r(N)
local emd2_ahorro_suma_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_ahorro_suma_SxP')^(1/2)))*(1/`take_up_SxP')
*dum_pct1_D_13 (Saved > 5pct of baseline income)
sum dum_pct1_D_13 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6) 
local nats_dum_pct1_D_13_SxP=r(N)
local emd2_dum_pct1_D_13_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_dum_pct1_D_13_SxP')^(1/2)))*(1/`take_up_SxP')
*lnD_13 (Amount saved (log))
sum lnD_13 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6) 
local nats_lnD_13_SxP=r(N)
local emd2_lnD_13_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_lnD_13_SxP')^(1/2)))*(1/`take_up_SxP')
*dum_pct1_B_11 (Saved > 5pct of baseline income")
sum dum_pct1_B_11 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6) 
local nats_dum_pct1_B_11_SxP=r(N)
local emd2_dum_pct1_B_11_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_dum_pct1_B_11_SxP')^(1/2)))*(1/`take_up_SxP')
*dumB_10 (Positive balance (dummy))
sum dumB_10 if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6) 
local nats_dumB_10_SxP=r(N)
local emd2_dumB_10_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_dumB_10_SxP')^(1/2)))*(1/`take_up_SxP')
*lnB_10 (Budget balance (log))
sum lnB_10  if (Tratamiento==1 | Tratamiento==4 | Tratamiento==5 | Tratamiento==6) 
local nats_lnB_10_SxP=r(N)
local emd2_lnB_10_SxP: di %12.3f (2.8/((`prop_trat_SxP'*`prop_control_SxP')^(1/2)))*(1/((`nats_lnB_10_SxP')^(1/2)))*(1/`take_up_SxP')

*generate Table A3
texdoc init tables\table_a3.tex, replace
tex \begin{table}[h]
tex \caption{"Minimum Detectable Effects by Outcome"}
tex \begin{center}
	tex \begin{tabular}{lccccccc} \toprule
	tex \\
    tex   & \multicolumn{2}{c}{Salience} & \multicolumn{2}{c}{Personalization} & \multicolumn{2}{c}{SxP} \\
    tex Variables 								& N(1-att)     			& MDE  						  &   N(1-att)     		& MDE  				&   N(1-att)    		& MDE\\
	tex  \midrule \\
    tex \multicolumn{7}{c}{Savings during intervention} \\
    tex  Num of months saved        			 &  `nats_ahorro_suma_S' & `emd2_ahorro_suma_S'       &  `nats_ahorro_suma_P' & `emd2_ahorro_suma_P' &  `nats_ahorro_suma_SxP' & `emd2_ahorro_suma_SxP'       \\
    tex  Savings during intervention (log)       & `nats_lnD_13_S'         & `emd2_lnD_13_S'                & `nats_lnD_13_P'        & `emd2_lnD_13_P'      & `nats_lnD_13_SxP'        & `emd2_lnD_13_SxP'\\
	tex  Saved > 5pct of baseline income         &  `nats_dum_pct1_D_13_S'& `emd2_dum_pct1_D_13_S'    &  `nats_dum_pct1_D_13_P'& `emd2_dum_pct1_D_13_P'&  `nats_dum_pct1_D_13_SxP'& `emd2_dum_pct1_D_13_SxP'    \\
    tex \multicolumn{7}{c}{Savings at endline} \\
	tex  Saved (dummy)   			             & `nats_dumB_11_S' 	& `emd2_dumB_11_S'     		  & `nats_dumB_11_P'   &  `emd2_dumB_11_P'  & `nats_dumB_11_SxP'   &  `emd2_dumB_11_SxP'    \\
    tex  Amount saved (log)					 	 & `nats_lnB_11_S' 		& `emd2_lnB_11_S'             & `nats_lnB_11_P' 	 & `emd2_lnB_11_P' 	  & `nats_lnB_11_SxP' 	   & `emd2_lnB_11_SxP'  \\
    tex  Positive balance (dummy)                &  `nats_dumB_10_S'    & `emd2_dumB_10_S'            &  `nats_dumB_10_P'    & `emd2_dumB_10_P'   &  `nats_dumB_10_SxP'    & `emd2_dumB_10_SxP'           \\
	tex  Budget balance (log)                    &  `nats_lnB_10_S'       & `emd2_lnB_10_S'           &  `nats_lnB_10_P'       & `emd2_lnB_10_P'  &  `nats_lnB_10_SxP'       & `emd2_lnB_10_SxP'           \\
    tex  Expenses on household items 	         & `nats_household_S' 	& `emd2_household_S' 		  & `nats_household_P' 	& `emd2_household_P'  & `nats_household_SxP' & `emd2_household_SxP'\\
    tex  Expenses on fun, clothes, and co.	     & `nats_div_ves_S' 	& `emd2_div_ves_S'           & `nats_div_ves_P' 	& `emd2_div_ves_P'   & `nats_div_ves_SxP' 	& `emd2_div_ves_SxP'  \\
    tex  \multicolumn{7}{c}{Other outcomes} \\
	tex  N months with financial problems        &  `nats_B_13_S'       & `emd2_B_13_S'               &  `nats_B_13_P'       & `emd2_B_13_P'      &  `nats_B_13_SxP'       & `emd2_B_13_SxP' \\
	tex  Thought of using savings next time?     &  `nats_dumB_17_S'    & `emd2_dumB_17_S'            &  `nats_dumB_17_P'    & `emd2_dumB_17_P'   &  `nats_dumB_17_SxP'    & `emd2_dumB_17_SxP'    \\
	tex  Index of well being			         &  `nats_index_S'      & `emd2_index_S'              &  `nats_index_P'      & `emd2_index_P'     &  `nats_index_SxP'      & `emd2_index_SxP'              \\
	tex  Satisfaction with financial situation   &  `nats_C_11_S'       & `emd2_C_11_S'               &  `nats_C_11_P'       & `emd2_C_11_P'      &  `nats_C_11_SxP'       & `emd2_C_11_SxP'              \\
	tex  Requested credit        				 &  `nats_dumC_1_S'     & `emd2_dumC_1_S'             &  `nats_dumC_1_P'     & `emd2_dumC_1_P'    &  `nats_dumC_1_SxP'     & `emd2_dumC_1_SxP'    \\
	tex  Total amount requested (thousands)      &  `nats_C_3_monto_S'  & `emd2_C_3_monto_S'          &  `nats_C_3_monto_P'  & `emd2_C_3_monto_P' &  `nats_C_3_monto_SxP'  & `emd2_C_3_monto_SxP'  \\
	tex  Total amount approved (thousands)       &  `nats_C_3_montop_S' & `emd2_C_3_montop_S'         &  `nats_C_3_montop_P' & `emd2_C_3_montop_P'&  `nats_C_3_montop_SxP' & `emd2_C_3_montop_SxP'          \\
	tex  Defaulted						         &  `nats_dumC_3_nopag_S'& `emd2_dumC_3_nopag_S'      &  `nats_dumC_3_nopag_P'& `emd2_dumC_3_nopag_P'& `nats_dumC_3_nopag_SxP'& `emd2_dumC_3_nop_SxP'      \\
	tex & \\ \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close





*-------------------------------------------------------------------------------	
*Table A4
*-------------------------------------------------------------------------------
*Seasonality
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta"

*every treatment
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
	
*variables in thousands
replace _c_ingreso_gasto=_c_ingreso_gasto/1000 
replace _c_6_ingreso_total=_c_6_ingreso_total/1000
replace _c_8_gastos_total=_c_8_gastos_total/1000
label variable _c_ingreso_gasto "Baseline balance (thousands)"
label variable _c_6_ingreso_total "Baseline income (thousands)"
label variable _c_8_gastos_total "Baseline expenses (thousands)"

*generate data without controls
foreach var in _c_ingreso_gasto _c_6_ingreso_total _c_8_gastos_total SO PO SxP {

*control mean
	estpost summarize `var'
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg `var' d_month_* , robust
	local N_`var': di %12.0fc e(N)
	test d_month_1 d_month_2 d_month_3 d_month_4 d_month_5
	local F_`var': di %12.2fc r(F)
	local s_F_`var'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))
	foreach x in d_month_1 d_month_2 d_month_3 d_month_4 d_month_5 {
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
}

*generate Table A4
texdoc init tables\table_a4.tex, replace
tex \begin{table}[h]
tex \caption{"Seasonality"}
tex \begin{center}
	tex \begin{tabular}{p{3cm}ccccccc}
	tex \toprule
	tex &	\multicolumn{1}{c}{Mean}	&	\multicolumn{1}{c}{jul} &	\multicolumn{1}{c}{aug}	&	\multicolumn{1}{c}{sep} &	\multicolumn{1}{c}{oct} &	\multicolumn{1}{c}{nov} &	\multicolumn{1}{c}{F-test}	\\
	tex \midrule
	tex \multicolumn{8}{c}{Regressions without controls} \\
	foreach var in _c_ingreso_gasto _c_6_ingreso_total _c_8_gastos_total SO PO SxP {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_d_month_1'`s_`var'_d_month_1'	& `b_`var'_d_month_2'`s_`var'_d_month_2' & `b_`var'_d_month_3'`s_`var'_d_month_3' & `b_`var'_d_month_4'`s_`var'_d_month_4' & `b_`var'_d_month_5'`s_`var'_d_month_5' & `F_`var''`s_F_`var'' 	\\
	tex & & (`se_`var'_d_month_1') & (`se_`var'_d_month_2') & (`se_`var'_d_month_3') & (`se_`var'_d_month_4') & (`se_`var'_d_month_5') &   \\
	}
texdoc close

*regression with controls
foreach var in _c_ingreso_gasto _c_6_ingreso_total _c_8_gastos_total SO PO SxP {

*control mean
	estpost summarize `var'
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg `var'  d_month_* $C_general_withoutmonths, robust
	local N_`var': di %12.0fc e(N)
	test d_month_1 d_month_2 d_month_3 d_month_4 d_month_5
	local F_`var': di %12.2fc r(F)
	local s_F_`var'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))
	
	foreach x in d_month_1 d_month_2 d_month_3 d_month_4 d_month_5 {
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
}

*generate Table A4
texdoc init tables\table_a4.tex, append
	tex \multicolumn{8}{c}{Regressions with controls}\\
	foreach var in _c_ingreso_gasto _c_6_ingreso_total _c_8_gastos_total SO PO SxP {
		tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_d_month_1'`s_`var'_d_month_1'	& `b_`var'_d_month_2'`s_`var'_d_month_2' & `b_`var'_d_month_3'`s_`var'_d_month_3' & `b_`var'_d_month_4'`s_`var'_d_month_4' & `b_`var'_d_month_5'`s_`var'_d_month_5' & `F_`var''`s_F_`var'' 				\\
	tex & & (`se_`var'_d_month_1') & (`se_`var'_d_month_2') & (`se_`var'_d_month_3') & (`se_`var'_d_month_4') & (`se_`var'_d_month_5') &   \\
	}
	tex \bottomrule
tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close





*-------------------------------------------------------------------------------	
*Table A5
*-------------------------------------------------------------------------------
*Disaggregated Balance
*-------------------------------------------------------------------------------

use "data/baseline_charac_ready.dta", clear	

*every treatment
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

label var ln_ahorro_ind "Individual savings (ln)"

*generate data
foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {

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
	qui reg `var' SO PO SP TG PS, robust
	local N_`var': di %12.0fc e(N)
	foreach x in SO PO SP TG PS {
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
	test SO PO SP TG PS
	local F_`var': di %12.2fc r(F)
	local s_F_`var'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
}

preserve
clear
set obs 1
gen n=1 
save test_f, replace 

local i=0
use "data/baseline_charac_ready.dta", clear	
replace ln_ahorro_ind=. if _c_11_ahorroind==.
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
foreach var of varlist _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total  _c_ingreso_gasto _c_8_gastos_total savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index{
keep `var' SO PO SP TG PS 
rename `var' outcome
local i=`i'+1
gen dum`i'=1
rename SO SO_`i'
rename PO PO_`i'
rename SP SP_`i'
rename TG TG_`i'
rename PS PS_`i'
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
replace SO_`i'=0 if SO_`i'==.
replace PO_`i'=0 if PO_`i'==.
replace SP_`i'=0 if SP_`i'==.
replace TG_`i'=0 if TG_`i'==.
replace PS_`i'=0 if PS_`i'==.
}

reg outcome dum* SO_* PO_* SP_* TG_* PS_*, robust nocons
test SO_1 SO_2 SO_3 SO_4 SO_5 SO_6 SO_7 SO_8 SO_9 SO_10 SO_11 SO_12 SO_13 SO_14

local F_SO: di %12.2fc r(F)
display `F_SO'	

test PO_1 PO_2 PO_3 PO_4 PO_5 PO_6 PO_7 PO_8 PO_9 PO_10 PO_11 PO_12 PO_13 PO_14
local F_PO: di %12.2fc r(F)
display `F_PO'

test SP_1 SP_2 SP_3 SP_4 SP_5 SP_6 SP_7 SP_8 SP_9 SP_10 SP_11 SP_12 SP_13 SP_14
local F_SP: di %12.2fc r(F)
display `F_SP'

test TG_1 TG_2 TG_3 TG_4 TG_5 TG_6 TG_7 TG_8 TG_9 TG_10 TG_11 TG_12 TG_13 TG_14
local F_TG: di %12.2fc r(F)
display `F_TG'

test PS_1 PS_2 PS_3 PS_4 PS_5 PS_6 PS_7 PS_8 PS_9 PS_10 PS_11 PS_12 PS_13 PS_14
local F_PS: di %12.2fc r(F)
display `F_PS'


*generate Table A5
texdoc init tables\table_a5.tex, replace
tex \begin{table}[h]
tex \caption{"Disaggregated Balance"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}cccccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{Mean} 	&	\multicolumn{1}{c}{SO} 	& \multicolumn{1}{c}{PO}	& \multicolumn{1}{c}{SP} & \multicolumn{1}{c}{TG} & \multicolumn{1}{c}{PS} & Joint F-test & \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {
	tex   `:var label `var'' 	&	`mean_`var'' & `b_`var'_SO'`s_`var'_SO'			& `b_`var'_PO'`s_`var'_PO'		&	`b_`var'_SP'`s_`var'_SP' &	`b_`var'_TG'`s_`var'_TG' &	`b_`var'_PS'`s_`var'_PS'	& `F_`var''`s_F_`var''		& `N_`var''					\\
	tex               			&	(`sd_`var'') & (`se_`var'_SO')       				& (`se_`var'_PO') 				&   (`se_`var'_SP') & (`se_`var'_TG') & (`se_`var'_PS')			& 					&							\\
	}
	tex F-test: &  &  `F_SO' & `F_PO' & `F_SP' & `F_TG' & `F_PS' & & \\
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close
estimates clear





*-------------------------------------------------------------------------------	
*Table A6
*-------------------------------------------------------------------------------
*Attrition Test
*-------------------------------------------------------------------------------

clear all
use "data/main_regressions_ready.dta", clear

*regression without controls
foreach var in attrition{

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg   `var' S P SxP , robust
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

*generate Table A6
texdoc init tables\table_a6a.tex, replace
tex \begin{table}[h]
tex \caption{"Attrition Test"}
tex \begin{center}
	tex \begin{tabular}{lcccccc}
	tex \toprule
	tex	&	\multicolumn{1}{c}{Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{Both}  	& \multicolumn{1}{c}{Agg.}		& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	foreach var in attrition {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'	&	`N_`var''				\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')				& 							\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close

*regression with controls
foreach var in attrition{

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

*generate Table A6
texdoc init tables\table_a6b.tex, replace
tex \begin{table}[h]
tex \caption{"Attrition Test"}
tex \begin{center}
	tex \begin{tabular}{lcccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{Both}  	& \multicolumn{1}{c}{Agg.}		& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	foreach var in attrition {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'	&	`N_`var''				\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')				& 							\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close





*-------------------------------------------------------------------------------	
*Table A7
*-------------------------------------------------------------------------------
*Balance Conditional on Answering the Endline
*-------------------------------------------------------------------------------

use "data/baseline_charac_ready.dta", clear	
replace ln_ahorro_ind=. if _c_11_ahorroind==.
label var ln_ahorro_ind "Individual savings (ln)"

*generate data
foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {

*control mean
	estpost summarize `var' if Tratamiento==1 & attrition==0
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
	qui reg `var' S P SxP if attrition==0, robust
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

local i=0
use "data/baseline_charac_ready.dta", clear	
replace ln_ahorro_ind=. if _c_11_ahorroind==.
foreach var of varlist _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total  _c_ingreso_gasto _c_8_gastos_total savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index{
keep if attrition==0
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

restore

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

*generate Table A7
texdoc init tables\table_a7.tex, replace
tex \begin{table}[h]
tex \caption{"Balance Conditional on Answering the Endline"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}ccccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{Both}  	& Joint F-test & \multicolumn{1}{c}{Agg. Effect}	& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {
	tex   `:var label `var'' 	&	`mean_`var'' & `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `F_`var''`s_F_`var'' & `b_`var'_Agg'`s_`var'_Agg'		& `N_`var''					\\
	tex               			&	(`sd_`var'') & (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			&  & (`se_`var'_Agg')					&							\\
	}
	tex F-test: &  &  `F_S' & `F_P' & `F_SP' &  & \\
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close
	

	
		

*-------------------------------------------------------------------------------	
*Table A8
*-------------------------------------------------------------------------------
*Disaggregated Balance Conditional on Answering the Endline
*-------------------------------------------------------------------------------

use "data/baseline_charac_ready.dta", clear	
replace ln_ahorro_ind=. if _c_11_ahorroind==.

*every treatment
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
label var ln_ahorro_ind "Individual savings (ln)"

*generate data
foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {

*control mean
	estpost summarize `var' if attrition==0
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
	qui reg `var' SO PO SP TG PS if attrition==0, robust
	local N_`var': di %12.0fc e(N)
	foreach x in SO PO SP TG PS {
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
	test SO PO SP TG PS
	local F_`var': di %12.2fc r(F)
	local s_F_`var'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))
}

preserve
clear
set obs 1
gen n=1 
save test_f, replace 

local i=0
use "data/baseline_charac_ready.dta", clear	
replace ln_ahorro_ind=. if _c_11_ahorroind==.
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
foreach var of varlist _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total  _c_ingreso_gasto _c_8_gastos_total savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index{
keep if attrition==0
keep `var' SO PO SP TG PS
rename `var' outcome
local i=`i'+1
gen dum`i'=1
rename SO SO_`i'
rename PO PO_`i'
rename SP SP_`i'
rename TG TG_`i'
rename PS PS_`i'
append using test_f
save test_f, replace
restore
preserve 
}

restore

use test_f, clear
drop if n==1
drop n

forvalues i=1/14{
replace dum`i'=0 if dum`i'==.
replace SO_`i'=0 if SO_`i'==.
replace PO_`i'=0 if PO_`i'==.
replace SP_`i'=0 if SP_`i'==.
replace TG_`i'=0 if TG_`i'==.
replace PS_`i'=0 if PS_`i'==.
}


reg outcome dum* SO_* PO_* SP_* TG_* PS_*, robust nocons

test SO_1 SO_2 SO_3 SO_4 SO_5 SO_6 SO_7 SO_8 SO_9 SO_10 SO_11 SO_12 SO_13 SO_14
local F_SO: di %12.2fc r(F)
display `F_SO'	

test PO_1 PO_2 PO_3 PO_4 PO_5 PO_6 PO_7 PO_8 PO_9 PO_10 PO_11 PO_12 PO_13 PO_14
local F_PO: di %12.2fc r(F)
display `F_PO'

test SP_1 SP_2 SP_3 SP_4 SP_5 SP_6 SP_7 SP_8 SP_9 SP_10 SP_11 SP_12 SP_13 SP_14
local F_SP: di %12.2fc r(F)
display `F_SP'

test TG_1 TG_2 TG_3 TG_4 TG_5 TG_6 TG_7 TG_8 TG_9 TG_10 TG_11 TG_12 TG_13 TG_14
local F_TG: di %12.2fc r(F)
display `F_TG'

test PS_1 PS_2 PS_3 PS_4 PS_5 PS_6 PS_7 PS_8 PS_9 PS_10 PS_11 PS_12 PS_13 PS_14
local F_PS: di %12.2fc r(F)
display `F_PS'

*generate Table A8
texdoc init tables\table_a8.tex, replace
tex \begin{table}[h]
tex \caption{"Disaggregated Balance Conditional on Answering the Endline"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}cccccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{Mean} 	&	\multicolumn{1}{c}{SO} 	& \multicolumn{1}{c}{PO}	& \multicolumn{1}{c}{SP} & \multicolumn{1}{c}{TG} & \multicolumn{1}{c}{PS} & Joint F-test & \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	foreach var in _a_1_edad Female _a_3_educacion single _a_5_jefe _a_6_trabajo _c_6_ingreso_total _c_8_gastos_total _c_ingreso_gasto savings ln_ahorro_ind dum_c_13_meses_dif dum_c_15_caidas index {
	tex   `:var label `var'' 	&	`mean_`var'' & `b_`var'_SO'`s_`var'_SO'			& `b_`var'_PO'`s_`var'_PO'		&	`b_`var'_SP'`s_`var'_SP' &	`b_`var'_TG'`s_`var'_TG' &	`b_`var'_PS'`s_`var'_PS'	& `F_`var''`s_F_`var''		& `N_`var''					\\
	tex               			&	(`sd_`var'') & (`se_`var'_SO')       				& (`se_`var'_PO') 				&   (`se_`var'_SP') & (`se_`var'_TG') & (`se_`var'_PS')			& 					&							\\
	}
	tex F-test: &  &  `F_SO' & `F_PO' & `F_SP' & `F_TG' & `F_PS' & & \\
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close
	

	
	
	
*-------------------------------------------------------------------------------	
*Table A9
*-------------------------------------------------------------------------------
*Effects on Savings (without baseline controls)
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*generate data with baseline variables
foreach var in dumB_11 lnB_11 household_expenses div_ves_o_expenses{

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg   `var' S P SxP `var'_lb , robust
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
foreach var in D_1 lnD_2 dum_pct1_D_2 ahorro_suma_meses dum_pct1_D_13 lnD_13 dumB_10 lnB_10 dum_pct1_B_11 {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg   `var' S P SxP , robust
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

*generate Table A9
texdoc init tables\table_a9.tex, replace
tex \begin{table}[h]
tex \caption{"Effects on Savings (without baseline controls)"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}cccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Person.}	& \multicolumn{1}{c}{Both}  	& \multicolumn{1}{c}{Agg.}		& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule
	tex \multicolumn{7}{c}{"Panel A: Savings during intervention period"} \\
	foreach var in ahorro_suma_meses lnD_13 dum_pct1_D_13 {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'	&	`N_`var''				\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')				& 							\\
	}
	tex \\
	tex \multicolumn{7}{c}{"Panel B: Savings target at endline"} \\
	foreach var in  D_1 lnD_2 dum_pct1_D_2 {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'		&	`b_`var'_SxP'`s_`var'_SxP'	& `b_`var'_Agg'`s_`var'_Agg'	&	`N_`var''				\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 				&   (`se_`var'_SxP')			& (`se_`var'_Agg')				& 							\\
	}
	tex \\
	tex \multicolumn{7}{c}{"Panel C: Actual savings at endline"} \\
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
*Table A10
*-------------------------------------------------------------------------------
*Comparing Salience and Personalization Versus Interaction
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear


*salience=2
*generate data
foreach var in ahorro_suma_meses lnD_13 dum_pct1_D_13{

*control mean
	estpost summarize `var' if Tratamiento==2  
	if abs(el(e(mean),1,1))>100{
		local meanSO_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local meanSO_`var': di %12.2fc el(e(mean),1,1)
		}		

*regression
	reg `var' SxP $C_general if Tratamiento!=1 & Tratamiento!=3, robust
	local NSO_`var': di %12.0fc e(N)
	test SxP
	local s_`var'_SO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[SxP])>100{
		local b_`var'_SO: di %12.0fc _b[SxP]
		}
	else{
		local b_`var'_SO: di %12.2fc _b[SxP]
		}
	if abs(_se[SxP])>100{
		local se_`var'_SO: di %12.0fc _se[SxP]
		}
	else{
		local se_`var'_SO: di %12.2fc _se[SxP]
		}
}

*personalization=3
*generate data
foreach var in ahorro_suma_meses lnD_13 dum_pct1_D_13{

*control mean
	estpost summarize `var' if Tratamiento==3  
	if abs(el(e(mean),1,1))>100{
		local meanPO_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local meanPO_`var': di %12.2fc el(e(mean),1,1)
		}		

*regression
	reg `var' SxP $C_general if Tratamiento!=1 & Tratamiento!=2, robust
	local NPO_`var': di %12.0fc e(N)
	test SxP
	local s_`var'_PO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[SxP])>100{
		local b_`var'_PO: di %12.0fc _b[SxP]
		}
	else{
		local b_`var'_PO: di %12.2fc _b[SxP]
		}
	if abs(_se[SxP])>100{
		local se_`var'_PO: di %12.0fc _se[SxP]
		}
	else{
		local se_`var'_PO: di %12.2fc _se[SxP]
		}
}

*generate Table A10
texdoc init tables\table_a10.tex, replace
tex \begin{table}[h]
tex \begin{center}
	tex \begin{tabular}{p{7cm}cccccc}
	tex \toprule
	tex	&	\multicolumn{1}{c}{Mean} 	&	\multicolumn{1}{c}{SxP} 	& \multicolumn{1}{c}{Obser.} &	\multicolumn{1}{c}{Mean} 	&	\multicolumn{1}{c}{SxP} 	& \multicolumn{1}{c}{Obser.}\\
	tex \midrule
	foreach var in  ahorro_suma_meses lnD_13 dum_pct1_D_13 {
	tex   `:var label `var'' &	`meanSO_`var'' & `b_`var'_SO'`s_`var'_SO' &	`NSO_`var'' &	`meanPO_`var'' & `b_`var'_PO'`s_`var'_PO' &	`NPO_`var''				\\
	tex & & (`se_`var'_SO')&&&(`se_`var'_PO')&\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close





*-------------------------------------------------------------------------------	
*Table A11
*-------------------------------------------------------------------------------
*Comparing the Way Personalization and Salience are Combined
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*every treatment
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

*generate data with baseline variables
foreach var in dumB_11 lnB_11 household_expenses div_ves_o_expenses {

*regression vs SP
	reg `var' gr4 gr5 gr6 $C_general `var'_lb if Tratamiento>=4, robust noconstant
	local NN_`var': di %12.0fc e(N)
	foreach x in gr4 gr5 gr6 {
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
	
*regression vs control
	reg   `var' SO PO SP TG PS $C_general `var'_lb, robust
	local N_`var': di %12.0fc e(N)
	foreach x in SO PO SP TG PS {
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
}

*generate data without baseline variables
foreach var in D_1 lnD_2 dum_pct1_D_2 ahorro_suma_meses dum_pct1_D_13 lnD_13 dumB_10 lnB_10 dum_pct1_B_11 {

*regression vs SP
	reg   `var' gr4 gr5 gr6 $C_general  if Tratamiento>=4, robust noconstant
	local NN_`var': di %12.0fc e(N)
	foreach x in gr4 gr5 gr6 {
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

*regression vs control
	reg   `var' SO PO SP TG PS $C_general, robust
	local N_`var': di %12.0fc e(N)
	foreach x in SO PO SP TG PS {
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
}

*generate Table A11
texdoc init tables\table_a11.tex, replace
tex \begin{table}[h]
tex \caption{"Comparing the Way Personalization and Salience are Combined"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}ccccc}
	tex \toprule
	tex 		 		&	\multicolumn{1}{c}{SP} &	\multicolumn{1}{c}{TG} &	\multicolumn{1}{c}{PS} &	\multicolumn{1}{c}{TG}		&	\multicolumn{1}{c}{PS}  \\
	tex \midrule \\
	tex \multicolumn{5}{c}{"Panel A: Savings during intervention period"} \\
	foreach var in ahorro_suma_meses lnD_13 dum_pct1_D_13 {
	tex   `:var label `var''  & `b_`var'_SP'`s_`var'_SP' & `b_`var'_TG'`s_`var'_TG' & `b_`var'_PS'`s_`var'_PS'			& `b_`var'_gr5'`s_`var'_gr5'	&	`b_`var'_gr6'`s_`var'_gr6'		\\
	tex               			& (`se_`var'_SP') & (`se_`var'_TG') & (`se_`var'_PS')       				& (`se_`var'_gr5') 				&   (`se_`var'_gr6')			\\
	}
	tex \\
	tex \multicolumn{5}{c}{"Panel B: Savings target"} \\
	foreach var in  D_1 lnD_2 dum_pct1_D_2 {
	tex   `:var label `var'' 	& `b_`var'_SP'`s_`var'_SP' & `b_`var'_TG'`s_`var'_TG' & `b_`var'_PS'`s_`var'_PS'			& `b_`var'_gr5'`s_`var'_gr5'	&	`b_`var'_gr6'`s_`var'_gr6'	\\
	tex               			& (`se_`var'_SP') & (`se_`var'_TG') & (`se_`var'_PS')       				& (`se_`var'_gr5') 				&   (`se_`var'_gr6')			\\
	}
	tex \\
	tex \multicolumn{5}{c}{"Panel C: Savings at endline"} \\
	foreach var in dumB_11 lnB_11 dum_pct1_B_11 dumB_10 lnB_10 household_expenses div_ves_o_expenses {
	tex   `:var label `var'' 	& `b_`var'_SP'`s_`var'_SP' & `b_`var'_TG'`s_`var'_TG' & `b_`var'_PS'`s_`var'_PS'			& `b_`var'_gr5'`s_`var'_gr5'	&	`b_`var'_gr6'`s_`var'_gr6'	\\
	tex               			& (`se_`var'_SP') & (`se_`var'_TG') & (`se_`var'_PS')       				& (`se_`var'_gr5') 				&   (`se_`var'_gr6')			\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close





*-------------------------------------------------------------------------------	
*Table A12
*-------------------------------------------------------------------------------
*Impact on Savings Compared to Stated Goal
*-------------------------------------------------------------------------------

*generate dummies (personalization only)
gen dum_D151=D_15==1 if D_15~=.
gen dum_D152=D_15==2 if D_15~=.
gen dum_D153=D_15==3 if D_15~=.
gen dum_D154=D_15==4 if D_15~=.
gen dum_D155=D_15==5 if D_15~=.
gen dum_D156=D_15==6 if D_15~=.

*generate data without baseline variables 
foreach var of varlist dum_D15* {

*control mean
	estpost summarize `var' if Tratamiento==3
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}

*regression
	reg   `var' SxP $C_general, robust
	local N_`var': di %12.0fc e(N)
	test SxP
	local s_`var'=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[SxP])>100{
		local b_`var': di %12.0fc _b[SxP]
		}
	else{
		local b_`var': di %12.2fc _b[SxP]
		}
	if abs(_se[SxP])>100{
		local se_`var': di %12.0fc _se[SxP]
		}
	else{
		local se_`var': di %12.2fc _se[SxP]
		}
}
	
*generate Table A12
texdoc init tables\table_a12.tex, replace
tex \begin{table}[h]
tex \caption{"Impact on Savings Compared to Stated Goal"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}cccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{No savings} 	&	\multicolumn{1}{c}{Much less than goal} 	& \multicolumn{1}{c}{Bit less than goal}	& \multicolumn{1}{c}{Same as goal}  	& \multicolumn{1}{c}{Bit more than goal}		& \multicolumn{1}{c}{Much more than goal}	\\
	tex \midrule
	tex   SxP	&	`b_dum_D151'`s_dum_D151'	& `b_dum_D152'`s_dum_D152'			& `b_dum_D153'`s_dum_D153'		&	`b_dum_D154'`s_dum_D154'	& `b_dum_D155'`s_dum_D155'	&	`b_dum_D156'`s_dum_D156'				\\
	tex               			&	(`se_dum_D151')							& (`se_dum_D152')	     				& (`se_dum_D153')				&   (`se_dum_D154')				& (`se_dum_D155')					& 	(`se_dum_D156')							\\
	tex Mean control & `mean_dum_D151'& `mean_dum_D152' & `mean_dum_D153' & `mean_dum_D154' & `mean_dum_D155' & `mean_dum_D156'\\
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close





*-------------------------------------------------------------------------------	
*Table A13
*-------------------------------------------------------------------------------
*Impact on Savings Behavior
*-------------------------------------------------------------------------------

*generate data
foreach var in dum1D_14 dum2D_14 dum3D_14 {

*control mean
	estpost summarize `var' if Tratamiento==1
	if abs(el(e(mean),1,1))>100{
		local mean_`var': di %12.0fc el(e(mean),1,1)
		}
	else{
		local mean_`var': di %12.2fc el(e(mean),1,1)
		}
		
*regression
	reg   `var' S P SxP $C_general, robust
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

*generate Table A13
texdoc init tables\table_a13.tex, replace
tex \begin{table}[h]
tex \caption{"Impact on Savings Behavior"}
tex \begin{center}
	tex \begin{tabular}{p{5cm}cccccc}
	tex \toprule
	tex 						&	\multicolumn{1}{c}{C. Mean} 	&	\multicolumn{1}{c}{Salience} 	& \multicolumn{1}{c}{Personalization}	& \multicolumn{1}{c}{Both}  	& \multicolumn{1}{c}{Agg. Effect}	& \multicolumn{1}{c}{Obs.}	\\
	tex \midrule \\
	foreach var in dum1D_14 dum2D_14 dum3D_14 {
	tex   `:var label `var'' 	&	`mean_`var''				& `b_`var'_S'`s_`var'_S'			& `b_`var'_P'`s_`var'_P'				&	`b_`var'_SxP'`s_`var'_SxP'	&	`b_`var'_Agg'`s_`var'_Agg'		&	`N_`var''				\\
	tex               			&								& (`se_`var'_S')       				& (`se_`var'_P') 						&   (`se_`var'_SxP')			&	(`se_`var'_Agg')				&							\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close





*-------------------------------------------------------------------------------	
*Table A14-A16
*-------------------------------------------------------------------------------
*Bounding Effects Due to Attrition
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*AGGREGATE EFFECT:

*loop without baseline variables
foreach var in D_1 lnD_2 dum_pct1_D_2 ahorro_suma_meses dum_pct1_D_13 lnD_13 dumB_10 lnB_10 dum_pct1_B_11{
	gen nomiss_`var'=`var'~=.
	count if treatment==1 & nomiss_`var'==1	
	qui reg   nomiss_`var' S P SxP  $C_general, robust
	lincom _b[S]+_b[P]+_b[SxP]
	global trim = r(estimate)
	sort treatment nomiss_`var' `var'
	by treatment nomiss_`var': gen order=_n
	preserve
	*lower bound
	count if treatment==1 & `var'~=.
	drop if treatment==1 & nomiss_`var'==1 & $trim>0 & order>(1-$trim)*r(N)
	count if treatment==0 & `var'~=.
	drop if treatment==0 & nomiss_`var'==1 & $trim<=0 & order<abs($trim)*r(N)
	reg   `var' S P SxP $C_general , robust
	lincom _b[S]+_b[P]+_b[SxP]
		local t_value: di abs(r(estimate)/r(se))
		local s_`var'_L=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
		if abs(r(estimate))>100{
			local b_`var'_L: di %12.0fc r(estimate)
			}
		else{
		local b_`var'_L: di %12.2fc r(estimate)
			}
		if abs(r(se))>100{
			local se_`var'_L: di %12.0fc r(se)
			}
		else{
			local se_`var'_L: di %12.2fc r(se)
			}
	restore
	preserve
	*upper bound
	count if treatment==1 & `var'~=.
	drop if treatment==1 & nomiss_`var'==1 & $trim>0 & order<$trim*r(N)
	count if treatment==0 & `var'~=.
	drop if treatment==0 & nomiss_`var'==1 & $trim<=0 & order>(1-abs($trim))*r(N)
	qui reg   `var' S P SxP $C_general , robust
	lincom _b[S]+_b[P]+_b[SxP]
		local t_value: di abs(r(estimate)/r(se))
		local s_`var'_U=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
		if abs(r(estimate))>100{
			local b_`var'_U: di %12.0fc r(estimate)
			}
		else{
		local b_`var'_U: di %12.2fc r(estimate)
			}
		if abs(r(se))>100{
			local se_`var'_U: di %12.0fc r(se)
			}
		else{
			local se_`var'_U: di %12.2fc r(se)
			}	
	restore
	drop order
	drop nomiss_`var'
}

*loop with baseline variables
foreach var in  dumB_11 lnB_11 household_expenses div_ves_o_expenses {
	gen nomiss_`var'=`var'~=.
	count if treatment==1 & nomiss_`var'==1
	reg   nomiss_`var' S P SxP  $C_general `var'_lb , robust
	lincom _b[S]+_b[P]+_b[SxP]
	global trim = r(estimate)
	sort treatment nomiss_`var' `var'
	by treatment nomiss_`var': gen order=_n
	preserve
	*lower bound
	count if treatment==1 & `var'~=.
	drop if treatment==1 & nomiss_`var'==1 & $trim>0 & order>(1-$trim)*r(N)
	count if treatment==0 & `var'~=.
	drop if treatment==0 & nomiss_`var'==1 & $trim<=0 & order<abs($trim)*r(N)
	qui reg   `var' S P SxP $C_general , robust
	lincom _b[S]+_b[P]+_b[SxP]
		local t_value: di abs(r(estimate)/r(se))
		local s_`var'_L=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
		if abs(r(estimate))>100{
			local b_`var'_L: di %12.0fc r(estimate)
			}
		else{
		local b_`var'_L: di %12.2fc r(estimate)
			}
		if abs(r(se))>100{
			local se_`var'_L: di %12.0fc r(se)
			}
		else{
			local se_`var'_L: di %12.2fc r(se)
			}
	restore
	preserve
	*upper bound
	count if treatment==1 & `var'~=.
	drop if treatment==1 & nomiss_`var'==1 & $trim>0 & order<$trim*r(N)
	count if treatment==0 & `var'~=.
	drop if treatment==0 & nomiss_`var'==1 & $trim<=0 & order>(1-abs($trim))*r(N)
	qui reg   `var' S P SxP $C_general , robust
	lincom _b[S]+_b[P]+_b[SxP]
		local t_value: di abs(r(estimate)/r(se))
		local s_`var'_U=cond(`t_value'>2.326,"***",cond(`t_value'>1.96,"**",cond(`t_value'>1.645,"*","")))	
		if abs(r(estimate))>100{
			local b_`var'_U: di %12.0fc r(estimate)
			}
		else{
		local b_`var'_U: di %12.2fc r(estimate)
			}
		if abs(r(se))>100{
			local se_`var'_U: di %12.0fc r(se)
			}
		else{
			local se_`var'_U: di %12.2fc r(se)
			}
	restore
	drop order
	drop nomiss_`var'
}


*SALIENCE ONLY
	gen SO=0
	replace SO=1 if Tratamiento==2
	gen PO=0
	replace PO=1 if Tratamiento==3
	gen SP=0
	replace SP=1 if Tratamiento>=4

*loop without baseline variables
foreach var in D_1 lnD_2 dum_pct1_D_2 ahorro_suma_meses dum_pct1_D_13 lnD_13 dumB_10 lnB_10 dum_pct1_B_11{
	gen nomiss_`var'=`var'~=.
	count if SO==1 & nomiss_`var'==1
	qui reg   nomiss_`var' SO PO SP $C_general, robust
	global trim = _b[SO]
	sort SO nomiss_`var' `var'
	by SO nomiss_`var': gen order=_n
	preserve
	*lower bound
	count if SO==1 & `var'~=.
	drop if SO==1 & nomiss_`var'==1 & $trim>0 & order>(1-$trim)*r(N)
	count if SO==0 & `var'~=.
	drop if SO==0 & nomiss_`var'==1 & $trim<=0 & order<abs($trim)*r(N)
	reg   `var' SO PO SP $C_general , robust
	test SO
	local s_`var'_LSO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[SO])>100{
		local b_`var'_LSO: di %12.0fc _b[SO]
		}
	else{
		local b_`var'_LSO: di %12.2fc _b[SO]
		}
	if abs(_se[SO])>100{
		local se_`var'_LSO: di %12.0fc _se[SO]
		}
	else{
		local se_`var'_LSO: di %12.2fc _se[SO]
		}
	restore
	preserve
	*upper bound
	count if SO==1 & `var'~=.
	drop if SO==1 & nomiss_`var'==1 & $trim>0 & order<$trim*r(N)
	count if SO==0 & `var'~=.
	drop if SO==0 & nomiss_`var'==1 & $trim<=0 & order>(1-abs($trim))*r(N)
	qui reg  `var' SO PO SP $C_general , robust
	test SO
	local s_`var'_USO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[SO])>100{
		local b_`var'_USO: di %12.0fc _b[SO]
		}
	else{
		local b_`var'_USO: di %12.2fc _b[SO]
		}
	if abs(_se[SO])>100{
		local se_`var'_USO: di %12.0fc _se[SO]
		}
	else{
		local se_`var'_USO: di %12.2fc _se[SO]
		}
	restore
	drop order
	drop nomiss_`var'
}

*loop with baseline variables
foreach var in  dumB_11 lnB_11 household_expenses div_ves_o_expenses {
	gen nomiss_`var'=`var'~=.
	count if SO==1 & nomiss_`var'==1	
	reg   nomiss_`var' SO PO SP  $C_general `var'_lb , robust
	global trim = _b[SO]
	sort SO nomiss_`var' `var'
	by SO nomiss_`var': gen order=_n
	preserve
	*lower bound
	count if SO==1 & `var'~=.
	drop if SO==1 & nomiss_`var'==1 & $trim>0 & order>(1-$trim)*r(N)
	count if SO==0 & `var'~=.
	drop if SO==0 & nomiss_`var'==1 & $trim<=0 & order<abs($trim)*r(N)
	qui reg   `var' SO PO SP $C_general , robust
	test SO
	local s_`var'_LSO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[SO])>100{
		local b_`var'_LSO: di %12.0fc _b[SO]
		}
	else{
		local b_`var'_LSO: di %12.2fc _b[SO]
		}
	if abs(_se[SO])>100{
		local se_`var'_LSO: di %12.0fc _se[SO]
		}
	else{
		local se_`var'_LSO: di %12.2fc _se[SO]
		}
	restore
	preserve
	*upper bound
	count if SO==1 & `var'~=.
	drop if SO==1 & nomiss_`var'==1 & $trim>0 & order<$trim*r(N)
	count if SO==0 & `var'~=.
	drop if SO==0 & nomiss_`var'==1 & $trim<=0 & order>(1-abs($trim))*r(N)
	qui reg   `var' SO PO SP $C_general , robust
	test SO
	local s_`var'_USO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[SO])>100{
		local b_`var'_USO: di %12.0fc _b[SO]
		}
	else{
		local b_`var'_USO: di %12.2fc _b[SO]
		}
	if abs(_se[SO])>100{
		local se_`var'_USO: di %12.0fc _se[SO]
		}
	else{
		local se_`var'_USO: di %12.2fc _se[SO]
		}	
	restore
	drop order
	drop nomiss_`var'
}


*PERSONALIZATION ONLY

*loop without baseline variables
foreach var in D_1 lnD_2 dum_pct1_D_2 ahorro_suma_meses dum_pct1_D_13 lnD_13 dumB_10 lnB_10 dum_pct1_B_11{
	gen nomiss_`var'=`var'~=.
	count if PO==1 & nomiss_`var'==1
	qui reg   nomiss_`var' SO PO SP $C_general, robust
	global trim = _b[PO]
	sort PO nomiss_`var' `var'
	by PO nomiss_`var': gen order=_n
	preserve
	*lower bound
	count if PO==1 & `var'~=.
	drop if PO==1 & nomiss_`var'==1 & $trim>0 & order>(1-$trim)*r(N)
	count if PO==0 & `var'~=.
	drop if PO==0 & nomiss_`var'==1 & $trim<=0 & order<abs($trim)*r(N)
	reg   `var' SO PO SP $C_general , robust
	test PO
	local s_`var'_LPO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[PO])>100{
		local b_`var'_LPO: di %12.0fc _b[PO]
		}
	else{
		local b_`var'_LPO: di %12.2fc _b[PO]
		}
	if abs(_se[PO])>100{
		local se_`var'_LPO: di %12.0fc _se[PO]
		}
	else{
		local se_`var'_LPO: di %12.2fc _se[PO]
		}
	restore
	preserve
	*upper bound
	count if PO==1 & `var'~=.
	drop if PO==1 & nomiss_`var'==1 & $trim>0 & order<$trim*r(N)
	count if PO==0 & `var'~=.
	drop if PO==0 & nomiss_`var'==1 & $trim<=0 & order>(1-abs($trim))*r(N)
	qui reg  `var' SO PO SP $C_general , robust
	test PO
	local s_`var'_UPO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[PO])>100{
		local b_`var'_UPO: di %12.0fc _b[PO]
		}
	else{
		local b_`var'_UPO: di %12.2fc _b[PO]
		}
	if abs(_se[PO])>100{
		local se_`var'_UPO: di %12.0fc _se[PO]
		}
	else{
		local se_`var'_UPO: di %12.2fc _se[PO]
		}
	restore
	drop order
	drop nomiss_`var'
}

*loop with baseline variables
foreach var in  dumB_11 lnB_11 household_expenses div_ves_o_expenses {
	gen nomiss_`var'=`var'~=.
	count if PO==1 & nomiss_`var'==1	
	reg   nomiss_`var' SO PO SP  $C_general `var'_lb , robust
	global trim = _b[PO]	
	sort PO nomiss_`var' `var'
	by PO nomiss_`var': gen order=_n	
	preserve
	*lower bound
	count if PO==1 & `var'~=.
	drop if PO==1 & nomiss_`var'==1 & $trim>0 & order>(1-$trim)*r(N)
	count if PO==0 & `var'~=.
	drop if PO==0 & nomiss_`var'==1 & $trim<=0 & order<abs($trim)*r(N)
	qui reg   `var' SO PO SP $C_general , robust
	test PO
	local s_`var'_LPO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[PO])>100{
		local b_`var'_LPO: di %12.0fc _b[PO]
		}
	else{
		local b_`var'_LPO: di %12.2fc _b[PO]
		}
	if abs(_se[PO])>100{
		local se_`var'_LPO: di %12.0fc _se[PO]
		}
	else{
		local se_`var'_LPO: di %12.2fc _se[PO]
		}
	restore	
	preserve
	*upper bound
	count if PO==1 & `var'~=.
	drop if PO==1 & nomiss_`var'==1 & $trim>0 & order<$trim*r(N)
	count if PO==0 & `var'~=.
	drop if PO==0 & nomiss_`var'==1 & $trim<=0 & order>(1-abs($trim))*r(N)
	qui reg   `var' SO PO SP $C_general , robust
	test PO
	local s_`var'_UPO=cond(r(p)<.01,"***",cond(r(p)<.05,"**",cond(r(p)<.1,"*","")))	 
	if abs(_b[PO])>100{
		local b_`var'_UPO: di %12.0fc _b[PO]
		}
	else{
		local b_`var'_UPO: di %12.2fc _b[PO]
		}
	if abs(_se[PO])>100{
		local se_`var'_UPO: di %12.0fc _se[PO]
		}
	else{
		local se_`var'_UPO: di %12.2fc _se[PO]
		}	
	restore
	drop order
	drop nomiss_`var'
}

*generate table A14-A16
texdoc init tables\table_a14_a16.tex, replace
tex \begin{table}[h]
tex \caption{"Bounding Effects Due to Attrition"}
tex \begin{center}
	tex \begin{tabular}{p{7cm}cccccc}
tex \toprule
	tex & \multicolumn{2}{c}{Salien.} & \multicolumn{2}{c}{Person.} & \multicolumn{2}{c}{Agg. Effect} \\
	tex & \multicolumn{1}{c}{LB} & \multicolumn{1}{c}{UB} & \multicolumn{1}{c}{LB} & \multicolumn{1}{c}{UB} & \multicolumn{1}{c}{LB} & \multicolumn{1}{c}{UB}	\\
tex \midrule
	foreach var in ahorro_suma_meses lnD_13 dum_pct1_D_13 D_1 lnD_2 dum_pct1_D_2 dumB_11 lnB_11 dum_pct1_B_11 dumB_10 lnB_10 household_expenses div_ves_o_expenses{
	tex   `:var label `var''	& `b_`var'_LSO'`s_`var'_LSO' & `b_`var'_USO'`s_`var'_USO' & `b_`var'_LPO'`s_`var'_LPO' & `b_`var'_UPO'`s_`var'_UPO' & `b_`var'_L'`s_`var'_L' & `b_`var'_U'`s_`var'_U' \\
	tex  & (`se_`var'_LSO') & (`se_`var'_USO') & (`se_`var'_LPO') & (`se_`var'_UPO') & (`se_`var'_L') & (`se_`var'_U') 	\\
	}
tex \bottomrule
tex \end{tabular}
tex \end{center}
tex \end{table}	
texdoc close


*-------------------------------------------------------------------------------	
*Table A17
*-------------------------------------------------------------------------------
*Testing for Pleasing Surveyor
*-------------------------------------------------------------------------------

clear all	
use "data/base.dta", clear

*goal equals savings?
drop if B_11==.
gen exact_po=(Tratamiento_3_obbjetivo - B_11==0)
replace exact_po=. if Tratamiento_3_obbjetivo - B_11==.
gen exact_sp=(T4A_Monto - B_11==0 | T6_ahorro_A1 - B_11==0)
replace exact_sp=. if T4A_Monto==. & T6_ahorro_A1==.

*personalization only vs both
tab exact_po
tab exact_sp
prtest exact_po==exact_sp





*-------------------------------------------------------------------------------	
*Table A18
*-------------------------------------------------------------------------------
*Testing for Framing
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*table
tab D_9 dumB_11

*McNemar's chi2
mcc D_9 dumB_11





*-------------------------------------------------------------------------------	
*Table A19
*-------------------------------------------------------------------------------
*Impact on Savings by Budget Balance at Baseline
*-------------------------------------------------------------------------------

clear all	
use "data/main_regressions_ready.dta", clear

*interaction
gen gr1		= negative_balance
gen gr2		= positive_balance
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
foreach var in D_1 lnD_2 dum_pct1_D_2 ahorro_suma_meses dum_pct1_D_13 lnD_13 dumB_10 lnB_10 dum_pct1_B_11 lnB_12 dumB_10 lnB_10 {

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
foreach var in dumB_11 lnB_11 div_ves_o_expenses {

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
foreach var in D_1 lnD_2 dum_pct1_D_2 ahorro_suma_meses dum_pct1_D_13 lnD_13 dumB_10 lnB_10 dum_pct1_B_11 lnB_12 dumB_10 lnB_10 {

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
foreach var in dumB_11 lnB_11 div_ves_o_expenses {

*regression
	reg `var' S P SxP gr1 Sx1 Px1 SxPx1 $C_general `var'_lb , robust
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

*generate table A19
texdoc init tables\table_a19.tex, replace
tex \begin{table}[h]
tex \caption{"Impact on Savings by Budget Balance at Baseline"}
tex \begin{center}
	tex \begin{tabular}{p{4cm}cccccccc}
	tex \toprule
	tex 		       			&	\multicolumn{1}{c}{Sal.}		&	\multicolumn{1}{c}{Per.}	&	\multicolumn{1}{c}{SxP}  		&	\multicolumn{1}{c}{Agg.}  		&	\multicolumn{1}{c}{Sal.}  	&	\multicolumn{1}{c}{Per.}  	&	\multicolumn{1}{c}{SxP}  		&	\multicolumn{1}{c}{Agg.}  		\\
	tex \midrule
	tex 		       			&	\multicolumn{4}{c}{Negative balance (N=`N_gr1')}																						&	\multicolumn{4}{c}{Positive balance (N=`N_gr2')}																							\\
	foreach var in ahorro_suma_meses lnD_13 D_1 lnD_2 dum_pct1_D_2 lnB_11 div_ves_o_expenses {
	tex   `:var label `var'' 	&	`b_`var'_S1'`s_`var'_S1'		&	`b_`var'_P1'`s_`var'_P1'	&	`b_`var'_SxP1'`s_`var'_SxP1'	&	`b_`var'_Agg1'`s_`var'_Agg1'	&	`b_`var'_S2'`s_`var'_S2'	&	`b_`var'_P2'`s_`var'_P2'	&	`b_`var'_SxP2'`s_`var'_SxP2'	&	`b_`var'_Agg2'`s_`var'_Agg2'	\\
	tex               			&	(`se_`var'_S1')       			&	(`se_`var'_P1')				&	(`se_`var'_SxP1')				&	(`se_`var'_Agg1')				&	(`se_`var'_S2')       		&	(`se_`var'_P2')				&	(`se_`var'_SxP2')				&	(`se_`var'_Agg2')				\\
	}
	tex \bottomrule
	tex \end{tabular}
tex \end{center}
tex \end{table}
texdoc close


