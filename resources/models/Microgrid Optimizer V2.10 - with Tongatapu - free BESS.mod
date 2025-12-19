/***************************************************
 * Microgrid Optimisation Model v2.10 w. TPL Tongatapu
 * Author: n.bergevin
 * Creation Date: 2024-07-04
 ***************************************************/

// hard-coded parameters for all microgrids in this model
//		- final battery SOC set to 0% or more (see finalSOCLowerBound param)
//		- number of inverters per storage units set to 1 (see inverterNbr param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param)
//		- linear and constant terms of linear approximation of assets min and max reactive powers set to zero (see aQmax / bQmax / aQmin / bQmin)
//		- physical min power for thermal generators set to 5 kW (see physMinThermalGenActivePower param)
//		- fraction of active power load that defines requirement for spinning raise reserve set to  0% (see NFLoadSpinRaiseReserveReq param)
//		- fraction of active power load that defines requirement for spinning lower reserve set to  0% (see NFLoadSpinLowerReserveReq param)
//		- set of grid forming assets set to empty (see isGRID_FORM set)
//		- set of grid following assets set to empty (see isGRID_FOLL set)

// hard-coded parameters in this model for Srisangtham microgrid
//		- cost of electricity pruchased from main grid set to 3 currency_unit / kWh (see electricityTariff param)

// hard-coded parameters in this model for VidoFleur microgrid
//		- cost of electricity pruchased from main grid set to 0.045 currency_unit / kWh (see electricityTariff param)

// hard-coded parameters in this model for Enercal's Ile des Pins and Mare microgrids and TPS's Tongatapu microgrid
//		- SOC strict minimum for any storage unit set to 5% (see strictMinSOC param)

// hard-coded parameters in this model for Enercal's Ile des Pins and Mare microgrids
// 		- artificial penality to encourage early battery discharges set to 10 * step_index[t] / step_number (see storArtificialPenality param and StorChargeDischargeCost var)

// hard-coded parameters in this model for Enercal's Ile des Pins microgrid
//		- number of inverters per storage units overidden to 6 (see inverterNbr param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param)
//		- storage unit's hard coded max discharge power set to 1040kW (see hardCodedPowerMin param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param) 
//			-> impacts computation of linear and constant terms of linear approximation of assets min and max reactive powers see (aQmax and bQmax param)
//			-> impacts computation of current injection potential for each storage unit (see storCurrentInjection param)
//		- linear and constant terms of linear approximation of assets min and max reactive powers overriden (see aQmax / bQmax / aQmin / bQmin)

// hard-coded parameters in this model for Enercal's Mare microgrid
//		- number of inverters per storage units overidden to 8 (see inverterNbr param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param)
//		- storage unit's hard coded max discharge power set to 800kW (see hardCodedPowerMin param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param) 
//			-> impacts computation of linear and constant terms of linear approximation of assets min and max reactive powers see (aQmax and bQmax param)
//			-> impacts computation of current injection potential for each storage unit (see storCurrentInjection param)
//		- linear and constant terms of linear approximation of assets min and max reactive powers overriden (see aQmax / bQmax / aQmin / bQmin)

// hard-coded parameters in this model for TPS's Tongatapu microgrid
//		- number of inverters per storage units overidden to 3 (see inverterNbr param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param)
//		- storage unit's hard coded max discharge power set to 6000kW for Tongatapu_Matatoa_BESS and 7200 for Tongatapu_Popua_BESS (see hardCodedPowerMin param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param) 
//			-> impacts computation of linear and constant terms of linear approximation of assets min and max reactive powers see (aQmax and bQmax param)
//			-> impacts computation of current injection potential for each storage unit (see storCurrentInjection param)
// 		- artificial penality to encourage early battery discharges set to 0.01 * step_index[t] / step_number (see storArtificialPenality param and StorChargeDischargeCost var)
//		- fraction of active power load that defines requirement for spinning raise reserve set to  30% (see NFLoadSpinRaiseReserveReq param)
//		- fraction of active power load that defines requirement for spinning lower reserve set to  30% (see NFLoadSpinLowerReserveReq param)
//		- set of grid forming assets set to Cummin + 6 Cat gensets (see isGRID_FORM set)

// hard-coded parameters in this model for Morbihan Energies' FlexMob'Ile and Kergrid microgrids
// 		- artificial penality to encourage early battery discharges set to 0.1 * (step_number) * step_index[t] / step_number (see storArtificialPenality param and StorChargeDischargeCost var)

// hard-coded parameters in this model for Morbihan Energies' Kergrid microgrid
//		- minimum charging rate for each charging point on charging station used by MORB_ENERGIES_Kergrid_V1G_C1 and MORB_ENERGIES_Kergrid_V1G_C2 vehicles set to 9kW (see ctStorageChargeMin constraint)
//		- maximum charging rate for charging station used by MORB_ENERGIES_Kergrid_V1G_C1 and MORB_ENERGIES_Kergrid_V1G_C2 vehicles set to 18kW (see ctCongV1GC1C2 constraint)

// temporary workaround to send battery's projected SOC for FlexMob'Ile and Kergrid and microgrids (see assetTempTarget output param)

// artifical penalties for all microgrids in this model
//		- artificial penalty to encourage first step's average active power to stay the same as it was initially for thermal gen g if g is initially on set to 0.1 * lowest piecewise linear cost model marginal cost: thermaGenInitialPowerViolPenalty
//		- artificial penalty to encourage battery SOC to be above min SOC set to 1.2 * highest piecewise linear cost model marginal cost: SOCminViolationPenaltyCost
//		- artificial penalty to avoid intermittent prod curtailment unless all storage units are full set to 0.1 * max prices (see unauthorizedInterProdCurtPenaltyCost param)

/*********************************************************************
 * declare tuple structures to host data read from Excel or JSON files
 * names of tuple members must be same as names of attributes in JSON
 * files or headers of columns in Excel files (DO cloud requirement)
 *********************************************************************/
/* OPERATION DATA */
tuple t_operation {
 	key string param_id;
 	string param_val;
 }
{t_operation} OPERATION = ...; // variable holding OPERATION data

/* OPERATION x STEP DATA */
tuple t_operation_steps {
 	key string step_id;				// Some ID generated by Everest
 	int step_duration;				// in minutes (MUST be expressed as a whole number of minutes b/c is used in the definition of a range)
 	float electricity_price;		// in currency unit/kWh
 	float max_export_to_main_grid;	// in kW
 	float max_import_from_main_grid;// in kW
 }
{t_operation_steps} OPERATION_STEPS = ...; // variable holding OPERATION_STEPS data

/* ASSET DATA */
tuple t_assets {
 	key string asset_id;					// Everest's capacity ID
 	string type;							// 'FLEX_LOAD' 'LOAD' 'GENERATOR' 'INTERMITTENT' STORAGE' 'SITE'
 	string site;							// ID of site the asset is connected to
 	string control;							// 'NONE' 'POWER' 'TEMPERATURE'
 	float min_power;						// in kW: min consumption for 'CONSUMPTION', -max generation for 'GENERATION', -max discharge rate for 'MIXED', and -max output for 'SITE'
 	float max_power;						// in kW: max consumption for 'CONSUMPTION', -min generation for 'GENERATION', max charge rate for 'MIXED', max input for 'SITE'
 	float max_energy;						// in kWh: 'MIXED' only
 	float storage_charging_efficiency;		// ratio: 'MIXED' only
 	float storage_discharging_efficiency;	// ratio: 'MIXED' only
 	float min_SOC;							// in %: 'MIXED' only
 	float max_SOC;							// in %: 'MIXED' only
 	float initial_SOC;						// in %: 'MIXED' only
 	float initial_power;					// in kW: +ve = consumption and -ve = generation
 	float max_ramp_rate;					// WARNING in W/min (-ve value means ramp rates do not apply)
 	int min_time_on;                		// minimum time the capacity can continuously generate / consume for (expressed in minutes)
 	int max_time_on;                		// maximum time the capacity can continuously generate / consume for (expressed in minutes)
 	int min_recovery_period;        		// minimum time between two continuous generation of the capacity (expressed in minutes)
 	int initial_time_on;            		// time the capacity has been continuously generating / consuming up until the current time (expressed in minutes) 
 	int initial_time_off;           		// time the capacity has not been generating / consuming up until the current time (expressed in minutes)  	
 	float injection_current_potential;		// current (expressed in A) that can be injected by the asset into the microgrid
 	float variable_cost;					// linear variable cost (expressed in market currency / kWh)
 	float compensation_cost;				// compensation cost for curtailing generation (expressed in market currency / kWh)
 	string compensation_model;				// indication of the curtailment calculation methodology (DEFAULT_BASED = based on installed peak capacity or FORECAST_BASED = based on power forecast)
 	float startup_cost;						// cost of starting asset (expressed in market currency)
 	string var_cost_model;					// ID of variable cost model applying to asset
 	float active_power_loss;				// credible sudden loss of active power (% of asset's active power)
 	float active_power_surge;				// credible sudden surge of active power (% of asset's active power)
 	float reactive_power_loss;				// credible sudden loss of reactive power (% of asset's active power)
 	float reactive_power_surge;				// credible sudden surge of reactive power (% of asset's active power)
 	float power_tolerance;					// active power floor (expressed in kW) under which asset is considered to be off
 	// IMPACT on EVEREST
// 	string operating_mode;					// asset's operating mode: GRID_FORMING / GRID_FOLLOWING / GRID_TIED
//	float spin_raise_reserv_req_perc;		// fraction (expressed as a %) of asset's active power that defines requirements for spinning raise reserve (NF load units only) 		
//	float spin_lower_reserv_req_perc;		// fraction (expressed as a %) of asset's active power that defines requirements for spinning lower reserve (NF load units only) 		
 }
{t_assets} ASSETS = ...; // variable holding ASSETS data

/* ASSET x STEP DATA */
tuple t_asset_steps {
	key string asset_id;			// Everest's capacity ID
	key string step_id;				// Some ID generated by Everest
	float power_prediction;			// in kW: +ve = consumption and -ve = generation
	float soc_target;				// SOC (in %) to reach before asset becomes unavailable
	int availability;				// asset's availability (0 /1)
}
{t_asset_steps} ASSET_STEPS = ...; // variable holding ASSET_STEPS data

/* CONGESTION DATA */
tuple t_congestions {
 	key string congestion_id;		// Everest's electrical area ID
 	float max_power_in;				// in kW: -lower limit 
 	float max_power_out;			// in kW: upper limit
 	float power_import_coef ;		// 1.0 if Everest's electrical area is conneted to main-grid, 0.0 otherwise
 }
{t_congestions} CONGESTIONS = ...; // variable holding CONGESTIONS data

/* CONGESTION_ASSET DATA */
tuple t_congestion_assets {
 	key string congestion_id;		// Everest's electrical area ID
 	key string asset_id;			// Everest's capacity ID
 	float power_coef;				// always 1.0
 }
{t_congestion_assets} CONGESTION_ASSETS = ...; // variable holding CONGESTIONS data

/* VARIABLE_COST_MODELS */
tuple t_variable_cost_models {
 	key string model_id;			// model ID
 	key int power_interval_nbr;		// segment ID
 	float lower_limit;				// segment upper limit (in kW)
 	float upper_limit;				// segment upper limit (in kW)
 	float marginal_cost;			// marginal variable cost that applies for the power segment (in currency unit/kWh)
 }
{t_variable_cost_models} VARIABLE_COST_MODELS = ...; // variable holding VARIABLE_COST_MODELS data

// Converting this reference to a microgrid name
string microgridName; // this param is filled up in pre-optimisation execute bloc

// indexing set of operation decision steps
{string} isDECISION_STEPS = {o.step_id | o in OPERATION_STEPS};
// indexing set of microgrid assets
{string} isASSETS = {a.asset_id | a in ASSETS};
// indexing set of microgrid assets operating in grid forming mode
// {string} isGRID_FORM = {a.asset_id | a in ASSETS: a.operating_mode == "GRID_FORMING"};
// HARD-CODED
{string} isGRID_FORM = (
	microgridName == "MICROGRID TPL Tongatapu"
	? isASSETS inter {"Tongatapu_Popua_GE1", "Tongatapu_Popua_GE2", "Tongatapu_Popua_GE3",
					"Tongatapu_Popua_GE4", "Tongatapu_Popua_GE5", "Tongatapu_Popua_GE6", "Tongatapu_Popua_GE7"}
	: {}
	);
// indexing set of microgrid assets operating in grid following mode
// {string} isGRID_FOLL = {a.asset_id | a in ASSETS: a.operating_mode == "GRID_FOLLOWING"};
{string} isGRID_FOLL = {};
// indexing set of sites
{string} isSITES = {a.asset_id | a in ASSETS: a.type == "SITE"};
// indexing set of microgrid assets operating in grid tie mode
// {string} isGRID_TIED = {a.asset_id | a in ASSETS: a.operating_mode == "GRID_TIED"};
{string} isGRID_TIED = isASSETS diff (isGRID_FORM union isGRID_FOLL union isSITES);
// indexing set of flexible load units
{string} isFLEX_LOADS = {a.asset_id | a in ASSETS: a.type == "FLEX_LOAD"};
// indexing set of intermittent production assets
{string} isINTER_PRODS = {a.asset_id | a in ASSETS: a.type == "INTERMITTENT"};
// indexing set of thermal generator assets
{string} isTHERMAL_GENS = {a.asset_id | a in ASSETS: a.type == "GENERATOR"};
// indexing set of piecewise linear variable cost models
{string} isVAR_COST_MODELS = {cm.model_id | cm in VARIABLE_COST_MODELS};
// indexing set of energy storage assets
{string} isSTORAGES = {a.asset_id | a in ASSETS: a.type == "STORAGE"};
// indexing set of non-flexible load units
{string} isNF_LOADS = {a.asset_id | a in ASSETS: a.type == "LOAD"};
// indexing set of assets controled by power targets
{string} isPOWER_CONTR_ASSETS = {a.asset_id | a in ASSETS: a.control == "POWER"};
// indexing set of assets controled by temperature targets
{string} isTEMP_CONTR_ASSETS = {a.asset_id | a in ASSETS: a.control == "TEMPERATURE"};
// indexing set of flexible load units controled by power targets
{string} isFLEX_LOADS_POWER = isFLEX_LOADS inter isPOWER_CONTR_ASSETS;
// indexing set of flexible load units controled by temperature targets
{string} isFLEX_LOADS_TEMP = isFLEX_LOADS inter isTEMP_CONTR_ASSETS;
// indexing set of network congestions
{string} isCONGESTIONS = {c.congestion_id | c in CONGESTIONS};
// indexing set of assets that have non-zero default current potential
{string} isDEFAULT_CURRENT_ASSET = {a.asset_id | a in ASSETS: a.injection_current_potential > 0};

/*********************************************************************
 * Model parameters (input data)
 *********************************************************************/
float epsilon = 0.00001;
// Reference to Everest's microgrid operation 
string operationID = first({o.param_val | o in OPERATION: o.param_id == "operation_id"});
string optimisationRequestTime = first({o.param_val | o in OPERATION: o.param_id == "optimisation_request_time"});
string optimisationIntervalStartTime = first({o.param_val | o in OPERATION: o.param_id == "optimisation_interval_start"});
// number of decision steps
int optimisationStepNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "optimisation_step_number"}));
// number of assets that can be used in optimisation
int assetNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "asset_number"}));
// time limit for optimisation (expressed in minutes)
float maxOptimisationTime = floatValue(first({o.param_val | o in OPERATION: o.param_id == "max_optimisation_time"}));
// duration (expressed in minutes) of decision step t (t in DECISION_STEPS)
// MUST be expressed as a whole number of minutes (int) b/c is used in the defintion of a range
int stepDuration[isDECISION_STEPS] = [os.step_id : os.step_duration | os in OPERATION_STEPS];
// duration (expressed in hours) of decision step t (t in DECISION_STEPS)
float stepDurationInHours[t in isDECISION_STEPS] = stepDuration[t] / 60.0; 
// number of optim steps in a 24-hour day
int stepsNumberInADay[t in isDECISION_STEPS] = ftoi(24 / stepDurationInHours[t]) ;
// optim step indexes
int stepIndex[isDECISION_STEPS] = [t.step_id : ord(isDECISION_STEPS, t.step_id) | t in OPERATION_STEPS];
// maximum power export out of the microgrid into the main grid (expressed in kW)
float maxExportCapacity[isDECISION_STEPS] = [t.step_id : t.max_export_to_main_grid | t in OPERATION_STEPS];
// maximum power import into the microgrid from the main grid (expressed in kW)
float maxImportCapacity[isDECISION_STEPS] = [t.step_id : t.max_import_from_main_grid | t in OPERATION_STEPS];
// last minute intermittent production curtailment option (1 means option is active / 0 means it is not)
int lastMinuteCurtOption = intValue(first({o.param_val | o in OPERATION: o.param_id == "avoid_anticipated_curtailment"}));
// requirement in default current injection (in A)
float defaultCurrentRequirement = floatValue(first({o.param_val | o in OPERATION: o.param_id == "default_current_req"}));
// number of power segments for each piecewise linear variable cost model (used in definitions of piecewise linear variable cost model constraints)
int varCostModelSegNumber[isVAR_COST_MODELS] = [cm : maxl(0, max(vc in VARIABLE_COST_MODELS: vc.model_id == cm) vc.power_interval_nbr) | cm in isVAR_COST_MODELS];
// number of power segments for largest piecewise linear variable cost model (used in declarations of piecewise linear variable cost model variables and constraints)
int maxSegNbr = maxl(0, max(cm in isVAR_COST_MODELS) varCostModelSegNumber[cm]);
// upper limit (in kW) of power segment s in cost model cm
float varCostSegUpLim[isVAR_COST_MODELS][1..maxSegNbr] = [s.model_id : [s.power_interval_nbr : s.upper_limit] | s in VARIABLE_COST_MODELS];
// marginal cost (in currency unit/kWh) associated with segment s in cost model cm
float varCostSegCost[isVAR_COST_MODELS][1..maxSegNbr] = [s.model_id : [s.power_interval_nbr : s.marginal_cost] | s in VARIABLE_COST_MODELS];
// assets startup costs (expressed in currency unit) (a in ASSETS)
float assetStartupCost[isASSETS] = [a.asset_id : a.startup_cost | a in ASSETS];
// startup costs for thermal generators g (expressed in currency unit) (g in isTHEMAL_GENS)
float thermalGenStartupCost[g in isTHERMAL_GENS] = assetStartupCost[g];
// % of active power generation or consumption (depending on assset's type, generation for storage type) that can be lost suddenly on asset a
//(a in ASSETS)
float activePowerLossPct[isASSETS] = [a.asset_id : a.active_power_loss | a in ASSETS];
// % of active power generation or consumption depending on assset's type, consumption for storage type) that can increase suddenly on asset a
//(a in ASSETS)
float activePowerSurgePct[isASSETS] = [a.asset_id : a.active_power_surge | a in ASSETS];
// % of reactive power generation or consumption depending on assset's type, generation for storage type) that can be lost suddenly on asset a
//(a in ASSETS)
float reactivePowerLossPct[isASSETS] = [a.asset_id : a.reactive_power_loss | a in ASSETS];
// % of reactive power generation or consumption depending on assset's type, consumption for storage type) that can increase suddenly on asset a
//(a in ASSETS)
float reactivePowerSurgePct[isASSETS] = [a.asset_id : a.reactive_power_surge | a in ASSETS];
// fixed electricity price (expressed in currency unit per kWh) for electricity purchase
// ENERCAL HARD-CODED
float electricityTariff = (microgridName == "Microgrid Srisangtham Microgrid" ? 3.0 : (microgridName == "VidoFleur Scheduled Assets" ? 0.045 : 0.0));
// assets maximum power
float powerMax[isASSETS] = [a.asset_id : a.max_power | a in ASSETS];
// assets minimum power
float powerMin[isASSETS] = [a.asset_id : a.min_power | a in ASSETS];
// maximum and minimum power generation (expressed in kW) possible for intermittent production asset p (p in INTER_PRODS)
float maxInterProdActivePower[p in isINTER_PRODS] = -powerMin[p];
float minInterProdActivePower[p in isINTER_PRODS] = -powerMax[p];
// maximum power generation (expressed in kW) physically possible for thermal generator asset g (g in THERMAL_GENS)
float maxThermalGenActivePower[g in isTHERMAL_GENS] = -powerMin[g];
// minimum power generation (expressed in kW) economically possible for thermal generator asset g (g in THERMAL_GENS)
float minThermalGenActivePower[g in isTHERMAL_GENS] = -powerMax[g];
// minimum power generation (expressed in kW) physically possible for thermal generators
float physMinThermalGenActivePower[g in isTHERMAL_GENS] = minl(5.0, minThermalGenActivePower[g]);
// maximum and minimum power consumption (expressed in kW) for non-flexible load unit n (n in NF_LOADS)
float maxNFLoad[n in isNF_LOADS] = powerMax[n];
float minNFLoad[n in isNF_LOADS] = powerMin[n];
// maximum and minimum power consumption (expressed in kW) for flexible load unit f (f in FLEX_LOADS)
float maxFlexLoad[f in isFLEX_LOADS] = powerMax[f];
float minFlexLoad[f in isFLEX_LOADS] = powerMin[f];
// assets energy charging / discharging efficiencies (as ratios)
float storageChargeEfficiency[isASSETS] = [a.asset_id : a.storage_charging_efficiency | a in ASSETS];
float storageDischargeEfficiency[isASSETS] = [a.asset_id : a.storage_discharging_efficiency | a in ASSETS];
// average charge / discharge efficiencies (expressed as a %) of storage asset s (s in STORAGES)
float chargeEfficiency[s in isSTORAGES] = storageChargeEfficiency[s] * 100;
float dischargeEfficiency[s in isSTORAGES] = (storageDischargeEfficiency[s] == -1 ? chargeEfficiency[s] : storageDischargeEfficiency[s] * 100);
// maximum AC-side charge / discharge rates (expressed in kW) for storage asset s (s in STORAGES)
float maxStorACActivePowerCharge[s in isSTORAGES] = (chargeEfficiency[s] > 0.0 ? powerMax[s] * (100.0 / chargeEfficiency[s]) : 0.0);
float maxStorACActivePowerDischarge[s in isSTORAGES] = -powerMin[s] * (dischargeEfficiency[s] / 100.0);
// HARD-CODED
// hardcoded total number of inverters for storages
// this parameter is set in pre-opt process script below
int inverterNbr[isSTORAGES];
// hardcoded max discharge power for storages used to deduce number of healthy inverters
// this parameter is set in pre-opt process script below
float hardCodedPowerMin[isSTORAGES];
int availInverterNbr[s in isSTORAGES] = (hardCodedPowerMin[s] > 0.0 ? ftoi(round(-powerMin[s] / hardCodedPowerMin[s] * inverterNbr[s])) : 0);
// maximum power input / output (expressed in kW) possible for site i (i in SITES)
float maxInput[i in isSITES] = powerMax[i];
float maxOutput[i in isSITES] = -powerMin[i];
// initial level of power input/output (expressed in kW) for asset a before the beginning of decision step 1
// positive values mean power output, negative values mean power input
float initialPower[isASSETS] = [a.asset_id : -a.initial_power | a in ASSETS];
// thermal generator initial power (expressed in kW)
float genInitialPower[g in isTHERMAL_GENS] = initialPower[g];
// active power floor under which asset is conseidered to be off (in kW)
float onStateTolerance[isASSETS] = [a.asset_id : a.power_tolerance | a in ASSETS];
// thermal generator initial state
// 0 means it was off, 1 it was on
int genInitialState[g in isTHERMAL_GENS] = genInitialPower[g] <= onStateTolerance[g] ? 0 : 1;
// minimum time each asset can continuously generate / consume for (expressed in minutes)
int minTimeOn[isASSETS] = [a.asset_id : a.min_time_on | a in ASSETS];
// minimum number of steps each thermal generator can continuously generate for
int genMinStepsOn[g in isTHERMAL_GENS] = ftoi(ceil(minTimeOn[g] / stepDuration[first(isDECISION_STEPS)]));
// maximum time each asset can continuously generate / consume for (expressed in minutes)
int maxTimeOn[isASSETS] = [a.asset_id : a.max_time_on | a in ASSETS];
// maximum number of steps each thermal generator can continuously generate for
int genMaxStepsOn[g in isTHERMAL_GENS] = ftoi(floor(maxTimeOn[g] / stepDuration[first(isDECISION_STEPS)]));
// minimum recovery time (expressed in minutes) between two continuous generation / consumption from each asset
int minRecoveryTime[isASSETS] = [a.asset_id : a.min_recovery_period | a in ASSETS];
// minimum recovery time (expressed in number os steps) between two continuous generation from each thermal gen
int genMinRecoverySteps[g in isTHERMAL_GENS] = ftoi(ceil(minRecoveryTime[g] / stepDuration[first(isDECISION_STEPS)]));
// time (expressed in minutes) each asset has been continuously on before the beginning of decision step 1
int initialTimeOn[isASSETS] = [a.asset_id : a.initial_time_on | a in ASSETS];
// number of time steps each thermal generator has been continuously on before the beginning of decision step 1
int genInitialStepsOnMax[g in isTHERMAL_GENS] = ftoi(ceil(initialTimeOn[g] / stepDuration[first(isDECISION_STEPS)]));
int maxGenInitialStepsOnMax = max(g in isTHERMAL_GENS) genInitialStepsOnMax[g];
range rgInitialStepOffset = 0..(maxGenInitialStepsOnMax-1);
int genInitialStepsOnMin[g in isTHERMAL_GENS] = ftoi(floor(initialTimeOn[g] / stepDuration[first(isDECISION_STEPS)]));
// time (expressed in minutes) each asset has been continuously off before the beginning of decision step 1
int initialTimeOff[isASSETS] = [a.asset_id : a.initial_time_off | a in ASSETS];
// number of time steps each thermal generator has been continuously off before the beginning of decision step 1
int genInitialStepsOff[g in isTHERMAL_GENS] = ftoi(floor(initialTimeOff[g] / stepDuration[first(isDECISION_STEPS)]));
// asset's piecwise linear cost model ID
string assetVarCostModelId [isASSETS] = [a.asset_id : a.var_cost_model | a in ASSETS];
// thermal generator's variable cost model id
string genVarCostModelId[g in isTHERMAL_GENS] = assetVarCostModelId[g];
// assets maximum energy
float energyMax[isASSETS] = [a.asset_id : a.max_energy | a in ASSETS];
// maximum charge (expressed in kWh) possible for storage asset s (s in STORAGES)
float maxCharge[s in isSTORAGES] = energyMax[s];
// assets initial SOC in %
float initialSOC[isASSETS] = [a.asset_id : a.initial_SOC | a in ASSETS];
// asset final SOC in %
float finalSOCLowerBound[isASSETS] = [a.asset_id : 0.0 | a in ASSETS];
// energy (expressed in kWh) initially stored (that is, stored at the beginning of decision step 1) in storage asset s (s in STORAGES)
float initialCharge[s in isSTORAGES] = initialSOC[s] / 100 * maxCharge[s];
// assets maximum SOC as a %
float SOCMax[isASSETS] = [a.asset_id : a.max_SOC | a in ASSETS];
// assets minimum SOC as a %
float SOCMin[isASSETS] = [a.asset_id : a.min_SOC | a in ASSETS];
// maximum state of charge (expressed as a % of asset's maximum energy storage capacity)
// allowed in storage asset s over decision step t (s in STORAGES, t in DECISION_STEPS)
float maxSOC[s in isSTORAGES] = SOCMax[s];
// minimum state of charge (expressed as a % of asset's maximum energy storage capacity)
// that should be verified in storage asset s over decision step t but that does not justify starting a thermal gen (s in STORAGES, t in DECISION_STEPS)
float minSOC[s in isSTORAGES] = SOCMin[s];
// strict minimum state of charge (expressed as a % of asset's maximum energy storage capacity)
// allowed in storage asset s over decision step t (s in STORAGES, t in DECISION_STEPS)
// HARD-CODED
float strictMinSOC[s in isSTORAGES] = (
	   microgridName == "MICROGRID ENERCAL Ile des Pins"
	|| microgridName == "MICROGRID ENERCAL Mare"
	|| microgridName == "MICROGRID TPL Tongatapu" ? 5.0 : minSOC[s]);
// asset's site
string siteID[isASSETS] = [a.asset_id : a.site | a in ASSETS];
// asset's current injection potential (expressed in A)
float currentInjectionPotential[isASSETS] = [a.asset_id : a.injection_current_potential | a in ASSETS];
// current injection potential (expressed in A) for each thermal generator
float thermalGenCurrentInjection[g in isTHERMAL_GENS] = currentInjectionPotential[g];
// current injection potential (expressed in A) for each intermittent production asset
float interProdCurrentInjection[p in isINTER_PRODS] = currentInjectionPotential[p];
// current injection potential (expressed in A) for each storage asset
float storCurrentInjection[s in isSTORAGES] = availInverterNbr[s] * currentInjectionPotential[s];
// assets variable cost (expressed in currency unit/kWh) (a in ASSETS)
float assetVariableCost[isASSETS] = [a.asset_id : a.variable_cost | a in ASSETS];
// variable costs for intermittent production asset p (expressed in currency unit) (p in isINTER_PRODS)
float interProdVariableCost[p in isINTER_PRODS] = assetVariableCost[p];
// assets curtailment compensation (expressed in currency unit/kWh) (a in ASSETS)
float assetCurtComp[isASSETS] = [a.asset_id : a.compensation_cost | a in ASSETS];
// curtailment compensation for intermittent production asset p (expressed in currency unit) (p in isINTER_PRODS)
float interProdCurtComp[p in isINTER_PRODS] = assetCurtComp[p];
// assets curtailment estimation method (a in ASSETS)
// "FORECAST_BASED" means curtailed energy is computed as forcast generation - generation target
// "DEFAULT_BASED" means curtailed energy is computed as default max generation - generation target
string assetCurtEstimationMethod[isASSETS] = [a.asset_id : a.compensation_model | a in ASSETS];
// curtailment estimation method for intermittent production asset p (p in isINTER_PRODS)
string interProdCurtEstimationMethod[p in isINTER_PRODS] = assetCurtEstimationMethod[p];
// thermal gen's linear factor of max reactive power approximation as a linear function of active power
float aThermalGenQmax[isTHERMAL_GENS];
// thermal gen's constant term of max reactive power approximation as a linear function of active power
float bThermalGenQmax[isTHERMAL_GENS];
// intermittent prod unit's linear factor of max reactive power approximation as a linear function of active power
float aInterProdQmax[isINTER_PRODS];
// intermittent prod unit's constant term of max reactive power approximation as a linear function of active power
float bInterProdQmax[isINTER_PRODS];
// intermittent prod unit's linear factor of min reactive power approximation as a linear function of active power
float aInterProdQmin[isINTER_PRODS];
// intermittent prod unit's constant term of min reactive power approximation as a linear function of active power
float bInterProdQmin[isINTER_PRODS];
// flexible load unit's linear factor of max reactive power approximation as a linear function of active power
float aFlexLoadQmax[isFLEX_LOADS];
// flexible load unit's constant term of max reactive power approximation as a linear function of active power
float bFlexLoadQmax[isFLEX_LOADS];
// flexible load unit's linear factor of min reactive power approximation as a linear function of active power
float aFlexLoadQmin[isFLEX_LOADS];
// flexible load unit's constant term of min reactive power approximation as a linear function of active power
float bFlexLoadQmin[isFLEX_LOADS];
// non-flexible load unit's linear factor of max reactive power approximation as a linear function of active power
float aNFLoadQmax[isNF_LOADS];
// non-flexible load unit's constant term of max reactive power approximation as a linear function of active power
float bNFLoadQmax[isNF_LOADS];
// storage unit's linear factor of max reactive power approximation as a linear function of active power when storage is discharging
float aStorQmaxOnDisch[isSTORAGES];
// storage unit's constant term of max reactive power approximation as a linear function of active power when storage is discharging
float bStorQmaxOnDisch[isSTORAGES];
// storage unit's linear factor of min reactive power approximation as a linear function of active power when storage is discharging
float aStorQminOnDisch[isSTORAGES];
// storage unit's constant term of min reactive power approximation as a linear function of active power when storage is discharging
float bStorQminOnDisch[isSTORAGES];
// storage unit's linear factor of max reactive power approximation as a linear function of active power when storage is charging
float aStorQmaxOnCharge[isSTORAGES];
// storage unit's constant term of max reactive power approximation as a linear function of active power when storage is charging
float bStorQmaxOnCharge[isSTORAGES];
// storage unit's linear factor of min reactive power approximation as a linear function of active power when storage is charging
float aStorQminOnCharge[isSTORAGES];
// storage unit's constant term of min reactive power approximation as a linear function of active power when storage is charging
float bStorQminOnCharge[isSTORAGES];
// fraction of asset's active power used to define spinning raise reserve requirements
// HARD-CODED
//float assetRaiseReserveReq[isASSETS] = [a.asset_id : a.spin_raise_reserv_req_perc | a in ASSETS];
//float NFLoadSpinRaiseReserveReq[n in isNF_LOADS] = assetRaiseReserveReq[n];
float NFLoadSpinRaiseReserveReq[isNF_LOADS] = [(microgridName == "MICROGRID TPL Tongatapu" ? 30.0 : 0.0)];
// fraction of asset's active power used to define spinning lower reserve requirements
// HARD-CODED
//float assetLowerReserveReq[isASSETS] = [a.asset_id : a.spin_lower_reserv_req_perc | a in ASSETS];
//float NFLoadSpinLowerReserveReq[n in isNF_LOADS] = assetLowerReserveReq[n];
float NFLoadSpinLowerReserveReq[isNF_LOADS] = [(microgridName == "MICROGRID TPL Tongatapu" ? 30.0 : 0.0)];
// average power forecast (expressed in kW) for microgid asset a over decision step t ((a, t) in ASSET_STEPS)
float powerPrediction[isASSETS][isDECISION_STEPS] = [as.asset_id : [as.step_id : as.power_prediction] | as in ASSET_STEPS];
// average power consumption forecast (expressed in kW) for non-flexible load unit n over decision step t
// (n in NF_LOADS, t in DECISION_STEPS)
float NFLoadForecast[n in isNF_LOADS][t in isDECISION_STEPS] = maxl(minl(maxNFLoad[n], powerPrediction[n][t]),minNFLoad[n]);
// nominal average power consumption (expressed in kW) forecast for flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
float flexLoadForecast[f in isFLEX_LOADS][t in isDECISION_STEPS] = maxl(minl(maxFlexLoad[f], powerPrediction[f][t]), minFlexLoad[f]);
// maximum average power generation forecast (expressed in kW) for intermittent production asset i over decision step t
// (i in INTER_PRODS, t in DECISION_STEPS)
float interProdActivePowerForecast[i in isINTER_PRODS][t in isDECISION_STEPS] = maxl(minl(maxInterProdActivePower[i],-powerPrediction[i][t]), minInterProdActivePower[i]);
// SOC Target (expressed as a % of asset's maximum energy storage capacity) for Battery Storage asset s over decision step t
// (s in isStorages, t in DECISION_STEPS)
// -1 : no SocTarget ; >-1 : there is a SOCTarget
float socTarget[isASSETS][isDECISION_STEPS] = [as.asset_id : [as.step_id : as.soc_target] | as in ASSET_STEPS];
float socTargetStorage[s in isSTORAGES][t in isDECISION_STEPS] = ( socTarget[s][t] < 0.0 ? -1.0 : minl(maxl(minSOC[s],socTarget[s][t]),maxSOC[s]));
// Variable describe the availability of the asset a over the decision step t
// -1 the asset a is not available during the decision step t 
// 1 the asset a is available during the decision step t 
int availability[isASSETS][isDECISION_STEPS] = [as.asset_id : [as.step_id : as.availability] | as in ASSET_STEPS];
int storAvail[s in isSTORAGES][t in isDECISION_STEPS] = (availability[s][t] == 1 ? 1 : 0 );
int flexLoadAvail[f in isFLEX_LOADS][t in isDECISION_STEPS] = (availability[f][t] == 1 ? 1 : 0 );
// lower limit imposed by network congestion constraint c (c in CONGESTIONS)
float congestionLowerLim[isCONGESTIONS] = [c.congestion_id : -c.max_power_in | c in CONGESTIONS];
// upper limit imposed by network congestion constraint c (c in CONGESTIONS)
float congestionUpperLim[isCONGESTIONS] = [c.congestion_id : c.max_power_out | c in CONGESTIONS];
// left hand side coefficient of power import from main grid in network congestion constraint c (c in CONGESTION)
float importFactor[isCONGESTIONS] = [c.congestion_id : c.power_import_coef | c in CONGESTIONS];
// left hand side coefficients of assets in network congestion constraints
float assetCongestionFactor[isCONGESTIONS][isASSETS] = [ca.congestion_id : [ca.asset_id : ca.power_coef] | ca in CONGESTION_ASSETS];
// left hand side coefficient of power generation from thermal generator g in network congestion constraint c
// (g in THERMAL_GENS, c in CONGESTION)
float thermalGenFactor[c in isCONGESTIONS][g in isTHERMAL_GENS] = assetCongestionFactor[c][g];
// left hand side coefficient of power generation from intermittent prod asset p in network congestion constraint c
// (g in THERMAL_GENS, c in CONGESTION)
float interProdFactor[c in isCONGESTIONS][p in isINTER_PRODS] = assetCongestionFactor[c][p];
// left hand side coefficient of power injection from storage asset s in network congestion constraint c
// (s in STORAGES, c in CONGESTION)
float injectionFactor[c in isCONGESTIONS][s in isSTORAGES] = assetCongestionFactor[c][s];
// left hand side coefficient of power consumption from flexible load unit f in network congestion constraint c
// (f in FLEX_LOADS, c in CONGESTION)
float flexLoadFactor[c in isCONGESTIONS][f in isFLEX_LOADS] = assetCongestionFactor[c][f];
// left hand side coefficient of power consumption from non-flexible load unit n in network congestion constraint c
// (n in NF_LOADS, c in CONGESTION)
float nonFlexLoadFactor[c in isCONGESTIONS][n in isNF_LOADS] = assetCongestionFactor[c][n];
// day-ahead electricity market price (expressed in currency unit per kWh) at decision step t
// (t in DECISION_STEPS)
// this price is used to compute costs from imports from the main-grid as well as earnings from exports to the main-grid
float electricityPrice[isDECISION_STEPS] = [os.step_id : os.electricity_price | os in OPERATION_STEPS];
// max elec price over optim horizon
float maxPrice = maxl(abs(electricityTariff), max(t in isDECISION_STEPS) abs(electricityPrice[t]));
// max generation cost over optim horizon
float maxCost = maxl(
	max (cm in isVAR_COST_MODELS, s in 1..maxSegNbr) varCostSegCost[cm][s],
	max (a in isASSETS) assetVariableCost[a],
	max (a in isASSETS) assetCurtComp[a],
	max (t in isDECISION_STEPS, g in isTHERMAL_GENS: stepDurationInHours[t] > 0.0 && maxThermalGenActivePower[g] > 0.0)
		(thermalGenStartupCost[g] / (stepDurationInHours[t] * maxThermalGenActivePower[g])));
// max between max price and max cost
float penaltyBase = maxl(1, maxPrice, maxCost);

// cat 5 violation variable penalty costs
/////////////////////////////////////////
float cat5_1Pen = max(g in isTHERMAL_GENS)minThermalGenActivePower[g];
float cat5_2Pen = 1.2*max (a in isASSETS) assetStartupCost[a];
float cat5_3Pen = 1 ;
// penalty cost (expressed in currency unit per ) applied if a min or max time on or off constraint cannot hold
float genMinStepOnPenaltyCost =  cat5_1Pen * penaltyBase;
float genMaxStepOnPenaltyCost = cat5_2Pen ;
float genMinStepOffPenaltyCost =  cat5_3Pen * penaltyBase;
// penalty cost for non-respect of minimal active power for gensets
float minThermalGenActivePowerDeficitPenalty = cat5_2Pen * penaltyBase ;
// artificial penalty to encourage first step's average active power to stay the same as it was initially for thermal gen g if g is initially on
// (g in THERMAL_GENS)
float thermaGenInitialPowerViolPenalty = 0.1 * min(cm in isVAR_COST_MODELS, s in 1..maxSegNbr) varCostSegCost[cm][s];
// artificial penality to encourage early/late battery charges/discharges
float storArtificialPenality[t in isDECISION_STEPS] =
	(
		microgridName == "MICROGRID ENERCAL Ile des Pins" || microgridName == "MICROGRID ENERCAL Mare" 
			? stepIndex[t] / optimisationStepNumber * 10.0	// for IDP and Mare, we want to encourage early discharge (see StorChargeDischargeCost var)
			: (
				microgridName == "MICROGRID MORBIHAN ENERGIES FlexMobIle" || microgridName == "MICROGRID MORBIHAN ENERGIES Kergrid"	// for FlexMob'Ile and Kergrid, we want to encourage late charge (see StorChargeDischargeCost var)
				? (optimisationStepNumber - stepIndex[t]) / optimisationStepNumber / 10.0
				: (
					microgridName == "MICROGRID TPL Tongatapu"
					? stepIndex[t] / optimisationStepNumber / 100.0	// for Tongatapu we want to encourage early discharge (see StorChargeDischargeCost var)
					: 0.0
				  )
			   )
	); 

// cat 4 violation variable penalty costs
/////////////////////////////////////////
float cat4Pen =
	(sum(g in isTHERMAL_GENS) (maxThermalGenActivePower[g]) > 0	// is there any thermal generators?
		? 2 * maxl(max(a in isASSETS) minRecoveryTime[a], 20) * 1.1 * cat5_2Pen / maxl(5/60, min(t in isDECISION_STEPS) stepDurationInHours[t]) // 
		: (card(isDEFAULT_CURRENT_ASSET) > 0	// is there any assets with non-zero default current potential? 
			? 1.2 * (	// yes, so compute cat 4 penalty based on max over all possible variable costs and startup costs
					  card(isDEFAULT_CURRENT_ASSET) * (maxl(
															max(cm in isVAR_COST_MODELS, s in 1..maxSegNbr) varCostSegCost[cm][s],
															max (b in isDEFAULT_CURRENT_ASSET) assetVariableCost[b],
															max (b in isDEFAULT_CURRENT_ASSET) assetCurtComp[b],
															10
															)
														+ max(b in isDEFAULT_CURRENT_ASSET) assetStartupCost[b] / maxl(defaultCurrentRequirement, 1)
														)
					)
			: 10	// no there isn't
			)
		);
// penalty cost (expressed in currency unit per Ah) applied if default current requirement constraints cannot be satisfied
float defaultCurrentReqDeficitPenaltyCost =  cat4Pen * penaltyBase; //must break min time off and 

// cat 3 violation variable penalty costs
/////////////////////////////////////////
float cat3Pen = (card(isDEFAULT_CURRENT_ASSET) > 0	// is there any assets with non-zero default current potential?
	? cat4Pen // yes
	: 1.2 * ( // no, so compute cat 4 penalty based on max over all possible variable costs and startup costs
				(card(isASSETS) - card(isSITES) - card(isNF_LOADS) - card(isFLEX_LOADS)) * (maxl(
																								max(cm in isVAR_COST_MODELS, s in 1..maxSegNbr) varCostSegCost[cm][s],
																								max (a in isASSETS) assetVariableCost[a],
																								max (a in isASSETS) assetCurtComp[a],
																								10
																								) 
																							+ max(a in isASSETS) assetStartupCost[a] / maxl(defaultCurrentRequirement, 1)
																							)
	)
);
	
// penalty cost (expressed in currency unit per kWh) applied if active power upper reserve constraints cannot be satisfied
float activePowerRaiseReserveDeficitPenaltyCost =  cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if active power upper reserve constraints cannot be satisfied
float activePowerLowerReserveDeficitPenaltyCost =  cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per kVARh) applied if reactive power upper reserve constraints cannot be satisfied
float reactivePowerRaiseReserveDeficitPenaltyCost =  cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per kVARh) applied if reactive power upper reserve constraints cannot be satisfied
float reactivePowerLowerReserveDeficitPenaltyCost =  cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if spinnig raise reserve constraints cannot be satisfied
float spinnigRaiseReserveDeficitPenaltyCost =  cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if spinnig lower reserve constraints cannot be satisfied
float spinnigLowerReserveDeficitPenaltyCost =  cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if SOC min or SOC max constraints are violated
// note: SOC min is used by Enercal to garanty battery can provide reserve over 15 minutes
float SOCminMaxViolationPenaltyCost = cat3Pen * penaltyBase;
float SOCminViolationPenaltyCost = 1.2 * max(cm in isVAR_COST_MODELS, s in 1..maxSegNbr) varCostSegCost[cm][s];
// penalty cost (expressed in currency unit per kWh) applied if AuthorizeCurt1&2 reserve constraints cannot be satisfied
float unauthorizedInterProdCurtPenaltyCost =  0.1 * penaltyBase;
// penalty cost (expressed in currency unit per kwh) applied if ctStorageTargetSoc constraint cannot be satisfied
float SocTargetStorageDeficitViolation = cat3Pen * penaltyBase;

// cat 2 violation variable penalty costs
/////////////////////////////////////////
float cat2Pen = 200*cat3Pen;
// penalty cost (expressed in currency unit per kWh) applied if power balance constraint cannot be satisfied
float powerImbalancePenaltyCost = cat2Pen * penaltyBase;

// cat 1 violation variable penalty costs
/////////////////////////////////////////
float cat1Pen = 100 * cat2Pen;
// penalty cost (expressed in currency unit per kWh) applied if maximum generation potential forecast constraint cannot be satisfied
float InterProdForecastExcessPenaltyCost = cat1Pen * penaltyBase; 
// penalty cost (expressed in currency unit per kWh) applied if nominal load forecast for a flexible load unit is not compatible
// with the unit's minimum or maximum consumption
float flexLoadForecastViolationPenaltyCost = cat1Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if a site maximum input/output constraint cannot hold
float siteInOutViolationPenaltyCost = cat1Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if a network congestion constraint cannot hold
float congestionLimViolationPenaltyCost = cat1Pen * penaltyBase; 

// HVAC hardcoded data
{string} isTARGET_LEVELS = {"LOW", "NOMINAL", "HIGH"};
float dummyTargetLevelTemps[isTARGET_LEVELS] = [0.0, 25.0, 50.0];
float targetLevelTemps[isFLEX_LOADS][isTARGET_LEVELS] = [f : [l : dummyTargetLevelTemps[l]] | f in isFLEX_LOADS, l in isTARGET_LEVELS];																							   
// HVAC hardcoded data

/*********************************************************************
 * Optim pre-processing
 *********************************************************************/
execute CPX_PARAM {
	if (operationID == "2021")
		microgridName = "MICROGRID Srisangtham Microgrid";
	if (operationID == "1133")
		microgridName = "MICROGRID ENERCAL Ile des Pins";
	if (operationID == "1136")
		microgridName = "MICROGRID ENERCAL Mare";
	if (operationID == "1100")
		microgridName = "MICROGRID MORBIHAN ENERGIES FlexMobIle";
	if (operationID == "1134")
		microgridName = "MICROGRID MORBIHAN ENERGIES Kergrid";
	if (operationID == "1067")
		microgridName = "MICROGRID Demo company";
	if (operationID == "1168" || operationID == "1267")
		microgridName = "MICROGRID TPL Tongatapu";
	if (operationID == "1167")
		microgridName = "VidoFleur Scheduled Assets";

// HARD-CODED
	for (var g in isTHERMAL_GENS){

		// Default values
		aThermalGenQmax[g] = 0.0;
		bThermalGenQmax[g] = 0.0;
		
		// Values for MICROGRID ENERCAL Ile des Pins
		if (microgridName == "MICROGRID ENERCAL Ile des Pins") {
			aThermalGenQmax[g] = -0.59749;
			bThermalGenQmax[g] = 622.26356;
 		}			

		// Values for MICROGRID ENERCAL Mare
		if (microgridName == "MICROGRID ENERCAL Mare") {
			// Values for QSK23 (520kW) gensets: MAR3 & MAR5
			if (g == "ENERCAL_MARE_GE_3_NC" || g == "ENERCAL_MARE_GE_5_NC") {
				aThermalGenQmax[g] = -0.59749;
				bThermalGenQmax[g] = 622.26356;
			}
			// Values for QSK38 (1000kW) gensets: MAR1, MAR2 & MAR4
			if (g == "ENERCAL_MARE_GE_1_NC" || g == "ENERCAL_MARE_GE_2_NC" || g == "ENERCAL_MARE_GE_4_NC") {
				aThermalGenQmax[g] = -0.37;
				bThermalGenQmax[g] = 1107.8;
			}
 		}			

		// Values for MICROGRID TPL Tongatapu
		if (microgridName == "MICROGRID TPL Tongatapu") {
			// Values for Cummins (1600kW) gensets: Popua - DG Cummins
			if (g == "Tongatapu_Popua_GE7") {
				aThermalGenQmax[g] = -0.3363;
				bThermalGenQmax[g] = 1738.2888;
			}
			// Values for Cat (1400kW) gensets: Popua - DG Caterpillar #1 to #6
			if (g == "Tongatapu_Popua_GE1" || g == "Tongatapu_Popua_GE2" || g == "Tongatapu_Popua_GE3" || g == "Tongatapu_Popua_GE4" || g == "Tongatapu_Popua_GE5" || g == "Tongatapu_Popua_GE6") {
				aThermalGenQmax[g] = -0.2889;
				bThermalGenQmax[g] = 1729.6619;
			}
			// Values for MAK (2760kW) gensets: Popua - DG MAK #1 and #2
			if (g == "Tongatapu_Popua_GE8" || g == "Tongatapu_Popua_GE9") {
//				aThermalGenQmax[g] = -0.5003;
//				bThermalGenQmax[g] = 3190.2481;
				aThermalGenQmax[g] = 0.0;
				bThermalGenQmax[g] = 0.0;
			}
 		}			
	}	
// HARD-CODED
	for (var p in isINTER_PRODS){
		// Default values
		aInterProdQmax[p] = 0.0;
		bInterProdQmax[p] = 0.0;
		aInterProdQmin[p] = 0.0;
		bInterProdQmin[p] = 0.0;
	}	
// HARD-CODED
	for (var s in isSTORAGES){

		// Default values
		aStorQmaxOnDisch[s] = 0.0;
		bStorQmaxOnDisch[s] = 0.0;
		aStorQminOnDisch[s] = 0.0;
		bStorQminOnDisch[s] = 0.0;
		aStorQmaxOnCharge[s] = 0.0;
		bStorQmaxOnCharge[s] = 0.0;
		aStorQminOnCharge[s] = 0.0;
		bStorQminOnCharge[s] = 0.0;
		inverterNbr[s] = 1;
		hardCodedPowerMin[s] = -powerMin[s];

		// Values for MICROGRID ENERCAL Ile des Pins
		if (microgridName == "MICROGRID ENERCAL Ile des Pins") {
			inverterNbr[s] = 6;
			hardCodedPowerMin[s] = 1040.0;
			if (availInverterNbr[s] >= inverterNbr[s]) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 1890.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 1890.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 1890.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 1890.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-1) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 1575.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 1575.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 1575.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 1575.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-2) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 1260.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 1260.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 1260.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 1260.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-3) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 945.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 945.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 945.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 945.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-4) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 630.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 630.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 630.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 630.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-5) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 315.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 315.0;			// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 315.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 315.0;		// charge
			}		
			if (availInverterNbr[s] <= inverterNbr[s]-6) {
				aStorQmaxOnDisch[s] = 0.0;		// discharge
				bStorQmaxOnDisch[s] = 0.0;		// discharge
				aStorQminOnDisch[s] = 0.0;		// charge
				bStorQminOnDisch[s] = 0.0;		// charge
				aStorQmaxOnCharge[s] = 0.0;	// discharge
				bStorQmaxOnCharge[s] = 0.0;		// discharge
				aStorQminOnCharge[s] = 0.0;	// charge
				bStorQminOnCharge[s] = 0.0;		// charge
			}
		}			
		
		// Values for MICROGRID ENERCAL Mare
		if (microgridName == "MICROGRID ENERCAL Mare") {
			inverterNbr[s] = 8;
			hardCodedPowerMin[s] = 1047.0;
			if (availInverterNbr[s] >= inverterNbr[s]) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 2520.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 2520.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 2520.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 2520.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-1) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 2205.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 2205.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 2205.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 2205.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-2) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 1890.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 1890.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 1890.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 1890.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-3) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 1575.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 1575.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 1575.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 1575.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-4) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 1260.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 1260.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 1260.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 1260.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-5) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 945.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 945.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 945.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 945.0;		// charge
			}		
			if (availInverterNbr[s] == inverterNbr[s]-6) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 630.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 630.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 630.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 630.0;		// charge
			}
			if (availInverterNbr[s] == inverterNbr[s]-7) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 315.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 315.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 315.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 315.0;		// charge
			}
			if (availInverterNbr[s] <= inverterNbr[s]-8) {
				aStorQmaxOnDisch[s] = 0.0;		// discharge
				bStorQmaxOnDisch[s] = 0.0;		// discharge
				aStorQminOnDisch[s] = 0.0;		// charge
				bStorQminOnDisch[s] = 0.0;		// charge
				aStorQmaxOnCharge[s] = 0.0;	// discharge
				bStorQmaxOnCharge[s] = 0.0;		// discharge
				aStorQminOnCharge[s] = 0.0;	// charge
				bStorQminOnCharge[s] = 0.0;		// charge
			}
 		}			

		// Values for MICROGRID TPL Tongatapu
		if (microgridName == "MICROGRID TPL Tongatapu") {
			if (s == "Tongatapu_Matatoa_BESS") {	
				inverterNbr[s] = 3;
				hardCodedPowerMin[s] = 6000.0;
				if (availInverterNbr[s] >= inverterNbr[s]) {
					aStorQmaxOnDisch[s] = -0.56575922;
					bStorQmaxOnDisch[s] = 6324.55532;
					aStorQminOnDisch[s] = -0.72075922;
					bStorQminOnDisch[s] = 6324.55532;
					aStorQmaxOnCharge[s] = -0.56575922;
					bStorQmaxOnCharge[s] = 6324.55532;
					aStorQminOnCharge[s] = -0.72075922;
					bStorQminOnCharge[s] = 6324.55532;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-1) {
					aStorQmaxOnDisch[s] = -0.56575;
					bStorQmaxOnDisch[s] = 4216.37021;
					aStorQminOnDisch[s] = -0.72075;
					bStorQminOnDisch[s] = 4216.37021;
					aStorQmaxOnCharge[s] = -0.56575;
					bStorQmaxOnCharge[s] = 4216.37021;
					aStorQminOnCharge[s] = -0.72075;
					bStorQminOnCharge[s] = 4216.37021;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-2) {
					aStorQmaxOnDisch[s] = -0.56575;
					bStorQmaxOnDisch[s] = 2108.1851;
					aStorQminOnDisch[s] = -0.72075;
					bStorQminOnDisch[s] = 2108.1851;
					aStorQmaxOnCharge[s] = -0.56575;
					bStorQmaxOnCharge[s] = 2108.1851;
					aStorQminOnCharge[s] = -0.72075;
					bStorQminOnCharge[s] = 2108.1851;
				}		
				if (availInverterNbr[s] <= inverterNbr[s]-3) {
					aStorQmaxOnDisch[s] = 0.0;
					bStorQmaxOnDisch[s] = 0.0;
					aStorQminOnDisch[s] = 0.0;
					bStorQminOnDisch[s] = 0.0;
					aStorQmaxOnCharge[s] = 0.0;
					bStorQmaxOnCharge[s] = 0.0;
					aStorQminOnCharge[s] = 0.0;
					bStorQminOnCharge[s] = 0.0;
				}
 			}	// if s == "Matatoa"
			if (s == "Tongatapu_Popua_BESS") {
				inverterNbr[s] = 3; 
				hardCodedPowerMin[s] = 7200.0;
				if (availInverterNbr[s] >= inverterNbr[s]) {
					aStorQmaxOnDisch[s] = -0.56754;
					bStorQmaxOnDisch[s] = 7586.31003;
					aStorQminOnDisch[s] = -0.72448;
					bStorQminOnDisch[s] = 7586.31003;
					aStorQmaxOnCharge[s] = -0.56615;
					bStorQmaxOnCharge[s] = 7586.31003;
					aStorQminOnCharge[s] = -0.7217;
					bStorQminOnCharge[s] = 7586.31003;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-1) {
					aStorQmaxOnDisch[s] = -0.56754;
					bStorQmaxOnDisch[s] = 5057.54002;
					aStorQminOnDisch[s] = -0.72448;
					bStorQminOnDisch[s] = 5057.54002;
					aStorQmaxOnCharge[s] = -0.56615;
					bStorQmaxOnCharge[s] = 5057.54002;
					aStorQminOnCharge[s] = -0.7217;
					bStorQminOnCharge[s] = 5057.54002;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-2) {
					aStorQmaxOnDisch[s] = -0.56754;
					bStorQmaxOnDisch[s] = 2528.77001;
					aStorQminOnDisch[s] = -0.72448;
					bStorQminOnDisch[s] = 2528.77001;
					aStorQmaxOnCharge[s] = -0.56615;
					bStorQmaxOnCharge[s] = 2528.77001;
					aStorQminOnCharge[s] = -0.7217;
					bStorQminOnCharge[s] = 2528.77001;
				}		
				if (availInverterNbr[s] <= inverterNbr[s]-3) {
					aStorQmaxOnDisch[s] = 0.0;
					bStorQmaxOnDisch[s] = 0.0;
					aStorQminOnDisch[s] = 0.0;
					bStorQminOnDisch[s] = 0.0;
					aStorQmaxOnCharge[s] = 0.0;
					bStorQmaxOnCharge[s] = 0.0;
					aStorQminOnCharge[s] = 0.0;
					bStorQminOnCharge[s] = 0.0;
				}
  			}	// if s == "Popua"			
			if (s == "Tongatapu_Dummy_for_FAT1_BESS") {	
				inverterNbr[s] = 6;
				hardCodedPowerMin[s] = 13200.0;
				if (availInverterNbr[s] >= inverterNbr[s]) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 13910.86266;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 13910.86266;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 13910.86266;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 13910.86266;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-1) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 11592.38555;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 11592.38555;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 11592.38555;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 11592.38555;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-2) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 9273.90844;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 9273.90844;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 9273.90844;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 9273.90844;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-3) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 6955.43133;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 6955.43133;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 6955.43133;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 6955.43133;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-4) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 4636.95422;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 4636.95422;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 4636.95422;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 4636.95422;
				}		
				if (availInverterNbr[s] == inverterNbr[s]-5) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 2318.47711;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 2318.47711;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 2318.47711;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 2318.47711;
				}		
				if (availInverterNbr[s] <= inverterNbr[s]-6) {
					aStorQmaxOnDisch[s] = 0.0;
					bStorQmaxOnDisch[s] = 0.0;
					aStorQminOnDisch[s] = 0.0;
					bStorQminOnDisch[s] = 0.0;
					aStorQmaxOnCharge[s] = 0.0;
					bStorQmaxOnCharge[s] = 0.0;
					aStorQminOnCharge[s] = 0.0;
					bStorQminOnCharge[s] = 0.0;
				}
 			}	// if s == "Dummy_for_FAT1"
		}		// if microGridName == "Tongatapu"		
	}			// for s in isSTORAGES	
// HARD-CODED
	for (var f in isFLEX_LOADS){
		// Default values
		aFlexLoadQmax[f] = 0.0;
		bFlexLoadQmax[f] = 0.0;
		aFlexLoadQmin[f] = 0.0;
		bFlexLoadQmin[f] = 0.0;
	}	
// HARD-CODED
	for (var n in isNF_LOADS){
		
		// Default values
		aNFLoadQmax[n] = 0.0;
		bNFLoadQmax[n] = 0.0;
		
		// Values for MICROGRID ENERCAL Ile des Pins
		if (microgridName == "MICROGRID ENERCAL Ile des Pins") {
			aNFLoadQmax[n] = 0.3349;
			bNFLoadQmax[n] = 0.0;
		}		
		
		// Values for MICROGRID MICROGRID ENERCAL Mare
		if (microgridName == "MICROGRID ENERCAL Mare") {
			aNFLoadQmax[n] = 0.3349;
			bNFLoadQmax[n] = 0.0;
		}		
		
		// Values for MICROGRID TPL Tongatapu
		if (microgridName == "MICROGRID TPL Tongatapu") {
			aNFLoadQmax[n] = 0.3349;
			bNFLoadQmax[n] = 0.0;
		}		
	}		
	
//	cplex.epgap = 0.18/100;
	settings.displayPrecision = 10;	// 4 by default
	if (maxOptimisationTime >= 0)
		cplex.tilim = 60 * maxOptimisationTime;
//	cplex.randomseed = 1;
//	writeln(cplex.randomseed);	
	
//	cplex.exportModel(".\\OPLtetris.sav"); //can only be called in flow control code (main)
//	cplex.exportModel(".\\OPLmicrogrid.lp"); //can only be called in flow control code (main)
//	cplex.importModel(".\\tetris.sav");	 //can only be called in flow control code (main)
}

/*********************************************************************
 * Decision variables
 *********************************************************************/
// Intermittent production assets
/////////////////////////////////
// average power generation target (expressed in kW) for intermittent production asset p over decision step t
// (p in INTER_PRODS, t in DECISION_STEPS)
dvar float+ InterProdActivePower[isINTER_PRODS][isDECISION_STEPS];
// active power curtailment (expressed in kW) for intermittent production asset p over step t
// (p in INTER_PRODS, t in DECISION_STEPS)
dexpr float InterProdPowerCurtailment[i in isINTER_PRODS][t in isDECISION_STEPS] = (maxInterProdActivePower[i] > 0 ? interProdActivePowerForecast[i][t] - InterProdActivePower[i][t] : 0.0);
// flag indicating whether intermittent production asset p is being curtailed over step t
// (p in INTER_PRODS, t in DECISION_STEPS)
dvar boolean InterProdIsCurtailed[isINTER_PRODS][isDECISION_STEPS];
// estimation of curtailed power (expressed in kW) that is penalised for intermittent production asset p over step t
// (p in INTER_PRODS, t in DECISION_STEPS) 
dexpr float InterProdCurtEstimation[i in isINTER_PRODS][t in isDECISION_STEPS] = (
	interProdCurtEstimationMethod[i] == "DEFAULT_BASED"
		? InterProdPowerCurtailment[i][t] + InterProdIsCurtailed[i][t] * (maxInterProdActivePower[i] - interProdActivePowerForecast[i][t])
		: InterProdPowerCurtailment[i][t]);
// max reactive power generation (expressed in kVAR) for intermittent production asset p over decision step t 
// (p in INTER_PRODS,t in DECISION_STEPS)
dexpr float InterProdMaxReactivePower[p in isINTER_PRODS][t in isDECISION_STEPS] = (
	maxl(maxInterProdActivePower[p],interProdActivePowerForecast[p][t]) > 0.0
		? aInterProdQmax[p] * InterProdActivePower[p][t] + bInterProdQmax[p]
		: 0.0
	);
// min reactive power generation (expressed in kVAR) for intermittent production asset p over decision step t 
// (p in INTER_PRODS,t in DECISION_STEPS)
dexpr float InterProdMinReactivePower[p in isINTER_PRODS][t in isDECISION_STEPS] = (
	maxl(maxInterProdActivePower[p],interProdActivePowerForecast[p][t]) > 0.0
		? aInterProdQmin[p] * InterProdActivePower[p][t] + bInterProdQmin[p]
		: 0.0
	);
// reactive power generation (expressed in kVAR) for intermittent production asset p over decision step t 
// (p in INTER_PRODS,t in DECISION_STEPS)
dvar float+ InterProdReactivePower[isINTER_PRODS][isDECISION_STEPS];
// Storage assets
/////////////////
// average power injection target (expressed in kW) into the microgrid for storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorACPowerDischarge[isSTORAGES][isDECISION_STEPS];
// average power extraction target (expressed in kW) from the microgrid for storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorACPowerCharge[isSTORAGES][isDECISION_STEPS];
// average power target (expressed in kW) for storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
// positive values = power injections (discharges) and negative values = power extractions (charges) 
dexpr float StorACActivePower[s in isSTORAGES][t in isDECISION_STEPS] = StorACPowerDischarge[s][t] - StorACPowerCharge[s][t];
// flag indicating if storage asset s�s injection target for decision step t corresponds to a charge or a discharge
// (s in STORAGES, t in DECISION_STEPS)
// 1 means charge, 0 means discharge
dvar boolean IsCharging[isSTORAGES][isDECISION_STEPS];
// flag indicating if all storage assets s that have a strictly positive maxStorACActivePowerCharge, are full on decision step t
// (t in DECISION_STEPS)
// 1 means all charged, 0 they are not all charged
dvar boolean AreAllStoragesFull[isDECISION_STEPS];																						   																									  
// incremental energy charge / discharge target (expressed in kWh) for storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
// positive values mean energy inputs into the asset, negative values mean energy output from the asset
dvar float StorStepDCEnergyIn[isSTORAGES][isDECISION_STEPS];
// energy charge target (expressed in kWh) for storage asset s at the end of decision step t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorStoredDCEnergy[isSTORAGES][isDECISION_STEPS];
// active power raise reserve (expressed in kW) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorActiveRaiseReserve[s in isSTORAGES][t in isDECISION_STEPS] = maxStorACActivePowerDischarge[s] - StorACActivePower[s][t];
// active power lower reserve (expressed in kW) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorActiveLowerReserve[s in isSTORAGES][t in isDECISION_STEPS] = maxStorACActivePowerCharge[s] + StorACActivePower[s][t];
// max reactive power (expressed in kVAR) for storage asset s over decision step t if s is discharging active power over t 
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorMaxReactivePowerOnDischarge[s in isSTORAGES][t in isDECISION_STEPS] = (
	maxStorACActivePowerDischarge[s] > 0.0
		? aStorQmaxOnDisch[s] * StorACPowerDischarge[s][t] + bStorQmaxOnDisch[s] * (1 - IsCharging[s][t])
		: 0.0
	);
// min reactive power (expressed in kVAR) for storage asset s over decision step t if s is discharging active power over t 
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorMinReactivePowerOnDischarge[s in isSTORAGES][t in isDECISION_STEPS] = (
	maxStorACActivePowerDischarge[s] > 0.0
		? aStorQminOnDisch[s] * StorACPowerDischarge[s][t] + bStorQminOnDisch[s] * (1 - IsCharging[s][t])
		: 0.0
	);
// reactive power discharge (expressed in kVAR) for storage asset s over decision step t 
// (s in STORAGES,t in DECISION_STEPS)
dvar float+ StorReactivePowerDischarge[isSTORAGES][isDECISION_STEPS];
// min reactive power (expressed in kVAR) for storage asset s over decision step t if s is charging active power over t
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorMinReactivePowerOnCharge[s in isSTORAGES][t in isDECISION_STEPS] = (
	maxStorACActivePowerCharge[s] > 0.0
		? aStorQminOnCharge[s] * StorACPowerCharge[s][t] + bStorQminOnCharge[s] * IsCharging[s][t]
		: 0.0
	);
// max reactive power (expressed in kVAR) for storage asset s over decision step t if s is charging active power over t
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorMaxReactivePowerOnCharge[s in isSTORAGES][t in isDECISION_STEPS] = (
	maxStorACActivePowerCharge[s] > 0.0
		? aStorQmaxOnCharge[s] * StorACPowerCharge[s][t] + bStorQmaxOnCharge[s] * IsCharging[s][t]
		: 0.0
	);
// reactive power charge (expressed in kVAR) for storage asset s over decision step t 
// (s in STORAGES,t in DECISION_STEPS)
dvar float+ StorReactivePowerCharge[isSTORAGES][isDECISION_STEPS];
// reactive power (expressed in kVAR) for storage asset s over decision step t 
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorReactivePower[s in isSTORAGES][t in isDECISION_STEPS] = StorReactivePowerDischarge[s][t] - StorReactivePowerCharge[s][t];
// reactive power raise reserve (expressed in kVAR) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorReactiveRaiseReserve[s in isSTORAGES][t in isDECISION_STEPS] = StorMaxReactivePowerOnDischarge[s][t] + StorMaxReactivePowerOnCharge[s][t] - StorReactivePower[s][t];
// active power lower reserve (expressed in kW) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorReactiveLowerReserve[s in isSTORAGES][t in isDECISION_STEPS] = StorMinReactivePowerOnDischarge[s][t] + StorMinReactivePowerOnCharge[s][t] + StorReactivePower[s][t];
// spinning raise reserve (expressed in kW) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorSpinRaiseReserve[isSTORAGES][isDECISION_STEPS];
// spinning lower reserve (expressed in kW) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorSpinLowerReserve[isSTORAGES][isDECISION_STEPS];
// Connection to grid
/////////////////////
// average power (expressed in kW) imported from the main grid into the microgrid over decision step t
// (t in DECISION_STEPS)
// positive values mean power flows into the microgrid, negative values mean power flows out of the microgrid
dvar float NetImportTarget[isDECISION_STEPS];
// average power (expressed in kW) imported from the main grid into the microgrid decision step t
// (t in DECISION_STEPS)
// strictly positive values mean power flows into the microgrid, zero values mean power flows out of the microgrid.
dvar float+ ImportTarget[isDECISION_STEPS];
// flag indicating if microgrid is importing power from the main grid over decision step t (t in DECISION_STEPS)
// ones mean microgrid is importing and zeros mean microgrid is exporting
dvar boolean IsImporting[isDECISION_STEPS];
// Non-Flexible load units
//////////////////////////
// average active power consumption target (expressed in kW) for non-flexible load unit n over decision step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadActivePower[n in isNF_LOADS][t in isDECISION_STEPS] = NFLoadForecast[n][t];
// average reactive power consumption target (expressed in kVAR) for non-flexible load unit n over decision step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadReactivePower[n in isNF_LOADS][t in isDECISION_STEPS] = (
	maxl(maxNFLoad[n],NFLoadForecast[n][t]) > 0.0
		? aNFLoadQmax[n] * NFLoadActivePower[n][t] + bNFLoadQmax[n]
		: 0.0
	);
// Flexible load units
//////////////////////
// average power consumption target (expressed in kW) for flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadActivePower[isFLEX_LOADS][isDECISION_STEPS];
// average power modulation target (expressed in kW) for flexible load unit f away from its nominal consumption forecast
// over decision step t (f in LOADS, t in DECISION_STEPS)
// positive values mean additional consumption on top of nominal consumption forecasts
// negative values result in consumptions lower than nominal consumption forecasts
dvar float ModulationTarget[isFLEX_LOADS][isDECISION_STEPS];
// active power raise reserve (expressed in kW) from flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadActiveRaiseReserve[f in isFLEX_LOADS][t in isDECISION_STEPS] = FlexLoadActivePower[f][t] - minFlexLoad[f];
// active power lower reserve (expressed in kW) from flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadActiveLowerReserve[f in isFLEX_LOADS][t in isDECISION_STEPS] = maxFlexLoad[f] - FlexLoadActivePower[f][t];
// max reactive power consumption (expressed in kVAR) for flexible load unit f over decision step t 
// (p in FLEX_LOADS,t in DECISION_STEPS)
dexpr float FlexLoadMaxReactivePower[f in isFLEX_LOADS][t in isDECISION_STEPS] = (
	maxl(maxFlexLoad[f],flexLoadForecast[f][t]) > 0.0
		? aFlexLoadQmax[f] * FlexLoadActivePower[f][t] + bFlexLoadQmax[f]
		: 0.0
	);
// min reactive power consumption (expressed in kVAR) for flexible load unit f over decision step t 
// (p in FLEX_LOADS,t in DECISION_STEPS)
dexpr float FlexLoadMinReactivePower[f in isFLEX_LOADS][t in isDECISION_STEPS] = (
	minFlexLoad[f] > 0.0
		? aFlexLoadQmin[f] * FlexLoadActivePower[f][t] + bFlexLoadQmin[f]
		: 0.0
	);
// reactive power consumption (expressed in kVAR) for flexible load unit f over decision step t 
// (f in FLEX_LOADS,t in DECISION_STEPS)
dvar float+ FlexLoadReactivePower[isFLEX_LOADS][isDECISION_STEPS];
// reactive power raise reserve (expressed in kVAR) from flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadReactiveRaiseReserve[f in isFLEX_LOADS][t in isDECISION_STEPS] = FlexLoadReactivePower[f][t] - FlexLoadMinReactivePower[f][t];
// reactive power lower reserve (expressed in kW) from flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadReactiveLowerReserve[f in isFLEX_LOADS][t in isDECISION_STEPS] = FlexLoadMaxReactivePower[f][t] - FlexLoadReactivePower[f][t];
//// spinning raise reserve (expressed in kW) from flexible load unit f over decision step t
//// (f in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadSpinRaiseReserve[isFLEX_LOADS][isDECISION_STEPS];
//// spinning lower reserve (expressed in kW) from storage asset s over decision step t
//// (s in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadSpinLowerReserve[isFLEX_LOADS][isDECISION_STEPS];
//Thermal Generators
////////////////////
//flag indicating if a generator g is on at decision step t
// 1 means it is on, 0 that it is off
// (g in THERMAL_GENS, t in DECISION_STEPS)
dvar boolean IsGenOn[isTHERMAL_GENS][isDECISION_STEPS];
// flag indicating if piecewise linear variable cost model segment s is used for thermal generator g over decision step t 
// 1 means it is used, 0 that it is not
// (g in THERMAL_GENS, s in VAR_COST_SEGS, t in DECISION_STEPS)
dvar boolean GenVarCostSegFlag[isTHERMAL_GENS][s in 1..maxSegNbr][isDECISION_STEPS];
// COST-SEG-CHANGE
//// number of piecewise linear variable cost model segment used for thermal generator g over decision step t 
//// (g in THERMAL_GENS, t in DECISION_STEPS)
//dexpr int GenVarCostSegNbr[g in isTHERMAL_GENS][t in isDECISION_STEPS] = sum (s in 1..maxSegNbr) GenVarCostSegFlag[g][s][t];
// COST-SEG-CHANGE
//// flag indicating if there is a change of piecewise linear variable cost model segment for thermal generator g in decision step t (compred to t-1) 
//// 1 means there is a chnage, 0 means that g is using the same segment in step t as in step t-1
//// (g in THERMAL_GENS, t in DECISION_STEPS)
//dvar boolean GenVarCostSegChange[isTHERMAL_GENS][isDECISION_STEPS];
//part (power in kw) of piecewise linear variable cost model segment s is used for thermal generator g over decision step t
// (g in THERMAL_GENS, s in VAR_COST_SEGS,t in DECISION_STEPS)
dvar float+ GenVarCostSegPower [isTHERMAL_GENS][s in 1..maxSegNbr][isDECISION_STEPS];
// average active power generation (expressed in kW) for thermal generator g over decision step t 
// (g in THERMAL_GENS,t in DECISION_STEPS)
//dexpr float ThermalGenActivePower[g in isTHERMAL_GENS][t in isDECISION_STEPS] = sum (s in 1..varCostModelSegNumber[genVarCostModelId[g]]) GenVarCostSegPower[g][s][t]; // slows opt down
dvar float+ ThermalGenActivePower[g in isTHERMAL_GENS][t in isDECISION_STEPS];
// generation variable cost (expressed in currency unit/h) for thermal generator g over step t 
// (g in THERMAL_GENS,t in DECISION_STEPS)
// dexpr float ThermalGenVarCost[g in isTHERMAL_GENS][t in isDECISION_STEPS] = sum (s in 1..varCostModelSegNumber[genVarCostModelId[g]]) varCostSegCost[genVarCostModelId[g]][s] * GenVarCostSegPower[g][s][t]; // slows opt down
dvar float+ ThermalGenVarCost[isTHERMAL_GENS][isDECISION_STEPS];
// indicator giving evolution of each thermal generator g's status between decision step t and the previous one. 
// -1 means g is shut down at t, 0 means g stays on or stays off, and +1 means g is started
// (g in THERMAL_GENS,t in DECISION_STEPS)
dvar int GenOnEvol[isTHERMAL_GENS][isDECISION_STEPS];
// flag indicating if generator g is started up at decision step t
// 1 means it is started up, 0 that it is not
dvar boolean ThermalGenStartup[isTHERMAL_GENS][isDECISION_STEPS];
// active power raise reserve (expressed in kW) from thermal generator g over decision step t
// (g in THERMAL_GENS, t in DECISION_STEPS)
dexpr float ThermalGenActiveRaiseReserve[g in isTHERMAL_GENS][t in isDECISION_STEPS] = IsGenOn[g][t] * maxThermalGenActivePower[g] - ThermalGenActivePower[g][t];
// max reactive power generation (expressed in kVAR) for thermal generator g over decision step t 
// (g in THERMAL_GENS,t in DECISION_STEPS)
dexpr float ThermalGenMaxReactivePower[g in isTHERMAL_GENS][t in isDECISION_STEPS] = aThermalGenQmax[g] * ThermalGenActivePower[g][t] + IsGenOn[g][t] * bThermalGenQmax[g];
// reactive power generation (expressed in kVAR) for thermal generator g over decision step t 
// (g in THERMAL_GENS,t in DECISION_STEPS)
dvar float+ ThermalGenReactivePower[isTHERMAL_GENS][isDECISION_STEPS];
// reactive power raise reserve (expressed in kVAR) from thermal generator g over decision step t
// (g in THERMAL_GENS, t in DECISION_STEPS)
dexpr float ThermalGenReactiveRaiseReserve[g in isTHERMAL_GENS][t in isDECISION_STEPS] = ThermalGenMaxReactivePower[g][t] - ThermalGenReactivePower[g][t];
// spinning raise reserve (expressed in kW) from thermal gen g over decision step t
// (g in THERMAL_GENS, t in DECISION_STEPS)
dvar float+ ThermalGenSpinRaiseReserve[isTHERMAL_GENS][isDECISION_STEPS];
// spinning lower reserve (expressed in kW) from thermal gen g over decision step t
// (s in THERMAL_GENS, t in DECISION_STEPS)
dvar float+ ThermalGenSpinLowerReserve[isTHERMAL_GENS][isDECISION_STEPS];
// Sites
////////
// site maximum power input violation (that is minimum allowed too high to be compatible with the characteristics of connected assets),
// expressed in kW, for site i over decision step t (i in SITES, t in DECISION_STEPS)
dvar float+ SiteMaxInputViolation[isSITES][isDECISION_STEPS];
// site maximum power output violation (that is maximum allowed too low to be compatible with the characteristics of connected assets),
// expressed in kW, for site i over decision step t (i in SITES, t in DECISION_STEPS).
dvar float+ SiteMaxOutputViolation[isSITES][isDECISION_STEPS];
// Network congestions
//////////////////////
// network congestion lower limit violation (that is lower limit too high to be compatible with the characteristics of impacted assets),
// expressed in kW, for network congestion constraint c over decision step t (c in CONGESTIONS, t in DECISION_STEPS)
dvar float+ CongestionLowerLimViolation[isCONGESTIONS][isDECISION_STEPS];
// network congestion upper limit violation (that is upper limit too low to be compatible with the characteristics of impacted assets),
// expressed in kW, for network congestion constraint c over decision step t (c in CONGESTIONS, t in DECISION_STEPS)
dvar float+ CongestionUpperLimViolation[isCONGESTIONS][isDECISION_STEPS];
// Violation variables
//////////////////////
// average power deficit (expressed in kW) over decision step t (t in DECISION_STEPS)
dvar float+ PowerDeficit[isDECISION_STEPS];
// average power excess (expressed in kW) over decision step t (t in DECISION_STEPS)
dvar float+ PowerExcess[isDECISION_STEPS];
// average power generation target excess (expressed in kWh) over intermittent production asset i�s potential forecast for decision step t
// (i in INTER_PRODS, t in DECISION_STEPS)
dvar float+ InterProdForecastExcess[isINTER_PRODS][isDECISION_STEPS];
// SOC min deficit expressed as a percentage (s in STORAGES, t in DECISION_STEPS)
dvar float+ SOCminDeficit[isSTORAGES][isDECISION_STEPS];
// SOC strict min deficit expressed as a percentage (s in STORAGES, t in DECISION_STEPS)
dvar float+ SOCstrictMinDeficit[isSTORAGES][isDECISION_STEPS];
// SOC max excess expressed as a percentage (s in STORAGES, t in DECISION_STEPS)
dvar float+ SOCmaxExcess[isSTORAGES][isDECISION_STEPS];
// SOCTargetDeficit expressed as a percentage (s in STORAGES, t in DECISION_STEPS)
dvar float+ SocTargetStorageDeficit[isSTORAGES][isDECISION_STEPS];

// nominal load forecast deficit (that is load forecast too low to be compatible with minimum consumption constraint),
// expressed in kW, for flexible load unit f over decision step t (f in FLEX_LOADS, t in DECISION_STEPS).
dvar float+ FlexLoadForecastDeficit[isFLEX_LOADS][isDECISION_STEPS];
 // nominal load forecast excess (that is load forecast too high to be compatible with maximum consumption constraint),
 // expressed in kW, for flexible load unit f over decision step t (f in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadForecastExcess[isFLEX_LOADS][isDECISION_STEPS];
// violation of desire to keep first step's average active power the same as *it was initially for thermal gen g
// (g in THERMAL_GENS)
dvar float+ ThermalGenInitialPowerUpViolation[isTHERMAL_GENS];
dvar float+ ThermalGenInitialPowerDwnViolation[isTHERMAL_GENS];
// economic min active power violation for generator g over step t
// (g in THERMAL_GENS,t in DECISION_STEPS)
dvar float+ ThermalGenMinActivePowerDeficit[isTHERMAL_GENS][isDECISION_STEPS];
// active power raise reserve deficit to cover the loss of thermal generator g over step t 
// (g in THERMAL_GENS, t in DECISION_STEPS)
dvar float+ ThermalGenActivePowerRaiseReserveDeficit[isTHERMAL_GENS][isDECISION_STEPS];
// active power raise reserve deficit to cover the loss of inter prod asset p over step t 
// (p in INTER_PRODS, t in DECISION_STEPS)
dvar float+ InterProdActivePowerRaiseReserveDeficit[isINTER_PRODS][isDECISION_STEPS];
// active power raise reserve deficit to cover the loss of injection from storage asset s over step t 
// (s in STORAGES, t in DECISION_STEPS) 
dvar float+ StorActivePowerRaiseReserveDeficit[isSTORAGES][isDECISION_STEPS];
// active power raise reserve deficit to cover a sudden increase of consumption from non-flexible load asset n over step t 
// (n in NF_LOADS, t in DECISION_STEPS) 
dvar float+ NFLoadActivePowerRaiseReserveDeficit[isNF_LOADS][isDECISION_STEPS];
// active power lower reserve deficit to cover a sudden increase of generation from inter prod asset p over step t 
// (p in INTER_PRODS, t in DECISION_STEPS) 
dvar float+ InterProdActivePowerLowerReserveDeficit[isINTER_PRODS][isDECISION_STEPS];
// active power lower reserve deficit to cover the loss of consumption from storage asset s over step t 
// (s in STORAGES, t in DECISION_STEPS) 
dvar float+ StorActivePowerLowerReserveDeficit[isSTORAGES][isDECISION_STEPS];
// active power lower reserve deficit to cover sudden drop in consumption from flexible load asset f over step t 
// (f in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadActivePowerLowerReserveDeficit[isFLEX_LOADS][isDECISION_STEPS];
// active power lower reserve deficit to cover a sudden drop in consumption from non-flexible load asset n over step t 
// (n in NF_LOADS, t in DECISION_STEPS) 
dvar float+ NFLoadActivePowerLowerReserveDeficit[isNF_LOADS][isDECISION_STEPS];
// reactive power raise reserve deficit to cover the loss of thermal generator g over step t 
// (g in THERMAL_GENS, t in DECISION_STEPS)
dvar float+ ThermalGenReactivePowerRaiseReserveDeficit[isTHERMAL_GENS][isDECISION_STEPS];
// reactive power raise reserve deficit to cover the loss of inter prod asset p over step t 
// (p in INTER_PRODS, t in DECISION_STEPS)
dvar float+ InterProdReactivePowerRaiseReserveDeficit[isINTER_PRODS][isDECISION_STEPS];
// reactive power raise reserve deficit to cover the loss of injection from storage asset s over step t 
// (s in STORAGES, t in DECISION_STEPS) 
dvar float+ StorReactivePowerRaiseReserveDeficit[isSTORAGES][isDECISION_STEPS];
// reactive power raise reserve deficit to cover a sudden increase of consumption from non-flexible load asset n over step t 
// (n in NF_LOADS, t in DECISION_STEPS) 
dvar float+ NFLoadReactivePowerRaiseReserveDeficit[isNF_LOADS][isDECISION_STEPS];
// reactive power lower reserve deficit to cover a sudden increase of generation from inter prod asset p over step t 
// (p in INTER_PRODS, t in DECISION_STEPS) 
dvar float+ InterProdReactivePowerLowerReserveDeficit[isINTER_PRODS][isDECISION_STEPS];
// reactive power lower reserve deficit to cover the loss of consumption from storage asset s over step t 
// (s in STORAGES, t in DECISION_STEPS) 
dvar float+ StorReactivePowerLowerReserveDeficit[isSTORAGES][isDECISION_STEPS];
// reactive power lower reserve deficit to cover sudden drop in consumption from flexible load asset f over step t 
// (f in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadReactivePowerLowerReserveDeficit[isFLEX_LOADS][isDECISION_STEPS];
// reactive power lower reserve deficit to cover a sudden drop in consumption from non-flexible load asset n over step t 
// (n in NF_LOADS, t in DECISION_STEPS) 
dvar float+ NFLoadReactivePowerLowerReserveDeficit[isNF_LOADS][isDECISION_STEPS];
// spinning raise reserve deficit over step t 
// (t in DECISION_STEPS)
dvar float+ SpinningRaiseReserveDeficit[isDECISION_STEPS];
// spinning lower reserve deficit over step t 
// (t in DECISION_STEPS)
dvar float+ SpinningLowerReserveDeficit[isDECISION_STEPS];
// default current requirement deficit over step t
// (t in DECISION_STEPS)
dvar float+ DefaultCurrentRequirementDeficit[isDECISION_STEPS];
// violation of maximum time allowed to be continuously on by thermal gen g over step t
// (g in THERMAL_GEN, t in DECISION_STEPS)  
dvar float+ GenMaxStepOnInitialExcess[g in isTHERMAL_GENS][i in 0..(maxGenInitialStepsOnMax-1)];
dvar float+ GenMaxStepOnExcess[isTHERMAL_GENS][isDECISION_STEPS];
// violation of minimum time allowed to be continuously on by thermal gen g over step t
// (g in THERMAL_GEN, t in DECISION_STEPS)  
dvar float+ GenMinStepOnInitialDeficit[isTHERMAL_GENS];
dvar float+ GenMinStepOnDeficit[isTHERMAL_GENS][isDECISION_STEPS];
// violation of minimum time allowed to be off between 2 consecutive uses for thermal gen g over step t
// (g in THERMAL_GEN, t in DECISION_STEPS)  
dvar float+ GenMinStepOffInitialDeficit[isTHERMAL_GENS];
dvar float+ GenMinStepOffDeficit[isTHERMAL_GENS][isDECISION_STEPS];
// violation of AuthorizedCurt : interProd curtailment is done while battery are not fully charged
dvar float+ UnauthorizedInterProdCurt[isDECISION_STEPS];

// Expressions to model various costs
/////////////////////////////////////
// total cost from buying electricity from the maingrid over optimisation window
dexpr float ElectricityTotalTariffCosts = electricityTariff * sum(t in isDECISION_STEPS) ImportTarget[t] * stepDurationInHours[t];
// total net revenue  from trading electricity with maingrid over optimisation window
dexpr float ElectricityTotalNetRevenue = sum(t in isDECISION_STEPS) electricityPrice[t] * NetImportTarget[t] * stepDurationInHours[t];
// total variable costs for generation from thermal generators over optimisation window
dexpr float ThermalGenTotalVarCosts = sum(t in isDECISION_STEPS, g in isTHERMAL_GENS) ThermalGenVarCost[g][t] * stepDurationInHours[t];
// total starting costs from thermal generators over optimisation window
dexpr float ThermalGenTotalStartupCosts = sum(t in isDECISION_STEPS, g in isTHERMAL_GENS) ThermalGenStartup[g][t] * thermalGenStartupCost[g];
// total variable costs for generation from intermittent production assets over optimiation window
dexpr float InterProdTotalVarCosts = sum(t in isDECISION_STEPS, i in isINTER_PRODS) InterProdActivePower[i][t] * interProdVariableCost[i] * stepDurationInHours[t]; 
// total curtailment costs from intermittent production over optimisation window
dexpr float InterProdTotalCurtCosts = sum(t in isDECISION_STEPS, i in isINTER_PRODS) interProdCurtComp[i] * InterProdCurtEstimation[i][t] * stepDurationInHours[t];
// total late discharge cost over optimisation window
dexpr float StorChargeDischargeCost = (
	microgridName == "MICROGRID MORBIHAN ENERGIES FlexMobIle" || microgridName == "MICROGRID MORBIHAN ENERGIES Kergrid"	// for FlexMob'Ile and Kergrid, we want to encourage late charge (see storArtificialPenality param)
		? sum(t in isDECISION_STEPS, s in isSTORAGES)
			storArtificialPenality[t] * (StorACPowerCharge[s][t] + StorACPowerDischarge[s][t]) * stepDurationInHours[t]
 		: (
 			microgridName == "MICROGRID TPL Tongatapu"																	// for Tonga, we want to encourage early discharge sor Matatoa BESS only (see storArtificialPenality param)
 				? sum(t in isDECISION_STEPS, s in isSTORAGES inter {"Tongatapu_Matatoa_BESS"})
 					storArtificialPenality[t] * StorACPowerDischarge[s][t] * stepDurationInHours[t]
 				: sum(t in isDECISION_STEPS, s in isSTORAGES)															// for IDP and Mare, we want to encourage early discharge (see storArtificialPenality param)
 					storArtificialPenality[t] * StorACPowerDischarge[s][t] * stepDurationInHours[t]
 		) 
 	);

/*********************************************************************
 * Some labelled constraints
 *********************************************************************/
constraint ctSegUpBound[isTHERMAL_GENS][2..maxSegNbr][isDECISION_STEPS];
constraint ctSegLowBound[isTHERMAL_GENS][2..(maxSegNbr-1)][isDECISION_STEPS];
constraint ctSegTest[isTHERMAL_GENS][1..(maxSegNbr-1)][isDECISION_STEPS];
/*********************************************************************
 * Objective function
 *********************************************************************/
minimize
  	ElectricityTotalTariffCosts
  + ElectricityTotalNetRevenue
  + ThermalGenTotalVarCosts
  + ThermalGenTotalStartupCosts
  + InterProdTotalVarCosts
  + InterProdTotalCurtCosts
  + StorChargeDischargeCost
  + thermaGenInitialPowerViolPenalty * sum(g in isTHERMAL_GENS) (ThermalGenInitialPowerUpViolation[g] + ThermalGenInitialPowerDwnViolation[g]) * stepDurationInHours[first(isDECISION_STEPS)]
  + powerImbalancePenaltyCost * sum(t in isDECISION_STEPS) (PowerDeficit[t] + PowerExcess[t]) * stepDurationInHours[t]
  + unauthorizedInterProdCurtPenaltyCost * sum(t in isDECISION_STEPS) UnauthorizedInterProdCurt[t] * stepDurationInHours[t]
  + InterProdForecastExcessPenaltyCost * sum(i in isINTER_PRODS, t in isDECISION_STEPS) InterProdForecastExcess[i][t] * stepDurationInHours[t]
  + SOCminMaxViolationPenaltyCost * sum(s in isSTORAGES, t in isDECISION_STEPS) (maxCharge[s] * (SOCstrictMinDeficit[s][t] + SOCmaxExcess[s][t]) / 100.0)
  + SocTargetStorageDeficitViolation * sum(s in isSTORAGES, t in isDECISION_STEPS) (maxCharge[s] * (SocTargetStorageDeficit[s][t]) / 100.0)
  + SOCminViolationPenaltyCost * sum(s in isSTORAGES, t in isDECISION_STEPS) (maxCharge[s] * SOCminDeficit[s][t] / 100.0)
  + flexLoadForecastViolationPenaltyCost * sum(f in isFLEX_LOADS, t in isDECISION_STEPS) (FlexLoadForecastDeficit[f][t] + FlexLoadForecastExcess[f][t]) * stepDurationInHours[t]
  + siteInOutViolationPenaltyCost * sum(i in isSITES, t in isDECISION_STEPS) (SiteMaxInputViolation[i][t] + SiteMaxOutputViolation[i][t]) * stepDurationInHours[t]  
  + siteInOutViolationPenaltyCost * sum(c in isCONGESTIONS, t in isDECISION_STEPS) (CongestionUpperLimViolation[c][t] + CongestionLowerLimViolation[c][t]) * stepDurationInHours[t]  
  + genMaxStepOnPenaltyCost * sum(g in isTHERMAL_GENS, i in 0..(genInitialStepsOnMax[g]-1)) GenMaxStepOnInitialExcess[g][i] 
  + genMaxStepOnPenaltyCost * sum(g in isTHERMAL_GENS, t in isDECISION_STEPS) GenMaxStepOnExcess[g][t]
  + genMinStepOnPenaltyCost * sum(g in isTHERMAL_GENS) GenMinStepOnInitialDeficit[g] * stepDurationInHours[first(isDECISION_STEPS)]
  + genMinStepOnPenaltyCost * sum(g in isTHERMAL_GENS, t in isDECISION_STEPS) GenMinStepOnDeficit[g][t] * stepDurationInHours[t]
  + genMinStepOffPenaltyCost * sum(g in isTHERMAL_GENS) GenMinStepOffInitialDeficit[g] * stepDurationInHours[first(isDECISION_STEPS)]
  + genMinStepOffPenaltyCost * sum(g in isTHERMAL_GENS, t in isDECISION_STEPS) GenMinStepOffDeficit[g][t] * stepDurationInHours[t]
  + minThermalGenActivePowerDeficitPenalty * sum(g in isTHERMAL_GENS, t in isDECISION_STEPS) ThermalGenMinActivePowerDeficit[g][t] * stepDurationInHours[t]
  + activePowerRaiseReserveDeficitPenaltyCost * sum(g in isTHERMAL_GENS, t in isDECISION_STEPS) (ThermalGenActivePowerRaiseReserveDeficit[g][t] * stepDurationInHours[t])
  + activePowerRaiseReserveDeficitPenaltyCost * sum(p in isINTER_PRODS, t in isDECISION_STEPS) (InterProdActivePowerRaiseReserveDeficit[p][t] * stepDurationInHours[t])
  + activePowerRaiseReserveDeficitPenaltyCost * sum(s in isSTORAGES, t in isDECISION_STEPS) (StorActivePowerRaiseReserveDeficit[s][t] * stepDurationInHours[t])
  + activePowerRaiseReserveDeficitPenaltyCost * sum(n in isNF_LOADS, t in isDECISION_STEPS) (NFLoadActivePowerRaiseReserveDeficit[n][t] * stepDurationInHours[t])
  + activePowerLowerReserveDeficitPenaltyCost * sum(p in isINTER_PRODS, t in isDECISION_STEPS) (InterProdActivePowerLowerReserveDeficit[p][t] * stepDurationInHours[t])
  + activePowerLowerReserveDeficitPenaltyCost * sum(s in isSTORAGES, t in isDECISION_STEPS) (StorActivePowerLowerReserveDeficit[s][t] * stepDurationInHours[t])
  + activePowerLowerReserveDeficitPenaltyCost * sum(f in isFLEX_LOADS, t in isDECISION_STEPS) (FlexLoadActivePowerLowerReserveDeficit[f][t] * stepDurationInHours[t])
  + activePowerLowerReserveDeficitPenaltyCost * sum(n in isNF_LOADS, t in isDECISION_STEPS) (NFLoadActivePowerLowerReserveDeficit[n][t] * stepDurationInHours[t])
  + reactivePowerRaiseReserveDeficitPenaltyCost * sum(g in isTHERMAL_GENS, t in isDECISION_STEPS) (ThermalGenReactivePowerRaiseReserveDeficit[g][t] * stepDurationInHours[t])
  + reactivePowerRaiseReserveDeficitPenaltyCost * sum(p in isINTER_PRODS, t in isDECISION_STEPS) (InterProdReactivePowerRaiseReserveDeficit[p][t] * stepDurationInHours[t])
  + reactivePowerRaiseReserveDeficitPenaltyCost * sum(s in isSTORAGES, t in isDECISION_STEPS) (StorReactivePowerRaiseReserveDeficit[s][t] * stepDurationInHours[t])
  + reactivePowerRaiseReserveDeficitPenaltyCost * sum(n in isNF_LOADS, t in isDECISION_STEPS) (NFLoadReactivePowerRaiseReserveDeficit[n][t] * stepDurationInHours[t])
  + reactivePowerLowerReserveDeficitPenaltyCost * sum(p in isINTER_PRODS, t in isDECISION_STEPS) (InterProdReactivePowerLowerReserveDeficit[p][t] * stepDurationInHours[t])
  + reactivePowerLowerReserveDeficitPenaltyCost * sum(s in isSTORAGES, t in isDECISION_STEPS) (StorReactivePowerLowerReserveDeficit[s][t] * stepDurationInHours[t])
  + reactivePowerLowerReserveDeficitPenaltyCost * sum(f in isFLEX_LOADS, t in isDECISION_STEPS) (FlexLoadReactivePowerLowerReserveDeficit[f][t] * stepDurationInHours[t])
  + reactivePowerLowerReserveDeficitPenaltyCost * sum(n in isNF_LOADS, t in isDECISION_STEPS) (NFLoadReactivePowerLowerReserveDeficit[n][t] * stepDurationInHours[t])
  + spinnigRaiseReserveDeficitPenaltyCost * sum(t in isDECISION_STEPS) (SpinningRaiseReserveDeficit[t] * stepDurationInHours[t])
  + spinnigLowerReserveDeficitPenaltyCost * sum(t in isDECISION_STEPS) (SpinningLowerReserveDeficit[t] * stepDurationInHours[t])
  + defaultCurrentReqDeficitPenaltyCost * sum(t in isDECISION_STEPS) (DefaultCurrentRequirementDeficit[t] * stepDurationInHours[t]);
  
/*********************************************************************
 * Constraints
 *********************************************************************/
  subject to {
//	forall (t in isDECISION_STEPS, g in {"Tongatapu_Popua_GE2", "Tongatapu_Popua_GE3", "Tongatapu_Popua_GE4", "Tongatapu_Popua_GE5", "Tongatapu_Popua_GE6"}: ord(isDECISION_STEPS, t) <= 5)
//	  ctTest: sum(g in isTHERMAL_GENS) ThermalGenActivePower[g][t] >= 920; 
//	forall (t in isDECISION_STEPS: 31 <= ord(isDECISION_STEPS, t) <= 44)
//	  ctTest2: sum (g in isTHERMAL_GENS) ThermalGenActivePower[g][t] <= 0.0; 
//	forall (t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= 24)
//	  ctTest3: sum (s in isSTORAGES) StorACActivePower[s][t] == 0.0; 
//	forall (t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= 100)
	//ctTest1: ThermalGenActivePower["ENERCAL_IDP_GE_1_NC"]["4"] <= 0;
	//ctTest2: ThermalGenActivePower["ENERCAL_IDP_GE_1_NC"]["5"] <= 0;
//	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
//	  ctTest2: IsGenOn[g][t] <= 0;
/* POWER BALANCE */
// Power generated by intermittent production assets, injected by storage assets
// and imported from the main grid must balance with the power consumed by flexible
// and non-flexible load units on each decision step.
	forall (t in isDECISION_STEPS)
	  ctPowerBalance:
	  	  sum(p in isINTER_PRODS) InterProdActivePower[p][t]
	  	+ sum(g in isTHERMAL_GENS) ThermalGenActivePower[g][t] 
	  	+ sum(s in isSTORAGES) StorACActivePower[s][t]
	  	+ NetImportTarget[t] ==
	  	  sum(f in isFLEX_LOADS) FlexLoadActivePower[f][t]
	  	+ sum(n in isNF_LOADS) NFLoadActivePower[n][t]
	  	- PowerDeficit[t] + PowerExcess[t];
/* POWER IMPORTS */
// Power import flag equals 1 for decision steps when microgrid imports power from the main grid
// and 0 for decision steps when microgrid exports power out to the main grid
	forall (t in isDECISION_STEPS)
	  ctPowerIsExporting:
	  	NetImportTarget[t] >= -maxExportCapacity[t] * (1 - IsImporting[t]);
	forall (t in isDECISION_STEPS)
	  ctPowerIsImporting:
	  	NetImportTarget[t] <= maxImportCapacity[t] * IsImporting[t];
// Power imported at each decision step is NetImportTarget if microgrid is importing power over decision step
// or zero if microgrid is not importing power
	forall (t in isDECISION_STEPS)
	  ctPowerImportTargetDef1:
	  	NetImportTarget[t] <= ImportTarget[t];
	forall (t in isDECISION_STEPS)
	  ctPowerImportTargetDef2:
	  	ImportTarget[t] <= NetImportTarget[t] + maxExportCapacity[t] * (1 - IsImporting[t]);
	forall (t in isDECISION_STEPS)
	  ctPowerImportTargetDef3:
	  	ImportTarget[t] <= maxImportCapacity[t] * IsImporting[t];
/* THERMAL GENSETS POWER PRODUCTION */
// Power generation from an thermal production asset is limited by the maximum and the minimum power generation possible for that asset. 
	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctThermalGenEcoMinPower:
	  	ThermalGenActivePower[g][t] >= minThermalGenActivePower[g] * IsGenOn[g][t] - ThermalGenMinActivePowerDeficit[g][t];
	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctThermalGenPhysMinPower:
	  	minThermalGenActivePower[g] * IsGenOn[g][t] - ThermalGenMinActivePowerDeficit[g][t] >= physMinThermalGenActivePower[g] * IsGenOn[g][t];
	forall(g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctThermalGenMaxPower:  	
	  	ThermalGenActivePower[g][t] <= maxThermalGenActivePower[g] * IsGenOn[g][t];
	  	
// Thermal gen cannot be on if maximum power generation is zero for this gen
	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctThermalGenZeroMaxGen:
	  	IsGenOn[g][t] <= (maxThermalGenActivePower[g] > 0.0 ? 1 : 0);
	  	
// Piecewise Variable Cost Model 
// Segment Upper bounds
// first segment: if first segment is used, power on first segment must be lower than first segment's upper limit  
	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctSegUpBound1:  	
	  	GenVarCostSegPower[g][1][t] <= GenVarCostSegFlag[g][1][t] * varCostSegUpLim[genVarCostModelId[g]][1];

// other segments: if segment s is used, power on s must be lower than the difference between s's upper limit and s-1's upper limit
	forall (g in isTHERMAL_GENS, s in 2..varCostModelSegNumber[genVarCostModelId[g]], t in isDECISION_STEPS)
	  ctSegUpBound[g][s][t]:  	
	  	GenVarCostSegPower[g][s][t] <= GenVarCostSegFlag[g][s][t] * (varCostSegUpLim[genVarCostModelId[g]][s] - varCostSegUpLim[genVarCostModelId[g]][s-1]);

// Segment Lower bounds
// first segment: if second segment 2 is used, first segment must be completely used and so power on first segment must be equal to first segment's upper bound. 
	forall (g in isTHERMAL_GENS: varCostModelSegNumber[genVarCostModelId[g]] >= 2, t in isDECISION_STEPS)
	  ctSegLowBound1:  	
	  	GenVarCostSegPower[g][1][t] >= GenVarCostSegFlag[g][2][t] * varCostSegUpLim[genVarCostModelId[g]][1];
	  	
// other segments:  if segment s+1 is used, segment s must be completely used and so power on s must be equal to the difference between s's upper bound and s-1's upper bound
	forall (g in isTHERMAL_GENS, s in 2..(varCostModelSegNumber[genVarCostModelId[g]]-1), t in isDECISION_STEPS)
	  ctSegLowBound[g][s][t]:  	
	  	GenVarCostSegPower[g][s][t] >= GenVarCostSegFlag[g][s+1][t] * (varCostSegUpLim[genVarCostModelId[g]][s] - varCostSegUpLim[genVarCostModelId[g]][s-1]);
// COST-SEG-CHANGE
//// Definition of the piecewise linear variable cost segment change indicator
//// Case when number of used segments goes up from step t-1 to step t	  	
//	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS diff {first(isDECISION_STEPS)})
//	  ctSegChangeUp:
//	  	GenVarCostSegNbr[g][t] - GenVarCostSegNbr[g][prev(isDECISION_STEPS, t)] <= varCostModelSegNumber[genVarCostModelId[g]] * GenVarCostSegChange[g][t];
//// Case when number of used segments goes down from step t-1 to step t	  	
//	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS diff {first(isDECISION_STEPS)})
//	  ctSegChangeDown:
//	  	GenVarCostSegNbr[g][prev(isDECISION_STEPS, t)] - GenVarCostSegNbr[g][t] <= varCostModelSegNumber[genVarCostModelId[g]] * GenVarCostSegChange[g][t];
// average power generation (expressed in kW) for thermal generator g over decision step t is sum of segment power over all segments
// (g in THERMAL_GENS,t in DECISION_STEPS)
	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctSegPowerSum:
	  	ThermalGenActivePower[g][t] == sum (s in 1..varCostModelSegNumber[genVarCostModelId[g]]) GenVarCostSegPower[g][s][t];

// generation variable cost for thermal generator g  over step t is sum of segment power times segment cost over all segments 
// (g in THERMAL_GENS,t in DECISION_STEPS)
	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctSegCostSum:
	  	ThermalGenVarCost[g][t] == sum (s in 1..varCostModelSegNumber[genVarCostModelId[g]]) varCostSegCost[genVarCostModelId[g]][s] * GenVarCostSegPower[g][s][t];


// if possible, keep first step's average power generation for thermal generator g the same as it was initially
// (g in THERMAL_GENS)
	forall (g in isTHERMAL_GENS: genInitialState[g] >= 1)
	  ctThermalGenPowerUp:
	  	genInitialPower[g] - ThermalGenActivePower[g][first(isDECISION_STEPS)] >= -ThermalGenInitialPowerUpViolation[g];
	forall (g in isTHERMAL_GENS: genInitialState[g] >= 1)
	  ctThermalGenPowerDwn:
	  	genInitialPower[g] - ThermalGenActivePower[g][first(isDECISION_STEPS)] <= ThermalGenInitialPowerDwnViolation[g];


// Start up and shut down model 
// Indicator giving evolution of each generator's status between decision step t and the previous one. 
// -1 means g is shut down at t, 0 means g stays on or stays off, and +1 means g is started.

// first steps
	forall (g in isTHERMAL_GENS)
	  ctGenEvol1 :
	  	GenOnEvol[g][first(isDECISION_STEPS)] - IsGenOn[g][first(isDECISION_STEPS)] == -genInitialState[g];

// other steps	  	
  	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS diff {first(isDECISION_STEPS)})
  	  ctGenEvol :
	  	GenOnEvol[g][t] == IsGenOn[g][t] - IsGenOn[g][prev(isDECISION_STEPS, t)];

// Thermal generator g is started up if its status evolution is +1 (1 at t and 0 at t-1)
// Note that, as ThermalGenStartup has a cost, it should not be set to 1 unless GenOnEvol equals 1
	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctGenOnEvol :
	  	GenOnEvol[g][t] <= ThermalGenStartup[g][t];
	  	
// Maximum number of steps each genset can be continuously on
// initial steps
	forall (g in isTHERMAL_GENS: genInitialState[g] > 0, i in rgInitialStepOffset: i <= genInitialStepsOnMax[g])
	  ctMaxStepsOn0:
	  	sum (j in i..(genInitialStepsOnMax[g]-1)) 1 +
	  	sum (t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= genMaxStepsOn[g] - genInitialStepsOnMax[g] + i) IsGenOn[g][t]
	  	<= genMaxStepsOn[g] + GenMaxStepOnInitialExcess[g][i];
	  	
// other steps
	forall (g in isTHERMAL_GENS: genMaxStepsOn[g] > 0, t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= card(isDECISION_STEPS) - genMaxStepsOn[g] - 1)
	  ctMaxStepsOn:
	  	sum (tt in isDECISION_STEPS: ord(isDECISION_STEPS, t) <=  ord(isDECISION_STEPS, tt) <= ord(isDECISION_STEPS, t) + genMaxStepsOn[g])
	  		IsGenOn[g][tt] <= genMaxStepsOn[g] + GenMaxStepOnExcess[g][t];
	  	
// Minimum number of steps each genset must be continuously on
// initial steps
	forall (g in isTHERMAL_GENS: genInitialState[g] > 0 && genMinStepsOn[g] > 0 && genInitialStepsOnMin[g] < genMinStepsOn[g])
	  ctMinStepsOn0:
	  	genInitialStepsOnMin[g] +
	  	sum (t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= genMinStepsOn[g] - genInitialStepsOnMin[g] - 1) IsGenOn[g][t]
	  	>= genMinStepsOn[g] - GenMinStepOnInitialDeficit[g];
// other steps
	forall (g in isTHERMAL_GENS: genMinStepsOn[g] > 0, t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= card(isDECISION_STEPS) - genMinStepsOn[g])
	  ctMinStepsOn:
	  	sum (tt in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= ord(isDECISION_STEPS, tt) <= ord(isDECISION_STEPS, t) + genMinStepsOn[g] - 1)
	  		IsGenOn[g][tt] >= genMinStepsOn[g] * GenOnEvol[g][t] - GenMinStepOnDeficit[g][t];

// Minimum number of steps each genset must be off between 2 consecutive uses
// initial steps
	forall (g in isTHERMAL_GENS: genInitialState[g] <= 0 && 0 < genMinRecoverySteps[g])
	  ctMinStepsOff0:
	  	sum (t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= genMinRecoverySteps[g] - genInitialStepsOff[g] - 1) IsGenOn[g][t]
	  	<= GenMinStepOffInitialDeficit[g];
// other steps
	forall (g in isTHERMAL_GENS: genMinRecoverySteps[g] > 0, t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= card(isDECISION_STEPS) - genMinRecoverySteps[g])
	  ctMinStepsOff:
	  	sum (tt in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= ord(isDECISION_STEPS, tt) <= ord(isDECISION_STEPS, t) + genMinRecoverySteps[g] - 1)
	  		IsGenOn[g][tt] <= genMinRecoverySteps[g] * (1 + GenOnEvol[g][t]) + GenMinStepOffDeficit[g][t];

//// Maximum reactive power for thermal gen g over step t is linear function of g's active power target over t
//// modelled as dexpr//	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
//	  ctThermalGenMaxReactivePower:
//	  	ThermalGenMaxReactivePower[g][t] == aQmax[g] * ThermalGenActivePower[g][t] + IsGenOn[g][t] * bQmax[g];
	  	
// Reactive power for thermal gen g over step t is limited by g's max recative power at t
	forall (g in isTHERMAL_GENS, t in isDECISION_STEPS)
	  ctThermalGenReactivePower:
	  	ThermalGenReactivePower[g][t] <= ThermalGenMaxReactivePower[g][t]; 

// For thermal gen g operating in grid-forming or grid-following mode, spinning raise reserve over step t
// is limited by the difference between g's max active power and g's active power target over t 
	forall (g in isTHERMAL_GENS inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctThermalGenMaxSpinRaiseReserve:
	  	ThermalGenSpinRaiseReserve[g][t] <= maxThermalGenActivePower[g] - ThermalGenActivePower[g][t];
// For thermal gen g operating in grid-tied mode, spinning raise reserve  over step t is zero
	forall (g in isTHERMAL_GENS inter isGRID_TIED, t in isDECISION_STEPS)
	  ctThermalGenMaxSpinRaiseReserve0:
	  	ThermalGenSpinRaiseReserve[g][t] <= 0.0;
	  	
// If thermal gen g is operating in grid-following mode, it can only provide spinning raise reserve if at least one other asset is operating in grid-forming mode
	forall (g in isTHERMAL_GENS inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLThermalGenMaxSpinRaiseReserve:
	  	ThermalGenSpinRaiseReserve[g][t] <= maxThermalGenActivePower[g] *
	  		(
			 sum (g1 in isTHERMAL_GENS inter isGRID_FORM) IsGenOn[g1][t] +
	  		 sum (s in isSTORAGES inter isGRID_FORM: (maxStorACActivePowerDischarge[s] + maxStorACActivePowerCharge[s] > 0.0) && storAvail[s][t] > 0.0) 1 +
			 sum (f in isFLEX_LOADS inter isGRID_FORM: maxFlexLoad[f] > 0.0 && flexLoadAvail[f][t] > 0.0) 1
			 );

// For thermal gen g operating in grid-forming or grid-following mode, spinning lower reserve over step t
// is limited by s's active power target over t 
	forall (g in isTHERMAL_GENS inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctThermalGenMaxSpinLowerReserve:
	  	ThermalGenSpinLowerReserve[g][t] <= ThermalGenActivePower[g][t];
// For thermal gen g operating in grid-tied mode, spinning lower reserve  over step t is zero
	forall (g in isTHERMAL_GENS inter isGRID_TIED, t in isDECISION_STEPS)
	  ctThermalGenMaxSpinLowerReserve0:
	  	ThermalGenSpinLowerReserve[g][t] <= 0.0;
	  	
// If thermal gen g is operating in grid-following mode, it can only provide spinning lower reserve if at least one other asset is operating in grid-forming mode
	forall (g in isTHERMAL_GENS inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLThermalGenMaxSpinLowerReserve:
	  	ThermalGenSpinLowerReserve[g][t] <= maxThermalGenActivePower[g] *
	  		(
			 sum (g1 in isTHERMAL_GENS inter isGRID_FORM) IsGenOn[g1][t] +
	  		 sum (s in isSTORAGES inter isGRID_FORM: (maxStorACActivePowerDischarge[s] + maxStorACActivePowerCharge[s] > 0.0) && storAvail[s][t] > 0.0) 1 +
			 sum (f in isFLEX_LOADS inter isGRID_FORM: maxFlexLoad[f] > 0.0 && flexLoadAvail[f][t] > 0.0) 1
			 );

/* INTERMITTENT POWER PRODUCTION */
// Power generation from an intermittent production asset is limited by the maximum and the minimum power generation possible for that asset
	forall (i in isINTER_PRODS, t in isDECISION_STEPS)
	  ctInterProdMinMax: minInterProdActivePower[i] <= InterProdActivePower[i][t] <= maxInterProdActivePower[i];

// Power generation from an intermittent production asset is limited to the maximum generation potential forecast for that asset
	forall (i in isINTER_PRODS, t in isDECISION_STEPS)
	  ctPotentialInterProd: InterProdActivePower[i][t] <= interProdActivePowerForecast[i][t] + InterProdForecastExcess[i][t];
	  
//// Power curtailment for an intermittent production asset is the difference between its power generation and its maximum generation forecast
// => modelled as a dexpr to speed up optimisation
//	forall (i in isINTER_PRODS, t in isDECISION_STEPS)
//	  ctInterProdCurt:
//	  	InterProdPowerCurtailment[i][t] == interProdActivePowerForecast[i][t] - InterProdActivePower[i][t];
	  	
// If an intermittent production asset is not curtailed, its power curtailment must be zero (only required with curtailment estimation based on installed peak capacity)
	forall (i in isINTER_PRODS, t in isDECISION_STEPS)
	  ctInterProdCurtFlagDef:
	  	InterProdPowerCurtailment[i][t] <= (
	  		interProdCurtEstimationMethod[i] == "DEFAULT_BASED"
	  			? InterProdIsCurtailed[i][t] * interProdActivePowerForecast[i][t]
	  			: interProdActivePowerForecast[i][t]);

//// For intermittent production curtailment estimation mode 1, the estimation of curtailed power is the difference
//// between installed maximum power and activer power target  
// => modelled as a dexpr to speed up optimisation
//	forall (i in isINTER_PRODS, t in isDECISION_STEPS)
//	  ctInterProdPenCurtDef:
//	  	InterProdCurtEstimation[i][t] == InterProdPowerCurtailment[i][t] + InterProdIsCurtailed[i][t] * (maxInterProdActivePower[i] - interProdActivePowerForecast[i][t]);

// If batteries are not fully charged, InterProduction cannot be curtailed.
// card(isSTORAGES)*max(s in isSTORAGES) maxCharge[s] -> big M
// card(isINTER_PRODS)*max(i in isINTER_PRODS) maxInterProdActivePower[i]  -> big M 																		   							
if (lastMinuteCurtOption == 1 && card(isINTER_PRODS) > 0 && card(isSTORAGES) > 0) { 
		forall (t in isDECISION_STEPS)
	  		ctAuthorizedCurt1 : sum(s in isSTORAGES : maxStorACActivePowerCharge[s] > 0)(maxCharge[s] * maxSOC[s] / 100 - StorStoredDCEnergy[s][t]) 
	  			<= 0.01 + card(isSTORAGES) * max(s in isSTORAGES) maxCharge[s] * (1 - AreAllStoragesFull[t]);
		forall (t in isDECISION_STEPS)
	  		ctAuthorizedCurt2 : sum(i in isINTER_PRODS) InterProdPowerCurtailment[i][t]
	  			<= card(isINTER_PRODS) * max(i in isINTER_PRODS) maxInterProdActivePower[i] * AreAllStoragesFull[t] + UnauthorizedInterProdCurt[t];   																		   							   
	}
//// Maximum reactive power for intermittent production asset p over step t is linear function of p's active power target over t
//// modelled as dexpr
//	forall (p in isINTER_PRODS, t in isDECISION_STEPS)
//	  ctInterProdMaxReactivePower:
//	  	InterProdMaxReactivePower[p][t] == aQmax[p] * InterProdActivePower[p][t] + bQmax[p];
// Reactive power for intermittent production asset p over step t is limited by p's max recative power at t
	forall (p in isINTER_PRODS, t in isDECISION_STEPS)
	  ctInterProdReactivePower:
	  	InterProdReactivePower[p][t] <= InterProdMaxReactivePower[p][t]; 

 /* STORAGE POWER INJECTION */
// HARD-CODED
// For Tonga, we force BESS to operate in the same direction (charge or discharge, not both)
//	if (microgridName == "MICROGRID TPL Tongatapu")
//		forall (s in isSTORAGES: s != first(isSTORAGES), t in isDECISION_STEPS)
// 	  		ctStorageSameDirection: IsCharging[s][t] == IsCharging[first(isSTORAGES)][t];
 	  	
// Power consumption by a storage asset in charge is limited by its maximum charge rate
	forall (s in isSTORAGES, t in isDECISION_STEPS)
	  ctStorageChargeMax: StorACPowerCharge[s][t] <= maxStorACActivePowerCharge[s] * IsCharging[s][t];

// HARD-CODED
// For one specific charging station on Kergrid microgrid, power consumption by a storage asset in charge is limited by its minimum charge rate
	if (microgridName == "MICROGRID MORBIHAN ENERGIES Kergrid") {
		forall (s in isSTORAGES inter {"MORB_ENERGIES_Kergrid_V1G_C1", "MORB_ENERGIES_Kergrid_V1G_C2"}, t in isDECISION_STEPS)
		  ctStorageChargeMin: StorACPowerCharge[s][t] >= 9 * IsCharging[s][t];
  }		  

// Power injection by a storage asset in discharge is limited by its maximum discharge rate
	forall (s in isSTORAGES, t in isDECISION_STEPS)
	  ctStorageDischargeMax: StorACPowerDischarge[s][t] <= maxStorACActivePowerDischarge[s] * (1 - IsCharging[s][t]);

// Incremental charge / discharge definition
	forall (s in isSTORAGES: dischargeEfficiency[s] > 0, t in isDECISION_STEPS)
	  ctStorageIncrCharge: StorStepDCEnergyIn[s][t] == (chargeEfficiency[s] / 100) * StorACPowerCharge[s][t] * stepDurationInHours[t]
	  - (100 / dischargeEfficiency[s]) * StorACPowerDischarge[s][t] * stepDurationInHours[t];
	forall (s in isSTORAGES: dischargeEfficiency[s] <= 0, t in isDECISION_STEPS)
	  ctStorageIncrCharge0: StorStepDCEnergyIn[s][t] ==  (chargeEfficiency[s] / 100) * StorACPowerCharge[s][t] * stepDurationInHours[t];
	  
// Energy stored at end of step 1
	forall (s in isSTORAGES)
	  ctStorageStoredEnergy1: StorStoredDCEnergy[s][first(isDECISION_STEPS)] == initialCharge[s] + StorStepDCEnergyIn[s][first(isDECISION_STEPS)];
	  
// Energy stored at end of other steps
	forall (s in isSTORAGES, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
	  ctStorageStoredEnergy: StorStoredDCEnergy[s][t] == StorStoredDCEnergy[s][prev(isDECISION_STEPS, t)] + StorStepDCEnergyIn[s][t];

// Physical capacity constraints for each storage units
	 forall (s in isSTORAGES, t in isDECISION_STEPS)
	   ctPhysCapacity: StorStoredDCEnergy[s][t] <= maxCharge[s];
	   
// Minimum SOC
 	forall (s in isSTORAGES: maxCharge[s] > 0, t in isDECISION_STEPS)
 	  ctStorageMinSOC: minSOC[s] - SOCminDeficit[s][t] - SOCstrictMinDeficit[s][t] <= 100 * StorStoredDCEnergy[s][t] / maxCharge[s];
	   
// Strict minimum SOC
 	forall (s in isSTORAGES: maxCharge[s] > 0, t in isDECISION_STEPS)
 	  ctStorageStrictMinSOC: strictMinSOC[s] - SOCstrictMinDeficit[s][t] <= 100 * StorStoredDCEnergy[s][t] / maxCharge[s];
 	  
// Maximum SOC
 	forall (s in isSTORAGES: maxCharge[s] > 0, t in isDECISION_STEPS)
 	  ctStorageMaxSOC: 100 * StorStoredDCEnergy[s][t] / maxCharge[s] <= maxSOC[s] + SOCmaxExcess[s][t];

// final SOC
	forall (s in isSTORAGES: maxCharge[s] > 0.0)
	  ctStorageFinalSOC: 100 * StorStoredDCEnergy[s][last(isDECISION_STEPS)] / maxCharge[s] >= finalSOCLowerBound[s];
	  
// Target SOC
    if (card(isSTORAGES)> 0)
    {
    	forall (t in isDECISION_STEPS, s in isSTORAGES: maxCharge[s] > 0.0)
    	{
    		if (socTargetStorage[s][t] !=-1.0 && storAvail[s][t] == 1) 
    		{
    		ctStorageTargetSoc: 100 * StorStoredDCEnergy[s][t] / maxCharge[s] >= socTargetStorage[s][t]- SocTargetStorageDeficit[s][t];
    		}
    	}
    }

// Reactive power discharge for storage asset s over step t is limited by s's max recative discharge at t
	forall (s in isSTORAGES, t in isDECISION_STEPS)
	  ctStorageMaxReactivePowerOnDischarge:
	  	StorReactivePowerDischarge[s][t] <= StorMaxReactivePowerOnDischarge[s][t]; 
	forall (s in isSTORAGES, t in isDECISION_STEPS)
	  ctStorageMaxReactivePowerOnCharge:
	  	StorReactivePowerDischarge[s][t] <= StorMaxReactivePowerOnCharge[s][t]; 


// Reactive power charge for storage asset s over step t is limited by s's max recative charge at t
	forall (s in isSTORAGES, t in isDECISION_STEPS)
	  ctStorageMinReactiveOnDisharge:
	  	StorReactivePowerCharge[s][t] <= StorMinReactivePowerOnDischarge[s][t]; 
	forall (s in isSTORAGES, t in isDECISION_STEPS)
	  ctStorageMinReactiveOnCharge:
	  	StorReactivePowerCharge[s][t] <= StorMinReactivePowerOnCharge[s][t]; 

// For storage asset s operating in grid-forming or grid-following mode, spinning raise reserve over step t
// is limited by the difference between s's max active discharge and s's AC power target over t 
	forall (s in isSTORAGES inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctStorageMaxSpinRaiseReserve:
	  	StorSpinRaiseReserve[s][t] <= maxStorACActivePowerDischarge[s] - StorACActivePower[s][t];
// For storage asset s operating in grid-tied mode, spinning raise reserve  over step t is zero
	forall (s in isSTORAGES inter isGRID_TIED, t in isDECISION_STEPS)
	  ctStorageMaxSpinRaiseReserve0:
	  	StorSpinRaiseReserve[s][t] <= 0.0;
	  	
// If storage unit s is operating in grid-following mode, it can only provide spinning raise reserve if at least one other asset is operating in grid-forming mode
	forall (s in isSTORAGES inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLStorageMaxSpinRaiseReserve:
	  	StorSpinRaiseReserve[s][t] <= (maxStorACActivePowerDischarge[s] + maxStorACActivePowerCharge[s]) *
	  		(
			 sum (g in isTHERMAL_GENS inter isGRID_FORM) IsGenOn[g][t] +
	  		 sum (s1 in isSTORAGES inter isGRID_FORM: (maxStorACActivePowerDischarge[s1] + maxStorACActivePowerCharge[s1]) > 0.0 && storAvail[s1][t] > 0.0) 1 +
			 sum (f in isFLEX_LOADS inter isGRID_FORM: maxFlexLoad[f] > 0.0 && flexLoadAvail[f][t] > 0.0) 1
			 );

// For storage asset s operating in grid-forming or grid-following mode, spinning lower reserve over step t
// is limited by the sum of s's max active charge and s's AC power target over t 
	forall (s in isSTORAGES inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctStorageMaxSpinLowerReserve:
	  	StorSpinLowerReserve[s][t] <= maxStorACActivePowerCharge[s] + StorACActivePower[s][t];

// For storage asset s operating in grid-tied mode, spinning lower reserve  over step t is zero
	forall (s in isSTORAGES inter isGRID_TIED, t in isDECISION_STEPS)
	  ctStorageMaxSpinLowerReserve0:
	  	StorSpinLowerReserve[s][t] <= 0.0;
	  	
// If storage unit s is operating in grid-following mode, it can only provide spinning lower reserve if at least one other asset is operating in grid-forming mode
	forall (s in isSTORAGES inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLStorageMaxSpinLowerReserve:
	  	StorSpinLowerReserve[s][t] <= (maxStorACActivePowerDischarge[s] + maxStorACActivePowerCharge[s]) *
	  		(
			 sum (g in isTHERMAL_GENS inter isGRID_FORM) IsGenOn[g][t] +
	  		 sum (s1 in isSTORAGES inter isGRID_FORM: (maxStorACActivePowerDischarge[s1] + maxStorACActivePowerCharge[s1]) > 0.0 && storAvail[s1][t] > 0.0 ) 1 +
			 sum (f in isFLEX_LOADS inter isGRID_FORM: maxFlexLoad[f] > 0.0 && flexLoadAvail[f][t] > 0.0) 1
			 );

/* NON-FLEXIBLE LOAD UNITS */
// Maximum consumption
// Modelled as an dexpression

/* FLEXIBLE LOAD UNITS */
// Maximum and minimum consumption
 	forall (f in isFLEX_LOADS, t in isDECISION_STEPS)
 	  ctFlexLoadMinmaxFlexLoad: minFlexLoad[f] <= FlexLoadActivePower[f][t] <= maxFlexLoad[f];

// Modulation definition
 	forall (f in isFLEX_LOADS, t in isDECISION_STEPS)
 	  ctFlexLoadModulation: FlexLoadActivePower[f][t] == flexLoadForecast[f][t] + ModulationTarget[f][t]
 	  + FlexLoadForecastDeficit[f][t] - FlexLoadForecastExcess[f][t];

// Modulation constraints
 	forall (f in isFLEX_LOADS, t in isDECISION_STEPS)
 	  ctFlexLoadModConstraints: ModulationTarget[f][t] == 0.0;

//// Maximum reactive power for flexible load unit f over step t is linear function of f's active power target over t
//// modelled as dexpr
//	forall (f in isFLEX_LOADS, t in isDECISION_STEPS)
//	  ctFlexLoadMaxReactivePower:
//	  	FlexLoadMaxReactivePower[f][t] == aQmax[f] * FlexLoadActivePower[f][t] + bQmax[f];
// Reactive power for flexible load unit f over step t is limited by p's max recative power at t
	forall (f in isFLEX_LOADS, t in isDECISION_STEPS)
	  ctFlexLoadReactivePower:
	  	FlexLoadReactivePower[f][t] <= FlexLoadMaxReactivePower[f][t];

// For flexible elec load f operating in grid-forming or grid-following mode, spinning raise reserve over step t
// is limited by the difference between f's AC power target over t and f's min active power  
	forall (f in isFLEX_LOADS inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctFlexLoadMaxSpinRaiseReserve:
	  	FlexLoadSpinRaiseReserve[f][t] <= (flexLoadAvail[f][t] == 1 ? FlexLoadActivePower[f][t] - minFlexLoad[f] : 0.0);
// For flexible elec load f operating in grid-tied mode, spinning raise reserve over step t is zero
	forall (f in isFLEX_LOADS inter isGRID_TIED, t in isDECISION_STEPS)
	  ctFlexLoadMaxSpinRaiseReserve0:
	  	FlexLoadSpinRaiseReserve[f][t] <= 0.0;
// // If flexible elec load f is operating in grid-following mode, it can only provide spinning raise reserve if at least one other asset is operating in grid-forming mode
	forall (f in isFLEX_LOADS inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLFlexLoadMaxSpinRaiseReserve:
	  	FlexLoadSpinRaiseReserve[f][t] <= (maxFlexLoad[f] + minFlexLoad[f]) *
	  		( sum (d in isTHERMAL_GENS inter isGRID_FORM) IsGenOn[d][t]
	  		+ sum (s in isSTORAGES inter isGRID_FORM: (maxStorACActivePowerDischarge[s] + maxStorACActivePowerCharge[s]) > 0.0 && storAvail[s][t] > 0.0) 1
	  		+ sum (f1 in isFLEX_LOADS inter isGRID_FORM: maxFlexLoad[f1] > 0.0 && flexLoadAvail[f1][t] > 0.0) 1
	  		);

// For flexible elec load f operating in grid-forming or grid-following mode, spinning lower reserve over step t
// is limited by the difference between f's max active power and f's AC power target over t 
	forall (f in isFLEX_LOADS inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctFlexLoadMaxSpinLowerReserve:
	  	FlexLoadSpinLowerReserve[f][t] <= (flexLoadAvail[f][t] == 1 ? maxFlexLoad[f] - FlexLoadActivePower[f][t] : 0.0);
// For flexible elec load f operating in grid-tied mode, spinning lower reserve  over step t is zero
	forall (f in isFLEX_LOADS inter isGRID_TIED, t in isDECISION_STEPS)
	  ctFlexLoadMaxSpinLowerReserve0:
	  	FlexLoadSpinLowerReserve[f][t] <= 0.0;
	  	
// If flexible elec load f is operating in grid-following mode, it can only provide spinning lower reserve if at least one other asset is operating in grid-forming mode
	forall (f in isFLEX_LOADS inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLFlexLoadMaxSpinLowerReserve:
	  	FlexLoadSpinLowerReserve[f][t] <= (maxFlexLoad[f] + minFlexLoad[f]) *
	  		( sum (d in isTHERMAL_GENS inter isGRID_FORM) IsGenOn[d][t]
	  		+ sum (s in isSTORAGES inter isGRID_FORM: (maxStorACActivePowerDischarge[s] + maxStorACActivePowerCharge[s]) > 0.0 && storAvail[s][t] > 0.0 ) 1
	  		+ sum (f1 in isFLEX_LOADS inter isGRID_FORM: maxFlexLoad[f1] > 0.0 && flexLoadAvail[f1][t] > 0.0) 1
	  		);
//	forall (s in isSTORAGES inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
//	  ctStorageMaxSpinRaiseReserve:
//	  	StorSpinRaiseReserve[s][t] <= maxStorACActivePowerDischarge[s] - StorACActivePower[s][t];
//// For flexible load asset f operating in grid-tied mode, spinning raise reserve over step t is zero
//	forall (s in isSTORAGES inter isGRID_TIED, t in isDECISION_STEPS)
//	  ctStorageMaxSpinRaiseReserve0:
//	  	StorSpinRaiseReserve[s][t] <= 0.0;
//	  	
//// active power raise reserve (expressed in kW) from flexible load unit f over decision step t
//// (f in FLEX_LOADS, t in DECISION_STEPS)
//dexpr float FlexLoadActiveRaiseReserve[f in isFLEX_LOADS][t in isDECISION_STEPS] = FlexLoadActivePower[f][t] - minFlexLoad[f];
//// active power lower reserve (expressed in kW) from flexible load unit f over decision step t
//// (f in FLEX_LOADS, t in DECISION_STEPS)
//dexpr float FlexLoadActiveLowerReserve[f in isFLEX_LOADS][t in isDECISION_STEPS] = maxFlexLoad[f] - FlexLoadActivePower[f][t];
//
//// If For flexible load asset f is operating in grid-following mode, it can only provide spinning raise reserve if at least one other asset is operating in grid-forming mode
//	forall (s in isSTORAGES inter isGRID_FOLL, t in isDECISION_STEPS)
//	  ctGFLStorageMaxSpinRaiseReserve:
//	  	StorSpinRaiseReserve[s][t] <= (maxStorACActivePowerDischarge[s] + maxStorACActivePowerCharge[s]) *
//	  		(sum (g in isTHERMAL_GENS inter isGRID_FORM) IsGenOn[g][t] +
//	  		 sum (s1 in isSTORAGES inter isGRID_FORM: maxStorACActivePowerDischarge[s1] + maxStorACActivePowerCharge[s1] > 0.0) 1);
//
//// For storage asset s operating in grid-forming or grid-following mode, spinning lower reserve over step t
//// is limited by the sum of s's max active charge and s's AC power target over t 
//	forall (s in isSTORAGES inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
//	  ctStorageMaxSpinLowerReserve:
//	  	StorSpinLowerReserve[s][t] <= maxStorACActivePowerCharge[s] + StorACActivePower[s][t];
//
//// For storage asset s operating in grid-tied mode, spinning lower reserve  over step t is zero
//	forall (s in isSTORAGES inter isGRID_TIED, t in isDECISION_STEPS)
//	  ctStorageMaxSpinLowerReserve0:
//	  	StorSpinLowerReserve[s][t] <= 0.0;
//	  	
//// If storage unit s is operating in grid-following mode, it can only provide spinning lower reserve if at least one other asset is operating in grid-forming mode
//	forall (s in isSTORAGES inter isGRID_FOLL, t in isDECISION_STEPS)
//	  ctGFLStorageMaxSpinLowerReserve:
//	  	StorSpinLowerReserve[s][t] <= (maxStorACActivePowerDischarge[s] + maxStorACActivePowerCharge[s]) *
//	  		(sum (g in isTHERMAL_GENS inter isGRID_FORM) IsGenOn[g][t] +
//	  		 sum (s1 in isSTORAGES inter isGRID_FORM: maxStorACActivePowerDischarge[s1] + maxStorACActivePowerCharge[s1] > 0.0) 1);

/* Active Power reserve */
// RAISE RESRVE
// Reserve should cover loss of termal generator with largest generation
	forall (g1 in isTHERMAL_GENS: activePowerLossPct[g1] > 0, t in isDECISION_STEPS)
	  ctActivePowerRaiseReserveThermalGen :
	  	(100.0 - activePowerLossPct[g1]) / 100 * ThermalGenActiveRaiseReserve[g1][t]	// reserve from what is left of g1
	  +	sum (g in isTHERMAL_GENS diff({g1})) ThermalGenActiveRaiseReserve[g][t]			// reserve from other thermal gens
	  + sum (s in isSTORAGES) StorActiveRaiseReserve[s][t]	  							// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadActiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  activePowerLossPct[g1] / 100 * ThermalGenActivePower[g1][t] - ThermalGenActivePowerRaiseReserveDeficit[g1][t];

// Reserve should cover loss of intermittent production asset with largest generation
	forall (p in isINTER_PRODS: activePowerLossPct[p] > 0, t in isDECISION_STEPS)
	  ctActivePowerRaiseReserveInterProd :
	  	sum (g in isTHERMAL_GENS) ThermalGenActiveRaiseReserve[g][t]					// reserve from thermal gens
	  + sum (s in isSTORAGES) StorActiveRaiseReserve[s][t]								// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadActiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  activePowerLossPct[p] / 100 * InterProdActivePower[p][t] - InterProdActivePowerRaiseReserveDeficit[p][t];

// Reserve should cover loss of storage asset with largest discharge
	forall (s1 in isSTORAGES: activePowerLossPct[s1] > 0, t in isDECISION_STEPS)
	  ctActivePowerRaiseReserveStorage :
	  	sum (g in isTHERMAL_GENS) ThermalGenActiveRaiseReserve[g][t]					// reserve from thermal gens
	  + (100.0 - activePowerLossPct[s1]) / 100 * StorActiveRaiseReserve[s1][t]			// reserve from what is left of s1
	  + sum (s in isSTORAGES diff({s1})) StorActiveRaiseReserve[s][t]					// reserve from other storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadActiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  activePowerLossPct[s1] / 100 * StorACPowerDischarge[s1][t] - StorActivePowerRaiseReserveDeficit[s1][t];

// Reserve should cover surge of non-flexible load unit with largest consumption
	forall (n in isNF_LOADS: activePowerSurgePct[n] > 0, t in isDECISION_STEPS)
	  ctActivePowerRaiseReserveNFLoad :
	  	sum (g in isTHERMAL_GENS) ThermalGenActiveRaiseReserve[g][t]					// reserve from thermal gens
	  + sum (s in isSTORAGES) StorActiveRaiseReserve[s][t]								// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadActiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  activePowerSurgePct[n] / 100 * NFLoadActivePower[n][t] - NFLoadActivePowerRaiseReserveDeficit[n][t];

// LOWER RESRVE
// Reserve should cover surge of intermittent production asset with largest generation
	forall (p1 in isINTER_PRODS: activePowerSurgePct[p1] > 0, t in isDECISION_STEPS)
	  ctActivePowerLowerReserveInterProd :
	  	sum(g in isTHERMAL_GENS) ThermalGenActivePower[g][t]							// reserve from thermal gens
	  + (100.0 - activePowerSurgePct[p1]) / 100 * InterProdActivePower[p1][t]			// reserve from what is left of p1
	  + sum (p in isINTER_PRODS diff({p1})) InterProdActivePower[p][t]					// reserve from other intermittent prod assets
	  + sum (s in isSTORAGES) StorActiveLowerReserve[s][t]								// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadActiveLowerReserve[f][t] >=						// reserve from flexible load units
	  activePowerSurgePct[p1] / 100 * InterProdActivePower[p1][t] - InterProdActivePowerLowerReserveDeficit[p1][t];

// Reserve should cover loss of storage asset with largest charge
	forall (s1 in isSTORAGES: activePowerSurgePct[s1] > 0, t in isDECISION_STEPS)
	  ctActivePowerLowerReserveStorage :
	  	sum (g in isTHERMAL_GENS) ThermalGenActivePower[g][t]							// reserve from thermal gens
	  + sum (p in isINTER_PRODS) InterProdActivePower[p][t]								// reserve from intermittent prod assets
	  + (100.0 - activePowerSurgePct[s1]) / 100 * StorActiveLowerReserve[s1][t]			// reserve from what is left of s1
	  + sum (s in isSTORAGES diff({s1})) StorActiveLowerReserve[s][t]					// reserve from other storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadActiveLowerReserve[f][t] >=						// reserve from flexible load units
	  activePowerSurgePct[s1] / 100 * StorACPowerCharge[s1][t] - StorActivePowerLowerReserveDeficit[s1][t];

// Reserve should cover loss of flexible load unit with largest consumption
	forall (f1 in isFLEX_LOADS: activePowerLossPct[f1] > 0, t in isDECISION_STEPS)
	  ctActivePowerLowerReserveFlexLoad :
	  	sum (g in isTHERMAL_GENS) ThermalGenActivePower[g][t]							// reserve from thermal gens
	  + sum (p in isINTER_PRODS) InterProdActivePower[p][t]								// reserve from intermittent prod assets
	  + sum (s in isSTORAGES) StorActiveLowerReserve[s][t]								// reserve from storage assets
	  + (100.0 - activePowerLossPct[f1]) / 100 * FlexLoadActiveLowerReserve[f1][t]		// reserve from what is left of f1
	  + sum (f in isFLEX_LOADS diff({f1})) FlexLoadActiveLowerReserve[f][t] >=			// reserve from other flexible load units
	  activePowerLossPct[f1] / 100 * FlexLoadActivePower[f1][t] - FlexLoadActivePowerLowerReserveDeficit[f1][t];

// Reserve should cover loss of non-flexible load unit with largest consumption
	forall (n in isNF_LOADS: activePowerLossPct[n] > 0, t in isDECISION_STEPS)
	  ctActivePowerLowerReserveNFLoad :
	  	sum (g in isTHERMAL_GENS) ThermalGenActivePower[g][t]							// reserve from thermal gens
	  + sum (p in isINTER_PRODS) InterProdActivePower[p][t]								// reserve from intermittent prod assets
	  + sum (s in isSTORAGES) StorActiveLowerReserve[s][t]								// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadActiveLowerReserve[f][t] >=						// reserve from flexible load units
	  activePowerLossPct[n] / 100 * NFLoadActivePower[n][t] - NFLoadActivePowerLowerReserveDeficit[n][t];
	  	
/* Reactive Power reserve */
// RAISE RESRVE
// Reserve should cover loss of termal generator with largest generation
	forall (g1 in isTHERMAL_GENS: reactivePowerLossPct[g1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerRaiseReserveThermalGen :
	    (100.0 - reactivePowerLossPct[g1]) / 100 * ThermalGenReactiveRaiseReserve[g1][t]	// reserve from what is left of g1
	  + sum (g in isTHERMAL_GENS diff({g1})) ThermalGenReactiveRaiseReserve[g][t]			// reserve from other thermal gens
	  + sum (s in isSTORAGES) StorReactiveRaiseReserve[s][t]	  							// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadReactiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  reactivePowerLossPct[g1] / 100 * ThermalGenReactivePower[g1][t] - ThermalGenReactivePowerRaiseReserveDeficit[g1][t];

// Reserve should cover loss of intermittent production asset with largest generation
	forall (p in isINTER_PRODS: reactivePowerLossPct[p] > 0, t in isDECISION_STEPS)
	  ctReactivePowerRaiseReserveInterProd :
	  	sum (g in isTHERMAL_GENS) ThermalGenReactiveRaiseReserve[g][t]					// reserve from thermal gens
	  + sum (s in isSTORAGES) StorReactiveRaiseReserve[s][t]							// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadReactiveRaiseReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerLossPct[p] / 100 * InterProdReactivePower[p][t] - InterProdReactivePowerRaiseReserveDeficit[p][t];

// Reserve should cover loss of storage asset with largest discharge
	forall (s1 in isSTORAGES: reactivePowerLossPct[s1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerRaiseReserveStorage :
	  	sum (g in isTHERMAL_GENS) ThermalGenReactiveRaiseReserve[g][t]					// reserve from thermal gens
	  + (100.0 - reactivePowerLossPct[s1]) / 100 * StorReactiveRaiseReserve[s1][t]		// reserve from what is left of s1
	  + sum (s in isSTORAGES diff({s1})) StorReactiveRaiseReserve[s][t]	  				// reserve from other storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadReactiveRaiseReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerLossPct[s1] / 100 * StorReactivePowerDischarge[s1][t] - StorReactivePowerRaiseReserveDeficit[s1][t];

// Reserve should cover surge of non-flexible load unit with largest consumption
	forall (n in isNF_LOADS: reactivePowerSurgePct[n] > 0, t in isDECISION_STEPS)
	  ctReactivePowerRaiseReserveNFLoad :
	  	sum (g in isTHERMAL_GENS) ThermalGenReactiveRaiseReserve[g][t]					// reserve from thermal gens
	  + sum (s in isSTORAGES) StorReactiveRaiseReserve[s][t]							// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadReactiveRaiseReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerSurgePct[n] / 100 * NFLoadReactivePower[n][t] - NFLoadReactivePowerRaiseReserveDeficit[n][t];

// LOWER RESRVE
// Reserve should cover surge of intermittent production asset with largest generation
	forall (p1 in isINTER_PRODS: reactivePowerSurgePct[p1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerLowerReserveInterProd :
	  	sum(g in isTHERMAL_GENS) ThermalGenReactivePower[g][t]							// reserve from thermal gens
	  + (100.0 - reactivePowerSurgePct[p1]) / 100 * InterProdReactivePower[p1][t]		// reserve from what is left of p1
	  + sum (p in isINTER_PRODS diff({p1})) InterProdReactivePower[p][t]				// reserve from other intermittent prod assets
	  + sum (s in isSTORAGES) StorReactiveLowerReserve[s][t]							// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadReactiveLowerReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerSurgePct[p1] / 100 * InterProdReactivePower[p1][t] - InterProdReactivePowerLowerReserveDeficit[p1][t];

// Reserve should cover loss of storage asset with largest charge
	forall (s1 in isSTORAGES: reactivePowerSurgePct[s1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerLowerReserveStorage :
	  	sum (g in isTHERMAL_GENS) ThermalGenReactivePower[g][t]							// reserve from thermal gens
	  + sum (p in isINTER_PRODS) InterProdReactivePower[p][t]							// reserve from intermittent prod assets
	  + (100.0 - reactivePowerSurgePct[s1]) / 100 * StorReactiveLowerReserve[s1][t]		// reserve from what is left of s1
	  + sum (s in isSTORAGES diff({s1})) StorReactiveLowerReserve[s][t]					// reserve from other storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadActiveLowerReserve[f][t] >=						// reserve from flexible load units
	  reactivePowerSurgePct[s1] / 100 * StorReactivePowerCharge[s1][t] - StorReactivePowerLowerReserveDeficit[s1][t];

// Reserve should cover loss of flexible load unit with largest consumption
	forall (f1 in isFLEX_LOADS: reactivePowerLossPct[f1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerLowerReserveFlexLoad :
	  	sum (g in isTHERMAL_GENS) ThermalGenReactivePower[g][t]							// reserve from thermal gens
	  + sum (p in isINTER_PRODS) InterProdReactivePower[p][t]							// reserve from intermittent prod assets
	  + sum (s in isSTORAGES) StorReactiveLowerReserve[s][t]							// reserve from storage assets
	  + (100.0 - reactivePowerLossPct[f1]) / 100 * FlexLoadReactiveLowerReserve[f1][t]	// reserve from what is left of f1
	  + sum (f in isFLEX_LOADS diff({f1})) FlexLoadReactiveLowerReserve[f][t] >=		// reserve from other flexible load units
	  reactivePowerLossPct[f1] / 100 * FlexLoadReactivePower[f1][t] - FlexLoadReactivePowerLowerReserveDeficit[f1][t];

// Reserve should cover loss of non-flexible load unit with largest consumption
	forall (n in isNF_LOADS: reactivePowerLossPct[n] > 0, t in isDECISION_STEPS)
	  ctReactivePowerLowerReserveNFLoad :
	  	sum (g in isTHERMAL_GENS) ThermalGenReactivePower[g][t]							// reserve from thermal gens
	  + sum (p in isINTER_PRODS) InterProdReactivePower[p][t]							// reserve from intermittent prod assets
	  + sum (s in isSTORAGES) StorReactiveLowerReserve[s][t]							// reserve from storage assets
	  + sum (f in isFLEX_LOADS) FlexLoadReactiveLowerReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerLossPct[n] / 100 * NFLoadReactivePower[n][t] - NFLoadReactivePowerLowerReserveDeficit[n][t];

/* Spinning reserve */
// RAISE RESERVE
// Raise reserve should cover 30% of total non-flexibile load for each decision step
	forall (t in isDECISION_STEPS)
	  ctSpinningRaiseReserveReq:
		  sum (g in isTHERMAL_GENS) ThermalGenSpinRaiseReserve[g][t] + sum (s in isSTORAGES) StorSpinRaiseReserve[s][t]
		>= sum (n in isNF_LOADS) NFLoadSpinRaiseReserveReq[n] / 100 * NFLoadActivePower[n][t] - SpinningRaiseReserveDeficit[t];

// LOWER RESERVE
// Lower reserve should cover 30% of total non-flexibile load for each decision step
	forall (t in isDECISION_STEPS)
	  ctSpinningLowerReserveReq:
		  sum (g in isTHERMAL_GENS) ThermalGenSpinLowerReserve[g][t] + sum (s in isSTORAGES) StorSpinLowerReserve[s][t]
		>= sum (n in isNF_LOADS) NFLoadSpinLowerReserveReq[n] / 100 * NFLoadActivePower[n][t] - SpinningLowerReserveDeficit[t];
	  
/* DEFAULT CURRENT */
// potential of current injection from assets must cover the global requirement for default current
	forall (t in isDECISION_STEPS)
	  ctDefaultCurrentReq :
	    sum (g in isTHERMAL_GENS) IsGenOn[g][t] * thermalGenCurrentInjection[g]
	  + sum (p in isINTER_PRODS: maxInterProdActivePower[p] > 0.0) (1.0 - InterProdActivePower[p][t] / maxInterProdActivePower[p]) * interProdCurrentInjection[p]
	  + sum (s in isSTORAGES: maxStorACActivePowerDischarge[s] > 0.0) storCurrentInjection[s]
	  >= defaultCurrentRequirement - DefaultCurrentRequirementDeficit[t];

/* SITES */
// Maximum input and output
 	forall (i in isSITES, t in isDECISION_STEPS)
 	  ctSiteMaxInOut : -maxInput[i] <=
 	    sum(g in isTHERMAL_GENS: i == siteID[g]) ThermalGenActivePower[g][t]
 	  + sum(p in isINTER_PRODS: i == siteID[p]) InterProdActivePower[p][t]
 	  + sum(s in isSTORAGES: i == siteID[s]) StorACActivePower[s][t]
 	  - sum(f in isFLEX_LOADS: i == siteID[f]) FlexLoadActivePower[f][t]
 	  - sum(n in isNF_LOADS: i == siteID[n]) NFLoadActivePower[n][t]
 	  + SiteMaxInputViolation[i][t] - SiteMaxOutputViolation[i][t]
 	  <= maxOutput[i];

/* NETWORK CONGESTIONS */
// Generic congestion contraints
 	forall (c in isCONGESTIONS, t in isDECISION_STEPS)
 	  ctCongestions : congestionLowerLim[c] <=
 	  	  importFactor[c] * NetImportTarget[t]
 	  	+ sum(g in isTHERMAL_GENS) thermalGenFactor[c][g] * ThermalGenActivePower[g][t]
 	  	+ sum(i in isINTER_PRODS) interProdFactor[c][i] * (InterProdActivePower[i][t] - InterProdForecastExcess[i][t])
 	  	+ sum(s in isSTORAGES) injectionFactor[c][s] * StorACActivePower[s][t]
 	  	- sum(f in isFLEX_LOADS) flexLoadFactor[c][f] * (FlexLoadActivePower[f][t] - FlexLoadForecastDeficit[f][t] + FlexLoadForecastExcess[f][t])
 	  	- sum(n in isNF_LOADS) nonFlexLoadFactor[c][n] * NFLoadActivePower[n][t]
 	  	+ CongestionLowerLimViolation[c][t] - CongestionUpperLimViolation[c][t] 
 	  	<= congestionUpperLim[c];
 
// HARD-CODED
// Specific congestion contraints
	if (microgridName == "MICROGRID MORBIHAN ENERGIES Kergrid") {
	 	forall (t in isDECISION_STEPS)
	 	  ctCongV1GC1C2 : sum (s in isSTORAGES inter {"MORB_ENERGIES_Kergrid_V1G_C1", "MORB_ENERGIES_Kergrid_V1G_C2"}) StorACActivePower[s][t] >= -18.0;
  } 	  
 }

 /**************************************************************************
 * declare tuple structures to host output data writen to Excel or JSON files
 * names of tuple members must be same as names of attributes in JSON
 * files or headers of columns in Excel files (DO cloud requirement)
 ****************************************************************************/
 /* DUMMY TUPLES TO EMPTY OUT AND PREPARE OUTPUT FILES */
tuple t_empty {
	string field_01;
	string field_02;
	string field_03;
	string field_04;
	string field_05;
	string field_06;
	string field_07;
	string field_08;
	string field_09;
	string field_10;
	string field_11;
	string field_12;
	string field_13;
	string field_14;
	string field_15;
	string field_16;
	string field_17;
	string field_18;
	string field_19;
	string field_20;
}
// FOR DEV ONLY (comment out for run)
{t_empty} EMPTY_OUTPUT = {<"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..10000};
{t_empty} OPERATION_HEADER = {<"param_id", "param_val", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
{t_empty} OPERATION_STEPS_HEADER = {<"step_id", "step_duration", "electricity_price", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
{t_empty} ASSETS_HEADER = {<"asset_id", "control", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
{t_empty} ASSET_STEPS_HEADER = {<"asset_id", "step_id", "power_target", "energy_target", "temperature_target", "curtailment_target", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
{t_empty} VIOLATIONS_OUTPUT_HEADER = {<"violation_type", "asset_id", "step_id", "violation_value", "violation_criticality", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
 
/* OPERATION DATA */
tuple t_operation_output {
 	key string param_id;
 	string param_val;
 }
string strSolStatus;
string strObjVal;
//string strTetrisStatus;
string strDispatchStatusString = "Dispatch found";
//string strTetrisCost;
//string strTetrisEnergyModulation;
//string strTetrisResourceUsage;
{t_operation_output} OPERATION_OUTPUT = {<"operation_id", operationID>	 // variable holding OPERATION output data
										, <"optimisation_request_time", optimisationRequestTime>
										, <"optimisation_interval_start", optimisationIntervalStartTime>
										, <"optimiser_solution_status", strSolStatus>
										, <"optimiser_objective_value", strObjVal>
//										, <"tetris_status", strTetrisStatus>
										, <"optimiser_solution_description", strDispatchStatusString>
//										, <"tetris_cost", strTetrisCost>
//										, <"tetris_energy", strTetrisEnergyModulation>
//										, <"tetris_usage", strTetrisResourceUsage>
										};
										
/* OPERATION x STEPS OUTPUT DATA */
tuple t_operation_steps_output {
 	key string step_id;
 	int step_duration;
 	float electricity_price;
 	}

{t_operation_steps_output} OPERATION_STEPS_OUTPUT = {<t, stepDuration[t], electricityPrice[t]> | t in isDECISION_STEPS}; // variable holding OPERATION x STEPS output data
string operationStepsExcelRange = "'OPERATION_STEPS_OUTPUT'!A2:C";

/* ASSETS OUTPUT DATA */
tuple t_assets_output {
 	key string asset_id;
 	string control;
 	}

{t_assets_output} ASSETS_OUTPUT = {<a.asset_id, a.control> | a in ASSETS}; // variable holding ASSETS output data
string assetsExcelRange = "'ASSETS_OUTPUT'!A2:B";

/* ASSET x STEPS OUTPUT DATA */
tuple t_asset_steps_output {
 	key string asset_id;
 	key string step_id;
 	float power_target;
 	float storage_target;
 	float temperature_target;
 	float curtailment_target;
 	}

float assetPowerTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetStorageTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetTempTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetCurtailmentTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
{t_asset_steps_output} ASSET_STEPS_OUTPUT = {<a, t, assetPowerTarget[a][t], assetStorageTarget[a][t], assetTempTarget[a][t], assetCurtailmentTarget[a][t]> | a in isASSETS union {"MAINGRID"}, t in isDECISION_STEPS}; // variable holding ASSET x STEPS output data
string assetStepsExcelRange = "'ASSET_STEPS_OUTPUT'!A2:F";
 
/* VIOLATION OUTPUT DATA */
tuple t_violations_output {
 	key string violation_type;
 	key string asset_id;
 	key string step_id;
 	float violation_value;
	int violation_criticality;
 	}
 
{t_violations_output} VIOLATIONS_OUTPUT; // variable holding VIOLATIONS output data
int nViolations = card(VIOLATIONS_OUTPUT);
string violationExcelRange = "'VIOLATIONS_OUTPUT'!A2:E";

execute {
	strSolStatus = cplex.getCplexStatus().toString();
	strObjVal = cplex.getObjValue().toString();
	assetsExcelRange += (assetNumber + 1).toString();
 	assetStepsExcelRange += (optimisationStepNumber * (assetNumber+1) + 1).toString();
 	operationStepsExcelRange += (optimisationStepNumber + 1).toString();
 	
 	// fill in asset targets according to types of asset and types of control 
 	for (var t in isDECISION_STEPS) {
 		
 		// power import targets for connection to main-grid
 		assetPowerTarget["MAINGRID"][t] = NetImportTarget[t];
 		
 		// power generation target for intermittent production assets
 		for	(var i in isINTER_PRODS)
 		{
 			assetPowerTarget[i][t] = -InterProdActivePower[i][t];				// respects Everest's sign convention (-ve values = power generation)
 			assetCurtailmentTarget[i][t] = -InterProdPowerCurtailment[i][t];	// respects Everest's sign convention (-ve values = power generation)
  		}
  		
  		// power generation target for thermal generator assets
 		for	(var g in isTHERMAL_GENS)
 		{
 			assetPowerTarget[g][t] = -ThermalGenActivePower[g][t];				// respects Everest's sign convention (-ve values = power generation)
  		}
  		
  		// consumption forecasts for non-flexible load units
 		for	(var n in isNF_LOADS)
 		{
 			assetPowerTarget[n][t] = NFLoadActivePower[n][t];					// respects Everest's sign convention (+ve values = power consumption)
			// temporary workaround to send battery's projected SOC
			if ((microgridName == "MICROGRID MORBIHAN ENERGIES FlexMobIle" || microgridName == "MICROGRID MORBIHAN ENERGIES Kergrid")
				&& maxCharge[Opl.first(isSTORAGES)] > 0.0)
 				assetTempTarget[n][t] = 100 * StorStoredDCEnergy[Opl.first(isSTORAGES)][t] / maxCharge[Opl.first(isSTORAGES)];
		}
  		
  		// consumption targets for flexible load units 
 		for	(var f in isFLEX_LOADS)	// when not subject to ramp rate constraints
 		{
 			assetPowerTarget[f][t] = FlexLoadActivePower[f][t];					// respects Everest's sign convention (+ve values = power consumption)
  		} 			
  		
  		// temperature targets for flexible load units that are controled by temperature setpoints
  		for	(var f in isFLEX_LOADS_TEMP) {
 			assetTempTarget[f][t] = (ModulationTarget[f][t] < -epsilon ? targetLevelTemps[f]["LOW"] :
 									(ModulationTarget[f][t] > epsilon ? targetLevelTemps[f]["HIGH"] :
 									targetLevelTemps[f]["NOMINAL"]));
  		}
  		
  		// power charge / discharge targets and energy storage targets for storage units
 		for	(var s in isSTORAGES)	// when not subject to ramp rate constraints
 		{
 			assetPowerTarget[s][t] = -StorACActivePower[s][t];					// respects Everest's sign convention (+ve values = power charge and -ve values = power discharge)
 			assetStorageTarget[s][t] = StorStoredDCEnergy[s][t];
  		} 			
  	}
 
	// check if any power balance violation
	var anyDeficit = false;
	var anyExcess = false;
	for (var t in isDECISION_STEPS) {
		// power deficit
		if (PowerDeficit[t] > epsilon) {
			if (!anyDeficit) {
				strDispatchStatusString += ", some power balance constraint deficit";
				anyDeficit = true;
 			}

			VIOLATIONS_OUTPUT.add("power_balance_constraint_deficit", "", t, PowerDeficit[t], 1);
		}
		// power excess
		if (PowerExcess[t] > epsilon) {
			if (!anyExcess) {
				strDispatchStatusString += ", some power balance constraint excess";
				anyExcess = true;
 			}

			VIOLATIONS_OUTPUT.add("power_balance_constraint_excess", "", t, PowerExcess[t], 1);
		}
	}

	// check if any intermittent production forecast violation
	var anyViolation = false;
	for (var i in isINTER_PRODS)
		for (var t in isDECISION_STEPS)
			if (InterProdForecastExcess[i][t] > epsilon) {
				if (!anyViolation) {
					strDispatchStatusString += ", some intermittent production forecast violation";
					anyViolation = true;
	 			}

				VIOLATIONS_OUTPUT.add("intermittent_production_forecast_violation", i, t, InterProdForecastExcess[i][t], 1);
			}
	
	// check if any unauthorized intermittent production curtailment 
	var anyViolation = false;
	for (var t in isDECISION_STEPS)
		if (UnauthorizedInterProdCurt[t] > epsilon) {
			if (!anyViolation) {
				strDispatchStatusString += ", some unauthorized intermittent production curtailment";
				anyViolation = true;
		}

				VIOLATIONS_OUTPUT.add("unauthorized_intermittent_production_curtailment", "", t, UnauthorizedInterProdCurt[t], 100);
			}
 
	// check if any storage charge violation
	anyDeficit = false;
	anyExcess = false;
	for (var s in isSTORAGES)
		for (var t in isDECISION_STEPS) {
			// min SOC deficit
			if (SOCminDeficit[s][t] > epsilon) {
				if (!anyDeficit) {
					strDispatchStatusString += ", some minimum SOC deficit";
					anyDeficit = true;
	 			}
	
				VIOLATIONS_OUTPUT.add("minimum_SOC_deficit", s, t, SOCminDeficit[s][t], 100);
			}
			// strict min SOC deficit
			if (SOCstrictMinDeficit[s][t] > epsilon) {
				if (!anyDeficit) {
					strDispatchStatusString += ", some strict minimum SOC deficit";
					anyDeficit = true;
	 			}
	
				VIOLATIONS_OUTPUT.add("strict_minimum_SOC_deficit", s, t, SOCstrictMinDeficit[s][t], 1);
			}
			// max SOC excess
			if (SOCmaxExcess[s][t] > epsilon) {
				if (!anyExcess) {
					strDispatchStatusString += ", some maximum SOC excess";
					anyExcess = true;
	 			}
	
				VIOLATIONS_OUTPUT.add("maximum_SOC_excess", s, t, SOCmaxExcess[s][t], 1);
			}
		}

	// check if there is SOC target violation
	anyDeficit = false;
	// SOCTarget
	for (var s in isSTORAGES)
		for (var t in isDECISION_STEPS) 
		{			
			if (SocTargetStorageDeficit[s][t] > epsilon) {
				if (!anyDeficit) {
				strDispatchStatusString += ", some Target SOC deficit";
				anyDeficit = true;
	 			}
				VIOLATIONS_OUTPUT.add("SOC_Target_deficit", s, t, SocTargetStorageDeficit[s][t], 100);
			}
		}
		
	// check if any flexible load nominal forecast violation
	anyDeficit = false;
	anyExcess = false;
	for (var f in isFLEX_LOADS)
		for (var t in isDECISION_STEPS) {
			// forecast deficit
			if (FlexLoadForecastDeficit[f][t] > epsilon) {
				if (!anyDeficit) {
					strDispatchStatusString += ", some nominal load forecast deficit";
					anyDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("nominal_load_forecast_deficit", f, t, FlexLoadForecastDeficit[f][t], 1);
			}
			// forecast excess
			if (FlexLoadForecastExcess[f][t] > epsilon) {
				if (!anyExcess) {
					strDispatchStatusString += ", some nominal load forecast excess";
					anyExcess = true;
	 			}

				VIOLATIONS_OUTPUT.add("nominal_load_forecast_excess", f, t, FlexLoadForecastExcess[f][t], 1);
			}
 		}
 
	// check if any default current requirement violation
	anyDeficit = false;
	for (var t in isDECISION_STEPS) {
		if (DefaultCurrentRequirementDeficit[t] > epsilon) {
			if (!anyDeficit) {
				strDispatchStatusString += ", some default current requirement deficit";
				anyDeficit = true;
 			}

			VIOLATIONS_OUTPUT.add("default_current_requirement_deficit", "", t, DefaultCurrentRequirementDeficit[t], 10);
		}
	}
	
	//Check if any termal gen minimum active power constraint violation
	anyDeficit = false;
	for (var g in isTHERMAL_GENS)
		for (var t in isDECISION_STEPS) {
			if(ThermalGenMinActivePowerDeficit[g][t] > epsilon){
				if (!anyDeficit) {
					strDispatchStatusString += ", some minimum power deficit";
					anyDeficit = true;
 			}
 			VIOLATIONS_OUTPUT.add("min_active_power_deficit", g, t, ThermalGenMinActivePowerDeficit[g][t], 1);
			}		
		}

	// check if any min/max steps on/off constraint violation for initial steps
	var anyMinStepsOnViolation = false;
	var anyMaxStepsOnViolation = false;
	var anyMinStepsOffViolation = false;
	for (var g in isTHERMAL_GENS) {
		// initial min steps on violation
		if (GenMinStepOnInitialDeficit[g] > epsilon) {
			if (!anyMinStepsOnViolation) {
				strDispatchStatusString += ", some deficit of initial minimum steps on constraint";
				anyMinStepsOnViolation = true;			
			}
			
			VIOLATIONS_OUTPUT.add("initial_min_steps_on_deficit", g, "", GenMinStepOnInitialDeficit[g], 10);
		}
		// initial max steps on violation
		for (var i = 0 ; i <= genInitialStepsOnMax[g]-1 ; i++)
			if (GenMaxStepOnInitialExcess[g][i] > epsilon) {
				if (!anyMaxStepsOnViolation) {
					strDispatchStatusString += ", some excess of initial maximum steps on constraint";
					anyMaxStepsOnViolation= true;			
				}
				
				VIOLATIONS_OUTPUT.add("initial_max_steps_on_excess", g, (i-genInitialStepsOnMax[g]).toString(), GenMaxStepOnInitialExcess[g][i], 10);
			}
		// initial min steps off violation
		if (GenMinStepOffInitialDeficit[g] > epsilon) {
			if (!anyMinStepsOffViolation) {
				strDispatchStatusString += ", some deficit of initial minimum steps off constraint";
				anyMinStepsOffViolation = true;			
			}
			
			VIOLATIONS_OUTPUT.add("initial_min_steps_off_deficit", g, "", GenMinStepOffInitialDeficit[g], 10);
		}
	}
	
	// check if any min/max steps on/off constraint violation for other steps
	anyMinStepsOnViolation = false;
	anyMaxStepsOnViolation = false;
	anyMinStepsOffViolation = false;
	for (var g in isTHERMAL_GENS)
		for (var t in isDECISION_STEPS) {
			// min steps on violation
			if (GenMinStepOnDeficit[g][t] > epsilon) {
				if (!anyMinStepsOnViolation) {
					strDispatchStatusString += ", some deficit of minimum steps on constraint";
					anyMinStepsOnViolation = true;			
				}
				
				VIOLATIONS_OUTPUT.add("min_steps_on_deficit", g, t, GenMinStepOnDeficit[g][t], 10);
			}
			// max steps on violation
			if (GenMaxStepOnExcess[g][t] > epsilon) {
				if (!anyMaxStepsOnViolation) {
					strDispatchStatusString += ", some excess of maximum steps on constraint";
					anyMaxStepsOnViolation= true;			
				}
				
				VIOLATIONS_OUTPUT.add("max_steps_on_excess", g, t, GenMaxStepOnExcess[g][t], 10);
			}
			// min steps off violation
			if (GenMinStepOffDeficit[g][t] > epsilon) {
				if (!anyMinStepsOffViolation) {
					strDispatchStatusString += ", some deficit of minimum steps off constraint";
					anyMinStepsOffViolation = true;			
				}
				
				VIOLATIONS_OUTPUT.add("min_steps_off_deficit", g, t, GenMinStepOffDeficit[g][t], 10);
			}
		}
	
	// check if any active power reserve constraint violation for thermal gens
	var anyRaiseReserveDeficit = false;
	var anyLowerReserveDeficit = false;
	for (var g in isTHERMAL_GENS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (ThermalGenActivePowerRaiseReserveDeficit[g][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power raise reserve to cover loss of thermal generation";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("thermal_gen_active_power_raise_reserve_deficit", g, t, ThermalGenActivePowerRaiseReserveDeficit[g][t], 10);
			}
 		}

 	// check if any reactive power reserve constraint violation for thermal gens
	var anyRaiseReserveDeficit = false;
	var anyLowerReserveDeficit = false;
	for (var g in isTHERMAL_GENS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (ThermalGenReactivePowerRaiseReserveDeficit[g][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power raise reserve to cover loss of thermal generation";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("thermal_gen_reactive_power_raise_reserve_deficit", g, t, ThermalGenReactivePowerRaiseReserveDeficit[g][t], 10);
			}
 		}

	// check if any active power reserve constraint violation for intermittent production
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var i in isINTER_PRODS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (InterProdActivePowerRaiseReserveDeficit[i][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power raise reserve to cover loss of intermittent production";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_prod_active_power_raise_reserve_deficit", i, t, InterProdActivePowerRaiseReserveDeficit[i][t], 10);
			}
			// lower reserve violation
			if (InterProdActivePowerLowerReserveDeficit[i][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power lower reserve to cover surge of intermittent production";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_prod_active_power_lower_reserve_deficit", i, t, InterProdActivePowerLowerReserveDeficit[i][t], 10);
			}
 		}		
	
	// check if any reactive power reserve constraint violation for intermittent production
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var i in isINTER_PRODS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (InterProdReactivePowerRaiseReserveDeficit[i][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power raise reserve to cover loss of intermittent production";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_prod_reactive_power_raise_reserve_deficit", i, t, InterProdReactivePowerRaiseReserveDeficit[i][t], 10);
			}
			// lower reserve violation
			if (InterProdReactivePowerLowerReserveDeficit[i][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power lower reserve to cover surge of intermittent production";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_prod_reactive_power_lower_reserve_deficit", i, t, InterProdReactivePowerLowerReserveDeficit[i][t], 10);
			}
 		}	

	// check if any active power reserve constraint violation for storage
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var s in isSTORAGES)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (StorActivePowerRaiseReserveDeficit[s][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power raise reserve to cover loss of storage discharge";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("storage_active_power_raise_reserve_deficit", s, t, StorActivePowerRaiseReserveDeficit[s][t], 10);
			}
			// lower reserve violation
			if (StorActivePowerLowerReserveDeficit[s][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power lower reserve to cover loss of storage charge";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("storage_active_power_lower_reserve_deficit", s, t, StorActivePowerLowerReserveDeficit[s][t], 10);
			}
 		}		

 	// check if any reactive power reserve constraint violation for storage
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var s in isSTORAGES)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (StorReactivePowerRaiseReserveDeficit[s][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power raise reserve to cover loss of storage discharge";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("storage_reactive_power_raise_reserve_deficit", s, t, StorReactivePowerRaiseReserveDeficit[s][t], 10);
			}
			// lower reserve violation
			if (StorReactivePowerLowerReserveDeficit[s][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power lower reserve to cover loss of storage charge";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("storage_reactive_power_lower_reserve_deficit", s, t, StorReactivePowerLowerReserveDeficit[s][t], 10);
			}
 		}		

	// check if any active power reserve constraint violation for flexible load
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var f in isFLEX_LOADS)
		for (var t in isDECISION_STEPS) {
			// lower reserve violation
			if (FlexLoadActivePowerLowerReserveDeficit[f][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power lower reserve to cover loss of flexible load";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("flex_load_active_power_lower_reserve_deficit", f, t, FlexLoadActivePowerLowerReserveDeficit[f][t], 10);
			}
 		}		

 	// check if any reactive power reserve constraint violation for flexible load
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var f in isFLEX_LOADS)
		for (var t in isDECISION_STEPS) {
			// lower reserve violation
			if (FlexLoadReactivePowerLowerReserveDeficit[f][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power lower reserve to cover loss of flexible load";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("flex_load_reactive_power_lower_reserve_deficit", f, t, FlexLoadReactivePowerLowerReserveDeficit[f][t], 10);
			}
 		}		

	// check if any active power reserve constraint violation for non-flexible load
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var n in isNF_LOADS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (NFLoadActivePowerRaiseReserveDeficit[n][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power raise reserve to cover surge of non-flexible load";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("NF_load_active_power_raise_reserve_deficit", n, t, NFLoadActivePowerRaiseReserveDeficit[n][t], 10);
			}
			// lower reserve violation
			if (NFLoadActivePowerLowerReserveDeficit[n][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power lower reserve to cover loss of non-flexible load";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("NF_load_active_power_lower_reserve_deficit", n, t, NFLoadActivePowerLowerReserveDeficit[n][t], 10);
			}
 		}		
 			
	// check if any reactive power reserve constraint violation for non-flexible load
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var n in isNF_LOADS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (NFLoadReactivePowerRaiseReserveDeficit[n][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power raise reserve to cover surge of non-flexible load";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("NF_load_reactive_power_raise_reserve_deficit", n, t, NFLoadReactivePowerRaiseReserveDeficit[n][t], 10);
			}
			// lower reserve violation
			if (NFLoadReactivePowerLowerReserveDeficit[n][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power lower reserve to cover loss of non-flexible load";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("NF_load_reactive_power_lower_reserve_deficit", n, t, NFLoadReactivePowerLowerReserveDeficit[n][t], 10);
			}
 		}		

	
	// check if any spinning reserve constraint violation
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var t in isDECISION_STEPS) {
		// raise reserve violation
		if (SpinningRaiseReserveDeficit[t] > epsilon) {
			if (!anyRaiseReserveDeficit) {
				strDispatchStatusString += ", some deficit of spinning raise reserve";
				anyRaiseReserveDeficit = true;
 			}

			VIOLATIONS_OUTPUT.add("spinning_raise_reserve_deficit", "", t, SpinningRaiseReserveDeficit[t], 10);
		}

		// lower reserve violation
		if (SpinningLowerReserveDeficit[t] > epsilon) {
			if (!anyLowerReserveDeficit) {
				strDispatchStatusString += ", some deficit of spinning lower reserve";
				anyLowerReserveDeficit = true;
 			}

			VIOLATIONS_OUTPUT.add("spinning_lower_reserve_deficit", "", t, SpinningLowerReserveDeficit[t], 10);
		}
	}

	// check if any site max input/output constraint violation
	anyDeficit = false;
	anyExcess = false;
	for (var i in isSITES)
		for (var t in isDECISION_STEPS) {
			// max input violation
			if (SiteMaxInputViolation[i][t] > epsilon) {
				if (!anyDeficit) {
					strDispatchStatusString += ", some site max input violation";
					anyDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("site_maximum_input_violation", i, t, SiteMaxInputViolation[i][t], 1);
			}
			// max output violation
			if (SiteMaxOutputViolation[i][t] > epsilon) {
				if (!anyExcess) {
					strDispatchStatusString += ", some site max output violation";
					anyExcess = true;
	 			}

				VIOLATIONS_OUTPUT.add("site_maximum_output_violation", i, t, SiteMaxOutputViolation[i][t], 1);
			}
 		}					

	// check if any network congestion constraint violation
	anyDeficit = false;
	anyExcess = false;
	for (var c in isCONGESTIONS)
		for (var t in isDECISION_STEPS) {
			// lower limit violation
			if (CongestionLowerLimViolation[c][t] > epsilon) {
				if (!anyDeficit) {
					strDispatchStatusString += ", some network congestion lower limit violation";
					anyDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("network_congestion_lower_lim_violation", c, t, CongestionLowerLimViolation[c][t], 1);
			}
			// upper limit violation
			if (CongestionUpperLimViolation[c][t] > epsilon) {
				if (!anyExcess) {
					strDispatchStatusString += ", some network congestion upper limit violation";
					anyExcess = true;
	 			}

				VIOLATIONS_OUTPUT.add("network_congestion_uppwer_lim_violation", c, t, CongestionUpperLimViolation[c][t], 1);
			}
 		}					

	violationExcelRange += (nViolations+2).toString();
}
 