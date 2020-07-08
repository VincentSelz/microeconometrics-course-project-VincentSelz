"""individual specific correlations of e2 with v conditional on Period."""

import numpy as np

from auxiliary.overview import *
from scipy.stats.stats import pearsonr

def get_resid(df, sub, column_name):
    int = df.loc[sub,:][f'{column_name}'].to_numpy()
    xr = np.stack((np.arange(1, 11),np.ones(10)),axis=0).T
    b = np.dot(np.linalg.inv(np.dot(xr.T,xr)),np.dot(xr.T,int))
    resid = np.subtract(int,np.dot(xr,b))
    resid = pd.Series(resid)
    return resid
