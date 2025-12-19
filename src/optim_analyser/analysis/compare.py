import pandas as pd
import numpy as np
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from datetime import datetime,timedelta

from optim_analyser.analysis import subplot
from optim_analyser.analysis.colors import color_map_costs, color_map_default, color_blind_map
from optim_analyser.analysis.display import get_df

def combine_plotly_figs_to_html(plotly_figs:list[go.Figure], html_fname:str, include_plotlyjs='cdn', 
                                separator:str=None, auto_open:bool=False) -> None:
    """
    Create .html file with all the plotly figures merged

    :param plotly_figs: The list of figures to merge
    :type plotly_figs: list[go.Figure]
    :param html_fname: The .html file path to save the result
    :type html_fname: str
    :param include_plotlyjs: defaults to 'cdn'
    :type include_plotlyjs: str, optional
    :param separator: Separator written between each figure in the .html, defaults to None
    :type separator: str, optional
    :param auto_open: If True, the .html file will be automatically opened, defaults to False
    :type auto_open: bool, optional
    """

    with open(html_fname, 'w') as f:
        f.write(plotly_figs[0].to_html(include_plotlyjs=include_plotlyjs))
        for fig in plotly_figs[1:]:
            if separator:
                f.write(separator)
            f.write(fig.to_html(full_html=False, include_plotlyjs=False))

    if auto_open:
        import pathlib, webbrowser
        uri = pathlib.Path(html_fname).absolute().as_uri()
        webbrowser.open(uri)


def input_comparison(data_in_init:dict[str,pd.DataFrame],
                     data_in_forced:dict[str,pd.DataFrame]) -> str :
    """
    Return the string describing the changes in the optimization inputs

    :param data_in_init: The initial input data
    :type data_in_init: dict[str,pd.DataFrame]
    :param data_in_forced: The forced input data
    :type data_in_forced: dict[str,pd.DataFrame]
    :return: The description of what has been changed in the optimization inputs
    :rtype: str
    """

    data_in_changed = dict()
    for sheet_name in data_in_init.keys():
        data_in_changed[sheet_name] = data_in_init[sheet_name].compare(data_in_forced[sheet_name], result_names=('init', 'forced'))
    
    fields = []
    field_init_values = []
    field_forced_values = []
    for sheet_name in data_in_changed.keys():
        for (column, optim) in data_in_changed[sheet_name].columns:
            fields.append(column)
            if optim=='init':
                field_init_values.append(list(data_in_changed[sheet_name][(column,'init')]))
            elif optim=='forced':
                field_forced_values.append(list(data_in_changed[sheet_name][(column,'forced')]))
    fields = np.unique(fields)

    if len(fields)==0:
        text = "No changes in inputs"
    else :
        text = "Changes in inputs : "
        for i,field in enumerate(fields):
            text += field + " values " + str(field_init_values[i]) + " -> " + str(field_forced_values[i])
            if i < len(fields)-1:
                text += ", "
    return text

def obj_func_comparison(optim_objective_value_init:float, optim_objective_value_forced:float, epgap:float=1e-6):
    """
    Return the string describing the objective function values

    :param optim_objective_value_init: The initial value of the objective function
    :type optim_objective_value_init: _type_
    :param optim_objective_value_forced: The forced value of the objective function
    :type optim_objective_value_forced: _type_
    :param epgap: The gap tolerance (the optimization is stopped when a feasible solution proved to be within (epgap*100)% of optimal), defaults to 1e-6
    :type epgap: float, optional
    :return: The description of the objective function values
    :rtype: _type_
    """
    if optim_objective_value_init == optim_objective_value_forced :
        text = "Equivalent solutions, the optimizer has arbitrarily chosen the initial optimization solution."
    elif optim_objective_value_init*(1-epgap) <= optim_objective_value_forced <= optim_objective_value_init*(1+epgap) :
        text = "Forced optimization solution is in the precision range of the initial optimization."
    elif optim_objective_value_init*(1-epgap) > optim_objective_value_forced :
        text = "Forced optimization solution is better than the initial optimization. Not normal if same inputs."
    elif optim_objective_value_init*(1+epgap) < optim_objective_value_forced :
        text = "Forced optimization is valid but the initial optimization should cost less."
    return text


def compare_from_input_output_data(data_in_init:dict[str,pd.DataFrame],
                                    data_out_init:dict[str,pd.DataFrame],
                                    data_in_forced:dict[str,pd.DataFrame],
                                    data_out_forced:dict[str,pd.DataFrame],
                                    html_path:str,
                                    subplots_param:pd.DataFrame,
                                    add_costs:bool=True,
                                    color_blind:bool=False) -> None :
    """
    Create the .html file with visuals to help comparison of the two given optimizations (ran on the same model and with the same asset_step number)

    :param data_in_init: The initial input data 
    :type data_in_init: dict[str,pd.DataFrame]
    :param data_out_init: The initial output data
    :type data_out_init: dict[str,pd.DataFrame]
    :param data_in_forced: The forced input data
    :type data_in_forced: dict[str,pd.DataFrame]
    :param data_out_forced: The forced output data
    :type data_out_forced: dict[str,pd.DataFrame]
    :param html_path: The .html file path in which the visuals will be saved
    :type html_path: str
    :param subplots_param: The specific plotting parameters
    :type subplots_param: pd.DataFrame
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to True
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    :rtype: None
    """
    
    data_init = data_in_init | data_out_init
    data_forced = data_in_forced | data_out_forced

    input_comparison_text = input_comparison(data_in_init=data_in_init, data_in_forced=data_in_forced)

    optim_objective_value_init = data_init['OPERATION_OUTPUT'].set_index('param_id').transpose()['optimiser_objective_value']['param_val']
    optim_objective_value_forced = data_forced['OPERATION_OUTPUT'].set_index('param_id').transpose()['optimiser_objective_value']['param_val']

    obj_func_comparison_text = obj_func_comparison(optim_objective_value_init, optim_objective_value_forced)

    # Comparison will take initial solution as a base
    # The differences expressed correspond to what has to be added to this initial base in order to get the forced solution
    # value_diff = value_forced - value_init

    tot_costs_forced = dict()
    
    for cost_name in data_forced['COSTS'].columns :
        if not(cost_name=='step_id') :
            tot_costs_forced[cost_name] = data_forced['COSTS'][cost_name].sum()
    
    tot_costs_diff = tot_costs_forced.copy()
    tot_costs_init = dict()
    
    for cost_name in data_init['COSTS'].columns :
        if not(cost_name=='step_id') :
            tot_costs_init[cost_name] = data_init['COSTS'][cost_name].sum()
            if cost_name in tot_costs_diff.keys() :
                tot_costs_diff[cost_name] -= tot_costs_init[cost_name]

    tot_costs_df = pd.DataFrame({
        "cost_name" : tot_costs_init.keys(),
        "tot_costs_init" : tot_costs_init.values(),
        "tot_costs_forced" : tot_costs_forced.values(),
        "tot_costs_diff" : tot_costs_diff.values()
    }).set_index("cost_name")

    obj_func_df = pd.DataFrame({
        "optimiser_objective_value" : [data_init['OPERATION_OUTPUT'].set_index('param_id').transpose()['optimiser_objective_value']['param_val'],
                                       data_forced['OPERATION_OUTPUT'].set_index('param_id').transpose()['optimiser_objective_value']['param_val'],
                                       data_forced['OPERATION_OUTPUT'].set_index('param_id').transpose()['optimiser_objective_value']['param_val']-data_init['OPERATION_OUTPUT'].set_index('param_id').transpose()['optimiser_objective_value']['param_val']],
        "tot_costs" : [tot_costs_df['tot_costs_init'].sum(),
                       tot_costs_df['tot_costs_forced'].sum(),
                       tot_costs_df['tot_costs_forced'].sum()-tot_costs_df['tot_costs_init'].sum()]
    }, index=['initial', 'forced', 'diff'])
    obj_func_df['violation_costs'] = [obj_func_df.loc['initial',"optimiser_objective_value"]-obj_func_df.loc['initial',"tot_costs"],
                                      obj_func_df.loc['forced',"optimiser_objective_value"]-obj_func_df.loc['forced',"tot_costs"],
                                      obj_func_df.loc['diff',"optimiser_objective_value"]-obj_func_df.loc['diff',"tot_costs"]
                                      ]

    if "violation_cost" in data_init['VIOLATIONS_OUTPUT'].columns :
        # Read and merge on violation type the violation costs for the initial solution
        for violation_type in np.unique(data_init['VIOLATIONS_OUTPUT']['violation_type'].values):
            tot_costs_df.loc[violation_type, 'tot_costs_init'] = data_init['VIOLATIONS_OUTPUT'].loc[data_init['VIOLATIONS_OUTPUT']['violation_type']==violation_type,'violation_cost'].sum()
        # Read and merge on violation type the violation costs for the forced solution
        for violation_type in np.unique(data_forced['VIOLATIONS_OUTPUT']['violation_type'].values):
            tot_costs_df.loc[violation_type, 'tot_costs_forced'] = data_forced['VIOLATIONS_OUTPUT'].loc[data_forced['VIOLATIONS_OUTPUT']['violation_type']==violation_type,'violation_cost'].sum()
        tot_costs_df = tot_costs_df.fillna(0)
        for violation_type in np.unique(list(data_forced['VIOLATIONS_OUTPUT']['violation_type'].values) + list(data_init['VIOLATIONS_OUTPUT']['violation_type'].values)):
            tot_costs_df.loc[violation_type, 'tot_costs_diff'] = tot_costs_df.loc[violation_type, 'tot_costs_forced'] - tot_costs_df.loc[violation_type, 'tot_costs_init']
           

    tot_costs_df.loc['violation_costs'] = [obj_func_df.loc['initial', 'violation_costs'],
                                           obj_func_df.loc['forced', 'violation_costs'],
                                           obj_func_df.loc['diff', 'violation_costs']]
    for cost_name in tot_costs_df.index :
        if tot_costs_df.loc[cost_name,'tot_costs_init'] !=0 :
            tot_costs_df.loc[cost_name,'costs_diff-costs_init_ratio'] = tot_costs_df.loc[cost_name,'tot_costs_diff']/tot_costs_df.loc[cost_name,'tot_costs_init']
        else :
            tot_costs_df.loc[cost_name,'costs_diff-costs_init_ratio'] = 0
    tot_costs_df = tot_costs_df.sort_values(by="tot_costs_diff", key=abs, ascending=False)

    # Get initial optimization dataframes to plot as a base
    (operation_df_init, operation_steps_df_init, assets_df_init, storage_assets_df_init, intermittent_assets_df_init, site_assets_df_init,
    maingrid_serie_init, asset_steps_power_df_init, intermittent_steps_df_init,
    prices_df_init, engagement_df_init,
    asset_steps_soc_df_init, asset_steps_availability_df_init,
    operation_steps_output_df_init) = get_df(data_in_init, data_out_init, subplots_param)

    # Get forced optimization dataframes to compute the differences and plot
    (_, _, _, _, _, _,
    maingrid_serie_diff, asset_steps_power_df_forced, intermittent_steps_df_diff,
    _, engagement_df_forced,
    asset_steps_soc_df_diff, asset_steps_availability_df_diff,
    operation_steps_output_df_diff) = get_df(data_in_forced, data_out_forced, subplots_param)
    
    maingrid_serie_diff -= maingrid_serie_init
    asset_steps_power_df_diff = asset_steps_power_df_forced -asset_steps_power_df_init
    intermittent_steps_df_diff -= intermittent_steps_df_init
    engagement_df_diff = engagement_df_forced - engagement_df_init
    #asset_steps_soc_df_diff -= asset_steps_soc_df_init
    asset_steps_availability_df_diff -= asset_steps_availability_df_init
    operation_steps_output_df_diff -= operation_steps_output_df_init


    
    # PLOT OPTIMIZATION COMPARISON TOOLS ------------------------------------------------------------
    # Load the step numbers/durations
    optimisation_interval_start = operation_df_init['optimisation_interval_start']['param_val']
    if type(optimisation_interval_start) != datetime :
        optimisation_interval_start = datetime.strptime(optimisation_interval_start[:-4], '%Y-%m-%d %H:%M:%S')

    optimisation_request_time = operation_df_init['optimisation_request_time']['param_val']
    if type(optimisation_request_time) != datetime :
        optimisation_request_time = datetime.strptime(optimisation_request_time[:-4], '%Y-%m-%d %H:%M:%S')

    optimisation_step_number = int(operation_df_init['optimisation_step_number']['param_val'])

    asset_step_duration = int(operation_df_init['asset_step_duration']['param_val'])


    dates = [optimisation_interval_start + timedelta(minutes=asset_step_duration)*i for i in range(optimisation_step_number)]
    
    # ENERGY VECTORS    
    energy_vectors_number = 1 # Elec by default
    energy_vectors = ['ELECTRICITY']
    # if any(["H2" in assets_df.at[asset_id, "energies_in"] for asset_id in assets_df.index]) or any(["H2" in assets_df.at[asset_id, "energies_out"] for asset_id in assets_df.index]):
    if any(["H2" in asset_id for asset_id in assets_df_init.index]) :
        energy_vectors_number += 1
        energy_vectors.append('H2')
    # if any(["GAS" in assets_df.at[asset_id, "energies_in"] for asset_id in assets_df.index]) or any(["GAS" in assets_df.at[asset_id, "energies_out"] for asset_id in assets_df.index]):
    if any(["GAS" in asset_id in asset_id for asset_id in assets_df_init.index]) :
        energy_vectors_number += 1
        energy_vectors.append('GAS')
    # if any(["HEAT" in assets_df.at[asset_id, "energies_in"] for asset_id in assets_df.index]) or any(["HEAT" in assets_df.at[asset_id, "energies_out"] for asset_id in assets_df.index]):
    if any(["HEAT" in asset_id or asset_id in ["Buffer_850m3", "Verberne_America_HeatBuffer", "Verberne_America_Heat_Need"] for asset_id in assets_df_init.index]) :
        energy_vectors_number += 1
        energy_vectors.append('HEAT')

    # AVAILABILITY --------------------------------------------------------------------------
    all_available = ((asset_steps_availability_df_init - 1).sum(axis=1).sum(axis=0) == 0.0
                     and asset_steps_availability_df_diff.sum(axis=1).sum(axis=0) == 0.0)

    # PLOT ----------------------------------------------------------------------------------
    
    if color_blind :
        color_map = color_blind_map
    else :
        color_map = color_map_default
    color_map_greyscale = dict()
    
    subplots_comp = [
        # Optimization objective values and violation costs
        True,
        # Costs repartition
        add_costs,
        # Table of initial optimization violations if not empty
        not data_out_init['VIOLATIONS_OUTPUT'].empty,
        # Table of forced optimization violations if not empty
        not data_out_forced['VIOLATIONS_OUTPUT'].empty
    ]
    subplots_classic = [
        # Power Target
        [True]*energy_vectors_number,
        # Energy market prices & Market engagements
        False, #subplots_param['day_ahead_price'] or subplots_param['engagement'],
        # Imbalances
        False, #subplots_param['imbalance'],
        # Congestions
        #subplots_param['congestion']
        [subplots_param['congestion']]*site_assets_df_init.shape[0],
        # Target SOC & Energy market prices
        not storage_assets_df_init.empty,
        # Assets availability if there is at least one asset that is unavailable
        not all_available,
    ]

    # Count the number of displayed subplots, need to count the list of bool for the congestions separately
    subplots_congestions_number = subplots_classic[3].count(True)
    subplots_classic_number = subplots_classic.count(True) + energy_vectors_number + subplots_congestions_number
    subplots_comp_number = subplots_comp.count(True)

    def flatten_list(lst:list):
        flat = []
        for elt in lst :
            if type(elt) != list :
                flat.append(elt)
            else :
                flat += flatten_list(elt)
        return flat
    subplots_classic_flat = flatten_list(subplots_classic)
    congestions_titles = [site_name + ' congestions' for site_name in site_assets_df_init['asset_id'].values]
    power_target_titles = ['Power Target '+ energy_vector + ' [kW]' for energy_vector in energy_vectors]
    all_subplot_classic_titles_flat = flatten_list([power_target_titles,
                                            'Energy market prices & Market engagements',
                                            'Imbalances',
                                            congestions_titles,
                                            'Target SOC & Energy market prices',
                                            'Assets availability',
                                            ])
    all_subplot_comp_titles_flat = ['Optimization objective values and violation costs',
                                    'Optimization costs repartition',
                                    'Initial optimization violations',
                                    'Forced optimization violations']
    subplot_classic_titles=[title for index,title in enumerate(all_subplot_classic_titles_flat)
                                            if subplots_classic_flat[index]]
    subplot_comp_titles=[title for index,title in enumerate(all_subplot_comp_titles_flat)
                                            if subplots_comp[index]]

    
    all_specs_classic_flat = [[{"secondary_y": True}]]*len(all_subplot_classic_titles_flat)
    all_specs_comp_flat = [[{"type": "table"}]] + [[{"secondary_y": True}]] + [[{"type": "table"}]]*2
    specs_classic = [title for index,title in enumerate(all_specs_classic_flat)
                                    if subplots_classic_flat[index]]
    specs_comp = [title for index,title in enumerate(all_specs_comp_flat)
                                    if subplots_comp[index]]

    # Consumer convention by default in Everest -> Consumption > 0, Production < 0
    # 1 for consumer, -1 for producer
    convention = subplots_param['convention']

    # Currency unit symbol, default is CU
    currency_unit = subplots_param['currency_unit']

    # Create a subplot layout
    fig_classic = make_subplots(rows=subplots_classic_number,cols=1,
                                shared_xaxes=True,
                                subplot_titles=subplot_classic_titles,
                                specs=specs_classic,
                                vertical_spacing = 0.25/subplots_classic_number,
                                )
    fig_comp = make_subplots(rows=subplots_comp_number,cols=1,
                             row_heights=[0.2]+[(1-0.2-0.15/subplots_comp_number)/(subplots_comp_number-1)]*(subplots_comp_number-1),
                             shared_xaxes=True,
                             subplot_titles=subplot_comp_titles,
                             specs=specs_comp,
                             vertical_spacing = 0.15/subplots_comp_number,
                             )


    # Call the plot functions
    power_target_plot_done = False
    congestions_plot_done = False
    for index, title in enumerate(subplot_classic_titles):
        row = index + 1
        if title.startswith('Power Target') and not power_target_plot_done:
            power_target_plot_done = True
            """
            subplot.plot_power_target_by_energy_vector([row+i for i in range(energy_vectors_number)],
                                                            fig_classic, color_map_greyscale, convention,
                                                            dates,
                                                            assets_df_init, asset_steps_power_df_init, intermittent_assets_df_init, intermittent_steps_df_init,
                                                            maingrid_serie_init, subplots_param['maingrid'],
                                                            energy_vectors)
            """
            subplot.plot_power_target_by_energy_vector([row+i for i in range(energy_vectors_number)],
                                                            fig_classic, color_map, convention,
                                                            dates,
                                                            assets_df_init, asset_steps_power_df_diff, pd.DataFrame(), pd.DataFrame(), # Considers that power_prediction will not be changed
                                                            maingrid_serie_diff, subplots_param['maingrid'],
                                                            energy_vectors, diff=True)
        elif title == 'Energy market prices & Market engagements':
            # Not checked yet
            subplot.plot_energy_market_prices_engagements(row, fig_classic, color_map_greyscale, currency_unit, convention,
                                                        dates, prices_df_init, engagement_df_init,
                                                        subplots_param['spot_threshold'],
                                                        operation_steps_output_df_init)
            subplot.plot_energy_market_prices_engagements(row, fig_classic, color_map, currency_unit, convention,
                                                        dates, prices_df_init, engagement_df_diff,
                                                        subplots_param['spot_threshold'],
                                                        operation_steps_output_df_diff)  
        elif title == 'Imbalances':
            # Not checked yet
            subplot.plot_imbalances(row, fig_classic, color_map_greyscale, convention,
                                    dates,
                                    engagement_df_init, maingrid_serie_init,
                                    operation_steps_output_df_init, storage_assets_df_init, asset_steps_power_df_init)
            subplot.plot_imbalances(row, fig_classic, color_map, convention,
                                    dates,
                                    engagement_df_diff, maingrid_serie_diff,
                                    operation_steps_output_df_diff, storage_assets_df_init, asset_steps_power_df_diff)
        elif title.endswith('congestions') and not congestions_plot_done :
            congestions_plot_done = True
            subplot.plot_congestions_by_site([row+i for i in range(subplots_congestions_number)], 
                                                      fig_classic, color_map, convention,
                                                      dates,
                                                      operation_steps_df_init,
                                                      site_assets_df_init,
                                                      asset_steps_power_df_init, assets_df_init,
                                                      engagement_df_init, diff=True, legend_prefix="Initial ")
            subplot.plot_congestions_by_site([row+i for i in range(subplots_congestions_number)], 
                                                      fig_classic, color_map, convention,
                                                      dates,
                                                      operation_steps_df_init,
                                                      site_assets_df_init,
                                                      asset_steps_power_df_forced, assets_df_init,
                                                      engagement_df_forced, diff=True, legend_prefix="Forced ")
        elif title == 'Target SOC & Energy market prices':
            subplot.plot_soc(row, fig_classic, color_map_greyscale, currency_unit,
                     dates,
                     storage_assets_df_init, asset_steps_soc_df_init, prices_df_init, operation_steps_output_df_init, legend_prefix="Initial ")
            subplot.plot_soc(row, fig_classic, color_map, currency_unit,
                     dates,
                     storage_assets_df_init, asset_steps_soc_df_diff, prices_df_init, operation_steps_output_df_diff, diff=True, legend_prefix="Forced ")
        elif title == 'Assets availability':
            subplot.plot_asset_availability(row, fig_classic, color_map_greyscale,
                                    dates,
                                    assets_df_init, asset_steps_availability_df_init)
            subplot.plot_asset_availability(row, fig_classic, color_map,
                                    dates,
                                    assets_df_init, asset_steps_availability_df_diff)
    for index, title in enumerate(subplot_comp_titles):
        row = index + 1
        if title == 'Optimization objective values and violation costs':
            # Table with objective function values and violation costs
            obj_func_df = obj_func_df.reset_index()
            fig_comp.add_trace(go.Table(header=dict(values=[k for k in obj_func_df.columns if k!='tot_costs']),
                                   cells=dict(values=[obj_func_df[k].tolist() for k in obj_func_df.columns if k!='tot_costs'],
                                              align=["left", "right", "right", "right"],
                                              format=["",".4f",".4f",".4f"])
                                              ), row=row, col=1)
        elif title == 'Optimization costs repartition':
            # Graph with costs by type for each optimization and the difference
            color_list_costs = [color_map_costs.get(cost_name,'grey') for cost_name in tot_costs_df.index]
            color_list_costs_greyscale = ['grey' for cost_name in tot_costs_df.index]
            fig_comp.add_trace(go.Bar(
                x=list(tot_costs_df['tot_costs_init']),
                y=list(tot_costs_df.index),
                name='Initial optimization costs',
                orientation='h',
                marker_color=color_list_costs, #"rgba(0,0,0,0)", #color_list_costs_greyscale,
                opacity=0.5,
                visible='legendonly',
                ), row=row, col=1
            )
            fig_comp.add_trace(go.Bar(
                x=list(tot_costs_df['tot_costs_forced']),
                y=list(tot_costs_df.index),
                name='Forced optimization costs',
                orientation='h',
                base=0,
                marker_color="rgba(0,0,0,0)", #color_list_costs_greyscale,
                marker_line_color=color_list_costs,
                visible='legendonly',
                ), row=row, col=1
            )
            fig_comp.add_trace(go.Bar(
                x=list(tot_costs_df['tot_costs_diff']),
                y=list(tot_costs_df.index),
                name='Costs variation',
                orientation='h',
                #base=tot_costs_df['tot_costs_init'],
                marker_color=color_list_costs,
                ), row=row, col=1
            )
            fig_comp.update_layout(xaxis1=dict(ticksuffix=''+currency_unit))
        elif title == 'Initial optimization violations':
            subplot.plot_violations(row, fig_comp, data_out_init['VIOLATIONS_OUTPUT'])
        elif title == 'Forced optimization violations':
            subplot.plot_violations(row, fig_comp, data_out_forced['VIOLATIONS_OUTPUT'])


    # GENERAL LAYOUT --------------------------------------------------------------------------
    
    fig_text = "<sub>" + obj_func_comparison_text
    if convention == 1:
        fig_text += '<br>(Consumer convention)</sub>'
    else: 
        fig_text += '<br>(Producer convention)</sub>'

    fig_classic.update_layout(
        title = fig_text,
        legend_title = '',
        barmode = 'relative',  # This sets the bars to stack on top of each other
        bargap = 0,
        height = 375*subplots_classic_number,
        margin = dict(t = 150,
                      b = 100,
        ),
        #template='plotly_white',
    )
    height_comp = 375
    if subplots_comp[1] :
        height_comp += 325
    if subplots_comp[2] :
        height_comp += 325
    if subplots_comp[3] :
        height_comp += 325
    fig_comp.update_layout(title_text="Optimization comparison"
                                "<br><br><sup>" + input_comparison_text + "</sup>",
                            height = height_comp,
                            margin=dict(t=150),
                            barmode='group')

    fig_classic.update_xaxes(showticklabels=True, showline=True, mirror=True)
    fig_classic.update_yaxes(rangemode='tozero', showline=True, mirror=True)
    
    # Sublegends
    for i, yaxis in enumerate(fig_classic.select_yaxes(), 1):
        if yaxis.domain != None:
            legend_name = f"legend{i}"
            fig_classic.update_layout({legend_name: dict(y=yaxis.domain[1], yanchor="top")}, showlegend=True)
            fig_classic.update_traces(row=i//2+1, legend=legend_name)
    for i, yaxis in enumerate(fig_comp.select_yaxes(), 1):
        if yaxis.domain != None:
            legend_name = f"legend{i}"
            fig_comp.update_layout({legend_name: dict(y=yaxis.domain[1], yanchor="top")}, showlegend=True)
            fig_comp.update_traces(row=i//2+1, legend=legend_name)

    combine_plotly_figs_to_html([fig_comp, fig_classic], html_path, auto_open=True) #separator="<p>Test afficher du texte entre les deux figures</p>",
