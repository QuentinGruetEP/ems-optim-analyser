import pandas as pd
import shutil
import os
from datetime import datetime
import subprocess

from optim_analyser.optim.dataframes import dataframe_to_excel
from optim_analyser.errors import ModelReferenceError

def get_column_from_int(n:int) -> str :
    """
    Return the letter of the column corresponding to the n-th column in an Excel file

    :param n: The column number
    :type n: int
    :return: The column letter in the Excel file
    :rtype: str
    """

    alphabet = [chr(i) for i in range(65,91)]
    q = (n-1) // 26
    r = (n-1) % 26
    if q == 0 :
        return alphabet[r]
    else :
        return get_column_from_int(q) + alphabet[r]

def prepare_excel_initial_data(data:dict[str,list[str]], excel_init_path: str) -> None :
    """
    Save the Excel file containing all input and output data at excel_init_path

    :param data: The dictionnary containing the names of the datasheets and their content
    :type data: dict[str,list[str]]
    :param excel_init_path: The saved Excel file path
    :type excel_init_path: str
    :rtype: None
    """

    dataframe_to_excel(data, excel_init_path)
    print(f"Excel file with all input and output data completed.\nPlease check the file at '{excel_init_path}'.\n")

def find_in_out_fields(model_file:str) -> tuple[list[str]]:
    """
    Read the OPL model file, retrieve the input and output datasheet names used

    :param model_file: The OPL model file path (.mod)
    :type model_file: str
    :return: The lists containing the input and output datasheet names
    :rtype: tuple[list[str]]
    """

    input_fields = []
    output_fields = []

    try :
        with open(model_file, 'r') as f:
            mod_lines =  f.readlines()
            l = 0
            line = mod_lines[l]
            
            # Find the input fields names
            while l<len(mod_lines) and not(mod_lines[l].startswith("// Converting this reference to")) : # Could probably replace 2nd condition with tuple t_empty limit
                if line.startswith("tuple t_") :
                    input = line[len("tuple t_"):].split("{")[0].split(" ")[0]
                    input_fields.append(input)
                l += 1
                line = mod_lines[l]
            
            while l<len(mod_lines) and not(mod_lines[l].startswith("tuple t_empty")) :
                l += 1
                line = mod_lines[l]
            
            l += 1
            line = mod_lines[l]
            
            while l<len(mod_lines) :
                if line.startswith("tuple t_") :
                    output = line[len("tuple t_"):].split("{")[0].split(" ")[0]
                    output_fields.append(output)
                if line.startswith("execute"):
                    break
                l += 1
                line = mod_lines[l]

        return input_fields, output_fields
    except FileNotFoundError:
        raise ModelReferenceError(f"Model file not found at {model_file}")

def find_used_columns(model_file:str, input_fields: list[str]) -> dict[str,list[str]]:
    """
    Read the OPL model, retrieve the input columns names in their order of appearance in the model

    :param model_file: The OPL model file path (.mod)
    :type model_file: str
    :param input_fields: The list of the input datasheets used in the OPL model
    :type input_fields: list[str]
    :return: The dictionnary containing the input datasheet names associated with the columns names used in the OPL model, in their order of appearance
    :rtype: dict[str,list[str]]
    """

    used_columns = dict() # Warning : order of the used_columns kept only thanks to adding order in the dictionnary

    with open(model_file, 'r') as f:
        mod_lines =  f.readlines()
        
        # Find the datasheets used in the optimization model
        for l,line in enumerate(mod_lines) :
            if line.startswith("tuple t_") :
                for i in input_fields :
                    if line.startswith("tuple t_" + i + ' {') :

                        sheet_name = str.upper(i)
                        sheet_data = []

                        l += 1
                        line = mod_lines[l]
                        while not("}" in line):
                            # Find the columns of the datasheet used in the optimization model
                            words = line.split(";")                 # Separate the line in two parts : before/after the ';'
                            if "//" not in words[0] :               # Check if the line is not commented
                                words = words[0].split(" ")         # Separate the words of the first part of the line (before the ';')
                                words = list(filter(None, words))   # Remove empty characters resulting from the splits
                                sheet_data.append(words[-1])        # Keep only the name of the column (last word before the ';')
                            l += 1
                            line = mod_lines[l]
                        used_columns[sheet_name] = sheet_data
    return used_columns

def reorder_columns(data:dict[str,pd.DataFrame],
                    used_columns:dict[str,list[str]]) -> dict[str,pd.DataFrame]:
    """
    Clear and reorder the input data to keep only the columns in the OPL model, in their order of appearance

    :param data: The dictionnary containing the names of the input datasheets and their content
    :type data: dict[str,pd.DataFrame]
    :param used_columns: The dictionnary containing the input datasheet names associated with the columns names used in the OPL model, in their order of appearance
    :type used_columns: dict[str,list[str]]
    :return: The dictionnary containing the names of the input datasheets and only the content of the columns used in the OPL model, in their order of appearance
    :rtype: dict[str,pd.DataFrame]
    """

    ordered_data = dict()

    for sheet_name in used_columns.keys():
        sheet_data = data[sheet_name].filter(items=used_columns[sheet_name]) #Reorder and keep only the columns of used_columns
        ordered_data[sheet_name] = sheet_data

    return ordered_data

def prepare_input_data(data:dict[str,pd.DataFrame], mod_file:str, input_fields:list[str]) -> dict[str,pd.DataFrame]:
    """
    Format the data as expected in the OPL model

    :param data: The dictionnary containing the names of the input and output datasheets and their content
    :type data: dict[str,pd.DataFrame]
    :param mod_file: The OPL model file path (.mod)
    :type mod_file: str
    :param input_fields: The list of the input datasheets used in the OPL model
    :type input_fields: list[str]
    :return: The dictionnary containing only the names of the input datasheets and their content as expected in the OPL model
    :rtype: dict[str,pd.DataFrame]
    """
    used_columns = find_used_columns(mod_file, input_fields)
    data_dat = reorder_columns(data, used_columns)
    return data_dat

def prepare_excel_input(data_dat:dict[str,pd.DataFrame], excel_input_path:str) -> None:
    """
    Save the input data Excel file that will be read by the OPL model

    :param data_dat: The dictionnary containing only the names of the input datasheets and their content as expected in the OPL model
    :type data_dat: dict[str,pd.DataFrame]
    :param excel_input_path: The input data Excel file path
    :type excel_input_path: str
    :rtype: None
    """
    dataframe_to_excel(data_dat, excel_input_path)
    print(f"Excel file with formated input data completed.\nPlease check the file at '{excel_input_path}'.\n")

def prepare_excel_output(excel_output_path:str, output_fields:list[str], add_costs:bool=True) -> None:
    """
    Save the empty output Excel file that will be used by the OPL model to store the optimization results

    :param excel_output_path: The empty output Excel file path
    :type excel_output_path: str
    :param output_fields: The list of the output datasheets needed by the OPL model
    :type output_fields: list[str]
    :rtype: None
    """
    data_out = dict()
    for sheet_name in output_fields :
        """
        if sheet_name.endswith('_output'):
            sheet_name = sheet_name[:-len('_output')]
        """
        data_out[sheet_name.upper()] = pd.DataFrame()
    if add_costs:
        data_out['COSTS'] = pd.DataFrame()
    dataframe_to_excel(data_out, excel_output_path)
    print(f"Formated output file completed.\nPlease check the file at '{excel_output_path}'.\n")

def create_cost_extraction_opl_model(model_file:str, opl_cost_extraction_path:str, dat_extension_path:str) -> None:
    """
    Create the additional OPL code to add at the end of the model and update the .dat file in order to get the detailed costs in the output

    :param model_file: The original OPL model file path (.mod)
    :type model_file: str
    :param opl_cost_extraction_path: The OPL model file path (.mod) containing the additional code
    :type opl_cost_extraction_path: str
    :param dat_extension_path: The .dat file path that will be updated with the added code
    :type dat_extension_path: str
    :rtype: None
    """
    costs_variables_names = []
    project_name = opl_cost_extraction_path.split("/")[-1][:-len("_cost_extraction.mod")]

    with open(model_file, 'r') as f:
        mod_lines =  f.readlines()
        
        # Find the objective function terms
        for l,line in enumerate(mod_lines) :
            if line.startswith("minimize") :
                l += 1
                line = mod_lines[l]
                while not(";" in list(line)):
                    words = list(filter(None, line.split()))
                    if words[0] == '+' :
                        words = words[1:]   # Remove the +
                    if "//" not in words[0] and not('sum' in '\t'.join(words)) :     # Check if the line is not commented
                        costs_variables_names.append(words[0])
                    l += 1
                    line = mod_lines[l]
                break
        
        # Find the expression of the objective function terms
        def find_obj_function_term_definition(mod_lines:list[str],
                                              costs_variables_names:list[str]) -> list[str]:
            """
            Return the list of definitions of the objective function terms given in costs_variables_names        

            :param mod_lines: The OPL model (.mod) lines
            :type mod_lines: list[str]
            :param costs_variables_names: The objective function terms which will appear in the optimization output
            :type costs_variables_names: list[str]
            :return: The list of definitions of the objective function terms 
            :rtype: list[str]
            """
            variables_definitions = []
            totalFCRNetworkCostsByStep_defined = False
            for l,line in enumerate(mod_lines):
                if 'TotalFCRNetworkCostsByStep' in line :
                    totalFCRNetworkCostsByStep_defined = True
                if line.startswith("dexpr float "):
                    for costs_variable in costs_variables_names:
                        if (line.startswith("dexpr float " + costs_variable + "=")
                            or line.startswith("dexpr float " + costs_variable + " =")):
                            cost_definition = line.replace("\n", '').replace("\t",'').split("//")[0]
                            while not(";" in list(line)):
                                l += 1
                                line = mod_lines[l]
                                cost_definition += line.replace("\n", '').replace("\t",'').split("//")[0]
                            if cost_definition == "dexpr float DayAheadTotalTradeCost = NotInCFDDaTotalTradCost - InCFDDaTotalTradRevenues;" :
                                cost_definition = ("dexpr float DayAheadTotalTradeCost = "+
                                                   "(sum(h in isHOURLY_STEPS_POS) NotInCFDDaPosition[h] * daElecPrice[h] * effDaStepDurationInHours[h])" +
                                                   " - " +
                                                   "(sum(h in isHOURLY_STEPS_POS) -InCFDDaPosition[h] * inCFDDaPrice[h] * effDaStepDurationInHours[h]);")
                            elif cost_definition == "dexpr float ImbalanceTotalCost = NotInCFDTotalImbalanceCost + InCFDTotalImbalanceCost;" :
                                cost_definition = ("dexpr float ImbalanceTotalCost = "+
                                                   "(sum(imb in isIMBALANCE_STEPS_POS) (NotInCFDNegativeImbalancePower_imb [imb] * negative_imb_price[imb]  - NotInCFDPositiveImbalancePower_imb[imb] * positive_imb_price[imb]) * effImbStepDurationInHours[imb])"+
                                                   " + " +
                                                   "(sum(imb in isIMBALANCE_STEPS_POS) (InCFDNegativeImbalancePower_imb[imb] * inCFDNegImbPrice[imb] - InCFDPositiveImbalancePower_imb[imb] * inCFDPosImbPrice[imb]) *  effImbStepDurationInHours[imb]);")
                            variables_definitions.append(cost_definition)
            return variables_definitions, totalFCRNetworkCostsByStep_defined
        costs_variables_definitions, totalFCRNetworkCostsByStep_defined = find_obj_function_term_definition(mod_lines=mod_lines,
                                                                        costs_variables_names=costs_variables_names)

    def sum_into_time_series(cost:str, time_step:str) -> str:
        """
        Replace costs definitions that are aggregated on some time index with a timed-version of the definition

        :param cost: The cost definition to change
        :type cost: str
        :param time_step: The name of the time index which needs to be removed
        :type time_step: str
        :return: The timed-version cost definition
        :rtype: str
        """
        time_indexes = dict({'t' : 'isDECISION_STEPS',
                             'fcr' : 'isFCR_STEPS_POS',
                             'h' : 'isHOURLY_STEPS_POS',
                             'imb' : 'isIMBALANCE_STEPS_POS',
                             })
        new_cost = cost.replace("sum("+ time_step +" in "+ time_indexes[time_step]+") ",'')
        new_cost = cost.replace("sum("+ time_step +" in "+ time_indexes[time_step]+")",'')
        new_cost = new_cost.replace("sum("+ time_step +" in "+ time_indexes[time_step]+",",'sum(')
        new_cost = new_cost.replace("sum ("+ time_step +" in "+ time_indexes[time_step]+") ",'')
        new_cost = new_cost.replace("sum ("+ time_step +" in "+ time_indexes[time_step]+",",'sum(')
        new_cost = new_cost.replace(", "+ time_step +" in "+ time_indexes[time_step]+")",')')
        return new_cost
    
    new_costs_definitions = []
    # Definition of int assetStepOtherStep_int[isDECISION_STEPS] and int StepMultiplicationOther[t in isDECISION_STEPS]
    step_conversion = ''
    conversion_imb = False
    conversion_h = False
    conversion_fcr = False

    for cost_definition in costs_variables_definitions :
        # TotalFCRNetworkCostsByStep is already defined step by step no need to recompute for some models
        if not(cost_definition.startswith("dexpr float TotalFCRNetworkCosts") and totalFCRNetworkCostsByStep_defined) :
            # Computation of conversion otherStep -> assetStep
            step_recalibration = ''
                                        
            new_cost = cost_definition.replace('dexpr ', '')
            new_cost_words = new_cost.split(" ")
            if new_cost_words[1] in costs_variables_names :
                    raw_cost_name = new_cost_words[1]
            if "[imb]" in new_cost :
                conversion_imb = True
                new_cost_words[1] += 'ByStepImb[imb in isIMBALANCE_STEPS_POS]'
                step_recalibration = ("\nfloat "+raw_cost_name+"ByStep[t in isDECISION_STEPS];\n"+
                                        "execute{\n"+
                                        "\tfor (var osl in OPERATION_STEPS_LINK){\n"+
                                        "\t\tosl.imbalance_step > 0 ?\n"+
                                        "\t\t"+raw_cost_name+"ByStep[osl.asset_step] = "+raw_cost_name+"ByStepImb[osl.imbalance_step] / StepMultiplicationImb[osl.asset_step]\n"+
                                        "\t\t:"+raw_cost_name+"ByStep[osl.asset_step] = 0;\n" +
                                        "\t}\n" +
                                        "}")
                new_cost = ' '.join(new_cost_words)
                new_cost = sum_into_time_series(new_cost,'imb')
            elif "[h]" in new_cost :
                conversion_h = True
                new_cost_words[1] += 'ByStepH[h in isHOURLY_STEPS_POS]'
                step_recalibration = ("\nfloat "+raw_cost_name+"ByStep[t in isDECISION_STEPS];\n"+
                                        "execute{\n"+
                                        "\tfor (var osl in OPERATION_STEPS_LINK){\n"+
                                        "\t\tosl.day_ahead_step > 0 ?\n"+
                                        "\t\t"+raw_cost_name+"ByStep[osl.asset_step] = "+raw_cost_name+"ByStepH[osl.day_ahead_step] / StepMultiplicationH[osl.asset_step]\n"+
                                        "\t\t:"+raw_cost_name+"ByStep[osl.asset_step] = 0;\n" +
                                        "\t}\n" +
                                        "}")
                new_cost = ' '.join(new_cost_words)
                new_cost = sum_into_time_series(new_cost,'h')
            elif "[fcr]" in new_cost :
                conversion_fcr = True
                new_cost_words[1] += 'ByStepFCR[fcr in isFCR_STEPS_POS]'
                step_recalibration = ("\nfloat "+raw_cost_name+"ByStep[t in isDECISION_STEPS];\n"+
                                        "execute{\n"+
                                        "\tfor (var osl in OPERATION_STEPS_LINK){\n"+
                                        "\t\tosl.fcr_step > 0 ?\n"+
                                        "\t\t"+raw_cost_name+"ByStep[osl.asset_step] = "+raw_cost_name+"ByStepFCR[osl.fcr_step] / StepMultiplicationFCR[osl.asset_step]\n"+
                                        "\t\t:"+raw_cost_name+"ByStep[osl.asset_step] = 0;\n" +
                                        "\t}\n" +
                                        "}")
                new_cost = ' '.join(new_cost_words)
                new_cost = sum_into_time_series(new_cost,'fcr')
            else :
                new_cost_words[1] += 'ByStep[t in isDECISION_STEPS]'
                new_cost = ' '.join(new_cost_words)
                new_cost = sum_into_time_series(new_cost,'t')
            new_costs_definitions.append(new_cost + step_recalibration)
    if conversion_imb:
        step_conversion += ("int assetStepImbalanceStep_int[isDECISION_STEPS] = [osl.asset_step : intValue(osl.imbalance_step) | osl in OPERATION_STEPS_LINK];\n" +
                            "int StepMultiplicationImb[t in isDECISION_STEPS] = count(assetStepImbalanceStep_int, assetStepImbalanceStep_int[t]);\n")
    if conversion_h:
        step_conversion += ("int assetStepHourlyStep_int[isDECISION_STEPS] = [osl.asset_step : intValue(osl.day_ahead_step) | osl in OPERATION_STEPS_LINK];\n" +
                            "int StepMultiplicationH[t in isDECISION_STEPS] = count(assetStepHourlyStep_int, assetStepHourlyStep_int[t]);\n")
    if conversion_fcr:
        step_conversion += ("int assetStepFCRStep_int[isDECISION_STEPS] = [osl.asset_step : intValue(osl.fcr_step) | osl in OPERATION_STEPS_LINK];\n" +
                            "int StepMultiplicationFCR[t in isDECISION_STEPS] = count(assetStepFCRStep_int, assetStepFCRStep_int[t]);\n")

    new_costs_definitions = [step_conversion] + new_costs_definitions

    costs_variables = dict({
        'step_id' : 't',
        'TotalTradeNetworkCostsByStep' : 'network_total_trade_costs',
        'TotalFCRNetworkCostsByStep' : 'network_total_fcr_costs',
        'ElectricityTotalNetCostsByStep' : 'contract_total_net_costs',
        'GenTotalNonLinVarCostsByStep' : 'non_lin_gen_var_costs',
        'TotalGenNonLinVarCostsByStep' : 'non_lin_gen_var_costs',
        'DispGenTotalStartupCostsByStep' : 'disp_gen_start_up_costs',
        'DispLoadTotalStartupCostsByStep' : 'disp_load_start_up_costs',
        'GenTotalLinearVarCostsByStep' : 'lin_gen_var_costs',
        'ConvTotalLinearCostsByStep' : 'conv_var_cost',
        'InterGenTotalCurtCostsByStep' : 'inter_gen_var_cost',
        'StorChargeDischargeCostByStep' : 'storage_use_penalties',
        'StorPowerChangeTotalCostByStep' : 'storage_power_change_penalties',
        'ImbalanceTotalCostByStep' : 'imbalance_total_net_costs',
        'DayAheadTotalTradeCostByStep' : 'day_ahead_total_trade_costs',
        'TotalDayAheadFCRCostByStep' : 'day_ahead_total_fcr_costs',
        'AggregatorCostByStep' : 'aggregator_costs',
        'FCRPowerEngDeficitTotalCostByStep' : 'fcr_power_eng_deficit_total_costs',
        'H2EnergyTotalCostsByStep' : 'h2_energy_total_costs',
        'ElectricityTotalTariffCostsByStep' : 'electricity_total_tariff_costs',
        'ElectricityTotalNetRevenueByStep' : 'electricity_total_net_revenue',
        'ThermalGenTotalVarCostsByStep' : 'thermal_gen_total_var_costs',
        'ThermalGenTotalStartupCostsByStep' : 'thermal_gen_total_startup_costs',
        'InterProdTotalVarCostsByStep' : 'inter_prod_total_var_costs',
        'InterProdTotalCurtCostsByStep' : 'inter_prod_total_curt_costs'
    })

    costs_output_header = '{t_empty} COSTS_HEADER = {<"step_id"'
    for cost_mod_name in costs_variables_names :
        costs_output_header += ', "'+costs_variables[cost_mod_name+"ByStep"]+'"'
    for i in range(19 - len(costs_variables_names)) :
        costs_output_header += ', ""'
    costs_output_header += "> | i in 1..1};"

    tuple_costs_output = "/* COSTS OUTPUT DATA */\ntuple t_costs {\n\tkey string step_id;\n"
    for cost_mod_name in costs_variables_names :
        tuple_costs_output += '\tfloat '+costs_variables[cost_mod_name+"ByStep"]+";\n"
    tuple_costs_output += "}\n\n"
    tuple_costs_output += "{t_costs} COSTS = {<t"
    for cost_mod_name in costs_variables_names :
        tuple_costs_output += ',\n\t'+cost_mod_name+"ByStep[t]"
    tuple_costs_output += ">\n\t| t in isDECISION_STEPS};"

    # Create the new .mod file extension and write the new instructions in it
    with open(opl_cost_extraction_path, 'w') as output:
        output.write("\n\n\n/* COSTS EXPRESSED AS TIME SERIES */\n\n")
        for line in new_costs_definitions:
            output.write(line + "\n\n")
        for line in costs_output_header:
            output.write(line)
        output.write("\n\n")
        for line in tuple_costs_output:
            output.write(line)
    
    cost_excel_range = get_column_from_int(len(costs_variables_names)+1) + '10001'
    cost_dat_extension = '// costs output\n'
    cost_dat_extension += 'EMPTY_OUTPUT to SheetWrite(outputSheet,"'+"'COSTS'"+'!A1:T10001");\n'
    cost_dat_extension += 'COSTS_HEADER to SheetWrite(outputSheet,"'+"'COSTS'"+'!A1:T1");\n'
    cost_dat_extension += 'COSTS to SheetWrite(outputSheet, "'+"'COSTS'"+'!A2:'+ cost_excel_range+'");\n'
    with open(dat_extension_path,'w') as dat_file:
        dat_file.write(cost_dat_extension)
    
    print(f"cost_extension.mod file created and .dat updated.\nPlease check the file at '{opl_cost_extraction_path}'.\n")


def create_dat_file(data_dat:dict[str,pd.DataFrame], dat_path:str, output_fields_dat:str,
                    excel_input_path:str, excel_output_path:str,
                    add_costs:bool=True, dat_costs_extension_path:str=None) -> None:
    """
    Create and save the .dat file linked to the input data and empty output Excel files

    :param data_dat: The dictionnary containing only the names of the input datasheets and their content as expected in the OPL model
    :type data_dat: dict[str,pd.DataFrame]
    :param dat_path: The .dat file path
    :type dat_path: str
    :param output_fields_dat: The output fields required in the OPL model that need to appear in the .dat
    :type output_fields_dat: str
    :param excel_input_path: The input data Excel file path
    :type excel_input_path: str
    :param excel_output_path: The empty output Excel file path
    :type excel_output_path: str
    :param add_costs: If True, the detailed optimization costs will be added in the .dat, defaults to True
    :type add_costs: bool, optional
    :param dat_costs_extension_path: The path to the file containing the additional code to add the detailed costs in the optimization output, defaults to None
    :type dat_costs_extension_path: str, optional
    :rtype: None
    """
    
    new_dat = []

    # Header and input sheet declaration
    new_dat.append("/*********************************************\n")
    new_dat.append(" * Auto generated\n")
    datetime_str = (datetime.now()).strftime("%d/%m/%Y %H:%M:%S") # dd/mm/YY H:M:S
    new_dat.append(" * Creation Date: " + datetime_str + "\n")
    new_dat.append(" *********************************************/\n")
    new_dat.append('\n')
    
    # Input sheet declaration
    model_folder = os.path.split(dat_path)[0]
    excel_input_relative_path = os.path.relpath(os.path.join(model_folder, "Data", os.path.basename(excel_input_path)), model_folder) #os.path.join(model_folder, "Data", os.path.basename(excel_input_path))
    new_dat.append('SheetConnection inputSheet("' +
                    ("/").join(excel_input_relative_path.split('\\')) + '");\n')
    new_dat.append('\n')

    # Input reading instructions
    for sheet_name, sheet_data in data_dat.items() :
        (n_rows, n_columns) = sheet_data.shape
        last_cell = get_column_from_int(n_columns) + str(n_rows+1)
        new_dat.append(sheet_name + ' from SheetRead(inputSheet, "' + "'" + sheet_name
                + "'!A2:" +  last_cell + '");\n')
    new_dat.append("\n")

    # Output sheet declaration
    excel_output_relative_path = os.path.relpath(os.path.join(model_folder, "Data", os.path.basename(excel_output_path)), model_folder) #os.path.join(model_folder, "Data", os.path.basename(excel_output_path))
    new_dat.append('SheetConnection outputSheet("' +
                    ("/").join(excel_output_relative_path.split('\\')) + '");\n')
    new_dat.append("\n")

    # Output writing instructions
    excel_range = dict({'operation_output' : '"'+ "'OPERATION_OUTPUT'" + '!A2:B10001"',
                        'operation_steps_output' : 'operationStepsExcelRange',
                        'assets_output' : 'assetsExcelRange',
                        'asset_steps_output' : 'assetStepsExcelRange',
                        'market_bids_output': 'marketBidsExcelRange',
                        'violations_output': 'violationExcelRange',
                        'asset_steps_cost' : 'assetStepsCostExcelRange',
                        'step_costs' : 'stepCostsExcelRange'
                        })
    output_header = dict({'operation_output' : 'OPERATION_HEADER',
                        'operation_steps_output' : 'OPERATION_STEPS_HEADER',
                        'assets_output' : 'ASSETS_HEADER',
                        'asset_steps_output' : 'ASSET_STEPS_HEADER',
                        'market_bids_output': 'MARKET_BIDS_OUTPUT_HEADER',
                        'violations_output' : 'VIOLATIONS_OUTPUT_HEADER',
                        'asset_steps_cost' : 'ASSET_STEPS_COST_HEADER',
                        'step_costs' : 'STEP_COSTS_HEADER',
                        'costs_output' : 'COSTS_OUTPUT_HEADER',
                        })
    output_data = dict({'operation_output' : 'OPERATION_OUTPUT',
                        'operation_steps_output' : 'OPERATION_STEPS_OUTPUT',
                        'assets_output' : 'ASSETS_OUTPUT',
                        'asset_steps_output' : 'ASSET_STEPS_OUTPUT',
                        'market_bids_output': 'MARKET_BIDS_OUTPUT',
                        'violations_output' : 'VIOLATIONS_OUTPUT',
                        'asset_steps_cost' : 'ASSET_STEPS_COST',
                        'step_costs' : 'STEP_COSTS',
                        'costs_output' : 'COSTS_OUTPUT',
                        })

    for output_field in output_fields_dat :
        # Temporary fix for asset_step_cost/asset_steps_cost naming issue between old and new models
        if output_field == 'asset_step_cost' and output_field not in excel_range.keys() :
            output_field = 'asset_steps_cost'

        field = output_field
        if field.endswith("_output") :
            field = field[:-len("_output")]
        new_dat.append("// " + (" x ").join(field.split("_")) + " output\n")
        sheet_name = field.upper()

        new_dat.append('EMPTY_OUTPUT to SheetWrite(outputSheet,"' + output_field.upper() + '!A1:T10001");\n')
        new_dat.append(output_header[output_field] + ' to SheetWrite(outputSheet,"' + output_field.upper() + '!A1:T1");\n')
        new_dat.append(output_data[output_field] + ' to SheetWrite(outputSheet,' + excel_range[output_field] + '); // Check the excel range\n')

    # Create the new .dat file and write the new instructions in it
    with open(dat_path, 'w') as output:
        for line in new_dat:
            output.write(line)
        if add_costs :
            with open(dat_costs_extension_path,'r') as f:
                dat_extension_lines =  f.readlines()
                for line in dat_extension_lines :
                    output.write(line)
    
    print(f".dat file created.\nPlease check the file at '{dat_path}'.\n")

def copy_model(mod_file:str, copied_model_path:str, add_costs:bool=True, mod_costs_extension_path:str=None) -> None:
    """
    Create copy of the original model used in IBM cloud with additional code to add the detailed costs in the optimization output

    :param mod_file: The original OPL model file path (.mod)
    :type mod_file: str
    :param copied_model_path: The copied OPL model file path (.mod)
    :type copied_model_path: str
    :param add_costs: If True, the detailed optimization costs will be added in the copied OPL model file, defaults to True
    :type add_costs: bool, optional
    :param mod_costs_extension_path: The path to the OPL file containing the additional code to add the detailed costs in the optimization output, defaults to None
    :type mod_costs_extension_path: str, optional
    :rtype: None
    """
    to_copy = [mod_file]
    if add_costs:
        to_copy.append(mod_costs_extension_path)
    with open(copied_model_path,'wb') as fdst:
        for f in to_copy:
            with open(f,'rb') as fsrc:
                shutil.copyfileobj(fsrc=fsrc, fdst=fdst)


def prepare_optimization(data:dict[str,pd.DataFrame], mod_file:str, copied_model_path:str,
                         excel_input_path:str, dat_path:str, excel_output_path:str,
                         add_costs=True, mod_costs_extension_path:str=None, dat_costs_extension_path:str=None) -> None :
    """
    Create and save all files needed to run the OPL model

    :param data: The dictionnary containing the names of the input and output datasheets and their content
    :type data: dict[str,pd.DataFrame]
    :param mod_file: The original OPL model file path (.mod)
    :type mod_file: str
    :param copied_model_path: The copied OPL model file path (.mod)
    :type copied_model_path: str
    :param excel_input_path: The input data Excel file path
    :type excel_input_path: str
    :param dat_path: The .dat file path
    :type dat_path: str
    :param excel_output_path: The output Excel file path
    :type excel_output_path: str
    :param add_costs: If True, the detailed optimization costs will be added in the copied OPL model file, defaults to True
    :type add_costs: bool, optional
    :param mod_costs_extension_path: The path to the OPL file containing the additional code to add the detailed costs in the optimization output, defaults to None
    :type mod_costs_extension_path: str, optional
    :param dat_costs_extension_path: The path to the file containing the additional code to add the detailed costs in the optimization output, defaults to None
    :type dat_costs_extension_path: str, optional
    :rtype: None
    """
    print(mod_file)
    input_fields, output_fields = find_in_out_fields(mod_file)
    data_dat = prepare_input_data(data, mod_file, input_fields)
    prepare_excel_input(data_dat, excel_input_path)
    prepare_excel_output(excel_output_path, output_fields, add_costs=add_costs)
    if add_costs :
        create_cost_extraction_opl_model(mod_file, mod_costs_extension_path, dat_costs_extension_path)
    copy_model(mod_file, copied_model_path, add_costs=add_costs, mod_costs_extension_path=mod_costs_extension_path)
    create_dat_file(data_dat, dat_path, output_fields, excel_input_path, excel_output_path, add_costs=add_costs, dat_costs_extension_path=dat_costs_extension_path)

def run_optimization(model_path:str, dat_path:str) -> None :
    """
    Run the optimization configuration given by the OPL model file and the .dat file

    :param model_path: The OPL model file (.mod) path
    :type model_path: str
    :param dat_path: The .dat file path
    :type dat_path: str
    :rtype: None
    """

    command = f'oplrun "{model_path}" "{dat_path}"' 
    print(command + "\n")
    p = subprocess.Popen(command, shell=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT)
    
    for line in p.stdout :
        print(line.decode(errors='replace'), end="")
    
    p.wait()

    p.terminate()

    
    print('/////////////////////////')
    import time
    time.sleep(60)
    