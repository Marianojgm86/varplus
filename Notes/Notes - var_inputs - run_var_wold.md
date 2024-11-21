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

$\tilde{\Omega} = (X'X + \bar{\Omega}^{-1})/I_{40} = (X'X)^{-1}$ (this comes from $A/B = A^{-1}B$)

$\tilde{\Omega}^{-1} = X'X + \bar{\Omega}^{-1} = X'X$

$\tilde{\Psi} = \tilde{\Omega}(X'Y + \bar{\Omega}^{-1}\bar{\Psi}) = (X'X)^{-1}(X'Y)$ -> OLS Estimator

$\tilde{\Psi}$ is then assigned as $B_{OLS}$

$\tilde{\Phi} = Y'Y + \bar{\Phi} + \bar{\Psi}'\bar{\Omega}^{-1}\bar{\Psi} - \tilde{\Psi}\tilde{\Omega}^{-1}\tilde{\Psi}$

$\tilde{\Phi} = Y'Y - \tilde{\Psi}\tilde{\Omega}^{-1}\tilde{\Psi}$

$\tilde{\Phi} = Y'Y - ((X'X)X'Y)(X'X)((X'X)X'Y)$

$\tilde{\Phi} = (\tilde{\Phi}'+\tilde{\Phi})*0.5$

$\tilde{\Phi}$ is then assigned as $\Sigma_{OLS}$

Draws from Posterior - For each Draw

1. $\Sigma_{draw}$: Take a random matrix from the inverse Wishart distribution with parameters $\tilde{\Phi}$ (Covariance Matrix) and $\tilde{\nu}$ (Degrees of freedom).
2. $chol(\Sigma_{draw})$ Get the Cholesky decomposition of the draw on step 1.
3. $B_{draw}$: Reduced Form coeficients matrix using the previous inputs: `<break>`
   $B_{draw} = chol(\Sigma_{draw})\otimes chol(\tilde{\Omega})*RV+ vec(\tilde{\Psi})$  Where $RV $ is a Random Normal Vector of size (40x10)x1.
   $B_{draw}$ is then reshaped to be a 40x10 matrix.
4. All Draws of $B$ and $\Sigma$ are then stored in $B^{draws}$ and $\Sigma^{draws}$.

Output of the function: [$B_{OLS}, \Sigma_{OLS}, B^{draws}, \Sigma^{draws}$]

#### OLS Wold IRFs

Impulse-Response Functions using the OLS Estimators

$\Sigma_u = \Sigma_{OLS}$ y $B = B_{OLS}$

Creates a Benchmark (arbitrary) Rotation $W = chol(\Sigma_u)$ para obtener las IRF (???)

IRF_Wold: Impulso-Respuesta from the Reduced-Form. Array of Size 10x10x250.

Recursion from page 26 Kilian & Luktepohl. 

$\Phi_0 = I_K$ `IRF_Wold(:,:,1) = eye(10)`

$\Phi_i = \sum_{j=1}^{i}\Phi_{i-j}A_{j}$

Here, we use `IRF_Wold(:,:,l+1)` for $\Phi_i$ and $B$ instead of A.

```
for l = 1:IRF_hor
    % Ref pagina 27 libro de Kilian y Lutkepohl
    if l < IRF_hor
        for j=1:min(l,n_lags)
            IRF_Wold(:,:,l+1) = IRF_Wold(:,:,l+1) + ... 
				B(1+(j-1)*n_y:j*n_y,:)'*IRF_Wold(:,:,l-j+1);
        end
    end
end
```

First creates an arrays of zeros `IRF_Wold = Zeros(10,10,250)` to store the 250 Reduced form IRF functions, one for each of the 250 horizonts, using the previous form.

##### Get IRFs

Using the Benchmark Rotation $chol(\Sigma_u)$ as the structural identification, they obtain the Structural IRFs.

Using the form in the page 111, Kilian & Luktepohl.

$\Theta_0 = \Phi_0 B_0^{-1} = I_K B_0^{-1} = B_0^{-1} $

$\Theta_1 = \Phi_1 B_0^{-1}$ 

$\Theta_2 = \Phi_2 B_0^{-1}$

and so on...

Here our $\Theta_i$ is `IRF_OLS(:,:,i_hor)` $\Phi_{i}$ is `IRF_Wold(:,:,i_hor) `and $B_0^{-1}$ corresponds to `W`

```
IRF_OLS = NaN(n_y,n_y,IRF_hor);
for i_hor = 1:IRF_hor
    IRF_OLS(:,:,i_hor) = IRF_Wold(:,:,i_hor) * W;
end
```

Then they do this same procedure for each draw from the posterior.

For each draw, 

1. Obtain $\Sigma_u$ from $\Sigma^{draws}$
2. Obtain B from $B^{draws}$
3. Get the Wold IRFs $\Phi_i$
4. Use the benchmark rotation $chol(\Sigma_u)$ to obtain the structural IRFs $\Theta_i$
5. Compute the percentiles (50, 16 and 84) from $\Theta$
6. Reorder for plots


##### Compute Second-Moments

VMA-implied variance-covariance matrix

In the code, given by 

$\Sigma_u = \sum\limits_{h=1}^{H}\Theta_h\Theta_h'$

This is the MSPE(h)?

Then they compute the correlations matrix

Then they compute the Frequency bands

Then they save the `IS_wold` structure and the `series_names` array into `wold_results.mat`

`IS_wold` contiene:

```
     Theta_OLS: [10×10×250 double] - Structural IRFs from the OLS estimator
        Theta: [10×10×250×1000 double] - Draws from the posterior BayEst
    Theta_med: [250×10×10 double] - Median from the posterior
     Theta_lb: [250×10×10 double] - Lower Bound (p16)
     Theta_ub: [250×10×10 double] - Upper Bound (p84)
          cov: [10×10 double] - Covariance Matrix (OLS)
         corr: [10×10 double] - Correlation Matrix (OLS)
     freq_var: [10×1 double] - Frequency Bands
```
