"""Function used to get the params."""

import pandas as pd
import respy as rp
import numpy as np
from auxiliary.overview import *
from auxiliary.msm import *
from linearmodels.panel import PanelOLS

#### Naive versions. #####

def cost_of_effort(b, c, e2):
    ce = b * e2 + (c*e2^2)/2
    return ce

def convexity_param(kappa, delta, mu, pi):
    c = kappa + delta + mu + pi
    return c

def win_prob(e1, e2, gamma):
    p_win = (e2 - e2 + gamma)/(2 * gamma)
    return p_win

def expected_utility(p_win,prize, cost_of_effort, e2):
    eu = p_win * v + (1 - p_win)*0 - cost_of_effort(e2)
    return eu

def expected_utility_disappointment(p_win, gain, loss, ref, cost_of_effort, e2):
    eu = v + 1(if u >R)*gain*(u - R)+1(if v < R)*loss*(v - R) - cost_of_effort(e2)
    return eu

def ref_point(p_win):
    r = p_win * v + (1 - p_win)*0
    return r
