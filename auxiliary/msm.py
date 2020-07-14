"""Functions for use in the method of Simulated Moments."""
from collections import OrderedDict

import pandas as pd
import respy as rp
import numpy as np
from auxiliary.overview import *
from auxiliary.helper import *
from linearmodels.panel import PanelOLS

def params_description():
    data={'category': ['lambda','lambda', 'cost_of_effort', 'cost_of_effort', 'cost_of_effort',
    'cost_of_effort','cost_of_effort','cost_of_effort','cost_of_effort'],
    'name':['lambda','std_lambda', 'phi_pi', 'varphi_pi', 'phi_mu', 'varphi_mu',
    'kappa', 'b','delta'],
    'values':[np.nan]*9,
    'comment':['strength of disappointment aversion on average', 'standard deviation of strength of disappointment aversion',
    'unobserved differences in cost of effort functions that vary over rounds and individuals', 'unobserved differences in cost of effort functions that vary over rounds and individuals',
    'unobserved differences in cost of effort functions between individuals, constant over rounds', 'unobserved differences in cost of effort functions between individuals, constant over rounds',
    'common cost parameter','common cost parameter','round effects for round 2,...N']
    }
    df = pd.DataFrame(data, columns=['category', 'name','values', 'comment'])
    df.set_index(['category','name'],inplace=True)
    return df

def trial_values():
    data={
    'name':['lambda','std_lambda', 'phi_pi', 'varphi_pi', 'phi_mu', 'varphi_mu',
    'kappa', 'b','delta2','delta3','delta4','delta5','delta6','delta7','delta8','delta9','delta10'],
    'values':[2, 1.5,0.35,0.85,0.35,0.85,1.75,np.nan,0, 0, 0, 0, 0, 0, 0, 0,0]
    }
    df = pd.DataFrame(data, columns=['name','values'])
    return df


def moments_description():
    data={'category':['lambda','lambda','lambda','lambda','lambda', 'lambda', 'lambda','std_lambda',
    'std_lambda', 'std_lambda', 'std_lambda', 'std_lambda', 'std_lambda', 'std_lambda',
    'phi_pi', 'phi_pi', 'phi_pi', 'phi_pi', 'phi_pi',
    'phi_mu', 'phi_mu', 'phi_mu', 'phi_mu', 'phi_mu', 'phi_mu',
    'varphi_pi', 'varphi_pi', 'varphi_pi', 'varphi_pi', 'varphi_pi',
    'varphi_mu', 'varphi_mu', 'varphi_mu', 'varphi_mu', 'varphi_mu', 'varphi_mu',
    'kappa', 'kappa', 'kappa', 'kappa', 'b','delta'],
    'name': ['cond_corr_e2_prize','cond_corr_e2_e1', 'cond_corr_e2_e1timesprize',
    'low_effort_low_prize', 'low_effort_high_prize','high_effort_low_prize',
    'high_effort_high_prize', 'effort_std','low_effort_prop','high_effort_prop',
    'autocorrelation_l1', 'autocorrelation_l2', 'j_perc_cond_corr_e2_e1', 'j_perc_cond_corr_e2_e1timesprize',
    'effort_std', 'low_effort_prop','high_effort_prop', 'round_change_std', 'j_perc_cond_corr_e2_prize',
    'effort_std', 'low_effort_prop','high_effort_prop', 'autocorrelation_l1', 'autocorrelation_l2', 'j_perc_cond_corr_e2_prize',
    'effort_std', 'low_effort_prop','high_effort_prop', 'round_change_std', 'j_perc_cond_corr_e2_prize',
    'effort_std', 'low_effort_prop','high_effort_prop', 'autocorrelation_l1', 'autocorrelation_l2', 'j_perc_cond_corr_e2_prize',
    'low_effort_low_prize', 'low_effort_high_prize','high_effort_low_prize','high_effort_high_prize',
    'period average','period average'
    ],
    'values': [np.nan]*42,
    'comment':['correlation of e2 and prize, conditional on control effects',
        'correlation of e2 and e1, conditional on control effects',
        'correlation of e2 and e1 * prize, conditional on control effects',
        'effort conditional on low e2 and low prizes',
        'effort conditional on low e2 and high prizes',
        'effort conditional on low e2 and low prizes',
        'effort conditional on high e2 and high prizes',
        'standard deviation of effort', 'probability of low effort',
        'probability of high effort', 'autocorrelation with lag 1',
        'autocorrelation with lag 2',
        'jth percentile of cond. correlation e1 and e2 of specific effects',
        'jth percentile of cond. correlation e2 and e1 * prize of specific effects',
        'standard deviation of effort', 'probability of low effort',
        'probability of high effort', 'standard deviation of round-round change of effort',
        'jth percentile of cond. correlation e1 and prize of specific effects',
        'standard deviation of effort', 'probability of low effort',
        'probability of high effort', 'autocorrelation with lag 1',
        'autocorrelation with lag 2', 'jth percentile of cond. correlation e1 and prize of specific effects',
        'standard deviation of effort', 'probability of low effort',
        'probability of high effort', 'standard deviation of round-round change of effort',
        'jth percentile of cond. correlation e1 and prize of specific effects',
        'standard deviation of effort', 'probability of low effort',
        'probability of high effort', 'autocorrelation with lag 1',
        'autocorrelation with lag 2', 'jth percentile of cond. correlation e1 and prize of specific effects',
        'effort conditional on low e2 and low prizes',
        'effort conditional on low e2 and high prizes',
        'effort conditional on low e2 and low prizes',
        'effort conditional on high e2 and high prizes',
        'average effort in period i',
        'average effort in period i']
        }

    df = pd.DataFrame(data, columns=['name', 'comment'])
    df.set_index(['name'],inplace=True)
    df.drop_duplicates(inplace=True)
    return df

def replace_nans(df):
    """Replace missing values in data."""
    return df.fillna(0)

def effort_std(df):
    """Standard deviation of the effort."""
    return df['e2'].std()

def df_autocorr(df, lag=1, axis=0):
    """Compute full-sample column-wise autocorrelation for a DataFrame."""
    return df.apply(lambda col: col.autocorr(lag), axis=axis)

def calc_autocorrelation_lag1(df):
    """Compute average autocorrelation with specified lag."""
    corr_rounds = df.reset_index(inplace=False)
    corr_rounds = corr_rounds.pivot(index='period', columns='subject')['e2']
    return corr_rounds.apply(lambda col: col.autocorr(1), axis=0).mean()

def pooled_autocorr_lag1(df):
    """Compute the pooled autocorrelation with lag 1."""
    ds = df.query('period > 1')['e2']
    ds.reset_index(drop=True, inplace=True)
    ds_lag = df.query('period < 10')['e2']
    ds_lag.reset_index(drop=True, inplace=True)
    return ds.corr(ds_lag)

def pooled_autocorr_lag2(df):
    """Compute the pooled autocorrelation with lag 2."""
    ds = df.query('period > 2')['e2']
    ds.reset_index(drop=True, inplace=True)
    ds_lag = df.query('period < 9')['e2']
    ds_lag.reset_index(drop=True, inplace=True)
    return ds.corr(ds_lag)

def calc_autocorrelation_lag2(df):
    """Compute average autocorrelation with specified lag."""
    corr_rounds = df.reset_index(inplace=False)
    corr_rounds = corr_rounds.pivot(index='period', columns='subject')['e2']
    return corr_rounds.apply(lambda col: col.autocorr(2), axis=0).mean()

def round_change_std(df):
    """Compute standard deviation of round to round change."""
    corr_rounds = df.reset_index(inplace=False)
    corr_rounds = corr_rounds.pivot(index='period', columns='subject')['e2']
    round_changes = list()
    for sub in corr_rounds.columns:
        for i in corr_rounds.index:
            if i < 10:
                round_changes.append(corr_rounds[sub][i+1]-corr_rounds[sub][i])
            else:
                break
    rc = pd.Series(round_changes)
    return rc.std()

def period1_average(df):
    """Compute period average effort."""
    return df.query(f'period == {1}')['e2'].mean()

def period2_average(df):
    """Compute period average effort."""
    return df.query(f'period == {2}')['e2'].mean()

def period3_average(df):
    """Compute period average effort."""
    return df.query(f'period == {3}')['e2'].mean()

def period4_average(df):
    """Compute period average effort."""
    return df.query(f'period == {4}')['e2'].mean()

def period5_average(df):
    """Compute period average effort."""
    return df.query(f'period == {5}')['e2'].mean()

def period6_average(df):
    """Compute period average effort."""
    return df.query(f'period == {6}')['e2'].mean()

def period7_average(df):
    """Compute period average effort."""
    return df.query(f'period == {7}')['e2'].mean()

def period8_average(df):
    """Compute period average effort."""
    return df.query(f'period == {8}')['e2'].mean()

def period9_average(df):
    """Compute period average effort."""
    return df.query(f'period == {9}')['e2'].mean()

def period10_average(df):
    """Compute period average effort."""
    return df.query(f'period == {10}')['e2'].mean()

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

def perc17_cond_corr_e2_prize(df):
    """J percentile of the correlation of e2 and the prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        p_resid = get_resid(df, i, 'prize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(p_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.17, interpolation='lower')[0]

def perc33_cond_corr_e2_prize(df):
    """J percentile of the correlation of e2 and the prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        p_resid = get_resid(df, i, 'prize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(p_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.33, interpolation='lower')[0]

def perc50_cond_corr_e2_prize(df):
    """J percentile of the correlation of e2 and the prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        p_resid = get_resid(df, i, 'prize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(p_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.5, interpolation='lower')[0]

def perc66_cond_corr_e2_prize(df):
    """J percentile of the correlation of e2 and the prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        p_resid = get_resid(df, i, 'prize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(p_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.66, interpolation='lower')[0]

def perc83_cond_corr_e2_prize(df):
    """J percentile of the correlation of e2 and the prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        p_resid = get_resid(df, i, 'prize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(p_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.83, interpolation='lower')[0]

def perc17_cond_corr_e2_e1(df):
    """J percentile of the correlation of e2 and e1 after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1_resid = get_resid(df, i, 'e1')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.17, interpolation='lower')[0]

def perc33_cond_corr_e2_e1(df):
    """J percentile of the correlation of e2 and e1 after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1_resid = get_resid(df, i, 'e1')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.33, interpolation='lower')[0]

def perc50_cond_corr_e2_e1(df):
    """J percentile of the correlation of e2 and e1 after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1_resid = get_resid(df, i, 'e1')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.50, interpolation='lower')[0]

def perc66_cond_corr_e2_e1(df):
    """J percentile of the correlation of e2 and e1 after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1_resid = get_resid(df, i, 'e1')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.66, interpolation='lower')[0]

def perc83_cond_corr_e2_e1(df):
    """J percentile of the correlation of e2 and e1 after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1_resid = get_resid(df, i, 'e1')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.83, interpolation='lower')[0]

def perc17_cond_corr_e2_e1timesprize(df):
    """J percentile of the correlation of e2 and the e1 * prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1timesprize_resid = get_resid(df, i, 'e1timesprize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1timesprize_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.17, interpolation='lower')[0]

def perc33_cond_corr_e2_e1timesprize(df):
    """J percentile of the correlation of e2 and the e1 * prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1timesprize_resid = get_resid(df, i, 'e1timesprize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1timesprize_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.33, interpolation='lower')[0]

def perc50_cond_corr_e2_e1timesprize(df):
    """J percentile of the correlation of e2 and the e1 * prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1timesprize_resid = get_resid(df, i, 'e1timesprize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1timesprize_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.5, interpolation='lower')[0]

def perc66_cond_corr_e2_e1timesprize(df):
    """J percentile of the correlation of e2 and the e1 * prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1timesprize_resid = get_resid(df, i, 'e1timesprize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1timesprize_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.66, interpolation='lower')[0]

def perc83_cond_corr_e2_e1timesprize(df):
    """J percentile of the correlation of e2 and the e1 * prize after partialing out other effects."""
    corrs = list()
    for i in df['s2'].unique():
        e1timesprize_resid = get_resid(df, i, 'e1timesprize')
        e2_resid = get_resid(df, i, 'e2')
        corrs.append(e2_resid.corr(e1timesprize_resid))
        ds = pd.DataFrame(corrs, columns=['correlation'])
        ds.sort_values(by='correlation', inplace=True)
    return ds.quantile(0.83, interpolation='lower')[0]

def low_effort_low_prize(df):
    return df.query('e1 <= 23 & prize <= 1.33')['e2'].mean()

def low_effort_high_prize(df):
    return df.query('e1 <= 23 & prize >= 2.55')['e2'].mean()

def high_effort_low_prize(df):
    return df.query('e1 >= 28 & prize <= 1.33')['e2'].mean()

def high_effort_high_prize(df):
    return df.query('e1 >= 28 & prize >= 2.55')['e2'].mean()

def low_effort_prop(df):
    return df.query('e2 < 15')['e2'].count()/df['e2'].count()

def high_effort_prop(df):
    return df.query('e2 > 35')['e2'].count()/df['e2'].count()

def old_percentile_correlation(df):
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
    return np.percentile(cond_corr, 66)

def observed_moments(df):
    """Compute the observed moments."""
    observed_moments = {
        'effort_std': effort_std(df),
        'corr_round_lag1': pooled_autocorr_lag1(df),
        'corr_round_lag2': pooled_autocorr_lag2(df),
        'round_change_std': round_change_std(df),
        'mean_period_1': period1_average(df),
        'mean_period_2': period2_average(df),
        'mean_period_3': period3_average(df),
        'mean_period_4': period4_average(df),
        'mean_period_5': period5_average(df),
        'mean_period_6': period6_average(df),
        'mean_period_7': period7_average(df),
        'mean_period_8': period8_average(df),
        'mean_period_9': period9_average(df),
        'mean_period_10': period10_average(df),
        'cond_corr_e2_prize': cond_corr_e2_prize(df),
        'cond_corr_e2_e1': cond_corr_e2_e1(df),
        'cond_corr_e2_e1timesprize': cond_corr_e2_e1timesprize(df),
        'perc17_cond_corr_e2_prize': perc17_cond_corr_e2_prize(df),
        'perc33_cond_corr_e2_prize': perc33_cond_corr_e2_prize(df),
        'perc50_cond_corr_e2_prize': perc50_cond_corr_e2_prize(df),
        'perc66_cond_corr_e2_prize': perc66_cond_corr_e2_prize(df),
        'perc83_cond_corr_e2_prize': perc83_cond_corr_e2_prize(df),
        'perc17_cond_corr_e2_e1': perc17_cond_corr_e2_e1(df),
        'perc33_cond_corr_e2_e1': perc33_cond_corr_e2_e1(df),
        'perc50_cond_corr_e2_e1': perc50_cond_corr_e2_e1(df),
        'perc66_cond_corr_e2_e1': perc66_cond_corr_e2_e1(df),
        'perc83_cond_corr_e2_e1': perc83_cond_corr_e2_e1(df),
        'perc17_cond_corr_e2_e1timesprize': perc17_cond_corr_e2_e1timesprize(df),
        'perc33_cond_corr_e2_e1timesprize': perc33_cond_corr_e2_e1timesprize(df),
        'perc50_cond_corr_e2_e1timesprize': perc50_cond_corr_e2_e1timesprize(df),
        'perc66_cond_corr_e2_e1timesprize': perc66_cond_corr_e2_e1timesprize(df),
        'perc83_cond_corr_e2_e1timesprize': perc83_cond_corr_e2_e1timesprize(df),
        'low_effort_low_prize': low_effort_low_prize(df),
        'low_effort_high_prize': low_effort_high_prize(df),
        'high_effort_low_prize': high_effort_low_prize(df),
        'high_effort_high_prize': high_effort_high_prize(df),
        'low_effort_prop': low_effort_prop(df),
        'high_effort_prop': high_effort_prop(df)
        }
    return observed_moments

def get_weighting_matrix(
    data,
    empirical_moments,
    calc_moments,
    n_bootstrap_samples,
    n_observations_per_sample,
    replace_missing_variances=None,
):
    """ Computes a diagonal weighting matrix for estimation with msm. Weights are the
    inverse bootstrap variances of the observed sample moments."""
    # Seed for reproducibility.
    np.random.seed(47828324)
    flat_empirical_moments = rp.get_flat_moments(empirical_moments)
    index_base = data.index.get_level_values("Identifier").unique()
    calc_moments = _harmonize_input(calc_moments)
    # Create bootstrapped moments.
    moments_sample = []
    for _ in range(n_bootstrap_samples):
        ids_boot = np.random.choice(
            index_base, n_observations_per_sample, replace=False
        )
        moments_boot = [func(data.loc[ids_boot]) for func in calc_moments]
        flat_moments_boot = rp.get_flat_moments(moments_boot)
        flat_moments_boot = flat_moments_boot.reindex_like(flat_empirical_moments)
        moments_sample.append(flat_moments_boot)

    # Compute variance for each moment and construct diagonal weighting matrix.
    moments_var = np.array(moments_sample).var(axis=0)

    # The variance of missing moments is nan. Unless a repalcement variance is
    # specified, their inverse variance will be set to 0.
    if replace_missing_variances is None:
        diagonal = moments_var ** (-1)
        diagonal = np.nan_to_num(diagonal, nan=0)
        weighting_matrix = np.diag(diagonal)
    else:
        moments_var = np.nan_to_num(moments_var, nan=replace_missing_variances)
        diagonal = moments_var ** (-1)
        weighting_matrix = np.diag(diagonal)

    # Checks weighting matrix.
    if np.isnan(weighting_matrix).any() or np.isinf(weighting_matrix).any():
        raise ValueError("Weighting matrix contains NaNs or infinite values.")

    return weighting_matrix
