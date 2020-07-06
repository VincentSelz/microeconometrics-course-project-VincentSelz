"""Functions for use in the method of Simulated Moments."""
from collections import OrderedDict

import pandas as pd
import respy as rp
import numpy as np
from auxiliary.overview import *
from linearmodels.panel import PanelOLS

def params_description(): ## TODO:
    """Description of the estimating parameters."""
    data = {'category':{
     'lambda':{'name': {'cond_corr_e2_prize','cond_corr_e2_e1', 'cond_corr_e2_e1timesprize','low_effort_low_prize', 'low_effort_high_prize','high_effort_low_prize','high_effort_high_prize'},
            'comment': {'correlation of e2 and prize, conditional on control effects',
                'correlation of e2 and e1, conditional on control effects',
                'correlation of e2 and e1 * prize, conditional on control effects',
                'effort conditional on low e2 and low prizes',
                'effort conditional on low e2 and high prizes',
                'effort conditional on low e2 and low prizes',
                'effort conditional on high e2 and high prizes'
                }
    },
    'std_lambda':{ 'name': {'effort_std','low_effort_prop','high_effort_prop', 'autocorrelation_l1', 'autocorrelation_l2', 'j_perc_cond_corr_e2_e1', 'j_perc_cond_corr_e2_e1timesprize'},
                'comment': {'standard deviation of effort', 'probability of low effort', 'probability of high effort', 'autocorrelation with lag 1', 'autocorrelation with lag 2', 'jth percentile of cond. correlation e1 and e2 of specific effects', 'jth percentile of cond. correlation e1 and e1 * prize of specific effects'}
    },
    'phi_pi':{ 'name': {'effort_std', 'low_effort_prop','high_effort_prop', 'round_change_std', 'j_perc_cond_corr_e2_prize'},
            'comment': {'standard deviation of effort', 'probability of low effort', 'probability of high effort', 'standard deviation of round-round change of effort', 'jth percentile of cond. correlation e1 and prize of specific effects'}
    },
    'phi_mu':{'name': {'effort_std', 'low_effort_prop','high_effort_prop', 'autocorrelation_l1', 'autocorrelation_l2', 'j_perc_cond_corr_e2_prize'},
            'comment': {'standard deviation of effort', 'probability of low effort', 'probability of high effort', 'autocorrelation with lag 1', 'autocorrelation with lag 2', 'jth percentile of cond. correlation e1 and prize of specific effects'}
    },
    'varphi_pi':{'name': {'effort_std', 'low_effort_prop','high_effort_prop', 'round_change_std', 'j_perc_cond_corr_e2_prize'},
                'comment': {'standard deviation of effort', 'probability of low effort', 'probability of high effort', 'standard deviation of round-round change of effort', 'jth percentile of cond. correlation e1 and prize of specific effects'}
    },
    'varphi_mu':{'name': {'effort_std', 'low_effort_prop','high_effort_prop', 'autocorrelation_l1', 'autocorrelation_l2', 'j_perc_cond_corr_e2_prize'},
                'comment': {'standard deviation of effort', 'probability of low effort', 'probability of high effort', 'autocorrelation with lag 1', 'autocorrelation with lag 2', 'jth percentile of cond. correlation e1 and prize of specific effects'}
    },
    'kappa':{'name': {'low_effort_low_prize', 'low_effort_high_prize','high_effort_low_prize','high_effort_high_prize'},
            'comment': {'effort conditional on low e2 and low prizes',
                    'effort conditional on low e2 and high prizes',
                    'effort conditional on low e2 and low prizes',
                    'effort conditional on high e2 and high prizes'
                    }
    },
    'b':{'name': {'period average'},
        'comment': {'average effort in period i'}
    },
    'delta':{'name': {'period average'},
            'comment': {'average effort in period i'}
    }
    }}
    df = pd.DataFrame(data, columns=['category', 'name', 'comment'])
    return df

def effort_std(df):
    """Standard deviation of the effort."""
    return df['e2'].std()

def df_autocorr(df, lag=1, axis=0):
    """Compute full-sample column-wise autocorrelation for a DataFrame."""
    return df.apply(lambda col: col.autocorr(lag), axis=axis)

def calc_autocorrelation(df, lag=1):
    """Compute average autocorrelation with specified lag."""
    corr_rounds = df.reset_index(inplace=False)
    corr_rounds = corr_rounds.pivot(index='period', columns='subject')['e2']
    return corr_rounds.apply(lambda col: col.autocorr(lag), axis=0).mean()

def period_average(df, period=1):
    """Compute period average effort."""
    return df.query(f'period == {period}')['e2'].mean()

def cond_corr_e2_prize(df):
    """Correlation of e2 and the prize after partialing out other effects."""
    df_resid = pd.DataFrame(columns=["e2_resid", "prize_resid"])
    for label in ['e2','prize']:
        column, formula = f'{label}_resid', f'{label}~e1+e1timesprize+tt2+tt3+tt4+tt5+tt6+tt7+tt8+tt9+tt10+EntityEffects'
        df_resid.loc[:,column] = PanelOLS.from_formula(formula, data=df).fit().resids
    return df_resid['e2_resid'].corr(df_resid['prize_resid'])

def cond_corr_e2_e1(df):
    """Correlation of e2 and the e1 after partialing out other effects."""
    df_resid = pd.DataFrame(columns=["e2_resid", "e1_resid"])
    for label in ['e2','e1']:
        column, formula = f'{label}_resid', f'{label}~prize+e1timesprize+tt2+tt3+tt4+tt5+tt6+tt7+tt8+tt9+tt10+EntityEffects'
        df_resid.loc[:,column] = PanelOLS.from_formula(formula, data=df).fit().resids
    return df_resid['e2_resid'].corr(df_resid['e1_resid'])

def cond_corr_e2_e1timesprize(df):
    """Correlation of e2 and the interaction of e1 and prize after partialing out other effects."""
    df_resid = pd.DataFrame(columns=["e2_resid", "e1timesprize_resid"])
    for label in ['e2','e1timesprize']:
        column, formula = f'{label}_resid', f'{label}~e1+prize+tt2+tt3+tt4+tt5+tt6+tt7+tt8+tt9+tt10+EntityEffects'
        df_resid.loc[:,column] = PanelOLS.from_formula(formula, data=df).fit().resids
    return df_resid['e2_resid'].corr(df_resid['e1timesprize_resid'])

def j_perc_cond_corr_e2_prize(df, perc=17):
    """J percentile of the correlation of e2 and the prize after partialing out other effects."""
    df_resid = pd.DataFrame(columns=['e2_resid', 'prize_resid'],index=df.index)
    for label in ['e2','prize']:
        column, formula = f'{label}_resid', f'{label}~e1+e1timesprize+TimeEffects'
        df_resid.loc[:,column] = PanelOLS.from_formula(formula, data=df).fit().resids
    df_resid.reset_index(inplace=True)
    dfs = dict()
    for sub in df_resid['subject'].unique():
        dfs[f'{sub}'] = df_resid.query(f'subject == {sub}')
    cond_corr = list()
    for key in dfs:
        cond_corr.append(dfs[key]['e2_resid'].corr(dfs[key]['prize_resid']))
    return np.percentile(cond_corr, perc)

def j_perc_cond_corr_e2_e1(df, perc=17):
    """J percentile of the correlation of e2 and e1 after partialing out other effects."""
    df_resid = pd.DataFrame(columns=['e2_resid', 'e1_resid'],index=df.index)
    for label in ['e2','e1']:
        column, formula = f'{label}_resid', f'{label}~prize+e1timesprize+TimeEffects'
        df_resid.loc[:,column] = PanelOLS.from_formula(formula, data=df).fit().resids
    df_resid.reset_index(inplace=True)
    dfs = dict()
    for sub in df_resid['subject'].unique():
        dfs[f'{sub}'] = df_resid.query(f'subject == {sub}')
    cond_corr = list()
    for key in dfs:
        cond_corr.append(dfs[key]['e2_resid'].corr(dfs[key]['e1_resid']))
    return np.percentile(cond_corr, perc)

def j_perc_cond_corr_e2_e1timesprize(df, perc=17):
    """J percentile of the correlation of e2 and the e1 * prize after partialing out other effects."""
    df_resid = pd.DataFrame(columns=['e2_resid', 'e1timesprize_resid'],index=df.index)
    for label in ['e2','e1timesprize']:
        column, formula = f'{label}_resid', f'{label}~e1+prize+TimeEffects'
        df_resid.loc[:,column] = PanelOLS.from_formula(formula, data=df).fit().resids
    df_resid.reset_index(inplace=True)
    dfs = dict()
    for sub in df_resid['subject'].unique():
        dfs[f'{sub}'] = df_resid.query(f'subject == {sub}')
    cond_corr = list()
    for key in dfs:
        cond_corr.append(dfs[key]['e2_resid'].corr(dfs[key]['e1timesprize_resid']))
    return np.percentile(cond_corr, perc)

def low_effort_low_prize(df):
    return df.query('e1 < 23 & prize < 1.33')['e2'].mean()

def low_effort_high_prize(df):
    return df.query('e1 < 23 & prize > 2.55')['e2'].mean()

def high_effort_low_prize(df):
    return df.query('e1 > 28 & prize < 1.33')['e2'].mean()

def high_effort_high_prize(df):
    return df.query('e1 > 28 & prize > 2.55')['e2'].mean()

def replace_nans(df):
    """Replace missing values in data."""
    return df.fillna(0)

def low_effort_prop(df):
    return df.query('e2 < 15')['e2'].count()/df['e2'].count()

def high_effort_prop(df):
    return df.query('e2 > 35')['e2'].count()/df['e2'].count()
