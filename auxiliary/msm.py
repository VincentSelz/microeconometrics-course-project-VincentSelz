"""Functions for use in the method of Simulated Moments."""
from collections import OrderedDict

import pandas as pd
import respy as rp
from auxiliary.overview import *

def moments_description():
    """Description of the estimating moments."""
    data = {
    'Moment':[r'$SD(e_{2,n,r})$',
    r'$Prob(e_{2,n,r}<15); Prob(e_{2,n,r}>35)$',
    r'$SD(e_{2,n,r}-e_{2,n,r-1})$',
    r'$Corr(e_{2,n,r},e_{2,n,r-1}; e_{2,n,r},e_{2,n,r-2})$',
    r'$Mean(e_{2,n,r})$ for round r in 1,...,10',
    r'$Corr(e_{2,n,r},v_{n,r} \vert e_{1,n,r},e_{1,n,r}v_{n,r},RD,FE)$',
    r'$Corr(e_{2,n,r},e_{1,n,r} \vert v_{n,r},e_{1,n,r}v_{n,r},RD,FE)$',
    r'$Corr(e_{2,n,r},v_{n,r}e_{1,n,r} \vert e_{1,n,r},v_{n,r},RD,FE)$',
    r'$Pc_{j}Corr_{n}(e_{2,n,r},v_{n,r} \vert e_{1,n,r},e_{1,n,r}v_{n,r},RT)$ for j=17,33,50,66,83',
    r'$Pc_{j}Corr_{n}(e_{2,n,r},e_{1,n,r}\vertv_{n,r},e_{1,n,r}v_{n,r},RT)$ for j=17,33,50,66,83',
    r'$Pc_{j}Corr_{n}(e_{2,n,r},v_{n,r}e_{1,n,r}\verte_{1,n,r},v_{n,r},RT)$ for j=17,33,50,66,83',
    r'$Mean(e_{2,n,r} \vert e_{1,n,r} < 23 \cap v_{n,r} < 1.33)$',
    r'$Mean(e_{2,n,r} \vert e_{1,n,r} < 23 \cap v_{n,r} > 2.55)$',
    r'$Mean(e_{2,n,r} \vert e_{1,n,r} > 28 \cap v_{n,r} < 1.33)$',
    r'$Mean(e_{2,n,r} \vert e_{1,n,r} > 23 \cap v_{n,r} > 2.55)$',
    ],
    'Description':['Standard deviation of Second Mover effort',
    'Proportions of Second Mover efforts below 15 and above 35',
    'Standard deviation of the round on round change in Second Mover effort',
    '1st and 2nd order autocorrelations in Second Mover effort',
    'Round specific means of Second Mover effort',
    'Correlation between Second Mover effort and the prize after partialing out linear additive effects of First Mover effort, First Mover effort interacted with the prize, round dummies, and Second Mover specific fixed effects',
    'Correlation between Second Mover effort and First Mover effort after partialing out linear additive effects of the prize, First Mover effort interacted with the prize, round dummies, and Second Mover specific fixed effects',
    'Correlation between Second Mover effort and First Mover effort interacted with the prize after partial ing out linear additive effects of First Mover effort, the prize, round dummies, and Second Mover specific fixed effects',
    'jth percentile of the Second Mover specific correlation between Second Mover effort and the prize after partialing out linear additive effects of First Mover effort, First Mover effort interacted with the prize, and a linear round trend',
    'jth percentile of the Second Mover specific correlation between Second Mover effort and First Mover effort after partialing out linear additive effects of the prize, First Mover effort interacted with the prize, and a linear round trend',
    'jth percentile of the Second Mover specific correlation between Second Mover effort and First Mover effort interacted with the prize after partial ing out linear additive effects of First Mover effort the prize, and a linear round trend',
    'Mean of Second Mover effort conditional on low First Mover effort and low prize',
    'Mean of Second Mover effort conditional on low First Mover effort and high prize',
    'Mean of Second Mover effort conditional on high First Mover effort and low prize',
    'Mean of Second Mover effort conditional on high First Mover effort and high prize'
    ],
    'Primarily identifying': [r'$\phi_{\pi},\phi_{\mu},\varphi_{\pi},\varphi_{\mu},\sigma_{\lambda}$',
    r'$\phi_{\pi},\phi_{\mu},\varphi_{\pi},\varphi_{\mu},\sigma_{\lambda}$',
    r'$\phi_{\pi}, \varphi_{\pi}$',
    r'$\phi_{\mu}, \varphi_{\mu}, \sigma_{\lambda}$',
    r'$b, \delta_{r}$ for r = 2,...,10',
    r'$\kappa$',
    r'$\tilde \lambda_{2}$',
    r'$\tilde \lambda_{2}$',
    r'$\phi_{\pi},\phi_{\mu},\varphi_{\pi},\varphi_{\mu}$',
    r'$\sigma_{\lambda}$',
    r'$\sigma_{\lambda}$',
    r'$\kappa, \tilde \lambda_{2}$',
    r'$\kappa, \tilde \lambda_{2}$',
    r'$\kappa, \tilde \lambda_{2}$',
    r'$\kappa, \tilde \lambda_{2}$']
    }
    df = pd.DataFrame (data, columns=['Moment','Description','Primarily identifying'])
    return df

def df_autocorr(df, lag=1, axis=0):
    """Compute full-sample column-wise autocorrelation for a DataFrame."""
    return df.apply(lambda col: col.autocorr(lag), axis=axis)

def observed_moments():

    # Load in Dataframes
    _, _, df = get_datasets()
    # Inititate Dataframe
    vector_moments = OrderedDict()
    vector_moments['effort_std'] = df['e2'].std()
    df.reset_index(inplace=True)
    # Compute Autocorrelation
    corr_rounds = df.pivot(index='period', columns='subject')['e2']
    for lag in [1,2]:
        vector_moments[f'corr_round_lag{lag}'] = df_autocorr(corr_rounds, lag=lag).mean()
    # Compute Period Average
    for period in df['period']:
        vector_moments[f'period_{period}'] = df.query(f'period == {period}')['e2'].mean()

    # Conditional means
    vector_moments['low_effort1_low_prize'] = df.loc[(df["e1"] < 23) & (df["prize"] < 1.33), "e2"].mean()
    vector_moments['low_effort1_high_prize'] = df.loc[(df["e1"] < 23) & (df["prize"] > 2.55), "e2"].mean()
    vector_moments['high_effort1_low_prize'] = df.loc[(df["e1"] > 28) & (df["prize"] < 1.33), "e2"].mean()
    vector_moments['high_effort1_high_prize'] = df.loc[(df["e1"] > 28) & (df["prize"] < 2.55), "e2"].mean()

    vector_moments['low_effort_prop'] = df.query('e2 < 15')['e2'].count()/df['e2'].count()
    vector_moments['high_effort_prop'] = df.query('e2 > 35')['e2'].count()/df['e2'].count()

    return vector_moments
