from __future__ import annotations

from datetime import datetime, timedelta

import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots

from optim_analyser.analysis import subplot
from optim_analyser.analysis.colors import color_blind_map, color_map_costs, color_map_default
from optim_analyser.errors import OptimizationFail
from optim_analyser.optim import dataframes


def get_df(
    input_data: dict[str, pd.DataFrame], output_data: dict[str, pd.DataFrame], subplots_param: pd.DataFrame
) -> tuple[
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.Series,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
    pd.DataFrame,
]:
    """
    Return the most useful optimization data in dataframes or series

    :param input_data: The optimization input data
    :type input_data: dict[str,pd.DataFrame]
    :param output_data: The optimization output data
    :type output_data: dict[str,pd.DataFrame]
    :param subplots_param: The specific plotting parameters for the microgrid
    :type subplots_param: pd.DataFrame
    :return: The operation data sheet transposed (index 'param_id'),
    the operation steps data sheet,
    the assets data sheet with good stacking order (index 'asset_id'),
    the storage assets data sheet which is the assets data sheet with only the storage assets (index 'asset_id'),
    the intermittent assets data sheet which is the assets data sheet with only the intermittent assets (index 'asset_id'),
    the site assets data sheet with only the site assets,
    the maingrid series (index 'step_id'),
    the asset steps power data sheet pivoted (index 'step_id', columns 'asset_id'),
    the intermittent steps power prediction data sheet (index 'step_id', columns 'asset_id'),
    the day-ahead, PPA and transport price data sheet (index 'step_index' int),
    the engagement data sheet (index 'step_id'/'step_index' int),
    the storage soc steps data sheet (index 'step_id', columns 'asset_id'),
    the asset availability steps data sheet pivoted (index 'step_id', columns 'asset_id'),
    the operation steps output data sheet,
    :rtype: tuple[pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.Series,pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.DataFrame,pd.DataFrame]
    """

    if any([input_data[sheet_name].columns.tolist() == [] for sheet_name in input_data.keys()]):
        raise OptimizationFail("No optimization input data to display")
    if any([output_data[sheet_name].columns.tolist() == [] for sheet_name in output_data.keys()]):
        raise OptimizationFail("No optimization output data to display")

    operation_df = input_data["OPERATION"].set_index("param_id").transpose()

    operation_steps_df = input_data["OPERATION_STEPS"]

    # POWER TARGET -----------------------------------------------------------------------------
    assets_df = input_data["ASSETS"].drop(columns=["type", "control"])
    asset_type_order = ["INTERMITTENT", "GENERATOR", "LOAD", "FLEX_LOAD", "STORAGE", "SITE"]
    assets_df["type"] = pd.Categorical(input_data["ASSETS"]["type"], asset_type_order)
    assets_df["control"] = pd.Categorical(input_data["ASSETS"]["control"], ["NONE", "POWER"])
    assets_df = assets_df.sort_values(by=["type", "control"])
    real_asset = []
    for index_asset in assets_df.index:
        asset_name = assets_df.loc[index_asset]["asset_id"]
        asset_type = assets_df.loc[index_asset]["type"]
        real_asset.append(not (asset_name.startswith("dummy")) and asset_type != "SITE")
    assets_df = assets_df.loc[real_asset]
    for index_asset in assets_df.index:
        if assets_df.at[index_asset, "type"] == "LOAD" and assets_df.at[index_asset, "control"] == "POWER":
            assets_df.at[index_asset, "type"] = "FLEX_LOAD"
    assets_df = assets_df.set_index("asset_id", drop=True)

    # STORAGE ASSETS
    storage_assets_df = assets_df[assets_df["type"] == "STORAGE"]
    # INTERMITTENT ASSETS
    intermittent_assets_df = assets_df[assets_df["type"] == "INTERMITTENT"]
    # SITE ASSETS
    site_assets_df = input_data["ASSETS"][input_data["ASSETS"]["type"] == "SITE"]

    # ASSET_STEPS
    if "ASSET_STEPS_OUTPUT" not in output_data:
        raise OptimizationFail(
            f"Output data is missing 'ASSET_STEPS_OUTPUT' sheet. Available sheets: {list(output_data.keys())}"
        )

    asset_steps_df = output_data["ASSET_STEPS_OUTPUT"].filter(
        items=["asset_id", "step_id", "power_target", "target_soc", "storage_target", "energy_target"]
    )
    maingrid_serie = (
        asset_steps_df[asset_steps_df["asset_id"] == "MAINGRID"]
        .set_index("step_id", drop=True)["power_target"]
        .astype(float)
    )
    asset_steps_df = asset_steps_df[asset_steps_df["asset_id"] != "MAINGRID"]
    asset_steps_df.loc[:, "step_id"] = pd.to_numeric(asset_steps_df["step_id"])
    asset_steps_df = asset_steps_df.sort_values(by=["step_id"])  # Sort by step_id to ensure proper stacking
    # Pivot the DataFrame for stacked bar plotting
    asset_steps_power_df = asset_steps_df.pivot_table(
        index="step_id", columns="asset_id", values="power_target", fill_value=0, aggfunc=lambda x: float(x.iloc[0])
    )

    # Intermittent potential
    intermittent_steps_df = input_data["ASSET_STEPS"].filter(items=["asset_id", "step_id", "power_prediction"])
    intermittent_steps_df = intermittent_steps_df.loc[
        intermittent_steps_df["asset_id"].isin(intermittent_assets_df.index)
    ]
    intermittent_steps_df.loc[:, "step_id"] = pd.to_numeric(intermittent_steps_df["step_id"])
    intermittent_steps_df = intermittent_steps_df.sort_values(by="step_id").pivot_table(
        index="step_id", columns="asset_id", values="power_prediction", fill_value=0, aggfunc=lambda x: x
    )

    # ENERGY MARKET PRICES & ENGAGEMENTS ------------------------------------------------------
    operation_steps_link = (
        input_data["OPERATION_STEPS_LINK"].astype(float).astype(int).set_index("asset_step", drop=True)
    )  # All steps are converted into int (str->float->int), they are used as indexes later

    # PRICES
    prices_df = pd.DataFrame()

    # Spot price
    day_ahead_init_df = (
        input_data["MARKET_PRICE_STEPS"][input_data["MARKET_PRICE_STEPS"]["type"] == "DAY_AHEAD"]
        .astype({"step_index": int})
        .filter(items=["step_index", "price"])
        .set_index(
            "step_index",
            drop=True,
        )
    )
    if not day_ahead_init_df.empty:
        for index, steps in operation_steps_link.iterrows():
            # if steps['day_ahead_step'] < day_ahead_init_df.last_valid_index() :
            if steps["day_ahead_step"] in list(day_ahead_init_df.index):
                prices_df.at[index, "day_ahead"] = day_ahead_init_df.loc[steps["day_ahead_step"], "price"]
            else:
                prices_df.at[index, "day_ahead"] = 0

    # PPA price
    ppa_init_df = input_data["MARKET_PRICE_STEPS"]
    ppa_init_df = (
        ppa_init_df[ppa_init_df["type"] == "PPA"]
        .filter(items=["step_index", "price"])
        .set_index("step_index", drop=True)
    )
    if not ppa_init_df.empty:
        for index, steps in operation_steps_link.iterrows():
            if steps["ppa_step"] in list(ppa_init_df.index):
                prices_df.at[index, "ppa"] = ppa_init_df.loc[steps["ppa_step"], "price"]
            else:
                prices_df.at[index, "ppa"] = 0

    # TURPE price
    prices_df["transport"] = (
        input_data["MARKET_PRICE_STEPS"][input_data["MARKET_PRICE_STEPS"]["type"] == "TRANSPORT"]
        .astype({"step_index": int})
        .filter(items=["step_index", "price"])
        .set_index("step_index", drop=True)
    )

    # Threshold on day-ahead price
    if subplots_param["spot_threshold"]:
        threshold_init_df = (
            output_data["MARKET_BIDS_OUTPUT"][output_data["MARKET_BIDS_OUTPUT"]["type"] == "DAY_AHEAD"]
            .astype({"step_id": int})
            .filter(items=["step_id", "price"])
            .set_index(
                "step_id",
                drop=True,
            )
        )
        if not threshold_init_df.empty:
            for index, steps in operation_steps_link.iterrows():
                if steps["day_ahead_step"] in list(day_ahead_init_df.index):
                    prices_df.at[index, "day_ahead_threshold"] = threshold_init_df.loc[steps["day_ahead_step"], "price"]
                else:
                    prices_df.at[index, "day_ahead_threshold"] = 0

    # ENGAGEMENTS
    engagement_df = pd.DataFrame()

    # Long term engagement
    long_term_engagement_init_df = (
        input_data["MARKET_ENGAGEMENTS"].astype({"step_index": int}).set_index("step_index", drop=True)
    )
    long_term_engagement_init_df = (
        long_term_engagement_init_df[long_term_engagement_init_df["type"] == "ELECTRICITY_LONG_TERM_AGREGATED_BIDS"]
        .filter(items=["engagement"])
        .astype(float)
    )
    if not (long_term_engagement_init_df.empty):
        for index, steps in operation_steps_link.iterrows():
            engagement_df.at[index, "long_term"] = long_term_engagement_init_df.loc[
                steps["day_ahead_step"], "engagement"
            ]

    if subplots_param["engagement"]:
        # Day ahead engagement and clearing
        day_ahead_engagement_init_df = (
            output_data["MARKET_BIDS_OUTPUT"].astype({"step_id": int}).set_index("step_id", drop=True)
        )
        day_ahead_engagement_init_df = (
            day_ahead_engagement_init_df[day_ahead_engagement_init_df["type"] == "DAY_AHEAD"]
            .filter(items=["power"])
            .astype(float)
        )
        day_ahead_clearing_init_df = (
            input_data["MARKET_ENGAGEMENTS"].astype({"step_index": int}).set_index("step_index", drop=True)
        )
        day_ahead_clearing_init_df = (
            day_ahead_clearing_init_df[day_ahead_clearing_init_df["type"] == "DAY_AHEAD"]
            .filter(items=["is_step_cleared"])
            .astype(int)
        )
        if not (day_ahead_engagement_init_df.empty):
            for index, steps in operation_steps_link.iterrows():
                engagement_df.at[index, "day_ahead"] = day_ahead_engagement_init_df.loc[
                    steps["day_ahead_step"], "power"
                ]
                engagement_df.at[index, "is_step_cleared"] = day_ahead_clearing_init_df.loc[
                    steps["day_ahead_step"], "is_step_cleared"
                ]

        # PPA engagement
        ppa_engagement_init_df = output_data["MARKET_BIDS_OUTPUT"].set_index("step_id", drop=True)
        ppa_engagement_init_df = (
            ppa_engagement_init_df[ppa_engagement_init_df["type"] == "PPA"].filter(items=["power"]).astype(float)
        )
        if not (ppa_engagement_init_df.empty):
            for index, steps in operation_steps_link.iterrows():
                engagement_df.at[index, "ppa"] = -ppa_engagement_init_df.loc[
                    int(steps["ppa_step"]), "power"
                ]  # PPA engagement sign seems to be the opposite of usual signs for engagements

        # FCR engagement
        fcr_engagement_init_df = output_data["MARKET_BIDS_OUTPUT"].set_index("step_id", drop=True)
        fcr_engagement_init_df = (
            fcr_engagement_init_df[fcr_engagement_init_df["type"] == "FCR"].filter(items=["power"]).astype(float)
        )
        if not (fcr_engagement_init_df.empty):
            for index, steps in operation_steps_link.iterrows():
                engagement_df.at[index, "fcr"] = fcr_engagement_init_df.loc[steps["fcr_step"], "power"]

        # aFRR capacity up engagement (input)
        afrr_capacity_up_engagement_init_df = (
            input_data["MARKET_ENGAGEMENTS"].astype({"step_index": int}).set_index("step_index", drop=True)
        )
        afrr_capacity_up_engagement_init_df = (
            afrr_capacity_up_engagement_init_df[afrr_capacity_up_engagement_init_df["type"] == "AFRR_R2_CAPACITY_UP"]
            .filter(items=["engagement"])
            .astype(float)
        )
        if not (afrr_capacity_up_engagement_init_df.empty):
            for index, steps in operation_steps_link.iterrows():
                engagement_df.at[index, "afrr_capacity_up"] = -afrr_capacity_up_engagement_init_df.loc[
                    steps["afrr_capacity_step"], "engagement"
                ]

        # aFRR capacity down engagement (input)
        afrr_capacity_down_engagement_init_df = (
            input_data["MARKET_ENGAGEMENTS"].astype({"step_index": int}).set_index("step_index", drop=True)
        )
        afrr_capacity_down_engagement_init_df = (
            afrr_capacity_down_engagement_init_df[
                afrr_capacity_down_engagement_init_df["type"] == "AFRR_R2_CAPACITY_DOWN"
            ]
            .filter(items=["engagement"])
            .astype(float)
        )
        if not (afrr_capacity_down_engagement_init_df.empty):
            for index, steps in operation_steps_link.iterrows():
                engagement_df.at[index, "afrr_capacity_down"] = +afrr_capacity_down_engagement_init_df.loc[
                    steps["afrr_capacity_step"], "engagement"
                ]

        # aFRR voluntary up engagement (input)
        afrr_voluntary_up_engagement_init_df = (
            input_data["MARKET_ENGAGEMENTS"].astype({"step_index": int}).set_index("step_index", drop=True)
        )
        afrr_voluntary_up_engagement_init_df = (
            afrr_voluntary_up_engagement_init_df[afrr_voluntary_up_engagement_init_df["type"] == "AFRR_R2_VOLUNTARY_UP"]
            .filter(items=["engagement"])
            .astype(float)
        )
        if not (afrr_voluntary_up_engagement_init_df.empty):
            for index, steps in operation_steps_link.iterrows():
                engagement_df.at[index, "afrr_voluntary_up"] = -afrr_voluntary_up_engagement_init_df.loc[
                    steps["afrr_voluntary_step"], "engagement"
                ]

        # aFRR voluntary down engagement (input)
        afrr_voluntary_down_engagement_init_df = (
            input_data["MARKET_ENGAGEMENTS"].astype({"step_index": int}).set_index("step_index", drop=True)
        )
        afrr_voluntary_down_engagement_init_df = (
            afrr_voluntary_down_engagement_init_df[
                afrr_voluntary_down_engagement_init_df["type"] == "AFRR_R2_VOLUNTARY_DOWN"
            ]
            .filter(items=["engagement"])
            .astype(float)
        )
        if not (afrr_voluntary_down_engagement_init_df.empty):
            for index, steps in operation_steps_link.iterrows():
                engagement_df.at[index, "afrr_voluntary_down"] = +afrr_voluntary_down_engagement_init_df.loc[
                    steps["afrr_voluntary_step"], "engagement"
                ]

    # IMBALANCES ----------------------------------------------------------------------------
    if subplots_param["engagement"]:
        if "day_ahead" in engagement_df.columns:
            engagement_df["total"] = engagement_df["day_ahead"].copy()
        elif "ppa" in engagement_df.columns:
            engagement_df["total"] = engagement_df["ppa"].copy()
        if "long_term" in engagement_df.columns:
            engagement_df["total"] += engagement_df["long_term"]

    # TARGET SOC & ENERGY MARKET PRICES -----------------------------------------------------

    if "target_soc" in list(asset_steps_df.columns):
        asset_steps_soc_df = asset_steps_df.pivot_table(
            index="step_id", columns="asset_id", values="target_soc", fill_value=0, aggfunc=lambda x: x
        )
    else:  # If target_soc is not computed, recompute from storage_target/energy_target values
        if "storage_target" in list(asset_steps_df.columns):
            asset_steps_soc_df = asset_steps_df.pivot_table(
                index="step_id", columns="asset_id", values="storage_target", fill_value=0, aggfunc=lambda x: x
            )
        elif "energy_target" in list(asset_steps_df.columns):
            asset_steps_soc_df = asset_steps_df.pivot_table(
                index="step_id", columns="asset_id", values="energy_target", fill_value=0, aggfunc=lambda x: x
            )
        for asset_id in storage_assets_df.index:
            try:
                max_energy = float(assets_df.loc[asset_id, "nominal_max_energy"])
            except:
                max_energy = float(assets_df.loc[asset_id, "max_energy"])
            if max_energy > 0:
                asset_steps_soc_df.loc[:, asset_id] = asset_steps_soc_df.loc[:, asset_id] * 100 / max_energy
            else:
                asset_steps_soc_df.loc[:, asset_id] = 0

    # AVAILABILITY --------------------------------------------------------------------------

    asset_steps_availability_df = input_data["ASSET_STEPS"].filter(items=["asset_id", "step_id", "availability"])
    asset_steps_availability_df = asset_steps_availability_df.pivot_table(
        index="step_id", columns="asset_id", values="availability", fill_value=0, aggfunc=lambda x: x
    )
    asset_steps_availability_df = asset_steps_availability_df.filter(items=assets_df.index)

    # OUTPUT --------------------------------------------------------------------------------
    operation_steps_output_df = output_data["OPERATION_STEPS_OUTPUT"]

    return (
        operation_df,
        operation_steps_df,
        assets_df,
        storage_assets_df,
        intermittent_assets_df,
        site_assets_df,
        maingrid_serie,
        asset_steps_power_df,
        intermittent_steps_df,
        prices_df,
        engagement_df,
        asset_steps_soc_df,
        asset_steps_availability_df,
        operation_steps_output_df,
    )


def fig_from_input_output_data(
    input_data: dict[str, pd.DataFrame],
    output_data: dict[str, pd.DataFrame],
    sc_name: str,
    subplots_param: pd.DataFrame,
    add_costs: bool = True,
    color_blind: bool = False,
) -> go.Figure:
    """
    The figure with all subplots filled

    :param input_data: The optimization input data
    :type input_data: dict[str,pd.DataFrame]
    :param output_data: The optimization output data
    :type output_data: dict[str,pd.DataFrame]
    :param sc_name: The scenario name
    :type sc_name: str
    :param subplots_param: The specific plotting parameters for the microgrid
    :type subplots_param: pd.DataFrame
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to True
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    :return: The figure with all subplots
    :rtype: go.Figure
    """
    (
        operation_df,
        operation_steps_df,
        assets_df,
        storage_assets_df,
        intermittent_assets_df,
        site_assets_df,
        maingrid_serie,
        asset_steps_power_df,
        intermittent_steps_df,
        prices_df,
        engagement_df,
        asset_steps_soc_df,
        asset_steps_availability_df,
        operation_steps_output_df,
    ) = get_df(input_data, output_data, subplots_param)

    # Load the step numbers/durations
    optimisation_interval_start = operation_df["optimisation_interval_start"]["param_val"]
    if type(optimisation_interval_start) != datetime:
        optimisation_interval_start = datetime.strptime(optimisation_interval_start[:-4], "%Y-%m-%d %H:%M:%S")

    optimisation_request_time = operation_df["optimisation_request_time"]["param_val"]
    if type(optimisation_request_time) != datetime:
        optimisation_request_time = datetime.strptime(optimisation_request_time[:-4], "%Y-%m-%d %H:%M:%S")

    optimisation_step_number = int(operation_df["optimisation_step_number"]["param_val"])

    asset_step_duration = int(operation_df["asset_step_duration"]["param_val"])

    dates = pd.Series(
        [
            optimisation_interval_start + timedelta(minutes=asset_step_duration) * i
            for i in range(optimisation_step_number)
        ]
    )
    dates.index += 1

    # ENERGY VECTORS
    energy_vectors_number = 1  # Elec by default
    energy_vectors = ["ELECTRICITY"]
    # if any(["H2" in assets_df.at[asset_id, "energies_in"] for asset_id in assets_df.index]) or any(["H2" in assets_df.at[asset_id, "energies_out"] for asset_id in assets_df.index]):
    if any(["H2" in asset_id for asset_id in assets_df.index]):
        energy_vectors_number += 1
        energy_vectors.append("H2")
    # if any(["GAS" in assets_df.at[asset_id, "energies_in"] for asset_id in assets_df.index]) or any(["GAS" in assets_df.at[asset_id, "energies_out"] for asset_id in assets_df.index]):
    if any(["GAS" in asset_id in asset_id for asset_id in assets_df.index]):
        energy_vectors_number += 1
        energy_vectors.append("GAS")
    # if any(["HEAT" in assets_df.at[asset_id, "energies_in"] for asset_id in assets_df.index]) or any(["HEAT" in assets_df.at[asset_id, "energies_out"] for asset_id in assets_df.index]):
    if any(
        [
            "HEAT" in asset_id
            or asset_id in ["Buffer_850m3", "Verberne_America_HeatBuffer", "Verberne_America_Heat_Need"]
            for asset_id in assets_df.index
        ]
    ):
        energy_vectors_number += 1
        energy_vectors.append("HEAT")

    # CONGESTION ----------------------------------------------------------------------------
    # min_power = max(max(site_assets_df['min_power'].values),
    #                max(- input_data['OPERATION_STEPS']['max_export_to_main_grid'])) #max bc <0 values
    # max_power = min(min(site_assets_df['max_power'].values),
    #                min(input_data['OPERATION_STEPS']['max_import_from_main_grid']))

    # AVAILABILITY --------------------------------------------------------------------------
    all_available = (asset_steps_availability_df - 1).sum(axis=1).sum(axis=0) == 0.0

    # PLOT ----------------------------------------------------------------------------------

    if color_blind:
        color_map = color_blind_map
    else:
        color_map = color_map_default

    subplots = [
        # Power Target
        [True] * energy_vectors_number,
        # Energy market prices & Market engagements
        subplots_param["day_ahead_price"] or subplots_param["engagement"],
        # Imbalances
        subplots_param["imbalance"],
        # Congestions
        # subplots_param['congestion']
        [subplots_param["congestion"]] * site_assets_df.shape[0],
        # Target SOC & Energy market prices
        not storage_assets_df.empty,
        # Assets availability if there is at least one asset that is unavailable
        not all_available,
        # Costs
        add_costs,
        # Total costs
        add_costs,
        # Table of violations if not empty
        not output_data["VIOLATIONS_OUTPUT"].empty,
    ]

    # Count the number of displayed subplots, need to count the list of bool for the congestions separately
    subplots_congestions_number = subplots[3].count(True)
    subplots_number = subplots.count(True) + energy_vectors_number + subplots_congestions_number

    def flatten_list(lst: list):
        flat = []
        for elt in lst:
            if type(elt) != list:
                flat.append(elt)
            else:
                flat += flatten_list(elt)
        return flat

    subplots_flat = flatten_list(subplots)
    congestions_titles = [site_name + " congestions" for site_name in site_assets_df["asset_id"].values]
    power_target_titles = ["Power Target " + energy_vector + " [kW]" for energy_vector in energy_vectors]
    all_subplot_titles_flat = flatten_list(
        [
            power_target_titles,
            "Energy market prices & Market engagements",
            "Imbalances",
            congestions_titles,
            "Target SOC & Energy market prices",
            "Assets availability",
            "Costs",
            "Total costs",
            "Violations",
        ]
    )
    subplot_titles = [title for index, title in enumerate(all_subplot_titles_flat) if subplots_flat[index]]

    all_specs_flat = [[{"secondary_y": True}]] * (len(subplots_flat) - 1)
    all_specs_flat.append([{"type": "table"}])
    specs = [title for index, title in enumerate(all_specs_flat) if subplots_flat[index]]

    # Consumer convention by default in Everest -> Consumption > 0, Production < 0
    # 1 for consumer, -1 for producer
    convention = subplots_param["convention"]

    # Currency unit symbol, default is CU
    currency_unit = subplots_param["currency_unit"]

    # Create a subplot layout
    fig = make_subplots(
        rows=subplots_number,
        cols=1,
        shared_xaxes=True,
        subplot_titles=subplot_titles,
        specs=specs,
        vertical_spacing=0.25 / subplots_number,
    )

    # Call the plot functions
    power_target_plot_done = False
    congestions_plot_done = False
    for index, title in enumerate(subplot_titles):
        row = index + 1
        if title.startswith("Power Target") and not power_target_plot_done:
            power_target_plot_done = True
            subplot.plot_power_target_by_energy_vector(
                [row + i for i in range(energy_vectors_number)],
                fig,
                color_map,
                convention,
                dates,
                assets_df,
                asset_steps_power_df,
                intermittent_assets_df,
                intermittent_steps_df,
                maingrid_serie,
                subplots_param["maingrid"],
                energy_vectors,
            )
        elif title == "Energy market prices & Market engagements":
            subplot.plot_energy_market_prices_engagements(
                row,
                fig,
                color_map,
                currency_unit,
                convention,
                dates,
                prices_df,
                engagement_df,
                operation_steps_output_df,
            )
        elif title == "Imbalances":
            subplot.plot_imbalances(
                row,
                fig,
                color_map,
                convention,
                dates,
                engagement_df,
                maingrid_serie,
                operation_steps_output_df,
                storage_assets_df,
                asset_steps_power_df,
            )
        elif title.endswith("congestions") and not congestions_plot_done:
            congestions_plot_done = True
            subplot.plot_congestions_by_site(
                [row + i for i in range(subplots_congestions_number)],
                fig,
                color_map,
                convention,
                dates,
                operation_steps_df,
                site_assets_df,
                asset_steps_power_df,
                assets_df,
                engagement_df,
            )
        elif title == "Target SOC & Energy market prices":
            subplot.plot_soc(
                row,
                fig,
                color_map,
                currency_unit,
                dates,
                storage_assets_df,
                asset_steps_soc_df,
                prices_df,
                operation_steps_output_df,
            )
        elif title == "Assets availability":
            subplot.plot_asset_availability(row, fig, color_map, dates, assets_df, asset_steps_availability_df)
        elif title == "Costs":
            subplot.plot_costs(row, fig, color_map_costs, currency_unit, dates, input_data, output_data)
        elif title == "Total costs":
            subplot.plot_total_costs(row, fig, color_map_costs, currency_unit, input_data, output_data)
        elif title == "Violations":
            subplot.plot_violations(row, fig, output_data["VIOLATIONS_OUTPUT"])

    # GENERAL LAYOUT --------------------------------------------------------------------------
    if sc_name == None:
        sc_name = "Combined plots"
    if convention == 1:
        fig_title = sc_name + " (Consumer convention) : "  # + optimisation_request_time.strftime("%Y-%m-%d %H:%M:%S")
    else:
        fig_title = sc_name + " (Producer convention) : "  # + optimisation_request_time.strftime("%Y-%m-%d %H:%M:%S")

    fig.update_layout(
        title=fig_title,
        legend_title="",
        barmode="relative",  # This sets the bars to stack on top of each other
        bargap=0,
        height=325 * subplots_number,
        margin=dict(
            t=100,
            b=100,
        ),
        # template='plotly_white',
    )

    fig.update_xaxes(showticklabels=True, showline=True, mirror=True)
    fig.update_yaxes(rangemode="tozero", showline=True, mirror=True)

    # Sublegends
    for i, yaxis in enumerate(fig.select_yaxes(), 1):
        if yaxis.domain != None:
            legend_name = f"legend{i}"
            fig.update_layout({legend_name: dict(y=yaxis.domain[1], yanchor="top")}, showlegend=True)
            fig.update_traces(row=i // 2 + 1, legend=legend_name)

    return fig


def plot_from_input_output_data(
    input_data: dict[str, pd.DataFrame],
    output_data: dict[str, pd.DataFrame],
    sc_name: str,
    html_path: str,
    subplots_param: pd.DataFrame,
    add_costs: bool = True,
    color_blind: bool = False,
) -> None:
    """
    Generate .html with all visuals to analyse the given optimization, with input data and output data in separate dictionaries

    :param input_data: The optimization input data
    :type input_data: dict[str,pd.DataFrame]
    :param output_data: The optimization output data
    :type output_data: dict[str,pd.DataFrame]
    :param sc_name: The scenario name
    :type sc_name: str
    :param html_path: The .html file path where the optimization visuals will be saved
    :type html_path: str
    :param subplots_param: The specific plotting parameters for the microgrid
    :type subplots_param: pd.DataFrame
    :param add_costs: If True, the detailed optimization costs will be added in the .dat, defaults to True
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    fig = fig_from_input_output_data(input_data, output_data, sc_name, subplots_param, add_costs, color_blind)
    fig.write_html(html_path)
    # fig.write_image(file=html_path.replace(".html", ".png"))
    fig.show()


def plot_from_data(
    all_data: dict[str, pd.DataFrame],
    sc_name: str | None,
    html_path: str,
    subplots_param: pd.DataFrame,
    color_blind: bool = False,
) -> None:
    """
    Generate .html with all visuals to analyse the given optimization

    :param all_data: The optimization input and output data
    :type all_data: dict[str,pd.DataFrame]
    :param sc_name: The scenario name
    :type sc_name: str
    :param html_path: The .html file path where the optimization visuals will be saved
    :type html_path: str
    :param subplots_param: The specific plotting parameters for the microgrid
    :type subplots_param: pd.DataFrame
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    input_fields = [
        "assets",
        "asset_steps",
        "congestions",
        "congestion_assets",
        "market_engagements",
        "market_price_steps",
        "operation",
        "operation_steps",
        "operation_steps_link",
        "variable_cost_models",
    ]
    input_fields_upper = [field.upper() for field in input_fields]

    output_fields = [
        "operation_output",
        "operation_steps_output",
        "assets_output",
        "asset_steps_output",
        "violations_output",
        "market_bids_output",
        "costs",
    ]
    output_fields_upper = [field.upper() for field in output_fields]

    # Separate the input and output data from the dictionnary containing all the data
    input_data = dict((k, all_data[k]) for k in input_fields_upper if k in all_data)
    output_data = dict((k, all_data[k]) for k in output_fields_upper if k in all_data)

    add_costs = "COSTS" in output_data.keys()

    plot_from_input_output_data(input_data, output_data, sc_name, html_path, subplots_param, add_costs, color_blind)


def plot_from_excel(
    excel_input_path: str,
    excel_output_path: str,
    sc_name: str | None,
    html_path: str,
    client_param: pd.DataFrame,
    add_costs: bool = False,
    color_blind: bool = False,
) -> None:
    """
    Generate .html with all visuals to analyse the given optimization, with input data and output data in separate dictionaries

    :param excel_input_path: The input data Excel file path
    :type excel_input_path: str
    :param excel_output_path: The output data Excel file path
    :type excel_output_path: str
    :param sc_name: The scenario name
    :type sc_name: str
    :param html_path: The .html file path where the optimization visuals will be saved
    :type html_path: str
    :param client_param: The specific plotting parameters for the microgrid
    :type client_param: pd.DataFrame
    :param add_costs: If True, the detailed repartition of the optimization costs will be added, defaults to True
    :type add_costs: bool, optional
    :param color_blind: If True, the color blind palette will be used, defaults to False
    :type color_blind: bool, optional
    """

    # Load the input and output data from the Excel files
    input_data = dataframes.excel_to_dataframe(excel_input_path)
    output_data = dataframes.excel_to_dataframe(excel_output_path)

    plot_from_input_output_data(input_data, output_data, sc_name, html_path, client_param, add_costs, color_blind)
