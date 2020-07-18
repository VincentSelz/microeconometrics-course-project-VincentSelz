"""This file lays the blueprint for a simulation implementation."""

import numpy as np
import pandas as pd
import respy as rp
import math as math

from auxiliary.overview import *
from auxiliary.msm import *

#Read in Datasets
_,_,df = get_datasets()
params = params_description()

# Define assisting functions
def weibull_draw(phi, var_phi):
    """One draw from a weibull distrbution with scale and scope parameter."""
    draw = phi * (-math.log(np.random.uniform()**(1/var_phi)))
    return draw

def win_prob(e2, e1):
    """Probability of winning the lottery."""
    p_win = (e2 - e1 + 50)/(100)
    return p_win

def ref_point(p_win, v):
    """Generates reference point."""
    r = p_win * v + (1 - p_win)*0
    return r

def simulation(df, params):
    """Simulate num_agents over 10 rounds.

    Parameters
    ----------------
    params: Pandas DataFrame with a Multiindex (category, name) contains parameter values.

    df: Pandas DataFrame with the relevant exogenous variables.

    Returns
    ---------------
    DataFrame: of the form of df, where e2 is updated with the simulated choices.

    """
    # Create sim dataset with exogenous inputs
    df_sim = df.copy()
    df_sim['e2'] = np.nan * len(df_sim)
    choices = 49
    for sub in df_sim.index.get_level_values('subject').unique():
        #Set params on subject level
        _lambda = params.loc['lambda','lambda']['value']+ params.loc['lambda','std_lambda']['value'] * np.random.normal()
        mu = weibull_draw(params.loc['cost_of_effort','phi_mu']['value'],params.loc['cost_of_effort','varphi_mu']['value'])
        for period in df_sim.index.get_level_values('period').unique():
            # Load params for cleaner code
            b = params.loc['cost_of_effort','b']['value']
            kappa = params.loc['cost_of_effort','kappa']['value']
            pi = weibull_draw(params.loc['cost_of_effort','phi_pi']['value'],params.loc['cost_of_effort','varphi_pi']['value'])
            # Set cost of effort for round and subject
            if period == 1:
                c = kappa + mu + pi
            else:
                c = kappa + params.loc['cost_of_effort',f'delta_{period}']['value'] + mu + pi
            choice_list = list()
            for choice in range(choices):
                # Cost of effort
                cost_effort = b * choice + (c * choice**2)/2
                # Win probablity
                p_win = win_prob(choice, df_sim.loc[sub,period]['e1'])
                utility = df_sim.loc[sub,period]['prize']*p_win - _lambda * df_sim.loc[sub,period]['prize']*p_win*(1-p_win) - cost_effort
                choice_list.append(utility)
            # Get the utility maximizing choice
            max_choice = choice_list.index(max(choice_list))
            df_sim['e2'].loc[sub,period] = max_choice
    return df_sim

def n_sims(df, params, calc_moments, empirical_moments, num_simulation=10, seed=1789):
    """This funcions runs the constructed simulation num_simulation times.

    In addition to running the simulation num_simulation times, it also constructs the
    simulated moments by using the mean of all simulated moments-

    Parameter
    ------------------------
    df: Pandas DataFrame that provides the relevant exogenous variables.
    params: Pandas DataFrame with a Multiindex (category, name) contains parameter values.
    calc_moments: list or dict with the functions to compute the moments.
    empirical_moments: dict or Pandas DataFrame is used to adjust indexing of simulated moments.
    Can be used when repurposing to criterion function.
    num_simulation: number of simulations
    seed: numpy random seed

    Return

    ---------------------------

    DataSeries with the simulated_moments in scientific notation.
    """
    np.random.seed(seed)
    # Transform inputs
    if type(calc_moments) == dict:
        calc_moments = dict_to_list(calc_moments)
    else:
        pass
    empirical_moments = pd.Series(empirical_moments)
    # Create empty dict
    simulated_moments = pd.Series(index=empirical_moments.index)
    for _ in range(num_simulation):
        moments_sample = list()
        df_sim = simulation(df, params)
        [moments_sample.append(func(df_sim)) for func in calc_moments]
        moments_sample = pd.Series(moments_sample, index=empirical_moments.index)
        simulated_moments = simulated_moments.add(moments_sample.div(num_simulation), fill_value=0)
    return simulated_moments
