"""This module consists of some preliminary functions for data analysis."""

import pandas as pd
import seaborn as sns
import scipy.stats as stats
import matplotlib as plt
import matplotlib.pyplot as pyplt

def get_datasets():
    """Quickly get datasets necessary for replication.

    Function reads in stata-files, puts all column names in lower case and sets
    a MultiIndex with subject and period.

    Returns: Two datasets: One for the first movers and another for the second movers.
    """
    df_2 = pd.read_stata('data/paper_data/master_data.dta')
    df_1 = pd.read_stata('data/paper_data/master_data_FM.dta')
    df_2.columns = map(str.lower, df_2.columns)
    df_2 = df_2.set_index(['subject','period'])
    df_2_pref = df_2.drop(index=302)
    return df_1, df_2, df_2_pref


def effort_overview(df):
    """Gives overview over efforts.

    Function uses a DataFrame of the Second Movers, drops a subject that does not
    expend any effort over all periods and gives out an DataFrame with means, standard
    deviation and minimum and maximum for the respective period.

    Args: DataFrame

    Return: Dataframe with an overview of the effort choices for the respective round.
    """
    rslt = pd.DataFrame()
    for name, e in [('E1','e1'),('E2','e2')]:
        rslt['Mean '+name] = df.groupby('period')[e].mean()
        rslt['SD '+name] = df.groupby('period')[e].std()
        rslt['Min '+name] = df.groupby('period')[e].min().astype(int)
        rslt['Max '+name] = df.groupby('period')[e].max().astype(int)
    rslt = rslt[['Mean E1', 'SD E1','Mean E2', 'SD E2','Min E1','Min E2','Max E1','Max E2']]
    return rslt

def effort_chart(rslt):
    """Plots the Effort overview."""
    effort_plot = rslt[['Mean E1', 'Mean E2']].plot(title='Mean Effort per Period', figsize=(10, 5), kind='bar', yerr=rslt[['SD E1', 'SD E2']].values.T, alpha = 0.7, error_kw=dict(elinewidth=1, ecolor='k'))
    effort_plot.set_xlabel('Period')
    effort_plot.set_ylabel('Effort')
    return effort_plot

def effort_distr_per_round(df):
    """Plots the distribution of effort per round."""
    new = df.reset_index(inplace=False)
    for round in new['period'].unique():
        distr = new.query(f'period == {round}')['e2']
        fig, ax = pyplt.subplots()
        ax.hist(distr)
        ax.set_xlabel(f"Effort Round {round}")
        ax.set_ylabel("Frequency")
        pyplt.tight_layout()

def joint_effort(df):
    """Using the setup from lecture 4 to plot the joint distribution

    Args: Dataframe with columns e1 and e2.

    Return: Jointplot with Pearson R.
    """
    joint_effort = sns.jointplot("e1", "e2", df)
    # JointGrid has a convenience function
    joint_effort.set_axis_labels('x', 'y', fontsize=16)
    # or set labels via the axes objects
    joint_effort.ax_joint.set_xlabel('First Mover Effort')
    joint_effort.ax_joint.set_ylabel('Second Mover Effort')
    joint_effort.annotate(stats.pearsonr)
    return joint_effort
