"""This module replicates Table 1 of the paper."""

import pandas as pd

def effort_overview(df_2):
    """Gives overview over efforts.

    Function uses a DataFrame of the Second Movers, drops a subject that does not
    expend any effort over all periods and gives out an DataFrame with means, standard
    deviation and minimum and maximum for the respective period.

    Args: DataFrame

    Return: Dataframe with an overview of the effort choices for the respective round.
    """
    df_2_pref = df_2.drop(index=302)
    rslt = pd.DataFrame()
    for name, e in [('E1','e1'),('E2','e2')]:
        rslt['Mean '+name] = df_2_pref.groupby('period')[e].mean().round(3)
        rslt['SD '+name] = df_2_pref.groupby('period')[e].std().round(3)
        rslt['Min '+name] = df_2_pref.groupby('period')[e].min().astype(int)
        rslt['Max '+name] = df_2_pref.groupby('period')[e].max().astype(int)
    rslt = rslt[['Mean E1', 'SD E1','Mean E2', 'SD E2','Min E1','Min E2','Max E1','Max E2']]
    return rslt
