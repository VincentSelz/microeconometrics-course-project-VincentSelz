"""This module consists of some preliminary functions for data analysis."""

import pandas as pd

def get_datasets():
    """Quickly get datasets necessary for replication.



    Returns: Two datasets: One for the first movers and another for the second movers.
    """
    df_2 = pd.read_stata('data/paper_data/master_data.dta')
    df_1 = pd.read_stata('data/paper_data/master_data_FM.dta')
    df_2.columns = map(str.lower, df_2.columns)
    df_2 = df_2.set_index(['subject','period'])
    df_2_pref = df_2.drop(index=302)
    return df_1, df_2, df_2_pref


def effort_overview(df_2):
    """Gives overview over efforts.

    Function uses a DataFrame of the Second Movers, drops a subject that does not
    expend any effort over all periods and gives out an DataFrame with means, standard
    deviation and minimum and maximum for the respective period.

    Args: DataFrame

    Return: Dataframe with an overview of the effort choices for the respective round.
    """
    rslt = pd.DataFrame()
    for name, e in [('E1','e1'),('E2','e2')]:
        rslt['Mean '+name] = df_2_pref.groupby('period')[e].mean()
        rslt['SD '+name] = df_2_pref.groupby('period')[e].std()
        rslt['Min '+name] = df_2_pref.groupby('period')[e].min().astype(int)
        rslt['Max '+name] = df_2_pref.groupby('period')[e].max().astype(int)
    rslt = rslt[['Mean E1', 'SD E1','Mean E2', 'SD E2','Min E1','Min E2','Max E1','Max E2']]
    return rslt
