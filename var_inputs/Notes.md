# Notes on codes - VAR_INPUTS folder

## Code: run_var_wold.m

Wold shocks IRFs - Caravello, McKay and Wolf 2024

### Housekeeping

Chunk of code to set paths (kind of disorganized)

### Data

Reads as a Table from `'_data_cmw.csv'` , Then it converts it into an array (??)

Data in the file - sample: 1954-2023 in quarters:

They use 10 (transformed) series:

- gdp - Output
- unemp - Unemployment
- ffr - Federal Funds Rate
- infl - Inflation
- inv - Investmet
- cons - Consumption
- lab - Hours
- lab_share - Labour Share
- lab_prod - Labour Productivity
- tfp - TPF

### General Settings for VAR

Ordering (should not matter):

`vardata = [unemp gdp inv cons lab tfp lab_prod lab_share infl ffr];`

Lags = 4

No constant (demeaned and detrended data)

IRF Horizon `IRF_hor`: 250

Draws for Bayesian estimation `n_draws`: 1000

Number of variables `n_y`: 10

This is a $VAR(4)$ with $k=10$

### Reduced-Form $VAR$ Estimation

They do both, OLS and Bayesian estimation. This is done within the `bvar_fn`that has as inputs: the data `varadata`, number of lags `n_lags`, `constant`, and `n_draws`. The outputs are the `B_draws`, `Sigma_draws`, `B_OLS` and `Sigma_OLS`

Sigma is the Variance-Covariance Matrix $\Sigma_u$

B is the 

#### Bvar_fn

n_var -> 10. Number of endogenous variables.

m -> 40. Number of exogenous variables (10 variables, 4 Lags)

T - Sample Size -> 236

$Y$ - T x n_var  (236x10) matrix of observations

X - T x nvar*nlags (236x40) matrix of regressors (no constant)

$VAR$ model of the type

$Y = c + BX + U$, with $Y = y_t$ and $X =y_{t-1}$

##### Prior and Posterior for Reduced Form Parameters

Prior

```
nnuBar              = 0;
OomegaBarInverse    = zeros(m);
PpsiBar             = zeros(m,n_var);
PphiBar             = zeros(n_var);
```

$\bar{\nu}=0$

$\bar{\Omega}^{-1}=0_{40x40}$

$\bar{\Psi}=0_{40x10}$

$\bar{\Phi} = 0_{10x10}$

Posterior

```
nnuTilde            = T +nnuBar; %T =236
OomegaTilde         = (X'*X  + OomegaBarInverse)\eye(m);
OomegaTildeInverse  =  X'*X  + OomegaBarInverse;
PpsiTilde           = OomegaTilde*(X'*Y + OomegaBarInverse*PpsiBar);
PphiTilde           = Y'*Y + PphiBar + PpsiBar'*OomegaBarInverse*PpsiBar - PpsiTilde'*OomegaTildeInverse*PpsiTilde;
PphiTilde           = (PphiTilde'+PphiTilde)*0.5;
```

$\tilde{\nu} = T + \bar{\nu} = 236 + 0 = 236$

$\tilde{\Omega} = (X'X + \bar{\Omega}^{-1})/I_{40} = X'X$

$\tilde{\Omega}^{-1} = X'X + \bar{\Omega}^{-1} = X'X$

$\tilde{\Psi} = \tilde{\Omega}(X'Y + \bar{\Omega}^{-1}\bar{\Psi}) = X'X(X'Y)$ -> OLS Estimator?? OLS estimator should be $(X'X)^{-1}X'Y$

$\tilde{\Psi}$ is then assigned as $B_{OLS}$

$\tilde{\Phi} = Y'Y + \bar{\Phi} + \bar{\Psi}'\bar{\Omega}^{-1}\bar{\Psi} - \tilde{\Psi}\tilde{\Omega}^{-1}\tilde{\Psi}$

$\tilde{\Phi} = Y'Y - \tilde{\Psi}\tilde{\Omega}^{-1}\tilde{\Psi}$

$\tilde{\Phi} = Y'Y - ((X'X)X'Y)(X'X)((X'X)X'Y)$

$\tilde{\Phi} = (\tilde{\Phi}'+\tilde{\Phi})*0.5$

$\tilde{\Phi}$ is then assigned as $\Sigma_{OLS}$

Draws from Posterior - For each Draw

Take a random matrix from the inverse Wishart distribution with parameters $\tilde{\Phi}$ (Covariance Matrix) and $\tilde{\nu}$ (Degrees of freedom)
