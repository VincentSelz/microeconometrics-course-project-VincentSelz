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
    draw = phi * (-math.log(np.random.uniform()**(1/var_phi)))
    return draw

def win_prob(e2, e1):
    p_win = (e2 - e1 + 50)/(100)
    return p_win

def ref_point(p_win, v):
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
    DataFrame:

    """
    # Create sim dataset with exogenous inputs
    df_sim = df.loc[:,['e1','prize','e1timesprize','e2']]
    df_sim['e2_sim'] = np.nan * len(df_sim)
    choices = 49
    np.random.seed(435789237)
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
            df_sim['e2_sim'].loc[sub,period] = max_choice
    return df_sim
