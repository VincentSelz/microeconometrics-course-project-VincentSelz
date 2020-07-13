# Replication of "A Structural Analysis of Disappointment Aversion in a Real Effort Competition"

![Continuous Integration](https://github.com/HumanCapitalAnalysis/microeconometrics-course-project-VincentSelz/workflows/Continuous%20Integration/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/HumanCapitalAnalysis/microeconometrics-course-project-VincentSelz/master?urlpath=https%3A%2F%2Fgithub.com%2FHumanCapitalAnalysis%2Fmicroeconometrics-course-project-VincentSelz%2Fblob%2Fmaster%2FProject-VincentSelz.ipynb)
<a href="https://nbviewer.jupyter.org/github/HumanCapitalAnalysis/microeconometrics-course-project-VincentSelz/blob/master/Project-VincentSelz.ipynb"
   target="_parent">
   <img align="center"
  src="https://raw.githubusercontent.com/jupyter/design/master/logos/Badges/nbviewer_badge.png"
      width="109" height="20"></a>


In the notebook [Project-VincentSelz.ipynb](https://github.com/HumanCapitalAnalysis/microeconometrics-course-project-VincentSelz/blob/master/Project-VincentSelz.ipynb), I replicate the core findings of the following paper:

* Gill, David, and Victoria Prowse. 2012. [A Structural Analysis of Disappointment Aversion in a Real Effort Competition.](https://www.aeaweb.org/articles?id=10.1257/aer.102.1.469) *American Economic Review*, 102 (1): 469-503.

## Project overview

### Paper

Gill and Prowse (2012) use a sequential real effort tournament to test experimentally whether agents exhibit disappointment aversion. They find significant evidence for an discouragement effect and use the Method of Simulated Moments to estimate the strength of disappointment aversion on average and investigate heterogeneity.

### Contribution

My contribution consists of replicating the reduced form results and adding visualization to the data. For their analysis, the authors use Stata and Matlab. I am using python, yet if necessary, R is used for the replication. In fact, the regression packages in python do not print out the same results as the R and Stata output.

The main result of the paper - their structural estimation, I attempt to replicate as well.


<a href="https://nbviewer.jupyter.org/github/HumanCapitalAnalysis/template-course-project/blob/master/example_project.ipynb"
   target="_parent">
   <img align="center"
  src="https://raw.githubusercontent.com/jupyter/design/master/logos/Badges/nbviewer_badge.png"
      width="109" height="20">
</a>
<a href="https://mybinder.org/v2/gh/HumanCapitalAnalysis/template-course-project/master?filepath=example_project.ipynb"
    target="_parent">
    <img align="center"
       src="https://mybinder.org/badge_logo.svg"
       width="109" height="20">
</a>

## Reproducibility

To ensure full reproducibility of your project, please try to set up a [Travis CI](https://travis-ci.org) as your continuous integration service. An introductory tutorial for [conda](https://conda.io) and [Travis CI](https://docs.travis-ci.com/) is provided [here](https://github.com/HumanCapitalAnalysis/template-course-project/blob/master/tutorial_conda_travis.ipynb). While not at all mandatory, setting up a proper continuous integration workflow is an extra credit that can improve the final grade.

[![Build Status](https://travis-ci.org/HumanCapitalAnalysis/template-course-project.svg?branch=master)](https://travis-ci.org/HumanCapitalAnalysis/template-course-project)

In some cases you might not be able to run parts of your code on  [Travis CI](https://travis-ci.org) as, for example, the computation of results takes multiple hours. In those cases you can add the result in a file to your repository and load it in the notebook. See below for an example code.

```python
# If we are running on TRAVIS-CI we will simply load a file with existing results.
if os.environ['TRAVIS']:
  rslt = pkl.load(open('stored_results.pkl', 'br'))
else:
  rslt = compute_results()

# Now we are ready for further processing.
...
```

However, if you decide to do so, please be sure to provide an explanation in your notebook explaining why exactly this is required in your case.

## Structure of notebook

A typical project notebook has the following structure:

* presentation of baseline article with proper citation and brief summary

* using causal graphs to illustrate the authors' identification strategy

* replication of selected key results

* critical assessment of quality

* independent contribution, e.g. additional external evidence, robustness checks, visualization

There might be good reason to deviate from this structure. If so, please simply document your reasoning and go ahead. Please use the opportunity to review other student projects for some inspirations as well.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/HumanCapitalAnalysis/template-course-project/blob/master/LICENSE)
[![Continuous Integration](https://github.com/HumanCapitalAnalysis/template-course-project/workflows/Continuous%20Integration/badge.svg)](https://github.com/HumanCapitalAnalysis/template-course-project/actions)
