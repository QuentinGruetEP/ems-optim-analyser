/*********************************************
 * Microgrid Optimisation Model v3.10
 * Author: j.leduc
 * Creation Date: 07 feb. 2025
 *********************************************/

// hard-coded parameters for all microgrids in this model
//		- final battery SOC set to 0% or more (see finalSOCLowerBound param)
//		- number of asset's blocks set to 1 (see nomBlockNbr param)
//			-> impacts computation of number of healty blocks for each asset (see healthyBlockNbr param)
//		- linear and constant terms of linear approximation of assets min and max reactive powers set to zero (see aQmax / bQmax / aQmin / bQmin)
//		- physical min power for each dispatchable generator set to min between 5 kW and generator's min power (see physMinDispGenActivePower param)
//		- conversion efficiency set to 0.998 for all elec to heat energy conversion assets (see convElecToHeatEff param)
//		- indexing set of assets converting heat into some other type of energy set to empty (see isHIN_CONVS set)
//		- indexing set of assets converting some other of energy into electricity set to empty (see isEOUT_CONVS set)
//		- indexing set of assets converting heat into electricity set to empty (see isH_E_CONVS set)
//		- heat congestion for combined output from heat generating assets set to 50.0MW (see ctHeatCongestion constraint)

// hard-coded parameters in this model for Srisangtham microgrid
//		- tax on drawing electricity from main grid set to 3 currency_unit / kWh (see networkDrawingTax param)

// hard-coded parameters in this model for VidoFleur microgrid
//		- tax on drawing electricity from main grid set to 0.045 currency_unit / kWh (see networkDrawingTax param)

// hard-coded parameters in this model for Enercal's Ile des Pins and Mare microgrids and TPS's Tongatapu microgrid
//		- SOC strict minimum for any storage unit set to 5% (see storStrictElecMinSOC param)

// hard-coded parameters in this model for Enercal's Ile des Pins microgrid
//		- number of asset's blocks overidden to 6 (see nomBlockNbr param)
//			-> impacts computation of number of healty blocks for each asset (see healthyBlockNbr param)
//		- storage unit's hard coded nominal max charge and discharge power set to 1040kW (-1040kW)(see nomPowerMax / nomPowerMin param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param) 
//			-> impacts computation of linear and constant terms of linear approximation of assets min and max reactive powers see (aQmax and bQmax param)
//			-> impacts computation of current injection potential for each storage unit (see storCurrentInjection param)
//		- linear and constant terms of linear approximation of assets min and max reactive powers overriden (see aQmax / bQmax / aQmin / bQmin)

// hard-coded parameters in this model for Enercal's Mare microgrid
//		- number of asset's blocks overidden to 6 (see nomBlockNbr param)
//			-> impacts computation of number of healty blocks for each asset (see healthyBlockNbr param)
//		- storage unit's hard coded max charge and discharge power set to 800kW (-800kW) (see nomPowerMax / nomPowerMin param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param) 
//			-> impacts computation of linear and constant terms of linear approximation of assets min and max reactive powers see (aQmax and bQmax param)
//			-> impacts computation of current injection potential for each storage unit (see storCurrentInjection param)
//		- linear and constant terms of linear approximation of assets min and max reactive powers overriden (see aQmax / bQmax / aQmin / bQmin)

// hard-coded parameters in this model for TPS's Tongatapu microgrid
//		- number of asset's blocks overidden to 6 (see nomBlockNbr param)
//			-> impacts computation of number of healty blocks for each asset (see healthyBlockNbr param)
//		- storage unit's hard coded max charge and discharge power set to 6000kW (-6000kW) for Tongatapu_Matatoa_BESS and 7200kW (-7200kW) for Tongatapu_Popua_BESS (see nomPowerMin / nomPowerMax param)
//			-> impacts computation of number of healty inverters for each storage unit (see availInverterNbr param)
//			-> impacts computation of linear and constant terms of linear approximation of assets min and max reactive powers see (aQmax and bQmax param)
//			-> impacts computation of current injection potential for each storage unit (see storCurrentInjection param)
//		- linear and constant terms of linear approximation of assets min and max reactive powers overriden (see aQmax / bQmax / aQmin / bQmin)
//		- fraction of active power load that defines requirement for spinning raise reserve set to  30% (see NFLoadRaiseReserveReq param)
//		- fraction of active power load that defines requirement for spinning lower reserve set to  30% (see NFLoadLowerReserveReq param)

// hard-coded parameters in this model for Morbihan Energies' Kergrid microgrid
//		- minimum charging rate for each charging point on charging station used by MORB_ENERGIES_Kergrid_V1G_C1 and MORB_ENERGIES_Kergrid_V1G_C2 vehicles set to 9kW (see ctStorageChargeMin1 constraint)
//		- maximum charging rate for charging station used by MORB_ENERGIES_Kergrid_V1G_C1 and MORB_ENERGIES_Kergrid_V1G_C2 vehicles set to 18kW (see ctCongV1GC1C2 constraint)

// temporary workaround to send battery's projected SOC for FlexMob'Ile and Kergrid and microgrids (see assetTempTarget output param)

// hard-coded parameters in this model for MOPABLOEM, Globe Plant Brielle and Vierpoldres and Verberne America microgrids
//		- indexing set of assets that consume or generate electricity (see E_ASSETS set)
//		- indexing set of assets that consume or generate heat (see H_ASSETS set)
//		- indexing set of energy conversion assets (see isCONVS)
//		- indexing set of assets converting elec into some other type of energy (see isEIN_CONVS set)
//		- indexing set of assets converting some type of energy into heat (see isHOUT_CONVS set)

// hard-coded parameters in this model for MOPABLOEM microgrid
//		- heat/elec ratio giving the heat energy produced by CHP per unit of elec energy set to 1.9 / 1.6 (see assetHeatElecRatio param)
//		- energy conversion efficiency expressed as a ratio for e-boilers set to 0.998 (see assetEnergyConvEfficiency param)

// hard-coded parameters in this model for Globe Plant Brielle microgrid
//		- heat/elec ratio giving the heat energy produced by CHP per unit of elec energy set to 51.8 / 43.7 (see assetHeatElecRatio param)
//		- energy conversion efficiency expressed as a ratio for e-boilers set to 0.998 (see assetEnergyConvEfficiency param)

// hard-coded parameters in this model for Globe Plant Vierpolders microgrid
//		- heat/elec ratio giving the heat energy produced by CHP per unit of elec energy set to 46.1 / 43.7 (see assetHeatElecRatio param)
//		- energy conversion efficiency expressed as a ratio for e-boilers set to 0.998 (see assetEnergyConvEfficiency param)

// hard-coded parameters in this model for Verberne America microgrid
//		- heat/elec ratio giving the heat energy produced by CHP 1 per unit of elec energy set to 35.9 / 55.9 (see assetHeatElecRatio param)
//		- heat/elec ratio giving the heat energy produced by CHP 2 per unit of elec energy set to 20,67 / 44,04 (see assetHeatElecRatio param)
// TO BE DONE
//		- energy conversion efficiency expressed as a ratio for e-boilers set to 300 (see assetEnergyConvEfficiency param)

// hard-coded parameters in this model for VALOREM LIMOUX microgrid
//		- set of asset certified to deliver FCR set to "VALOREM_Limoux_BESS" (see isFCR_ASSETS set)
//		- site's maximum power offtake linked to "VALOREM_Limoux_PDL_in" non-flex load unit's maximum load (see maxInput param)
//		- site's maximum power injection linked to "VALOREM_Limoux_PDL_out" non-flex load unit's maximum load (see maxOutput param)
//		- artificial cost on storage asset charing / discharging changes to smooth out usage set to 0.0001 (see storPowerChangePenalty para)
//		- artificial cost on storage asset charing / discharging to encourage late usage of the asset set to zero (see storArtificialPenalityCost param)
//		- negative imbalance price hard coded to 10 x DA price in the context of intraday operation optimisation (see negative_imb_price param)
//		- positive imbalance price hard coded to 10 x DA price in the context of intraday operation optimisation (see positive_imb_price param)
//		- storage unit's hard coded FCR certified power set to 1000kW (see fcrCertfiedPower param)
//		- storage unit's hard coded nominal max charge and discharge power set to 1304kW (-1304kW) (see nomPowerMax / nomPowerMin param)
//		- storage unit's hard coded nominal max energy set to 2610kWh (see nomEnergyMax)
//		- site's minimum partial availability required to deliver FCR hard coded to 90% (see fcrReqPower param)

// hard-coded parameters in this model for GEG SYNERGIE MAURIENNE microgrid
//		- artificial cost on storage asset charing / discharging changes to smooth out usage set to 0.0001 (see storPowerChangePenalty para)
//		- artificial cost on storage asset charing / discharging to encourage late usage of the asset set to zero (see storArtificialPenalityCost param)
//		- negative imbalance price hard coded to 10 x DA price in the context of intraday operation optimisation (see negative_imb_price param)
//		- positive imbalance price hard coded to 10 x DA price in the context of intraday operation optimisation (see positive_imb_price param)
//		- storage unit's hard coded nominal max charge and discharge power set to 1000kW (-1000kW) for GEG and 5600kW (-5600kW) for Synergie M. (see nomPowerMax / nomPowerMin param)
//		- storage unit's hard coded nominal max energy set to 1831kWh for GEG and 12210kW for SYNERGIE M. (see nomEnergyMax)

// artifical penalties for all microgrids in this model
//		- artificial penalty to encourage first step's average active power to stay the same as it was initially for dispatchable gen d if d is initially on set to 0.1 * d's linear variable costs or d's lowest non-linear cost model marginal cost: dispGenInitialPowerViolPenalty
//		- artificial penalty to encourage battery SOC to be above min SOC set to 1.2 * highest non-linear cost model marginal cost: socMinViolationPenaltyCost
//		- artificial penalty to avoid intermittent prod curtailment unless all storage units are full set to 0.1 * max prices (see unauthorizedInterGenCurtPenaltyCost param)
//		- FCR asset's minimum partial availability required to deliver FCR hard coded to 90% (see fcrReqPower param)

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
 	key string step_id;				// Asset step ID generated by Everest
 	int step_duration;				// in minutes (MUST be expressed as a whole number of minutes b/c is used in the definition of a range)
 	float electricity_price;		// in currency unit/kWh
 	float max_export_to_main_grid;	// in kW
 	float max_import_from_main_grid; // in kW
 }
{t_operation_steps} OPERATION_STEPS = ...; // variable holding OPERATION_STEPS data

/* OPERATION_STEPS_LINK */
tuple t_operation_steps_link {
 	key string asset_step;			// Asset step ID generated by Everest
 	string imbalance_step;			// Imbalance step ID generated by Everest
 	string day_ahead_step;			// Day-ahead step ID generated by Everest
 	string fcr_step;				// FCR step ID generated by Everest
 	string mfrr_step;				// mFRR step ID generated by Everest
 	string afrr_capacity_step;		// aFRR capacity step ID generated by Everest
 	string afrr_voluntary_step;	// aFRR voluntary step ID generated by Everest
 }
{t_operation_steps_link} OPERATION_STEPS_LINK = ...; // variable holding OPERATION_STEPS_LINK
/* ASSET DATA */
tuple t_assets {
 	key string asset_id;					// Everest's capacity ID
 	string type;							// 'FLEX_LOAD' 'LOAD' 'GENERATOR' 'INTERMITTENT' 'STORAGE' 'SITE'
 	// IMPACT EV
 	// string type;							// 'FLEX_LOAD' 'LOAD' 'GENERATOR' 'INTERMITTENT' 'STORAGE' 'CONVERTER' 'SITE'
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
 	string compensation_model;				// indication of the curtailment calculation methodology (DEFAULT_BASED or -1 = based on installed peak capacity or FORECAST_BASED = based on power forecast or -1 if not set in Everest)
 	float startup_cost;						// cost of starting asset (expressed in market currency)
 	string var_cost_model;					// ID of variable cost model applying to asset
 	float active_power_loss;				// credible sudden loss of active power (% of asset's active power)
 	float active_power_surge;				// credible sudden surge of active power (% of asset's active power)
 	float reactive_power_loss;				// credible sudden loss of reactive power (% of asset's active power)
 	float reactive_power_surge;				// credible sudden surge of reactive power (% of asset's active power)
 	float power_tolerance;					// active power floor (expressed in kW) under which asset is considered to be off
	float daily_maximum_number_of_cycles;   // daily maximum cycling (expressed in number of cycle) for the storage asset.
	string var_efficiency_model;				//  ID of variable efficiency model applying to asset
	// IMPACT EV
// 	string operating_mode;					// asset's operating mode: GRID_FORMING / GRID_FOLLOWING / GRID_TIED
//	float spin_raise_reserv_req_perc;		// fraction (expressed as a %) of asset's active power that defines requirements for spinning raise reserve (NF load units only)
//	float spin_lower_reserv_req_perc;		// fraction (expressed as a %) of asset's active power that defines requirements for spinning lower reserve (NF load units only) // 	string energies_in;						// 'ELEC', 'HEAT', 'OTHER'
// 	string energies_out;					// 'ELEC', 'HEAT', 'ELEC+HEAT', 'OTHER'
// 	float elec_heat_ratio;				// ratio giving the heat energy produced per unit of elec energy produced
//	float conv_efficiency;					// ratio giving energy conversion efficiency
}
{t_assets} ASSETS = ...; // variable holding ASSETS data

/* ASSET x STEP DATA */
tuple t_asset_steps {
	key string asset_id;						// Everest's capacity ID
	key string step_id;							// Some ID generated by Everest
	float power_prediction;						// in kW: +ve = consumption and -ve = generation
	float soc_target;							// SOC (in %) to reach before asset becomes unavailable
	float availability;							// asset's availability (0 / 1 for alla or nothing assets or betwwen 0 and 1 for assets with partial availability)
	float daily_known_cycle_contribution;       // number of charge cycles performed in the last 24 hours
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
	key string direction; 			// It will take as value "CHARGE" or "DISCHARGE" for batteries, -1 otherwise.
	float efficiency_slope;			// A specific field for batteries. Is the slope of the straight line AC power as a function of DC power. -1 by default.
	float efficiency_intercept;		// A specific field for batteries. Is the intercept of the straight line AC power as a function of DC power. -1 by default.
 }
{t_variable_cost_models} VARIABLE_COST_MODELS = ...; // variable holding VARIABLE_COST_MODELS data

/* MARKET_ENGAGEMENTS */
tuple t_market_engagements {
 	key string type;				// Name of the market (DAY_AHEAD / ELECTRICITY_LONG_TERM_AGREGATED_BIDS  / MFRR_R3 / FCR)
 	key string step_index;          // Step number of the market
 	float engagement;				// Engaged energy or power (in kWh or kW). Positive values mean "buy" or downward service, negative "sell" or upward service
 	float price;					// No longer used (to be removed?)
 	int is_step_cleared;			// flag indicating if engagement is cleared for that market type and that step (1 = cleared / 0 = not cleared)
 }
{t_market_engagements} MARKET_ENGAGEMENTS = ...; // variable holding MARKET_ENGAGEMENTS data

/* MARKET_PRICE_STEPS */
tuple t_market_price_steps {
  key string type;					// (DAY_AHEAD / TRANSPORT)
  key string step_index;			// DAY_AHEAD TYPE will be sampled at : day_ahead_step / TRANSPORT will be sampled at : asset_step
  float price;						// Da price : clearing price/ sourced from market price for the transport
 }
{t_market_price_steps} MARKET_PRICE_STEPS = ...; // variable holding MARKET_PRICE_STEPS data
// Converting this reference to a microgrid name
string microgridName; // this param is filled up in pre-optimisation execute bloc
// indexing set of operation decision steps
{string} isDECISION_STEPS = {osl.asset_step | osl in OPERATION_STEPS_LINK};
// indexing set of mFRR steps
// Will always be : assetassetStepDuration <= mFRRassetStepDuration <= imbalanceassetStepDuration
{string} ismFRR_STEPS = {osl.mfrr_step | osl in OPERATION_STEPS_LINK};
// indexing set of imbalance steps
{string} isIMBALANCE_STEPS = {osl.imbalance_step | osl in OPERATION_STEPS_LINK };
// indexing set of day_ahead steps (hourly)
{string} isHOURLY_STEPS = {osl.day_ahead_step | osl in OPERATION_STEPS_LINK };
// indexing set of fcr steps
{string} isFCR_STEPS = {osl.fcr_step | osl in OPERATION_STEPS_LINK };
// indexing set of afrr capacity steps
{string} isAFRR_CAPACITY_STEPS = {osl.afrr_capacity_step | osl in OPERATION_STEPS_LINK };
// indexing set of afrr voluntary steps
// Equivalent to energy bid step
{string} isAFRR_VOLUNTARY_STEPS = {osl.afrr_voluntary_step | osl in OPERATION_STEPS_LINK };
// indexing set of afrr capacity steps with only positive values
{string} isAFRR_CAPACITY_STEPS_POS = {osl.afrr_capacity_step | osl in OPERATION_STEPS_LINK : osl.afrr_capacity_step !="-1.0" &&  osl.afrr_capacity_step !="-1"};
// indexing set of afrr voluntary steps with only positive values
{string} isAFRR_VOLUNTARY_STEPS_POS = {osl.afrr_voluntary_step | osl in OPERATION_STEPS_LINK : osl.afrr_voluntary_step !="-1.0" &&  osl.afrr_voluntary_step !="-1"};
// indexing set of mFRR steps with only positive values
{string} ismFRR_STEPS_POS = {osl.mfrr_step | osl in OPERATION_STEPS_LINK : osl.mfrr_step !="-1.0" &&  osl.mfrr_step!="-1" };
// indexing set of imbalance steps with only positive values
{string} isIMBALANCE_STEPS_POS = {osl.imbalance_step | osl in OPERATION_STEPS_LINK : osl.imbalance_step !="-1.0" &&  osl.imbalance_step !="-1"};
// indexing set of day_ahead steps (hourly) with only positive values
{string} isHOURLY_STEPS_POS = {osl.day_ahead_step | osl in OPERATION_STEPS_LINK : osl.day_ahead_step !="-1.0" &&  osl.day_ahead_step !="-1"};
// indexing set of fcr steps with only positive values
{string} isFCR_STEPS_POS = {osl.fcr_step | osl in OPERATION_STEPS_LINK : osl.fcr_step !="-1.0" &&  osl.fcr_step !="-1"};
// All assets
// -------------------------------------------
// indexing set of all microgrid assets (incl. sites)
{string} isASSETS = {a.asset_id | a in ASSETS};
// indexing set of assets that consume or generate electricity
// HARD-CODED
//{t_assets} E_ASSETS = {a | a in ASSETS: a.energies_in == "ELEC" || a.energies_out == "ELEC" || a.energies_out == "ELEC+HEAT"};
{t_assets} E_ASSETS = (
	microgridName == "MICROGRID MOPABLOEM"
	? ASSETS inter {a | a in ASSETS:
		a.asset_id == "E_boiler_1000kW" ||
		a.asset_id == "E_boiler_1200kW" ||
		a.asset_id == "Load_1" ||
		a.asset_id == "Load_2" ||
		a.asset_id == "CHP_1600kW" ||
		a.asset_id == "PV_150kW" ||
		a.asset_id == "PV_700kW" ||
		a.asset_id == "BESS_MOPABLOEM" ||
		a.asset_id == "dummy_congestion_asset"
		}
	: microgridName == "MICROGRID GP Brielle"
	? ASSETS inter {a | a in ASSETS:
		a.asset_id == "GP_BRIELLE_EBOILER" ||
		a.asset_id == "GP_BRIELLE_BUILDINGS" ||
		a.asset_id == "GP_BRIELLE_LIGHTS" ||
		a.asset_id == "GP_BRIELLE_CHP" ||
		a.asset_id == "GP_BRIELLE_BESS" ||
		a.asset_id == "dummy_congestion_asset"
		}
	: microgridName == "MICROGRID GP Vierpolders"
	? ASSETS inter {a | a in ASSETS:
		a.asset_id == "GP_VIERPOLDERS_EBOILER" ||
		a.asset_id == "GP_VIERPOLDERS_BUILDINGS" ||
		a.asset_id == "GP_VIERPOLDERS_CHP" ||
		a.asset_id == "GP_VIERPOLDERS_LIGHTS_1200" ||
		a.asset_id == "GP_VIERPOLDERS_LIGHTS_860" ||
		a.asset_id == "dummy_congestion_asset"
		}
	: microgridName == "MICROGRID VERBERNE America"
	? ASSETS inter {a | a in ASSETS:
		a.asset_id == "Verberne_America_CHP1" ||
		a.asset_id == "Verberne_America_CHP2" ||
		a.asset_id == "Verberne_America_Heatpump_1" ||
		a.asset_id == "Verberne_America_Heatpump_2" ||
		a.asset_id == "Verberne_America_Heatpump_3" ||
		a.asset_id == "Verberne_America_Heatpump_4" ||
		a.asset_id == "Verberne_America_Load" ||
		a.asset_id == "Verberne_America_PV1" ||
		a.asset_id == "dummy_congestion_asset"
		}	: ASSETS
	);
{string} isE_ASSETS = {a.asset_id | a in E_ASSETS};
// indexing set of assets that consume or generate heat
// HARD-CODED
//{t_assets} H_ASSETS = {a | a in ASSETS: a.energies_in == "HEAT" || a.energies_out == "HEAT" || a.energies_out == "ELEC+HEAT"};
{t_assets} H_ASSETS = (
	microgridName == "MICROGRID MOPABLOEM"
	? ASSETS inter {a | a in ASSETS:
		a.asset_id == "Heat_consumption" ||
		a.asset_id == "Buffer_850m3" ||
		a.asset_id == "CHP_1600kW" ||
		a.asset_id == "E_boiler_1000kW" ||
		a.asset_id == "E_boiler_1200kW"
		}
	: microgridName == "MICROGRID GP Brielle"
	? ASSETS inter {a | a in ASSETS:
		a.asset_id == "GP_BRIELLE_HEAT_NEED" ||
		a.asset_id == "GP_BRIELLE_HEAT_STORAGE" ||
		a.asset_id == "GP_BRIELLE_CHP" ||
		a.asset_id == "GP_BRIELLE_EBOILER"
		}
	: microgridName == "MICROGRID GP Vierpolders"
	? ASSETS inter {a | a in ASSETS:
		a.asset_id == "GP_VIERPOLDERS_HEAT_NEED" ||
		a.asset_id == "GP_VIERPOLDERS_HEAT_STORAGE" ||
		a.asset_id == "GP_VIERPOLDERS_CHP" ||
		a.asset_id == "GP_VIERPOLDERS_EBOILER"
		}
	: microgridName == "MICROGRID VERBERNE America"
	? ASSETS inter {a | a in ASSETS:
		a.asset_id == "Verberne_America_CHP1" ||
		a.asset_id == "Verberne_America_CHP2" ||
		a.asset_id == "Verberne_America_HeatBuffer" ||
		a.asset_id == "Verberne_America_Heat_Need" ||
		a.asset_id == "Verberne_America_Heatpump_1" ||
		a.asset_id == "Verberne_America_Heatpump_2" ||
		a.asset_id == "Verberne_America_Heatpump_3" ||
		a.asset_id == "Verberne_America_Heatpump_4"
		}	: {}
	);
// a tuple containing, as an id, the type of operation (charge/discharge), and the default model ID used for piecewise linearising  of the battery efficiency (battery power)
// NB: this tuple is used for microgrids with a constant efficiency
// NB: the advantage of using this tuple is to have the charge/discharge efficiency and the maximum charge/discharge power according to the type of battery operation (charge/discharge).
// NB: this tuple will be removed when the battery efficiency linearisation is automated on the Everest side.
tuple store_op_types {
    key string op_id;
}

{store_op_types} STORE_OPERATION_TYPES = {<"CHARGE">, <"DISCHARGE">};
// indexing of Storage operation
{string} isSTORE_OPERATION_TYPES = {o.op_id | o in STORE_OPERATION_TYPES};
{string} isH_ASSETS = {a.asset_id | a in H_ASSETS};
// indexing set of assets that consume or generate electricity and heat
{string} isEH_ASSETS = isE_ASSETS inter isH_ASSETS;
// Flexible loads (in this model we only model energy or energies consumed by these assets)
// -------------------------------------------
// indexing set of flexible load units
{string} isFLEX_LOADS = {a.asset_id | a in ASSETS: a.type == "FLEX_LOAD"};
// indexing set of flexible elec load units
{string} isFLEX_E_LOADS = isFLEX_LOADS inter isE_ASSETS;
// indexing set of flexible heat load units
{string} isFLEX_H_LOADS = isFLEX_LOADS inter isH_ASSETS;
// indexing set of flexible elec and heat load units
{string} isFLEX_EH_LOADS = isFLEX_E_LOADS inter isFLEX_H_LOADS;
// Intermittent generation assets (in this model we only model energy or energies generated by these assets)
// -------------------------------------------
// indexing set of intermittent generation assets
{string} isINTER_GENS = {a.asset_id | a in ASSETS: a.type == "INTERMITTENT"};
// indexing set of intermittent elec generation assets
{string} isINTER_E_GENS = isINTER_GENS inter isE_ASSETS;
// indexing set of intermittent heat generation assets
{string} isINTER_H_GENS = isINTER_GENS inter isH_ASSETS;
// indexing set of intermittent elec and heat generation assets
{string} isINTER_EH_GENS = isINTER_E_GENS inter isINTER_H_GENS;
// Dispatchable generation assets (in this model we only model energy or energies generated by these assets)
// -------------------------------------------
// indexing set of dispatchable generation assets
{string} isDISP_GENS = {a.asset_id | a in ASSETS: a.type == "GENERATOR"};
// indexing set of dispatchable elec generation assets
{string} isDISP_E_GENS = isDISP_GENS inter isE_ASSETS;
// indexing set of dispatchable heat generation assets
{string} isDISP_H_GENS = isDISP_GENS inter isH_ASSETS;
// indexing set of dispatchable elec & heat generation assets
{string} isDISP_EH_GENS = isDISP_E_GENS inter isDISP_H_GENS;
// Storage assets (in this model we model energy or energies consumed and generated by these assets and energy type(s) in = energy type(s) out)
// -------------------------------------------
// indexing set of energy storage assets
{string} isSTORAGES = {a.asset_id | a in ASSETS: a.type == "STORAGE"};
// indexing set of elec energy storage assets
{string} isE_STORAGES = isSTORAGES inter isE_ASSETS;
// indexing set of heat energy storage assets
{string} isH_STORAGES = isSTORAGES inter isH_ASSETS;
// indexing set of elec and heat energy storage assets
{string} isEH_STORAGES = isE_STORAGES inter isH_STORAGES;
// Non-flexible loads (in this model we only model energy or energies consumed by these assets)
// -------------------------------------------
// indexing set of non-flexible loads
{string} isNF_LOADS = microgridName == "MICROGRID MOPABLOEM" ?
						{a.asset_id | a in ASSETS: a.type == "LOAD" && a.asset_id != "E_boiler_1000kW" && a.asset_id != "E_boiler_1200kW"}
						: microgridName == "MICROGRID GP Brielle" ?
						{a.asset_id | a in ASSETS: a.type == "LOAD" && a.asset_id != "GP_BRIELLE_EBOILER"}
						: microgridName == "MICROGRID GP Vierpolders" ?
						{a.asset_id | a in ASSETS: a.type == "LOAD" && a.asset_id != "GP_Vierpolders_EBOILER"}
						: microgridName == "MICROGRID VERBERNE America" ?
						{a.asset_id | a in ASSETS: a.type == "LOAD" && a.asset_id != "Verberne_America_Heatpump_1" && a.asset_id != "Verberne_America_Heatpump_2" && a.asset_id != "Verberne_America_Heatpump_3" && a.asset_id != "Verberne_America_Heatpump_4"}
						: {a.asset_id | a in ASSETS: a.type == "LOAD"};
// indexing set of non-flexible elec loads
{string} isNF_E_LOADS = isNF_LOADS inter isE_ASSETS;
// indexing set of non-flexible heat loads
{string} isNF_H_LOADS = isNF_LOADS inter isH_ASSETS;
// Energy conversion assets (in this model we model energy or energies consumed and generated by these assets and energy type(s) in != energy type(s) out)
// -------------------------------------------
// indexing set of energy conversion assets
// HARD-CODED
//{string} isCONVS = {a.asset_id | a in ASSETS: a.type == "CONV"};
{string} isCONVS = microgridName == "MICROGRID MOPABLOEM" ? 
				    isASSETS inter {"E_boiler_1000kW", "E_boiler_1200kW"}
				    : microgridName == "MICROGRID GP Brielle" ? 
				    isASSETS inter {"GP_BRIELLE_EBOILER"}
				    : microgridName == "MICROGRID GP Vierpolders" ? 
				    isASSETS inter {"GP_VIERPOLDERS_EBOILER"}
				    : microgridName == "MICROGRID VERBERNE America" ? 
				    isASSETS inter {"Verberne_America_Heatpump_1", "Verberne_America_Heatpump_2", "Verberne_America_Heatpump_3", "Verberne_America_Heatpump_4"}
					: {};
// indexing set of assets converting elec into some other type of energy
// HARD-CODED
//{string} isEIN_CONVS = isCONVS inter {a.asset_id | a in ASSETS: a.energies_in == "ELEC"};
{string} isEIN_CONVS = microgridName == "MICROGRID MOPABLOEM" ? 
					isASSETS inter {"E_boiler_1000kW", "E_boiler_1200kW"}
					: microgridName == "MICROGRID GP Brielle" ? 
				    isASSETS inter {"GP_BRIELLE_EBOILER"}
				    : microgridName == "MICROGRID GP Vierpolders" ? 
				    isASSETS inter {"GP_VIERPOLDERS_EBOILER"} 
				    : microgridName == "MICROGRID VERBERNE America" ? 
				    isASSETS inter {"Verberne_America_Heatpump_1", "Verberne_America_Heatpump_2", "Verberne_America_Heatpump_3", "Verberne_America_Heatpump_4"}
					: {};
// indexing set of assets converting some type of energy into heat
// HARD-CODED
//{string} isHOUT_CONVS = isCONVS inter {a.asset_id | a in ASSETS: a.energies_out == "HEAT" || a.energies_out == "ELEC+HEAT"};
{string} isHOUT_CONVS = microgridName == "MICROGRID MOPABLOEM" ? 
					isASSETS inter {"E_boiler_1000kW", "E_boiler_1200kW"}
					: microgridName == "MICROGRID GP Brielle" ? 
				    isASSETS inter {"GP_BRIELLE_EBOILER"}
				    : microgridName == "MICROGRID GP Vierpolders" ? 
				    isASSETS inter {"GP_VIERPOLDERS_EBOILER"} 
				    : microgridName == "MICROGRID VERBERNE America" ? 
				    isASSETS inter {"Verberne_America_Heatpump_1", "Verberne_America_Heatpump_2", "Verberne_America_Heatpump_3", "Verberne_America_Heatpump_4"}
					: {};
// indexing set of assets converting elec into heat
{string} isE_H_CONVS = isEIN_CONVS inter isHOUT_CONVS;
// indexing set of assets converting heat into some other type of energy
// HARD-CODED
//{string} isHIN_CONVS = isCONVS inter {a.asset_id | a in ASSETS: a.energies_in == "HEAT"};
{string} isHIN_CONVS = {};
// indexing set of assets converting some type of energy into elec
// HARD-CODED
//{string} isEOUT_CONVS = isCONVS inter {a.asset_id | a in ASSETS: a.energies_out == "ELEC" || a.energies_out == "ELEC+HEAT"};
{string} isEOUT_CONVS = {};
// indexing set of assets converting heat into elec
{string} isH_E_CONVS = isHIN_CONVS inter isEOUT_CONVS;
// indexing set of sites
// -------------------------------------------
{string} isSITES = {a.asset_id | a in ASSETS: a.type == "SITE"};
// indexing sets of assets by types of control
// -------------------------------------------
// indexing set of elec assets controled by power targets
{string} isPC_E_ASSETS = {a.asset_id | a in E_ASSETS: a.control == "POWER"};
// indexing set of elec assets controled by temperature targets
{string} isTC_E_ASSETS = {a.asset_id | a in E_ASSETS: a.control == "TEMPERATURE"};
// indexing set of flexible elec load units controled by power targets
{string} isPC_FLEX_E_LOADS = isFLEX_E_LOADS inter isPC_E_ASSETS;
// indexing set of flexible elec load units controled by temperature targets
{string} isTC_FLEX_E_LOADS = isFLEX_E_LOADS inter isTC_E_ASSETS;
// Other indexing sets
// -------------------------------------------
// indexing set of non-linear variable cost models
{string} isVAR_COST_MODELS = {cm.model_id | cm in VARIABLE_COST_MODELS};
// indexing set of non-linear storage charge efficiency model
// indexing set of network congestions
{string} isCONGESTIONS = {c.congestion_id | c in CONGESTIONS};
// indexing set of assets that have non-zero default current potential
{string} isDEFAULT_CURRENT_ASSET = {a.asset_id | a in E_ASSETS: a.injection_current_potential > 0};
// indexing set of elec generation assets with linear variable costs
{string} isLIN_COST_E_GENS = {a.asset_id | a in E_ASSETS: a.variable_cost > 0};
// indexing set of elc generation assets with non-linear variable costs
{string} isNL_COST_E_GENS = {a.asset_id | a in E_ASSETS: a.var_cost_model != "-1.0" && a.var_cost_model != "-1"};
// indexing set of elec intermittent generation assets with curtailment compensation costs
{string} isCURT_COMP_E_GENS = {a.asset_id | a in E_ASSETS: a.compensation_cost > 0};
// indexing set of dispatchable elec generation assets with startup costs
{string} isSTART_COST_E_GENS = {a.asset_id | a in E_ASSETS: a.startup_cost > 0};
// indexing set of assets subject to elec power ramp rates
{string} isRR_E_ASSETS = {a.asset_id | a in E_ASSETS: a.max_ramp_rate > 0};
// indexing set of assets that have a max time on > 0.
{string} isMAX_TIME_ON_GENS = {a.asset_id | a in E_ASSETS: a.max_time_on > 0};
// indexing set of assets that have a min time on > 0.
{string} isMIN_TIME_ON_GENS = {a.asset_id | a in E_ASSETS: a.min_time_on > 0};
// indexing set of microgrid assets operating in grid forming mode
// {string} isGRID_FORM = {a.asset_id | a in ASSETS: a.operating_mode == "GRID_FORMING"};
// HARD-CODED
{string} isGRID_FORM = (
	microgridName == "MICROGRID TPL Tongatapu"
	? isASSETS inter {"Tongatapu_Popua_GE1", "Tongatapu_Popua_GE2", "Tongatapu_Popua_GE3",
					"Tongatapu_Popua_GE4", "Tongatapu_Popua_GE5", "Tongatapu_Popua_GE6", "Tongatapu_Popua_GE7",
					"Tongatapu_Popua_BESS", "Tongatapu_Dummy_for_FAT1_BESS"}
	: {}
	);
// indexing set of microgrid assets operating in grid following mode
// {string} isGRID_FOLL = {a.asset_id | a in ASSETS: a.operating_mode == "GRID_FOLLOWING"};
{string} isGRID_FOLL = (
	microgridName == "MICROGRID TPL Tongatapu"
	? isASSETS inter {"Tongatapu_Popua_GE8", "Tongatapu_Popua_GE9", "Tongatapu_Matatoa_BESS"}
	: {}
	);
// indexing set of microgrid assets operating in grid tie mode
// {string} isGRID_TIED = {a.asset_id | a in ASSETS: a.operating_mode == "GRID_TIED"};
{string} isGRID_TIED = isE_ASSETS diff (isGRID_FORM union isGRID_FOLL union isSITES);

// indexing set of microgrid assets participating in FCR
// {string} isFCR_ASSETS = {a.asset_id | a in E_ASSETS: a.fcr_certifiate_power > 0};
{string} isFCR_ASSETS = (
	microgridName == "MICROGRID VALOREM LIMOUX"
	? isE_ASSETS inter {"VALOREM_Limoux_BESS"}
	: {}
	);
// indexing set of microgrid assets participating in aFRR up
// {string} isaFRRUp_ASSETS = {a.asset_id | a in E_ASSETS: a.afrr_up_certifiate_power > 0};
{string} isaFRRUp_ASSETS = (
	microgridName == "MICROGRID MOPABLOEM"
	? isE_ASSETS inter {"BESS_MOPABLOEM","CHP_1600kW"}
	: {}
	);
// indexing set of microgrid assets participating in aFRR down
// {string} isaFRRDwn_ASSETS = {a.asset_id | a in E_ASSETS: a.afrr_dwn_certifiate_power > 0};
{string} isaFRRDwn_ASSETS = (
	microgridName == "MICROGRID MOPABLOEM"
	? isE_ASSETS inter {"E_boiler_1200kW","E_boiler_1000kW"}
	: {}
	);
// site id to wich the asset a is connected
{string} siteIdByAsset[isASSETS] = [a.asset_id:{a.site}| a in ASSETS];
// asset ids that connected to the site s
{string} assetIdsBySite[s in isSITES] = {a.asset_id | a in ASSETS: s == a.site};
/*********************************************************************
 * Model parameters (input data)
 *********************************************************************/
float epsilon = 0.00001;
// Reference to Everest's microgrid operation 
string operationID = first({o.param_val | o in OPERATION: o.param_id == "operation_id"});
string optimisationRequestTime = first({o.param_val | o in OPERATION: o.param_id == "optimisation_request_time"});
string optimisationIntervalStartTime = first({o.param_val | o in OPERATION: o.param_id == "optimisation_interval_start"});
// number of assets that can be used in optimisation
int assetNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "asset_number"}));
// time limit for optimisation (expressed in minutes)
float maxOptimisationTime = floatValue(first({o.param_val | o in OPERATION: o.param_id == "max_optimisation_time"}));
// number of decision steps
int optimisationStepNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "optimisation_step_number"}));
// number of mFRR steps (NOT USED, to be deleted?)
int mFRRStepNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "mfrr_step_number"}));
// number of imbalance steps (NOT USED, to be deleted?)
int imbStepNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "imbalance_step_number"}));
// number of day-ahead steps (NOT USED, to be deleted?)
int da_StepNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "day_ahead_step_number"}));
// Number of FCR steps (NOT USED, to be deleted?)
int fcrStepNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "fcr_step_number"}));
// Number of aFRR capacity steps (NOT USED, to be deleted?)
int aFRRCapacityStepNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "afrr_capacitiy_step_number"}));
// duration (expressed in minutes) of affr capacity step
// MUST be expressed as a whole number of minutes (int) b/c is used in the defintion of a range
int afrrCapacityStepDuration = intValue(first({o.param_val | o in OPERATION: o.param_id == "afrr_capacitiy_step_duration"}));
// duration (expressed in hours) of afrr_capacity_step_duration ()
float afrrCapacityStepDurationInHours = afrrCapacityStepDuration / 60.0;
// Number of aFRR voluntary steps (NOT USED, to be deleted?)
int aFRRVoluntaryStepNumber = intValue(first({o.param_val | o in OPERATION: o.param_id == "afrr_voluntary_step_number"}));
// duration (expressed in minutes) of affr voluntary step
// MUST be expressed as a whole number of minutes (int) b/c is used in the defintion of a range
int afrrVoluntaryStepDuration = intValue(first({o.param_val | o in OPERATION: o.param_id == "afrr_voluntary_step_duration"}));
// duration (expressed in hours) of afrr_voluntary_step_duration ()
float afrrVoluntaryStepDurationInHours = afrrVoluntaryStepDuration / 60.0;
// duration (expressed in minutes) of decision step t (t in DECISION_STEPS)
// MUST be expressed as a whole number of minutes (int) b/c is used in the defintion of a range
int assetStepDuration = intValue(first({o.param_val | o in OPERATION: o.param_id == "asset_step_duration"}));
// duration (expressed in minutes) of mFRR step mfrr (mfrr in ismFRR_STEPS)
// MUST be expressed as a whole number of minutes (int) b/c is used in the defintion of a range
int mFRRStepDuration = intValue(first({o.param_val | o in OPERATION: o.param_id == "mfrr_step_duration"}));
// duration (expressed in minutes) of imbalance step imb (imb in isIMBALANCE_STEPS)
// MUST be expressed as a whole number of minutes (int) b/c is used in the defintion of a range
int imbStepDuration = intValue(first({o.param_val | o in OPERATION: o.param_id == "imbalance_step_duration"}));
// duration (expressed in minutes) of day ahead step
// MUST be expressed as a whole number of minutes (int) b/c is used in the defintion of a range
int daStepDuration = intValue(first({o.param_val | o in OPERATION: o.param_id == "day_ahead_step_duration"}));
// duration (expressed in minutes) of fcr step
// MUST be expressed as a whole number of minutes (int) b/c is used in the defintion of a range
int fcrStepDuration = intValue(first({o.param_val | o in OPERATION: o.param_id == "fcr_step_duration"}));
float assetStepDurationInHours = assetStepDuration / 60.0;
// duration (expressed in hours) of day ahead step
float daStepDurationInHours = daStepDuration / 60.0;
// duration (expressed in hours) of mFRR step mfrr (mfrr in ismFRR_STEPS)
float mFRRStepDurationInHours = mFRRStepDuration / 60.0;
// duration (expressed in hours) of fcr_step_duration (fcr in isfcr_STEPS)
float fcrStepDurationInHours = fcrStepDuration / 60.0;
// duration (expressed in hours) of mFRR step mfrr (mfrr in ismFRR_STEPS)
//float mFRRStepDurationInHours[t in isDECISION_STEPS] = ;
float imbStepDurationInHours = imbStepDuration / 60.0;
// mFRR step index in asset_step reference frame
string assetStepmFRRStep[isDECISION_STEPS] = [t.asset_step : t.mfrr_step | t in OPERATION_STEPS_LINK];
// imbalance step index in asset_step reference frame
string assetStepImbalanceStep[isDECISION_STEPS] = [t.asset_step : t.imbalance_step | t in OPERATION_STEPS_LINK];
// hourly step index in asset_step reference frame
string assetStepHourlyStep[isDECISION_STEPS] = [t.asset_step : t.day_ahead_step | t in OPERATION_STEPS_LINK];
// fcr index in asset_step reference frame
string assetStepFCRStep[isDECISION_STEPS] = [t.asset_step : t.fcr_step | t in OPERATION_STEPS_LINK];
// imbalance step index in mFRR_step reference frame
string mFRRStepImbalanceStep[ismFRR_STEPS] = [mfrr.mfrr_step : mfrr.imbalance_step | mfrr in OPERATION_STEPS_LINK];
// hourly step index in mFRR_step reference frame
string mFRRStepHourlyStep[ismFRR_STEPS] = [mfrr.mfrr_step : mfrr.day_ahead_step | mfrr in OPERATION_STEPS_LINK];
// fcr index in mFRR_step reference frame
string mFRRStepFCRStep[ismFRR_STEPS] = [mfrr.mfrr_step : mfrr.fcr_step | mfrr in OPERATION_STEPS_LINK];
// hourly step index in imbalance_step reference frame
string imbStepHourlyStep[isIMBALANCE_STEPS] = [imb.imbalance_step : imb.day_ahead_step | imb in OPERATION_STEPS_LINK];
// fcr index in imbalance_step reference frame
string imbStepFCRStep[isIMBALANCE_STEPS] = [imb.imbalance_step : imb.fcr_step | imb in OPERATION_STEPS_LINK];
// fcr index in day-ahead_step reference frame
string hourlyStepFCRStep[isHOURLY_STEPS] = [h.day_ahead_step : h.fcr_step | h in OPERATION_STEPS_LINK];
// afrr voluntary index in asset_step reference frame
string assetStepAfrrVoluntaryStep[isDECISION_STEPS] = [t.asset_step : t.afrr_voluntary_step | t in OPERATION_STEPS_LINK];
// afrr capacity index in afrr_voluntary_step reference frame
string voluntaryAfrrStepCapacityStep[isAFRR_VOLUNTARY_STEPS] = [afrr.afrr_voluntary_step : afrr.afrr_capacity_step | afrr in OPERATION_STEPS_LINK];
// imbalance index in afrr_voluntary_step reference frame
string voluntaryAfrrStepImbalanceStep[isAFRR_VOLUNTARY_STEPS] = [afrr.afrr_voluntary_step : afrr.imbalance_step | afrr in OPERATION_STEPS_LINK];
// number of optim steps in a 24-hour day
int stepsNumberInADay[t in isDECISION_STEPS] = ftoi(24 / assetStepDurationInHours) ;
// optim step indexes
int stepIndex[isDECISION_STEPS] = [t.step_id : ord(isDECISION_STEPS, t.step_id) | t in OPERATION_STEPS];
// maximum power export out of the microgrid into the main grid (expressed in kW)
float maxExportCapacity[isDECISION_STEPS] = [t.step_id : t.max_export_to_main_grid | t in OPERATION_STEPS];
// maximum power import into the microgrid from the main grid (expressed in kW)
float maxImportCapacity[isDECISION_STEPS] = [t.step_id : t.max_import_from_main_grid | t in OPERATION_STEPS];
// last minute intermittent generation curtailment option (1 means option is active / 0 means it is not)
int lastMinuteCurtOption = intValue(first({o.param_val | o in OPERATION: o.param_id == "avoid_anticipated_curtailment"}));
// requirement in default current injection (in A)
float defaultCurrentRequirement = floatValue(first({o.param_val | o in OPERATION: o.param_id == "default_current_req"}));
// number of power segments for each non-linear variable cost model (used in definitions of non-linear variable cost model constraints)
int varCostModelSegNumber[isVAR_COST_MODELS] = [cm : maxl(0, max(vc in VARIABLE_COST_MODELS: vc.model_id == cm) vc.power_interval_nbr) | cm in isVAR_COST_MODELS];
// number of power segments for largest non-linear variable cost model (used in declarations of non-linear variable cost model variables and constraints)
int maxSegNbr = maxl(0, max(cm in isVAR_COST_MODELS) varCostModelSegNumber[cm]);
// upper limit (in kW) of power segment s in cost model cm
float varCostSegUpLim[isVAR_COST_MODELS][1..maxSegNbr] = [s.model_id : [s.power_interval_nbr : s.upper_limit] | s in VARIABLE_COST_MODELS];
// marginal cost (in currency unit/kWh) associated with segment s in cost model cm
float varCostSegCost[isVAR_COST_MODELS][1..maxSegNbr] = [s.model_id : [s.power_interval_nbr : s.marginal_cost] | s in VARIABLE_COST_MODELS];
// assets startup costs (expressed in currency unit) (a in ASSETS)
float assetStartupCost[isASSETS] = [a.asset_id : a.startup_cost | a in ASSETS];
// startup costs for dispatchable generators d (expressed in currency unit) (d in isSTART_COST_E_GENS)
float dispGenStartupCost[d in isSTART_COST_E_GENS] = assetStartupCost[d];
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
// profiled tax (expressed in currency unit / kWh) on drawing electricity from main grid at decision step t
// (t in DECISION_STEPS)
float profiledNetworkDrawingTax[isDECISION_STEPS] = [p.step_index : p.price | p in MARKET_PRICE_STEPS : p.type == "TRANSPORT"];
// tax on drawing electricity from main grid (expressed in currency unit per kWh)
// HARD-CODED
float networkDrawingTax[t in isDECISION_STEPS] =
(
	microgridName == "Microgrid Srisangtham Microgrid"
		? 3.0
		: (
		microgridName == "VidoFleur Scheduled Assets"
			? 0.045
			: profiledNetworkDrawingTax[t]));
// assets real-time maximum power (dynamic data from telemetry)
float powerMax[isASSETS] = [a.asset_id : a.max_power | a in ASSETS];
// assets nominal maximum power (static data from configuration)
// HARD-CODED for various microgrids in pre-optimisation processing script (see CPX_PARAM) while input from Everest is not available
float nomPowerMax[a in isASSETS] = powerMax[a];
// assets real-time minimum power (from telemetry)
float powerMin[isASSETS] = [a.asset_id : a.min_power | a in ASSETS];
// assets nominal minimum power (static data from configuration)
// HARD-CODED for various microgrids in pre-optimisation processing script (see CPX_PARAM) while input from Everest is not available
float nomPowerMin[a in isASSETS] = powerMin[a];
// asset's non-linear cost model ID
string assetVarCostModelId[isASSETS] = [a.asset_id : a.var_cost_model | a in ASSETS];
// asset's non-linear efficiency model id
string assetVarEffModelId[isASSETS] = [a.asset_id : a.var_efficiency_model | a in ASSETS];
// generator's variable cost model id
string genVarCostModelId[g in isNL_COST_E_GENS] = assetVarCostModelId[g];
// asset storage's variable efficiency model id
string storageVarEffModelId[s in isSTORAGES] = (assetVarEffModelId[s] == "-1" || assetVarEffModelId[s] == "-1.0" ? s : assetVarEffModelId[s]);
// initial level of power input/output (expressed in kW) for asset a before the beginning of decision step 1
// positive values mean power output, negative values mean power input
float initialPower[isASSETS] = [a.asset_id : -a.initial_power | a in ASSETS];
// active power floor under which asset is conseidered to be off (in kW)
float onStateTolerance[isASSETS] = [a.asset_id : a.power_tolerance | a in ASSETS];
// dispatchable generator initial state
// 0 means it was off, 1 it was on
int genInitialState[d in isDISP_E_GENS] = initialPower[d] <= onStateTolerance[d] ? 0 : 1;
// dispatchable generator initial power (expressed in kW)
// If the initial power is negative for generation asset, it mays mean that it is due to its auxiliaries' consumption. Then we set genInitialPower to zero, otherwise it will cause issues.
float genInitialPower[d in isDISP_E_GENS] = initialPower[d] <= onStateTolerance[d] ? 0 : initialPower[d];
// maximum ramp rate (expressed in W/min) for asset a
float maxRampRate[isASSETS] = [a.asset_id : a.max_ramp_rate | a in ASSETS];
// maximum ramp rate (expressed in kW/hour) for asset a
float maxRampRateInkWperH[a in isASSETS] = (maxRampRate[a] >= 0.0 ? maxRampRate[a] / 1000.0 * 60.0 : -1.0);
// minimum time each asset can continuously generate / consume for (expressed in minutes)
int  minTimeOn[isASSETS] = [a.asset_id : a.min_time_on | a in ASSETS];
// minimum number of steps each dispatchable generator can continuously generate for
int dispGenMinStepsOn[d in isDISP_E_GENS] = ftoi(ceil(minTimeOn[d] / assetStepDuration));
// maximum time each asset can continuously generate / consume for (expressed in minutes)
int maxTimeOn[isASSETS] = [a.asset_id : a.max_time_on | a in ASSETS];
int dispGenMaxStepsOn[d in isDISP_E_GENS] = ftoi(floor(maxTimeOn[d] / assetStepDuration));
// minimum recovery time (expressed in minutes) between two continuous generation / consumption from each asset
int minRecoveryTime[isASSETS] = [a.asset_id : a.min_recovery_period | a in ASSETS];
// minimum recovery time (expressed in number os steps) between two continuous generation from each dispatchable gen
int genMinRecoverySteps[d in isDISP_E_GENS] = ftoi(ceil(minRecoveryTime[d] / assetStepDuration));
// time (expressed in minutes) each asset has been continuously on before the beginning of decision step 1
int initialTimeOn[isASSETS] = [a.asset_id : a.initial_time_on | a in ASSETS];
// number of time steps each dispatchable generator has been continuously on before the beginning of decision step 1
int genInitialStepsOnMax[d in isDISP_E_GENS] = ftoi(ceil(initialTimeOn[d] / assetStepDuration));
int maxGenInitialStepsOnMax = maxl(1, max(d in isDISP_E_GENS) genInitialStepsOnMax[d]);
range rgInitialStepOffset = 0..(maxGenInitialStepsOnMax-1);
int genInitialStepsOnMin[d in isDISP_E_GENS] = ftoi(floor(initialTimeOn[d] / assetStepDuration));
// time (expressed in minutes) each asset has been continuously off before the beginning of decision step 1
int initialTimeOff[isASSETS] = [a.asset_id : a.initial_time_off | a in ASSETS];
// number of time steps each dispatchable generator has been continuously off before the beginning of decision step 1
int genInitialStepsOff[d in isDISP_E_GENS] = ftoi(floor(initialTimeOff[d] / assetStepDuration));
// Asset availability of asset a over decision step t
float availability[isASSETS][isDECISION_STEPS] = [as.asset_id : [as.step_id : as.availability] | as in ASSET_STEPS];
// All or nothing availability
// 0: asset a is not available during decision step t
// 1: asset a is available during decision step t
int heatStorAvail[s in isH_STORAGES][t in isDECISION_STEPS] = (availability[s][t] == 1.0 ? 1 : 0 );
int dispGenAvail[d in isDISP_GENS][t in isDECISION_STEPS] = (availability[d][t] == 1.0 ? 1 : 0 );
int flexLoadAvail[f in isFLEX_LOADS][t in isDECISION_STEPS] = (availability[f][t] == 1.0 ? 1 : 0 );
int convAvail[c in isCONVS][t in isDECISION_STEPS] = (availability[c][t] == 1.0 ? 1 : 0 );
// Partial availability
// availability = % of availability for asset a over decision step t
float storAvail[s in isE_STORAGES][t in isDECISION_STEPS] = (availability[s][t] == -1.0 ? 0.0 : 100.0 * availability[s][t]);
float NFLoadAvail[n in isNF_LOADS][t in isDECISION_STEPS] = (availability[n][t] == -1.0 ? 0.0 : 100.0 * availability[n][t]);
float interGenAvail[i in isINTER_GENS][t in isDECISION_STEPS] = (availability[i][t] == -1.0 ? 0.0 : 100.0 * availability[i][t]);
// maximum and minimum power generation (expressed in kW) possible for intermittent generation asset i (i in INTER_E_GENS)
// accounts for partial availability of asset i over decisions step t
float maxInterGenActivePower[i in isINTER_E_GENS][t in isDECISION_STEPS] = -powerMin[i] * interGenAvail[i][t] / 100.0;
float minInterGenActivePower[i in isINTER_E_GENS][t in isDECISION_STEPS] = -powerMax[i] * interGenAvail[i][t] / 100.0;
// maximum power generation (expressed in kW) physically possible for dispatchable generation asset d (d in DISP_E_GENS)
float maxDispGenActivePower[d in isDISP_E_GENS] = -powerMin[d];
// minimum power generation (expressed in kW) economically possible for dispatchable generation asset d (d in DISP_E_GENS)
float minDispGenActivePower[d in isDISP_E_GENS] = -powerMax[d];
// minimum power generation (expressed in kW) physically possible for dispatchable generation asset d (d in DISP_E_GENS)
float physMinDispGenActivePower[d in isDISP_E_GENS] = minl(5.0, minDispGenActivePower[d]);
// maximum and minimum heat consumption (expressed in kW) for non-flexible heat load n (n in NF_E_LOADS)
float maxNFHeatLoad[n in isNF_H_LOADS] = powerMax[n];
float minNFHeatLoad[n in isNF_H_LOADS] = powerMin[n];
// maximum and minimum power consumption (expressed in kW) for flexible load unit f (f in FLEX_E_LOADS)
float maxFlexLoad[f in isFLEX_E_LOADS] = powerMax[f];
float minFlexLoad[f in isFLEX_E_LOADS] = powerMin[f];
// maximum and minimum power consumption (expressed in kW) for energy converter c (c in CONVS)
float maxConvActivePowerIn[c in isCONVS] = powerMax[c];
float minConvActivePowerIn[c in isCONVS] = powerMin[c];
// maximum power consumption (expressed in kW) for non-flex elec load n over decision step t (s in NF_E_LOADS, t in DECISION_STEPS)
// accounts for partial availability of asset n over decisions step t
float maxNFElecLoad[n in isNF_E_LOADS][t in isDECISION_STEPS] = powerMax[n] * NFLoadAvail[n][t] / 100.0;
// minimum power consumption (expressed in kW) for non-flex elec load n over decision step t (s in NF_E_LOADS, t in DECISION_STEPS)
// accounts for partial availability of asset n over decisions step t
float minNFElecLoad[n in isNF_E_LOADS][t in isDECISION_STEPS] = powerMin[n] * NFLoadAvail[n][t] / 100.0;
// maximum power input / output (expressed in kW) possible for site i (i in SITES)
float maxInput[i in isSITES][t in isDECISION_STEPS] = (
	microgridName == "MICROGRID VALOREM LIMOUX" && card(isASSETS inter {"VALOREM_Limoux_PDL_in"}) > 0
	? maxNFElecLoad["VALOREM_Limoux_PDL_in"][t]
	: powerMax[i]
	);
float maxOutput[i in isSITES][t in isDECISION_STEPS] = (
	microgridName == "MICROGRID VALOREM LIMOUX" && card(isASSETS inter {"VALOREM_Limoux_PDL_out"}) > 0
	? maxNFElecLoad["VALOREM_Limoux_PDL_out"][t]
	: -powerMin[i]
	);
// assets real-time maximum energy (dynamic data from telemetry)
float energyMax[isASSETS] = [a.asset_id : a.max_energy | a in ASSETS];
// assets nominal maximum energy (static data from configuration)
// HARD-CODED for Valorem Limoux in pre-optimisation processing script (see CPX_PARAM) while input from Everest is not available
float nomEnergyMax[a in isASSETS] = energyMax[a];
// maximum DC-side energy capacity (expressed in kWh) for elec storage asset s over decision step t (s in E_STORAGES, t in DECISION_STEPS)
// accounts for partial availability of asset s over decisions step t
float storMaxDCEnergy[s in isE_STORAGES][t in isDECISION_STEPS] = (
	storAvail[s][first(isDECISION_STEPS)] > 0.0
		? minl(nomEnergyMax[s], energyMax[s] / storAvail[s][first(isDECISION_STEPS)] * storAvail[s][t])
		: nomEnergyMax[s] * storAvail[s][t] /100.0
	);
// maximum heat charge (expressed in kWh) possible for heat storage asset s (s in H_STORAGES)
float storMaxHeatCharge[s in isH_STORAGES] = energyMax[s];
// assets initial SOC in %
float initialSOC[isASSETS] = [a.asset_id : a.initial_SOC | a in ASSETS];
// asset final SOC in %
float finalSOCLowerBound[isASSETS] = [a.asset_id : 0.0 | a in ASSETS];
// elec energy (expressed in kWh) initially stored (that is, stored at the beginning of decision step 1) in elec storage asset s (s in E_STORAGES)
float storInitialElecCharge[s in isE_STORAGES] = initialSOC[s] / 100.0 * storMaxDCEnergy[s][first(isDECISION_STEPS)];
// heat energy (expressed in kWh) initially stored (that is, stored at the beginning of decision step 1) in heat storage asset s (s in H_STORAGES)
float storInitialHeatCharge[s in isH_STORAGES] = initialSOC[s] / 100.0 * storMaxHeatCharge[s];
// assets maximum SOC as a %
float SOCMax[isASSETS] = [a.asset_id : a.max_SOC | a in ASSETS];
// assets minimum SOC as a %
float SOCMin[isASSETS] = [a.asset_id : a.min_SOC | a in ASSETS];
// maximum state of charge (expressed as a % of asset's maximum elec energy storage capacity)
// allowed in elec storage asset s over decision step t (s in E_STORAGES, t in DECISION_STEPS)
float storElecMaxSOC[s in isE_STORAGES] = SOCMax[s];
// minimum state of charge (expressed as a % of asset's maximum elec energy storage capacity)
// that should be verified in elec storage asset s over decision step t but that does not justify starting a dispatchable gen (s in E_STORAGES, t in DECISION_STEPS)
float storElecMinSOC[s in isE_STORAGES] = SOCMin[s];
// strict minimum state of charge (expressed as a % of asset's maximum elec energy storage capacity)
// allowed in elec storage asset s over decision step t (s in E_STORAGES, t in DECISION_STEPS)
// HARD-CODED
float storStrictElecMinSOC[s in isE_STORAGES] = (
	   microgridName == "MICROGRID ENERCAL Ile des Pins"
	|| microgridName == "MICROGRID ENERCAL Mare"
	|| microgridName == "MICROGRID TPL Tongatapu" ? 5.0 : storElecMinSOC[s]);
// maximum state of charge (expressed as a % of asset's maximum heat energy storage capacity)
// allowed in heat storage asset s over decision step t (s in H_STORAGES, t in DECISION_STEPS)
float storHeatMaxSOC[s in isH_STORAGES] = SOCMax[s];
// minimum state of charge (expressed as a % of asset's maximum heat energy storage capacity)
// allowed in heat storage asset s over decision step t (s in H_STORAGES, t in DECISION_STEPS)
float storHeatMinSOC[s in isH_STORAGES] = SOCMin[s];
// The maximum number of cycles per day for the asset a
float dailyMaxCycles[isASSETS] = [a.asset_id : a.daily_maximum_number_of_cycles | a in ASSETS];
// The maximum number of cycles per day for the asset storage s ( represents the one half of the maximum number of cycle per day declared by the customer. It is an input from Everest)
float storElecDailyMaxCycles [s in isE_STORAGES] =  (dailyMaxCycles[s] < 0.0 ? -1 : dailyMaxCycles[s]);
// assets nominal number of blocks (static data from configuration)
// HARD-CODED pre-optimisation processing script (see CPX_PARAM) while input from Everest is not available
int nomBlockNbr[isASSETS] = [a.asset_id : 1 | a in ASSETS];
// measured number of healthy blocks for asset a (deduced from ratio between nominal min power and measured min power)
// should be dynamic data from telemetry (soon available in ASSETS table)
int healthyBlockNbr[a in isASSETS] = (abs(nomPowerMin[a]) > 0.0 ? ftoi(round(powerMin[a] / nomPowerMin[a] * nomBlockNbr[a])) : 0);
// The historical number of charging cycles performed by the asset storage s during the step t before  beginning of the opreration optimization (expressed as a ratio of the maximum energy that can be stored in the battery)
// There is a mistake in the calculation in Everest : (Ein + Eout)/Emax, instead of (Ein + Eout)/2*Emax. That's why divide here by two.
float cyclHistory[isASSETS][isDECISION_STEPS] = [as.asset_id : [as.step_id : as.daily_known_cycle_contribution] | as in ASSET_STEPS];
float storElecCyclHistory[s in isE_STORAGES][t in isDECISION_STEPS] = (cyclHistory[s][t] < 0.0 ? 0.0 : cyclHistory[s][t]/2.0);
//asset's site// asset's site
string siteID[isASSETS] = [a.asset_id : a.site | a in ASSETS];
// asset's current injection potential (expressed in A)
float currentInjectionPotential[isASSETS] = [a.asset_id : a.injection_current_potential | a in ASSETS];
// current injection potential (expressed in A) for each dispatchable generator
float dispGenCurrentInjection[d in isDISP_E_GENS] = currentInjectionPotential[d];
// current injection potential (expressed in A) for each intermittent generation asset
float interGenCurrentInjection[i in isINTER_E_GENS] = currentInjectionPotential[i];
// assets variable cost (expressed in currency unit/kWh) (a in E_ASSETS)
float assetVariableCost[isASSETS] = [a.asset_id : a.variable_cost | a in ASSETS];
// variable costs for generation asset with linear costs g (expressed in currency unit) (g in isLIN_COST_E_GENS)
float genVariableCost[g in isLIN_COST_E_GENS] = assetVariableCost[g];
// assets curtailment compensation (expressed in currency unit/kWh) (a in E_ASSETS)
float assetCurtComp[isASSETS] = [a.asset_id : a.compensation_cost | a in ASSETS];
// curtailment compensation for intermittent generation asset i (expressed in currency unit) (i in isCURT_COMP_E_GENS)
float interGenCurtComp[i in isCURT_COMP_E_GENS] = assetCurtComp[i];
// assets curtailment estimation method (a in E_ASSETS)
// "FORECAST_BASED" means curtailed energy is computed as forcast generation - generation target
// "DEFAULT_BASED" means curtailed energy is computed as default max generation - generation target
// "-1" means parameter was not set in Everest (will be treated as DEFAULT_BASED here)
string assetCurtEstimationMethod[isASSETS] = [a.asset_id : a.compensation_model | a in ASSETS];
// curtailment estimation method for intermittent generation asset i (i in isINTER_E_GENS)
string interGenCurtEstimationMethod[i in isINTER_E_GENS] = assetCurtEstimationMethod[i];
// dispatchable generation asset's linear factor of max reactive power approximation as a linear function of active power
float aDispGenQmax[isDISP_E_GENS];
// dispatchable generation asset's constant term of max reactive power approximation as a linear function of active power
float bDispGenQmax[isDISP_E_GENS];
// intermittent generation asset's linear factor of max reactive power approximation as a linear function of active power
float aInterGenQmax[isINTER_E_GENS];
// intermittent generation asset's constant term of max reactive power approximation as a linear function of active power
float bInterGenQmax[isINTER_E_GENS];
// intermittent generation asset's linear factor of min reactive power approximation as a linear function of active power
float aInterGenQmin[isINTER_E_GENS];
// intermittent generation asset's constant term of min reactive power approximation as a linear function of active power
float bInterGenQmin[isINTER_E_GENS];
// flexible load unit's linear factor of max reactive power approximation as a linear function of active power
float aFlexLoadQmax[isFLEX_E_LOADS];
// flexible load unit's constant term of max reactive power approximation as a linear function of active power
float bFlexLoadQmax[isFLEX_E_LOADS];
// flexible load unit's linear factor of min reactive power approximation as a linear function of active power
float aFlexLoadQmin[isFLEX_E_LOADS];
// flexible load unit's constant term of min reactive power approximation as a linear function of active power
float bFlexLoadQmin[isFLEX_E_LOADS];
// non-flexible load unit's linear factor of reactive power approximation as a linear function of active power
float aNFLoadQ[isNF_E_LOADS];
// non-flexible load unit's constant term of reactive power approximation as a linear function of active power
float bNFLoadQ[isNF_E_LOADS];
// storage unit's linear factor of max reactive power approximation as a linear function of active power when storage is discharging
float aStorQmaxOnDisch[isE_STORAGES];
// storage unit's constant term of max reactive power approximation as a linear function of active power when storage is discharging
float bStorQmaxOnDisch[isE_STORAGES];
// storage unit's linear factor of min reactive power approximation as a linear function of active power when storage is discharging
float aStorQminOnDisch[isE_STORAGES];
// storage unit's constant term of min reactive power approximation as a linear function of active power when storage is discharging
float bStorQminOnDisch[isE_STORAGES];
// storage unit's linear factor of max reactive power approximation as a linear function of active power when storage is charging
float aStorQmaxOnCharge[isE_STORAGES];
// storage unit's constant term of max reactive power approximation as a linear function of active power when storage is charging
float bStorQmaxOnCharge[isE_STORAGES];
// storage unit's linear factor of min reactive power approximation as a linear function of active power when storage is charging
float aStorQminOnCharge[isE_STORAGES];
// storage unit's constant term of min reactive power approximation as a linear function of active power when storage is charging
float bStorQminOnCharge[isE_STORAGES];
// fraction of asset's active power used to define spinning raise reserve requirements
// HARD-CODED
//float assetSpinRaiseReserveReq[isASSETS] = [a.asset_id : a.spin_raise_reserv_req_perc | a in ASSETS];
//float NFLoadSpinRaiseReserveReq[n in isNF_E_LOADS] = assetSpinRaiseReserveReq[n];
float NFLoadSpinRaiseReserveReq[n in isNF_E_LOADS] = (microgridName == "MICROGRID TPL Tongatapu" ? 30.0 : 0.0);
// fraction of asset's active power used to define spinning lower reserve requirements
// HARD-CODED
//float assetSpinLowerReserveReq[isASSETS] = [a.asset_id : a.spin_lower_reserv_req_perc | a in ASSETS];
//float NFLoadSpinLowerReserveReq[n in isNF_E_LOADS] = assetSpinLowerReserveReq[n];
float NFLoadSpinLowerReserveReq[s in isNF_E_LOADS] = (microgridName == "MICROGRID TPL Tongatapu" ? 30.0 : 0.0);
// HARD-CODED
// assset's heat/elec ratio giving the heat energy produced per unit of elec energy (HARD-CODED in preprocessing block)
float assetHeatElecRatio[isASSETS]; // [a.asset_id : a.elec_heat_ratio | a in ASSETS];
float disGenHeatElecRatio[d in isDISP_EH_GENS] = assetHeatElecRatio[d];
// HARD-CODED
// assset's energy conversion efficiency expressed as a ratio (HARD-CODED in preprocessing block)
float assetEnergyConvEfficiency[isASSETS]; // [a.asset_id : a.conv_efficiency | a in ASSETS];
float convElecToHeatEff[c in isCONVS] = assetEnergyConvEfficiency[c];
// average power forecast (expressed in kW) for microgid asset a over decision step t ((a, t) in ASSET_STEPS)
float powerPrediction[isASSETS][isDECISION_STEPS] = [as.asset_id : [as.step_id : as.power_prediction] | as in ASSET_STEPS];
// average power consumption forecast (expressed in kW) for non-flexible load unit n over decision step t
// (n in NF_E_LOADS, t in DECISION_STEPS)
float NFElecLoadForecast[n in isNF_E_LOADS][t in isDECISION_STEPS] = maxl(minl(maxNFElecLoad[n][t], NFLoadAvail[n][t] / 100.0 * powerPrediction[n][t]), minNFElecLoad[n][t]);
// A flag that signals the changing on the NFElecLoad forecasts values
float NFElecLoadChangedForecast[n in isNF_E_LOADS][t in isDECISION_STEPS] = (NFElecLoadForecast[n][t] != powerPrediction[n][t]*NFLoadAvail[n][t] / 100.0  ? powerPrediction[n][t]*NFLoadAvail[n][t]/100.0 - NFElecLoadForecast[n][t]: 0);
// average heat consumption forecast (expressed in kW) for non-flexible heat load n over decision step t
// (n in NF_H_LOADS, t in DECISION_STEPS)
float NFHeatLoadForecast[n in isNF_H_LOADS][t in isDECISION_STEPS] = maxl(minl(maxNFHeatLoad[n], powerPrediction[n][t]), minNFHeatLoad[n]);
// A flag that signals the changing on the NFHeatLoad forecasts values
float NFLoadHeatChangedForecast[n in isNF_H_LOADS][t in isDECISION_STEPS] = (NFHeatLoadForecast[n][t] != powerPrediction[n][t] ? powerPrediction[n][t] - NFHeatLoadForecast[n][t] : 0);
// nominal average power consumption (expressed in kW) forecast for flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
float flexLoadForecast[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = maxl(minl(maxFlexLoad[f], powerPrediction[f][t]), minFlexLoad[f])* flexLoadAvail[f][t];
// A flag that signals the changing on the flexLoad forecasts values
float flexLoadChangedForecast[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = (flexLoadForecast[f][t] != flexLoadAvail[f][t]*powerPrediction[f][t] ? flexLoadAvail[f][t]*powerPrediction[f][t] - flexLoadForecast[f][t] : 0);
// maximum average power generation forecast (expressed in kW) for intermittent generation asset i over decision step t
// (i in INTER_GENS, t in DECISION_STEPS)
float interGenActivePowerForecast[i in isINTER_E_GENS][t in isDECISION_STEPS] = maxl(minl(maxInterGenActivePower[i][t], -interGenAvail[i][t] / 100.0 * powerPrediction[i][t]), minInterGenActivePower[i][t]);
// A flag that signals the changing on the InterGen forecasts values
float interGenChangedForecast[i in isINTER_E_GENS][t in isDECISION_STEPS] = (interGenActivePowerForecast[i][t] != -powerPrediction[i][t]*interGenAvail[i][t]/100.0   ? -powerPrediction[i][t]*interGenAvail[i][t]/100.0  - interGenActivePowerForecast[i][t] : 0);
// min SOC Target (expressed as a % of asset's maximum energy storage capacity) for Battery Storage asset s over decision step t
// (s in isStorages, t in DECISION_STEPS)
// -1 : no minSocTarget ; >-1 : there is a minSocTarget
float minSocTarget[isASSETS][isDECISION_STEPS] = [as.asset_id : [as.step_id : as.soc_target] | as in ASSET_STEPS];
float storMinSocTarget[s in isE_STORAGES][t in isDECISION_STEPS] = ( minSocTarget[s][t] < 0.0 ? -1.0 : minl(maxl(storElecMinSOC[s],minSocTarget[s][t]),storElecMaxSOC[s]));
/*Congestions*/
// lower limit imposed by network congestion constraint c (c in CONGESTIONS)
float congestionLowerLim[isCONGESTIONS] = [c.congestion_id : -c.max_power_in | c in CONGESTIONS];
// upper limit imposed by network congestion constraint c (c in CONGESTIONS)
float congestionUpperLim[isCONGESTIONS] = [c.congestion_id : c.max_power_out | c in CONGESTIONS];
// left hand side coefficient of power import from main grid in network congestion constraint c (c in CONGESTION)
float importFactor[isCONGESTIONS] = [c.congestion_id : c.power_import_coef | c in CONGESTIONS];
// left hand side coefficients of assets in network congestion constraints
float assetCongestionFactor[isCONGESTIONS][isE_ASSETS] = [ca.congestion_id : [ca.asset_id : ca.power_coef] | ca in CONGESTION_ASSETS];
// left hand side coefficient of power generation from dispatchable generator d in network congestion constraint c
// (d in DISP_GENS, c in CONGESTION)
float dispGenFactor[c in isCONGESTIONS][d in isDISP_E_GENS] = assetCongestionFactor[c][d];
// left hand side coefficient of power generation from intermittent gen asset i in network congestion constraint c
// (i in INTER_GENS, c in CONGESTION)
float interGenFactor[c in isCONGESTIONS][i in isINTER_E_GENS] = assetCongestionFactor[c][i];
// left hand side coefficient of power injection from storage asset s in network congestion constraint c
// (s in STORAGES, c in CONGESTION)
float injectionFactor[c in isCONGESTIONS][s in isE_STORAGES] = assetCongestionFactor[c][s];
// left hand side coefficient of power consumption from flexible load unit f in network congestion constraint c
// (f in FLEX_LOADS, c in CONGESTION)
float flexLoadFactor[c in isCONGESTIONS][f in isFLEX_E_LOADS] = assetCongestionFactor[c][f];
// left hand side coefficient of power consumption from non-flexible load unit n in network congestion constraint c
// (n in NF_LOADS, c in CONGESTION)
float nonFlexLoadFactor[c in isCONGESTIONS][n in isNF_E_LOADS] = assetCongestionFactor[c][n];
// left hand side coefficient of fcr asset unit fcr_a particpating to fcr in network congestion constraint c
// (fcr_a in isFCR_ASSETS, c in CONGESTION)
float fcrAssetFactor[c in isCONGESTIONS][fcr_a in isFCR_ASSETS] = assetCongestionFactor[c][fcr_a];
// left hand side coefficient of afrr up asset unit afrr_up_a particpating to afrr up in network congestion constraint c
// (afrr_up_a in isaFRRUp_ASSETS, c in CONGESTION)
float afrrUpAssetFactor[c in isCONGESTIONS][afrr_up_a in isaFRRUp_ASSETS] = assetCongestionFactor[c][afrr_up_a];
// left hand side coefficient of afrr down asset unit afrr_dwn_a particpating to afrr down in network congestion constraint c
// (afrr_dwn_a in isaFRRDwn_ASSETS, c in CONGESTION)
float afrrDwnAssetFactor[c in isCONGESTIONS][afrr_dwn_a in isaFRRDwn_ASSETS] = assetCongestionFactor[c][afrr_dwn_a];
/* Energy Markets */
// this is either the total electricity price, or just the transport cost depending on the project,(expressed in currency unit per kWh) at decision step t
// (t in DECISION_STEPS)
float electricityPrice[isDECISION_STEPS] = [os.step_id : os.electricity_price | os in OPERATION_STEPS];
// da forecast spot price (will be a forecast for time steps not cleared yet)
float daElecPrice[isHOURLY_STEPS] = [p.step_index : p.price | p in MARKET_PRICE_STEPS : p.type == "DAY_AHEAD"];
// day-ahead electricity market engagements (expressed in kW),
// (h in isHOURLY_STEPS)
float daEngagement[isHOURLY_STEPS] = [m.step_index : m.engagement | m in MARKET_ENGAGEMENTS : m.type == "DAY_AHEAD"];
// day-ahead electricity market engagement status (1 = cleared / 0 = not cleared),
// (h in isHOURLY_STEPS)
int isDAStepCleared[isHOURLY_STEPS] = [m.step_index : m.is_step_cleared | m in MARKET_ENGAGEMENTS : m.type == "DAY_AHEAD"];
// (h in isHOURLY_STEPS)
// flag indicating if the optimisation context is present in the input
int isOptContextSpecified = card({o.param_val | o in OPERATION: o.param_id == "optimisation_context"});
// optimisation's context (OPERATIONS or MARKET_STRAT)
string optContext = (isOptContextSpecified > 0 ? first({o.param_val | o in OPERATION: o.param_id == "optimisation_context"}) : "OPERATIONS");
// long term agragated electricity market engagements (expressed in kW)
float long_term_engagement[isHOURLY_STEPS] = [m.step_index : m.engagement | m in MARKET_ENGAGEMENTS : m.type == "ELECTRICITY_LONG_TERM_AGREGATED_BIDS"];
// activated power for mFRR on mFRR step.
// Positive values mean downward activation, negative upward activation
float mFRRactivatedPower_mFRR[ismFRR_STEPS] = [m.step_index : m.engagement | m in MARKET_ENGAGEMENTS : m.type == "MFRR_R3"];
// activated power for mFRR on imbalance step.
// Positive values mean downward activation, negative upward activation
float mFRRactivatedPower_imb[imb in isIMBALANCE_STEPS_POS] = sum (mFRR in ismFRR_STEPS_POS : imb == mFRRStepImbalanceStep[mFRR]) mFRRactivatedPower_mFRR[mFRR] /
														 sum (mFRR in ismFRR_STEPS_POS : imb == mFRRStepImbalanceStep[mFRR]) 1;

/////////////////////////////////////////
// Penalties Categories
/////////////////////////////////////////
// max elec price over optim horizon
float maxPrice = maxl(
	max(t in isDECISION_STEPS) abs(networkDrawingTax[t]),
	max(t in isDECISION_STEPS) abs(electricityPrice[t]),
	max(h in isHOURLY_STEPS_POS) abs(daElecPrice[h]));
float maxCost = maxl(
	max (cm in isVAR_COST_MODELS, s in 1..maxSegNbr) varCostSegCost[cm][s],
	max (a in isLIN_COST_E_GENS) assetVariableCost[a],
	max (a in isCURT_COMP_E_GENS) assetCurtComp[a]);
// max between max price and max cost (expressed in currency unit per kwh)
//float penaltyBase = maxl(maxPrice, maxCost, 1.0);
float penaltyBase = maxl(maxPrice, maxCost, 0.001);
float catMultFactor = 10.0;
// cat 5 Violation variable penality costs (without unit)
// we should start from cat5Pen since cat5Pen must be higher than the max cost and max price. So for this minSocTargetStoragePenaltyCost must be lower than the minimum startup cost
///////////////////////////////////////
// penality under cat5 must be higher than the max cost and max price, for this we need to multiply by 2.
float cat5Pen = 2;
// penalty cost (expressed in currency unit per kWh) applied if AuthorizeCurt1&2 reserve constraints cannot be satisfied
float unauthorizedInterGenCurtPenaltyCost =  cat5Pen * penaltyBase;
// penalty cost (expressed in currency unit per kwh) applied if ctStorageTargetSoc constraint cannot be satisfied
float minSocTargetStoragePenaltyCost = cat5Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if SOC min constraints are violated
// note: Socmin is the ideal minimum SOC of the sotrage asset, but it is allowed to be violated so that you don't have to turn on a new generator for it
float socMinViolationPenaltyCost = cat5Pen * penaltyBase;
// cat 6 Violation variable penality costs (without unit)
///////////////////////////////////////
// the storArtificialPenalityCost should be lower than the min variable cost and the min différence between segCost (to avoid using a generator instead of  battery when both are available)
float minCost = minl(min (a in isLIN_COST_E_GENS) assetVariableCost[a], min (cm in isVAR_COST_MODELS, s in 1..maxSegNbr, s1 in 1..maxSegNbr : s1 != s ) (abs(varCostSegCost[cm][s] - varCostSegCost[cm][s1])));
float cat6Pen = minl(cat5Pen / catMultFactor, 1);
// artificial penality to encourage late battery charges/discharges whatever the the Microgrid
// the 1.01 is used to avoid the equivalent optimal solution
// To avoid the multiplication by 0 (when the mincost equal to zero) we should compare minCos with an default value (in our case 0.001)
float storArtificialPenalityCost[t in isDECISION_STEPS] = (microgridName == "MICROGRID GP Brielle"  || microgridName == "MICROGRID VALOREM LIMOUX" || microgridName == "MICROGRID GEG SYNERGIE MAURIENNE"
	? 0.0
	: (optimisationStepNumber - stepIndex[t]) / optimisationStepNumber * cat6Pen * minl(penaltyBase, maxl(minCost/1.01, 0.001)));
// artificial penalty to reduce changes in active power (in or out) for elec storage assets
float storPowerChangePenalty = (microgridName == "MICROGRID VALOREM LIMOUX" || microgridName == "MICROGRID GEG SYNERGIE MAURIENNE" ? 0.0001 : 0.0);
// artificial penalty to encourage first step's average active power to stay the same as it was initially for dispatchable gen d if d is initially on
float dispGenInitialPowerViolPenalty = cat6Pen * penaltyBase;
// cat 4 violation variable penalty costs
/////////////////////////////////////////
// The max startup cost (unit / kwh) of all asset that have a start_up_cost and a max time on, this value will be used to calculate the Cat4 penality cost
// When a generator reaches the maximum time on, another generator must be turn on (if it is available)
// We Should taken into account the asset id  that have a max times  on > 0 because the penality cost of the cat4 must be higher than the startup cost (+ NL cost / Lin cost)
// of asset that have startup cost and Max time On > 0
// hypothesis : In calcul of the maxNlVarCost, the generator is on, on average for dispGenMaxStepsOn / 2.
// The max seg cost of all asset that have a non linear cost
// The max Lin cost of all asset that have a lin cost
// We should take into account this costs when calculating the genMinMaxStepOnOffPenaltyCost (genMinMaxStepOnOffPenaltyCost should be
// higher than the maxstartup)
// NB : it is not generalized, to be revised: in the case where the dispGen has no limit on the MaxtimeOn => separation of max (+ multiplication by stepOberationNumber / 2 for the Gen without max time on)
float maxStartNlVarCost = maxl(
						  max(g in isNL_COST_E_GENS inter isSTART_COST_E_GENS inter isMAX_TIME_ON_GENS : assetStepDurationInHours > 0.0 && maxDispGenActivePower[g] > 0.0, s in 1..maxSegNbr : s < varCostModelSegNumber[genVarCostModelId[g]])
                          ((assetStartupCost[g] / (assetStepDurationInHours * maxDispGenActivePower[g])) + (varCostSegCost[genVarCostModelId[g]][s] * dispGenMaxStepsOn[g]) / 2.0 )
						  ,0.0);

float maxStartLinVarCost = maxl(
						   max(g in isLIN_COST_E_GENS inter isSTART_COST_E_GENS inter isMAX_TIME_ON_GENS :  assetStepDurationInHours > 0.0 && maxDispGenActivePower[g] > 0.0)
                          ((assetStartupCost[g] / (assetStepDurationInHours * maxDispGenActivePower[g])) + (genVariableCost[g]  * dispGenMaxStepsOn[g] / 2.0 ))
						  ,0.0);
// maxGenCost represent the maximum generation power cost that could be achieved by Generators
// when calculaiting the cat4Pen we add the catMultFactor to ensure that the cat5Pen * penality base is strictly higher than the maxGenCost
// in the other case the cat4Pen is the result of the multiplication of  maxGenCost / penaltyBase by catMultFactor
float maxGenCost = maxl(maxStartLinVarCost, maxStartNlVarCost);
float cat4Pen = maxl(catMultFactor*cat5Pen,(catMultFactor * maxGenCost) / penaltyBase);
// penalty cost (expressed in currency unit per kwh ) applied if a min or max time on or off constraint cannot hold
float genMinMaxStepOnOffPenaltyCost = cat4Pen * penaltyBase;
// cat 3 Violation variable penality costs (without unit)
///////////////////////////////////////
//  representing violation variables for active/reactive power raise/lower reserve
// to ensure that the cat of power/ current reserve and the cat of physical violations are mush higher than the other cat value we add the multiplication by 10 ion the definition of the cat3
//// other solution is to taken into account the maxGenPower when calculating  the cat3 as :
////  float cat3Pen = maxl(10*cat4Pen*catMultFactor, cat4Pen*card(isDECISION_STEPS)*assetStepDurationInHours*maxl(max(d in isDISP_E_GENS) maxDispGenActivePower[d], 1)/(penaltyBase*2.0));
////  in this solution : disp Gen must remain on, even if the Max/Min timesOn/recoveryPeriode are not satisfied, to cover the reserve requirements: to do this, we must take into account the maxGenPower.
////  An assumption was made: the Disp Gen must cover the power and current reserves for at least the number of step duration*2 of Min/Max recovery/Time under violation of the Max/Min Recovery/TimeOn constraints.
float cat3Pen = 10.0*cat4Pen*catMultFactor;
// penalty cost (expressed in currency unit per kVARh) applied if reactive power upper reserve constraints cannot be satisfied
float reactivePowerLowerReserveDeficitPenaltyCost = cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per kVARh) applied if reactive power upper reserve constraints cannot be satisfied
float reactivePowerRaiseReserveDeficitPenaltyCost = cat3Pen* penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if active power lower reserve constraints cannot be satisfied
float activePowerLowerReserveDeficitPenaltyCost = cat3Pen* penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if active power upper reserve constraints cannot be satisfied
float activePowerRaiseReserveDeficitPenaltyCost = cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if spinning upper or lower reserve constraints cannot be satisfied
float spinningReserveDeficitPenaltyCost = cat3Pen * penaltyBase;
// penalty cost (expressed in currency unit per Ah) applied if default current requirement constraints cannot be satisfied
float defaultCurrentReqDeficitPenaltyCost = cat3Pen * penaltyBase;
// cat 2 Violation variable penality costs (without unit)
///////////////////////////////////////
// A multiplication constant to switch from one Sub category violation to another under the physical violations category
float subCatPhyMultPenalty = 3.2;
// subcategory representing violation variables for MaxNumberOfCycles constraint
float cat2_2Pen = minl(maxl(card(isE_STORAGES), 2)*cat3Pen, subCatPhyMultPenalty*cat3Pen);
// penalty cost (expressed in currency unit per kwh) applied if ctStorageMaxNumberOfCycles constraint cannot be satisfied
float storageDailyMaxCyclPenaltyCost = cat2_2Pen * penaltyBase;
// subcategory representing violation variables for StrictMin/MaxSOC for heat and elec storage, and min dispGen ActivePower constraints
float cat2_1Pen = minl(maxl((card(isDISP_E_GENS) + card(isE_STORAGES) + card(isH_STORAGES )), 2)*cat2_2Pen, subCatPhyMultPenalty*cat2_2Pen);
// penalty cost for non-respect of minimal active power for dispatchable generators
float minDispGenActivePowerDeficitPenalty = cat2_1Pen * penaltyBase;
// penalty cost for non-respect of the minimum and maximum physical SOC for the storage asset (Elec +Heat)
float socStrictMinMaxViolationPenaltyCost = cat2_1Pen * penaltyBase;
// penalty cost (expressed in currency unit per kwh) applied if ctFCRPoolEngagement constraint cannot be satisfied
float FCRPowerEngDeficitPenaltyCost = cat2_1Pen * penaltyBase;
// penalty cost (expressed in currency unit per kwh) applied if ctFCRPoolEngagement constraint cannot be satisfied
float AFRRUpPowerEngDeficitPenaltyCost = cat2_1Pen * penaltyBase;
// penalty cost (expressed in currency unit per kwh) applied if ctFCRPoolEngagement constraint cannot be satisfied
float AFRRDwnPowerEngDeficitPenaltyCost = cat2_1Pen * penaltyBase;
// cat 1 violation variable penalty costs
/////////////////////////////////////////
float cat1Pen = minl(maxl((card(E_ASSETS)+card(H_ASSETS)), 2)*cat2_1Pen, cat2_1Pen*catMultFactor);
// penalty cost (expressed in currency unit per kWh) applied if power balance constraint cannot be satisfied
float powerImbalancePenaltyCost = cat1Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if heat balance constraint cannot be satisfied
float heatImbalancePenaltyCost = cat1Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if a site maximum input/output constraint cannot hold
float siteInOutViolationPenaltyCost = cat1Pen * penaltyBase;
// penalty cost (expressed in currency unit per kWh) applied if a network congestion constraint cannot hold
float congestionLimViolationPenaltyCost = cat1Pen * penaltyBase; 
/*********************************************/ 
/*assets energy charging / discharging efficiencies*/
/*********************************************/ 
float assetChargeEfficiency[isASSETS] = [a.asset_id : a.storage_charging_efficiency | a in ASSETS];
float assetDischargeEfficiency[isASSETS] = [a.asset_id : a.storage_discharging_efficiency | a in ASSETS];
// average charge / discharge efficiencies (expressed as a %)of elec storage asset s (s in E_STORAGES)
// The battery efficiency for "MICROGRID MORBIHAN ENERGIES FlexMobIle" will be defined in hard code
float storElecChargeCstEff[s in isE_STORAGES] = assetChargeEfficiency[s]*100;
float storElecDischCstEff[s in isE_STORAGES] = assetDischargeEfficiency[s]*100;
// average charge / discharge efficiencies (expressed as a %) of heat storage asset s (s in H_STORAGES)
float storHeatChargeEfficiency[s in isH_STORAGES] = assetChargeEfficiency[s] * 100;
float storHeatDischargeEfficiency[s in isH_STORAGES] = (assetDischargeEfficiency[s] == -1 ? storHeatChargeEfficiency[s] : assetDischargeEfficiency[s] * 100);
// maximum heat charge / discharge rates (expressed in kW) for heat storage asset s (s in H_STORAGES)
float maxStorHeatCharge[s in isH_STORAGES] = (storHeatChargeEfficiency[s] > 0.0 ? powerMax[s] * (100.0 / storHeatChargeEfficiency[s]) : 0.0);
float maxStorHeatDischarge[s in isH_STORAGES] = -powerMin[s] * (storHeatDischargeEfficiency[s] / 100.0);
// Opration type : charge / discharge
string operationType[isSTORE_OPERATION_TYPES] = [o.op_id : o.op_id | o in STORE_OPERATION_TYPES];
// Max charge/discharge Power according to the opration type : charge / discharge
float storeOpMaxPower[o in isSTORE_OPERATION_TYPES] [s in isE_STORAGES] = (operationType[o] == "CHARGE" ? nomPowerMax[s] : maxl(-nomPowerMin[s], 0.0));
// charge/discharge efficiency, as coefficient, according to the operation type : charge / discharge
float storeOpEff[o in isSTORE_OPERATION_TYPES] [s in isE_STORAGES] = (operationType[o] == "CHARGE" ? 100/storElecChargeCstEff[s] : storElecDischCstEff[s]/100);
// Battery Efficiency Hardcoded data : AC power is a piecewise linear function as a function of DC power
tuple t_battery_efficiency_model{
 	key string model_id;
 	key int power_interval_nbr;
	key string direction;
 	float lower_limit; // in kw
 	float upper_limit; // in kw
 	float efficiency_slope;
 	float efficiency_intercept;
}

// Storage assets charge variable efficiency model id
string chargeVarEffModelId[s in isE_STORAGES] = storageVarEffModelId[s];
// Storage assets discharge variable efficiency model id
string dischVarEffModelId[s in isE_STORAGES] =  storageVarEffModelId[s];
// indexing set of storage variable efficiency model (only non-linear)
{string} isSTOR_VAR_MODEL = {ve.model_id | ve in VARIABLE_COST_MODELS: ve.direction == "CHARGE" || ve.direction == "DISCHARGE"};
// indexing set of storage charge efficiency model (linear and non-linear)
{string} isSTOR_CHARGE_EFF = {ve.model_id | ve in VARIABLE_COST_MODELS: ve.direction == "CHARGE"} union {a.asset_id | a in ASSETS: a.type == "STORAGE" && (a.var_efficiency_model == "-1.0" || a.var_efficiency_model == "-1")};
// indexing set of storage discharge efficiency model (linear and non-linear)
{string} isSTOR_DISCHARGE_EFF = {ve.model_id | ve in VARIABLE_COST_MODELS: ve.direction == "DISCHARGE"} union {a.asset_id | a in ASSETS: a.type == "STORAGE" && (a.var_efficiency_model == "-1.0" || a.var_efficiency_model == "-1")};
// all factors and min/max power are DC side : we must keep the same logic as Everest. : in fact on Everest side we send all storage input data on the DC side
{t_battery_efficiency_model} BATTERY_EFFICIENCY_MODELS = (
    {<ve.model_id, ve.power_interval_nbr, ve.direction, ve.lower_limit, ve.upper_limit, ve.efficiency_slope, ve.efficiency_intercept> | s in isE_STORAGES, ve in VARIABLE_COST_MODELS : ve.model_id == storageVarEffModelId[s]} union
    {<s, 1, o.op_id, 0, storeOpMaxPower[o.op_id][s], storeOpEff[o.op_id][s], 0.0> | s in isE_STORAGES, o in STORE_OPERATION_TYPES: storageVarEffModelId[s] not in isSTOR_VAR_MODEL});
// power segment index for each battery charge efficiency model (used in declarations of model efficiency (linear and non-linear) variables and constraints)
int chargeEffModelSegIndx[isSTOR_CHARGE_EFF] = [ve.model_id : ve.power_interval_nbr | ve in BATTERY_EFFICIENCY_MODELS : ve.direction =="CHARGE"];
// number of power segments (per model) for each stor charge efficiency model (used in declarations of model efficiency (linear and non-linear) variables and constraints)
int chargeStorSegNbr[isSTOR_CHARGE_EFF] = [em: maxl(0, max(ve in BATTERY_EFFICIENCY_MODELS : ve.model_id == em ) chargeEffModelSegIndx[em])|  em  in isSTOR_CHARGE_EFF];
// set containing the number of segments per model during the phase charge
int maxChargeSegNbr = max (em in isSTOR_CHARGE_EFF) chargeStorSegNbr[em];
// upper limit (in kW) of power segment ve in efficiency model em
float chargeEffSegUpLim[isSTOR_CHARGE_EFF][1..maxChargeSegNbr] = [ve.model_id : [ve.power_interval_nbr : ve.upper_limit] | ve in BATTERY_EFFICIENCY_MODELS : ve.direction =="CHARGE"];
//  linear function slope associated with segment charge ve in efficiency model em
float storChargeSegSlope[isSTOR_CHARGE_EFF][1..maxChargeSegNbr] = [ve.model_id : [ve.power_interval_nbr : ve.efficiency_slope] | ve in BATTERY_EFFICIENCY_MODELS : ve.direction =="CHARGE"];
//  linear function ordinate associated with segment charge ve in efficiency model em
float storChargeSegOrdinate[isSTOR_CHARGE_EFF][1..maxChargeSegNbr] = [ve.model_id : [ve.power_interval_nbr : ve.efficiency_intercept ] | ve in BATTERY_EFFICIENCY_MODELS : ve.direction =="CHARGE"];
// power segment index for each battery discharge efficiency model (used in declarations of the model efficiency (linear and non-linear) variables and constraints)
int dischEffModelSegIndx[isSTOR_DISCHARGE_EFF] = [ve.model_id : ve.power_interval_nbr | ve in BATTERY_EFFICIENCY_MODELS : ve.direction =="DISCHARGE"];
// number of power segments for each stor dicharge efficiency model (used in declarations of the model efficiency (linear and non-linear) variables and constraints)
int dischStorSegNbr[isSTOR_DISCHARGE_EFF] = [em: maxl(0, max(ve in BATTERY_EFFICIENCY_MODELS : ve.model_id == em ) dischEffModelSegIndx[em])|  em  in isSTOR_DISCHARGE_EFF];
// set containing the number of segments per model during the phase discharge
int maxDischSegNbr = max(em in isSTOR_DISCHARGE_EFF) dischStorSegNbr[em];
// upper limit (in kW) of power segment ve in efficiency model em
float dischEffSegUpLim[isSTOR_DISCHARGE_EFF][1..maxDischSegNbr] = [ve.model_id : [ve.power_interval_nbr : ve.upper_limit] | ve in BATTERY_EFFICIENCY_MODELS : ve.direction =="DISCHARGE" ];
// linear function slope associated with segment discharge ve in efficiency model em
float storDischSegSlope[isSTOR_DISCHARGE_EFF][1..maxDischSegNbr] = [ve.model_id : [ve.power_interval_nbr :  ve.efficiency_slope ] | ve in BATTERY_EFFICIENCY_MODELS : ve.direction =="DISCHARGE"];
//  linear function ordinate associated with segment discharge ve in efficiency model em
float storDischSegOrdinate[isSTOR_DISCHARGE_EFF][1..maxChargeSegNbr] = [ve.model_id : [ve.power_interval_nbr : ve.efficiency_intercept ] | ve in BATTERY_EFFICIENCY_MODELS : ve.direction =="DISCHARGE"];
// maximum DC-side charge / discharge rates (expressed in kW) for elec storage asset s over decision step t (s in E_STORAGES, t in DECISION_STEPS)
// accounts for partial availability of asset s over decisions step t
float storMaxDCActivePowerCharge[s in isE_STORAGES][t in isDECISION_STEPS] = (
	storAvail[s][first(isDECISION_STEPS)] > 0.0
		? minl(nomPowerMax[s], powerMax[s] / storAvail[s][first(isDECISION_STEPS)] * storAvail[s][t])
		: nomPowerMax[s] * storAvail[s][t]/100.0
	);
float storMaxDCActivePowerDischarge[s in isE_STORAGES][t in isDECISION_STEPS] = (nomPowerMin[s] < 0.0
	? (storAvail[s][first(isDECISION_STEPS)] > 0.0
		? minl(-nomPowerMin[s], -powerMin[s] / storAvail[s][first(isDECISION_STEPS)] * storAvail[s][t])
		: -nomPowerMin[s] * storAvail[s][t]/100.0)
	: 0.0
	);
// minimum DC-side charge rates (expressed in kW) for elec storage asset s over decision step t (s in E_STORAGES, t in DECISION_STEPS)
// accounts for partial availability of asset s over decisions step t
float storMinDCActivePowerCharge[s in isE_STORAGES][t in isDECISION_STEPS] = (nomPowerMin[s] > 0.0
	? minl(nomPowerMin[s], storMaxDCActivePowerCharge[s][t])
	: (microgridName == "MICROGRID MOPABLOEM" ? // We set a minimum power charge different from 0
		150.0
		: 0.0)
	);

float storMinDCActivePowerDischarge[s in isE_STORAGES][t in isDECISION_STEPS] =
		(microgridName == "MICROGRID MOPABLOEM" ? // We set a minimum power discharge different from 0
		150.0
		: 0.0);
// maximum AC-side charge / discharge rates (expressed in kW) for elec storage asset s over decision step t (s in E_STORAGES, t in DECISION_STEPS)
float storMaxACActivePowerCharge[s in isE_STORAGES][t in isDECISION_STEPS] = storMaxDCActivePowerCharge[s][t] * storChargeSegSlope[chargeVarEffModelId[s]][chargeStorSegNbr[chargeVarEffModelId[s]]] + storChargeSegOrdinate[chargeVarEffModelId[s]][chargeStorSegNbr[chargeVarEffModelId[s]]];
float storMaxACActivePowerDischarge[s in isE_STORAGES][t in isDECISION_STEPS] = storMaxDCActivePowerDischarge[s][t] * storDischSegSlope[dischVarEffModelId[s]][dischStorSegNbr[dischVarEffModelId[s]]] + storDischSegOrdinate[dischVarEffModelId[s]][dischStorSegNbr[dischVarEffModelId[s]]];
// minimum AC-side charge rates (expressed in kW) for elec storage asset s over decision step t (s in E_STORAGES, t in DECISION_STEPS)
float storMinACActivePowerCharge[s in isE_STORAGES][t in isDECISION_STEPS] = storMinDCActivePowerCharge[s][t] * storChargeSegSlope[chargeVarEffModelId[s]][chargeStorSegNbr[chargeVarEffModelId[s]]] + storChargeSegOrdinate[chargeVarEffModelId[s]][chargeStorSegNbr[chargeVarEffModelId[s]]];
float storMinACActivePowerDischarge[s in isE_STORAGES][t in isDECISION_STEPS] = storMinDCActivePowerDischarge[s][t] * storDischSegSlope[dischVarEffModelId[s]][dischStorSegNbr[dischVarEffModelId[s]]] + storDischSegOrdinate[dischVarEffModelId[s]][dischStorSegNbr[dischVarEffModelId[s]]];

// number of available inverters for elec storage asset s over decision step t (s in E_STORAGES, t in DECISION_STEPS)
// accounts for partial availability of asset s over decisions step t
float availInverterNbr[s in isE_STORAGES][t in isDECISION_STEPS] = (
	storAvail[s][first(isDECISION_STEPS)] > 0.0
		? minl(nomBlockNbr[s], healthyBlockNbr[s] / storAvail[s][first(isDECISION_STEPS)] * storAvail[s][t])
		: nomBlockNbr[s] * storAvail[s][t]/100.0
	);
// current injection potential (expressed in A) for each storage asset
float storCurrentInjection[s in isE_STORAGES][t in isDECISION_STEPS] = availInverterNbr[s][t] * currentInjectionPotential[s];


////////////////////////////
// FCR
////////////////////////////
// FCRPower that can be engaged into FCR for asset a , expressed in kW. (a in ASSETS)
//int fcrCertfiedPower[fcr_a in isFCR_ASSETS] = [a.asset_id : a.fcr_certfied_power | a in ASSETS];
int fcrCertfiedPower[a in isASSETS] = (microgridName ==  "MICROGRID VALOREM LIMOUX" && a in isFCR_ASSETS ? 1000 : 0);
// FCRPower that can be engaged into FCR for asset a , expressed in MW. (a in ASSETS)
int fcrCertfiedPower_MW[a in isASSETS] = ftoi(fcrCertfiedPower[a]/1000);
// max certified power among the different assets
int maxfcrCertfiedPower_MW = max(a in isASSETS) fcrCertfiedPower_MW[a];
// Engaged power, in kW, in FCR over FCR step fcr, (fcr in FCR_STEPS)
float fcrEngPower[isFCR_STEPS] = [m.step_index : (m.engagement >= 0 ? m.engagement : 0) | m in MARKET_ENGAGEMENTS : m.type == "FCR"];
// Required power, in kW, in FCR over FCR step fcr, (fcr in FCR_STEPS)
// accounts for partial availability of FCR assets and grid connection
float fcrReqPower[fcr in isFCR_STEPS] = maxl(0.0, fcrEngPower[fcr]
	- sum(s in isE_STORAGES inter isFCR_ASSETS, t in isDECISION_STEPS: assetStepFCRStep[t] == fcr && storMaxACActivePowerCharge[s][t] < 0.9 * fcrCertfiedPower[s])
		fcrCertfiedPower[s] 
	- sum(s in isE_STORAGES inter isFCR_ASSETS, t in isDECISION_STEPS: assetStepFCRStep[t] == fcr && storMaxACActivePowerDischarge[s][t] < 0.9 * fcrCertfiedPower[s])
		fcrCertfiedPower[s]
	- sum(s in isASSETS inter {"VALOREM_Limoux_PDL_in"}, t in isDECISION_STEPS: assetStepFCRStep[t] == fcr && maxNFElecLoad[s][t] < 0.9 * fcrEngPower[fcr])
		fcrEngPower[fcr]
	- sum(s in isASSETS inter {"VALOREM_Limoux_PDL_out"}, t in isDECISION_STEPS: assetStepFCRStep[t] == fcr && maxNFElecLoad[s][t] < 0.9 * fcrEngPower[fcr])
		fcrEngPower[fcr]);
//float storMaxDCEnergy[s in isE_STORAGES][t in isDECISION_STEPS] = (
//	storAvail[s][first(isDECISION_STEPS)] > 0.0
//		? minl(nomEnergyMax[s], energyMax[s] / storAvail[s][first(isDECISION_STEPS)] * storAvail[s][t])
//		: 0.0
//	);
// Flag indicating if pool is engaged into FCR market over FCR step fcr (fcr in FCR_STEPS).
// If engagement is strictly positive, it means there is an engagement
// int isFCR[fcr in isFCR_STEPS] = fcrEngPower[fcr] > 0 ? 1 : 0 ;
// FCR bidding size : 1MW or 100kW. 100kW suppose 100% pool availability
//string fcrBidSize = first({o.param_val | o in OPERATION: o.param_id == "fcr_bid_size"});
//string fcrBidSize = "1MW";
// coefficient representing the most probable band that will be taken by asset a for FCR and SOC management for batteries ; on imports.
// 1 means we don�t take any risk and block all. (a in ASSETS)
//float assetCoeffFCRImport[isASSETS] = [a.asset_id : a.assetCoeffFCRImport | a in ASSETS];
//float assetCoeffFCRImport[a in isFCR_ASSETS] = (microgridName ==  "MICROGRID VALOREM LIMOUX" ? 1000 : 0);
// coefficient representing the most probable band that will be taken by asset a for FCR and SOC management for batteries ; on exports.
// 1 means we don�t take any risk and block all. (a in ASSETS)
// float CoeffFCRExport[isASSETS];
// Hard-coded
// battery's minimum energy downward needed to enter FCR period.
// in kWh/MW engaged
float storEnergyDwn1MWFCR = 300;
// battery's minimum energy needed upward to enter FCR period.
// in kWh/MW engaged
float storEnergyUp1MWFCR = 300;
// Average AC Energy out during 1h of FCR Engagement for 1KW engaged, expressed in kWh/kW/1h
float FCRHourlyACEnergyOut = 350.0/8760;
// Average AC Energy out during an optimization step t duration in FCR, expressed in kWh/kW
float FCRUnitarianStepACEnergyOut = FCRHourlyACEnergyOut * assetStepDurationInHours;
// Hard coded storage efficiency in during fcr
float storefficiencyfcr = 92;
// Hard coded inverter efficiency out during fcr, it is low since fcr is done at low power
float inverterefficiencyfcrout = 50;

///////////////////////////////
////AFRR
//////////////////////////////
// Minimum energy necessary for limited energy assets, to do aFRR up
// For mopa, must hold 15min for the CHP to ramp up
float minACEnergyForAFRRUpPerMW[s in isSTORAGES inter isaFRRUp_ASSETS] = 650.0 ;
// Minimum energy necessary for limited energy assets, to do aFRR down
// For mopa, e-boilers have a quick ramp-up, so there is no much need
float minACEnergyForAFRRDwnPerMW[s in isSTORAGES inter isaFRRUp_ASSETS] = 150.0 ; 
// Hard coded storage efficiency in during afrr
float storefficiencyaFRR = 92; 
// AFRR Up Power that can be engaged into AFRR UP for asset a , expressed in kW. (a in ASSETS)
//int aFRRUpCertfiedPower[afrr_up_a in isAFRRUp_ASSETS] = [afrr_up_a.asset_id : a.afrr_up_certfied_power | a in ASSETS];
int afrrUpCertfiedPower[a in isASSETS] = (microgridName ==  "MICROGRID MOPABLOEM" ? 
							(a == "BESS_MOPABLOEM" ? 1000 
								: (a == "CHP_1600kW" ? 1600
							  		: 0))
							: 0);						  
// AFRR Down Power that can be engaged into AFRR Down for asset a , expressed in kW. (a in ASSETS)
//int aFRRDwnCertfiedPower[afrr_dwn_a in isAFRRDwn_ASSETS] = [afrr_dwn_a.asset_id : a.afrr_dwn_certfied_power | a in ASSETS];
int afrrDwnCertfiedPower[a in isASSETS] = (microgridName ==  "MICROGRID MOPABLOEM" ? 
							(a == "E_boiler_1200kW" ? 1200
								: (a == "E_boiler_1000kW" ? 1000
							  		: 0))
							 :0);
// aFRRUPPower that can be engaged into aFRR Up for asset a , expressed in MW. (a in ASSETS)
float afrrUpCertfiedPower_MW[a in isASSETS] = (afrrUpCertfiedPower[a]/1000);
// aFRRDwnPower that can be engaged into aFRR Down for asset a , expressed in MW. (a in ASSETS)
float afrrDwnCertfiedPower_MW[a in isASSETS] = (afrrDwnCertfiedPower[a]/1000);
// Available energy, for limited energy sotrage s, to participate aFRR up, on first step
// We suppose here that all available energy of the asset can serve to aFRR; It might not be the case for stand-alone assets
dexpr float aFRRUpInitialAvailEnergyAC[s in isSTORAGES inter isaFRRUp_ASSETS][t in isDECISION_STEPS] = (initialSOC[s] - (storElecMinSOC[s] / 100) * storMaxDCEnergy[s][t]) * (storefficiencyaFRR/100);
// Define max available power to do aFRR up, per asset, taking into consideration availability
// availability can be included into max/min power. 
float afrrUpAssetAvailPower[a in isASSETS][t in isDECISION_STEPS] = 
	(a in (isINTER_E_GENS union isDISP_E_GENS union isE_STORAGES) ?
		(availability[a][t] > 0.99 && - powerMin[a]>= afrrUpCertfiedPower[a] ? afrrUpCertfiedPower[a] : 0)
			: (availability[a][t] > 0.99 && powerMax[a]>= afrrUpCertfiedPower[a] ? afrrUpCertfiedPower[a] : 0) // Load
	);
// Does not take into consideration if limited energy assets have required energy min/max
float afrrUpAvailPower[t in isDECISION_STEPS] = sum(a in isaFRRUp_ASSETS) afrrUpAssetAvailPower[a][t];
// Define max available power to do aFRR down, per asset, taking into consideration availability
// availability can be included into max/min power. 
// Does not take into consideration if limited energy assets have required energy min/max
float afrrDwnAssetAvailPower[a in isASSETS][t in isDECISION_STEPS] = 
	(a in (isINTER_E_GENS union isDISP_E_GENS union isE_STORAGES) ?
		(availability[a][t] > 0.99 && - powerMin[a]>= afrrDwnCertfiedPower[a] ? afrrDwnCertfiedPower[a] : 0)
		: (availability[a][t] > 0.99 && powerMax[a]>= afrrDwnCertfiedPower[a] ? afrrDwnCertfiedPower[a] : 0) // Load
	);
float afrrDwnAvailPower[t in isDECISION_STEPS] = sum(a in isaFRRDwn_ASSETS) afrrDwnAssetAvailPower[a][t];

// We must prepare to do aFRR, whether because we are engaged in capacity, or because we did free bids on energy: "voluntary" participation
// Capacity engagement in kW, in aFRR up over aFRRUp step afrr_up_capacity, (afrr_up_capacity in isAFRR_CAPACITY_STEPS)
float aFRRUpCapacityEngPower[isAFRR_CAPACITY_STEPS] = [m.step_index : (m.engagement >= 0 ? m.engagement : 0) | m in MARKET_ENGAGEMENTS : m.type == "AFRR_R2_CAPACITY_UP"];
// Voluntary engagement in kW, in aFRR up over aFRRUp step afrr_up_voluntary, (afrr_down_capacity in isAFRR_CAPACITY_STEPS)
float aFRRDwnCapacityEngPower[isAFRR_CAPACITY_STEPS] = [m.step_index : (m.engagement >= 0 ? m.engagement : 0) | m in MARKET_ENGAGEMENTS : m.type == "AFRR_R2_CAPACITY_DOWN"];
// Voluntary engagement, in kW, in aFRR up over aFRRUp step afrr_up_voluntary, (afrr_up_voluntary in isAFRR_VOLUNTARY_STEPS)
float aFRRUpVoluntaryEngPower[isAFRR_VOLUNTARY_STEPS] = [m.step_index : (m.engagement >= 0 ? m.engagement : 0) | m in MARKET_ENGAGEMENTS : m.type == "AFRR_R2_VOLUNTARY_UP"];
// Voluntary engagement, in kW, in aFRR down over aFRRDwn step afrr_down_voluntary, (afrr_down_voluntary in isAFRR_VOLUNTARY_STEPS)
float aFRRDwnVoluntaryEngPower[isAFRR_VOLUNTARY_STEPS] = [m.step_index : (m.engagement >= 0 ? m.engagement : 0) | m in MARKET_ENGAGEMENTS : m.type == "AFRR_R2_VOLUNTARY_DOWN"];
// We aggregate afrr engagements
// Total engaged power, in kW, in aFRR up over aFRR voluntary step afrr_v, (afrr_v in isAFRR_VOLUNTARY_STEPS)
float aFRRUpEngPower[afrr_v in isAFRR_VOLUNTARY_STEPS] = aFRRUpCapacityEngPower[voluntaryAfrrStepCapacityStep[afrr_v]] + aFRRUpVoluntaryEngPower[afrr_v];
// Total engaged power, in kW, in aFRR up over aFRR voluntary step afrr_v, (afrr_v in isAFRR_VOLUNTARY_STEPS)
float aFRRDwnEngPower[afrr_v in isAFRR_VOLUNTARY_STEPS] = aFRRDwnCapacityEngPower[voluntaryAfrrStepCapacityStep[afrr_v]] + aFRRDwnVoluntaryEngPower[afrr_v];
// indexing set of steps when there is no aFRR engagements
// Will be used to determine starting point of some constraints
{string} isNotEngagedAFRRSteps = {afrr_v | afrr_v in isAFRR_VOLUNTARY_STEPS :aFRRUpEngPower[afrr_v] == 0.0 && aFRRDwnEngPower[afrr_v] == 0.0};
	
// Required power, in kW, in aFRR Up over aFRR voluntary step afrr_v, (afrr_v in isAFRR_VOLUNTARY_STEPS)
// accounts for partial availability of aFRR assets and grid connection
// Not totally accurate, we could do aFRR up without injecting to the grid, or at least not as much
float aFRRUpReqPower[afrr_v in isAFRR_VOLUNTARY_STEPS] = maxl(0.0, minl( 
		aFRRUpEngPower[afrr_v],  
	  	min(t in isDECISION_STEPS: assetStepAfrrVoluntaryStep[t] == afrr_v) (afrrUpAvailPower[t]),
	    maxl(0,min (s in isASSETS inter {"MOPABLOEM_PDL_out"}, t in isDECISION_STEPS: assetStepAfrrVoluntaryStep[t] == afrr_v) maxNFElecLoad[s][t]) 
	    ));		
float aFRRDwnReqPower[afrr_v in isAFRR_VOLUNTARY_STEPS] = maxl(0.0, minl(
		aFRRDwnEngPower[afrr_v],
		min(t in isDECISION_STEPS: assetStepAfrrVoluntaryStep[t] == afrr_v) (afrrDwnAvailPower[t]),
		maxl(0,min(s in isASSETS inter {"MOPABLOEM_PDL_in"}, t in isDECISION_STEPS: assetStepAfrrVoluntaryStep[t] == afrr_v) maxNFElecLoad[s][t])
		));		

// negative imbalance price (expressed in currency unit per kWh) applied if energy engagements are not respected : less production / more consumption than engaged
// If the site is activated in upward mFRR, it must not go towards negative imbalance, otherwise it will be considered as a default of mFRR service, and then be highly expensive
// Hard coded, only for market-related microgrids, otherwise the price is equal to zero -> no impact in the objective function
float negative_imb_price[imb in isIMBALANCE_STEPS_POS] =
			(microgridName == "MICROGRID MOPABLOEM" || microgridName == "MICROGRID GP Brielle" || microgridName == "MICROGRID GP Vierpolders" || microgridName == "MICROGRID VERBERNE America"
				// Upward activation ?
				? (mFRRactivatedPower_imb[imb] < 0 || max(afrr_v in isAFRR_VOLUNTARY_STEPS : imb == voluntaryAfrrStepImbalanceStep[afrr_v])	aFRRUpReqPower[afrr_v] > 0 
					? penaltyBase * 100
					// We put an arbitrate price, way less favourable than day-ahead elec spot price
				    : (daElecPrice[imbStepHourlyStep[imb]] >= 0
				    	? daElecPrice[imbStepHourlyStep[imb]] * 1.5 + 120/1000
				    	: daElecPrice[imbStepHourlyStep[imb]] / 1.5 + 120/1000))
				: (microgridName == "MICROGRID VALOREM LIMOUX" || microgridName == "MICROGRID GEG SYNERGIE MAURIENNE"
					? (daElecPrice[imbStepHourlyStep[imb]] >= 0
				    	? (optContext == "MARKET_STRAT" ? daElecPrice[imbStepHourlyStep[imb]] * 10 : daElecPrice[imbStepHourlyStep[imb]] * 1.2)
				    	: (optContext == "MARKET_STRAT" ? daElecPrice[imbStepHourlyStep[imb]] / 10 : daElecPrice[imbStepHourlyStep[imb]] / 1.2))
					: 0));
// positive imbalance cost (expressed in currency unit per kWh) applied if energy engagements are not respected : more production / less consumption than engaged
// If the site is activated in downward mFRR, it must not go towards positive imbalance, otherwise it will be considered as a default of mFRR service, and then be highly expensive
// Hard coded, only for market-related microgrids, otherwise the price is equal to zero -> no impact in the objective function
float positive_imb_price[imb in isIMBALANCE_STEPS_POS] =
			 (microgridName == "MICROGRID MOPABLOEM" || microgridName == "MICROGRID GP Brielle" || microgridName == "MICROGRID GP Vierpolders" || microgridName == "MICROGRID VERBERNE America"
				// Downward activation ?
				? (mFRRactivatedPower_imb[imb] > 0 || max(afrr_v in isAFRR_VOLUNTARY_STEPS : imb == voluntaryAfrrStepImbalanceStep[afrr_v])	aFRRDwnReqPower[afrr_v] > 0 
				    ? -penaltyBase * 100
					// We penalize positive imbalance, lower though than PV curtailment penalty
			        :(daElecPrice[imbStepHourlyStep[imb]] >= 0
				    	? daElecPrice[imbStepHourlyStep[imb]] / 1.5 - 120/1000
				    	: daElecPrice[imbStepHourlyStep[imb]] * 1.5 - 120/1000))
			    : (microgridName == "MICROGRID VALOREM LIMOUX" || microgridName == "MICROGRID GEG SYNERGIE MAURIENNE"
					// Downward activation ?
					? (mFRRactivatedPower_imb[imb] > 0
				    	? -penaltyBase * 100
			    		// We put an arbitrate price, less favourable than day-ahead elec spot price
				    	: (daElecPrice[imbStepHourlyStep[imb]] >= 0
				    		? (optContext == "MARKET_STRAT" ? daElecPrice[imbStepHourlyStep[imb]] / 10 : daElecPrice[imbStepHourlyStep[imb]] / 1.2)
				  	   		: (optContext == "MARKET_STRAT" ? daElecPrice[imbStepHourlyStep[imb]] * 10 : daElecPrice[imbStepHourlyStep[imb]] * 1.2)))
					: 0));		
// HVAC hardcoded data
//For Mopabloem
{string} isTARGET_LEVELS = {"LOW", "NOMINAL", "HIGH"};
float dummyTargetLevelTemps[isTARGET_LEVELS] = [0.0, 25.0, 50.0];
float targetLevelTemps[isFLEX_E_LOADS][isTARGET_LEVELS] = [f : [l : dummyTargetLevelTemps[l]] | f in isFLEX_E_LOADS, l in isTARGET_LEVELS];
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
	if (operationID == "1463" || operationID == "1233")
		microgridName = "MICROGRID MOPABLOEM";
	if (operationID == "1168")
		microgridName = "MICROGRID TPL Tongatapu";
	if (operationID == "1167")
		microgridName = "VidoFleur Scheduled Assets";
	if (operationID == "1364")
		microgridName = "MICROGRID VALOREM LIMOUX";
	if (operationID == "1333")
		microgridName = "MICROGRID GEG SYNERGIE MAURIENNE";
	if (operationID == "1529")
		microgridName = "MICROGRID GP Brielle";
	if (operationID == "XXX")
		microgridName = "MICROGRID GP Vierpolders";
	if (operationID == "1597" || operationID == "1566")
		microgridName = "MICROGRID VERBERNE America";

// HARD-CODED
	for (var d in isDISP_E_GENS){

		// Default values
		aDispGenQmax[d] = 0.0;
		bDispGenQmax[d] = 0.0;
		
		// Values for MICROGRID ENERCAL Ile des Pins
		if (microgridName == "MICROGRID ENERCAL Ile des Pins") {
			aDispGenQmax[d] = -0.59749;
			bDispGenQmax[d] = 622.26356;
 		}			

		// Values for MICROGRID ENERCAL Mare
		if (microgridName == "MICROGRID ENERCAL Mare") {
			// Values for QSK23 (520kW) gensets: MAR3 & MAR5
			if (d == "ENERCAL_MARE_GE_3_NC" || d == "ENERCAL_MARE_GE_5_NC") {
				aDispGenQmax[d] = -0.59749;
				bDispGenQmax[d] = 622.26356;
			}
			// Values for QSK38 (1000kW) gensets: MAR1, MAR2 & MAR4
			if (d == "ENERCAL_MARE_GE_1_NC" || d == "ENERCAL_MARE_GE_2_NC" || d == "ENERCAL_MARE_GE_4_NC") {
				aDispGenQmax[d] = -0.37;
				bDispGenQmax[d] = 1107.8;
			}
 		}

		// Values for MICROGRID TPL Tongatapu
		if (microgridName == "MICROGRID TPL Tongatapu") {
			// Values for Cummins (1600kW) gensets: Popua - DG Cummins
			if (d == "Tongatapu_Popua_GE1") {
				aDispGenQmax[d] = -0.3363;
				bDispGenQmax[d] = 1738.2888;
			}
			// Values for Cat (1400kW) gensets: Popua - DG Caterpillar #1 to #6
			if (d == "Tongatapu_Popua_GE2" || d == "Tongatapu_Popua_GE3" || d == "Tongatapu_Popua_GE4" || d == "Tongatapu_Popua_GE5" || d == "Tongatapu_Popua_GE6" || d == "Tongatapu_Popua_GE7") {
				aDispGenQmax[d] = -0.2889;
				bDispGenQmax[d] = 1729.6619;
			}
			// Values for MAK (2760kW) gensets: Popua - DG MAK #1 and #2
			if (d == "Tongatapu_Popua_GE8" || d == "Tongatapu_Popua_GE9") {
				aDispGenQmax[d] = -0.5003;
				bDispGenQmax[d] = 3190.2481;
			}
 		}			
	}

// HARD-CODED
	for (var i in isINTER_E_GENS){
		// Default values
		aInterGenQmax[i] = 0.0;
		bInterGenQmax[i] = 0.0;
		aInterGenQmin[i] = 0.0;
		bInterGenQmin[i] = 0.0;

//		// Values for Valorem Limoux's PV plant
//		if (microgridName == "MICROGRID VALOREM LIMOUX" && i == "VALOREM_Limoux_PV") {
//			nomPowerMin[i] = -1400.0;
//		}
	}

// HARD-CODED
	for (var s in isE_STORAGES){

		// Default values
		aStorQmaxOnDisch[s] = 0.0;
		bStorQmaxOnDisch[s] = 0.0;
		aStorQminOnDisch[s] = 0.0;
		bStorQminOnDisch[s] = 0.0;
		aStorQmaxOnCharge[s] = 0.0;
		bStorQmaxOnCharge[s] = 0.0;
		aStorQminOnCharge[s] = 0.0;
		bStorQminOnCharge[s] = 0.0;

		// Values for Valorem Limoux's BESS
		if (microgridName == "MICROGRID VALOREM LIMOUX" && s == "VALOREM_Limoux_BESS") {
			nomPowerMax[s] = 1304.0;
			nomPowerMin[s] = -1304.0;
			nomEnergyMax[s] = 2610.0;
			nomBlockNbr[s] = 1;
		}

		// Values for GEG & SYNERGIE MAURIENNE's BESS
		if (microgridName == "MICROGRID GEG SYNERGIE MAURIENNE") {
			if (s == "GEG_Batterie") {
				nomPowerMax[s] = 1000.0;
				nomPowerMin[s] = -1000.0;
				nomEnergyMax[s] = 1831.0;
				nomBlockNbr[s] = 1;
  			}
			if (s == "SYNERGIE_MAURIENNE_Batterie") {
				nomPowerMax[s] = 5600.0;
				nomPowerMin[s] = -5600.0;
				nomEnergyMax[s] = 12210.0;
				nomBlockNbr[s] = 1;
  			}
		}

		// Values for MICROGRID ENERCAL Ile des Pins
		if (microgridName == "MICROGRID ENERCAL Ile des Pins") {
			nomBlockNbr[s] = 6;
			nomPowerMin[s] = -1040.0;
			nomPowerMax[s] = 1040.0;
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] >= nomBlockNbr[s]) {
				aStorQmaxOnDisch[s] = -0.26241;		// discharge
				bStorQmaxOnDisch[s] = 1890.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;		// charge
				bStorQminOnDisch[s] = 1890.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 1890.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 1890.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-1) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 1575.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 1575.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 1575.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 1575.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-2) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 1260.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 1260.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 1260.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 1260.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-3) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 945.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 945.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 945.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 945.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-4) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 630.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 630.0;		// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 630.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 630.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-5) {
				aStorQmaxOnDisch[s] = -0.26241;	// discharge
				bStorQmaxOnDisch[s] = 315.0;		// discharge
				aStorQminOnDisch[s] = -0.26241;	// charge
				bStorQminOnDisch[s] = 315;			// charge
				aStorQmaxOnCharge[s] = -0.26241;	// discharge
				bStorQmaxOnCharge[s] = 315.0;		// discharge
				aStorQminOnCharge[s] = -0.26241;	// charge
				bStorQminOnCharge[s] = 315;			// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] <= nomBlockNbr[s]-6) {
				aStorQmaxOnDisch[s] = 0.0;		// discharge
				bStorQmaxOnDisch[s] = 0.0;		// discharge
				aStorQminOnDisch[s] = 0.0;		// charge
				bStorQminOnDisch[s] = 0.0;		// charge
				aStorQmaxOnCharge[s] = 0.0;		// discharge
				bStorQmaxOnCharge[s] = 0.0;		// discharge
				aStorQminOnCharge[s] = 0.0;		// charge
				bStorQminOnCharge[s] = 0.0;		// charge
			}
		}			
		
		// Values for MICROGRID ENERCAL Mare
		if (microgridName == "MICROGRID ENERCAL Mare") {
			nomBlockNbr[s] = 8;
			nomPowerMin[s] = -1047.0;
			nomPowerMax[s] = 1047.0;
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] >= nomBlockNbr[s]) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 2520.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 2520.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 2520.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 2520.0;		// charge
			}
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-1) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 2205.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 2205.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 2205.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 2205.0;		// charge
			}
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-2) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 1890.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 1890.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 1890.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 1890.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-3) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 1575.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 1575.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 1575.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 1575.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-4) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 1260.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 1260.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 1260.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 1260.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-5) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 945.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 945.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 945.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 945.0;		// charge
			}		
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-6) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 630.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 630.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 630.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 630.0;		// charge
			}
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-7) {
				aStorQmaxOnDisch[s] = -0.16294;	// discharge
				bStorQmaxOnDisch[s] = 315.0;		// discharge
				aStorQminOnDisch[s] = -0.16294;	// charge
				bStorQminOnDisch[s] = 315.0;		// charge
				aStorQmaxOnCharge[s] = -0.16294;	// discharge
				bStorQmaxOnCharge[s] = 315.0;		// discharge
				aStorQminOnCharge[s] = -0.16294;	// charge
				bStorQminOnCharge[s] = 315.0;		// charge
			}
			if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] <= nomBlockNbr[s]-8) {
				aStorQmaxOnDisch[s] = 0.0;		// discharge
				bStorQmaxOnDisch[s] = 0.0;		// discharge
				aStorQminOnDisch[s] = 0.0;		// charge
				bStorQminOnDisch[s] = 0.0;		// charge
				aStorQmaxOnCharge[s] = 0.0;		// discharge
				bStorQmaxOnCharge[s] = 0.0;		// discharge
				aStorQminOnCharge[s] = 0.0;		// charge
				bStorQminOnCharge[s] = 0.0;		// charge
			}
 		}

		// Values for MICROGRID TPL Tongatapu
		if (microgridName == "MICROGRID TPL Tongatapu") {
			if (s == "Tongatapu_Matatoa_BESS") {
				nomBlockNbr[s] = 3;
				nomPowerMin[s] = -6000.0;
				nomPowerMax[s] = 6000.0;
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] >= nomBlockNbr[s]) {
					aStorQmaxOnDisch[s] = -0.56575922;
					bStorQmaxOnDisch[s] = 6324.55532;
					aStorQminOnDisch[s] = -0.72075922;
					bStorQminOnDisch[s] = 6324.55532;
					aStorQmaxOnCharge[s] = -0.56575922;
					bStorQmaxOnCharge[s] = 6324.55532;
					aStorQminOnCharge[s] = -0.72075922;
					bStorQminOnCharge[s] = 6324.55532;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-1) {
					aStorQmaxOnDisch[s] = -0.56575;
					bStorQmaxOnDisch[s] = 4216.37021;
					aStorQminOnDisch[s] = -0.72075;
					bStorQminOnDisch[s] = 4216.37021;
					aStorQmaxOnCharge[s] = -0.56575;
					bStorQmaxOnCharge[s] = 4216.37021;
					aStorQminOnCharge[s] = -0.72075;
					bStorQminOnCharge[s] = 4216.37021;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-2) {
					aStorQmaxOnDisch[s] = -0.56575;
					bStorQmaxOnDisch[s] = 2108.1851;
					aStorQminOnDisch[s] = -0.72075;
					bStorQminOnDisch[s] = 2108.1851;
					aStorQmaxOnCharge[s] = -0.56575;
					bStorQmaxOnCharge[s] = 2108.1851;
					aStorQminOnCharge[s] = -0.72075;
					bStorQminOnCharge[s] = 2108.1851;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] <= nomBlockNbr[s]-3) {
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
				nomBlockNbr[s] = 3;
				nomPowerMin[s] = -7200.0;
				nomPowerMax[s] = 7200.0;
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] >= nomBlockNbr[s]) {
					aStorQmaxOnDisch[s] = -0.56754;
					bStorQmaxOnDisch[s] = 7586.31003;
					aStorQminOnDisch[s] = -0.72448;
					bStorQminOnDisch[s] = 7586.31003;
					aStorQmaxOnCharge[s] = -0.56615;
					bStorQmaxOnCharge[s] = 7586.31003;
					aStorQminOnCharge[s] = -0.7217;
					bStorQminOnCharge[s] = 7586.31003;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-1) {
					aStorQmaxOnDisch[s] = -0.56754;
					bStorQmaxOnDisch[s] = 5057.54002;
					aStorQminOnDisch[s] = -0.72448;
					bStorQminOnDisch[s] = 5057.54002;
					aStorQmaxOnCharge[s] = -0.56615;
					bStorQmaxOnCharge[s] = 5057.54002;
					aStorQminOnCharge[s] = -0.7217;
					bStorQminOnCharge[s] = 5057.54002;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-2) {
					aStorQmaxOnDisch[s] = -0.56754;
					bStorQmaxOnDisch[s] = 2528.77001;
					aStorQminOnDisch[s] = -0.72448;
					bStorQminOnDisch[s] = 2528.77001;
					aStorQmaxOnCharge[s] = -0.56615;
					bStorQmaxOnCharge[s] = 2528.77001;
					aStorQminOnCharge[s] = -0.7217;
					bStorQminOnCharge[s] = 2528.77001;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] <= nomBlockNbr[s]-3) {
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
				nomBlockNbr[s] = 6;
				nomPowerMin[s] = -13200.0;
				nomPowerMax[s] = 13200.0;
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] >= nomBlockNbr[s]) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 13910.86266;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 13910.86266;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 13910.86266;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 13910.86266;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-1) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 11592.38555;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 11592.38555;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 11592.38555;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 11592.38555;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-2) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 9273.90844;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 9273.90844;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 9273.90844;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 9273.90844;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-3) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 6955.43133;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 6955.43133;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 6955.43133;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 6955.43133;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-4) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 4636.95422;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 4636.95422;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 4636.95422;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 4636.95422;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] == nomBlockNbr[s]-5) {
					aStorQmaxOnDisch[s] = -0.56673;
					bStorQmaxOnDisch[s] = 2318.47711;
					aStorQminOnDisch[s] = -0.72279;
					bStorQminOnDisch[s] = 2318.47711;
					aStorQmaxOnCharge[s] = -0.56597;
					bStorQmaxOnCharge[s] = 2318.47711;
					aStorQminOnCharge[s] = -0.72127;
					bStorQminOnCharge[s] = 2318.47711;
				}
				if (availInverterNbr[s][Opl.first(isDECISION_STEPS)] <= nomBlockNbr[s]-6) {
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
	for (var f in isFLEX_E_LOADS){
		// Default values
		aFlexLoadQmax[f] = 0.0;
		bFlexLoadQmax[f] = 0.0;
		aFlexLoadQmin[f] = 0.0;
		bFlexLoadQmin[f] = 0.0;
	}	
// HARD-CODED
	for (var n in isNF_E_LOADS){
		
		// Default values
		aNFLoadQ[n] = 0.0;
		bNFLoadQ[n] = 0.0;
		
//		// Values for Valorem Limoux's offake
//		if (microgridName == "MICROGRID VALOREM LIMOUX" && s == "VALOREM_Limoux_PDL_in") {
//			nomPowerMax[s] = 2450.0;
//		}
//
//		// Values for Valorem Limoux's injection
//		if (microgridName == "MICROGRID VALOREM LIMOUX" && s == "VALOREM_Limoux_PDL_out") {
//			nomPowerMax[s] = 2450.0;
//		}

		// Values for MICROGRID ENERCAL Ile des Pins
		if (microgridName == "MICROGRID ENERCAL Ile des Pins") {
			aNFLoadQ[n] = 0.3349;
			bNFLoadQ[n] = 0.0;
		}		
		
		// Values for MICROGRID MICROGRID ENERCAL Mare
		if (microgridName == "MICROGRID ENERCAL Mare") {
			aNFLoadQ[n] = 0.3349;
			bNFLoadQ[n] = 0.0;
		}		

		// Values for MICROGRID TPL Tongatapu
		if (microgridName == "MICROGRID TPL Tongatapu") {
			aNFLoadQ[n] = 0.3349;
			bNFLoadQ[n] = 0.0;
		}
	}
// HARD-CODED
	for (var d in isDISP_EH_GENS){

		// Default values
		assetHeatElecRatio[d] = 1.0;
		
		// Values for MICROGRID Mopabloem
		if (microgridName == "MICROGRID MOPABLOEM")
			assetHeatElecRatio[d] = 1.9 / 1.6;
		// Values for MICROGRID Globe Plant Brielle
		if (microgridName == "MICROGRID GP Brielle")
			assetHeatElecRatio[d] = 51.8 / 43.7;
		// Values for MICROGRID Globe Plant Vierpolders
		if (microgridName == "MICROGRID GP Vierpolders")
			assetHeatElecRatio[d] = 46.1 / 43.7;
		// Values for MICROGRID Verberne America
		// CHP 1
		if (microgridName == "MICROGRID VERBERNE America" && d == "Verberne_America_CHP1")
			assetHeatElecRatio[d] = 35.9 / 55.9;
		// CHP 2
		if (microgridName == "MICROGRID VERBERNE America" && d == "Verberne_America_CHP2")
			assetHeatElecRatio[d] = 20.67 / 44.04; }
// HARD-CODED
	for (var c in isCONVS){

		// Default values
		assetEnergyConvEfficiency[c] = 1.0;
		
		// Values for MICROGRID Mopabloem
		if (microgridName == "MICROGRID MOPABLOEM")
			assetEnergyConvEfficiency[c] = 0.998;
		// Values for MICROGRID Globe Plant Brielle
		if (microgridName == "MICROGRID GP Brielle")
			assetEnergyConvEfficiency[c] = 0.998;
		// Values for MICROGRID Globe Plant Vierpolders
		if (microgridName == "MICROGRID GP Vierpolders")
			assetEnergyConvEfficiency[c] = 0.998;
		// Values for MICROGRID Verberne America
		// TO BE DONE
		if (microgridName == "MICROGRID VERBERNE America" && c == "Verberne_America_Heatpump_1")
			assetEnergyConvEfficiency[c] = 3.0;
		if (microgridName == "MICROGRID VERBERNE America" && c == "Verberne_America_Heatpump_2")
			assetEnergyConvEfficiency[c] = 3.0;
		if (microgridName == "MICROGRID VERBERNE America" && c == "Verberne_America_Heatpump_3")
			assetEnergyConvEfficiency[c] = 3.0;
		if (microgridName == "MICROGRID VERBERNE America" && c == "Verberne_America_Heatpump_4")
			assetEnergyConvEfficiency[c] = 3.0;
 }
  		
//	cplex.epgap = 0.18/100;
	//settings.displayPrecision = 10;	// 4 by default
	cplex.epopt = 1.0E-6;
	cplex.eprhs = 1.0E-6;
	cplex.epint = 1.0E-6;
	cplex.eprelax = 1.0E-6;
	if (maxOptimisationTime >= 0)
		cplex.tilim = 60 * maxOptimisationTime;
	
	//cplex.randomseed= 3 ; // OPL random seed execute
	
	//cplex.mipemphasis = 4;	
	
//	cplex.exportModel(".\\OPLtetris.sav"); //can only be called in flow control code (main)
//	cplex.exportModel(".\\OPLmicrogrid.lp"); //can only be called in flow control code (main)
//	cplex.importModel(".\\tetris.sav");	 //can only be called in flow control code (main)
}

/*********************************************************************
 * Decision variables
 *********************************************************************/
// Intermittent generation assets
/////////////////////////////////
// average power generation target (expressed in kW) for intermittent generation asset i over decision step t
// (i in INTER_E_GENS, t in DECISION_STEPS)
dvar float+ InterGenActivePower[isINTER_E_GENS][isDECISION_STEPS];
//// power generation target (expressed in kW) for intermittent generation asset i at end of decision step t
//// (i in INTER_E_GENS, t in DECISION_STEPS)
//dvar float+ InterGenActivePowerEnd[isINTER_E_GENS][isDECISION_STEPS];
// active power curtailment (expressed in kW) for intermittent generation asset i over step t
// (i in INTER_E_GENS, t in DECISION_STEPS)
dexpr float InterGenPowerCurtailment[i in isINTER_E_GENS][t in isDECISION_STEPS] = (maxInterGenActivePower[i][t] > 0 ? interGenActivePowerForecast[i][t] - InterGenActivePower[i][t] : 0.0);
// flag indicating whether intermittent generation asset i is being curtailed over step t
// (i in INTER_GENS, t in DECISION_STEPS)
dvar boolean InterGenIsCurtailed[isINTER_E_GENS][isDECISION_STEPS];
// estimation of curtailed power (expressed in kW) that is penalised for intermittent generation asset i over step t
// (i in isINTER_E_GENS, t in DECISION_STEPS) 
dexpr float InterGenCurtEstimation[i in isINTER_E_GENS][t in isDECISION_STEPS] = (
	interGenCurtEstimationMethod[i] == "FORECAST_BASED"
		? InterGenPowerCurtailment[i][t]
		: InterGenPowerCurtailment[i][t] + InterGenIsCurtailed[i][t] * (maxInterGenActivePower[i][t] - interGenActivePowerForecast[i][t]));
// max reactive power generation (expressed in kVAR) for intermittent generation asset i over decision step t 
// (i in INTER_GENS,t in DECISION_STEPS)
dexpr float InterGenMaxReactivePower[i in isINTER_E_GENS][t in isDECISION_STEPS] = (
	(maxl(maxInterGenActivePower[i][t], interGenActivePowerForecast[i][t]) > 0.0)
		? aInterGenQmax[i] * InterGenActivePower[i][t] + bInterGenQmax[i]
		: 0.0
	);
// min reactive power generation (expressed in kVAR) for intermittent generation asset i over decision step t
// (i in INTER_GENS,t in DECISION_STEPS)
dexpr float InterGenMinReactivePower[i in isINTER_E_GENS][t in isDECISION_STEPS] = (
	(maxl(maxInterGenActivePower[i][t], interGenActivePowerForecast[i][t]) > 0.0)
		? aInterGenQmin[i] * InterGenActivePower[i][t] + bInterGenQmin[i]
		: 0.0
	);
// reactive power generation (expressed in kVAR) for intermittent generation asset i over decision step t 
// (i in INTER_GENS,t in DECISION_STEPS)
dvar float+ InterGenReactivePower[isINTER_E_GENS][isDECISION_STEPS];
// Storage assets
/////////////////
// average power injection target (expressed in kW) into the microgrid for storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorACPowerDischarge[isE_STORAGES][isDECISION_STEPS];
// average power extraction target (expressed in kW) from the microgrid for storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorACPowerCharge[isE_STORAGES][isDECISION_STEPS];
// average power target (expressed in kW) for storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
// positive values = power injections (discharges) and negative values = power extractions (charges) 
dexpr float StorACActivePower[s in isE_STORAGES][t in isDECISION_STEPS] = StorACPowerDischarge[s][t] - StorACPowerCharge[s][t];
// average power target increase (expressed in kW) for storage asset s between decision steps t-1 and t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorACActivePowerInc[isE_STORAGES][isDECISION_STEPS];
// average power target decrease (expressed in kW) for storage asset s between decision steps t-1 and t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorACActivePowerDec[isE_STORAGES][isDECISION_STEPS];
// flag indicating if storage asset s�s injection target for decision step t corresponds to a charge or a discharge
// (s in E_STORAGES union H_STORAGE, t in DECISION_STEPS)
// 1 means charge, 0 means discharge or nothing
dvar boolean IsCharging[isE_STORAGES union isH_STORAGES][isDECISION_STEPS];
// flag indicating if storage asset s�s injection target for decision step t corresponds to a charge or a discharge
// (s in E_STORAGES union H_STORAGE, t in DECISION_STEPS)
// 1 means discharge, 0 means charge or nothing
dvar boolean IsDischarging[isE_STORAGES union isH_STORAGES][isDECISION_STEPS];
// flag indicating if variable charge efficiency model segment se is used for asset storage s over decision step t
// 1 means it is used, 0 that it is not
// (isE_STORAGES, s in VAR_Eff_SEGS, t in DECISION_STEPS)
dvar boolean  StorACSegChargeFlag[isE_STORAGES][1..maxChargeSegNbr][isDECISION_STEPS];
// flag indicating if variable discharge efficiency model segment se is used for asset storage s over decision step t
// 1 means it is used, 0 that it is not
// (isE_STORAGES, s in VAR_Eff_SEGS, t in DECISION_STEPS)
dvar boolean StorACSegDischFlag[isE_STORAGES][1..maxDischSegNbr][isDECISION_STEPS];
// the average charge power (expressed in kw) of the segment se, of the variable efficiency model, used for storing asset s during decision step t
// (isE_STORAGES, se in 1..maxChargeSegNbr, t in DECISION_STEPS)
dvar float+ StorACSegPowerCharge[isE_STORAGES][1..maxChargeSegNbr][isDECISION_STEPS];
// the average discharge power (expressed in kw) of the segment se, of the variable efficiency model, used for storing asset s during decision step t
// (isE_STORAGES, se in 1..maxDischSegNbr, t in DECISION_STEPS)
dvar float+ StorACSegPowerDischarge[isE_STORAGES][1..maxDischSegNbr][isDECISION_STEPS];
// flag indicating if all storage assets s that have a strictly positive storMaxACActivePowerCharge, are full on decision step t
// (t in DECISION_STEPS)
// 1 means all charged, 0 they are not all charged
dvar boolean AreAllStoragesFull[isDECISION_STEPS];
// DC Power Charge
dvar float+ StorDCPowerCharge[isE_STORAGES][isDECISION_STEPS];
// DC Power Discharge
dvar float+ StorDCPowerDischarge[isE_STORAGES][isDECISION_STEPS];
// incremental energy charge / discharge target (expressed in kWh) for storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
// positive values mean energy inputs into the asset, negative values mean energy output from the asset
dvar float StorStepDCEnergyIn[isE_STORAGES][isDECISION_STEPS];
// energy charge target (expressed in kWh) for storage asset s at the end of decision step t
// (s in STORAGES, t in DECISION_STEPS)
dvar float+ StorStoredDCEnergy[isE_STORAGES][isDECISION_STEPS];
// SOC target (expressed as a % of asset's maximum  elec energy storage capacity) for elec asset storage s over decision step t
// (a in isE_STORAGES, t in DECISION_STEPS)
dexpr float ElecStorSocTarget[s in isE_STORAGES][t in isDECISION_STEPS] = (storMaxDCEnergy[s][t] > 0.0 ? 100 * StorStoredDCEnergy[s][t] / storMaxDCEnergy[s][t] : 0.0);
// active power raise reserve (expressed in kW) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorActiveRaiseReserve[s in isE_STORAGES][t in isDECISION_STEPS] = storMaxACActivePowerDischarge[s][t] - StorACActivePower[s][t];
// active power lower reserve (expressed in kW) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorActiveLowerReserve[s in isE_STORAGES][t in isDECISION_STEPS] = storMaxACActivePowerCharge[s][t] + StorACActivePower[s][t];
// max reactive power (expressed in kVAR) for storage asset s over decision step t if s is discharging active power over t
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorMaxReactivePowerOnDischarge[s in isE_STORAGES][t in isDECISION_STEPS] = (
	storMaxACActivePowerDischarge[s][t] > 0.0
		? aStorQmaxOnDisch[s] * StorACPowerDischarge[s][t] + bStorQmaxOnDisch[s] * IsDischarging[s][t]
		: 0.0
	);
// min reactive power (expressed in kVAR) for storage asset s over decision step t if s is discharging active power over t
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorMinReactivePowerOnDischarge[s in isE_STORAGES][t in isDECISION_STEPS] = (
	storMaxACActivePowerDischarge[s][t] > 0.0
		? aStorQminOnDisch[s] * StorACPowerDischarge[s][t] + bStorQminOnDisch[s] * IsDischarging[s][t]
		: 0.0
	);
// reactive power discharge (expressed in kVAR) for storage asset s over decision step t 
// (s in STORAGES,t in DECISION_STEPS)
dvar float+ StorReactivePowerDischarge[isE_STORAGES][isDECISION_STEPS];
// min reactive power charge (expressed in kVAR) for storage asset s over decision step t if s is charging active power over t
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorMinReactivePowerOnCharge[s in isE_STORAGES][t in isDECISION_STEPS] = (
	storMaxACActivePowerCharge[s][t] > 0.0
		? aStorQminOnCharge[s] * StorACPowerCharge[s][t] + bStorQminOnCharge[s] * IsCharging[s][t]
		: 0.0
	);
// max reactive power charge (expressed in kVAR) for storage asset s over decision step t if s is charging active power over t
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorMaxReactivePowerOnCharge[s in isE_STORAGES][t in isDECISION_STEPS] = (
	storMaxACActivePowerCharge[s][t] > 0.0
		? aStorQmaxOnCharge[s] * StorACPowerCharge[s][t] + bStorQmaxOnCharge[s] * IsCharging[s][t]
		: 0.0
	);
// reactive power charge (expressed in kVAR) for storage asset s over decision step t 
// (s in STORAGES,t in DECISION_STEPS)
dvar float+ StorReactivePowerCharge[isE_STORAGES][isDECISION_STEPS];
// reactive power (expressed in kVAR) for storage asset s over decision step t 
// (s in STORAGES,t in DECISION_STEPS)
dexpr float StorReactivePower[s in isE_STORAGES][t in isDECISION_STEPS] = StorReactivePowerDischarge[s][t] - StorReactivePowerCharge[s][t];
// reactive power raise reserve (expressed in kVAR) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorReactiveRaiseReserve[s in isE_STORAGES][t in isDECISION_STEPS] = StorMaxReactivePowerOnDischarge[s][t] + StorMaxReactivePowerOnCharge[s][t] - StorReactivePower[s][t];
// active power lower reserve (expressed in kW) from storage asset s over decision step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorReactiveLowerReserve[s in isE_STORAGES][t in isDECISION_STEPS] = StorMinReactivePowerOnDischarge[s][t] + StorMinReactivePowerOnCharge[s][t] + StorReactivePower[s][t];
// spinning raise reserve (expressed in kW) from elec storage asset s over decision step t
// (s in E_STORAGES, t in DECISION_STEPS)
dvar float+ StorSpinRaiseReserve[isE_STORAGES][isDECISION_STEPS];
// spinning lower reserve (expressed in kW) from elec storage asset s over decision step t
// (s in E_STORAGES, t in DECISION_STEPS)
dvar float+ StorSpinLowerReserve[isE_STORAGES][isDECISION_STEPS];
// Connection to grid
/////////////////////
// average power (expressed in kW) imported from the main grid into the microgrid over decision step t
// (t in DECISION_STEPS)
// positive values mean power flows into the microgrid, negative values mean power flows out of the microgrid
dvar float NetElecImportTarget[isDECISION_STEPS];
// average power (expressed in kW) imported from the main grid into the microgrid decision step t
// (t in DECISION_STEPS)
// strictly positive values mean power flows into the microgrid, zero values mean power flows out of the microgrid.
dvar float+ ImportTarget[isDECISION_STEPS];
// flag indicating if microgrid is importing power from the main grid over decision step t (t in DECISION_STEPS)
// ones mean microgrid is importing and zeros mean microgrid is exporting
dvar boolean IsImporting[isDECISION_STEPS];
// Non-Flexible elec loads
//////////////////////////
// average active power consumption target (expressed in kW) for non-flexible load unit n over decision step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadActivePower[n in isNF_E_LOADS][t in isDECISION_STEPS] = NFElecLoadForecast[n][t];
// average reactive power consumption target (expressed in kVAR) for non-flexible load unit n over decision step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadReactivePower[n in isNF_E_LOADS][t in isDECISION_STEPS] = (
	NFElecLoadForecast[n][t] > 0.0
		? aNFLoadQ[n] * NFLoadActivePower[n][t] + bNFLoadQ[n]
		: 0.0
	);
// Non-Flexible heat loads
//////////////////////////
// average heat consumption target (expressed in kW) for non-flexible heat load n over decision step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadHeat[n in isNF_H_LOADS][t in isDECISION_STEPS] = NFHeatLoadForecast[n][t];
// Flexible elec loads
//////////////////////
// average power consumption target (expressed in kW) for flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadActivePower[isFLEX_E_LOADS][isDECISION_STEPS];
// average power modulation target (expressed in kW) for flexible load unit f away from its nominal consumption forecast
// over decision step t (f in LOADS, t in DECISION_STEPS)
// positive values mean additional consumption on top of nominal consumption forecasts
// negative values result in consumptions lower than nominal consumption forecasts
dvar float ModulationTarget[isFLEX_E_LOADS][isDECISION_STEPS];
// active power raise reserve (expressed in kW) from flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadActiveRaiseReserve[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = (flexLoadAvail[f][t] == 1 ? FlexLoadActivePower[f][t] - minFlexLoad[f] : 0.0);
// active power lower reserve (expressed in kW) from flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadActiveLowerReserve[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = (flexLoadAvail[f][t] == 1 ? maxFlexLoad[f] - FlexLoadActivePower[f][t] : 0.0);
// max reactive power consumption (expressed in kVAR) for flexible load unit f over decision step t 
// (f in FLEX_LOADS,t in DECISION_STEPS)
dexpr float FlexLoadMaxReactivePower[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = (
	(maxl(maxFlexLoad[f],flexLoadForecast[f][t]) > 0.0 &&  flexLoadAvail[f][t] == 1)
		? aFlexLoadQmax[f] * FlexLoadActivePower[f][t] + bFlexLoadQmax[f]
		: 0.0
	);
// min reactive power consumption (expressed in kVAR) for flexible load unit f over decision step t 
// (f in FLEX_LOADS,t in DECISION_STEPS)
dexpr float FlexLoadMinReactivePower[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = (
	(minFlexLoad[f] > 0.0 && flexLoadAvail[f][t] == 1)
		? aFlexLoadQmin[f] * FlexLoadActivePower[f][t] + bFlexLoadQmin[f]
		: 0.0
	);
// reactive power consumption (expressed in kVAR) for flexible load unit f over decision step t 
// (f in FLEX_LOADS,t in DECISION_STEPS)
dvar float+ FlexLoadReactivePower[isFLEX_E_LOADS][isDECISION_STEPS];
// reactive power raise reserve (expressed in kVAR) from flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadReactiveRaiseReserve[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = FlexLoadReactivePower[f][t] - FlexLoadMinReactivePower[f][t];
// reactive power lower reserve (expressed in kW) from flexible load unit f over decision step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadReactiveLowerReserve[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = FlexLoadMaxReactivePower[f][t] - FlexLoadReactivePower[f][t];
// spinning raise reserve (expressed in kW) from flexible elc load unit f over decision step t
// (f in FLEX_E_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadSpinRaiseReserve[isFLEX_E_LOADS][isDECISION_STEPS];
// spinning lower reserve (expressed in kW) from flexible elec unit f over decision step t
// (f in FLEX_E_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadSpinLowerReserve[isFLEX_E_LOADS][isDECISION_STEPS];
// dispatchable elec generators
///////////////////////////////
//flag indicating if a dispatchable generator d is on at decision step t
// 1 means it is on, 0 that it is off
// (d in DISP_GENS, t in DECISION_STEPS)
dvar boolean IsGenOn[isDISP_E_GENS][isDECISION_STEPS];
// flag indicating if non-linear variable cost model segment s is used for generator g over decision step t 
// 1 means it is used, 0 that it is not
// (g in NL_COST_GENS, s in VAR_COST_SEGS, t in DECISION_STEPS)
dvar boolean GenVarCostSegFlag[isNL_COST_E_GENS][s in 1..maxSegNbr][isDECISION_STEPS];
// COST-SEG-CHANGE
//// number of non-linear variable cost model segment used for dispatchable generator g over decision step t 
//// (g in NL_COST_GENS, t in DECISION_STEPS)
//dexpr int GenVarCostSegNbr[g in NL_COST_GENS][t in isDECISION_STEPS] = sum (s in 1..maxSegNbr) GenVarCostSegFlag[g][s][t];
// COST-SEG-CHANGE
//// flag indicating if there is a change of non-linear variable cost model segment for generator g in decision step t (compred to t-1) 
//// 1 means there is a chnage, 0 means that g is using the same segment in step t as in step t-1
//// (g in NL_COST_GENS, t in DECISION_STEPS)
//dvar boolean GenVarCostSegChange[isNL_COST_E_GENS][isDECISION_STEPS];
//part (power in kw) of non-linear variable cost model segment s is used for generator g over decision step t
// (g in NL_COST_GENS, s in VAR_COST_SEGS,t in DECISION_STEPS)
dvar float+ GenVarCostSegPower [isNL_COST_E_GENS][s in 1..maxSegNbr][isDECISION_STEPS];
// average active power generation (expressed in kW) for dispatchable generator d over decision step t 
// (d in DISP_GENS,t in DECISION_STEPS)
//dexpr float DispGenActivePower[d in isDISP_E_GENS][t in isDECISION_STEPS] = sum (s in 1..varCostModelSegNumber[genVarCostModelId[d]]) GenVarCostSegPower[d][s][t]; // slows opt down
dvar float+ DispGenActivePower[isDISP_E_GENS][isDECISION_STEPS];
// effective average active power generation (expressed in kW) for dispatchable generator d over decision step t (accounts for ramp rates)
// (d in DISP_GENS,t in DECISION_STEPS)
dvar float+ DispGenEffActivePower[isDISP_E_GENS][isDECISION_STEPS];
//// power generation target (expressed in kW) for dispatchable generation asset d at end of decision step t
//// (d in isDISP_E_GENS, t in DECISION_STEPS)
//dvar float+ DispGenActivePowerEnd[isDISP_E_GENS][isDECISION_STEPS];
// generation variable cost (expressed in currency unit/h) for generator with non-linear variable costs g over step t 
// (g in NL_COST_GENS,t in DECISION_STEPS)
// dexpr float GenNonLinVarCost[g in isNL_COST_E_GENS][t in isDECISION_STEPS] = sum (s in 1..varCostModelSegNumber[genVarCostModelId[g]]) varCostSegCost[genVarCostModelId[g]][s] * GenVarCostSegPower[g][s][t]; // slows opt down
dvar float+ GenNonLinVarCost[isNL_COST_E_GENS][isDECISION_STEPS];
// indicator giving evolution of each dispatchable generator d's status between decision step t and the previous one. 
// -1 means d is shut down at t, 0 means d stays on or stays off, and +1 means d is started
// (d in DISP_GENS,t in DECISION_STEPS)
dvar int GenOnEvol[isDISP_E_GENS][isDECISION_STEPS];
// flag indicating if disp generator d is started up at decision step t
// 1 means it is started up, 0 that it is not
dvar boolean DispGenStartup[isDISP_E_GENS][isDECISION_STEPS];
// active power raise reserve (expressed in kW) from dispatchable generator d over decision step t
// (d in DISP_GENS, t in DECISION_STEPS)
dexpr float DispGenActiveRaiseReserve[d in isDISP_E_GENS][t in isDECISION_STEPS] = IsGenOn[d][t] * maxDispGenActivePower[d] - DispGenActivePower[d][t];
// max reactive power generation (expressed in kVAR) for dispatchable generator d over decision step t 
// (d in DISP_GENS,t in DECISION_STEPS)
dexpr float DispGenMaxReactivePower[d in isDISP_E_GENS][t in isDECISION_STEPS] = aDispGenQmax[d] * DispGenActivePower[d][t] + IsGenOn[d][t] * bDispGenQmax[d];
// reactive power generation (expressed in kVAR) for dispatchable generator d over decision step t 
// (d in DISP_GENS,t in DECISION_STEPS)
dvar float+ DispGenReactivePower[isDISP_E_GENS][isDECISION_STEPS];
// reactive power raise reserve (expressed in kVAR) from dispatchable generator d over decision step t
// (d in DISP_GENS, t in DECISION_STEPS)
dexpr float DispGenReactiveRaiseReserve[d in isDISP_E_GENS][t in isDECISION_STEPS] = DispGenMaxReactivePower[d][t] - DispGenReactivePower[d][t];
// spinning raise reserve (expressed in kW) from dispatchable gen d over decision step t
// (d in DISP_GENS, t in DECISION_STEPS)
dvar float+ DispGenSpinRaiseReserve[isDISP_GENS][isDECISION_STEPS];
// spinning lower reserve (expressed in kW) from dispatchable gen d over decision step t
// (d in DISP_GENS, t in DECISION_STEPS)
dvar float+ DispGenSpinLowerReserve[isDISP_GENS][isDECISION_STEPS];
// average heat generation (expressed in kW) for dispatchable generator d over decision step t
// (d in DISP_H_GENS, t in DECISION_STEPS)
dvar float+ DispGenHeat[isDISP_H_GENS][isDECISION_STEPS];
// Heat storage assets
//////////////////////
// average heat injection target (expressed in kW) into the microgrid for storage asset s over decision step t
// (s in H_STORAGES, t in DECISION_STEPS)
dvar float+ StorHeatDischarge[isH_STORAGES][isDECISION_STEPS];
// average heat extraction target (expressed in kW) from the microgrid for storage asset s over decision step t
// (s in H_STORAGES, t in DECISION_STEPS)
dvar float+ StorHeatCharge[isH_STORAGES][isDECISION_STEPS];
//// flag indicating if storage asset s�s injection target for decision step t corresponds to a charge or a discharge
//// (s in H_STORAGES, t in DECISION_STEPS)
//// 1 means charge, 0 means discharge
//dvar boolean IsCharging[isE_STORAGES][isDECISION_STEPS];
// incremental heat charge / discharge target (expressed in kWh) for storage asset s over decision step t
// (s in H_STORAGES, t in DECISION_STEPS)
// positive values mean heat inputs into the asset, negative values mean heat output from the asset
dvar float StorStepHeatIn[isH_STORAGES][isDECISION_STEPS];
// heat charge target (expressed in kWh) for storage asset s at the end of decision step t
// (s in H_STORAGES, t in DECISION_STEPS)
dvar float+ StorStoredHeat[isH_STORAGES][isDECISION_STEPS];
// average heat target (expressed in kW) for storage asset s over decision step t
// (s in H_STORAGES, t in DECISION_STEPS)
// positive values = heat injections (discharges) and negative values = heat extractions (charges)
dexpr float StorHeatExchange[s in isH_STORAGES][t in isDECISION_STEPS] = StorHeatDischarge[s][t] - StorHeatCharge[s][t];
// Soc target (expressed as a % of asset's maximum  Heat energy storage capacity) for Heat asset storage s over decision step t
// (a in isH_STORAGES, t in DECISION_STEPS)
dexpr float HeatStorSocTarget[h in isH_STORAGES][t in isDECISION_STEPS] = 100 * StorStoredHeat[h][t] / storMaxHeatCharge[h];
// Energy converters
////////////////////
// average elec power consumption (expressed in kW) for energy converter c over decision step t
// (c in EIN_CONVS, t in DECISION_STEPS)
dvar float+ ConvActivePowerIn[isEIN_CONVS][isDECISION_STEPS];
// average heat power generation (expressed in kW) for energy converter c over decision step t
// (c in HOUT_CONVS, t in DECISION_STEPS)
dvar float+ ConvHeatOut[isHOUT_CONVS][isDECISION_STEPS];
// Flag indicating if converter c is on (1) or iff (0) over decision step t
// (c in isCONVS, t in DECISION_STEPS)
dvar boolean IsConvOn[isCONVS][isDECISION_STEPS];
/* Market*/
////////////////////////////////
// agregated average power (expressed in kW) imported from the main grid into the microgrid over mFRR step mfrr, (mfrr in ismFRR_STEPS)
// positive values mean power flows into the microgrid, negative values mean power flows out of the microgrid
dexpr float NetElecImportTarget_mfrr[mfrr in ismFRR_STEPS_POS] = sum(t in isDECISION_STEPS : mfrr == assetStepmFRRStep[t]) NetElecImportTarget[t] /
															 sum(t in isDECISION_STEPS : mfrr == assetStepmFRRStep[t]) 1;
// agregated average power (expressed in kW) imported from the main grid into the microgrid over imbalance step imb
// (imb in isIMBALANCE_STEPS)
// positive values mean power flows into the microgrid, negative values mean power flows out of the microgrid
dexpr float NetElecImportTarget_imb[imb in isIMBALANCE_STEPS_POS] = sum(t in isDECISION_STEPS : imb == assetStepImbalanceStep[t]) NetElecImportTarget[t]/
																sum(t in isDECISION_STEPS : imb == assetStepImbalanceStep[t]) 1;
// Power, expressed in kW, which represent, at an imabalance step imb, the positive value of the difference between real grid exchanges and market engagements
// It is equivalent to over production or less consumption than expected
dvar float+ PositiveImbalancePower_imb[isIMBALANCE_STEPS];
// Power, expressed in kW, which represent, at an imabalance step imb, the negatie value of the difference between real grid exchanges and market engagements
// It is equivalent to over production or less consumption than expected
dvar float+ NegativeImbalancePower_imb[isIMBALANCE_STEPS];
// Power, expressed in kW, which represent, at an imabalance step imb, the difference between real grid exchanges and market engagements
// Positive values means over production or less consumption than expected, whereas negative values means more consumption or less production than expected
dexpr float ImbalancePower_imb[imb in isIMBALANCE_STEPS_POS] = PositiveImbalancePower_imb[imb] - NegativeImbalancePower_imb[imb];
// Power, expressed in kW, which represent, at an asset step t, the difference between real grid exchanges and market engagements
// Positive values means over production or less consumption than expected, whereas negative values means more consumption or less production than expected
dvar float ImbalancePower_mfrr[ismFRR_STEPS];
// Flag indicating if imbalances are positive or negative
dvar boolean IsPositiveImbalance_imb[isIMBALANCE_STEPS];
// Imbalance cost over imbalance step im
// Offer made on the day-ahead market for DA step hr expressed in kW (> 0 means purchase / < 0 means sale)
// (hr in isHOURLY_STEPS)
dvar float DAOffer[isHOURLY_STEPS];
//dvar int DAOffer100kW[isHOURLY_STEPS];
// Position taken on the day-ahead market fro DA step hr expressed in kW (> 0 means purchase / < 0 means sale)
// If hr has already been cleared then position is fixed, otherwise it is up to optimisation
// (hr in isHOURLY_STEPS)
dexpr float DaPosition[hr in isHOURLY_STEPS] = (isDAStepCleared[hr] == 1 ? daEngagement[hr] : DAOffer[hr]);
//dexpr float DaPosition[hr in isHOURLY_STEPS] = (isDAStepCleared[hr] == 1 ? daEngagement[hr] : DAOffer100kW[hr] * 100);
/*FCR*/
//Flag indicating wether 1MW is engaged (1) or not (0).
dvar boolean FCR1MWFlag[a in isASSETS][isFCR_STEPS][s in 1..maxl(1, maxfcrCertfiedPower_MW)];
// asset's FCR engaged power (in MW)
// it does not represent the real power that goes out of the battery, but the band taken
// (fcr_a in isFCR_ASSETS, fcr in FCR_STEPS)
dexpr int FCRPower_MW[a in isASSETS][fcr in isFCR_STEPS] = sum(s in 1..maxl(1, maxfcrCertfiedPower_MW)) FCR1MWFlag[a][fcr][s];
// asset's FCR engaged power (in kW)
// (fcr_a in isFCR_ASSETS, fcr in FCR_STEPS)
dexpr int FCRPower[a in isASSETS][fcr in isFCR_STEPS] = FCRPower_MW[a][fcr] * 1000;
// Storage cycling due to FCR
dvar float StorStepFCRCycle[s in isSTORAGES][isDECISION_STEPS];

/*aFRR*/
// Maximum power of service, in kW, which an asset participates to aFRR up, on a voluntary step afrr_v, to reach aFRR up commitment, whether through capacity or voluntary participation
dvar float+ AFRRCapacityPowerUp[isASSETS][isAFRR_VOLUNTARY_STEPS];
// idem, in MW
dexpr float AFRRCapacityPowerUp_MW[a in isASSETS][afrr_v in isAFRR_VOLUNTARY_STEPS] = AFRRCapacityPowerUp[a][afrr_v] / 1000;
// Maximum power of service, in kW, which an asset participates to aFRR down, on a voluntary step afrr_v, to reach aFRR down commitment, whether through capacity or voluntary participation
dvar float+ AFRRCapacityPowerDwn[isASSETS][isAFRR_VOLUNTARY_STEPS];
// idem, in MW
dexpr float AFRRCapacityPowerDwn_MW[a in isASSETS][afrr_v in isAFRR_VOLUNTARY_STEPS] = AFRRCapacityPowerDwn[a][afrr_v] / 1000;
// Violation variable of the engaged aFRR up Power. this decision variable is used in cases where the power engaged in aFRR up is greater than the sum of availabe power afrr up within the pool to relax the ctAFRRUpPoolEngagement constraint.
dvar float+ AFRRUpCapacityDeficit[isAFRR_VOLUNTARY_STEPS];
// Violation variable of the engaged aFRR down Power. this decision variable is used in cases where the power engaged in aFRR down is greater than the sum of availabe power afrr down within the pool to relax the ctAFRRUpPoolEngagement constraint.
dvar float+ AFRRDwnCapacityDeficit[isAFRR_VOLUNTARY_STEPS];
// aFRR Up eng deficit cost over afrr_v in isAFRR_VOLUNTARY_STEPS_POS
dexpr float AFRRUpPowerEngDeficitCost[afrr_v in isAFRR_VOLUNTARY_STEPS_POS] =  AFRRUpPowerEngDeficitPenaltyCost * afrrVoluntaryStepDuration * AFRRUpCapacityDeficit[afrr_v];
// aFRR Down eng deficit cost over afrr_v in isAFRR_VOLUNTARY_STEPS_POS
dexpr float AFRRDwnPowerEngDeficitCost[afrr_v in isAFRR_VOLUNTARY_STEPS_POS] =  AFRRDwnPowerEngDeficitPenaltyCost * afrrVoluntaryStepDuration * AFRRDwnCapacityDeficit[afrr_v];

// Available energy, for limited energy sotrage s, to participate aFRR up
// We suppose here that all available energy of the asset can serve to aFRR; It might not be the case for stand-alone assets
// We set a minimum to 0 such that if min soc is not respected we don't have an unfeasability with ctMinAvailEnergyAfrrUp given a negative AFRRUpAvailEnergyAC
dexpr float AFRRUpAvailEnergyAC[s in isSTORAGES inter isaFRRUp_ASSETS][t in isDECISION_STEPS] = maxl(0, (StorStoredDCEnergy[s][t] - (storElecMinSOC[s] / 100) * storMaxDCEnergy[s][t]) * (storefficiencyaFRR/100));
// Available energy, for limited energy sotrage s, to participate aFRR down
// We suppose here that all available energy of the asset can serve to aFRR; It might not be the case for stand-alone assets
// We set a minimum to 0 such that if max soc is not respected we don't have an unfeasability with ctMinAvailEnergyAfrrDwnp given a negative AFRRDwnAvailEnergyAC
dexpr float AFRRDwnAvailEnergyAC[s in isSTORAGES inter isaFRRDwn_ASSETS][t in isDECISION_STEPS] = maxl(0,((storElecMaxSOC[s] / 100) * storMaxDCEnergy[s][t] - StorStoredDCEnergy[s][t]) * (100/storefficiencyaFRR));
// Flag indicating whether an asset is doing aFRR up or not. Usefull to block multi-mecanisms.
dvar boolean IsAFRRUp[isASSETS][isAFRR_VOLUNTARY_STEPS];
// Flag indicating whether an asset is doing aFRR down or not. Usefull to block multi-mecanisms.
dvar boolean IsAFRRDwn[isASSETS][isAFRR_VOLUNTARY_STEPS];


// Violation variables
//////////////////////
// site maximum power input violation (that is minimum allowed too high to be compatible with the characteristics of connected assets),
// expressed in kW, for site i over decision step t (i in SITES, t in DECISION_STEPS)
dvar float+ SiteMaxInputViolation[isSITES][isDECISION_STEPS];
// site maximum power input violation cost
dexpr float SiteMaxInputViolationCost[i in isSITES][t in isDECISION_STEPS] = siteInOutViolationPenaltyCost * SiteMaxInputViolation[i][t] * assetStepDurationInHours;
// site maximum power output violation (that is maximum allowed too low to be compatible with the characteristics of connected assets),
// expressed in kW, for site i over decision step t (i in SITES, t in DECISION_STEPS).
dvar float+ SiteMaxOutputViolation[isSITES][isDECISION_STEPS];
// site maximum power output violation cost
dexpr float SiteMaxOutputViolationCost[i in isSITES][t in isDECISION_STEPS] = siteInOutViolationPenaltyCost * SiteMaxOutputViolation[i][t] * assetStepDurationInHours;
// network congestion lower limit violation (that is lower limit too high to be compatible with the characteristics of impacted assets),
// expressed in kW, for network congestion constraint c over decision step t (c in CONGESTIONS, t in DECISION_STEPS)
dvar float+ CongestionLowerLimViolation[isCONGESTIONS][isDECISION_STEPS];
// network congestion lower limit violation cost
dexpr float CongestionLowerLimViolationCost[c in isCONGESTIONS][t in isDECISION_STEPS] = siteInOutViolationPenaltyCost * CongestionLowerLimViolation[c][t] * assetStepDurationInHours;
// network congestion upper limit violation (that is upper limit too low to be compatible with the characteristics of impacted assets),
// expressed in kW, for network congestion constraint c over decision step t (c in CONGESTIONS, t in DECISION_STEPS)
dvar float+ CongestionUpperLimViolation[isCONGESTIONS][isDECISION_STEPS];
// network congestion upper limit violation cost
dexpr float CongestionUpperLimViolationCost[c in isCONGESTIONS][t in isDECISION_STEPS] = siteInOutViolationPenaltyCost * CongestionUpperLimViolation[c][t] * assetStepDurationInHours;
// average power deficit (expressed in kW) over decision step t (t in DECISION_STEPS)
dvar float+ PowerDeficit[isDECISION_STEPS];
// Power deficit penalty over decision step t (t in DECISION_STEPS)
dexpr float PowerDeficitCost[t in isDECISION_STEPS] = powerImbalancePenaltyCost * assetStepDurationInHours * PowerDeficit[t];
// average power excess (expressed in kW) over decision step t (t in DECISION_STEPS)
dvar float+ PowerExcess[isDECISION_STEPS];
// Power excess cost over decision step t (t in DECISION_STEPS)
dexpr float PowerExcessCost[t in isDECISION_STEPS] = powerImbalancePenaltyCost * assetStepDurationInHours * PowerExcess[t];
// average heat deficit (expressed in kW) over decision step t (t in DECISION_STEPS)
dvar float+ HeatDeficit[isDECISION_STEPS];
// Heat deficit cost over decision step t (t in DECISION_STEPS)
dexpr float HeatDeficitCost[t in isDECISION_STEPS] = powerImbalancePenaltyCost * assetStepDurationInHours * HeatDeficit[t];
// average heat excess (expressed in kW) over decision step t (t in DECISION_STEPS)
dvar float+ HeatExcess[isDECISION_STEPS];
// Heat Excess cost over decision step t (t in DECISION_STEPS)
dexpr float HeatExcessCost[t in isDECISION_STEPS] = powerImbalancePenaltyCost * assetStepDurationInHours * HeatExcess[t];
// SOC min deficit expressed as a percentage (s in E_STORAGES, t in DECISION_STEPS)
dvar float+ SOCminDeficit[isE_STORAGES][isDECISION_STEPS];
// SOC min deficit Cost (s in E_STORAGES, t in DECISION_STEPS)
dexpr float SOCminDeficitCost[s in isE_STORAGES][t in isDECISION_STEPS] = socMinViolationPenaltyCost * (storMaxDCEnergy[s][t] * SOCminDeficit[s][t] / 100.0);
// SOC strict min deficit expressed as a percentage (s in E_STORAGES, t in DECISION_STEPS)
dvar float+ SOCstrictMinDeficit[isE_STORAGES][isDECISION_STEPS];
// SOC strict min deficit cost (s in E_STORAGES, t in DECISION_STEPS)
dexpr float SOCstrictMinDeficitCost[s in isE_STORAGES][t in isDECISION_STEPS] = socStrictMinMaxViolationPenaltyCost * storMaxDCEnergy[s][t] * SOCstrictMinDeficit[s][t] / 100.0;
// SOC max excess expressed as a percentage (s in E_STORAGES, t in DECISION_STEPS)
dvar float+ SOCmaxExcess[isE_STORAGES][isDECISION_STEPS];
// SOC max excess Cost (s in E_STORAGES, t in DECISION_STEPS)
dexpr float SOCmaxExcessCost[s in isE_STORAGES][t in isDECISION_STEPS] = socStrictMinMaxViolationPenaltyCost * storMaxDCEnergy[s][t] * SOCmaxExcess[s][t] / 100.0;
// SOC min deficit expressed as a percentage (s in H_STORAGES, t in DECISION_STEPS)
dvar float+ HeatSOCminDeficit[isH_STORAGES][isDECISION_STEPS];
// SOC min deficit cost (s in H_STORAGES, t in DECISION_STEPS)
dexpr float HeatSOCminDeficitCost[s in isH_STORAGES][t in isDECISION_STEPS] = socStrictMinMaxViolationPenaltyCost * storMaxHeatCharge[s] * HeatSOCminDeficit[s][t]/100.0;
// SOC max excess expressed as a percentage (s in H_STORAGES, t in DECISION_STEPS)
dvar float+ HeatSOCmaxExcess[isH_STORAGES][isDECISION_STEPS];
// SOC max excess cost (s in H_STORAGES, t in DECISION_STEPS)
dexpr float HeatSOCmaxExcessCost[s in isH_STORAGES][t in isDECISION_STEPS] = socStrictMinMaxViolationPenaltyCost * storMaxHeatCharge[s] * HeatSOCmaxExcess[s][t]/100.0;
// minSocTargetDeficit expressed as a percentage (s in E_STORAGES, t in DECISION_STEPS)
dvar float+ minSocTargetStorageDeficit[isE_STORAGES][isDECISION_STEPS];
// minSocTargetDeficit cost (s in E_STORAGES, t in DECISION_STEPS)
dexpr float minSocTargetStorageDeficitCost[s in isE_STORAGES][t in isDECISION_STEPS] = minSocTargetStoragePenaltyCost * storMaxDCEnergy[s][t] * minSocTargetStorageDeficit[s][t] / 100.0;
// The number of cycles performed by the storage asset s during the step t (expressed as a ratio of the nominal maximum energy that can be stored in the asset storage s)
dexpr float CyclingStepContribution[s in isE_STORAGES][t in isDECISION_STEPS] = (nomEnergyMax[s] > 0.0 ? abs(StorStepDCEnergyIn[s][t]) / (2 * nomEnergyMax[s]) : 0.0);
//The number of cycles performed by the storage asset s before the decision step t, during (24h - stepDuraionInHour[t])
dvar float StorageNumCyclPerformedBeforeBeginStep [isE_STORAGES] [isDECISION_STEPS];
//The maximum Number of cycles performed by the asset storage s excess (expressed as a ratio of the maximum energy that can be stored)
dvar float+ StorageDailyMaxNumCyclExcess[isE_STORAGES][isDECISION_STEPS];
//Maximum Number of cycles performed by the asset storage s excess cost (expressed as a ratio of the maximum energy that can be stored)
dexpr float StorageDailyMaxNumCyclExcessCost[s in isE_STORAGES][t in isDECISION_STEPS] = storageDailyMaxCyclPenaltyCost * StorageDailyMaxNumCyclExcess[s][t] * nomEnergyMax[s];
// violation of desire to keep first step's average active power the same as it was initially for dispatchable gen d
// (d in DISP_GENS)
dvar float+ DispGenInitialPowerUpViolation[isDISP_E_GENS];
dvar float+ DispGenInitialPowerDwnViolation[isDISP_E_GENS];
dexpr float DispGenInitialPowerUpViolationCost[d in isDISP_E_GENS] = dispGenInitialPowerViolPenalty * DispGenInitialPowerUpViolation[d] * assetStepDurationInHours;
dexpr float DispGenInitialPowerDwnViolationCost[d in isDISP_E_GENS] = dispGenInitialPowerViolPenalty * DispGenInitialPowerDwnViolation[d] * assetStepDurationInHours;
// economic min active power violation for generator d over step t
// (d in DISP_GENS,t in DECISION_STEPS)
dvar float+ DispGenMinActivePowerDeficit[isDISP_E_GENS][isDECISION_STEPS];
// cost of the violation of the economic min active power for generator d over step t
// (d in DISP_GENS,t in DECISION_STEPS)
dexpr float DispGenMinActivePowerDeficitCost[d in isDISP_E_GENS][t in isDECISION_STEPS] = minDispGenActivePowerDeficitPenalty * assetStepDurationInHours * DispGenMinActivePowerDeficit[d][t];
// active power raise reserve deficit to cover the loss of dispatchable generator d over step t
// (d in DISP_GENS, t in DECISION_STEPS)
dvar float+ DispGenActivePowerRaiseReserveDeficit[isDISP_E_GENS][isDECISION_STEPS];
// active power raise reserve deficit cost of the dispatchable generator d over step t (d in DISP_GENS, t in DECISION_STEPS)
dexpr float DispGenActivePowerRaiseReserveDeficitCost[d in isDISP_E_GENS][t in isDECISION_STEPS] = activePowerRaiseReserveDeficitPenaltyCost * assetStepDurationInHours * DispGenActivePowerRaiseReserveDeficit[d][t];
// active power raise reserve deficit to cover the loss of inter gen asset i over step t
// (i in INTER_GENS, t in DECISION_STEPS)
dvar float+ InterGenActivePowerRaiseReserveDeficit[isINTER_E_GENS][isDECISION_STEPS];
// cost of the active power raise reserve deficit to cover the loss of inter gen asset i over step t
// (i in INTER_GENS, t in DECISION_STEPS)
dexpr float InterGenActivePowerRaiseReserveDeficitCost[i in isINTER_E_GENS][t in isDECISION_STEPS] = activePowerRaiseReserveDeficitPenaltyCost * assetStepDurationInHours * InterGenActivePowerRaiseReserveDeficit[i][t];
// active power raise reserve deficit to cover the loss of injection from storage asset s over step t
// (s in STORAGES, t in DECISION_STEPS) 
dvar float+ StorActivePowerRaiseReserveDeficit[isE_STORAGES][isDECISION_STEPS];
// cost of the deficit of the active power raise reserve to cover the loss of injection from storage asset s over step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorActivePowerRaiseReserveDeficitCost[s in isE_STORAGES][t in isDECISION_STEPS] = activePowerRaiseReserveDeficitPenaltyCost  * assetStepDurationInHours * StorActivePowerRaiseReserveDeficit[s][t];
// active power raise reserve deficit to cover a sudden increase of consumption from non-flexible load asset n over step t
// (n in NF_LOADS, t in DECISION_STEPS) 
dvar float+ NFLoadActivePowerRaiseReserveDeficit[isNF_E_LOADS][isDECISION_STEPS];
// cost of the deficit of the active power raise reserve to cover a sudden increase of consumption from non-flexible load asset n over step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadActivePowerRaiseReserveDeficitCost[n in isNF_E_LOADS][t in isDECISION_STEPS] = activePowerRaiseReserveDeficitPenaltyCost * assetStepDurationInHours * NFLoadActivePowerRaiseReserveDeficit[n][t];
// active power lower reserve deficit to cover a sudden increase of generation from inter gen asset i over step t
// (i in INTER_GENS, t in DECISION_STEPS) 
dvar float+ InterGenActivePowerLowerReserveDeficit[isINTER_E_GENS][isDECISION_STEPS];
// cost of the active power lower reserve deficit to cover a sudden increase of generation from inter gen asset i over step t
// (i in INTER_GENS, t in DECISION_STEPS)
dexpr float InterGenActivePowerLowerReserveDeficitCost[i in isINTER_E_GENS][t in isDECISION_STEPS] = activePowerLowerReserveDeficitPenaltyCost * assetStepDurationInHours * InterGenActivePowerLowerReserveDeficit[i][t];
// active power lower reserve deficit to cover the loss of consumption from storage asset s over step t
// (s in STORAGES, t in DECISION_STEPS) 
dvar float+ StorActivePowerLowerReserveDeficit[isE_STORAGES][isDECISION_STEPS];
// cost of the active power lower reserve deficit to cover the loss of consumption from storage asset s over step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorActivePowerLowerReserveDeficitCost[s in isE_STORAGES][t in isDECISION_STEPS] = activePowerLowerReserveDeficitPenaltyCost * assetStepDurationInHours * StorActivePowerLowerReserveDeficit[s][t];
// active power lower reserve deficit to cover sudden drop in consumption from flexible load asset f over step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadActivePowerLowerReserveDeficit[isFLEX_E_LOADS][isDECISION_STEPS];
// cost of the active power lower reserve deficit to cover sudden drop in consumption from flexible load asset f over step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadActivePowerLowerReserveDeficitCost[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = activePowerLowerReserveDeficitPenaltyCost * assetStepDurationInHours * FlexLoadActivePowerLowerReserveDeficit[f][t];
// active power lower reserve deficit to cover a sudden drop in consumption from non-flexible load asset n over step t
// (n in NF_LOADS, t in DECISION_STEPS) 
dvar float+ NFLoadActivePowerLowerReserveDeficit[isNF_E_LOADS][isDECISION_STEPS];
// cost of the active power lower reserve deficit to cover a sudden drop in consumption from non-flexible load asset n over step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadActivePowerLowerReserveDeficitCost[n in isNF_E_LOADS][t in isDECISION_STEPS] = activePowerLowerReserveDeficitPenaltyCost * assetStepDurationInHours * NFLoadActivePowerLowerReserveDeficit[n][t];
// reactive power raise reserve deficit to cover the loss of dispatchable generator d over step t
// (d in DISP_GENS, t in DECISION_STEPS)
dvar float+ DispGenReactivePowerRaiseReserveDeficit[isDISP_E_GENS][isDECISION_STEPS];
// cost of the reactive power raise reserve deficit to cover the loss of dispatchable generator d over step t
// (d in DISP_GENS, t in DECISION_STEPS)
dexpr float DispGenReactivePowerRaiseReserveDeficitCost[d in isDISP_E_GENS][t in isDECISION_STEPS] = reactivePowerRaiseReserveDeficitPenaltyCost * assetStepDurationInHours * DispGenReactivePowerRaiseReserveDeficit[d][t];
// reactive power raise reserve deficit to cover the loss of inter gen asset i over step t
// (i in INTER_GENS, t in DECISION_STEPS)
dvar float+ InterGenReactivePowerRaiseReserveDeficit[isINTER_E_GENS][isDECISION_STEPS];
// cost of the reactive power raise reserve deficit to cover the loss of inter gen asset i over step t
// (i in INTER_GENS, t in DECISION_STEPS)
dexpr float InterGenReactivePowerRaiseReserveDeficitCost[i in isINTER_E_GENS][t in isDECISION_STEPS] = reactivePowerRaiseReserveDeficitPenaltyCost * assetStepDurationInHours * InterGenReactivePowerRaiseReserveDeficit[i][t];
// reactive power raise reserve deficit to cover the loss of injection from storage asset s over step t
// (s in STORAGES, t in DECISION_STEPS) 
dvar float+ StorReactivePowerRaiseReserveDeficit[isE_STORAGES][isDECISION_STEPS];
// cost of the reactive power raise reserve deficit to cover the loss of injection from storage asset s over step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorReactivePowerRaiseReserveDeficitCost[s in isE_STORAGES][t in isDECISION_STEPS] = reactivePowerRaiseReserveDeficitPenaltyCost * assetStepDurationInHours * StorReactivePowerRaiseReserveDeficit[s][t];
// reactive power raise reserve deficit to cover a sudden increase of consumption from non-flexible load asset n over step t
// (n in NF_LOADS, t in DECISION_STEPS) 
dvar float+ NFLoadReactivePowerRaiseReserveDeficit[isNF_E_LOADS][isDECISION_STEPS];
// cost of th reactive power raise reserve deficit to cover a sudden increase of consumption from non-flexible load asset n over step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadReactivePowerRaiseReserveDeficitCost[n in isNF_E_LOADS][t in isDECISION_STEPS] = reactivePowerRaiseReserveDeficitPenaltyCost * assetStepDurationInHours * NFLoadReactivePowerRaiseReserveDeficit[n][t];
// reactive power lower reserve deficit to cover a sudden increase of generation from inter gen asset i over step t
// (i in INTER_GENS, t in DECISION_STEPS) 
dvar float+ InterGenReactivePowerLowerReserveDeficit[isINTER_E_GENS][isDECISION_STEPS];
// cost of the reactive power lower reserve deficit to cover a sudden increase of generation from inter gen asset i over step t
// (i in INTER_GENS, t in DECISION_STEPS)
dexpr float InterGenReactivePowerLowerReserveDeficitCost[i in isINTER_E_GENS][t in isDECISION_STEPS] = reactivePowerLowerReserveDeficitPenaltyCost * assetStepDurationInHours * InterGenReactivePowerLowerReserveDeficit[i][t];
// reactive power lower reserve deficit to cover the loss of consumption from storage asset s over step t
// (s in STORAGES, t in DECISION_STEPS) 
dvar float+ StorReactivePowerLowerReserveDeficit[isE_STORAGES][isDECISION_STEPS];
// cost of the reactive power lower reserve deficit to cover the loss of consumption from storage asset s over step t
// (s in STORAGES, t in DECISION_STEPS)
dexpr float StorReactivePowerLowerReserveDeficitCost[s in isE_STORAGES][t in isDECISION_STEPS] = reactivePowerLowerReserveDeficitPenaltyCost * assetStepDurationInHours * StorReactivePowerLowerReserveDeficit[s][t];
// reactive power lower reserve deficit to cover sudden drop in consumption from flexible load asset f over step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dvar float+ FlexLoadReactivePowerLowerReserveDeficit[isFLEX_E_LOADS][isDECISION_STEPS];
// cost of the reactive power lower reserve deficit to cover sudden drop in consumption from flexible load asset f over step t
// (f in FLEX_LOADS, t in DECISION_STEPS)
dexpr float FlexLoadReactivePowerLowerReserveDeficitCost[f in isFLEX_E_LOADS][t in isDECISION_STEPS] = reactivePowerLowerReserveDeficitPenaltyCost * assetStepDurationInHours * FlexLoadReactivePowerLowerReserveDeficit[f][t];
// reactive power lower reserve deficit to cover a sudden drop in consumption from non-flexible load asset n over step t
// (n in NF_LOADS, t in DECISION_STEPS) 
dvar float+ NFLoadReactivePowerLowerReserveDeficit[isNF_E_LOADS][isDECISION_STEPS];
// cost of the reactive power lower reserve deficit to cover a sudden drop in consumption from non-flexible load asset n over step t
// (n in NF_LOADS, t in DECISION_STEPS)
dexpr float NFLoadReactivePowerLowerReserveDeficitCost[n in isNF_E_LOADS][t in isDECISION_STEPS] = reactivePowerLowerReserveDeficitPenaltyCost * assetStepDurationInHours * NFLoadReactivePowerLowerReserveDeficit[n][t];
// spinning raise reserve deficit over step t
// (t in DECISION_STEPS)
dvar float+ SpinningRaiseReserveDeficit[isDECISION_STEPS];
// spinning lower reserve deficit over step t
// (t in DECISION_STEPS)
dvar float+ SpinningLowerReserveDeficit[isDECISION_STEPS];
// spinning raise reserve deficit cost over step t
// (t in DECISION_STEPS)
dexpr float SpinningRaiseReserveDeficitCost[t in isDECISION_STEPS] = spinningReserveDeficitPenaltyCost * assetStepDurationInHours * SpinningRaiseReserveDeficit[t];
// spinning raise reserve deficit cost over step t
// (t in DECISION_STEPS)
dexpr float SpinningLowerReserveDeficitCost[t in isDECISION_STEPS] = spinningReserveDeficitPenaltyCost * assetStepDurationInHours * SpinningLowerReserveDeficit[t];
// default current requirement deficit over step t
// (t in DECISION_STEPS)
dvar float+ DefaultCurrentRequirementDeficit[isDECISION_STEPS];
// default current requirement deficit cost over step t
// (t in DECISION_STEPS)
dexpr float DefaultCurrentRequirementDeficitCost[t in isDECISION_STEPS] = defaultCurrentReqDeficitPenaltyCost* DefaultCurrentRequirementDeficit[t];
// violation of maximum time allowed to be continuously on by dispatchable gen d over step t
// (d in DISP_GEN, t in DECISION_STEPS)  
dvar float+ DispGenMaxStepOnInitialExcess[isDISP_E_GENS][i in 0..(maxGenInitialStepsOnMax-1)];
dvar float+ DispGenMaxStepOnExcess[isDISP_E_GENS][isDECISION_STEPS];
//MAxStepOnInitialExcess and MaxStepOnExcess violation cost
// (d in DIS_GEN, t in DECISION_STEPS)
dexpr float DispGenMaxStepOnInitialExcessCost[d in isDISP_E_GENS][i in 0..(maxGenInitialStepsOnMax-1)] = genMinMaxStepOnOffPenaltyCost  * assetStepDurationInHours *  maxDispGenActivePower[d]* DispGenMaxStepOnInitialExcess[d][i];
dexpr float DispGenMaxStepOnExcessCost[d in isDISP_E_GENS][t in isDECISION_STEPS] = genMinMaxStepOnOffPenaltyCost * assetStepDurationInHours * maxDispGenActivePower[d] * DispGenMaxStepOnExcess[d][t];
// violation of minimum time allowed to be continuously on by dispatchable gen d over step t
// (d in DIS_GEN, t in DECISION_STEPS)  
dvar float+ DispGenMinStepOnInitialDeficit[isDISP_E_GENS];
dvar float+ DispGenMinStepOnDeficit[isDISP_E_GENS][isDECISION_STEPS];
// cost of the violation of minimum time allowed to be continuously on by dispatchable gen d over step t
// (d in DIS_GEN, t in DECISION_STEPS)
dexpr float DispGenMinStepOnInitialDeficitCost[d in isDISP_E_GENS] = genMinMaxStepOnOffPenaltyCost * assetStepDurationInHours * maxDispGenActivePower[d] * DispGenMinStepOnInitialDeficit[d];
dexpr float DispGenMinStepOnDeficitCost[d in isDISP_E_GENS][t in isDECISION_STEPS]  = genMinMaxStepOnOffPenaltyCost * assetStepDurationInHours * maxDispGenActivePower[d] * DispGenMinStepOnDeficit[d][t];
// violation of minimum time allowed to be off between 2 consecutive uses for dispatchable gen d over step t
// (d in DISP_GEN, t in DECISION_STEPS)  
dvar float+ DispGenMinStepOffInitialDeficit[isDISP_E_GENS];
dvar float+ DispGenMinStepOffDeficit[isDISP_E_GENS][isDECISION_STEPS];
// Cost of the violation of minimum time allowed to be off between 2 consecutive uses for dispatchable gen d over step t
// (d in DISP_GEN, t in DECISION_STEPS)
dexpr float DispGenMinStepOffInitialDeficitCost[d in isDISP_E_GENS] = genMinMaxStepOnOffPenaltyCost * assetStepDurationInHours * DispGenMinStepOffInitialDeficit[d] * maxDispGenActivePower[d];
dexpr float DispGenMinStepOffDeficitCost[d in isDISP_E_GENS][t in isDECISION_STEPS] = genMinMaxStepOnOffPenaltyCost * assetStepDurationInHours * maxDispGenActivePower[d] * DispGenMinStepOffDeficit[d][t];
// violation of AuthorizedCurt : intermittent generation curtailment is done when batteries are not fully charged
dvar float+ UnauthorizedInterGenCurt[isDECISION_STEPS];
// AuthorizedCurt violation Cost
dexpr float UnauthorizedInterGenCurtCost[t in isDECISION_STEPS] = unauthorizedInterGenCurtPenaltyCost * assetStepDurationInHours* UnauthorizedInterGenCurt[t];
// Expressions to model various costs
/////////////////////////////////////
// Total cost of energy drawn for normal sale / purchase operations from the maingrid over optimisation window
dexpr float TotalTradeNetworkCosts = assetStepDurationInHours * sum(t in isDECISION_STEPS) ImportTarget[t] * networkDrawingTax[t];
// Cost of energy drawn for normal sale / purchase operations from the maingrid over steps that are not already cleared
dexpr float OptimisedTradeNetworkCosts = assetStepDurationInHours * sum(t in isDECISION_STEPS: isDAStepCleared[assetStepHourlyStep[t]] == 0) ImportTarget[t] * networkDrawingTax[t];
// // Estimation of cost of energy drawn during FCR (SOC management + regulation) at the step t
// (network tax applied to estimated AC energy in = estimated AC energy out / (inverter efficiency x battery efficiency x battery efficiency x inverter efficiency)
dexpr float TotalFCRNetworkCostsByStep[t in isDECISION_STEPS] =  1.0 / (pow(storefficiencyfcr / 100.0, 2) * pow(inverterefficiencyfcrout / 100.0, 2))
	* sum (s in isE_STORAGES) networkDrawingTax[t] * FCRUnitarianStepACEnergyOut * FCRPower[s][assetStepFCRStep[t]];
// Estimation of cost of energy drawn during FCR (SOC management + regulation) over optimisation window
// (network tax applied to estimated AC energy in = estimated AC energy out / (inverter efficiency x battery efficiency x battery efficiency x inverter efficiency)
dexpr float TotalFCRNetworkCosts = sum(t in isDECISION_STEPS) TotalFCRNetworkCostsByStep[t];
// Estimation of cost of energy drawn during FCR (SOC management + regulation) over steps that are not already cleared
dexpr float OptimisedFCRNetworkCosts =
	  1.0 / (pow(storefficiencyfcr / 100.0, 2) * pow(inverterefficiencyfcrout / 100.0, 2))
	* sum (s in isE_STORAGES, t in isDECISION_STEPS: isDAStepCleared[assetStepHourlyStep[t]] == 0) networkDrawingTax[t] * FCRUnitarianStepACEnergyOut * FCRPower[s][assetStepFCRStep[t]];
// total net costs from injecting/drawing electricity into/from maingrid over optimisation window
// positive values = net cost / negative values = net revenue
dexpr float ElectricityTotalNetCosts = sum(t in isDECISION_STEPS) electricityPrice[t] * NetElecImportTarget[t] * assetStepDurationInHours;
// net costs from injecting/drawing electricity into/from maingrid over decision steps that are not already cleared
// positive values = net cost / negative values = net revenue
dexpr float OptimisedElecNetCosts = sum(t in isDECISION_STEPS: isDAStepCleared[assetStepHourlyStep[t]] == 0) electricityPrice[t] * NetElecImportTarget[t] * assetStepDurationInHours;
// total variable costs for generation from generators with non-linear variable costs over optimisation window
dexpr float GenTotalNonLinVarCosts = sum(t in isDECISION_STEPS, g in isNL_COST_E_GENS) GenNonLinVarCost[g][t] * assetStepDurationInHours;
// total starting costs from dispatchable generators over optimisation window
dexpr float DispGenTotalStartupCosts = sum(t in isDECISION_STEPS, d in isSTART_COST_E_GENS) DispGenStartup[d][t] * dispGenStartupCost[d];
// total variable costs for generation from generation assets with linear variable costs over optimiation window
dexpr float GenTotalLinearVarCosts =
	  sum(t in isDECISION_STEPS, i in isINTER_E_GENS inter isLIN_COST_E_GENS) InterGenActivePower[i][t] * genVariableCost[i] * assetStepDurationInHours
	+ sum(t in isDECISION_STEPS, d in isDISP_E_GENS inter isLIN_COST_E_GENS) DispGenEffActivePower[d][t] * genVariableCost[d] * assetStepDurationInHours;
// total curtailment costs from intermittent generation over optimisation window
dexpr float InterGenTotalCurtCosts = sum(t in isDECISION_STEPS, i in isCURT_COMP_E_GENS) interGenCurtComp[i] * InterGenCurtEstimation[i][t] * assetStepDurationInHours;
// total late discharge cost over optimisation window
dexpr float StorChargeDischargeCost = sum(t in isDECISION_STEPS, s in isE_STORAGES) storArtificialPenalityCost[t] * (StorACPowerCharge[s][t] + StorACPowerDischarge[s][t]);
// total penalty for storage power changes between decision steps
dexpr float StorPowerChangeTotalCost =
    sum (s in isE_STORAGES, t in isDECISION_STEPS) storPowerChangePenalty * (StorACActivePowerInc[s][t] + StorACActivePowerDec[s][t]) * imbStepDurationInHours;
// Total imbalance cost over optimisation window
// Positive values mean it is indeed a cost, negative that it is a revenue
dexpr float ImbalanceTotalCost =
    sum (imb in isIMBALANCE_STEPS_POS) (NegativeImbalancePower_imb[imb] * negative_imb_price[imb] - PositiveImbalancePower_imb[imb] * positive_imb_price[imb]) * imbStepDurationInHours;
// Violation of the Engaged FCR Power. this decision variable is used in cases where the power engaged for the asset fcr f is greater than its certified power to relax the ctFCRPoolEngagement constraint.
dvar float+ FCRPowerEngDeficit[isFCR_STEPS];
// Total FCR eng deficit over optimisation window
dexpr float FCRPowerEngDeficitCost[fcr in isFCR_STEPS_POS] =  FCRPowerEngDeficitPenaltyCost * fcrStepDurationInHours * FCRPowerEngDeficit[fcr];
dexpr float ImbalanceOptimisedCost =
    sum (imb in isIMBALANCE_STEPS_POS: isDAStepCleared[imbStepHourlyStep[imb]] == 0) (NegativeImbalancePower_imb[imb] * negative_imb_price[imb] - PositiveImbalancePower_imb[imb] * positive_imb_price[imb]) * imbStepDurationInHours;
// Total cost of energy explicitly traded on DA market over optimisation window
// Positive values mean it is indeed a cost, negative that it is a revenue
dexpr float DayAheadTotalTradeCost = sum(h in isHOURLY_STEPS_POS) (DaPosition[h] * daElecPrice[h] * daStepDurationInHours);
// Cost of energy explicitly traded on DA market over steps that are not already cleared
// Positive values mean it is indeed a cost, negative that it is a revenue
dexpr float DayAheadOptimisedTradeCost =
    sum(h in isHOURLY_STEPS_POS: isDAStepCleared[h] == 0) (DaPosition[h] * daElecPrice[h] * daStepDurationInHours);
// Estimation of cost of energy purchased for during FCR over optimisation window (SOC management, we ignore regulation b/c symetrical with sales)
// (day ahead price applied to estimated AC energy in - estimated AC energy out = estimated AC energy out x (1 / (inverter efficiency x battery efficiency x battery efficiency x inverter efficiency) - 1)
dexpr float DayAheadTotalFCRCost =
	  (1.0 / (pow(storefficiencyfcr / 100.0, 2) * pow(inverterefficiencyfcrout / 100.0, 2)) - 1.0)
	* sum (s in isE_STORAGES, t in isDECISION_STEPS) daElecPrice[assetStepHourlyStep[t]] * FCRUnitarianStepACEnergyOut * FCRPower[s][assetStepFCRStep[t]];
// Estimation of cost of energy purchased for during FCR over decision steps not already cleared (SOC management, we ignore regulation b/c symetrical with sales)
dexpr float DayAheadOptimisedFCRCost =
	  (1.0 / (pow(storefficiencyfcr / 100.0, 2) * pow(inverterefficiencyfcrout / 100.0, 2)) - 1.0)
	* sum (s in isE_STORAGES, t in isDECISION_STEPS: isDAStepCleared[assetStepHourlyStep[t]] == 0) daElecPrice[assetStepHourlyStep[t]] * FCRUnitarianStepACEnergyOut * FCRPower[s][assetStepFCRStep[t]];

// Total costs, other than electricity, for conv assets
dexpr float ConvTotalLinearCosts =
	sum(t in isDECISION_STEPS, c in isEIN_CONVS) assetVariableCost[c] * ConvActivePowerIn[c][t] * assetStepDurationInHours;
/*********************************************************************
 * Some labelled constraints
 *********************************************************************/
constraint ctSegUpBound[isNL_COST_E_GENS][2..maxSegNbr][isDECISION_STEPS];
constraint ctSegLowBound[isNL_COST_E_GENS][2..(maxSegNbr-1)][isDECISION_STEPS];
constraint ctSegTest[isNL_COST_E_GENS][1..(maxSegNbr-1)][isDECISION_STEPS];
constraint ctChargeSegUpBound [isE_STORAGES][1..maxChargeSegNbr][isDECISION_STEPS];
constraint ctChargeSegLowBound [isE_STORAGES][2..(maxChargeSegNbr)][isDECISION_STEPS];
constraint ctDischargeSegUpBound [isE_STORAGES][1..maxDischSegNbr][isDECISION_STEPS];
constraint ctDischargeSegLowBound [isE_STORAGES][2..(maxDischSegNbr)][isDECISION_STEPS];
/*********************************************************************
 * Objective function
 *********************************************************************/
minimize
  	TotalTradeNetworkCosts
  + TotalFCRNetworkCosts
  + ElectricityTotalNetCosts
  + ImbalanceTotalCost
  + DayAheadTotalTradeCost
  + GenTotalNonLinVarCosts
  + DispGenTotalStartupCosts
  + GenTotalLinearVarCosts
  + ConvTotalLinearCosts
  + InterGenTotalCurtCosts
  + StorChargeDischargeCost
  + StorPowerChangeTotalCost
  + sum(d in isDISP_E_GENS) (DispGenInitialPowerUpViolationCost[d] + DispGenInitialPowerDwnViolationCost[d])
  + sum (fcr in isFCR_STEPS_POS) FCRPowerEngDeficitCost[fcr]
  + sum (afrr_v in isAFRR_VOLUNTARY_STEPS_POS) AFRRUpPowerEngDeficitCost[afrr_v]
  + sum (afrr_v in isAFRR_VOLUNTARY_STEPS_POS) AFRRDwnPowerEngDeficitCost[afrr_v]
  + sum(t in isDECISION_STEPS) (PowerDeficitCost[t] + PowerExcessCost[t])
  + sum(t in isDECISION_STEPS) (HeatDeficitCost[t] + HeatExcessCost[t])
  + sum(t in isDECISION_STEPS) UnauthorizedInterGenCurtCost[t]
  + sum(s in isE_STORAGES, t in isDECISION_STEPS) (SOCstrictMinDeficitCost[s][t] + SOCmaxExcessCost[s][t])
  + sum(s in isH_STORAGES, t in isDECISION_STEPS) (HeatSOCminDeficitCost[s][t] + HeatSOCmaxExcessCost[s][t])
  + sum(s in isE_STORAGES, t in isDECISION_STEPS) minSocTargetStorageDeficitCost[s][t]
  + sum(s in isE_STORAGES, t in isDECISION_STEPS) StorageDailyMaxNumCyclExcessCost[s][t]
  + sum(s in isE_STORAGES, t in isDECISION_STEPS) SOCminDeficitCost[s][t]
  + sum(i in isSITES, t in isDECISION_STEPS) (SiteMaxInputViolationCost[i][t] + SiteMaxOutputViolationCost[i][t])
  + sum(c in isCONGESTIONS, t in isDECISION_STEPS) (CongestionUpperLimViolationCost[c][t] + CongestionLowerLimViolationCost[c][t])
  + sum(d in isDISP_E_GENS, i in 0..(genInitialStepsOnMax[d]-1)) DispGenMaxStepOnInitialExcessCost[d][i]
  + sum(d in isDISP_E_GENS, t in isDECISION_STEPS) DispGenMaxStepOnExcessCost[d][t]
  + sum(d in isDISP_E_GENS) DispGenMinStepOnInitialDeficitCost[d]
  + sum(d in isDISP_E_GENS, t in isDECISION_STEPS) DispGenMinStepOnDeficitCost[d][t]
  + sum(d in isDISP_E_GENS) DispGenMinStepOffInitialDeficitCost[d]
  + sum(d in isDISP_E_GENS, t in isDECISION_STEPS) DispGenMinStepOffDeficitCost[d][t]
  + sum(d in isDISP_E_GENS, t in isDECISION_STEPS) DispGenMinActivePowerDeficitCost[d][t]
  + sum(d in isDISP_E_GENS, t in isDECISION_STEPS) DispGenActivePowerRaiseReserveDeficitCost[d][t]
  + sum(i in isINTER_E_GENS, t in isDECISION_STEPS) InterGenActivePowerRaiseReserveDeficitCost[i][t]
  + sum(s in isE_STORAGES, t in isDECISION_STEPS) StorActivePowerRaiseReserveDeficitCost[s][t]
  + sum(n in isNF_E_LOADS, t in isDECISION_STEPS) NFLoadActivePowerRaiseReserveDeficitCost[n][t]
  + sum(i in isINTER_E_GENS, t in isDECISION_STEPS) InterGenActivePowerLowerReserveDeficitCost[i][t]
  + sum(s in isE_STORAGES, t in isDECISION_STEPS) StorActivePowerLowerReserveDeficitCost[s][t]
  + sum(f in isFLEX_E_LOADS, t in isDECISION_STEPS) FlexLoadActivePowerLowerReserveDeficitCost[f][t]
  + sum(n in isNF_E_LOADS, t in isDECISION_STEPS) NFLoadActivePowerLowerReserveDeficitCost[n][t]
  + sum(d in isDISP_E_GENS, t in isDECISION_STEPS) DispGenReactivePowerRaiseReserveDeficit[d][t]
  + sum(i in isINTER_E_GENS, t in isDECISION_STEPS) InterGenReactivePowerRaiseReserveDeficitCost[i][t]
  + sum(s in isE_STORAGES, t in isDECISION_STEPS) StorReactivePowerRaiseReserveDeficitCost[s][t]
  + sum(n in isNF_E_LOADS, t in isDECISION_STEPS) NFLoadReactivePowerRaiseReserveDeficitCost[n][t]
  + sum(i in isINTER_E_GENS, t in isDECISION_STEPS) InterGenReactivePowerLowerReserveDeficitCost[i][t]
  + sum(t in isDECISION_STEPS) (SpinningRaiseReserveDeficitCost[t] + SpinningLowerReserveDeficitCost[t])
  + sum(s in isE_STORAGES, t in isDECISION_STEPS) StorReactivePowerLowerReserveDeficitCost[s][t]
  + sum(f in isFLEX_E_LOADS, t in isDECISION_STEPS) FlexLoadReactivePowerLowerReserveDeficitCost[f][t]
  + sum(n in isNF_E_LOADS, t in isDECISION_STEPS) NFLoadReactivePowerLowerReserveDeficitCost[n][t]
  + sum(t in isDECISION_STEPS) (DefaultCurrentRequirementDeficitCost[t]);
  
/*********************************************************************
 * Constraints
 *********************************************************************/
  subject to {
//	ctTest: ImbalancePower_imb["1"] >= 4.0;
//	forall (c in isHOUT_CONVS)
//		ctTest: ConvActivePowerIn[c]["1"] == 45.0;
//	forall (s in isE_STORAGES, t in isDECISION_STEPS : 7<=ord(isDECISION_STEPS, t)<= 10 )
//	  ctTest:
//	  	StorACActivePower[s][t]== - 50;
//	  ctTest: PowerDeficit[t] <= 0;
//	forall (t in isDECISION_STEPS : floatValue(t) <= 3)
	
//		ctTest1: StorACPowerCharge["VALOREM_Limoux_BESS"][t] >= 1000;
	//ctTest2: DispGenActivePower["CHP_1600kW"][t] >= 1000;
	//ctTest2: DispGenActivePower["ENERCAL_IDP_GE_1_NC"]["5"] <= 0;
//	forall (d in isDISP_E_GENS diff {"ENERCAL_IDP_GE_1_NC"}, t in isDECISION_STEPS)
//	  ctTest2: IsGenOn[d][t] <= 0;
//	forall (t in isDECISION_STEPS)
//		ctTest: SOCstrictMinDeficit["VALOREM_Limoux_BESS"][t] <= 0;

/*********************************************
 * Electricity related constraints
 *********************************************/

/* POWER BALANCE */
// Physical
// Power generated by intermittent and dispatchable generation assets, injected by storage assets
// and imported from the main grid must balance with the power consumed by flexible
// and non-flexible load units and by elec converting assest on each decision step.
	forall (t in isDECISION_STEPS)
	  ctPowerBalance:
	  	  sum(i in isINTER_E_GENS) InterGenActivePower[i][t]
	  	+ sum(d in isDISP_E_GENS) DispGenEffActivePower[d][t]
	  	+ sum(s in isE_STORAGES) StorACActivePower[s][t]
	  	+ NetElecImportTarget[t] ==
	  	  sum(f in isFLEX_E_LOADS) FlexLoadActivePower[f][t]
	  	+ sum(n in isNF_E_LOADS) NFLoadActivePower[n][t]
	  	+ sum(c in isEIN_CONVS) ConvActivePowerIn[c][t]
	  	- PowerDeficit[t] + PowerExcess[t];
// Pool market
// Pool engagement on imbalance step. Long term and day-ahead engagement at an hourly step gives the same engagement at the imabalance step.
// Positive engagement means purchase, negative sale.
// Positive imbalance means beeing long (less consumption/more production than purchased/sold), negative imbalance beeing short (more consumption/less production than purchased/sold)
// For non market-realted microgrids, there will be no engagements, then everything will be imbalanced : no impact since the imbalance prices then will be zero
	forall (imb in isIMBALANCE_STEPS_POS)
	  ctImbalanceManagement:
	  	NetElecImportTarget_imb[imb] == long_term_engagement[imbStepHourlyStep[imb]] + DaPosition[imbStepHourlyStep[imb]] + mFRRactivatedPower_imb[imb]
	  									- ImbalancePower_imb[imb];

// Pool engagement on mFRR step
	forall (mfrr in ismFRR_STEPS_POS)
	  ctmFRRManagement:
		NetElecImportTarget_mfrr[mfrr] == long_term_engagement[mFRRStepHourlyStep[mfrr]] + DaPosition[mFRRStepHourlyStep[mfrr]] + mFRRactivatedPower_mFRR[mfrr]
										 - ImbalancePower_mfrr[mfrr];
// Imbalance power flag equals 1 for imbalance steps when microgrid is in positive imbalance (long)
// and 0 for imbalance steps when microgrid is in negative imbalance (short)
// Hypothesis : Engaged energy cannot be larger than grid capacity. Then the larger positive imbalance possible is beeing engaged to consume maxImport and finally produce max Epxort.
	forall (imb in isIMBALANCE_STEPS_POS)
	  ctImbalanceIsPositive:
	    ImbalancePower_imb[imb] <= (maxExportCapacity[assetStepImbalanceStep[imb]] + maxImportCapacity[assetStepImbalanceStep[imb]]) * IsPositiveImbalance_imb[imb];
	forall (imb in isIMBALANCE_STEPS_POS)
	  ctImbalanceIsNegative:
	    ImbalancePower_imb[imb] >= - (maxExportCapacity[assetStepImbalanceStep[imb]] + maxImportCapacity[assetStepImbalanceStep[imb]]) * (1 - IsPositiveImbalance_imb[imb]);

// Link between imbalance and mfrr step for ImbalancePower
	forall (imb in isIMBALANCE_STEPS_POS: card(ismFRR_STEPS_POS) > 0)
	  ctmfrrToImbStepImbPower:
	  	ImbalancePower_imb[imb] == sum(mfrr in ismFRR_STEPS_POS : imb == mFRRStepImbalanceStep[mfrr]) ImbalancePower_mfrr[mfrr] /
	  							   sum(mfrr in ismFRR_STEPS_POS : imb == mFRRStepImbalanceStep[mfrr]) 1;

// FCR pool engagement
// FCR engagement must be equal to the sum of assets' FCRPower
	forall (fcr in isFCR_STEPS)
	  ctFCRPoolEngagement :
	  	fcrReqPower[fcr] == sum(a in isASSETS) FCRPower[a][fcr] + FCRPowerEngDeficit[fcr];

// An asset's engaged power cannot be higher than its certified power
	forall (a in isASSETS, fcr in isFCR_STEPS)
	  ctFCRMaxActivatedPower:
	  	FCRPower[a][fcr] <= fcrCertfiedPower[a];

// We give a position to flags, in order to force 1st flag to really be the 1st, and so on.
// We could go from boolean variables to a single integer variable, however we need a boolean variable that plays the role 'isFCR' and blocks simultaneaous multi-mechanisms
	if (maxfcrCertfiedPower_MW > 1) {
	forall (a in isASSETS, fcr in isFCR_STEPS, s in 2..maxfcrCertfiedPower_MW )
  		ctFCRFlagsRank1 : FCR1MWFlag[a][fcr][s-1] >= FCR1MWFlag[a][fcr][s] ;
	  			}

// Limitations to simultaneous multi-mchenasims for battery
// battery cannot inject power if reserved to supply FCR
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctBatNoPowerOutFCR:
	  	  StorACPowerDischarge[s][t] <= storMaxACActivePowerDischarge[s][t] * (1 - FCR1MWFlag[s][assetStepFCRStep[t]][1]);
// battery cannot extract power if reserved to supply FCR
	forall (s in isE_STORAGES inter isFCR_ASSETS, t in isDECISION_STEPS)
	  ctBatNoPowerInFCR:
	  	  StorACPowerCharge[s][t] <= storMaxACActivePowerCharge[s][t] * (1 - FCR1MWFlag[s][assetStepFCRStep[t]][1]);
	  	  
////////////////
/// AFRR
///////////////
// AFRR Pool engagement
// AFRR up engagement
	forall (afrr_v in isAFRR_VOLUNTARY_STEPS)
	  ctAFRRUpPoolEngagement:
	  	aFRRUpReqPower[afrr_v] == sum(a in isASSETS) AFRRCapacityPowerUp[a][afrr_v] + AFRRUpCapacityDeficit[afrr_v];

// AFRR down engagement
	forall (afrr_v in isAFRR_VOLUNTARY_STEPS)
	  ctAFRRDwnPoolEngagement:
	  	aFRRDwnReqPower[afrr_v] == sum(a in isASSETS) AFRRCapacityPowerDwn[a][afrr_v] + AFRRDwnCapacityDeficit[afrr_v];

// An asset participation to afrr is limited by its certified power/its capacity max to provide the service
// We take into consideration availability of the assets : partial unavailability means for now that it is a total unavailability
// We flag aFRR participation, that will be then use to block simultaneaous multi-markets
// up
	forall (a in isASSETS, t in isDECISION_STEPS)
	  ctAFRRUpMaxActivePower:
	      AFRRCapacityPowerUp[a][assetStepAfrrVoluntaryStep[t]] <= IsAFRRUp[a][assetStepAfrrVoluntaryStep[t]] * afrrUpAssetAvailPower[a][t];
// down
	forall (a in isASSETS, t in isDECISION_STEPS)
	  ctAFRRDwnMaxActivePower:
	      AFRRCapacityPowerDwn[a][assetStepAfrrVoluntaryStep[t]] <= IsAFRRDwn[a][assetStepAfrrVoluntaryStep[t]] * afrrDwnAssetAvailPower[a][t]; 

//For limited energy assets, minimum/maximum energy necessary for aFRR
// Two situations : within a pool : must cap the ramp-up/down of other assets. Stand-alone : to the service alone.
// Starts at first non-engaged time_step : otherwise we don't have the power to do anything
// Within a pool
	if (card(isNotEngagedAFRRSteps) != 0){
	forall (s in isSTORAGES inter isaFRRUp_ASSETS, afrr_v in isAFRR_VOLUNTARY_STEPS : afrr_v >= first(isNotEngagedAFRRSteps))
	  ctMinAvailEnergyAfrrUp:
	  	AFRRUpAvailEnergyAC[s][afrr_v] >= AFRRCapacityPowerUp_MW[s][afrr_v] * minACEnergyForAFRRUpPerMW[s];
	
	forall (s in isSTORAGES inter isaFRRDwn_ASSETS, afrr_v in isAFRR_VOLUNTARY_STEPS: afrr_v >= first(isNotEngagedAFRRSteps))
	  ctMinAvailEnergyAfrrDwn:
	  	AFRRDwnAvailEnergyAC[s][afrr_v] >= AFRRCapacityPowerDwn_MW[s][afrr_v] * minACEnergyForAFRRDwnPerMW[s];
 }	  	
	  	
//// No multi-mechanisms during aFRR for now
// Storage
// battery cannot use power if reserved to supply aFRR
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctBatNoPowerOutaFRRUp1:
	  	  StorACPowerDischarge[s][t] <= storMaxACActivePowerDischarge[s][t] * (1 - IsAFRRUp[s][assetStepAfrrVoluntaryStep[t]]);

	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctBatNoPowerOutaFRRUp2:
	  	  StorACPowerCharge[s][t] <= storMaxACActivePowerCharge[s][t] * (1 - IsAFRRUp[s][assetStepAfrrVoluntaryStep[t]]);

	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctBatNoPowerOutaFRRDwn1:
	  	  StorACPowerDischarge[s][t] <= storMaxACActivePowerDischarge[s][t] * (1 - IsAFRRDwn[s][assetStepAfrrVoluntaryStep[t]]);

	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctBatNoPowerOutaFRRDwn2:
	  	  StorACPowerCharge[s][t] <= storMaxACActivePowerCharge[s][t] * (1 - IsAFRRDwn[s][assetStepAfrrVoluntaryStep[t]]);

// Disp gen
// If disp gen particpating to aFRR, cannot do anything else
	forall (d in isDISP_E_GENS inter isaFRRUp_ASSETS, t in isDECISION_STEPS)
	  ctGenNoMultiStackingaFRR1:
		DispGenEffActivePower[d][t] <= (1-IsAFRRUp[d][assetStepAfrrVoluntaryStep[t]])* maxDispGenActivePower[d] * dispGenAvail[d][t];

// Idem, on the step before entering aFRR we must block it
	forall (d in isDISP_E_GENS inter isaFRRUp_ASSETS, t in isDECISION_STEPS : t!= first(isDECISION_STEPS))
	  ctGenNoMultiStackingaFRR2:
		DispGenEffActivePower[d][prev(isDECISION_STEPS,t)] <= (1-IsAFRRUp[d][assetStepAfrrVoluntaryStep[t]])* maxDispGenActivePower[d] * dispGenAvail[d][prev(isDECISION_STEPS,t)];

// e-boilers
// We suppose here when an conv asset do aFRR, it cannot do anything else
	forall (c in isEIN_CONVS inter isaFRRDwn_ASSETS, t in isDECISION_STEPS)
	  ctConvAvailPowerDuringAFRR1:
	  	ConvActivePowerIn[c][t] <= (1 - IsAFRRDwn[c][assetStepAfrrVoluntaryStep[t]]) * maxConvActivePowerIn[c] * convAvail[c][t]; 
// Idem, on the step before entering aFRR we must block it
	forall (c in isEIN_CONVS inter isaFRRDwn_ASSETS, t in isDECISION_STEPS : t!= first(isDECISION_STEPS))
	  ctConvAvailPowerDuringAFRR2:
	  	ConvActivePowerIn[c][prev(isDECISION_STEPS,t)] <= (1 - IsAFRRDwn[c][assetStepAfrrVoluntaryStep[t]]) * maxConvActivePowerIn[c] * convAvail[c][prev(isDECISION_STEPS,t)]; 

/* POWER IMPORTS */
// Power import flag equals 1 for decision steps when microgrid imports power from the main grid
// and 0 for decision steps when microgrid exports power out to the main grid
	forall (t in isDECISION_STEPS)
	  ctPowerIsExporting:
	  	NetElecImportTarget[t] >= -maxExportCapacity[t] * (1 - IsImporting[t]);
	forall (t in isDECISION_STEPS)
	  ctPowerIsImporting:
	  	NetElecImportTarget[t] <= maxImportCapacity[t] * IsImporting[t];
// Power imported at each decision step is NetElecImportTarget if microgrid is importing power over decision step
// or zero if microgrid is not importing power
	forall (t in isDECISION_STEPS)
	  ctPowerImportTargetDef1:
	  	NetElecImportTarget[t] <= ImportTarget[t];
	forall (t in isDECISION_STEPS)
	  ctPowerImportTargetDef2:
	  	ImportTarget[t] <= NetElecImportTarget[t] + maxExportCapacity[t] * (1 - IsImporting[t]);
	forall (t in isDECISION_STEPS)
	  ctPowerImportTargetDef3:
	  	ImportTarget[t] <= maxImportCapacity[t] * IsImporting[t];
/* dispatchable generators POWER PRODUCTION */
// Power generation from a dispatchable generation asset is limited by the maximum and the minimum power generation possible for that asset
// only applicable to disp gen with non-zero minActivePower (bc if minActivePower(d) = 0 then DispGenActivePower(d) can be = 0 and d considered to be on (IsGenOn(d) = 1))  
	forall (d in isDISP_E_GENS: minDispGenActivePower[d] > 0.0, t in isDECISION_STEPS)
	  ctDispGenEcoMinPower:
	  	DispGenActivePower[d][t] >= minDispGenActivePower[d] * IsGenOn[d][t] - DispGenMinActivePowerDeficit[d][t];
	forall (d in isDISP_E_GENS: minDispGenActivePower[d] > 0.0, t in isDECISION_STEPS)
	  ctDispGenPhysMinPower:
	  	minDispGenActivePower[d] * IsGenOn[d][t] - DispGenMinActivePowerDeficit[d][t] >= physMinDispGenActivePower[d] * IsGenOn[d][t];
	forall(d in isDISP_E_GENS, t in isDECISION_STEPS)
	  ctDispGenMaxPower:  	
	  	DispGenActivePower[d][t] <= maxDispGenActivePower[d] * IsGenOn[d][t];
	  	
// dispatchable gen cannot be on if maximum power generation is zero for this gen or if gen is unavailable
	forall (d in isDISP_E_GENS, t in isDECISION_STEPS)
	  ctDispGenZeroMaxGen:
	  	IsGenOn[d][t] <= (maxDispGenActivePower[d] > 0.0 && dispGenAvail[d][t] > 0 ? 1 : 0);

// if possible, keep first step's average power generation for dispatchable generator d the same as it was initially
// (d in DISP_GENS)
	forall (d in isDISP_E_GENS: genInitialState[d] >= 1 && dispGenAvail[d][first(isDECISION_STEPS)] == 1)
	  ctDispGenPowerUp:
	  	genInitialPower[d] - DispGenActivePower[d][first(isDECISION_STEPS)] >= -DispGenInitialPowerUpViolation[d];
	forall (d in isDISP_E_GENS: genInitialState[d] >= 1 && dispGenAvail[d][first(isDECISION_STEPS)] == 1)
	  ctDispGenPowerDwn:
	  	genInitialPower[d] - DispGenActivePower[d][first(isDECISION_STEPS)] <= DispGenInitialPowerDwnViolation[d];
	  	
// Non-linear Variable Cost Model 
// Segment Upper bounds
// first segment: if first segment is used, power on first segment must be lower than first segment's upper limit  
	forall (g in isNL_COST_E_GENS, t in isDECISION_STEPS)
	  ctSegUpBound1:  	
	  	GenVarCostSegPower[g][1][t] <= GenVarCostSegFlag[g][1][t] * varCostSegUpLim[genVarCostModelId[g]][1];

// other segments: if segment s is used, power on s must be lower than the difference between s's upper limit and s-1's upper limit
	forall (g in isNL_COST_E_GENS, s in 2..varCostModelSegNumber[genVarCostModelId[g]], t in isDECISION_STEPS)
	  ctSegUpBound[g][s][t]:  	
	  	GenVarCostSegPower[g][s][t] <= GenVarCostSegFlag[g][s][t] * (varCostSegUpLim[genVarCostModelId[g]][s] - varCostSegUpLim[genVarCostModelId[g]][s-1]);

// Segment Lower bounds
// first segment: if second segment 2 is used, first segment must be completely used and so power on first segment must be equal to first segment's upper bound. 
	forall (g in isNL_COST_E_GENS: varCostModelSegNumber[genVarCostModelId[g]] >= 2, t in isDECISION_STEPS)
	  ctSegLowBound1:  	
	  	GenVarCostSegPower[g][1][t] >= GenVarCostSegFlag[g][2][t] * varCostSegUpLim[genVarCostModelId[g]][1];
	  	
// other segments:  if segment s+1 is used, segment s must be completely used and so power on s must be equal to the difference between s's upper bound and s-1's upper bound
	forall (g in isNL_COST_E_GENS, s in 2..(varCostModelSegNumber[genVarCostModelId[g]]-1), t in isDECISION_STEPS)
	  ctSegLowBound[g][s][t]:  	
	  	GenVarCostSegPower[g][s][t] >= GenVarCostSegFlag[g][s+1][t] * (varCostSegUpLim[genVarCostModelId[g]][s] - varCostSegUpLim[genVarCostModelId[g]][s-1]);
// COST-SEG-CHANGE
//// Definition of the non-linear variable cost segment change indicator
//// Case when number of used segments goes up from step t-1 to step t	  	
//	forall (g in isNL_COST_E_GENS, t in isDECISION_STEPS diff {first(isDECISION_STEPS)})
//	  ctSegChangeUp:
//	  	GenVarCostSegNbr[g][t] - GenVarCostSegNbr[g][prev(isDECISION_STEPS, t)] <= varCostModelSegNumber[genVarCostModelId[g]] * GenVarCostSegChange[g][t];
//// Case when number of used segments goes down from step t-1 to step t	  	
//	forall (g in isNL_COST_E_GENS, t in isDECISION_STEPS diff {first(isDECISION_STEPS)})
//	  ctSegChangeDown:
//	  	GenVarCostSegNbr[g][prev(isDECISION_STEPS, t)] - GenVarCostSegNbr[g][t] <= varCostModelSegNumber[genVarCostModelId[g]] * GenVarCostSegChange[g][t];
// average power generation (expressed in kW) for generator with non-linear variable costs g over decision step t is sum of segment power over all segments
// (g in NL_COST_GENS,t in DECISION_STEPS)
	forall (d in isDISP_E_GENS inter isNL_COST_E_GENS, t in isDECISION_STEPS)
	  ctDispGenSegPowerSum:
	  	DispGenEffActivePower[d][t] == sum (s in 1..varCostModelSegNumber[genVarCostModelId[d]]) GenVarCostSegPower[d][s][t];
	forall (i in isINTER_E_GENS inter isNL_COST_E_GENS, t in isDECISION_STEPS)
	  ctInterGenSegPowerSum:
	  	InterGenActivePower[i][t] == sum (s in 1..varCostModelSegNumber[genVarCostModelId[i]]) GenVarCostSegPower[i][s][t];

// generation variable cost for generator with non-linear variable costs g  over step t is sum of segment power times segment cost over all segments 
// (g in NL_COST_GENS,t in DECISION_STEPS)
// the GenNonLinVarCost must be calculated separately so that the availability of the generation asset in question can be taken into consideration. 
	forall (d in isDISP_E_GENS inter isNL_COST_E_GENS, t in isDECISION_STEPS) 
	  ctSegCostSum1:
	  	GenNonLinVarCost[d][t] == sum (s in 1..varCostModelSegNumber[genVarCostModelId[d]]) varCostSegCost[genVarCostModelId[d]][s] * GenVarCostSegPower[d][s][t];
	forall (i in isINTER_E_GENS inter isNL_COST_E_GENS, t in isDECISION_STEPS)
	  ctSegCostSum2:
	  	GenNonLinVarCost[i][t] == sum (s in 1..varCostModelSegNumber[genVarCostModelId[i]]) varCostSegCost[genVarCostModelId[i]][s] * GenVarCostSegPower[i][s][t];
//
// Start up and shut down model 
// Indicator giving evolution of each disp generator's status between decision step t and the previous one. 
// -1 means d is shut down at t, 0 means d stays on or stays off, and +1 means d is started.

// first steps, the GenEvol on the step 1 must be equal to Zero if the dispGen is not available during this step, for this we must add the availabilityDisp == 1 as a condition in this contraint
// Disagree on this : since minTimeOn constraint on firsts steps is neutralized if there is unavailibility : it is not necessary to put 0.
	forall (d in isDISP_E_GENS : dispGenAvail[d][first(isDECISION_STEPS)] == 1)
	  ctGenEvol1 :
	  	GenOnEvol[d][first(isDECISION_STEPS)] - IsGenOn[d][first(isDECISION_STEPS)] == -genInitialState[d];

// other steps, we should not add  availabilityDisp == 1 as a condition in this contraint, otherwise we will not taken into consideration the evolution of this asset between the two step   	
  	forall (d in isDISP_E_GENS, t in isDECISION_STEPS diff {first(isDECISION_STEPS)})
  	  ctGenEvol :
	  	GenOnEvol[d][t] == IsGenOn[d][t] - IsGenOn[d][prev(isDECISION_STEPS, t)];

// dispatchable generator d is started up if its status evolution is +1 (1 at t and 0 at t-1)
// GenOnEvol is equal to -1, 0 or 1, but DispGenStartup 0 or 1. It ensures
	forall (d in isDISP_E_GENS, t in isDECISION_STEPS)
	  ctGenOnEvol1 :
	  	GenOnEvol[d][t] <= DispGenStartup[d][t];
	  	
// Maximum number of steps each genset can be continuously on
// initial steps
	forall (d in isDISP_E_GENS: genInitialState[d] > 0, i in rgInitialStepOffset: i <= genInitialStepsOnMax[d])
	  ctMaxStepsOn0:
	  	sum (j in i..(genInitialStepsOnMax[d]-1)) 1 +
	  	sum (t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= dispGenMaxStepsOn[d] - genInitialStepsOnMax[d] + i) IsGenOn[d][t]
	  	<= dispGenMaxStepsOn[d] + DispGenMaxStepOnInitialExcess[d][i];
	  	
// other steps
	forall (d in isDISP_E_GENS: dispGenMaxStepsOn[d] > 0, t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= card(isDECISION_STEPS) - dispGenMaxStepsOn[d] - 1)
	  ctMaxStepsOn:
	  	sum (tt in isDECISION_STEPS: ord(isDECISION_STEPS, t) <=  ord(isDECISION_STEPS, tt) <= ord(isDECISION_STEPS, t) + dispGenMaxStepsOn[d])
	  		IsGenOn[d][tt] <= dispGenMaxStepsOn[d] + DispGenMaxStepOnExcess[d][t];
	  	
// Minimum number of steps each genset must be continuously on
// we can't penalize the min step on of dispgen, if it is not available during a t
// initial steps
	forall (d in isDISP_E_GENS: genInitialState[d] > 0 && dispGenMinStepsOn[d] > 0 && genInitialStepsOnMin[d] < dispGenMinStepsOn[d])
	  ctMinStepsOn0:
	  	genInitialStepsOnMin[d] +
	  	sum (t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= dispGenMinStepsOn[d] - genInitialStepsOnMin[d] - 1) (IsGenOn[d][t] + (1-dispGenAvail[d][t]))
	  	>= dispGenMinStepsOn[d] - DispGenMinStepOnInitialDeficit[d];
// other steps
	forall (d in isDISP_E_GENS: dispGenMinStepsOn[d] > 0, t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= card(isDECISION_STEPS) - dispGenMinStepsOn[d])
	  ctMinStepsOn:
	  	sum (tt in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= ord(isDECISION_STEPS, tt) <= ord(isDECISION_STEPS, t) + dispGenMinStepsOn[d] - 1)
	  		IsGenOn[d][tt] >= dispGenMinStepsOn[d] * GenOnEvol[d][t] - DispGenMinStepOnDeficit[d][t];

// Minimum number of steps each genset must be off between 2 consecutive uses
// initial steps
	forall (d in isDISP_E_GENS: genInitialState[d] <= 0 && 0 < genMinRecoverySteps[d])
	  ctMinStepsOff0:
	  	sum (t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= genMinRecoverySteps[d] - genInitialStepsOff[d] - 1) IsGenOn[d][t]
	  	<= DispGenMinStepOffInitialDeficit[d];
// other steps
	forall (d in isDISP_E_GENS: genMinRecoverySteps[d] > 0, t in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= card(isDECISION_STEPS) - genMinRecoverySteps[d])
	  ctMinStepsOff:
	  	sum (tt in isDECISION_STEPS: ord(isDECISION_STEPS, t) <= ord(isDECISION_STEPS, tt) <= ord(isDECISION_STEPS, t) + genMinRecoverySteps[d] - 1)
	  		IsGenOn[d][tt] <= genMinRecoverySteps[d] * (1 + GenOnEvol[d][t]) + DispGenMinStepOffDeficit[d][t];

//// Maximum reactive power for dispatchable gen d over step t is linear function of d's active power target over t
//// modelled as dexpr//	forall (d in isDISP_E_GENS, t in isDECISION_STEPS)
//	  ctDispGenMaxReactivePower:
//	  	DispGenMaxReactivePower[d][t] == aQmax[d] * DispGenActivePower[d][t] + IsGenOn[d][t] * bQmax[d];
	  	
// Reactive power for dispatchable gen d over step t is limited by d's max recative power at t
	forall (d in isDISP_E_GENS, t in isDECISION_STEPS)
	  ctDispGenReactivePower:
	  	DispGenReactivePower[d][t] <= DispGenMaxReactivePower[d][t]; 


// For dispatchable gen d operating in grid-forming or grid-following mode, spinning raise reserve over step t
// is limited by the difference between d's max active power and d's active power target over t
	forall (d in isDISP_E_GENS inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctDispGenMaxSpinRaiseReserve:
	  	DispGenSpinRaiseReserve[d][t] <= (dispGenAvail[d][t] == 1 ? maxDispGenActivePower[d] - DispGenActivePower[d][t] : 0.0);
// For dispatchable gen d operating in grid-tied mode, spinning raise reserve  over step t is zero
	forall (d in isDISP_E_GENS inter isGRID_TIED, t in isDECISION_STEPS)
	  ctDispGenMaxSpinRaiseReserve0:
	  	DispGenSpinRaiseReserve[d][t] <= 0.0;

// If dispatchable gen d is operating in grid-following mode, it can only provide spinning raise reserve if at least one other asset is operating in grid-forming mode
	forall (d in isDISP_E_GENS inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLDispGenMaxSpinRaiseReserve:
	  	DispGenSpinRaiseReserve[d][t] <= maxDispGenActivePower[d] *
	  		( sum (d1 in isDISP_E_GENS inter isGRID_FORM) IsGenOn[d1][t]
	  		+ sum (s in isE_STORAGES inter isGRID_FORM: (storMaxACActivePowerDischarge[s][t] + storMaxACActivePowerCharge[s][t]) > 0.0) 1
	  		+ sum (f in isFLEX_E_LOADS inter isGRID_FORM: maxFlexLoad[f] > 0.0 && flexLoadAvail[f][t] > 0.0) 1
	  		);

// For dispatchable gen d operating in grid-forming or grid-following mode, spinning lower reserve over step t
// is limited by d's active power target over t
	forall (d in isDISP_E_GENS inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctDispGenMaxSpinLowerReserve:
	  	DispGenSpinLowerReserve[d][t] <= DispGenActivePower[d][t];
// For dispatchable gen d operating in grid-tied mode, spinning lower reserve  over step t is zero
	forall (d in isDISP_E_GENS inter isGRID_TIED, t in isDECISION_STEPS)
	  ctDispGenMaxSpinLowerReserve0:
	  	DispGenSpinLowerReserve[d][t] <= 0.0;

// If disp gen d is operating in grid-following mode, it can only provide spinning lower reserve if at least one other asset is operating in grid-forming mode
	forall (d in isDISP_E_GENS inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLDispGenMaxSpinLowerReserve:
	  	DispGenSpinLowerReserve[d][t] <= maxDispGenActivePower[d] *
	  		( sum (d1 in isDISP_E_GENS inter isGRID_FORM) IsGenOn[d1][t]
	  		+ sum (s in isE_STORAGES inter isGRID_FORM: (storMaxACActivePowerDischarge[s][t] + storMaxACActivePowerCharge[s][t]) > 0.0) 1
	  		+ sum (f in isFLEX_E_LOADS inter isGRID_FORM: maxFlexLoad[f] > 0.0 && flexLoadAvail[f][t] > 0.0) 1
	  		);

//// if dispatchable generation asset d is subject to ramp rates
//// Power target at end of step t is limited by asset's max ramp rate
//// if asset is avalialble on initial time step
//	forall (d in isDISP_E_GENS inter isRR_E_ASSETS)
//	  ctRRDispGenActivePowerEnd0:
//	  	(dispGenAvail[d][first(isDECISION_STEPS)] == 1 ? initialPower[d] - assetStepDurationInHours * maxRampRateInkWperH[d] : 0.0) <=
//	  		DispGenActivePowerEnd[d][first(isDECISION_STEPS)] <=
//	  	(dispGenAvail[d][first(isDECISION_STEPS)] == 1 ? initialPower[d] + assetStepDurationInHours * maxRampRateInkWperH[d] : 0.0);
//// other time step where asset is available
//	forall (d in isDISP_E_GENS inter isRR_E_ASSETS, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
//	  ctRRDwnDispGenActivePowerEnd: (dispGenAvail[d][t] == 1 ? DispGenActivePowerEnd[d][prev(isDECISION_STEPS, t)] - assetStepDurationInHours * maxRampRateInkWperH[d] : 0.0) <= DispGenActivePowerEnd[d][t];
//
//	forall (d in isDISP_E_GENS inter isRR_E_ASSETS, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
//	  ctRRupDispGenActivePowerEnd: DispGenActivePowerEnd[d][t] <= (dispGenAvail[d][t] == 1 ? DispGenActivePowerEnd[d][prev(isDECISION_STEPS, t)] + assetStepDurationInHours * maxRampRateInkWperH[d] : 0.0);
//// if dispatchable generation  asset d is subject to ramp rates
//// its average elec power over step t is average between power at end of step t and power at end of step t-1
//// wraning: this is an approximation / simplification and it is not correct when power target at end of t is reached before end of t
//// initial time step
//	forall (d in isDISP_E_GENS inter isRR_E_ASSETS)
//	  ctRRDispGenActivePowerDef0: DispGenActivePower[d][first(isDECISION_STEPS)] == (dispGenAvail[d][first(isDECISION_STEPS)] == 1 ? (DispGenActivePowerEnd[d][first(isDECISION_STEPS)] + initialPower[d]) / 2.0 : 0.0);
//// other time step
//	forall (d in isDISP_E_GENS inter isRR_E_ASSETS, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
//	  ctRRDispGenActivePowerDef: DispGenActivePower[d][t] == (dispGenAvail[d][t] == 1 ? (DispGenActivePowerEnd[d][t] + DispGenActivePowerEnd[d][prev(isDECISION_STEPS, t)]) / 2.0 : 0.0);
//
//// if dispatchable generation  asset d is not subject to ramp rates
//// its average elec power over step t is the same as its power at end of step t
//	forall (d in isDISP_E_GENS diff isRR_E_ASSETS, t in isDECISION_STEPS)
//	  ctNoRRDispGenActivePowerDef: DispGenActivePowerEnd[d][t]== DispGenActivePower[d][t];

// HARD-CODED

	// for CHP, effective active power is average of active power and prev step's active power
	// initial step
		/*forall (d in isDISP_E_GENS inter {"CHP_1600kW"})
		  ctCHPEffPowerStartUp_0: DispGenEffActivePower[d][first(isDECISION_STEPS)] == (genInitialPower[d] + cf[d][first(isDECISION_STEPS)]) / 2.0;
	// other steps
		forall (d in isDISP_E_GENS inter {"CHP_1600kW"}, t in isDECISION_STEPS diff {first(isDECISION_STEPS)})
		  ctCHPEffPowerStartUp: DispGenEffActivePower[d][t] == (DispGenActivePower[d][prev(isDECISION_STEPS, t)] + DispGenActivePower[d][t]) / 2.0;
	// for any other dispatchable generators, effective active power is just active power
		forall (d in isDISP_E_GENS diff {"CHP_1600kW"}, t in isDECISION_STEPS)
		  ctEffPower1: DispGenEffActivePower[d][t] == DispGenActivePower[d][t];*/

	if (microgridName == "MICROGRID MOPABLOEM") {
	 
	// Ramps of Mopabloem's CHP
	// Since the value is 0 if it is off, Pmax/2 if it is started up, and Pmax if is on and was on on the step before, we can cod ramps this way
	 forall (d in isDISP_E_GENS inter {"CHP_1600kW"}, t in isDECISION_STEPS)
		ctCHPEffPowerStartUp: DispGenEffActivePower[d][t] == maxDispGenActivePower[d]*(IsGenOn[d][t] - (1/2)*DispGenStartup[d][t]);
	
	// We force all assets to match necessary conditions to enter/do aFRR
		forall (a in isaFRRUp_ASSETS, t in isDECISION_STEPS)
		  ctForceAllAssetsAFRRUp:
		  	(aFRRUpReqPower[assetStepAfrrVoluntaryStep[t]] > 0 ?
		  	IsAFRRUp[a][t] == 1
		  	: IsAFRRUp[a][t] <= 1);
		
		forall (a in isaFRRDwn_ASSETS, t in isDECISION_STEPS)
		  ctForceAllAssetsAFRRDwn:
		  	(aFRRDwnReqPower[assetStepAfrrVoluntaryStep[t]] > 0 ? 
		  	IsAFRRDwn[a][t] == 1
		  	: IsAFRRDwn[a][t] <= 1);
		  	
	// For limited energy assets, we have to add a condition : forcing BESS participation in capacity
		forall (s in isSTORAGES inter isaFRRUp_ASSETS, t in isDECISION_STEPS)
		  ctForceBESSaFRRUp:
		  	(aFRRUpReqPower[assetStepAfrrVoluntaryStep[t]] > 0 ?
		  		AFRRCapacityPowerUp[s][assetStepAfrrVoluntaryStep[t]] >= 1000 * (storAvail[s][t] >= 100 ? 1 : 0)
		  		: AFRRCapacityPowerUp[s][assetStepAfrrVoluntaryStep[t]] >= 0);
		
		/*forall (s in isSTORAGES inter isaFRRUp_ASSETS, t in isDECISION_STEPS)
		  ctForceBESSaFRRDwn:
		  	(aFRRDwnReqPower[assetStepAfrrVoluntaryStep[t]] > 0 ?
		  		AFRRCapacityPowerDwn[s][assetStepAfrrVoluntaryStep[t] >= 1000 * (storAvail[s][t] >= 100 ? 1 : 0)
		  		: AFRRCapacityPowerDwn[s][assetStepAfrrVoluntaryStep[t]] >= 0);*/
		  		
	// We don't want to use CHP for imbalances
	// For steps cleared, CHP can be on, only if the engagement is over a treshold, otherwise, it has to be off
	
	 // All DA steps cleared
	 // When must we have the CHP on ? We cannot have it on, unless there is an engagement, where we must have it on
     forall (d in isDISP_E_GENS inter {"CHP_1600kW"}, t in isDECISION_STEPS: ord(isDECISION_STEPS, t) < card(isDECISION_STEPS) - 1 && isDAStepCleared[assetStepHourlyStep[t]]==1) {
	   ctNoCogeChange10:
	     ((dispGenAvail[d][t] == 1) && (mFRRactivatedPower_mFRR[assetStepmFRRStep[t]] == 0) &&
	     (daEngagement[assetStepHourlyStep[t]] + long_term_engagement[assetStepHourlyStep[t]] <= -600))
	     ||
	     ((dispGenAvail[d][t] == 1) && (mFRRactivatedPower_mFRR[assetStepmFRRStep[t]] == 0) && (dispGenAvail[d][nextc(isDECISION_STEPS, t, 1)] == 1)
	     && (mFRRactivatedPower_mFRR[assetStepmFRRStep[nextc(isDECISION_STEPS, t, 1)]] == 0) &&
	     (daEngagement[assetStepHourlyStep[nextc(isDECISION_STEPS, t, 1)]] + long_term_engagement[assetStepHourlyStep[nextc(isDECISION_STEPS, t, 1)]] <= -600)) ?
	         IsGenOn[d][t] >= 1
	        :IsGenOn[d][t] <= 0;	}

	 //idem on last step
	 forall (d in isDISP_E_GENS inter {"CHP_1600kW"}, t in isDECISION_STEPS: ord(isDECISION_STEPS, t) == card(isDECISION_STEPS) - 1 && isDAStepCleared[assetStepHourlyStep[t]]==1) {
	   ctNoCogeChange11:
	     ((dispGenAvail[d][t] == 1) && (mFRRactivatedPower_mFRR[assetStepmFRRStep[t]] == 0) &&
	     (daEngagement[assetStepHourlyStep[t]] + long_term_engagement[assetStepHourlyStep[t]] <= -600)) ?
	     	 IsGenOn[d][t] >= 1
	        :IsGenOn[d][t] <= 0;	}
	}
	else {
	  // Microgrids other than Mopabloem have no ramp rates and no asset's specific behaviour according to engagements
	  // effective active power is just active power
	  forall (d in isDISP_E_GENS, t in isDECISION_STEPS)
	    ctEffPower2: DispGenEffActivePower[d][t] == DispGenActivePower[d][t];
	}

/* INTERMITTENT GENERATION POWER PRODUCTION */
// Power generation from an intermittent generation asset is limited by the maximum and the minimum power generation possible for that asset
	forall (i in isINTER_E_GENS, t in isDECISION_STEPS)
	  ctInterGenMinMax: minInterGenActivePower[i][t] <= InterGenActivePower[i][t] <= maxInterGenActivePower[i][t];

// Power generation from an intermittent generation asset is limited to the maximum generation potential forecast for that asset
	forall (i in isINTER_E_GENS, t in isDECISION_STEPS)
	  ctPotentialInterGen: InterGenActivePower[i][t] <= interGenActivePowerForecast[i][t];
	  
//// Power curtailment for an intermittent generation asset is the difference between its power generation and its maximum generation forecast
//// => modelled as a dexpr to speed up optimisation
//	forall (i in isINTER_E_GENS, t in isDECISION_STEPS)
//	  ctInterGenCurt:
//	  	InterGenPowerCurtailment[i][t] == interGenActivePowerForecast[i][t] - InterGenActivePower[i][t];
	  	
// If an intermittent generation asset is not curtailed, its power curtailment must be zero (only required with curtailment estimation based on installed peak capacity)
	forall (i in isINTER_E_GENS, t in isDECISION_STEPS)
	  ctInterGenCurtFlagDef:
	  	InterGenPowerCurtailment[i][t] <= (
	  		interGenCurtEstimationMethod[i] == "FORECAST_BASED"
	  			? interGenActivePowerForecast[i][t]
	  			: InterGenIsCurtailed[i][t] * interGenActivePowerForecast[i][t]);

//// For intermittent generation curtailment estimation mode 1, the estimation of curtailed power is the difference
//// between installed maximum power and activer power target  
// => modelled as a dexpr to speed up optimisation
//	forall (i in isINTER_E_GENS, t in isDECISION_STEPS)
//	  ctInterGenPenCurtDef:
//	  	InterGenCurtEstimation[i][t] == InterGenPowerCurtailment[i][t] + InterGenIsCurtailed[i][t] * (maxInterGenActivePower[i] - interGenActivePowerForecast[i][t]);

// If batteries are not fully charged, Intermittent generation cannot be curtailed.
// card(isE_STORAGES)*max(s in isE_STORAGES) storMaxDCEnergy[s] -> big M
// card(isINTER_E_GENS)*max(i in isINTER_E_GENS) maxInterGenActivePower[i]  -> big M 	
// in the  ctAuthorizedCurt1 constraint, We check the state of charge only for the available batteries; for this we must pass storMaxACActivePowerCharge on argument in the sum.
// curtailment is not penalized if the storage asset is not available, 
// maxl(0, 1 - sum(s in isSTORAGES) storAvail[s][t]) will equal to one if and only if all asset storage are unavailable
// if we don't add this constraint, the optimizer will set the AreAllStoragesFull to 1, in case the batteries are unavailable
// even if the batteries are not fully charged. Since we only use this boolean variable for those 2 following constraints, it is not an issue. 
if (lastMinuteCurtOption == 1 && card(isINTER_E_GENS) > 0 && card(isE_STORAGES) > 0 ) { 
		forall (t in isDECISION_STEPS)
	  		ctAuthorizedCurt1 : sum(s in isE_STORAGES : storMaxACActivePowerCharge[s][t] > 0.0)(nomEnergyMax[s] * storElecMaxSOC[s] / 100 - StorStoredDCEnergy[s][t])
	  			<= card(isE_STORAGES) * max(s in isE_STORAGES) storMaxDCEnergy[s][t] * (1 - AreAllStoragesFull[t]);
		forall (t in isDECISION_STEPS)
	  		ctAuthorizedCurt2 : sum(i in isINTER_E_GENS) InterGenPowerCurtailment[i][t]
	  			<= card(isINTER_E_GENS) * max(i in isINTER_E_GENS) maxInterGenActivePower[i][t] * AreAllStoragesFull[t] + UnauthorizedInterGenCurt[t];
	}
//// Maximum reactive power for intermittent generation asset i over step t is linear function of i's active power target over t
//// modelled as dexpr
//	forall (i in isINTER_E_GENS, t in isDECISION_STEPS)
//	  ctInterGenMaxReactivePower:
//	  	InterGenMaxReactivePower[i][t] == aQmax[i] * InterGenActivePower[i][t] + bQmax[i];
// Reactive power for intermittent generation asset i over step t is limited by i's max recative power at t
	forall (i in isINTER_E_GENS, t in isDECISION_STEPS)
	  ctInterGenReactivePower:
	  	InterGenReactivePower[i][t] <= InterGenMaxReactivePower[i][t]; 

//// if intermittent generation asset i is subject to ramp rates
//// Power target at end of step t is limited by asset's max ramp rate
//// if asset is availalble on initial time step
//	forall (i in isINTER_E_GENS inter isRR_E_ASSETS)
//	  ctRRInterGenActivePowerEnd0:
//	  	(interGenAvail[i][first(isDECISION_STEPS)] == 1 ? initialPower[i] - assetStepDurationInHours * maxRampRateInkWperH[i] : 0.0) <=
//	  		InterGenActivePowerEnd[i][first(isDECISION_STEPS)] <=
//	  	(interGenAvail[i][first(isDECISION_STEPS)] == 1 ? initialPower[i] + assetStepDurationInHours * maxRampRateInkWperH[i] : 0.0);
//// other time step where asset is available
//	forall (i in isINTER_E_GENS inter isRR_E_ASSETS, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
//	  ctRRupInterGenActivePowerEnd: InterGenActivePowerEnd[i][t] <= (interGenAvail[i][t] == 1 ? InterGenActivePowerEnd[i][prev(isDECISION_STEPS, t)] + assetStepDurationInHours * maxRampRateInkWperH[i] : 0.0);
//	forall (i in isINTER_E_GENS inter isRR_E_ASSETS, t in isDECISION_STEPS: t != first(isDECISION_STEPS) && interGenAvail[i][t] == 1)
//	  ctRRDwnInterGenActivePowerEnd: InterGenActivePowerEnd[i][t] >= (interGenAvail[i][t] == 1 ? InterGenActivePowerEnd[i][prev(isDECISION_STEPS, t)] - assetStepDurationInHours * maxRampRateInkWperH[i] : 0.0);
//
//// if intermittent generation asset i is subject to ramp rates
//// its average elec power over step t is average between power at end of step t and power at end of step t-1
//// wraning: this is an approximation / simplification and it is not correct when power target at end of t is reached before end of t
//// initial time step
//	forall (i in isINTER_E_GENS inter isRR_E_ASSETS)
//	  ctRRInterGenActivePowerDef0: InterGenActivePower[i][first(isDECISION_STEPS)] == (interGenAvail[i][first(isDECISION_STEPS)] == 1 ? (InterGenActivePowerEnd[i][first(isDECISION_STEPS)] + initialPower[i]) / 2.0: 0.0);
//// other time step
//	forall (i in isINTER_E_GENS inter isRR_E_ASSETS, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
//	  ctRRInterGenActivePowerDef: InterGenActivePower[i][t] == (interGenAvail[i][t] == 1 ? (InterGenActivePowerEnd[i][t] + InterGenActivePowerEnd[i][prev(isDECISION_STEPS, t)]) / 2.0 : 0.0);
//
//// if intermittent generation asset i is not subject to ramp rates
//// its average elec power over step t is the same as its power at end of step t
//	forall (i in isINTER_E_GENS diff isRR_E_ASSETS, t in isDECISION_STEPS)
//	  ctNoRRInterGenActivePowerDef: InterGenActivePower[i][t] == InterGenActivePowerEnd[i][t];

/* STORAGE POWER INJECTION */
// Power consumption by a storage asset in charge is limited by its maximum charge rate
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageChargeMax: StorACPowerCharge[s][t] <= storMaxACActivePowerCharge[s][t] * IsCharging[s][t];
	  // Power consumption by a storage asset in charge is limited by its minimum charge rate
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageChargeMin: StorACPowerCharge[s][t] >= storMinACActivePowerCharge[s][t] * IsCharging[s][t];

// Definition of active power change between 2 consecutive decision steps
	forall (s in isE_STORAGES, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
	  ctStorageACActivePowerChange: StorACActivePower[s][t] - StorACActivePower[s][prev(isDECISION_STEPS, t)] == StorACActivePowerInc[s][t] - StorACActivePowerDec[s][t];

// Question: do we still need this constraint specific to MICROGRID MORBIHAN ENERGIES Kergrid
// Looks like it's covered by the generic one above (ctStorageChargeMin)
// For one specific charging station on Kergrid microgrid, power consumption by a storage asset in charge is limited by its minimum charge rate
	if (microgridName == "MICROGRID MORBIHAN ENERGIES Kergrid") {
		forall (s in isE_STORAGES inter {"MORB_ENERGIES_Kergrid_V1G_C1", "MORB_ENERGIES_Kergrid_V1G_C2"}, t in isDECISION_STEPS)
		  ctStorageChargeMin1: StorACPowerCharge[s][t] >= minl(9.0, storMaxACActivePowerCharge[s][t]) * IsCharging[s][t];
  }

// Power injection by a storage asset in discharge is limited by its maximum discharge rate
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageDischargeMax: StorACPowerDischarge[s][t] <= storMaxACActivePowerDischarge[s][t] * IsDischarging[s][t];
// Power injection by a storage asset in discharge is limited by its minimum discharge rate
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageDischargeMin: StorACPowerDischarge[s][t] >= storMinACActivePowerDischarge[s][t] * IsDischarging[s][t];

// Electrical batteries cannot charge and discharge simultaneously
forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctEStorageChargeOrDischarge: IsCharging[s][t] + IsDischarging[s][t] <= 1;


/* ******************************** */
// Non-linear Stor efficiency Model
/* ******************************** */
// Non-linear Charge efficiency Model
//depending on the power demand (either on-load or off-load) one and only one segment must be activated: this is the segment containing the power requested (power demanded is between its lower and upper limit)
// Segment Upper bounds
// if segment s is used, power on s must be lower than its upper limit
	forall (s in isE_STORAGES, se in 1..chargeStorSegNbr[chargeVarEffModelId[s]], t in isDECISION_STEPS)
	  ctChargeSegUpBound[s][se][t]:  	
	  	StorACSegPowerCharge[s][se][t] <= StorACSegChargeFlag[s][se][t] * (chargeEffSegUpLim[chargeVarEffModelId[s]][se] * storChargeSegSlope[chargeVarEffModelId[s]][se] + storChargeSegOrdinate[chargeVarEffModelId[s]][se]);

// Segment Lower bounds
//// if segment s is used, power on s must be higher than its lower limit
//// hypothesis : 1st segment starts at Pmin = 0
	forall (s in isE_STORAGES : chargeStorSegNbr[chargeVarEffModelId[s]] > 1 , se in 2..(chargeStorSegNbr[chargeVarEffModelId[s]]), t in isDECISION_STEPS)
	  ctChargeSegLowBound[s][se][t]:  	
	  	StorACSegPowerCharge[s][se][t] >=  StorACSegChargeFlag[s][se][t] * (chargeEffSegUpLim[chargeVarEffModelId[s]][se-1] * storChargeSegSlope[chargeVarEffModelId[s]][se-1] + storChargeSegOrdinate[chargeVarEffModelId[s]][se-1]);


// average power generation (expressed in kW) from asset storage s with efficiency over decision step t is the sum of segment power over all segments
// (s in isE_STORAGES, t in isDECISION_STEPS)
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorChargeSegPowerSum:
	  	StorACPowerCharge[s][t] ==sum(se in 1..chargeStorSegNbr[chargeVarEffModelId[s]]) StorACSegPowerCharge[s][se][t] ;

// Flags for segments charge 1..i must be set to zeros when segment i+1 is activated
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctChargeSegOneFalg:
	  	sum(se in 1..chargeStorSegNbr[chargeVarEffModelId[s]]) StorACSegChargeFlag [s][se][t] <= 1;

// Non-linear discharge efficiency Model
//depending on the power demand (either on-load or off-load) one and only one segment must be activated: this is the segment containing the power requested (power demanded is between its lower and upper limit)
// Segment Upper bounds
// if segment s is used, power on s must be lower than its upper limit
	forall (s in isE_STORAGES, se in 1..dischStorSegNbr[dischVarEffModelId[s]], t in isDECISION_STEPS)
	  ctDischargeSegUpBound[s][se][t]:  	
	  	StorACSegPowerDischarge[s][se][t] <=  StorACSegDischFlag[s][se][t]*(dischEffSegUpLim[dischVarEffModelId[s]][se] * storDischSegSlope[dischVarEffModelId[s]][se]+storDischSegOrdinate[dischVarEffModelId[s]][se]);

// Segment Lower bounds
//// if segment s is used, power on s must be higher than its lower limit
//// hypothesis : 1st segment starts at Pmin = 0
	forall (s in isE_STORAGES : dischStorSegNbr[dischVarEffModelId[s]] > 1 , se in 2..(dischStorSegNbr[dischVarEffModelId[s]]), t in isDECISION_STEPS)
	  ctDischargeSegLowBound[s][se][t]:  	
	  	StorACSegPowerDischarge[s][se][t] >=  StorACSegDischFlag[s][se][t] * (dischEffSegUpLim[dischVarEffModelId[s]][se-1] * storDischSegSlope[dischVarEffModelId[s]][se-1] + storDischSegOrdinate[dischVarEffModelId[s]][se-1]);

// Flags for segments discharge 1..i must be set to zeros when segment i+1 is activated
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctDischargeSegOneFalg:  	
	  	sum(se in 1..dischStorSegNbr[dischVarEffModelId[s]]) StorACSegDischFlag[s][se][t]  <= 1;

// average power generation (expressed in kW) from asset storage s with efficiency over decision step t is the sum of segment power over all segments
// (s in isE_STORAGES, t in isDECISION_STEPS)
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorDischargeSegPowerMax:
	  	StorACPowerDischarge[s][t] == sum (se in 1..dischStorSegNbr[dischVarEffModelId[s]]) StorACSegPowerDischarge[s][se][t];

// DC Charge Power
// To calculate DC charge power, we use the inverse function "fonction inverse"  
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorDCPowerCharge: StorDCPowerCharge[s][t] ==
	  	sum(se in 1..chargeStorSegNbr[chargeVarEffModelId[s]])
	  	  (  (storChargeSegSlope[chargeVarEffModelId[s]][se] > 0.0 ? StorACSegPowerCharge[s][se][t] / storChargeSegSlope[chargeVarEffModelId[s]][se] : 0.0)
	  	   - (storChargeSegSlope[chargeVarEffModelId[s]][se] > 0.0 ? storChargeSegOrdinate[chargeVarEffModelId[s]][se] / storChargeSegSlope[chargeVarEffModelId[s]][se] : 0.0)
	  	   * StorACSegChargeFlag[s][se][t]
	  	  );

// DC Discharge Power
// To calculate DC discharge power, we use the inverse function "fonction inverse"  
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorDCPowerDischarge: StorDCPowerDischarge[s][t] ==
	  	sum(se in 1..dischStorSegNbr[dischVarEffModelId[s]])
	  	  ( (storDischSegSlope[dischVarEffModelId[s]][se] > 0.0 ? StorACSegPowerDischarge[s][se][t] / storDischSegSlope[dischVarEffModelId[s]][se]: 0.0)
	  	  - (storDischSegSlope[dischVarEffModelId[s]][se] > 0.0 ? storDischSegOrdinate[dischVarEffModelId[s]][se] / storDischSegSlope[dischVarEffModelId[s]][se] : 0.0)
	  	  * StorACSegDischFlag[s][se][t]);
// Incremental charge / discharge definition
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageIncrCharge: StorStepDCEnergyIn[s][t] == (StorDCPowerCharge[s][t] - StorDCPowerDischarge[s][t])*assetStepDurationInHours;
// Energy stored at end of step 1
	forall (s in isE_STORAGES)
	  ctStorageStoredEnergy1: StorStoredDCEnergy[s][first(isDECISION_STEPS)] == storInitialElecCharge[s] + StorStepDCEnergyIn[s][first(isDECISION_STEPS)];
	  
// Energy stored at end of other steps
	forall (s in isE_STORAGES, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
	  ctStorageStoredEnergy: StorStoredDCEnergy[s][t] == StorStoredDCEnergy[s][prev(isDECISION_STEPS, t)] * storAvail[s][t]/100 + StorStepDCEnergyIn[s][t];

// Physical capacity constraints for each storage units
	 forall (s in isE_STORAGES, t in isDECISION_STEPS)
	   ctPhysCapacity: StorStoredDCEnergy[s][t] <= storMaxDCEnergy[s][t];


// Minimum SOC, without minimum energy stored needed for FCR
 	forall (s in isE_STORAGES diff (isFCR_ASSETS), t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0)
 	  ctStorageMinSOC: storElecMinSOC[s] - SOCminDeficit[s][t] - SOCstrictMinDeficit[s][t] <= 100 * StorStoredDCEnergy[s][t] / storMaxDCEnergy[s][t];

// Minimum SOC, including minimum energy stored needed with FCR
 	forall (s in isE_STORAGES inter isFCR_ASSETS, t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0)
 	  ctStorageMinSOCFCR: storElecMinSOC[s] + FCRPower_MW[s][assetStepFCRStep[t]] * (storEnergyDwn1MWFCR / storMaxDCEnergy[s][t]) * 100
 	  					- SOCminDeficit[s][t] - SOCstrictMinDeficit[s][t] <= 100 * StorStoredDCEnergy[s][t] / storMaxDCEnergy[s][t];

// Strict minimum SOC without FCR
 	forall (s in isE_STORAGES diff (isFCR_ASSETS), t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0)
 	  ctStorageStrictMinSOC: storStrictElecMinSOC[s] - SOCstrictMinDeficit[s][t] <= 100 * StorStoredDCEnergy[s][t] / storMaxDCEnergy[s][t];

// Strict minimum SOC with FCR
 	forall (s in isE_STORAGES inter isFCR_ASSETS, t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0)
 	  ctStorageStrictMinSOCFCR: storStrictElecMinSOC[s] + FCRPower_MW[s][assetStepFCRStep[t]] * (storEnergyDwn1MWFCR / storMaxDCEnergy[s][t]) * 100
 	  						- SOCstrictMinDeficit[s][t] <= 100 * StorStoredDCEnergy[s][t] / storMaxDCEnergy[s][t];

// Maximum SOC, without maximum energy stored needed for FCR
 	forall (s in isE_STORAGES diff (isFCR_ASSETS), t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0)
 	  ctStorageMaxSOC: 100 * StorStoredDCEnergy[s][t] / storMaxDCEnergy[s][t] <= storElecMaxSOC[s] + SOCmaxExcess[s][t];

// Maximum SOC, including maximum energy stored needed with FCR
 	forall (s in isE_STORAGES inter isFCR_ASSETS, t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0)
 	  ctStorageMaxSOCFCR: 100 * StorStoredDCEnergy[s][t] / storMaxDCEnergy[s][t] <=
 	  storElecMaxSOC[s] - FCRPower_MW[s][assetStepFCRStep[t]] * (storEnergyUp1MWFCR / storMaxDCEnergy[s][t])*100+ SOCmaxExcess[s][t];

// final SOC
	forall (s in isE_STORAGES : storMaxDCEnergy[s][last(isDECISION_STEPS)] > 0.0)
	  ctStorageFinalSOC: 100 * StorStoredDCEnergy[s][last(isDECISION_STEPS)] / storMaxDCEnergy[s][last(isDECISION_STEPS)] >= finalSOCLowerBound[s];
	  
// Min Soc Target
	forall (s in isE_STORAGES, t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0 && storMinSocTarget[s][t] !=-1.0)
		ctStorageTargetSoc: 100 * StorStoredDCEnergy[s][t] / storMaxDCEnergy[s][t] >= storMinSocTarget[s][t]- minSocTargetStorageDeficit[s][t];

//battery's step cycle from FCR definition
// Cycling is calculated by (EnergyInDC + EnergyOutDC)/(2*nomEmax)
	forall (s in isE_STORAGES, t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0)
	  ctStorStepFCRCycle: StorStepFCRCycle[s][t] ==
	   ((100 / storefficiencyfcr) + 1) * (FCRUnitarianStepACEnergyOut * FCRPower[s][assetStepFCRStep[t]] * 100 / inverterefficiencyfcrout)
	   / (2 * nomEnergyMax[s]);

//The number of cycles performed by the storage asset s before the decision step t, during (24h - stepDuraionInHour[t])
//In the equation we add +1 to the position of the step tt in the decision step set, since the ord function of cplex starts with index zero and not with 1 (like our algorithm)
//The 24h in the equation is the number of hour per day
	forall (s in isE_STORAGES, t in isDECISION_STEPS: storMaxDCEnergy[s][t] > 0.0)
	 ctStorStepArbitrCycle:
		StorageNumCyclPerformedBeforeBeginStep[s][t] == sum(tt in isDECISION_STEPS:
		maxl(1, ord(isDECISION_STEPS, t)+1-24/assetStepDurationInHours+1) <= ord(isDECISION_STEPS, tt)+1 <= ord(isDECISION_STEPS, t))
			(CyclingStepContribution[s][tt] + StorStepFCRCycle[s][tt]) + storElecCyclHistory[s][t];
//battery cycle
	forall (s in isE_STORAGES: nomEnergyMax[s] > 0.0 && storElecDailyMaxCycles[s] !=-1.0, t in isDECISION_STEPS)
	  ctStorageMaxNumberOfCyclesWithFCR:
		CyclingStepContribution[s][t] + StorStepFCRCycle[s][t] + StorageNumCyclPerformedBeforeBeginStep [s][t]  <=
			maxl(storElecDailyMaxCycles[s], storElecCyclHistory[s][t]) + StorageDailyMaxNumCyclExcess[s][t];

// Reactive power discharge for storage asset s over step t is limited by s's max recative discharge at t
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageMaxReactiveOnDischarge:
	  	StorReactivePowerDischarge[s][t] <= StorMaxReactivePowerOnDischarge[s][t];
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageMaxReactiveOnCharge:
	  	StorReactivePowerDischarge[s][t] <= StorMaxReactivePowerOnCharge[s][t];

// Reactive power charge for storage asset s over step t is limited by s's max recative charge at t
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageMinReactiveOnDiscarge:
	  	StorReactivePowerCharge[s][t] <= StorMinReactivePowerOnDischarge[s][t];
	forall (s in isE_STORAGES, t in isDECISION_STEPS)
	  ctStorageMinReactiveOnCharge:
	  	StorReactivePowerCharge[s][t] <= StorMinReactivePowerOnCharge[s][t];

// For elec storage asset s operating in grid-forming or grid-following mode, spinning raise reserve over step t
// is limited by the difference between s's max active discharge and s's AC power target over t
	forall (s in isE_STORAGES inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctStorageMaxSpinRaiseReserve:
	  	StorSpinRaiseReserve[s][t] <= storMaxACActivePowerDischarge[s][t] - StorACActivePower[s][t];
// For elec storage asset s operating in grid-tied mode, spinning raise reserve  over step t is zero
	forall (s in isE_STORAGES inter isGRID_TIED, t in isDECISION_STEPS)
	  ctStorageMaxSpinRaiseReserve0:
	  	StorSpinRaiseReserve[s][t] <= 0.0;

// If elec storage unit s is operating in grid-following mode, it can only provide spinning raise reserve if at least one other asset is operating in grid-forming mode
	forall (s in isE_STORAGES inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLStorageMaxSpinRaiseReserve:
	  	StorSpinRaiseReserve[s][t] <= (storMaxACActivePowerDischarge[s][t] + storMaxACActivePowerCharge[s][t]) *
	  		( sum (d in isDISP_E_GENS inter isGRID_FORM) IsGenOn[d][t]
	  		+ sum (s1 in isE_STORAGES inter isGRID_FORM: storMaxACActivePowerDischarge[s1][t] + storMaxACActivePowerCharge[s1][t] > 0.0) 1
	  		+ sum (f in isFLEX_E_LOADS inter isGRID_FORM: maxFlexLoad[f] > 0.0 && flexLoadAvail[f][t] > 0.0) 1
	  		);

// For elec storage asset s operating in grid-forming or grid-following mode, spinning lower reserve over step t
// is limited by the sum of s's max active charge and s's AC power target over t
	forall (s in isE_STORAGES inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctStorageMaxSpinLowerReserve:
	  	StorSpinLowerReserve[s][t] <= storMaxACActivePowerCharge[s][t] + StorACActivePower[s][t];
// For elec storage asset s operating in grid-tied mode, spinning lower reserve  over step t is zero
	forall (s in isE_STORAGES inter isGRID_TIED, t in isDECISION_STEPS)
	  ctStorageMaxSpinLowerReserve0:
	  	StorSpinLowerReserve[s][t] <= 0.0;

// If elec storage unit s is operating in grid-following mode, it can only provide spinning lower reserve if at least one other asset is operating in grid-forming mode
	forall (s in isE_STORAGES inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLStorageMaxSpinLowerReserve:
	  	StorSpinLowerReserve[s][t] <= (storMaxACActivePowerDischarge[s][t] + storMaxACActivePowerCharge[s][t]) *
	  		( sum (d in isDISP_E_GENS inter isGRID_FORM) IsGenOn[d][t]
	  		+ sum (s1 in isE_STORAGES inter isGRID_FORM: storMaxACActivePowerDischarge[s1][t] + storMaxACActivePowerCharge[s1][t] > 0.0) 1
	  		+ sum (f in isFLEX_E_LOADS inter isGRID_FORM: maxFlexLoad[f] > 0.0 && flexLoadAvail[f][t] > 0.0) 1
	  		);

/* NON-FLEXIBLE LOAD UNITS */
// Maximum consumption
// Modelled as an dexpression

/* FLEXIBLE LOAD UNITS */
// Maximum and minimum consumption
 	forall (f in isFLEX_E_LOADS, t in isDECISION_STEPS :  flexLoadAvail[f][t] == 1)
 	  ctFlexLoadMinmaxActivePower: minFlexLoad[f] <= FlexLoadActivePower[f][t] <= maxFlexLoad[f];
 	  
// Flex Load Active Power must be equal to zero when the load is not available 
 	forall (f in isFLEX_E_LOADS, t in isDECISION_STEPS :  flexLoadAvail[f][t] != 1)
 	  ctAvaiFlexLoadActivePower: FlexLoadActivePower[f][t] <= 0.0;

// Modulation definition, when the load not available we can not penalize the active power, for this we must add the availability condition in this constraint
 	forall (f in isFLEX_E_LOADS, t in isDECISION_STEPS : flexLoadAvail[f][t] == 1 )
 	  ctFlexLoadModulation: FlexLoadActivePower[f][t] == flexLoadForecast[f][t] + ModulationTarget[f][t];

// Modulation constraints
 	forall (f in isFLEX_E_LOADS, t in isDECISION_STEPS)
 	  ctFlexLoadModConstraints: ModulationTarget[f][t] == 0.0;

//// Maximum reactive power for flexible load unit f over step t is linear function of f's active power target over t
//// modelled as dexpr
//	forall (f in isFLEX_E_LOADS, t in isDECISION_STEPS)
//	  ctFlexLoadMaxReactivePower:
//	  	FlexLoadMaxReactivePower[f][t] == aQmax[f] * FlexLoadActivePower[f][t] + bQmax[f];
// Reactive power for flexible load unit f over step t is limited by f's max recative power at t
	forall (f in isFLEX_E_LOADS, t in isDECISION_STEPS)
	  ctFlexLoadReactivePower:
	  	FlexLoadReactivePower[f][t] <= FlexLoadMaxReactivePower[f][t];

// For flexible elec load f operating in grid-forming or grid-following mode, spinning raise reserve over step t
// is limited by the difference between f's AC power target over t and f's min active power
	forall (f in isFLEX_E_LOADS inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctFlexLoadMaxSpinRaiseReserve:
	  	FlexLoadSpinRaiseReserve[f][t] <= (flexLoadAvail[f][t] == 1 ? FlexLoadActivePower[f][t] - minFlexLoad[f] : 0.0);
// For flexible elec load f operating in grid-tied mode, spinning raise reserve over step t is zero
	forall (f in isFLEX_E_LOADS inter isGRID_TIED, t in isDECISION_STEPS)
	  ctFlexLoadMaxSpinRaiseReserve0:
	  	FlexLoadSpinRaiseReserve[f][t] <= 0.0;

// If flexible elec load f is operating in grid-following mode, it can only provide spinning raise reserve if at least one other asset is operating in grid-forming mode
	forall (f in isFLEX_E_LOADS inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLFlexLoadMaxSpinRaiseReserve:
	  	FlexLoadSpinRaiseReserve[f][t] <= (maxFlexLoad[f] + minFlexLoad[f]) *
	  		( sum (d in isDISP_E_GENS inter isGRID_FORM) IsGenOn[d][t]
	  		+ sum (s in isE_STORAGES inter isGRID_FORM: storMaxACActivePowerDischarge[s][t] + storMaxACActivePowerCharge[s][t] > 0.0) 1
	  		+ sum (f1 in isFLEX_E_LOADS inter isGRID_FORM: maxFlexLoad[f1] > 0.0 && flexLoadAvail[f1][t] > 0.0) 1
	  		);

// For flexible elec load f operating in grid-forming or grid-following mode, spinning lower reserve over step t
// is limited by the difference between f's max active power and f's AC power target over t
	forall (f in isFLEX_E_LOADS inter (isGRID_FORM union isGRID_FOLL), t in isDECISION_STEPS)
	  ctFlexLoadMaxSpinLowerReserve:
	  	FlexLoadSpinLowerReserve[f][t] <= (flexLoadAvail[f][t] == 1 ? maxFlexLoad[f] - FlexLoadActivePower[f][t] : 0.0);

// For flexible elec load f operating in grid-tied mode, spinning lower reserve  over step t is zero
	forall (f in isFLEX_E_LOADS inter isGRID_TIED, t in isDECISION_STEPS)
	  ctFlexLoadMaxSpinLowerReserve0:
	  	FlexLoadSpinLowerReserve[f][t] <= 0.0;

// If flexible elec load f is operating in grid-following mode, it can only provide spinning lower reserve if at least one other asset is operating in grid-forming mode
	forall (f in isFLEX_E_LOADS inter isGRID_FOLL, t in isDECISION_STEPS)
	  ctGFLFlexLoadMaxSpinLowerReserve:
	  	FlexLoadSpinLowerReserve[f][t] <= (maxFlexLoad[f] + minFlexLoad[f]) *
	  		( sum (d in isDISP_E_GENS inter isGRID_FORM) IsGenOn[d][t]
	  		+ sum (s in isE_STORAGES inter isGRID_FORM: storMaxACActivePowerDischarge[s][t] + storMaxACActivePowerCharge[s][t] > 0.0) 1
	  		+ sum (f1 in isFLEX_E_LOADS inter isGRID_FORM: maxFlexLoad[f1] > 0.0 && flexLoadAvail[f1][t] > 0.0) 1
	  		);

/* Active Power reserve */
// RAISE RESRVE
// Reserve should cover loss of termal generator with largest generation
	forall (d1 in isDISP_E_GENS: activePowerLossPct[d1] > 0, t in isDECISION_STEPS)
	  ctActivePowerRaiseReserveDispGen :
	  	(100.0 - activePowerLossPct[d1]) / 100 * DispGenActiveRaiseReserve[d1][t]	// reserve from what is left of g1
	  +	sum (d in isDISP_E_GENS diff({d1})) DispGenActiveRaiseReserve[d][t]			// reserve from other dispatchable gens
	  + sum (s in isE_STORAGES) StorActiveRaiseReserve[s][t]	  							// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadActiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  activePowerLossPct[d1] / 100 * DispGenActivePower[d1][t] - DispGenActivePowerRaiseReserveDeficit[d1][t];

// Reserve should cover loss of intermittent generation asset with largest generation
	forall (i in isINTER_E_GENS: activePowerLossPct[i] > 0, t in isDECISION_STEPS)
	  ctActivePowerRaiseReserveInterGen :
	  	sum (d in isDISP_E_GENS) DispGenActiveRaiseReserve[d][t]					// reserve from dispatchable gens
	  + sum (s in isE_STORAGES) StorActiveRaiseReserve[s][t]								// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadActiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  activePowerLossPct[i] / 100 * InterGenActivePower[i][t] - InterGenActivePowerRaiseReserveDeficit[i][t];

// Reserve should cover loss of storage asset with largest discharge
	forall (s1 in isE_STORAGES: activePowerLossPct[s1] > 0, t in isDECISION_STEPS)
	  ctActivePowerRaiseReserveStorage :
	  	sum (d in isDISP_E_GENS) DispGenActiveRaiseReserve[d][t]					// reserve from dispatchable gens
	  + (100.0 - activePowerLossPct[s1]) / 100 * StorActiveRaiseReserve[s1][t]			// reserve from what is left of s1
	  + sum (s in isE_STORAGES diff({s1})) StorActiveRaiseReserve[s][t]					// reserve from other storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadActiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  activePowerLossPct[s1] / 100 * StorACPowerDischarge[s1][t] - StorActivePowerRaiseReserveDeficit[s1][t];

// Reserve should cover surge of non-flexible load unit with largest consumption
	forall (n in isNF_E_LOADS: activePowerSurgePct[n] > 0, t in isDECISION_STEPS)
	  ctActivePowerRaiseReserveNFLoad :
	  	sum (d in isDISP_E_GENS) DispGenActiveRaiseReserve[d][t]					// reserve from dispatchable gens
	  + sum (s in isE_STORAGES) StorActiveRaiseReserve[s][t]								// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadActiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  activePowerSurgePct[n] / 100 * NFLoadActivePower[n][t] - NFLoadActivePowerRaiseReserveDeficit[n][t];

// LOWER RESRVE
// Reserve should cover surge of intermittent generation asset with largest generation
	forall (i1 in isINTER_E_GENS: activePowerSurgePct[i1] > 0, t in isDECISION_STEPS)
	  ctActivePowerLowerReserveInterGen :
	  	sum(d in isDISP_E_GENS) DispGenActivePower[d][t]							// reserve from dispatchable gens
	  + (100.0 - activePowerSurgePct[i1]) / 100 * InterGenActivePower[i1][t]			// reserve from what is left of p1
	  + sum (i in isINTER_E_GENS diff({i1})) InterGenActivePower[i][t]					// reserve from other intermittent gen assets
	  + sum (s in isE_STORAGES) StorActiveLowerReserve[s][t]								// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadActiveLowerReserve[f][t] >=						// reserve from flexible load units
	  activePowerSurgePct[i1] / 100 * InterGenActivePower[i1][t] - InterGenActivePowerLowerReserveDeficit[i1][t];

// Reserve should cover loss of storage asset with largest charge
	forall (s1 in isE_STORAGES: activePowerSurgePct[s1] > 0, t in isDECISION_STEPS)
	  ctActivePowerLowerReserveStorage :
	  	sum (d in isDISP_E_GENS) DispGenActivePower[d][t]							// reserve from dispatchable gens
	  + sum (i in isINTER_E_GENS) InterGenActivePower[i][t]								// reserve from intermittent gen assets
	  + (100.0 - activePowerSurgePct[s1]) / 100 * StorActiveLowerReserve[s1][t]			// reserve from what is left of s1
	  + sum (s in isE_STORAGES diff({s1})) StorActiveLowerReserve[s][t]					// reserve from other storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadActiveLowerReserve[f][t] >=						// reserve from flexible load units
	  activePowerSurgePct[s1] / 100 * StorACPowerCharge[s1][t] - StorActivePowerLowerReserveDeficit[s1][t];

// Reserve should cover loss of flexible load unit with largest consumption
	forall (f1 in isFLEX_E_LOADS: activePowerLossPct[f1] > 0, t in isDECISION_STEPS)
	  ctActivePowerLowerReserveFlexLoad :
	  	sum (d in isDISP_E_GENS) DispGenActivePower[d][t]							// reserve from dispatchable gens
	  + sum (i in isINTER_E_GENS) InterGenActivePower[i][t]								// reserve from intermittent gen assets
	  + sum (s in isE_STORAGES) StorActiveLowerReserve[s][t]								// reserve from storage assets
	  + (100.0 - activePowerLossPct[f1]) / 100 * FlexLoadActiveLowerReserve[f1][t]		// reserve from what is left of f1
	  + sum (f in isFLEX_E_LOADS diff({f1})) FlexLoadActiveLowerReserve[f][t] >=			// reserve from other flexible load units
	  activePowerLossPct[f1] / 100 * FlexLoadActivePower[f1][t] - FlexLoadActivePowerLowerReserveDeficit[f1][t];

// Reserve should cover loss of non-flexible load unit with largest consumption
	forall (n in isNF_E_LOADS: activePowerLossPct[n] > 0, t in isDECISION_STEPS)
	  ctActivePowerLowerReserveNFLoad :
	  	sum (d in isDISP_E_GENS) DispGenActivePower[d][t]							// reserve from dispatchable gens
	  + sum (i in isINTER_E_GENS) InterGenActivePower[i][t]								// reserve from intermittent gen assets
	  + sum (s in isE_STORAGES) StorActiveLowerReserve[s][t]								// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadActiveLowerReserve[f][t] >=						// reserve from flexible load units
	  activePowerLossPct[n] / 100 * NFLoadActivePower[n][t] - NFLoadActivePowerLowerReserveDeficit[n][t];
	  	
/* Reactive Power reserve */
// RAISE RESRVE
// Reserve should cover loss of termal generator with largest generation
	forall (d1 in isDISP_E_GENS: reactivePowerLossPct[d1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerRaiseReserveDispGen :
	    (100.0 - reactivePowerLossPct[d1]) / 100 * DispGenReactiveRaiseReserve[d1][t]	// reserve from what is left of g1
	  + sum (d in isDISP_E_GENS diff({d1})) DispGenReactiveRaiseReserve[d][t]			// reserve from other dispatchable gens
	  + sum (s in isE_STORAGES) StorReactiveRaiseReserve[s][t]	  							// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadReactiveRaiseReserve[f][t] >=						// reserve from flexible load units
	  reactivePowerLossPct[d1] / 100 * DispGenReactivePower[d1][t] - DispGenReactivePowerRaiseReserveDeficit[d1][t];

// Reserve should cover loss of intermittent generation asset with largest generation
	forall (i in isINTER_E_GENS: reactivePowerLossPct[i] > 0, t in isDECISION_STEPS)
	  ctReactivePowerRaiseReserveInterGen :
	  	sum (d in isDISP_E_GENS) DispGenReactiveRaiseReserve[d][t]					// reserve from dispatchable gens
	  + sum (s in isE_STORAGES) StorReactiveRaiseReserve[s][t]							// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadReactiveRaiseReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerLossPct[i] / 100 * InterGenReactivePower[i][t] - InterGenReactivePowerRaiseReserveDeficit[i][t];

// Reserve should cover loss of storage asset with largest discharge
	forall (s1 in isE_STORAGES: reactivePowerLossPct[s1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerRaiseReserveStorage :
	  	sum (d in isDISP_E_GENS) DispGenReactiveRaiseReserve[d][t]					// reserve from dispatchable gens
	  + (100.0 - reactivePowerLossPct[s1]) / 100 * StorReactiveRaiseReserve[s1][t]		// reserve from what is left of s1
	  + sum (s in isE_STORAGES diff({s1})) StorReactiveRaiseReserve[s][t]	  				// reserve from other storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadReactiveRaiseReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerLossPct[s1] / 100 * StorReactivePowerDischarge[s1][t] - StorReactivePowerRaiseReserveDeficit[s1][t];

// Reserve should cover surge of non-flexible load unit with largest consumption
	forall (n in isNF_E_LOADS: reactivePowerSurgePct[n] > 0, t in isDECISION_STEPS)
	  ctReactivePowerRaiseReserveNFLoad :
	  	sum (d in isDISP_E_GENS) DispGenReactiveRaiseReserve[d][t]					// reserve from dispatchable gens
	  + sum (s in isE_STORAGES) StorReactiveRaiseReserve[s][t]							// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadReactiveRaiseReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerSurgePct[n] / 100 * NFLoadReactivePower[n][t] - NFLoadReactivePowerRaiseReserveDeficit[n][t];

// LOWER RESRVE
// Reserve should cover surge of intermittent generation asset with largest generation
	forall (i1 in isINTER_E_GENS: reactivePowerSurgePct[i1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerLowerReserveInterGen :
	  	sum(d in isDISP_E_GENS) DispGenReactivePower[d][t]							// reserve from dispatchable gens
	  + (100.0 - reactivePowerSurgePct[i1]) / 100 * InterGenReactivePower[i1][t]		// reserve from what is left of p1
	  + sum (i in isINTER_E_GENS diff({i1})) InterGenReactivePower[i][t]				// reserve from other intermittent gen assets
	  + sum (s in isE_STORAGES) StorReactiveLowerReserve[s][t]							// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadReactiveLowerReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerSurgePct[i1] / 100 * InterGenReactivePower[i1][t] - InterGenReactivePowerLowerReserveDeficit[i1][t];

// Reserve should cover loss of storage asset with largest charge
	forall (s1 in isE_STORAGES: reactivePowerSurgePct[s1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerLowerReserveStorage :
	  	sum (d in isDISP_E_GENS) DispGenReactivePower[d][t]							// reserve from dispatchable gens
	  + sum (i in isINTER_E_GENS) InterGenReactivePower[i][t]							// reserve from intermittent gen assets
	  + (100.0 - reactivePowerSurgePct[s1]) / 100 * StorReactiveLowerReserve[s1][t]		// reserve from what is left of s1
	  + sum (s in isE_STORAGES diff({s1})) StorReactiveLowerReserve[s][t]					// reserve from other storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadActiveLowerReserve[f][t] >=						// reserve from flexible load units
	  reactivePowerSurgePct[s1] / 100 * StorReactivePowerCharge[s1][t] - StorReactivePowerLowerReserveDeficit[s1][t];

// Reserve should cover loss of flexible load unit with largest consumption
	forall (f1 in isFLEX_E_LOADS: reactivePowerLossPct[f1] > 0, t in isDECISION_STEPS)
	  ctReactivePowerLowerReserveFlexLoad :
	  	sum (d in isDISP_E_GENS) DispGenReactivePower[d][t]							// reserve from dispatchable gens
	  + sum (i in isINTER_E_GENS) InterGenReactivePower[i][t]							// reserve from intermittent gen assets
	  + sum (s in isE_STORAGES) StorReactiveLowerReserve[s][t]							// reserve from storage assets
	  + (100.0 - reactivePowerLossPct[f1]) / 100 * FlexLoadReactiveLowerReserve[f1][t]	// reserve from what is left of f1
	  + sum (f in isFLEX_E_LOADS diff({f1})) FlexLoadReactiveLowerReserve[f][t] >=		// reserve from other flexible load units
	  reactivePowerLossPct[f1] / 100 * FlexLoadReactivePower[f1][t] - FlexLoadReactivePowerLowerReserveDeficit[f1][t];

// Reserve should cover loss of non-flexible load unit with largest consumption
	forall (n in isNF_E_LOADS: reactivePowerLossPct[n] > 0, t in isDECISION_STEPS)
	  ctReactivePowerLowerReserveNFLoad :
	  	sum (d in isDISP_E_GENS) DispGenReactivePower[d][t]							// reserve from dispatchable gens
	  + sum (i in isINTER_E_GENS) InterGenReactivePower[i][t]							// reserve from intermittent gen assets
	  + sum (s in isE_STORAGES) StorReactiveLowerReserve[s][t]							// reserve from storage assets
	  + sum (f in isFLEX_E_LOADS) FlexLoadReactiveLowerReserve[f][t] >=					// reserve from flexible load units
	  reactivePowerLossPct[n] / 100 * NFLoadReactivePower[n][t] - NFLoadReactivePowerLowerReserveDeficit[n][t];
	  
/* Spinning reserve */
// RAISE RESERVE
// Raise reserve provided by assets should cover 30% of total non-flexibile load for each decision step
	forall (t in isDECISION_STEPS)
	  ctSpinningRaiseReserveReq:
		  sum (d in isDISP_E_GENS) DispGenSpinRaiseReserve[d][t] + sum (s in isE_STORAGES) StorSpinRaiseReserve[s][t] + sum (f in isFLEX_E_LOADS) FlexLoadSpinRaiseReserve[f][t]
		>= sum (n in isNF_E_LOADS) NFLoadSpinRaiseReserveReq[n] / 100 * NFLoadActivePower[n][t] - SpinningRaiseReserveDeficit[t];
// LOWER RESERVE
// Lower reserve provided by assets should cover 30% of total non-flexibile load for each decision step
	forall (t in isDECISION_STEPS)
	  ctSpinningLowerReserveReq:
		  sum (d in isDISP_E_GENS) DispGenSpinLowerReserve[d][t] + sum (s in isE_STORAGES) StorSpinLowerReserve[s][t] + sum (f in isFLEX_E_LOADS) FlexLoadSpinLowerReserve[f][t]
		>= sum (n in isNF_E_LOADS) NFLoadSpinLowerReserveReq[n] / 100 * NFLoadActivePower[n][t] - SpinningLowerReserveDeficit[t];

/* DEFAULT CURRENT */
// potential of current injection from assets must cover the global requirement for default current
	forall (t in isDECISION_STEPS)
	  ctDefaultCurrentReq :
	    sum (d in isDISP_E_GENS inter isDEFAULT_CURRENT_ASSET) IsGenOn[d][t] * dispGenCurrentInjection[d]
	  + sum (i in isINTER_E_GENS inter isDEFAULT_CURRENT_ASSET: maxInterGenActivePower[i][t] > 0.0) (1.0 - InterGenActivePower[i][t] / (-powerMin[i])) * interGenCurrentInjection[i]
	  + sum (s in isE_STORAGES inter isDEFAULT_CURRENT_ASSET: storMaxACActivePowerDischarge[s][t] > 0.0) storCurrentInjection[s][t]
	  >= defaultCurrentRequirement - DefaultCurrentRequirementDeficit[t];

/* SITES */
// Maximum input and output
 	forall (si in isSITES, t in isDECISION_STEPS)
 	  ctSiteMaxIn :
 	  -maxInput[si][t] <=
 	  sum(d in isDISP_E_GENS: si == siteID[d]) DispGenActivePower[d][t]
 	  + sum(i in isINTER_E_GENS: si == siteID[i]) InterGenActivePower[i][t]
 	  + sum(st in isE_STORAGES: si == siteID[st]) StorACActivePower[st][t]
 	  - sum(f in isFLEX_E_LOADS: si == siteID[f]) FlexLoadActivePower[f][t]
 	  - sum(n in isNF_E_LOADS: si == siteID[n]) NFLoadActivePower[n][t]
 	  - sum(fcr_a in isFCR_ASSETS: si == siteID[fcr_a]) FCRPower[fcr_a][assetStepFCRStep[t]]
 	  - sum(afrr_dwn_a in isaFRRDwn_ASSETS: si == siteID[afrr_dwn_a]) AFRRCapacityPowerDwn[afrr_dwn_a][assetStepAfrrVoluntaryStep[t]]    
 	  + SiteMaxInputViolation[si][t] - SiteMaxOutputViolation[si][t];

 	forall (si in isSITES, t in isDECISION_STEPS)
 	  ctSiteMaxOut :
 	  sum(d in isDISP_E_GENS: si == siteID[d]) DispGenActivePower[d][t]
 	  + sum(i in isINTER_E_GENS: si == siteID[i]) InterGenActivePower[i][t]
 	  + sum(st in isE_STORAGES: si == siteID[st]) StorACActivePower[st][t]
 	  - sum(f in isFLEX_E_LOADS: si == siteID[f]) FlexLoadActivePower[f][t]
 	  - sum(n in isNF_E_LOADS: si == siteID[n]) NFLoadActivePower[n][t]
 	  + sum(fcr_a in isFCR_ASSETS: si == siteID[fcr_a]) FCRPower[fcr_a][assetStepFCRStep[t]]
 	  + sum(afrr_up_a in isaFRRUp_ASSETS: si == siteID[afrr_up_a]) AFRRCapacityPowerUp[afrr_up_a][assetStepAfrrVoluntaryStep[t]]
 	  + SiteMaxInputViolation[si][t] - SiteMaxOutputViolation[si][t]
 	  <= maxOutput[si][t];

/* NETWORK CONGESTIONS */
// Generic congestion contraints
 	forall (c in isCONGESTIONS, t in isDECISION_STEPS)
 	  ctCongestionsIn :
 	  congestionLowerLim[c] <=
 	  	  importFactor[c] * NetElecImportTarget[t]
 	  	+ sum(d in isDISP_E_GENS) dispGenFactor[c][d] * DispGenActivePower[d][t]
 	  	+ sum(i in isINTER_E_GENS) interGenFactor[c][i] * InterGenActivePower[i][t]
 	  	+ sum(s in isE_STORAGES) injectionFactor[c][s] * StorACActivePower[s][t]
 	  	- sum(f in isFLEX_E_LOADS) flexLoadFactor[c][f] * FlexLoadActivePower[f][t]
 	  	- sum(n in isNF_E_LOADS) nonFlexLoadFactor[c][n] * NFLoadActivePower[n][t]
 	  	- sum(fcr_a in isFCR_ASSETS) fcrAssetFactor[c][fcr_a] * FCRPower[fcr_a][assetStepFCRStep[t]]
 	  	- sum(afrr_dwn_a in isaFRRDwn_ASSETS) afrrDwnAssetFactor[c][afrr_dwn_a] * AFRRCapacityPowerDwn[afrr_dwn_a][assetStepAfrrVoluntaryStep[t]]
 	  	+ CongestionLowerLimViolation[c][t] - CongestionUpperLimViolation[c][t];

 	 forall (c in isCONGESTIONS, t in isDECISION_STEPS)
 	  ctCongestionsOut :
 	  	  importFactor[c] * NetElecImportTarget[t]
 	  	+ sum(d in isDISP_E_GENS) dispGenFactor[c][d] * DispGenActivePower[d][t]
 	  	+ sum(i in isINTER_E_GENS) interGenFactor[c][i] * InterGenActivePower[i][t]
 	  	+ sum(s in isE_STORAGES) injectionFactor[c][s] * StorACActivePower[s][t]
 	  	- sum(f in isFLEX_E_LOADS) flexLoadFactor[c][f] * FlexLoadActivePower[f][t]
 	  	- sum(n in isNF_E_LOADS) nonFlexLoadFactor[c][n] * NFLoadActivePower[n][t]
 	  	+ sum(fcr_a in isFCR_ASSETS) fcrAssetFactor[c][fcr_a] * FCRPower[fcr_a][assetStepFCRStep[t]]
 	  	+ sum(afrr_up_a in isaFRRUp_ASSETS) afrrUpAssetFactor[c][afrr_up_a] * AFRRCapacityPowerUp[afrr_up_a][assetStepAfrrVoluntaryStep[t]]
 	  	+ CongestionLowerLimViolation[c][t] - CongestionUpperLimViolation[c][t]
 	  	<= congestionUpperLim[c];

// Specific congestion contraints
	if (microgridName == "MICROGRID MORBIHAN ENERGIES Kergrid") {
 	forall (t in isDECISION_STEPS)
 	  ctCongV1GC1C2 : sum (s in isE_STORAGES inter {"MORB_ENERGIES_Kergrid_V1G_C1", "MORB_ENERGIES_Kergrid_V1G_C2"}) StorACActivePower[s][t] >= -18.0;
  }

/*********************************************
 * Heat related constraints
 *********************************************/

/* HEAT BALANCE */
// Heat generated by dispatchable generation assets, injected by storage assets
// and converted by converter assets must balance with the heat consumed by
// non-flexible loads on each decision step.

	forall (t in isDECISION_STEPS)
	  ctHeatBalance:
	  	  sum(d in isDISP_H_GENS) DispGenHeat[d][t] 
	  	+ sum(s in isH_STORAGES) StorHeatExchange[s][t]
	  	+ sum(c in isHOUT_CONVS) ConvHeatOut[c][t]
	  	==
	  	  sum(n in isNF_H_LOADS) NFLoadHeat[n][t]
	  	- HeatDeficit[t] + HeatExcess[t];

 /* STORAGE HEAT INJECTION */
// Heat discharge should be equal to Zero when the heat storage asset is not available
	forall (s in isH_STORAGES, t in isDECISION_STEPS: heatStorAvail[s][t] != 1)
			ctAvaiHeatStorageDischarge: StorHeatDischarge[s][t] <= 0.0; 

// Heat charge should be equal to Zero when the heat storage asset is not available
	forall (s in isH_STORAGES, t in isDECISION_STEPS: heatStorAvail[s][t] != 1)
			ctAvaiHeatStorageCharge: StorHeatCharge[s][t] <= 0.0; 

// Heat consumption by a storage asset in charge is limited by its maximum charge rate
	forall (s in isH_STORAGES, t in isDECISION_STEPS: heatStorAvail[s][t] == 1)
	  ctHeatStorageChargeMax: StorHeatCharge[s][t] <= maxStorHeatCharge[s] * IsCharging[s][t];

// Heat injection by a storage asset in discharge is limited by its maximum discharge rate
	forall (s in isH_STORAGES, t in isDECISION_STEPS: heatStorAvail[s][t] == 1)
	  ctHeatStorageDischargeMax: StorHeatDischarge[s][t] <= maxStorHeatDischarge[s] * IsDischarging[s][t];

// Incremental charge / discharge definition
	forall (s in isH_STORAGES: storHeatDischargeEfficiency[s] > 0, t in isDECISION_STEPS)
	  ctHeatStorageIncrCharge: StorStepHeatIn[s][t] == (storHeatChargeEfficiency[s] / 100) * StorHeatCharge[s][t] * assetStepDurationInHours
	  - (100 / storHeatDischargeEfficiency[s]) * StorHeatDischarge[s][t] * assetStepDurationInHours;
	forall (s in isH_STORAGES: storHeatDischargeEfficiency[s] <= 0, t in isDECISION_STEPS)
	  ctHeatStorageIncrCharge0: StorStepHeatIn[s][t] ==  (storHeatChargeEfficiency[s] / 100) * StorHeatCharge[s][t] * assetStepDurationInHours;
	  
// Heat stored at end of step 1
	forall (s in isH_STORAGES)
	  ctHeatStorageStoredEnergy1: StorStoredHeat[s][first(isDECISION_STEPS)] == storInitialHeatCharge[s] + StorStepHeatIn[s][first(isDECISION_STEPS)];
	  
// Heat stored at end of other steps
	forall (s in isH_STORAGES, t in isDECISION_STEPS: t != first(isDECISION_STEPS))
	  ctHeatStorageStoredEnergy: StorStoredHeat[s][t] == StorStoredHeat[s][prev(isDECISION_STEPS, t)] + StorStepHeatIn[s][t];

// Physical capacity constraints for each heat storage units
	 forall (s in isH_STORAGES, t in isDECISION_STEPS)
	   ctPhysHeatCapacity: StorStoredHeat[s][t] <= storMaxHeatCharge[s];
	   
// Minimum SOC
 	forall (s in isH_STORAGES: storMaxHeatCharge[s] > 0, t in isDECISION_STEPS: heatStorAvail[s][t] == 1)
 	  ctHeatStorageMinSOC: storHeatMinSOC[s] - HeatSOCminDeficit[s][t] <= 100 * StorStoredHeat[s][t] / storMaxHeatCharge[s];

// Maximum SOC
 	forall (s in isH_STORAGES: storMaxHeatCharge[s] > 0, t in isDECISION_STEPS: heatStorAvail[s][t] == 1)
 	  ctHeatStorageMaxSOC: 100 * StorStoredHeat[s][t] / storMaxHeatCharge[s] <= storHeatMaxSOC[s] + HeatSOCmaxExcess[s][t];

 /* HEAT CONGESTIONS */
// HARD-CODED
// No more congestion for heat
	forall (t in isDECISION_STEPS)
	  ctHeatCongestion:
	  	  sum(d in isDISP_H_GENS) DispGenHeat[d][t] 
	  	+ sum(c in isHOUT_CONVS) ConvHeatOut[c][t]
	  	<= 50000.0;

/*********************************************
 * Electricity and heat related constraints
 *********************************************/

/* DISPATCHABLE GENERATION ASSETS THAT PRODUCE ELEC AND HEAT */
// Relation between elec generation and heat generation for dispatchable elec and heat generation assets
	forall (d in isDISP_EH_GENS, t in isDECISION_STEPS)
	  ctDispGenElecHeatRel : DispGenHeat[d][t] == disGenHeatElecRatio[d] * DispGenEffActivePower[d][t];

/* ENERGY CONVERTERS */
// Elec power consumed by an energy converter is limited by the maximum and the minimum power consumption possible for that asset
	forall (c in isEIN_CONVS, t in isDECISION_STEPS)
	  	  ctConvMinElecPowerIn:
	  	 ConvActivePowerIn[c][t] >= (convAvail[c][t] == 1 ? minConvActivePowerIn[c] : 0.0) * IsConvOn[c][t];
	forall (c in isEIN_CONVS, t in isDECISION_STEPS)
	  ctConvMaxElecPowerIn:
	  	ConvActivePowerIn[c][t] <= (convAvail[c][t] == 1 ? maxConvActivePowerIn[c] : 0.0) * IsConvOn[c][t];// Converters consuming something else than elec are not supported
	forall (c in isCONVS diff isEIN_CONVS, t in isDECISION_STEPS)
	  ctConvMinMaxNonElecPowerIn:
	  	ConvActivePowerIn[c][t] <= 0.0;

// Conversion into heat
	forall (c in isHOUT_CONVS, t in isDECISION_STEPS)
	  ctToHeatConv : ConvHeatOut[c][t] == convElecToHeatEff[c] * ConvActivePowerIn[c][t];
// Converters producing something else than heat are not supported
	forall (c in isCONVS diff isHOUT_CONVS, t in isDECISION_STEPS)
	  ctToNonHeatConv : ConvHeatOut[c][t] <= 0.0;
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
{t_empty} OPERATION_STEPS_HEADER = {<"step_id", "step_duration", "electricity_price", "imbalance_power", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
{t_empty} ASSETS_HEADER = {<"asset_id", "control", "non_fcr_energy_out", "optimised_non_fcr_energy_out", "fcr_energy_out", "optimised_fcr_energy_out", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
{t_empty} ASSET_STEPS_HEADER = {<"asset_id", "step_id", "power_target", "storage_target", "temperature_target", "curtailment_target","target_soc", "fcr_engagement", "afrr_up_engagement", "afrr_down_engagement", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
{t_empty} VIOLATIONS_OUTPUT_HEADER = {<"violation_type", "asset_id", "step_id", "violation_value", "violation_criticality", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};
{t_empty} MARKET_BIDS_OUTPUT_HEADER = {<"step_id", "type", "direction", "step_duration", "power", "price", "", "", "", "", "", "", "", "", "", "", "", "", "", ""> | i in 1..1};

/* OPERATION DATA */
tuple t_operation_output {
 	key string param_id;
 	string param_val;
 }
string strSolStatus;
string strObjVal;
string strDispatchStatusString = "Dispatch found";
string strTotalTradeNetworkCosts;
string strOptimisedTradeNetworkCosts;
string strTotalFCRNetworkCosts;
string strOptimisedFCRNetworkCosts;
string strElectricityTotalNetRevenue;
string strOptimisedElecNetCosts;
string strGenTotalLinearVarCosts;
string strGenTotalNonLinVarCosts;
string strDispGenTotalStartupCosts;
string strInterGenTotalCurtCosts;
string strConvTotalLinearCosts;
string strStorChargeDischargeCost;
string strDayAheadTotalTradeCost;
string strDayAheadOptimisedTradeCost;
string strDayAheadTotalFCRCost;
string strDayAheadOptimisedFCRCost;
string strImbalanceTotalCost;
string strImbalanceOptimisedCost;
string strOptimisedNetRevenues;
{t_operation_output} OPERATION_OUTPUT = {<"operation_id", operationID>	 									// variable holding OPERATION output data
										, <"optimisation_request_time", optimisationRequestTime>
										, <"optimisation_interval_start", optimisationIntervalStartTime>
										, <"optimiser_solution_status", strSolStatus>
										, <"optimiser_solution_description", strDispatchStatusString>
										, <"optimiser_objective_value", strObjVal>
										, <"network_total_trade_costs", strTotalTradeNetworkCosts>			// TotalTradeNetworkCosts
										, <"network_opt_trade_costs", strOptimisedTradeNetworkCosts>		// OptimisedTradeNetworkCosts
										, <"network_total_fcr_costs", strTotalFCRNetworkCosts>				// TotalFCRNetworkCosts
										, <"network_opt_fcr_costs", strOptimisedFCRNetworkCosts>			// OptimisedFCRNetworkCosts
										, <"contract_total_net_costs", strElectricityTotalNetRevenue>		// ElectricityTotalNetCosts
										, <"contract_opt_net_costs", strOptimisedElecNetCosts>				// OptimisedElecNetCosts
										, <"lin_gen_var_costs", strGenTotalLinearVarCosts>					// GenTotalLinearVarCosts
										, <"non_lin_gen_var_costs", strGenTotalNonLinVarCosts>				// GenTotalNonLinVarCosts
										, <"disp_gen_start_up_costs", strDispGenTotalStartupCosts>			// DispGenTotalStartupCosts
										, <"inter_gen_var_cost", strInterGenTotalCurtCosts>					// InterGenTotalCurtCosts
										, <"conv_var_cost", strConvTotalLinearCosts>						// ConvTotalLinearCosts
										, <"storage_use_penalties", strStorChargeDischargeCost>				// StorChargeDischargeCost
										, <"day_ahead_total_trade_costs", strDayAheadTotalTradeCost>		// DayAheadTotalTradeCost
										, <"day_ahead_opt_trade_costs", strDayAheadOptimisedTradeCost>		// DayAheadOptimisedTradeCost
										, <"day_ahead_total_fcr_costs", strDayAheadTotalFCRCost>			// DayAheadTotalFCRCost
										, <"day_ahead_opt_fcr_costs", strDayAheadOptimisedFCRCost>			// DayAheadOptimisedFCRCost
										, <"imbalance_total_net_costs", strImbalanceTotalCost>				// ImbalanceTotalCost
										, <"imbalance_opt_net_costs", strImbalanceOptimisedCost>			// ImbalanceOptimisedCost
										, <"net_optimised_revenues", strOptimisedNetRevenues>
										};
										
/* OPERATION x STEPS OUTPUT DATA */
tuple t_operation_steps_output {
 	key string step_id;
 	int step_duration;
 	float electricity_price;
 	float imbalance_power;
 	}

{t_operation_steps_output} OPERATION_STEPS_OUTPUT = {<t, assetStepDuration, electricityPrice[t], ImbalancePower_imb[assetStepImbalanceStep[t]]> | t in isDECISION_STEPS}; // variable holding OPERATION x STEPS output data
string operationStepsExcelRange = "'OPERATION_STEPS_OUTPUT'!A2:D";

/* ASSETS OUTPUT DATA */
tuple t_assets_output {
 	key string asset_id;
 	string control;
 	float non_fcr_energy_out;
 	float optimised_non_fcr_energy_out;
 	float fcr_energy_out;
 	float optimised_fcr_energy_out;
 	}

float nonFCRenergyOut[isASSETS];
float optimisedNonFCRenergyOut[isASSETS];
float FCRenergyOut[isASSETS];
float optimisedFCRenergyOut[isASSETS];
{t_assets_output} ASSETS_OUTPUT = {<a.asset_id, a.control, nonFCRenergyOut[a.asset_id], optimisedNonFCRenergyOut[a.asset_id], FCRenergyOut[a.asset_id], optimisedFCRenergyOut[a.asset_id]> | a in ASSETS}; // variable holding ASSETS output data
string assetsExcelRange = "'ASSETS_OUTPUT'!A2:F";

/* ASSET x STEPS OUTPUT DATA */
tuple t_asset_steps_output {
 	key string asset_id;
 	key string step_id;
 	float power_target;
 	float storage_target;
 	float temperature_target;
 	float curtailment_target;
	float target_soc;
	float fcr_engagement;
	float afrr_up_engagement;
	float afrr_down_engagement;
 	}

float assetPowerTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetStorageTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetSOCTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetTempTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetCurtailmentTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetFCRTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetAFRRCapacityPowerUpTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
float assetAFRRCapacityPowerDwnTarget[isASSETS union {"MAINGRID"}][isDECISION_STEPS];
{t_asset_steps_output} ASSET_STEPS_OUTPUT = {<a, t, assetPowerTarget[a][t], assetStorageTarget[a][t] , assetTempTarget[a][t], assetCurtailmentTarget[a][t], assetSOCTarget[a][t], 
											assetFCRTarget[a][t], assetAFRRCapacityPowerUpTarget[a][t], assetAFRRCapacityPowerDwnTarget[a][t]> | a in isASSETS union {"MAINGRID"}, t in isDECISION_STEPS}; // variable holding ASSET x STEPS output data
string assetStepsExcelRange = "'ASSET_STEPS_OUTPUT'!A2:J";
 
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

/* MARKET BIDS OUTPUT DATA */
tuple t_market_bids_output {
 	key string step_id;			// day_ahead / fcr market step_id / afrr voluntary step id
 	key string type;			// bids  type : day_ahead or fcr or aFRR
 	key string direction;		// BUY or SELL, UP or down
 	int step_duration;			// day_ahead / fcr Power step duration / afrr Voluntary step duration
 	float power;				// day_ahead / fcr Power engagement / aFRR power engagement
	float price;					// bids Price : 0 by default
 	}

{t_market_bids_output} MARKET_BIDS_OUTPUT = {<h, "DAY_AHEAD", (DaPosition[h] <= 0 ? "SELL" : "BUY"), daStepDuration, DaPosition[h], (DaPosition[h] <= 0 ? 0 : daElecPrice[h])>| h in isHOURLY_STEPS_POS}
											union {<fcr, "FCR", "SELL", fcrStepDuration, FCRPower[fcr_a][fcr], 0>| fcr in isFCR_STEPS_POS, fcr_a in isFCR_ASSETS}
											union {<afrr_v, "AFRR_POWER", "UP", afrrVoluntaryStepDuration, aFRRUpReqPower[afrr_v], 0.0> | afrr_v in isAFRR_VOLUNTARY_STEPS_POS}
											union {<afrr_v, "AFRR_POWER", "DOWN", afrrVoluntaryStepDuration, aFRRDwnReqPower[afrr_v], 0.0> | afrr_v in isAFRR_VOLUNTARY_STEPS_POS};// variable holding ENERGY_BIDS output data
											
string marketBidsExcelRange = "'MARKET_BIDS_OUTPUT'!A2:F";
int nMarketBids = card(isHOURLY_STEPS_POS) + card(isFCR_STEPS_POS)*card(isFCR_ASSETS) + 2*card(isAFRR_VOLUNTARY_STEPS_POS);

execute {
	strSolStatus = cplex.getCplexStatus().toString();
	strObjVal = cplex.getObjValue().toString();
	assetsExcelRange += (assetNumber + 1).toString();
 	assetStepsExcelRange += (optimisationStepNumber * (assetNumber+1) + 1).toString();
 	operationStepsExcelRange += (optimisationStepNumber + 1).toString();
	marketBidsExcelRange += (nMarketBids+2).toString();
	strTotalTradeNetworkCosts = TotalTradeNetworkCosts;
	strOptimisedTradeNetworkCosts = OptimisedTradeNetworkCosts;
	strTotalFCRNetworkCosts = TotalFCRNetworkCosts;
	strOptimisedFCRNetworkCosts = OptimisedFCRNetworkCosts;
	strElectricityTotalNetRevenue = ElectricityTotalNetCosts;
	strOptimisedElecNetCosts = OptimisedElecNetCosts;
	strGenTotalLinearVarCosts = GenTotalLinearVarCosts;
	strGenTotalNonLinVarCosts = GenTotalNonLinVarCosts;
	strDispGenTotalStartupCosts = DispGenTotalStartupCosts;
	strInterGenTotalCurtCosts = InterGenTotalCurtCosts;
	strConvTotalLinearCosts = ConvTotalLinearCosts;
	strStorChargeDischargeCost = StorChargeDischargeCost;
	strDayAheadTotalTradeCost = DayAheadTotalTradeCost;
	strDayAheadOptimisedTradeCost = DayAheadOptimisedTradeCost;
	strDayAheadTotalFCRCost = DayAheadTotalFCRCost;
	strDayAheadOptimisedFCRCost = DayAheadOptimisedFCRCost;
	strImbalanceTotalCost = ImbalanceTotalCost;
	strImbalanceOptimisedCost = ImbalanceOptimisedCost;
	strOptimisedNetRevenues = - DayAheadOptimisedTradeCost - OptimisedTradeNetworkCosts - DayAheadOptimisedFCRCost - OptimisedFCRNetworkCosts;

 	// fill in asset targets according to types of asset and types of control 
 	for (var t in isDECISION_STEPS) {
 		
 		// power import targets for connection to main-grid
 		assetPowerTarget["MAINGRID"][t] = NetElecImportTarget[t];
 		// power generation target for intermittent generation assets at the end of each time step
 		for	(var i in isINTER_E_GENS)
 		{
// 				assetPowerTarget[i][t] = -InterGenActivePowerEnd[i][t];				// respects Everest's sign convention (-ve values = power generation)
 				assetPowerTarget[i][t] = -InterGenActivePower[i][t];				// respects Everest's sign convention (-ve values = power generation)
 				assetCurtailmentTarget[i][t] = -InterGenPowerCurtailment[i][t];		// respects Everest's sign convention (-ve values = power generation)
  		}

  		// power generation target for dispatchable generation assets
 		for	(var d in isDISP_E_GENS)
 		{
// 			assetPowerTarget[d][t] = -DispGenActivePowerEnd[d][t];				// respects Everest's sign convention (-ve values = power generation)
 			assetPowerTarget[d][t] = -DispGenActivePower[d][t];				// respects Everest's sign convention (-ve values = power generation)
  		}

  		// consumption forecasts for non-flexible elec loads
 		for	(var n in isNF_E_LOADS)
 		{
 			assetPowerTarget[n][t] = NFLoadActivePower[n][t];					// respects Everest's sign convention (+ve values = power consumption)
			// temporary workaround to send battery's projected SOC
			if ((microgridName == "MICROGRID MORBIHAN ENERGIES FlexMobIle" || microgridName == "MICROGRID MORBIHAN ENERGIES Kergrid")
				&& storMaxDCEnergy[Opl.first(isE_STORAGES)][t] > 0.0)
 				assetTempTarget[n][t] = 100 * StorStoredDCEnergy[Opl.first(isE_STORAGES)][t] / storMaxDCEnergy[Opl.first(isE_STORAGES)][t];
		}
  		
  		// consumption forecasts for non-flexible heat loads
 		for	(var n in isNF_H_LOADS)
 		{
 			assetPowerTarget[n][t] = NFLoadHeat[n][t];					// respects Everest's sign convention (+ve values = power consumption)
		}
  		
  		// consumption targets for flexible load units 
 		for	(var f in isFLEX_E_LOADS)
 		{
 			assetPowerTarget[f][t] = FlexLoadActivePower[f][t];					// respects Everest's sign convention (+ve values = power consumption)
  		} 			
  		
  		// temperature targets for flexible load units that are controled by temperature setpoints
  		for	(var f in isTC_FLEX_E_LOADS) {
 			assetTempTarget[f][t] = (ModulationTarget[f][t] < -epsilon ? targetLevelTemps[f]["LOW"] :
 									(ModulationTarget[f][t] > epsilon ? targetLevelTemps[f]["HIGH"] :
 									targetLevelTemps[f]["NOMINAL"]));
  		}

  		// elec power charge / discharge targets and elec energy storage targets for elec storage units
 		for	(var s in isE_STORAGES)
 		{
 			assetPowerTarget[s][t] = -StorACActivePower[s][t];					// respects Everest's sign convention (+ve values = power charge and -ve values = power discharge)
 			assetStorageTarget[s][t] = StorStoredDCEnergy[s][t];
 			nonFCRenergyOut[s] = nonFCRenergyOut[s] + Opl.maxl(StorACActivePower[s][t], 0.0) * assetStepDurationInHours;
 			FCRenergyOut[s] = FCRenergyOut[s] + FCRPower_MW[s][assetStepFCRStep[t]] * 1000.0 * FCRUnitarianStepACEnergyOut;
 			if (isDAStepCleared[assetStepHourlyStep[t]] == 0) {
 				optimisedNonFCRenergyOut[s] = optimisedNonFCRenergyOut[s] + Opl.maxl(StorACActivePower[s][t], 0.0) * assetStepDurationInHours;
 				optimisedFCRenergyOut[s] = optimisedFCRenergyOut[s] + FCRPower_MW[s][assetStepFCRStep[t]] * 1000.0 * FCRUnitarianStepACEnergyOut;
   			}
  		}

  		// heat power charge / discharge targets and heat energy storage targets for heat storage units
 		for	(var s in isH_STORAGES)
 		{
 			assetPowerTarget[s][t] = -StorHeatExchange[s][t];					// respects Everest's sign convention (+ve values = power charge and -ve values = power discharge)
 			assetStorageTarget[s][t] = StorStoredHeat[s][t];
  		} 			
  		
		// elec soc targets for elec storage units
 		for	(var s in isE_STORAGES)
 		{
 			assetSOCTarget[s][t] = ElecStorSocTarget[s][t];

  		}

  		// heat soc targets for heat storage units
 		for	(var h in isH_STORAGES)
 		{
			assetSOCTarget[h][t] = HeatStorSocTarget[h][t];
  		}

  		// consumption targets for energy converters consuming elec
 		for	(var c in isEIN_CONVS)
 		{
 			assetPowerTarget[c][t] = ConvActivePowerIn[c][t];					// respects Everest's sign convention (+ve values = power consumption)
  		}
  		// fcr target lane, as well as aFRR up and down
  		FCRPower[a][assetStepFCRStep[t]], AFRRCapacityPowerUp[a][assetStepAfrrVoluntaryStep[t]], AFRRCapacityPowerDwn[a][assetStepAfrrVoluntaryStep[t]] 			
  		assetFCRTarget["MAINGRID"][t] = fcrReqPower[assetStepFCRStep[t]];
  		assetAFRRCapacityPowerUpTarget["MAINGRID"][t] = aFRRUpReqPower[assetStepAfrrVoluntaryStep[t]];
  		assetAFRRCapacityPowerDwnTarget["MAINGRID"][t] = aFRRDwnReqPower[assetStepAfrrVoluntaryStep[t]];
  		
  		for (var a in isASSETS)
  		{
  		 	assetFCRTarget[a][t] = FCRPower[a][assetStepFCRStep[t]];
  		 	assetAFRRCapacityPowerUpTarget[a][t] = AFRRCapacityPowerUp[a][assetStepAfrrVoluntaryStep[t]];
  			assetAFRRCapacityPowerDwnTarget[a][t] = AFRRCapacityPowerDwn[a][assetStepAfrrVoluntaryStep[t]]; 		
  		}
  		
//  		// generation targets for energy converters generating elec 
// 		for	(var c in isEOUT_CONVS)
// 		{
// 			assetPowerTarget[c][t] = -ConvActivePowerOut[c][t];					// respects Everest's sign convention (-ve values = power generation)
//  		} 			
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
 
	// check if any heat balance violation
	anyDeficit = false;
	anyExcess = false;
	for (var t in isDECISION_STEPS) {
		// heat deficit
		if (HeatDeficit[t] > epsilon) {
			if (!anyDeficit) {
				strDispatchStatusString += ", some heat balance constraint deficit";
				anyDeficit = true;
 			}

			VIOLATIONS_OUTPUT.add("heat_balance_constraint_deficit", "", t, HeatDeficit[t], 1);
		}
		// heat excess
		if (HeatExcess[t] > epsilon) {
			if (!anyExcess) {
				strDispatchStatusString += ", some heat balance constraint excess";
				anyExcess = true;
 			}

			VIOLATIONS_OUTPUT.add("heat_balance_constraint_excess", "", t, HeatExcess[t], 1);
		}
	}

	// check if any unauthorized intermittent generation curtailment 
	var anyViolation = false;
	for (var t in isDECISION_STEPS)
		if (UnauthorizedInterGenCurt[t] > epsilon) {
			if (!anyViolation) {
				strDispatchStatusString += ", some unauthorized intermittent generation curtailment";
				anyViolation = true;
		}

				VIOLATIONS_OUTPUT.add("unauthorized_intermittent_generation_curtailment", "", t, UnauthorizedInterGenCurt[t], 100);
			}
 
	// check if any storage charge violation
	var anyMinSOCdeficit = false;
	var anyStrictMinSOCdeficit = false;
	var anyMaxSOCexcess = false;
	var anyTargetSOCdeficit = false;
	var anyMaxCycleexcess = false;
	for (var s in isE_STORAGES)
		for (var t in isDECISION_STEPS) {
			// min SOC deficit
			if (SOCminDeficit[s][t] > epsilon) {
				if (!anyMinSOCdeficit) {
					strDispatchStatusString += ", some minimum SOC deficit";
					anyMinSOCdeficit = true;
	 			}
	
				VIOLATIONS_OUTPUT.add("minimum_SOC_deficit", s, t, SOCminDeficit[s][t], 100);
			}
			// strict min SOC deficit
			if (SOCstrictMinDeficit[s][t] > epsilon) {
				if (!anyStrictMinSOCdeficit) {
					strDispatchStatusString += ", some strict minimum SOC deficit";
					anyStrictMinSOCdeficit = true;
	 			}
	
				VIOLATIONS_OUTPUT.add("strict_minimum_SOC_deficit", s, t, SOCstrictMinDeficit[s][t], 1);
			}
			// max SOC excess
			if (SOCmaxExcess[s][t] > epsilon) {
				if (!anyMaxSOCexcess) {
					strDispatchStatusString += ", some maximum SOC excess";
					anyMaxSOCexcess = true;
	 			}
	
				VIOLATIONS_OUTPUT.add("maximum_SOC_excess", s, t, SOCmaxExcess[s][t], 1);
			}
			// target SOC violation
			if (minSocTargetStorageDeficit[s][t] > epsilon) {
				if (!anyTargetSOCdeficit) {
					strDispatchStatusString += ", some Target SOC deficit";
					anyTargetSOCdeficit = true;
	 			}
				VIOLATIONS_OUTPUT.add("soc_target_deficit", s, t, minSocTargetStorageDeficit[s][t], 100);
			}
			// maximum number of daily cycles violation
			if (StorageDailyMaxNumCyclExcess[s][t] > epsilon) {
				if (!anyMaxCycleexcess) {
					strDispatchStatusString += ", Maximum number of battery's cycles per day Excess";
					anyMaxCycleexcess = true;
	 			}
				VIOLATIONS_OUTPUT.add("Storage_Maximum_Cycles_Per_Day_Excess", s, t, StorageDailyMaxNumCyclExcess[s][t], 1);
			}
		}
		
	// check if any heat storage charge violation
	anyMinSOCdeficit = false;
	anyMaxSOCexcess = false;
	for (var s in isH_STORAGES)
		for (var t in isDECISION_STEPS) {
			// min SOC deficit
			if (HeatSOCminDeficit[s][t] > epsilon) {
				if (!anyMinSOCdeficit) {
					strDispatchStatusString += ", some heat minimum SOC deficit";
					anyMinSOCdeficit = true;
	 			}
	
				VIOLATIONS_OUTPUT.add("minimum_heat_SOC_deficit", s, t, HeatSOCminDeficit[s][t], 1);
			}
			// max SOC excess
			if (HeatSOCmaxExcess[s][t] > epsilon) {
				if (!anyMaxSOCexcess) {
					strDispatchStatusString += ", some heat maximum SOC excess";
					anyMaxSOCexcess = true;
	 			}
	
				VIOLATIONS_OUTPUT.add("maximum_heat_SOC_excess", s, t, HeatSOCmaxExcess[s][t], 1);
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
	
	//Check if any dispatchable gen minimum active power constraint violation
	anyDeficit = false;
	for (var d in isDISP_E_GENS)
		for (var t in isDECISION_STEPS) {
			if(DispGenMinActivePowerDeficit[d][t] > epsilon){
				if (!anyDeficit) {
					strDispatchStatusString += ", some minimum power deficit";
					anyDeficit = true;
 			}
 			VIOLATIONS_OUTPUT.add("disp_gen_min_active_power_deficit", d, t, DispGenMinActivePowerDeficit[d][t], 1);
			}		
		}

	// check if any min/max steps on/off constraint violation for initial steps
	var anyMinStepsOnViolation = false;
	var anyMaxStepsOnViolation = false;
	var anyMinStepsOffViolation = false;
	for (var d in isDISP_E_GENS) {
		// initial min steps on violation
		if (DispGenMinStepOnInitialDeficit[d] > epsilon) {
			if (!anyMinStepsOnViolation) {
				strDispatchStatusString += ", some deficit of initial minimum steps on constraint";
				anyMinStepsOnViolation = true;			
			}
			
			VIOLATIONS_OUTPUT.add("disp_gen_initial_min_steps_on_deficit", d, "", DispGenMinStepOnInitialDeficit[d], 10);
		}
		// initial max steps on violation
		for (var i = 0 ; i <= genInitialStepsOnMax[d]-1 ; i++)
			if (DispGenMaxStepOnInitialExcess[d][i] > epsilon) {
				if (!anyMaxStepsOnViolation) {
					strDispatchStatusString += ", some excess of initial maximum steps on constraint";
					anyMaxStepsOnViolation= true;			
				}
				
				VIOLATIONS_OUTPUT.add("disp_gen_initial_max_steps_on_excess", d, (i-genInitialStepsOnMax[d]).toString(), DispGenMaxStepOnInitialExcess[d][i], 10);
			}
		// initial min steps off violation
		if (DispGenMinStepOffInitialDeficit[d] > epsilon) {
			if (!anyMinStepsOffViolation) {
				strDispatchStatusString += ", some deficit of initial minimum steps off constraint";
				anyMinStepsOffViolation = true;			
			}
			
			VIOLATIONS_OUTPUT.add("disp_gen_initial_min_steps_off_deficit", d, "", DispGenMinStepOffInitialDeficit[d], 10);
		}
	}
	
	// check if any min/max steps on/off constraint violation for other steps
	anyMinStepsOnViolation = false;
	anyMaxStepsOnViolation = false;
	anyMinStepsOffViolation = false;
	for (var d in isDISP_E_GENS)
		for (var t in isDECISION_STEPS) {
			// min steps on violation
			if (DispGenMinStepOnDeficit[d][t] > epsilon) {
				if (!anyMinStepsOnViolation) {
					strDispatchStatusString += ", some deficit of minimum steps on constraint";
					anyMinStepsOnViolation = true;			
				}
				
				VIOLATIONS_OUTPUT.add("disp_gen_min_steps_on_deficit", d, t, DispGenMinStepOnDeficit[d][t], 10);
			}
			// max steps on violation
			if (DispGenMaxStepOnExcess[d][t] > epsilon) {
				if (!anyMaxStepsOnViolation) {
					strDispatchStatusString += ", some excess of maximum steps on constraint";
					anyMaxStepsOnViolation= true;			
				}
				
				VIOLATIONS_OUTPUT.add("disp_gen_max_steps_on_excess", d, t, DispGenMaxStepOnExcess[d][t], 10);
			}
			// min steps off violation
			if (DispGenMinStepOffDeficit[d][t] > epsilon) {
				if (!anyMinStepsOffViolation) {
					strDispatchStatusString += ", some deficit of minimum steps off constraint";
					anyMinStepsOffViolation = true;			
				}
				
				VIOLATIONS_OUTPUT.add("disp_gen_min_steps_off_deficit", d, t, DispGenMinStepOffDeficit[d][t], 10);
			}
		}
	
	// check if any active power reserve constraint violation for dispatchable gens
	var anyRaiseReserveDeficit = false;
	var anyLowerReserveDeficit = false;
	for (var d in isDISP_E_GENS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (DispGenActivePowerRaiseReserveDeficit[d][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power raise reserve to cover loss of dispatchable generation";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("disp_gen_active_power_raise_reserve_deficit", d, t, DispGenActivePowerRaiseReserveDeficit[d][t], 10);
			}
 		}

 	// check if any reactive power reserve constraint violation for dispatchable gens
	var anyRaiseReserveDeficit = false;
	var anyLowerReserveDeficit = false;
	for (var d in isDISP_E_GENS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (DispGenReactivePowerRaiseReserveDeficit[d][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power raise reserve to cover loss of dispatchable generation";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("disp_gen_reactive_power_raise_reserve_deficit", d, t, DispGenReactivePowerRaiseReserveDeficit[d][t], 10);
			}
 		}

	// check if any active power reserve constraint violation for intermittent generation
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var i in isINTER_E_GENS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (InterGenActivePowerRaiseReserveDeficit[i][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power raise reserve to cover loss of intermittent generation";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_gen_active_power_raise_reserve_deficit", i, t, InterGenActivePowerRaiseReserveDeficit[i][t], 10);
			}
			// lower reserve violation
			if (InterGenActivePowerLowerReserveDeficit[i][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of active power lower reserve to cover surge of intermittent generation";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_gen_active_power_lower_reserve_deficit", i, t, InterGenActivePowerLowerReserveDeficit[i][t], 10);
			}
 		}		
	
	// check if any reactive power reserve constraint violation for intermittent generation
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var i in isINTER_E_GENS)
		for (var t in isDECISION_STEPS) {
			// raise reserve violation
			if (InterGenReactivePowerRaiseReserveDeficit[i][t] > epsilon) {
				if (!anyRaiseReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power raise reserve to cover loss of intermittent generation";
					anyRaiseReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_gen_reactive_power_raise_reserve_deficit", i, t, InterGenReactivePowerRaiseReserveDeficit[i][t], 10);
			}
			// lower reserve violation
			if (InterGenReactivePowerLowerReserveDeficit[i][t] > epsilon) {
				if (!anyLowerReserveDeficit) {
					strDispatchStatusString += ", some deficit of reactive power lower reserve to cover surge of intermittent generation";
					anyLowerReserveDeficit = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_gen_reactive_power_lower_reserve_deficit", i, t, InterGenReactivePowerLowerReserveDeficit[i][t], 10);
			}
 		}	

	// check if any active power reserve constraint violation for storage
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var s in isE_STORAGES)
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
	for (var s in isE_STORAGES)
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
	for (var f in isFLEX_E_LOADS)
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
	for (var f in isFLEX_E_LOADS)
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
	for (var n in isNF_E_LOADS)
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
	for (var n in isNF_E_LOADS)
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

	// check if any spinning reserve deficit
	anyRaiseReserveDeficit = false;
	anyLowerReserveDeficit = false;
	for (var t in isDECISION_STEPS) {
		// raise reserve violation
		if(SpinningRaiseReserveDeficit[t] > epsilon) {
			if (!anyRaiseReserveDeficit) {
				strDispatchStatusString += ", some deficit of spinning raise reserve";
				anyRaiseReserveDeficit = true;
 			}

			VIOLATIONS_OUTPUT.add("spinning_raise_reserve_deficit", n, t, SpinningRaiseReserveDeficit[t], 10);
		}
		// lower reserve violation
		if(SpinningLowerReserveDeficit[t] > epsilon) {
			if (!anyLowerReserveDeficit) {
				strDispatchStatusString += ", some deficit of spinning lower reserve";
				anyRaiseReserveDeficit = true;
 			}

			VIOLATIONS_OUTPUT.add("spinning_lower_reserve_deficit", n, t, SpinningLowerReserveDeficit[t], 10);
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

	// check if there is any change in the InterGenElecActivePowerForecast
	var anyInterGenChangeForecast = false;
	for (var i in isINTER_E_GENS)
		for (var t in isDECISION_STEPS) {
			if (interGenChangedForecast[i][t] > epsilon) {
				if (!anyInterGenChangeForecast) {
					strDispatchStatusString += ", some changes in the intermittent generation forecast";
					anyInterGenChangeForecast = true;
	 			}

				VIOLATIONS_OUTPUT.add("inter_gen_active_power_forecast_change_flag", i, t, interGenChangedForecast[i][t], 100);
			}
		}

	// check if there is any change in the NFLoadForecast
	var anyNFElecLoadChangeForecast = false;
	for (var n in isNF_E_LOADS)
		for (var t in isDECISION_STEPS) {
			if (NFElecLoadChangedForecast[n][t] > epsilon) {
				if (!anyNFElecLoadChangeForecast) {
					strDispatchStatusString += ", some changes in consumption forecast for non-flexible elec load";
					anyNFElecLoadChangeForecast = true;
	 			}

				VIOLATIONS_OUTPUT.add("NF_elec_load_active_power_forecast_change_flag", n, t, NFElecLoadChangedForecast[n][t], 100);
			}
		}

	// check if there is any change in the NFHeatLoadForecast
	var anyNFLoadHeatChangeForecast = false;
	for (n in isNF_H_LOADS)
		for (var t in isDECISION_STEPS) {
			if (NFLoadHeatChangedForecast[n][t] > epsilon) {
				if (!anyNFLoadHeatChangeForecast) {
					strDispatchStatusString += ", some changes in consumption forecast for non-flexible heat load";
					anyNFLoadHeatChangeForecast = true;
	 			}

				VIOLATIONS_OUTPUT.add("NF_heat_load_power_forecast_change_flag", n, t, NFLoadHeatChangedForecast[n][t], 100);
			}
 		}

	// check if there is any change in the flexLoadForecast
	var anyflexLoadChangeForecast = false;
	for (f in isFLEX_E_LOADS)
		for (var t in isDECISION_STEPS) {
			if ( flexLoadChangedForecast[f][t] > epsilon) {
				if (!anyflexLoadChangeForecast) {
					strDispatchStatusString += ", changes in consumption forecast for flexible load";
					anyflexLoadChangeForecast = true;
	 			}

				VIOLATIONS_OUTPUT.add("flex_load_active_power_forecast_change_flag", f, t,  flexLoadChangedForecast[f][t], 100);
			}
 		}

	// check if there is any change in the fcrEngPower
	// check if there is any FCR Power requirement violation
	var anyFcrEngPowerChange = false;
	var anyFcrReqPowerDeficit = false;
	for (var t in isFCR_STEPS) {
		if (fcrReqPower[t] < fcrEngPower[t] - epsilon) {
			if (!anyFcrEngPowerChange) {
				strDispatchStatusString += ", reductions of FCR engagement";
				anyFcrEngPowerChange = true;
 			}

			VIOLATIONS_OUTPUT.add("fcr_engagement_reduction_flag", "", t,  fcrEngPower[t] - fcrReqPower[t], 1);
		}

		if (FCRPowerEngDeficit[t] > epsilon) {
			if (!anyFcrEngPowerChange) {
				strDispatchStatusString += ", some FCR requirement violation";
				anyFcrEngPowerChange = true;
 			}
 			VIOLATIONS_OUTPUT.add("Pool_FCR_Power_requirement_violation", "", t,  FCRPowerEngDeficit[t], 1);
		}
	}
	// check if there is any change in the afrrUp and down EngPower
	// check if there is any aFRR up or down Power requirement violation
	var anyAfrrUpEngPowerChange = false;
	var anyAfrrDwnEngPowerChange = false;
	var anyAfrrUpReqPowerDeficit = false;
	var anyAfrrDwnReqPowerDeficit = false;
	for (var t in isAFRR_VOLUNTARY_STEPS) {
		if (aFRRUpReqPower[t] < aFRRUpEngPower[t] - epsilon) {
			if (!anyAfrrUpEngPowerChange) {
				strDispatchStatusString += ", reductions of aFRR Up engagement";
				anyaFRRUpEngPowerChange = true;
 			}

			VIOLATIONS_OUTPUT.add("afrr_up_engagement_reduction_flag", "", t,  aFRRUpEngPower[t] - aFRRUpReqPower[t], 1);
		}
		
		if (aFRRDwnReqPower[t] < aFRRDwnEngPower[t] - epsilon) {
			if (!anyAfrrDwnEngPowerChange) {
				strDispatchStatusString += ", reductions of aFRR Down engagement";
				anyaFRRDwnEngPowerChange = true;
 			}

			VIOLATIONS_OUTPUT.add("afrr_down_engagement_reduction_flag", "", t,  aFRRDwnEngPower[t] - aFRRDwnReqPower[t], 1);
		}

		if (AFRRUpCapacityDeficit[t] > epsilon) {
			if (!anyAfrrUpEngPowerChange) {
				strDispatchStatusString += ", some AFRR Up requirement violation";
				anyAfrrUpEngPowerChange = true;
 			}
 			VIOLATIONS_OUTPUT.add("Pool_aFRR_Up_Power_requirement_violation", "", t,  AFRRUpCapacityDeficit[t], 1);
		}
		
		if (AFRRDwnCapacityDeficit[t] > epsilon) {
			if (!anyAfrrDwnEngPowerChange) {
				strDispatchStatusString += ", some AFRR Down requirement violation";
				anyAfrrDwnEngPowerChange = true;
 			}
 			VIOLATIONS_OUTPUT.add("Pool_aFRR_Down_Power_requirement_violation", "", t,  AFRRDwnCapacityDeficit[t], 1);
		}
	}

	violationExcelRange += (nViolations+2).toString();
}
