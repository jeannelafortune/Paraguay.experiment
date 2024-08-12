/*
********************************************************************************
DATA CREATION

REPLICATION FILE:
PAPER: Personalizing or Reminding? How to Better Incentivize Savings 
among Underbanked Individuals

DATASETS NEEDED:
	02-Base_Linea_Final_11_12_2017.dta
	Base_Final_4028_Casos_08_02_2017.dta
	data_public_equifax_consultas.dta
	data_public_equifax_personas.dta
	data_public_equifax_rechazados.dta
	
OUTPUTS:
	credicedula_ready.dta
	base.dta
	main_regressions_ready.dta
	base_plus_equifax_2020.dta
	baseline_charac_ready.dta
*/



*-------------------------------------------------------------------------------
*working directory 
clear all
cd "C:\Users\Ruben\RA team Dropbox\RUBEN JARA\Analisis experiment\replication_file"



*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*clean endline database
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

use "data/02-Base_Linea_Final_11_12_2017.dta", clear

rename _lf_b_8_1_1_vivienda_al B_8_1
label var B_8_1 "B_8_1: ¿Cuanto fue su gasto en vivienda(alquiler)?"
rename _lf_b_8_1_1_vivienda_hi B_8_2
label var B_8_2 "B_8_2: ¿Cuanto fue su gasto en vivienda(pago de crédito hipotecario)?"
rename _lf_b_8_1_2_alimentacion B_8_3
label var B_8_3 "B_8_3: ¿Cuanto fue su gasto en alimentacion?"
rename _lf_b_8_1_3_educacion B_8_4
label var B_8_4 "B_8_4: ¿Cuanto fue su gasto en educacion?"
rename _lf_b_8_1_4_salud B_8_5
label var B_8_5 "B_8_5: ¿Cuanto fue su gasto en salud?"
rename _lf_b_8_1_5_transporte B_8_6
label var B_8_6 "B_8_6: ¿Cuanto fue su gasto en transporte?"
rename _lf_b_8_1_6_baja B_8_7
label var B_8_7 "B_8_7: ¿Cuanto fue su gasto en linea baja?"
rename _lf_b_8_1_7_celular B_8_8
label var B_8_8 "B_8_8: ¿Cuanto fue su gasto en celular?"
rename _lf_b_8_1_8_internet_cable B_8_9
label var B_8_9 "B_8_9: ¿Cuanto fue su gasto en internet y tv cable?"
rename _lf_b_8_1_9_lf_gas B_8_10
label var B_8_10 "B_8_10: ¿Cuanto fue su gasto en gas, leña y carbón?"
rename _lf_b_8_1_10_luz B_8_11
label var B_8_11 "B_8_11: ¿Cuanto fue su gasto en luz?"
rename _lf_b_8_1_11_agua B_8_12
label var B_8_12 "B_8_12: ¿Cuanto fue su gasto en agua?"
rename _lf_b_8_1_12_combustible B_8_13
label var B_8_13 "B_8_13: ¿Cuanto fue su gasto en combustible?"
rename _lf_b_8_1_13_creditos B_8_14
label var B_8_14 "B_8_14: ¿Cuanto fue su gasto en créditos?"
rename _lf_b_8_1_14_diversion B_8_15
label var B_8_15 "B_8_15: ¿Cuanto fue su gasto en diversión?"
rename _lf_b_8_1_15_vestimenta B_8_16
label var B_8_16 "B_8_16: ¿Cuanto fue su gasto en vestimenta?"
rename _lf_b_8_1_16_otros B_8_17
label var B_8_17 "B_8_17: ¿Cuanto fue su gasto en otros?"
rename _lf_b_ingreso_gasto B_10 
label var B_10 "B_10: Diferencia entre ingresos y gastos" 
rename _lf_b_11_ahorroind B_11 
label var B_11 "B_1: ¿Cuántos Gs. ahorra mensualmente usted como persona individual" 
rename _lf_b_12_ahorrohogar B_12 
label var B_12 "B_12: ¿Cuántos Gs. ahorra mensualmente su hogar?" 
rename _lf_b_13_problemas_gastos B_13 
label var B_13 "B_13: Número meses con problemas para cubrir sus gastos" 
rename _lf_b_17_ahorrar_a B_17_1_ahorrar 
label var B_17_1_ahorrar "B_17_1_ahorrar: Pensó en ahorrar por si esto vuelve a pasar?" 
rename _lf_b_17_ahorrar_b B_17_2_ahorrar 
label var B_17_2_ahorrar "B_17_2_ahorrar: Pensó en ahorrar por si esto vuelve a pasar?" 
rename _lf_b_17_ahorrar_c B_17_3_ahorrar 
label var B_17_3_ahorrar "B_17_3_ahorrar: Pensó en ahorrar por si esto vuelve a pasar?" 
rename _lf_b_17_ahorrar_d B_17_4_ahorrar 
label var B_17_4_ahorrar "B_17_4_ahorrar: Pensó en ahorrar por si esto vuelve a pasar?" 
rename _lf_b_17_ahorrar_e B_17_5_ahorrar 
label var B_17_5_ahorrar "B_17_5_ahorrar: Pensó en ahorrar por si esto vuelve a pasar?" 
rename _lf_b_17_ahorrar_f B_17_6_ahorrar 
label var B_17_6_ahorrar "B_17_6_ahorrar: Pensó en ahorrar por si esto vuelve a pasar?" 
rename _lf_c_1_credito_entidad C_1 
label var C_1 "C_1: En el último año ¿Ha solicitado un crédito o recibido un préstamo?" 
rename _lf_c_1_credito_entidad1 C_1_1 
label var C_1_1 "C_1_1: Crédito solicitado en la entidad 1" 
rename _lf_c_3_2_monto_1 C_3_monto1 
label var C_3_monto1 "C_3_monto1: Monto del crédito que solicitó" 
rename _lf_c_3_3_aprobado_1 C_3_aprob1
label var C_3_aprob1 "C_3_aprob1: ¿Se lo aprobarón?" 
rename _lf_c_3_3_aprobado_monto_1 C_3_montocred1 
label var C_3_montocred1 "C_3_montocred1: Monto del crédito aprobado" 
rename _lf_c_3_6_nopago_1 C_3_nopag1 
label var C_3_nopag1 "C_3_nopag1: ¿Dejo de pagar el crédito sin haber terminado de pagar las cuotas?" 
rename _lf_c_3_2_monto_2 C_3_monto2 
label var C_3_monto2 "C_3_monto2: Monto del crédito que solicitó" 
rename _lf_c_3_3_aprobado_2 C_3_aprob2 
label var C_3_aprob2 "C_3_aprob2: ¿Se lo aprobarón?" 
rename _lf_c_3_3_aprobado_monto_2 C_3_montocred2 
label var C_3_montocred2 "C_3_montocred2: Monto del crédito aprobado" 
rename _lf_c_3_6_nopago_2 C_3_nopag2 
label var C_3_nopag2 "C_3_nopag2: ¿Dejo de pagar el crédito sin haber terminado de pagar las cuotas?" 
rename _lf_c_3_2_monto_3 C_3_monto3 
label var C_3_monto3 "C_3_monto3: Monto del crédito que solicitó" 
rename _lf_c_3_3_aprobado_3 C_3_aprob3 
label var C_3_aprob3 "C_3_aprob3: ¿Se lo aprobarón?" 
rename _lf_c_3_3_aprobado_monto_3 C_3_montocred3 
label var C_3_montocred3 "C_3_montocred3: Monto del crédito aprobado" 
rename _lf_c_3_6_nopago_3 C_3_nopag3 
label var C_3_nopag3 "C_3_nopag3: ¿Dejo de pagar el crédito sin haber terminado de pagar las cuotas?" 
rename _lf_c_3_2_monto_4 C_3_monto4 
label var C_3_monto4 "C_3_monto4: Monto del crédito que solicitó" 
rename _lf_c_3_3_aprobado_4 C_3_aprob4 
label var C_3_aprob4 "C_3_aprob4: ¿Se lo aprobarón?" 
rename _lf_c_3_3_aprobado_monto_4 C_3_montocred4 
label var C_3_montocred4 "C_3_montocred4: Monto del crédito aprobado" 
rename _lf_c_3_6_nopago_4 C_3_nopag4 
label var C_3_nopag4 "C_3_nopag4: ¿Dejo de pagar el crédito sin haber terminado de pagar las cuotas?" 
rename _lf_c_3_2_monto_5 C_3_monto5 
label var C_3_monto5 "C_3_monto5: Monto del crédito que solicitó" 
rename _lf_c_3_3_aprobado_5 C_3_aprob5 
label var C_3_aprob5 "C_3_aprob5: ¿Se lo aprobarón?" 
rename _lf_c_3_3_aprobado_monto_5 C_3_montocred5 
label var C_3_montocred5 "C_3_montocred5: Monto del crédito aprobado" 
rename _lf_c_3_6_nopago_5 C_3_nopag5 
label var C_3_nopag5 "C_3_nopag5: ¿Dejo de pagar el crédito sin haber terminado de pagar las cuotas?" 
rename _lf_c_3_2_monto_6 C_3_monto6 
label var C_3_monto6 "C_3_monto6: Monto del crédito que solicitó" 
rename _lf_c_3_3_aprobado_6 C_3_aprob6 
label var C_3_aprob6 "C_3_aprob6: ¿Se lo aprobarón?" 
rename _lf_c_3_3_aprobado_monto_6 C_3_montocred6 
label var C_3_montocred6 "C_3_montocred6: Monto del crédito aprobado" 
rename _lf_c_3_6_nopago_6 C_3_nopag6 
label var C_3_nopag6 "C_3_nopag6: ¿Dejo de pagar el crédito sin haber terminado de pagar las cuotas?" 
rename _lf_c_3_2_monto_7 C_3_monto7 
label var C_3_monto7 "C_3_monto7: Monto del crédito que solicitó" 
rename _lf_c_3_3_aprobado_7 C_3_aprob7 
label var C_3_aprob7 "C_3_aprob7: ¿Se lo aprobarón?" 
rename _lf_c_3_3_aprobado_monto_7 C_3_montocred7 
label var C_3_montocred7 "C_3_montocred7: Monto del crédito aprobado" 
rename _lf_c_3_6_nopago_7 C_3_nopag7 
label var C_3_nopag7 "C_3_nopag7: ¿Dejo de pagar el crédito sin haber terminado de pagar las cuotas?" 
rename _lf_c_11_satisfaccion C_11 
label var C_11 "C_11: De 1 a 10, ¿Que tan satisfecho está hoy con la situación financiera de su hogar?" 
rename _lf_c_11_1_suenio C_11_1 
label var C_11_1 "C_11_1: ¿Sus preocupaciones le han hecho perder el sueño?" 
rename _lf_c_11_2_tension C_11_2 
label var C_11_2 "C_11_2: ¿Estuvo agobiado y tensionado?" 
rename _lf_c_11_3_nervios C_11_3 
label var C_11_3 "C_11_3: ¿Estuvo nervioso o malhumorado?" 
rename _lf_c_11_4_sensacion C_11_4 
label var C_11_4 "C_11_4: ¿Ha tenido sensación de que todo se le viene encima?" 
rename _lf_d_1_meta D_1 
label var D_1 "D_1: En el último mes, ¿tuvo usted una meta de ahorro?" 
rename _lf_d_2_ahorro_monto D_2 
label var D_2 "D_2: ¿Cuál es el monto que usted tiene como meta para ahorrar?" 
rename _lf_d_3_encuesta_hogar D_3 
label var D_3 "D_3: ¿Recuerda que el año pasado un encuestador lo visitó en su hogar?" 
rename _d_4_1 D_4_1 
label var D_4_1 "D_4_1: Me mostraron una frase sobre lo importante que es ahorrar en general" 
rename _d_4_2 D_4_2 
label var D_4_2 "D_4_2: Me mostraron información sobre cuánto puedo ahorrar cada mes" 
rename _d_4_3 D_4_3 
label var D_4_3 "D_4_3: Me sugirieron ahorrar un 10% de mis ingresos cada mes" 
rename _d_4_5 D_4_5 
label var D_4_5 "D_4_5: Me explicaron que comprar a crédito es más caro que ahorrar para comprar" 
rename _lf_d_6_mensaje_celular D_6 
label var D_6 "D_6: ¿Usted recibió mensajes en su celular los últimos meses sobre el ahorro?" 
rename _lf_d_7_informacion_sms D_7 
label var D_7 "D_7: ¿Que información recuerda del SMS?" 
rename _lf_d_9_ahorro_ D_9 
label var D_9 "D_9: En los últimos 6 meses, ¿Ahorró?" 
rename _lf_d_12_ahorro_meses_jul16 D_12_1 
label var D_12_1 "D_12_1: Ahorró en Julio 2016"
rename _lf_d_12_ahorro_meses_ago16 D_12_2
label var D_12_2 "D_12_2: Ahorró en Agosto 2016"
rename _lf_d_12_ahorro_meses_sep16 D_12_3
label var D_12_3 "D_12_3: Ahorró en Septiembre 2016"
rename _lf_d_12_ahorro_meses_oct16 D_12_4
label var D_12_4 "D_12_4: Ahorró en Octubre 2016"
rename _lf_d_12_ahorro_meses_nov16 D_12_5
label var D_12_5 "D_12_5: Ahorró en Noviembre 2016"
rename _lf_d_12_ahorro_meses_dic16 D_12_6
label var D_12_6 "D_12_6: Ahorró en Diciembre 2016"
rename _lf_d_12_ahorro_meses_ene17 D_12_7
label var D_12_7 "D_12_7: Ahorró en Enero 2017" 
rename _lf_d_12_ahorro_meses_feb17 D_12_8
label var D_12_8 "D_12_8: Ahorró en Febrero 2017" 
rename _lf_d_12_ahorro_meses_mar17 D_12_9
label var D_12_9 "D_12_9: Ahorró en Marzo 2017" 
rename _lf_d_10_ahorro D_10
label var D_10 "D_10: Desde que le realizaron la primera encuesta y los 6 meses siguientes, ¿Ahorró?"
rename _lf_d_12_ahorro_meses_abr17 D_12_10
label var D_12_10 "D_12_10: Ahorró en Abril 2017" 
rename _lf_d_12_ahorro_meses_may17 D_12_11
label var D_12_11 "D_12_11: Ahorró en Mayo 2017" 
rename _lf_d_12_ahorro_meses_jun17 D_12_12
label var D_12_12 "D_12_12: Ahorró en Junio 2017" 
rename _lf_d_13_ahorro_monto D_13 
label var D_13 "D_13: Entre la 1era encuesta y los 6 meses siguientes ¿Cuánto logro ahorrar?" 
rename _lf_d_14_ahorrar_accion D_14 
label var D_14 "D_14: ¿Que acción tomó para ahorrar?" 
rename _lf_d_15_meta_ahorro D_15 
label var D_15 "D_15: Declaró q queria ahorrar X mensuales. Con cual afirmación se identifica más" 

tempfile endline
save "`endline'"



*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
*master database
*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------

use "data/Base_Final_4028_Casos_08_02_2017.dta", clear

rename key _lb_key
merge 1:1 _lb_key using "`endline'"

*variables

label variable _3_4_distrito "distrito" 
label variable _a_1_edad "edad" 
label variable _a_2_sexo "sexo"	
label variable _a_3_educacion "Años de educacion" 
label variable _a_4_estado "Estado civil" 
label variable _a_5_jefe "Jefe de hogar" 
label variable _a_6_trabajo "¿Trabajo ultimo mes?" 
label variable _b_5_riesgo "Riesgo" 
label variable _c_1_personas "numero de personas ..." 
label variable _c_6_ingreso_total "Ingreso total" 
label variable _c_12_ahorrohogar "Ahorro hogar" 
label variable _c_11_ahorroind "Ahorro individual" 
label variable _c_15_caidas "N de meses con probl" 
label variable _a_8_categoria "categoria" 

rename _c_8_1_1_vivienda			_c_8_2 
rename _c_8_1_2_alimentacion		_c_8_3 
rename _c_8_1_3_educacion			_c_8_4 
rename _c_8_1_4_salud				_c_8_5 
rename _c_8_1_5_transporte			_c_8_6 
rename _c_8_1_6_baja				_c_8_7 
rename _c_8_1_7_celular				_c_8_8 
rename _c_8_1_8_internet_cable		_c_8_9 
rename _c_8_1_9_gas					_c_8_10 
rename _c_8_1_10_luz				_c_8_11 
rename _c_8_1_11_agua				_c_8_12 
rename _c_8_1_12_combustible		_c_8_13 
rename _c_8_1_13_creditos			_c_8_14 
rename _c_8_1_14_diversion			_c_8_15 
rename _c_8_1_15_vestimenta			_c_8_16 
rename _c_8_1_16_otros				_c_8_17 
gen _c_8_1 = _c_8_2 

*_3_4_: distrito
recode _3_4_distrito (.=98) 

*_a_2_: sex
gen Female=0 
replace Female=1 	if	_a_2_sexo==1 

*_a_4_: single
gen single=0 
replace single=1 if _a_4_estado==1|_a_4_estado==4|_a_4_estado==5 

*_a_5_: jefe de hogar
replace _a_5_jefe=0 if _a_5_jefe==2 

*_a_6_: trabajo
replace _a_6_trabajo=0 if _a_6_trabajo==2 

*_a_8_: categoria Profesional
replace _a_8_categoria=6 if _a_8_categoria==. 

*_b_6_: Financial litteracy
gen litt = 0 
replace litt = 1 if _b_6_herencia==1 & _b_7_cuenta==1 
replace litt = 1 if _b_6_herencia==1 & _b_8_cuenta2==3 
replace litt = 1 if _b_7_cuenta==1   & _b_8_cuenta2==3 
gen no_litt = 1-litt 

*_c_6_: baseline ingreso total
gen		ln_c_6_ingreso_total=ln(1+_c_6_ingreso_total) 

*_c_8_: baseline gastos
gen		ln_c_8_gastos_total	=ln(1+_c_8_gastos_total) 

*_c_10_: baseline budget balance
gen 	ln_c_ingreso_gasto	= ln(_c_ingreso_gasto+1) 
replace ln_c_ingreso_gasto 	= -ln(-_c_ingreso_gasto+1) if _c_ingreso_gasto<0 

*positive account balance
gen positive_balance=0 
replace positive_balance=1 if _c_ingreso_gasto>0 
gen		negative_balance=1-positive_balance 

*_c_11_: baseline ahorro individual
replace _c_11_ahorroind		=. if _c_11_ahorroind==-99 
gen ahorro_ind = _c_11_ahorroind 
replace ahorro_ind = 0 if _c_11_ahorroind==. 
gen ln_ahorro_ind = ln(ahorro_ind+1) 
gen savings=0 
replace savings = 1 if _c_11_ahorroind>0 
replace savings = 1 if _c_11_ahorroind==. 

*discrepancy
gen ahorro = _c_11_ahorroind
replace ahorro = 0 if _c_11_ahorroind==. 
gen difference = ahorro - _c_ingreso_gasto 
gen discrepancy = 0 
replace discrepancy = 1 if difference<-322025 

*_c_12_: baseline ahorro hogar
replace _c_12_ahorrohogar	=. if _c_12_ahorrohogar==-99 
replace _c_12_ahorrohogar	=. if _c_12_ahorrohogar==99 
gen ahorro_hog = _c_12_ahorrohogar 
replace ahorro_hog = 0 if _c_12_ahorrohogar==. 
gen ln_ahorro_hog = ln(ahorro_hog+1) 

*_c_13_: meses_dificultad
rename _c_13_meses_dificultad _c_13_meses_dif 
gen dum_c_13_meses_dif = 0 
replace dum_c_13_meses_dif = 1 if _c_13_meses_dif>0 
gen _c_13_num_mon = _c_13_meses_dif 
replace _c_13_num_mon = . if _c_13_meses_dif==0 

*_c_15_: meses dificultad por caida de ingreso
replace _c_15_caidas = 0 if _c_13_meses_dif==0 
gen dum_c_15_caidas = 0 
replace dum_c_15_caidas = 1 if _c_15_caidas>0 
gen _c_15_num_mon = _c_15_caidas 
replace _c_15_num_mon = . if _c_15_caidas==0 

*_c_14_: meses dificultad por gastos inesperados
gen 	_c_14_gastos = _c_13_meses_dif - _c_15_caidas
replace	_c_14_gastos = 0 if _c_14_gastos<= 0

*_c_16_: monto de caida de ingreso
gen pct_c_16_monto = _c_16_monto/_c_6_ingreso_total 

*_c_17_: monto de gastos inesperados
foreach var in _c_17_monto_a _c_17_monto_b _c_17_monto_c _c_17_monto_d _c_17_monto_e _c_17_monto_f{
	replace `var' = . if `var'==-99
} 
egen _c_17_monto = rowtotal(_c_17_monto_a _c_17_monto_b _c_17_monto_c _c_17_monto_d _c_17_monto_e _c_17_monto_f) 
replace _c_17_monto =. if _c_17_monto==0 
gen pct_c_17_monto = _c_17_monto/_c_6_ingreso_total 

*Ha pensado alguna vez en ahorrar por si le vuelve a pasar?
foreach var in _c_17_ahorrar_a _c_17_ahorrar_b _c_17_ahorrar_c _c_17_ahorrar_d _c_17_ahorrar_e _c_17_ahorrar_f {
replace `var' = . if `var'==2
replace `var' = . if `var'==3
} 
egen dum_c_17 = rowtotal(_c_17_ahorrar_a _c_17_ahorrar_b _c_17_ahorrar_c _c_17_ahorrar_d _c_17_ahorrar_e _c_17_ahorrar_f) 
replace dum_c_17 = 1 if dum_c_17>1 

*_d_1_: Requested credit
gen dum_d_1=0 
replace dum_d_1=1 if _d_1_credito_entidad!="7" 
label variable dum_d_1 "Si solicitó/recibió crédito en el último año" 
 
*Total ammount requested
foreach var in _d_2_2_monto_1 _d_2_2_monto_2 _d_2_2_monto_3 _d_2_2_monto_4 _d_2_2_monto_5 _d_2_2_monto_6 {
replace `var' = . if `var'==99
} 
egen float _d_2_montototal = rowtotal(_d_2_2_monto_1 _d_2_2_monto_2 _d_2_2_monto_3 _d_2_2_monto_4 _d_2_2_monto_5 _d_2_2_monto_6)
replace _d_2_montototal=0 if dum_d_1==0 

*Total ammount approuved
foreach var in _d_2_3_aprobado_monto_1 _d_2_3_aprobado_monto_2 _d_2_3_aprobado_monto_3 _d_2_3_aprobado_monto_4 _d_2_3_aprobado_monto_5 _d_2_3_aprobado_monto_6 {
replace `var' = . if `var'==99
} 
egen float _d_2_montototalaprob = rowtotal(_d_2_3_aprobado_monto_1 _d_2_3_aprobado_monto_2 _d_2_3_aprobado_monto_3 _d_2_3_aprobado_monto_4 _d_2_3_aprobado_monto_5 _d_2_3_aprobado_monto_6) 
replace _d_2_montototalaprob=0 if dum_d_1==0 

*Credit unpaid
gen dum_d_2_nopag = 0 
replace dum_d_2_nopag = 1 if _d_2_10_nopago_1==1 | _d_2_10_nopago_2==1 | _d_2_10_nopago_3==1 | _d_2_10_nopago_4==1 | _d_2_10_nopago_5==1 | _d_2_10_nopago_6==1 
replace dum_d_2_nopag = 0 if dum_d_1==0 

*_d_27_: stress and mental distress indicators
gen		d_suenio=0 
replace	d_suenio=1 if _d_27_1==3|_d_27_1==4 
label	variable d_suenio  "Pierde Sueño" 

gen		d_tension=0 
replace	d_tension=1 if _d_27_2==3|_d_27_2==4 
label	variable d_tension  "Esta tenso" 

gen		d_nervios=0 
replace	d_nervios=1 if _d_27_3==3|_d_27_3==4 
label	variable d_nervios  "Esta nervioso" 

gen		d_sensacion=0 
replace	d_sensacion=1 if _d_27_4==3|_d_27_4==4 
label	variable d_sensacion  "Sensacion de que todo..." 

*Index well-being
egen std_d_suenio		= std(d_suenio)
egen std_d_tension		= std(d_tension)
egen std_d_nervios		= std(d_nervios)
egen std_d_sensacion	= std(d_sensacion)
egen index_baseline = rowmean(std_d_suenio std_d_tension std_d_nervios std_d_sensacion) 
drop std_d_suenio std_d_tension std_d_nervios std_d_sensacion 

*B_10: Diferencia ingresos-gastos
gen		lnB_10 = ln(B_10+1) 
replace	lnB_10 = -ln(-B_10+1) if B_10<0 
label variable lnB_10 "Diferencia entre ingresos y gastos ultimo mes. Logaritmo" 
gen dumB_10 = 0 
replace dumB_10 = 1 if B_10>0 
replace dumB_10 = . if B_10==. 

*B_11: ¿Cuántos Gs. ahorra mensualmente usted como persona individual?
replace B_11=. if B_11==-99 
gen lnB_11=ln(B_11+1) 
label variable lnB_11 "Ahorro mensual individual. Logaritmo" 

gen pct1B_11=(B_11/_c_6_ingreso_total) 
replace pct1B_11=. if _c_6_ingreso_total<=0 

gen dum_pct1_B_11 = 0 
replace dum_pct1_B_11 = 1 if pct1B_11>0.05 
replace dum_pct1_B_11 = 1 if _c_6_ingreso_total<=0 
replace dum_pct1_B_11 = . if B_11==. 

gen dumB_11=0 
replace dumB_11=1 if B_11>0 
replace dumB_11=. if B_11==. 

*B_12: Ahorro mensual del hogar
replace B_12=. if B_12==-99 
gen lnB_12=ln(B_12+1) 
label variable lnB_12 "Ahorro mensual del hogar. Logaritmo" 

*B_13: Numero de meses con problemas para cubrir gastos
sum B_13 
gen B_13_num_mon = B_13 

*Ha pensado alguna vez en ahorrar por si le vuelve a pasar?
foreach var in B_17_1_ahorrar B_17_2_ahorrar B_17_3_ahorrar B_17_4_ahorrar B_17_5_ahorrar B_17_6_ahorrar {
replace `var' = . if `var'==2
replace `var' = . if `var'==3
} 
egen dumB_17 = rowtotal(B_17_1_ahorrar B_17_2_ahorrar B_17_3_ahorrar B_17_4_ahorrar B_17_5_ahorrar B_17_6_ahorrar) 
replace dumB_17 = 1 if dumB_17>1 
sum dumB_17 

*C_1:En el ultimo año, ha solicitado/recibido un crédito?(a que entidad?
codebook C_1_1 
tab C_1,plot 
*Dummy para C_1: Si o no?
gen dumC_1=0 
replace dumC_1=1 if C_1_1!=9 
replace dumC_1=. if C_1=="" 
label variable dumC_1 "Si solicitó/recibió crédito en el último año" 
tab dumC_1 

*Dummy para cada uno
  
*Creditos solicitados
foreach var in C_3_monto1  C_3_monto2  C_3_monto3 C_3_monto4 C_3_monto5 C_3_monto6 C_3_monto7 {
replace `var' = . if `var'==99 | `var' ==2
} 
egen float C_3_montototal = rowtotal(C_3_monto1  C_3_monto2  C_3_monto3 C_3_monto4 C_3_monto5 C_3_monto6 C_3_monto7) 
replace C_3_montototal=. if C_3_monto1==. 
replace C_3_montototal=0 if dumC_1==0 
gen logC_3_montototal = log(C_3_montototal)
 
*Creditos aprobados
tabstat C_3_montocred1 C_3_montocred2 C_3_montocred3 C_3_montocred4 C_3_montocred5 C_3_montocred6 C_3_montocred7 
 
*Monto total aprobado
foreach var in C_3_montocred1  C_3_montocred2  C_3_montocred3 C_3_montocred4 C_3_montocred5 C_3_montocred6 C_3_montocred7 {
replace `var' = . if `var'==99 
} 
egen float C_3_montototalaprob = rowtotal(C_3_montocred1 C_3_montocred2 C_3_montocred3 C_3_montocred4 C_3_montocred5 C_3_montocred6 C_3_montocred7) 
replace C_3_montototalaprob=. if dumC_1==. 
replace C_3_montototalaprob=. if C_3_montocred1==. & C_3_montocred2==. & C_3_montocred3==. & C_3_montocred4==. & C_3_montocred5==. & C_3_montocred6==. & C_3_montocred7==. 
replace C_3_montototalaprob=0 if dumC_1==0 

*Credit unpaid
gen dumC_3_nopag = 0 
replace dumC_3_nopag = 1 if C_3_nopag1==1 | C_3_nopag2==1 | C_3_nopag3==1 | C_3_nopag4==1 | C_3_nopag5==1 | C_3_nopag6==1 | C_3_nopag7==1 
replace dumC_3_nopag = 0 if dumC_1==0 
replace dumC_3_nopag = . if dumC_1==. 

*C_11_1: ¿Sus preocupaciones le han hecho perder el sueño?
gen C_suenio=C_11_1==3|C_11_1==4 if C_11_1~=. 

*C_11_2: ¿Estuvo agobiado y tensionado?
gen C_tension=C_11_2==3 |C_11_2==4 if C_11_2~=. 

*C_11_3: ¿Estuvo nervioso o malhumorado?
gen C_nervios=C_11_3==3 |C_11_3==4 if C_11_3~=. 

*C_11_4: ¿Ha tenido sensación de que todo se le viene encima?
gen C_sensacion=C_11_4==3|C_11_4==4 if C_11_4~=. 

*Generate index of well-being
egen std_C_suenio		= std(C_suenio) 
egen std_C_tension		= std(C_tension) 
egen std_C_nervios		= std(C_nervios) 
egen std_C_sensacion	= std(C_sensacion) 
egen index_endline = rowmean(std_C_suenio std_C_tension std_C_nervios std_C_sensacion) 
drop std_C_suenio std_C_tension std_C_nervios std_C_sensacion

*D_1: En el último mes, tuvo usted meta de ahorro?
replace D_1=0 if D_1==2 
label variable D_1 "En el último mes, tuvo usted meta de ahorro?" 

*D_2: ¿Cuál es el monto que usted tiene como meta para ahorrar?
replace D_2=0 if D_1==0 
replace D_2=. if D_2==-99 
replace D_2=. if D_2==99 
label variable D_2 "¿Cuál es el monto que usted tiene como meta para ahorrar?" 
gen lnD_2=ln(D_2+1) 
label variable lnD_2 "¿Cuál es el monto que usted tiene como meta para ahorrar? Logaritmo" 
gen pct1D_2=(D_2/_c_6_ingreso_total) 
replace pct1D_2=. if _c_6_ingreso_total<=0 
gen dum_pct1_D_2 = 0 
replace dum_pct1_D_2 = 1 if pct1D_2>0.05 
replace dum_pct1_D_2 = 1 if _c_6_ingreso_total<=0 
replace dum_pct1_D_2 = . if D_2==. 

*D_6: ¿Usted recibió mensajes en su celular los últimos meses sobre el ahorro?
replace D_6=0 if D_6==2 
label variable D_6 "¿Usted recibió mensajes en su celular los últimos meses sobre el ahorro?" 

*D_7: ¿Que información recuerda del SMS?
gen dumD_71=0 
replace dumD_71=1 if D_7==1 
replace dumD_71=. if _merge==1 
label variable dumD_71 "Era un mensaje motivandome a ahorrar en general" 
gen dumD_72=0 
replace dumD_72=1 if D_7==2 
replace dumD_72=. if _merge==1 
label variable dumD_72 "Era un mensaje motivandome a ahorrar un monto de dinero especifico al mes" 

*Recuerda?
replace D_9=0 if D_9==2 
label variable D_9 "En los ultimos seis meses. ¿Ahorro?" 
replace D_3=0 if D_3==2 
label variable D_3 "¿Recuerda que el año pasado el encuestador visito su hogar?" 
replace D_4_1=0 if D_4_1==2 
label variable D_4_1 "Me mostraron una frase sobre lo importante que es ahorrar en general" 
replace D_4_2=0 if D_4_2==2 
label variable D_4_2 " Me mostraron información sobre cuanto puedo ahorrar cada mes" 
replace D_4_3=0 if D_4_3==2 
label variable D_4_3 "Me sugirieron ahorrar un 10 por ciento de mis ingresos cada mes" 
replace D_4_5=0 if D_4_5==2 
label variable D_4_5 "Me explicaron que comprar a crédito es más caro que ahorrar para comprar" 
replace D_9=0 if D_9==2 

*Cuando ahorró?
tab1  D_12_1 D_12_2 D_12_3 D_12_4 D_12_5 D_12_6 D_12_7 D_12_8 D_12_9 D_12_10 D_12_11 D_12_12

*D_12:
tabulate comienzo1, generate(g)
gen mes7=0
replace mes7=1 if g1==1 | g2==1 | g3==1 | g4==1 | g5==1 | g6==1 | g7==1 | g8==1 | g9==1 | g10==1 
gen mes8=0
replace mes8=1 if g11==1 | g12==1 | g13==1 | g14==1 | g15==1 | g16==1 | g17==1 | g18==1 | g19==1 | g20==1 | g20==1 | g22==1 | g23==1 | g24==1 | g25==1 | g26==1 | g27==1 | g28==1 | g29==1 |  g27==1 | g28==1 | g29==1 | g30==1 | g31==1 | g32==1 |g33==1 | g34==1 | g35==1 | g36==1 | g37==1 
 
gen mes9=0
replace mes9=1 if g38==1 | g39==1 | g40==1 | g41==1 | g42==1 | g43==1 | g44==1 | g45==1 | g46==1 | g47==1 | g48==1 

gen mes10=0
replace mes10=1 if g49==1 | g50==1 | g51==1 | g52==1 | g53==1 | g54==1 | g55==1 | g56==1 | g57==1 | g58==1 | g59==1 | g60==1 | g61==1 | g62==1 | g63==1   

gen mes11=0
replace mes11=1 if g64==1 | g65==1 | g66==1 | g67==1 | g68==1 | g69==1 | g70==1 | g71==1 | g72==1 | g73==1 | g74==1 | g75==1 | g76==1 | g77==1 | g78==1 | g79==1 | g80==1 | g81==1 | g82==1 | g83==1 | g84==1 | g85==1 | g86==1 | g87==1 | g88==1 |g89==1 | g90==1 | g91==1 

gen mes12=0
replace mes12=1 if g92==1 | g93==1 | g94==1 | g95==1 | g96==1 | g97==1 | g98==1 | g99==1 | g11==1 

gen ahorro_1_mes=D_12_1 if mes7==1
label variable ahorro_1_mes "Ahorro el primer mes"
gen ahorro_2_mes=D_12_2 if mes7==1
label variable ahorro_2_mes "Ahorro el segundo mes"
gen ahorro_3_mes=D_12_3 if mes7==1
label variable ahorro_3_mes "Ahorro el tercer mes"
gen ahorro_4_mes=D_12_4 if mes7==1
label variable ahorro_4_mes "Ahorro el cuarto mes"
gen ahorro_5_mes=D_12_5 if mes7==1
label variable ahorro_5_mes "Ahorro el quinto mes"
gen ahorro_6_mes=D_12_6 if mes7==1
label variable ahorro_6_mes "Ahorro el sexto mes"
gen ahorro_7_mes=D_12_7 if mes7==1
label variable ahorro_7_mes "Ahorro el septimo mes"

replace ahorro_1_mes= D_12_2 if mes8==1
replace ahorro_2_mes= D_12_3 if mes8==1
replace ahorro_3_mes= D_12_4 if mes8==1
replace ahorro_4_mes= D_12_5 if mes8==1
replace ahorro_5_mes= D_12_6 if mes8==1
replace ahorro_6_mes= D_12_7 if mes8==1
replace ahorro_7_mes= D_12_8 if mes8==1

replace ahorro_1_mes= D_12_3 if mes9==1
replace ahorro_2_mes= D_12_4 if mes9==1
replace ahorro_3_mes= D_12_5 if mes9==1
replace ahorro_4_mes= D_12_6 if mes9==1
replace ahorro_5_mes= D_12_7 if mes9==1
replace ahorro_6_mes= D_12_8 if mes9==1
replace ahorro_7_mes= D_12_9 if mes9==1

replace ahorro_1_mes= D_12_4 if mes10==1
replace ahorro_2_mes= D_12_5 if mes10==1
replace ahorro_3_mes= D_12_6 if mes10==1
replace ahorro_4_mes= D_12_7 if mes10==1
replace ahorro_5_mes= D_12_8 if mes10==1
replace ahorro_6_mes= D_12_9 if mes10==1
replace ahorro_7_mes= D_12_10 if mes10==1

replace ahorro_1_mes= D_12_5 if mes11==1
replace ahorro_2_mes= D_12_6 if mes11==1
replace ahorro_3_mes= D_12_7 if mes11==1
replace ahorro_4_mes= D_12_8 if mes11==1
replace ahorro_5_mes= D_12_9 if mes11==1
replace ahorro_6_mes= D_12_10 if mes11==1
replace ahorro_7_mes= D_12_11 if mes11==1

replace ahorro_1_mes= D_12_6 if mes12==1
replace ahorro_2_mes= D_12_7 if mes12==1
replace ahorro_3_mes= D_12_8 if mes12==1
replace ahorro_4_mes= D_12_9 if mes12==1
replace ahorro_5_mes= D_12_10 if mes12==1
replace ahorro_6_mes= D_12_11 if mes12==1
replace ahorro_7_mes= D_12_12 if mes12==1

replace ahorro_1_mes= 0 if D_10==0
replace ahorro_2_mes= 0 if D_10==0
replace ahorro_3_mes= 0 if D_10==0
replace ahorro_4_mes= 0 if D_10==0
replace ahorro_5_mes= 0 if D_10==0
replace ahorro_6_mes= 0 if D_10==0
replace ahorro_7_mes= 0 if D_10==0

forvalues x=1/7{
replace ahorro_`x'_mes=0 if ahorro_`x'_mes==.
replace ahorro_`x'_mes=. if _merge==1
}
drop g*

*D_14: Qué acción tomó para ahorrar?
replace D_14=0 if D_14==. 
replace D_14=. if _merge==1 
gen dum1D_14=0 
replace dum1D_14=1 if D_14==1 
replace dum1D_14=. if D_14==. 
label variable dum1D_14 "¿Qué acción tomó para ahorrar? Gasté menos" 
gen dum2D_14=0 
replace dum2D_14=1 if D_14==2 
replace dum2D_14=. if D_14==. 
label variable dum2D_14 "¿Qué acción tomó para ahorrar? Logré obtener más ingresos" 
gen dum3D_14=0 
replace dum3D_14=1 if D_14==3 
replace dum3D_14=. if D_14==. 
label variable dum3D_14 "¿Qué acción tomó para ahorrar? Bajé los costos de créditos que tenía y ahorré la diferencia" 

*D_13: Entre la 1era encuesta y los 6 meses siguientes ¿Cuánto logro ahorrar?
replace D_13 = 0 if D_10==0 
replace D_13 = . if D_13==99 
replace D_13 = . if D_13==-99
replace D_13 = 0 if D_14==0

gen		lnD_13 = ln(D_13+1) 

gen pct1D_13=(D_13/_c_6_ingreso_total) 
replace pct1D_13=. if _c_6_ingreso_total<=0 

gen dum_pct1_D_13 = 0 
replace dum_pct1_D_13 = 1 if pct1D_13>0.05 
replace dum_pct1_D_13 = . if D_13==. 




save "data/base.dta", replace

*Treatments

use "data/base.dta", clear

gen month = month(comienzo1) // month baseline
tab month, gen(d_month_) 
drop d_month_6 

*Creates Treatment status variables
gen S=0 
replace S=1 if Tratamiento==2|Tratamiento==4|Tratamiento==5|Tratamiento==6 
label var S "Salience" 

gen P=0 
replace P=1 if Tratamiento==3|Tratamiento==4|Tratamiento==5|Tratamiento==6 
label var P "Personalization" 

gen SxP=S*P 
label var SxP "Salience and Personalization" 

gen gr5=0 
replace gr5=1 if Tratamiento==5 
label var gr5 "Good News" 

gen gr6=0
replace gr6=1 if Tratamiento==6 
label var gr6 "Bad News" 

*Attrition
gen		attrition		=0 
replace	attrition		=1	if	_merge==1 

*Save
save "data/base.dta", replace



//Generando una variable que me va a ayudar más adelante para Equifax
gen long _3_2_cedula_copy=_3_2_cedula

//IMPORTANTE!!!! En base.dta hay cédulas repetidas, hay dos casos problemáticos (3416988 y 5649844). Entonces se le asignaría a dos personas la misma data de Equifax.
//Se identificó a través de la edad a quién le corresponde la data de Equifax.
//Entonces para hacer el merge voy a copiar la cedula y hacer el match perfectos a mano para los casos problemáticos. 

//Dos casos problematicos: (haciendo el match de los problemáticos)
//1.) 3416988: Fulgencio Acosta (39 años en el baseline) y María Cristina Lugo (25 años en el baseline)
replace _3_2_cedula_copy=0 if _3_2_cedula==735 & _a_1_edad==25 // en 2020 según Equifax 3416988 tiene 40 años

//2.) 5649844: Georgina Arias (31 años en el baseline) y Giselle Espinola (22 años en el baseline)
replace _3_2_cedula_copy=0 if _3_2_cedula==2439 & _a_1_edad==31 // en 2020 de acuerdo a Equifax 5649844 tiene 26 años

*Save
save "data/base.dta", replace




********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

*                          Equifax_2020 (do-file)
*                         -----------------------

*-------------------------------------------------------------------------------
*              Trabajando resultado_data_ready_equifax.xls (Solicitudes)
*             ----------------------------------------------------------

clear all
use data/data_public_equifax_consultas, clear

*Destring documento (convert string variable into numeric ones)
destring documento, replace 
rename documento _3_2_cedula 

*Arreglando la fecha 
replace fecha_solicitud="" if fecha_solicitud=="Sin consultas." // son 238 observaciones
gen Day=substr(fecha_solicitud,1,2) 
gen Month=substr(fecha_solicitud,4,2) 
gen year=substr(fecha_solicitud,7,4) 
destring Day Month year, replace 
gen Date=mdy(Month, Day, year) 
format Date %td 
drop Day Month
label var Date "Date requests" 

*Chequeando que no hayan duplicados 
duplicates report _3_2_cedula Date //No hay duplicados 

*save temporalmente 
tempfile hoja_solicitudes
save `hoja_solicitudes'


*                      Obteniendo la cantidad de consultas por año
*                     ---------------------------------------------

gen count_solicitudes=1 if rubro!="Sin consultas."
replace count_solicitudes=0 if rubro=="Sin consultas."
collapse (sum) count_solicitudes, by(year _3_2_cedula)
*Importante!!! Hay individuos que no tienen consultas y su Date es vacia
*Para identificar si no hay consultas en todo el periodo (2017 a 2020)
egen temporal=count(year), by(_3_2_cedula) //todos los individuos "Sin consultas" no tienen consultas en todo el periodo
drop temporal

*TRUCO: les voy a asignar un año (2020) a los que no tienen consultas para poder hacer el reshape y no perder las observaciones
*Ventaja del truco: no pierdo las observaciones y despues puedo reemplazar los "." (missings) por ceros. Entonces me queda que en todos los periodos hay 0 consultas (no solo en el 2020)
replace year=2020 if year==.

reshape wide count_solicitudes, i(_3_2_cedula) j(year)
*Asigno ceros a los periodos (años) donde no hay consultas 
forvalues i=2017/2020{
replace count_solicitudes`i'=0 if count_solicitudes`i'==.
label var count_solicitudes`i' "Sum requests, year `i'"
}

*Variable de todas las requests 
gen count_solicitudes=count_solicitudes2017+count_solicitudes2018+count_solicitudes2019+count_solicitudes2020
label var count_solicitudes "Total requests (2017-2020)"

*save temporalmente 
tempfile equifax_requests
save `equifax_requests'

*-------------------------------------------------------------------------------

*          Obteniendo la cantidad de consultas Equifax por año desagregadas
*         ------------------------------------------------------------------

clear 
use "data/base.dta", clear 
keep _3_2_cedula comienzo1 
merge m:m _3_2_cedula using `hoja_solicitudes', gen(_merge_consultas_desag_año) 
drop if _merge_consultas_desag_año==1 // Los que están en base.dta y no en `hoja solicitutes' (no en equifax)

*Distance between Date (of request) and comienzo1 (date of baseline)
gen dist= Date-comienzo1

*Generate time-period dummies
*Importante!!! En la data los que tienen dist==. son los que tienen Date==., o sea que no tienen consultas. C
*No tener consultas es informativo asi que las dejo con 0. 
gen		S_After	= 0 
replace S_After	= 1 if Date>comienzo1 & dist!=. 

gsort _3_2_cedula 

*Count days after the baseline
gen n_days_after=date("25jun2020", "DMY")-comienzo1

*Collapse request markets into counts of number of requests
collapse (sum) S_After, by(_3_2_cedula comienzo1 n_days_after) 

replace S_After = 100*S_After/n_days_after if n_days_after!=. 

*Merge con el resto de la data 
merge 1:m _3_2_cedula using `equifax_requests', gen(_merge_rubro_requests) 
drop _merge_rubro_requests 

*Labels 
label var S_After "Whole period" 

save `equifax_requests', replace


*-------------------------------------------------------------------------------

*                        Agregando los rechazados de Equifax
*                       -------------------------------------

clear all 
use data/data_public_equifax_rechazados, clear

*Cedula (identificador individual)
rename documento  _3_2_cedula 
destring  _3_2_cedula, replace 

*Dummy rechazados 
gen rechazados_equifax=1 

merge 1:m _3_2_cedula using `equifax_requests', gen(_merge_rechazados)
drop _merge_rechazados

replace S_After=. if rechazados_equifax==1

save `equifax_requests', replace



*-------------------------------------------------------------------------------

*    Merge con la primera hoja de resultado_data_ready_equifax.xls (Morosidades)
*   -----------------------------------------------------------------------------
*(Idea es agregar más variables como: Score, ips,)
*Limpiando la data de la primera hora del Excel (preparandola para el merge)
clear all 
use data/data_public_equifax_personas, clear

rename ips ips_2020

*Cedula (identificador individual)
rename documento  _3_2_cedula 
destring  _3_2_cedula, replace 

rename fajascoring Score_2020 

*asignando valores a Score 2020 

encode Score_2020, gen(Credit_Score_2020) 
replace Credit_Score_2020 = 99 if Score_2020=="X" 
label var Credit_Score_2020 "Credit score 2020 (not informative, see new_score_2020)" 
recode Credit_Score_2020 (1 = 0) (2 = 1) (3 = 2) (4 = 3) (5 = 4) (6 = 6) (7 = 8) (8 = 10) (9 = 12) (10 = 15) (11 = 20) (12 = 30) (13 = 50) (14 = 73) (99 = 100), generate(new_score_2020) 
label var new_score_2020 "Credit score 2020 in numbers" 

merge 1:m _3_2_cedula using `equifax_requests', gen(_merge_score_y_otros) 

*save temporalmente 
tempfile equifax_data
save `equifax_data', replace


*-------------------------------------------------------------------------------

*              Obteniendo el monto de mora desagregado en el tiempo
*            --------------------------------------------------------


*Ingresando la fecha de la consulta de la data para obtener le fecha del inicio de la mora
gen year=2020
gen month=6
gen day=25
gen Date_consulta=mdy(month, day, year)
drop year month day
format Date_consulta %td

gen Date_inicio_mora=Date_consulta-diasmoramaximo
format Date_inicio_mora %td
label var Date_inicio_mora "Fecha en la que inicia la mora"

gen year_insc = year(Date_inicio_mora)
gen dist_mora = Date_inicio_mora - comienzo1 
*drop if dist_mora<0 // drops negative distances 

*Marker for default 
gen M =0 
replace M=1 if montomorapublicags!=0 & montomorapublicags!=. & _merge_score_y_otros==3 

*Time-period markers (sirve para saber cuándo hay deuda)
gen tau0 = 1 

*Create default markers by time-period alone: 
foreach t in tau0 {
	gen		M_`t'	= 0         if  _merge_score_y_otros==3
	replace	M_`t'	= 1			if	`t'==1 & M==1
	gen		A_`t'	= 0         if  _merge_score_y_otros==3
	replace A_`t'=montomorapublicags/1000 if `t'==1 & M==1 & montomorapublicags!=. & montomorapublicags!=0
	label var M_`t' "Dummy unpaid debt"
	label var A_`t' "Amount unpaid debt (thousands)"
} 

*IMPORTANTE: Para los que tienen distancia negativa, los marcadores van a rellenarse para tau0 y tau3. El tau3 no estaría correcto, pero no lo arregle porque sólo importa el tau0 en el paper. 

*Dummy de baseline para la mora 
gen M_tau0_lb=0 if _merge_score_y_otros==3 
replace M_tau0_lb=1 if _merge_score_y_otros==3 & M_tau0==1 & dist_mora<0 

*Por conveniencia para las regresiones, creo la misma variable con un nombre conveniente
gen A_tau0_lb=M_tau0_lb 

*De nuevo merge por drop if dist<0
*merge 1:m _3_2_cedula using `equifax_data', gen(_merge_score_y_otros_2) // esto sirve para cuando se saca la distancia<0



*-------------------------------------------------------------------------------

*                          Merge con data_public_equifax.dta
*                         -----------------------------------

// IMPORTANTE!!!! En base.dta hay cédulas repetidas, hay dos casos problemáticos (3416988 y 5649844). Entonces se le asignaría a dos personas la misma data de Equifax.
//Se identificó a través de la edad a quién le corresponde la data de Equifax.
//Entonces para hacer el merge voy a copiar la cedula y hacer el match perfectos a mano para los casos problemáticos. 

gen long _3_2_cedula_copy=_3_2_cedula

merge 1:m _3_2_cedula_copy using "data/base.dta", gen(_merge_base_dta) // lo tuve que hacer 1:m, porque me dijo "variable _3_2_cedula does not uniquely identify observations in the using data"

*Dummy base de Equifax 

*gen dummy_equifax=0 if _merge_base_dta==2 // no considera a los 51 individuos rechazados
gen dummy_equifax=0
replace dummy_equifax=1 if _merge_score_y_otros==3

*los duplicados 
duplicates report _3_2_cedula
duplicates examples _3_2_cedula // cedulas repetidas: 0 (los que no tienen cedula), 3416988 y 5649844

save "data/base_plus_equifax_2020.dta", replace
clear all



*-------------------------------------------------------------------------------


*                        Including commands from the tables dofiles
*                       --------------------------------------------

clear all 
use "data/base_plus_equifax_2020.dta", clear 

//Generate index of well-being
egen std_d_suenio		= std(d_suenio) 
egen std_d_tension		= std(d_tension) 
egen std_d_nervios		= std(d_nervios) 
egen std_d_sensacion	= std(d_sensacion) 

egen index = rowmean(std_d_suenio std_d_tension std_d_nervios std_d_sensacion) 
drop std_d_suenio std_d_tension std_d_nervios std_d_sensacion

//Label Variabes
*label var attrition			"Attrition"
label var _a_1_edad				"Age" 
label var Female				"Share of women" 
label var _a_3_educacion		"Years of education" 
label var single				"Share single" 
label var _a_5_jefe				"Head of household" 
label var _a_6_trabajo			"Worked last year" 
*label var _a_10_aportacion		"Pays Social Security"
*label var _a_11_negocio			"Business owner"
*label var _a_12_ingresos		"Business income"
label var _b_5_riesgo			"Willingness to take risks (1-10)" 
*label var _c_1_personas			"no. of people in household"
label var _c_6_ingreso_total	"Total ind. income (thousands)" 
label var _c_8_gastos_total		"Total ind. expenses (thousands)" 
label var _c_ingreso_gasto		"Account balance (thousands)" 
*label var _c_12_ahorrohogar		"Household savings"
label var savings				"Dummy for saves" 
label var _c_11_ahorroind		"Individual savings (thousands)" 
label var dum_c_13_meses_dif	"Had financial problems last year..." 
label var dum_c_15_caidas		"...because of fall in income" 
label var _c_13_num_mon			"No. of Mon with financial problems..." 
*label var _c_14_gastos			"Because of unexpected expenses"
label var _c_15_num_mon			"...because of fall in income" 
label var pct_c_17_monto			"Pct inc spent on unexpected expenses" 
label var pct_c_16_monto			"Pct inc of fall in income" 
*label var _d_1_credito_entidad	"Has sought credit"
*label var _d_13_ahorro			"Has had savings account"
*label var _d_15_tarjeta			"Has been offered credit card"
*label var _d_16_tarjeta			"Has had Credit card"
label var index					"Index of well-being" 
*label var d_suenio				"Loses sleep"
*label var d_tension				"Is tensed"
*label var d_nervios				"Is nervous"
*label var d_sensacion			"Feels things collapsing"

//Recode income variables
replace		_c_6_ingreso_total	= _c_6_ingreso_total/1000 
replace		_c_8_gastos_total	= _c_8_gastos_total	/1000 
replace		_c_ingreso_gasto	= _c_ingreso_gasto	/1000 
replace		_c_11_ahorroind		= _c_11_ahorroind	/1000 

save "data/baseline_charac_ready.dta", replace


*-------------------------------------------------------------------------------

clear all 


use "data/base_plus_equifax_2020.dta", clear 


//Recode
	*Num of months saved
	egen ahorro_suma_meses = rowtotal(ahorro_1_mes ahorro_2_mes ahorro_3_mes ahorro_4_mes ahorro_5_mes ahorro_6_mes ahorro_7_mes) 
	replace ahorro_suma_meses =. if ahorro_1_mes==. 
	*Expenses at baseline
	foreach var in _c_8_1 _c_8_2 _c_8_3 _c_8_4 _c_8_5 _c_8_6 _c_8_7 _c_8_8 _c_8_9 _c_8_10 _c_8_11 _c_8_12 _c_8_13 _c_8_14 _c_8_15 _c_8_16 _c_8_17 {
	replace `var' = 0 if `var'==-99
	}
	foreach var in B_8_1 B_8_2 B_8_3 B_8_4 B_8_5 B_8_6 B_8_7 B_8_8 B_8_9 B_8_10 B_8_11 B_8_12 B_8_13 B_8_14 B_8_15 B_8_16 B_8_17 {
	replace `var' = . if `var'==-99
	}
	egen		div_ves_o_expenses_lb = rowtotal(_c_8_15 _c_8_16 _c_8_17)
	replace		div_ves_o_expenses_lb = ln(div_ves_o_expenses_lb+1)
	egen		household_expenses_lb = rowtotal(_c_8_2 _c_8_3 _c_8_4 _c_8_5 _c_8_10 _c_8_11 _c_8_12)
	replace		household_expenses_lb = ln(household_expenses_lb+1)	
	*Expenses on fun, clothes, and unidentified
	gen			div_ves_o_expenses = B_8_15 + B_8_16 + B_8_17
	replace		div_ves_o_expenses = ln(div_ves_o_expenses+1)
	*Household savings
	gen			household_expenses = B_8_1 + B_8_2 + B_8_3 + B_8_4 + B_8_5 + B_8_10 + B_8_11 + B_8_12
	replace		household_expenses = ln(household_expenses+1) 
	*Individual savings
	replace _c_11_ahorroind = 0 if _c_11_ahorroind==. 
	gen dum_c_11=0 
	replace dum_c_11=1 if _c_11_ahorroind>0 
	gen ln_c_11 = ln(_c_11_ahorroind+1) 
	
*Rewrite labels
*Savings intentions
label var D_1 						"Had a savings target last month" 
label var lnD_2 					"Amount of savings target (log)" 
label var dum_pct1_D_2				"Target > 5pct of baseline income" 

*Savings during interventions
label var	ahorro_suma_meses		"Num of months saved" 
label var	dum_pct1_D_13			"Saved > 5pct of baseline income" 
label var	lnD_13					"Amount saved (log)" 

*Savings 12 months after intervention
label var	dumB_11					"Saved (dummy)" 
label var	dum_pct1_B_11			"Saved > 5pct of baseline income" 
label var	lnB_11					"Amount saved (log)" 
label var	dumB_10					"Positive balance (dummy)" 
label var	lnB_10					"Budget balance (log)" 
label var	household_expenses		"Expenses on household items" 
label var	div_ves_o_expenses		"Expenses on fun, clothes, and co." 


//Rewrite labels
label var dum1D_14	"Spent less" 
label var dum2D_14	"Increased income" 
label var dum3D_14	"Reduced credit costs" 


//Rename
rename dum_c_13_meses_dif dum_c_13 
rename dum_c_15_caidas dum_c_15 

//Label Variabes
label var B_13_num_mon				"No. of Mon with financial problems" 
label var dumB_17					"Thought of using savings next time?" 

label var index_endline				"Index of well-being" 
label var C_11						"Satisfaction with financial situation (1-10)" 

label var dumC_1					"Requested credit" 
label var C_3_montototal			"Total ammount requested (`000s)" 
label var C_3_montototalaprob		"Total ammount approuved (`000s)" 
label var dumC_3_nopag				"Defaulted" 

label var dum_d_1					"Requested credit" 
label var _d_2_montototal			"Total ammount requested (`000s)" 
label var _d_2_montototalaprob		"Total ammount approuved (`000s)" 
label var dum_d_2_nopag				"Defaulted" 


//Recode 
foreach var in dum_c_13 _c_13_num_mon pct_c_17_monto dum_c_15 _c_15_num_mon pct_c_16_monto {
replace `var'=0 if `var'==.
replace `var'=. if attrition==1
}
replace dumB_17 = . if attrition==1 

foreach var in C_3_montototal C_3_montototalaprob _d_2_montototal _d_2_montototalaprob {
replace `var' = `var'/1000
} 

//Variable labels
label var D_3			"... being surveyed last year" 
label var D_4_1			"... being told saving is important" 
label var D_4_2			"... being told about savings potential" 
label var D_4_3			"... a recommendation to save 10pct of income" 
label var D_4_5			"... hearing that credit is more expensive than saving" 

label var	D_6			"... regarding savings" 
label var	dumD_71		"... urging savings in general" 
label var	dumD_72		"... urging saving a specific amount" 

//Table on Effect of being in groups 5 or 6 relative to group 4
gen gr4=1 
*(The rest of the commands are the same from table 4)


*                             Table equifax (do-file)
*                            ------------------------
	
	*Principal (P) (loan ammount approuved and withdrawn) : _d_2_montototalaprob
	gen Principal = 0
	replace Principal = _d_2_3_aprobado_monto_1 if _d_2_4_retirado_1==1
	*Total ammount paid (A) N_cuotas*valor_cuotas = P(1+r)^N where r is monthly interest
	gen Ammount = _d_prestamos_total_1
	*Numero de cuotas
	replace _d_2_7_cuotas_1 = . if _d_2_7_cuotas_1==99 | _d_2_7_cuotas_1==200000
	*interest rate
	gen rate = (Ammount/Principal)^(1/_d_2_7_cuotas_1) - 1	
	*monthly 
	gen i_rate = rate*12 if _d_2_7_cuotas_frecuencia_1==3 | _d_2_7_cuotas_frecuencia_1==4 /* upon careful analysis yearly rates are mistakes except for 1 person with 0 rate*/
	*weekly 
	replace i_rate = rate*52.14 if _d_2_7_cuotas_frecuencia_1==2  /* upon careful analysis yearly rates are mistakes except for 1 person with 0 rate*/
	*daily
	replace i_rate = rate*365 if _d_2_7_cuotas_frecuencia_1==1  /* upon careful analysis yearly rates are mistakes except for 1 person with 0 rate*/
	*byweekly
	replace i_rate = rate*26.07 if _d_2_7_cuotas_frecuencia_1==15  /* upon careful analysis yearly rates are mistakes except for 1 person with 0 rate*/
	
	*people borrowing from family and paying 0 rate
	replace rate = 0 if _lb_key=="uuid:427fa708-3eb4-4d60-aa9c-aee1b6e5b39a"
	replace rate = 0 if _lb_key=="uuid:5c639d45-703d-46fa-b927-f2ce6c03a2a9"
	replace i_rate = 0 if _lb_key=="uuid:427fa708-3eb4-4d60-aa9c-aee1b6e5b39a"
	replace i_rate = 0 if _lb_key=="uuid:5c639d45-703d-46fa-b927-f2ce6c03a2a9"
	
	*Has taken out a loan in past year
	gen Loan = 1 
	replace Loan = 0 if i_rate==. 
	replace Loan=1 if Ammount!=. 
	replace Loan=. if rate<0

label var attrition 						"Attrition (dummy)"  

gen treatment = 0 
replace treatment = 1 if SxP==1 

*Rewrite labels
label var	B_8_1	"Alquiler"
label var	B_8_2	"Hipoteca"
label var	B_8_3	"Alimentacion"
label var	B_8_4	"Educacion"
label var	B_8_5	"Salud"
label var	B_8_6	"Transporte"
label var	B_8_7	"Linea baja"
label var	B_8_8	"Celular"
label var	B_8_9	"Internet y cable"
label var	B_8_10	"Gas, lena, y carbon"
label var	B_8_11	"Electricidad"
label var	B_8_12	"Agua"
label var	B_8_13	"Combustible"
label var	B_8_14	"Creditos"
label var	B_8_15	"Diversion"
label var	B_8_16	"Vestimenta"
label var	B_8_17	"Otros"

gen			total_expenses 		= B_8_1 + B_8_2 + B_8_3 + B_8_4 + B_8_5 + B_8_6 + B_8_7 + B_8_8 + B_8_9 + B_8_10 + B_8_11 + B_8_12 + B_8_13 + B_8_14 + B_8_15 + B_8_16 + B_8_17 
label var	total_expenses		"Sum of all expenses" 
gen			transport_expenses = B_8_6 + B_8_13
label var	transport_expenses	"Expenses on transportation"
gen			communica_expenses = B_8_7 + B_8_8 + B_8_9
label var	communica_expenses	"Expenses on communication technology"

egen		total_expenses_lb = rowtotal(_c_8_2 _c_8_3 _c_8_4 _c_8_5 _c_8_6 _c_8_7 _c_8_8 _c_8_9 _c_8_10 _c_8_11 _c_8_12 _c_8_13 _c_8_14 _c_8_15 _c_8_16 _c_8_17)
egen		transport_expenses_lb = rowtotal(_c_8_6 _c_8_13)
egen		communica_expenses_lb = rowtotal(_c_8_7 _c_8_8 _c_8_9)

replace		total_expenses_lb = ln(total_expenses_lb+1)	
replace		transport_expenses_lb = ln(transport_expenses_lb+1)	
replace		communica_expenses_lb = ln(communica_expenses_lb+1)	


//Rewrite labels
*Savings intentions
label var D_9						"Saved in past 6 months" 


*                      Rename variables (baseline variables)
*                    ----------------------------------------

*Baseline D_9
gen D_9_lb=dum_c_11 
*Baseline dumB_11
rename dum_c_11 dumB_11_lb 
*Baseline lnB_11
rename ln_c_11 lnB_11_lb 
*Baseline B_13_num_mon
rename _c_13_num_mon B_13_num_mon_lb 
*Baseline dumB_17
rename dum_c_17 dumB_17_lb 
*Baseline index_endline
rename index_baseline index_endline_lb 
*Baseline C_11
rename _d_25_satisfaccion C_11_lb 
*Baseline dumC_1
rename dum_d_1 dumC_1_lb 
*Baseline C_3_montototal
rename _d_2_montototal C_3_montototal_lb 
*Baseline C_3_montototalaprob
rename _d_2_montototalaprob C_3_montototalaprob_lb 
*Baseline dumC_3_nopag
rename dum_d_2_nopag dumC_3_nopag_lb 

label var	lnB_11					"Amount saved (LR)" 
label var	lnD_13					"Amount saved (SR)" 
label var	div_ves_o_expenses		"Exp. on tempt. goods" 


save "data/main_regressions_ready.dta", replace 
clear all 

*-------------------------------------------------------------------------------





