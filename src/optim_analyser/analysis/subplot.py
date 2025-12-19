import numpy as np
import pandas as pd
import plotly.graph_objects as go


def plot_power_target(
    row: int,
    fig: go.Figure,
    color_map: dict[str, str],
    convention: int,
    dates: pd.Series,
    assets_df: pd.DataFrame,
    asset_steps_power_df: pd.DataFrame,
    intermittent_assets_df: pd.DataFrame,
    intermittent_steps_df: pd.DataFrame,
    maingrid_serie: pd.Series,
    maingrid_bool: bool = True,
    diff: bool = False,
) -> None:
    """
    Plot the assets power targets, eventually the maingrid, the PV potential and the total PV potential in the given figure and row

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: go.Figure
    :param color_map: The color map used to display power targets
    :type color_map: dict[str,str]
    :param convention: If 1, the convention used is the consumer convention (same as Everest's convention). If -1, the convention used is the producer convention
    :type convention: int
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param assets_df: The assets data sheet with good stacking order (index 'asset_id')
    :type assets_df: pd.DataFrame
    :param asset_steps_power_df: The asset steps power data sheet pivoted (index 'step_id', columns 'asset_id')
    :type asset_steps_power_df: pd.DataFrame
    :param intermittent_assets_df: The intermittent assets data sheet which is the assets data sheet with only the intermittent assets (index 'asset_id')
    :type intermittent_assets_df: pd.DataFrame
    :param intermittent_steps_df: The intermittent steps power prediction data sheet (index 'step_id', columns 'asset_id')
    :type intermittent_steps_df: pd.DataFrame
    :param maingrid_serie: The maingrid series (index 'step_id')
    :type maingrid_serie: pd.Series
    :param maingrid_bool: If True, the maingrid series will be displayed with the power targets, defaults to True
    :type maingrid_bool: bool, optional
    :param diff: If True, comparison mode is activated and the legend texts are adapted , defaults to False
    :type diff: bool, optional
    :rtype: None
    """

    if diff:
        name_prefix = "Variation "
    else:
        name_prefix = ""

    for asset_id in assets_df.index:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * asset_steps_power_df[asset_id],
                name=name_prefix + asset_id,
                marker_color=color_map.get(asset_id, color_map.get(assets_df.loc[asset_id, "type"], "grey")),
            ),
            row=row,
            col=1,
        )
    if not (intermittent_assets_df.empty):
        for asset_id in intermittent_assets_df.index:
            fig.add_trace(
                go.Scatter(
                    x=dates,
                    y=convention * intermittent_steps_df[asset_id],
                    name=name_prefix + asset_id + " potential [kW]",
                    line=dict({"dash": "dash"}),
                    marker_color=color_map.get("INTERMITTENT", "grey"),
                ),
                row=row,
                col=1,
            )
        if len(intermittent_assets_df.index) > 1:
            fig.add_trace(
                go.Scatter(
                    x=dates,
                    y=convention * intermittent_steps_df.sum(axis=1),
                    name=name_prefix + "Total intermittent potential [kW]",
                    line=dict({"dash": "dash"}),
                    marker_color=color_map.get("INTERMITTENT POTENTIAL", "grey"),
                ),
                row=row,
                col=1,
            )
    if maingrid_bool:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=convention * maingrid_serie,
                mode="lines+markers",
                name=name_prefix + "Maingrid",
                marker_color=color_map.get("MAINGRID", "grey"),
            ),
            row=row,
            col=1,
        )
    exec("fig.update_layout(" + "yaxis%d" % (row * 2 - 1) + "=dict(ticksuffix=' kW', tickformat='digits'))")


def plot_power_target_by_energy_vector(
    rows: list[int],
    fig: go.Figure,
    color_map: dict[str, str],
    convention: int,
    dates: pd.Series,
    assets_df: pd.DataFrame,
    asset_steps_power_df: pd.DataFrame,
    intermittent_assets_df: pd.DataFrame,
    intermittent_steps_df: pd.DataFrame,
    maingrid_serie: pd.Series,
    maingrid_bool: bool = True,
    energy_vectors: list[str] = ["ELECTRICITY"],
    diff: bool = False,
) -> None:
    """
    Create the display of power targets for all assets in subplots, with one subplot for each type of energy vector

    :param rows: The rows of the subplots to fill in the figure
    :type rows: list[int]
    :param fig: The figure
    :type fig: go.Figure
    :param color_map: The color map used to display power targets
    :type color_map: dict[str,str]
    :param convention: If 1, the convention used is the consumer convention (same as Everest's convention). If -1, the convention used is the producer convention
    :type convention: int
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param assets_df: The assets data sheet with good stacking order (index 'asset_id')
    :type assets_df: pd.DataFrame
    :param asset_steps_power_df: The asset steps power data sheet pivoted (index 'step_id', columns 'asset_id')
    :type asset_steps_power_df: pd.DataFrame
    :param intermittent_assets_df: The intermittent assets data sheet which is the assets data sheet with only the intermittent assets (index 'asset_id')
    :type intermittent_assets_df: pd.DataFrame
    :param intermittent_steps_df: The intermittent steps power prediction data sheet (index 'step_id', columns 'asset_id')
    :type intermittent_steps_df: pd.DataFrame
    :param maingrid_serie: The maingrid series (index 'step_id')
    :type maingrid_serie: pd.Series
    :param maingrid_bool: If True, the maingrid series will be displayed with the power targets, defaults to True
    :type maingrid_bool: bool, optional
    :param energy_vectors: The list of energy vectors used in the microgrid, defaults to ['Elec']
    :type energy_vectors: list[str], optional
    :param diff: If True, comparison mode is activated and the legend texts are adapted , defaults to False
    :type diff: bool, optional
    :rtype: None
    """

    # HEAT IN ASSETS
    # heat_assets_id = [asset_id for asset_id in assets_df.index
    #                            if 'HEAT' in assets_df.at[asset_id, "energies_in"]]
    heat_assets_id = [
        asset_id
        for asset_id in assets_df.index
        if "HEAT" in asset_id
        or asset_id in ["Buffer_850m3", "Verberne_America_HeatBuffer", "Verberne_America_Heat_Need"]
    ]
    heat_assets_df = assets_df.loc[heat_assets_id]
    heat_assets_steps_power_df = asset_steps_power_df.loc[:, heat_assets_id]

    # H2 IN ASSETS
    # h2_assets_id = [asset_id for asset_id in assets_df.index
    #                            if 'H2' in assets_df.at[asset_id, "energies_in"]]
    h2_assets_id = [asset_id for asset_id in assets_df.index if "H2" in asset_id]
    h2_assets_df = assets_df.loc[h2_assets_id]
    h2_assets_steps_power_df = asset_steps_power_df.loc[:, h2_assets_id]

    # GAS IN ASSETS
    # gas_assets_id = [asset_id for asset_id in assets_df.index
    #                            if 'GAS' in assets_df.at[asset_id, "energies_in"]]
    gas_assets_id = [asset_id for asset_id in assets_df.index if "GAS" in asset_id]
    gas_assets_df = assets_df.loc[gas_assets_id]
    gas_assets_steps_power_df = asset_steps_power_df.loc[:, gas_assets_id]

    # ELEC IN ASSETS
    # elec_assets_id = [asset_id for asset_id in assets_df.index
    #                            if 'ELECTRICITY' in assets_df.at[asset_id, "energies_in"]]
    elec_assets_id = [
        asset_id
        for asset_id in assets_df.index
        if (asset_id not in heat_assets_id) and (asset_id not in h2_assets_id) and (asset_id not in gas_assets_id)
    ]
    elec_assets_df = assets_df.loc[elec_assets_id]
    elec_assets_steps_power_df = asset_steps_power_df.loc[:, elec_assets_id]

    if not elec_assets_steps_power_df.empty:
        plot_power_target(
            rows[energy_vectors.index("ELECTRICITY")],
            fig,
            color_map,
            convention,
            dates,
            elec_assets_df,
            elec_assets_steps_power_df,
            intermittent_assets_df,
            intermittent_steps_df,
            maingrid_serie,
            maingrid_bool,
            diff,
        )
    if not h2_assets_steps_power_df.empty:
        plot_power_target(
            rows[energy_vectors.index("H2")],
            fig,
            color_map,
            convention,
            dates,
            h2_assets_df,
            h2_assets_steps_power_df,
            pd.DataFrame(),
            pd.DataFrame(),
            pd.DataFrame(),
            False,
            diff,
        )
    if not gas_assets_steps_power_df.empty:
        plot_power_target(
            rows[energy_vectors.index("GAS")],
            fig,
            color_map,
            convention,
            dates,
            gas_assets_df,
            gas_assets_steps_power_df,
            pd.DataFrame(),
            pd.DataFrame(),
            pd.DataFrame(),
            False,
            diff,
        )
    if not heat_assets_steps_power_df.empty:
        plot_power_target(
            rows[energy_vectors.index("HEAT")],
            fig,
            color_map,
            convention,
            dates,
            heat_assets_df,
            heat_assets_steps_power_df,
            pd.DataFrame(),
            pd.DataFrame(),
            pd.DataFrame(),
            False,
            diff,
        )


def plot_energy_market_prices_engagements(
    row: int,
    fig: go.Figure,
    color_map: dict[str, str],
    currency_unit: str,
    convention: int,
    dates: pd.Series,
    prices_df: pd.DataFrame,
    engagement_df: pd.DataFrame,
    operation_steps_output_df: pd.DataFrame,
) -> None:
    """
    Create the display of energy market prices (day-ahead, day-ahead+TURPE, other electricity price) and market engagements (long term, day ahead and flex)

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: go.Figure
    :param color_map: The color map used to display energy market prices and market engagements
    :type color_map: dict[str,str]
    :param currency_unit: The currency unit symbol
    :type currency_unit: str
    :param convention: If 1, the convention used is the consumer convention (same as Everest's convention). If -1, the convention used is the producer convention
    :type convention: int
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param prices_df: The day-ahead, PPA, transport and day-ahead threshold price data sheet (index 'step_index' int)
    :type prices_df: pd.DataFrame
    :param engagement_df: The engagement data sheet (index 'step_id'/'step_index' int)
    :type engagement_df: pd.DataFrame
    :param operation_steps_output_df: The operation steps output data sheet
    :type operation_steps_output_df: pd.DataFrame
    :rtype: None
    """
    engagements = list(engagement_df.columns) != []
    if engagements:
        exec(
            "fig.update_layout("
            + "yaxis%d" % (row * 2 - 1)
            + "=dict(ticksuffix=' kW', tickformat='digits'), "
            + "yaxis%d" % (row * 2)
            + "=dict(ticksuffix=' '+currency_unit+'/MWh', tickformat='digits'))"
        )  # tickmode='sync' to have only one y grid
    else:
        exec(
            "fig.update_layout("
            + "yaxis%d" % (row * 2)
            + "=dict(ticksuffix=' '+currency_unit+'/MWh', tickformat='digits'))"
        )

    # Prices display
    if "day_ahead" in prices_df.columns and not prices_df["day_ahead"].sum() == 0:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=prices_df["day_ahead"] * 1000,
                name="Spot price [" + currency_unit + "/MWh]",
                line=dict({"dash": "solid"}),
                marker_color=color_map.get("SPOT", "grey"),
            ),
            row=row,
            col=1,
            secondary_y=engagements,
        )
        if "transport" in prices_df.columns and not prices_df["transport"].sum() == 0:
            fig.add_trace(
                go.Scatter(
                    x=dates,
                    y=(prices_df["transport"] + prices_df["day_ahead"]) * 1000,
                    name="Spot price + TURPE [" + currency_unit + "/MWh]",
                    line=dict({"dash": "dash"}),
                    marker_color=color_map.get("SPOT + TURPE", "grey"),
                ),
                row=row,
                col=1,
                secondary_y=engagements,
            )
        # THRESHOLD PRICE PLOT
        if "day_ahead_threshold" in prices_df.columns:
            fig.add_trace(
                go.Scatter(
                    x=dates,
                    y=prices_df["day_ahead_threshold"] * 1000,
                    line=dict({"dash": "dash"}),
                    name="Threshold [" + currency_unit + "/MWh]",
                    marker_color=color_map.get("SPOT", "grey"),
                ),
                row=row,
                col=1,
                secondary_y=engagements,
            )
    elif "ppa" in prices_df.columns:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=prices_df["ppa"] * 1000,
                name="PPA price [" + currency_unit + "/MWh]",
                line=dict({"dash": "solid"}),
                marker_color=color_map.get("SPOT", "grey"),
            ),
            row=row,
            col=1,
            secondary_y=engagements,
        )
    else:
        if not operation_steps_output_df["electricity_price"].sum() == 0:
            fig.add_trace(
                go.Scatter(
                    x=dates,
                    y=operation_steps_output_df["electricity_price"] * 1000,
                    name="Electricity price [" + currency_unit + "/MWh]",
                    marker_color=color_map.get("SPOT", "grey"),
                ),
                row=row,
                col=1,
                secondary_y=engagements,
            )
        if "transport" in prices_df["transport"] and not prices_df["transport"].sum() == 0:
            fig.add_trace(
                go.Scatter(
                    x=dates,
                    y=(prices_df["transport"] + operation_steps_output_df["electricity_price"]) * 1000,
                    name="Electricity price + TURPE [" + currency_unit + "/MWh]",
                    line=dict({"dash": "dot"}),
                    marker_color=color_map.get("SPOT + TURPE", "grey"),
                ),
                row=row,
                col=1,
                secondary_y=engagements,
            )

    # Engagements display
    if "long_term" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * engagement_df["long_term"],
                name="Long term engagement [kW]",
                marker_color=color_map.get("LONG_TERM", "grey"),
                visible="legendonly",
                opacity=0.9,
                # fill='tozeroy',
            ),
            row=row,
            col=1,
        )
    if "day_ahead" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates[engagement_df["is_step_cleared"] == 1],
                y=convention * engagement_df["day_ahead"][engagement_df["is_step_cleared"] == 1],
                name="Cleared day ahead engagement [kW]",
                marker_color=color_map.get("DAY_AHEAD", "grey"),
                marker_pattern_shape="/",
                visible="legendonly",
                opacity=0.9,
                # fill='tozeroy',
            ),
            row=row,
            col=1,
        )
        fig.add_trace(
            go.Bar(
                x=dates[engagement_df["is_step_cleared"] == 0],
                y=convention * engagement_df["day_ahead"][engagement_df["is_step_cleared"] == 0],
                name="Day ahead engagement [kW]",
                marker_color=color_map.get("DAY_AHEAD", "grey"),
                visible="legendonly",
                opacity=0.9,
                # fill='tozeroy',
            ),
            row=row,
            col=1,
        )

    if "total" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * engagement_df["total"],
                name="Total day ahead & long term engagement [kW]",
                marker_color=color_map.get("CLEAR", "grey"),
                base=0,
                opacity=0.8,
            ),
            row=row,
            col=1,
        )
    if "fcr" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * 2 * engagement_df["fcr"],
                name="FCR engagement [kW]",
                marker_color=color_map.get("FLEX", "grey"),
                base=convention * (engagement_df["total"] - engagement_df["fcr"]),
                opacity=0.8,
            ),
            row=row,
            col=1,
        )
    if "afrr_capacity_up" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * (-engagement_df["afrr_capacity_up"]),  # -afrr : .xlsx only >0 values
                name="aFRR capacity engagement (up) [kW]",
                marker_color=color_map.get("FLEX", "grey"),
                base=convention * engagement_df["total"],
                opacity=0.8,
            ),
            row=row,
            col=1,
        )
    if "afrr_capacity_down" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * engagement_df["afrr_capacity_down"],
                name="aFRR capacity engagement (down) [kW]",
                marker_color=color_map.get("FLEX", "grey"),
                base=convention * engagement_df["total"],
                opacity=0.8,
            ),
            row=row,
            col=1,
        )
    if "afrr_voluntary_up" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * (-engagement_df["afrr_voluntary_up"]),  # -afrr : .xlsx only >0 values
                name="aFRR voluntary engagement (up) [kW]",
                marker_color=color_map.get("FLEX", "grey"),
                base=convention * engagement_df["total"],
                opacity=0.8,
            ),
            row=row,
            col=1,
        )
    if "afrr_voluntary_down" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * engagement_df["afrr_voluntary_down"],
                name="aFRR voluntary engagement (down) [kW]",
                marker_color=color_map.get("FLEX", "grey"),
                base=convention * engagement_df["total"],
                opacity=0.8,
            ),
            row=row,
            col=1,
        )


def plot_congestions(
    row: int,
    fig: go.Figure,
    color_map: dict[str, str],
    convention: int,
    dates: pd.Series,
    min_power: float,
    max_power: float,
    asset_steps_power_df: pd.DataFrame,
    assets_df: pd.DataFrame,
    maingrid_serie: pd.Series,
    engagement_df: pd.DataFrame,
    diff: bool = False,
    legend_prefix: str = "",
) -> None:
    """
    Create the display of congestions for a site : min_power, max_power, all assets power_target, and eventually flex engagements, maingrid (+- flex)

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: go.Figure
    :param color_map: The color map used to display power targets
    :type color_map: dict[str,str]
    :param convention: If 1, the convention used is the consumer convention (same as Everest's convention). If -1, the convention used is the producer convention
    :type convention: int
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param min_power: The lower power limit for this site
    :type min_power: float
    :param max_power: The upper power limit for this site
    :type max_power: float
    :param asset_steps_power_df: The asset steps power data sheet pivoted for this site (index 'step_id', columns 'asset_id')
    :type asset_steps_power_df: pd.DataFrame
    :param assets_df: The assets data sheet with good stacking order for this site (index 'asset_id')
    :type assets_df: pd.DataFrame
    :param maingrid_serie: The maingrid series of this site (index 'step_id')
    :type maingrid_serie: pd.Series
    :param engagement_df: The engagement data sheet (index 'step_id'/'step_index' int)
    :type engagement_df: pd.DataFrame
    :param diff: If True, comparison mode is activated and display only the min and max power limits with the maingrid (+- flex eventually), defaults to False
    :type diff: bool, optional
    :param legend_prefix: The prefix added to the default legend, defaults to ""
    :type legend_prefix: str, optional
    """

    show_in_legend = True
    color_maingrid = color_map.get("MAINGRID", "grey")
    if diff and legend_prefix.startswith("Forced"):
        show_in_legend = "legendonly"
        color_maingrid = color_map.get("SPOT", "grey")

    fig.add_trace(
        go.Scatter(
            x=dates,
            y=convention * min_power * np.ones(len(asset_steps_power_df.index)),
            name=legend_prefix + "min_power [kW]",
            marker_color=color_map.get("CONGESTION", "grey"),
            line=dict({"dash": "dashdot"}),
            visible=show_in_legend,
        ),
        row=row,
        col=1,
    )
    fig.add_trace(
        go.Scatter(
            x=dates,
            y=convention * max_power * np.ones(len(asset_steps_power_df.index)),
            name=legend_prefix + "max_power [kW]",
            marker_color=color_map.get("CONGESTION", "grey"),
            line=dict({"dash": "dashdot"}),
            visible=show_in_legend,
        ),
        row=row,
        col=1,
    )

    if not diff:
        for asset_id in assets_df.index:
            fig.add_trace(
                go.Bar(
                    x=dates,
                    y=convention * asset_steps_power_df[asset_id],
                    name=asset_id,
                    marker_color=color_map.get(assets_df.loc[asset_id, "type"], "grey"),
                ),
                row=row,
                col=1,
            )
        if "fcr" in engagement_df.columns:
            fig.add_trace(
                go.Bar(
                    x=dates,
                    y=convention * engagement_df["fcr"],
                    name="FCR engagement (down) [kW]",
                    marker_color=color_map.get("FCR", "grey"),
                ),
                row=row,
                col=1,
            )
            fig.add_trace(
                go.Bar(
                    x=dates,
                    y=-convention * engagement_df["fcr"],
                    name="FCR engagement (up) [kW]",
                    marker_color=color_map.get("FCR", "grey"),
                ),
                row=row,
                col=1,
            )
        if "afrr_capacity_up" in engagement_df.columns and engagement_df["afrr_capacity_up"].sum() != 0:
            fig.add_trace(
                go.Bar(
                    x=dates,
                    y=convention * engagement_df["afrr_capacity_up"],
                    name="aFRR capacity engagement (up) [kW]",
                    marker_color=color_map.get("AFRR", "grey"),
                ),
                row=row,
                col=1,
            )
        if "afrr_capacity_down" in engagement_df.columns and engagement_df["afrr_capacity_down"].sum() != 0:
            fig.add_trace(
                go.Bar(
                    x=dates,
                    y=convention * engagement_df["afrr_capacity_down"],
                    name="aFRR capacity engagement (down) [kW]",
                    marker_color=color_map.get("AFRR", "grey"),
                ),
                row=row,
                col=1,
            )
        if "afrr_voluntary_up" in engagement_df.columns and engagement_df["afrr_voluntary_up"].sum() != 0:
            fig.add_trace(
                go.Bar(
                    x=dates,
                    y=convention * engagement_df["afrr_voluntary_up"],
                    name="aFRR voluntary engagement (up) [kW]",
                    marker_color=color_map.get("AFRR", "grey"),
                ),
                row=row,
                col=1,
            )
        if "afrr_voluntary_down" in engagement_df.columns and engagement_df["afrr_voluntary_down"].sum() != 0:
            fig.add_trace(
                go.Bar(
                    x=dates,
                    y=convention * engagement_df["afrr_voluntary_down"],
                    name="aFRR voluntary engagement (down) [kW]",
                    marker_color=color_map.get("AFRR", "grey"),
                ),
                row=row,
                col=1,
            )

    total_up = maingrid_serie.copy()
    total_down = maingrid_serie.copy()
    plot_maingrid = True
    if "fcr" in engagement_df.columns:
        total_up["power_target"] += engagement_df.loc[:, "fcr"]
        total_down["power_target"] -= engagement_df.loc[:, "fcr"]
        plot_maingrid = False
    if "afrr_capacity_down" in engagement_df.columns:
        total_down["power_target"] += engagement_df.loc[:, "afrr_capacity_down"]
        plot_maingrid = False
    if "afrr_capacity_up" in engagement_df.columns:
        total_up["power_target"] += engagement_df.loc[:, "afrr_capacity_up"]
        plot_maingrid = False
    if "afrr_voluntary_down" in engagement_df.columns:
        total_down["power_target"] += engagement_df.loc[:, "afrr_voluntary_down"]
        plot_maingrid = False
    if "afrr_voluntary_up" in engagement_df.columns:
        total_up["power_target"] += engagement_df.loc[:, "afrr_voluntary_up"]
        plot_maingrid = False
    if plot_maingrid:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=convention * maingrid_serie["power_target"],
                mode="lines+markers",
                name=legend_prefix + "Maingrid",
                marker_color=color_maingrid,
            ),
            row=row,
            col=1,
        )
    else:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=convention * total_down["power_target"],
                mode="lines+markers",
                name=legend_prefix + "Maingrid + flex down [kW]",
                marker_color=color_maingrid,
            ),
            row=row,
            col=1,
        )
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=convention * total_up["power_target"],
                mode="lines+markers",
                name=legend_prefix + "Maingrid + flex up [kW]",
                marker_color=color_maingrid,
            ),
            row=row,
            col=1,
        )

    exec("fig.update_layout(" + "yaxis%d" % (row * 2 - 1) + "=dict(ticksuffix=' kW', tickformat='digits'))")


def plot_congestions_by_site(
    rows: list[int],
    fig: go.Figure,
    color_map: dict[str, str],
    convention: int,
    dates: pd.Series,
    operation_steps_df: dict[str, pd.DataFrame],
    site_assets_df: pd.DataFrame,
    asset_steps_power_df: pd.DataFrame,
    assets_df: pd.DataFrame,
    engagement_df: pd.DataFrame,
    diff: bool = False,
    legend_prefix: str = "",
) -> None:
    """
    Create the display of congestions for all sites of the microgrid in subplots, with one subplot for each site

    :param rows: The rows of the subplots to fill in the figure
    :type rows: list[int]
    :param fig: The figure
    :type fig: go.Figure
    :param color_map: The color map used to display power targets
    :type color_map: dict[str,str]
    :param convention: If 1, the convention used is the consumer convention (same as Everest's convention). If -1, the convention used is the producer convention
    :type convention: int
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param operation_steps_df: The operation steps data sheet
    :type operation_steps_df: dict[str,pd.DataFrame]
    :param site_assets_df: The site assets data sheet with only the site assets
    :type site_assets_df: pd.DataFrame
    :param asset_steps_power_df: The asset steps power data sheet pivoted (index 'step_id', columns 'asset_id')
    :type asset_steps_power_df: pd.DataFrame
    :param assets_df: The assets data sheet with good stacking order (index 'asset_id')
    :type assets_df: pd.DataFrame
    :param engagement_df: The engagement data sheet (index 'step_id'/'step_index' int)
    :type engagement_df: pd.DataFrame
    :param diff: If True, comparison mode is activated and display only the min and max power limits with the maingrid (+- flex eventually), defaults to False
    :type diff: bool, optional
    :param legend_prefix: The prefix added to the default legend, defaults to ""
    :type legend_prefix: str, optional
    :rtype: None
    """

    for site_index, site_name in enumerate(site_assets_df["asset_id"].values):
        row = rows[site_index]
        min_power = max(
            site_assets_df["min_power"][site_assets_df["asset_id"] == site_name].values[0],
            max(-operation_steps_df["max_export_to_main_grid"]),
        )  # max bc <0 values
        max_power = min(
            site_assets_df["max_power"][site_assets_df["asset_id"] == site_name].values[0],
            min(operation_steps_df["max_import_from_main_grid"]),
        )

        site_e_asset_bool = []

        for asset_id in assets_df.index:
            asset_site = assets_df.loc[asset_id, "site"]
            site_e_asset_bool.append(
                not (asset_id.startswith("Buffer"))
                and not "HEAT" in asset_id
                and not "H2" in asset_id
                and asset_site == site_name
            )
        site_e_assets_df = assets_df.loc[site_e_asset_bool]
        site_assets_steps_power_df = asset_steps_power_df.loc[:, site_e_assets_df.index]

        # HARD-CODED
        # Ramp for Mopabloem CHP (hard-coded) in the model recomputed (the output is DispGenActivePower and not DispGenEffActivePower)
        if site_name == "Tranformer_2000KVA":
            for asset_id in assets_df.index:
                if asset_id == "CHP_1600kW":
                    for index_power in site_assets_steps_power_df["CHP_1600kW"].index[1:]:
                        if (
                            site_assets_steps_power_df.loc[index_power, "CHP_1600kW"] < 0.0
                            and site_assets_steps_power_df.loc[index_power - 1, "CHP_1600kW"] == 0.0
                        ):
                            site_assets_steps_power_df.loc[index_power, "CHP_1600kW"] = (
                                site_e_assets_df.loc[asset_id, "max_power"] / 2
                            )
                    if (
                        site_assets_steps_power_df.loc[1, "CHP_1600kW"] < 0
                        and assets_df.loc[asset_id, "initial_power"] >= 0
                    ):
                        site_assets_steps_power_df.loc[1, "CHP_1600kW"] = (
                            site_e_assets_df.loc[asset_id, "max_power"] / 2
                        )
                    # les premières puissances non nulles de la CHP par 778

        site_net_power_df = pd.DataFrame(site_assets_steps_power_df.sum(axis=1), columns=["power_target"])
        if diff:
            site_e_assets_df = pd.DataFrame()

        plot_congestions(
            row,
            fig,
            color_map,
            convention,
            dates,
            min_power,
            max_power,
            site_assets_steps_power_df,
            site_e_assets_df,
            site_net_power_df,
            engagement_df,
            diff,
            legend_prefix,
        )


def plot_imbalances(
    row: int,
    fig: go.Figure,
    color_map: dict[str, str],
    convention: int,
    dates: pd.Series,
    engagement_df: pd.DataFrame,
    maingrid_serie: pd.Series,
    operation_steps_output_df: dict[str, pd.DataFrame],
    storage_assets_df: pd.DataFrame,
    asset_steps_power_df: pd.DataFrame,
) -> None:
    """
    Create the display of the long term and day-ahead engagement, with the resulting total engagement, the maingrid and the imbalances

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: go.Figure
    :param color_map: The color map used to display energy market prices and market engagements
    :type color_map: dict[str,str]
    :param convention: If 1, the convention used is the consumer convention (same as Everest's convention). If -1, the convention used is the producer convention
    :type convention: int
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param engagement_df: The engagement data sheet (index 'step_id'/'step_index' int)
    :type engagement_df: pd.DataFrame
    :param maingrid_serie: The maingrid series (index 'step_id')
    :type maingrid_serie: pd.Series
    :param operation_steps_output_df: The operation steps output data sheet
    :type operation_steps_output_df: pd.DataFrame
    :param storage_assets_df: The storage soc steps data sheet (index 'step_id', columns 'asset_id')
    :type storage_assets_df: pd.DataFrame
    :param asset_steps_power_df: The asset steps power data sheet pivoted (index 'step_id', columns 'asset_id')
    :type asset_steps_power_df: pd.DataFrame
    :rtype: None
    """

    if "long_term" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * engagement_df["long_term"],
                name="Long term engagement [kW]",
                marker_color=color_map.get("LONG_TERM", "grey"),
            ),
            row=row,
            col=1,
        )
    if "day_ahead" in engagement_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=convention * engagement_df["day_ahead"],
                name="Day ahead engagement [kW]",
                marker_color=color_map.get("DAY_AHEAD", "grey"),
            ),
            row=row,
            col=1,
        )
    if "total" in engagement_df.columns:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=convention * engagement_df["total"],
                name="Total day ahead + long term engagement",
                marker_color=color_map.get("SPOT", "grey"),
            ),
            row=row,
            col=1,
        )
    if not (operation_steps_output_df["imbalance_power"].values[0] == "-Infinity"):
        if not maingrid_serie.empty:
            fig.add_trace(
                go.Scatter(
                    x=dates,
                    y=convention * maingrid_serie,
                    mode="lines+markers",
                    name="Maingrid",
                    marker_color=color_map.get("MAINGRID", "grey"),
                ),
                row=row,
                col=1,
            )
        fig.add_trace(
            go.Bar(
                x=dates,
                y=operation_steps_output_df["imbalance_power"],
                # y=(total_engagement - maingrid_df['power_target']),
                name="Imbalance [kW]",
                marker_color=color_map.get("SPOT", "grey"),
            ),
            row=row,
            col=1,
        )
    if operation_steps_output_df["imbalance_power"].values[0] == "-Infinity":
        fig.add_trace(
            go.Bar(
                x=dates,
                y=operation_steps_output_df["imbalance_not_CFD_power"],
                # y=(total_engagement - maingrid_df['power_target']),
                name="Imbalance not CFD power [kW]",
                marker_color=color_map.get("SPOT", "grey"),
            ),
            row=row,
            col=1,
        )
        net_storage = np.zeros(len(maingrid_serie))
        for asset_name in storage_assets_df.index:
            net_storage += asset_steps_power_df[asset_name]
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=convention * net_storage,
                name="Net storage",
                mode="lines+markers",
                marker_color=color_map.get("MAINGRID", "grey"),
            ),
            row=row,
            col=1,
        )
    exec("fig.update_layout(" + "yaxis%d" % (row * 2 - 1) + "=dict(ticksuffix=' kW', tickformat='digits'))")


def plot_soc(
    row: int,
    fig: go.Figure,
    color_map: dict[str, str],
    currency_unit: str,
    dates: pd.Series,
    storage_assets_df: pd.DataFrame,
    asset_steps_soc_df: pd.DataFrame,
    prices_df: pd.DataFrame,
    operation_steps_output_df: pd.DataFrame,
    diff: bool = False,
    legend_prefix: str = "",
) -> None:
    """
    Create the display of state of charge of storage assets and eventually the spot price

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: go.Figure
    :param color_map: The color map used to display energy market prices and states of charge
    :type color_map: dict[str,str]
    :param currency_unit: The currency unit symbol
    :type currency_unit: str
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param storage_assets_df: The storage soc steps data sheet (index 'step_id', columns 'asset_id')
    :type storage_assets_df: pd.DataFrame
    :param asset_steps_soc_df: The storage soc steps data sheet (index 'step_id', columns 'asset_id')
    :type asset_steps_soc_df: pd.DataFrame
    :param prices_df: The day-ahead, PPA and transport price data sheet (index 'step_index' int)
    :type prices_df: pd.DataFrame
    :param operation_steps_output_df: The operation steps output data sheet
    :type operation_steps_output_df: pd.DataFrame
    :param diff: If True, comparison mode is activated, display colors and legend adapted, defaults to False
    :type diff: bool, optional
    :param legend_prefix: The prefix added to the default legend, defaults to ""
    :type legend_prefix: str, optional
    :rtype: None
    """

    dash_styles = ["solid", "dot", "dash", "longdash", "dashdot", "longdashdot"]
    dash_id = 0

    if diff:
        fill_soc = None
        color_soc = color_map.get("SPOT", "grey")
    else:
        fill_soc = "tozeroy"
        color_soc = color_map.get("SOC", "grey")
    for asset_id in storage_assets_df.index:
        dash_id += 1
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=asset_steps_soc_df[asset_id],
                name=legend_prefix + asset_id + " target soc [%]",
                fill=fill_soc,
                line=dict({"dash": dash_styles[dash_id % len(dash_styles)]}),
                marker_color=color_soc,
            ),
            row=row,
            col=1,
        )
    if "day_ahead" in prices_df.columns and not diff and not prices_df["day_ahead"].sum() == 0:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=prices_df["day_ahead"] * 1000,
                name="Spot price [" + currency_unit + "/MWh]",
                marker_color=color_map.get("STORAGE", "grey"),
            ),
            row=row,
            col=1,
            secondary_y=True,
        )
    elif "ppa" in prices_df.columns and not diff:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=prices_df["ppa"] * 1000,
                name="PPA price [" + currency_unit + "/MWh]",
                marker_color=color_map.get("STORAGE", "grey"),
            ),
            row=row,
            col=1,
            secondary_y=True,
        )
    elif not operation_steps_output_df["electricity_price"].sum() == 0:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=operation_steps_output_df["electricity_price"] * 1000,
                name="Electricity price [" + currency_unit + "/MWh]",
                marker_color=color_map.get("STORAGE", "grey"),
            ),
            row=row,
            col=1,
            secondary_y=True,
        )
    exec(
        "fig.update_layout("
        + "yaxis%d" % (row * 2 - 1)
        + "=dict(ticksuffix=' %', range=[0,100]), "
        + "yaxis%d" % (row * 2)
        + "=dict(ticksuffix=' '+currency_unit+'/MWh', tickformat='digits'))"
    )


def plot_asset_availability(
    row: int,
    fig: go.Figure,
    color_map: dict[str, str],
    dates: pd.Series,
    assets_df: pd.DataFrame,
    asset_steps_availability_df: pd.DataFrame,
) -> None:
    """
    Create the display of all assets availability

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: go.Figure
    :param color_map: The color map used to display power targets
    :type color_map: dict[str,str]
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param assets_df: The assets data sheet with good stacking order (index 'asset_id')
    :type assets_df: pd.DataFrame
    :param asset_steps_availability_df: The asset availability steps data sheet pivoted (index 'step_id', columns 'asset_id')
    :type asset_steps_availability_df: pd.DataFrame
    """

    for asset_id in assets_df.index:
        fig.add_trace(
            go.Scatter(
                x=dates,
                y=asset_steps_availability_df[asset_id] * 100,
                name=asset_id + " availability [%]",
                marker_color=color_map.get(assets_df.loc[asset_id, "type"], "grey"),
            ),
            row=row,
            col=1,
        )
    exec("fig.update_layout(" + "yaxis%d" % (row * 2 - 1) + "=dict(ticksuffix=' %'))")


def plot_costs(
    row: int,
    fig: go.Figure,
    color_map_costs: dict[str, str],
    currency_unit: str,
    dates: pd.Series,
    input_data: dict[str, pd.DataFrame],
    output_data: dict[str, pd.DataFrame],
) -> None:
    """
    Create the display of all regular optimization costs and violations costs if provided in the output sheet VIOLATIONS_OUTPUT
    and eventually the long term engagements costs even if it is not an optimization cost

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: go.Figure
    :param color_map_costs: The color map used to display costs
    :type color_map_costs: dict[str,str]
    :param currency_unit: The currency unit symbol
    :type currency_unit: str
    :param dates: The series of datetime corresponding to the date and time of each optimization step (index 'step_id' int)
    :type dates: pd.Series
    :param input_data: The optimization input data
    :type input_data: dict[str,pd.DataFrame]
    :param output_data: The optimization output data
    :type output_data: dict[str,pd.DataFrame]
    :rtype: None
    """

    costs_df = output_data["COSTS"].set_index("step_id", drop=True)

    try:
        violations_df = (
            output_data["VIOLATIONS_OUTPUT"]
            .filter(items=["violation_type", "step_id", "violation_cost"])
            .set_index("step_id")
        )
        violations_df = violations_df.pivot_table(
            index="step_id", columns="violation_type", values="violation_cost", fill_value=0
        )
        for violation_type in violations_df.columns:
            costs_df[violation_type] = violations_df[violation_type]
        costs_df = costs_df.fillna(0)
    except:
        pass

    for cost in costs_df.columns:
        fig.add_trace(
            go.Bar(
                x=dates,
                y=costs_df[cost],
                name=cost,
                marker_color=color_map_costs.get(cost, "grey"),
            ),
            row=row,
            col=1,
        )

    long_term_costs_init_df = input_data["MARKET_ENGAGEMENTS"]
    long_term_costs_init_df = (
        long_term_costs_init_df[long_term_costs_init_df["type"] == "ELECTRICITY_LONG_TERM_AGREGATED_BIDS"]
        .filter(items=["step_index", "engagement", "price"])
        .set_index("step_index", drop=True)
    )
    if not long_term_costs_init_df.empty:
        long_term_costs_series = pd.Series()
        operation_df = input_data["OPERATION"].set_index("param_id").transpose()
        asset_step_duration = int(operation_df["asset_step_duration"]["param_val"])
        # step_multiplication_h = input_data['OPERATION_STEPS_LINK']['day_ahead_step'].value_counts().sort_index()
        for index, steps in input_data["OPERATION_STEPS_LINK"].iterrows():
            long_term_costs_series.at[index] = (
                long_term_costs_init_df.loc[steps["day_ahead_step"], "engagement"]
                * long_term_costs_init_df.loc[steps["day_ahead_step"], "price"]
                * asset_step_duration
                / 60
            )
            # / step_multiplication_h[steps['day_ahead_step']])
        fig.add_trace(
            go.Bar(
                x=dates,
                y=long_term_costs_series,
                name="long_term_costs (not in objective function)",
                marker_color=color_map_costs.get("long_term_costs", "grey"),
            ),
            row=row,
            col=1,
        )

    exec("fig.update_layout(" + "yaxis%d" % (row * 2 - 1) + "=dict(ticksuffix=' '+currency_unit))")


def plot_total_costs(
    row: int,
    fig: go.Figure,
    color_map_costs: dict[str, str],
    currency_unit: str,
    input_data: dict[str, pd.DataFrame],
    output_data: dict[str, pd.DataFrame],
) -> None:
    """_summary_

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: go.Figure
    :param color_map_costs: The color map used to display costs
    :type color_map_costs: dict[str,str]
    :param currency_unit: The currency unit symbol
    :type currency_unit: str
    :param input_data: The optimization input data
    :type input_data: dict[str,pd.DataFrame]
    :param output_data: The optimization output data
    :type output_data: dict[str,pd.DataFrame]
    :rtype: None
    """

    exec("fig.update_layout(" + "xaxis%d" % (row) + "=dict(type='category'))")
    exec("fig.update_layout(" + "yaxis%d" % (row * 2 - 1) + "=dict(ticksuffix=' " + currency_unit + "'))")

    costs_df = output_data["COSTS"].set_index("step_id", drop=True)
    costs = dict()
    for cost_name in costs_df.columns:
        exec("costs['" + cost_name + "'] = costs_df['" + cost_name + "'].sum()")

    try:
        day_ahead_trade_costs_series = output_data["COSTS"]["day_ahead_total_trade_costs"].copy()
        day_ahead_trade_costs_series.loc[day_ahead_trade_costs_series < 0] *= 0
        costs["day_ahead_trade_costs"] = day_ahead_trade_costs_series.sum()
        day_ahead_trade_revenues_series = output_data["COSTS"]["day_ahead_total_trade_costs"].copy()
        day_ahead_trade_revenues_series.loc[day_ahead_trade_revenues_series > 0] *= 0
        costs["day_ahead_trade_revenues"] = day_ahead_trade_revenues_series.sum()
    except:
        pass

    try:
        violations_df = (
            output_data["VIOLATIONS_OUTPUT"]
            .filter(items=["violation_type", "step_id", "violation_cost"])
            .set_index("step_id")
        )
        violations_df = violations_df.pivot_table(
            index="step_id", columns="violation_type", values="violation_cost", fill_value=0
        )
        for violation_type in violations_df.columns:
            costs[violation_type] = violations_df[violation_type].sum()
    except:
        pass

    long_term_costs = input_data["MARKET_ENGAGEMENTS"]
    long_term_costs = (
        long_term_costs[long_term_costs["type"] == "ELECTRICITY_LONG_TERM_AGREGATED_BIDS"]
        .filter(items=["step_index", "engagement", "price"])
        .set_index("step_index", drop=True)
    )
    if not long_term_costs.empty:
        costs["long_term_costs (not in objective function)"] = (
            long_term_costs["engagement"] * long_term_costs["price"]
        ).sum()

    color_map = dict()
    for cost_name in costs.keys():
        color_map[cost_name] = color_map_costs.get(cost_name, "grey")

    fig.add_trace(
        go.Bar(
            x=list(costs.keys()),
            y=list(costs.values()),
            marker_color=list(color_map.values()),
            showlegend=False,
        ),
        row=row,
        col=1,
    )


def plot_violations(row: int, fig: go.Figure, violations_df: pd.DataFrame) -> None:
    """
    Fill the violation subplot with a table containing all the output violation data sheet

    :param row: The subplot row position
    :type row: int
    :param fig: The figure
    :type fig: _type_
    :param violations_df: The output violation data sheet
    :type violations_df: pd.DataFrame
    """
    # values = [[violation.replace("_", " ") if isinstance(violation, str) else violation for violation in
    #            violations_df[k].tolist()] for k in violations_df.columns],

    fig.add_trace(
        go.Table(
            header=dict(values=list(violations_df.columns), font=dict(size=10), align="left"),
            cells=dict(
                values=[
                    [str(violation).replace("_", " ") for violation in violations_df[k].tolist()]
                    for k in violations_df.columns
                ],
                align="left",
            ),
        ),
        row=row,
        col=1,
    )
