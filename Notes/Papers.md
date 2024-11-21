# What can time series regressions tell us about policy counterfactuals

KcKay & Wolf 2023

In a general family of linearized structural macro models knowledge of the empirically estimable causal effects of contemporaneous and news shocks to the prevailing policy rule is sufficient to construct counterfactuals under alternative policy rules. 

*Policy shocks -* surprise deviations from a prevailing rule. Evidence in policy shocks can help macroeconomists learn about policy rule counterfactuals.

Existing work:

1. Christiano, Eichenbaum and Evans (1999) - "Lucas Program". Begin estimating causal effects of policy shocks in the data, then construct a micro-founded structural model that matches these effects, and trust the model as laboratory for predicting the effects of changes in policy rules. Robust to lucas critique. Model misspeficication.
2. Sims and Zha  (1995). relies only on estimated policy shocks. Economy is subjected to a new policy shock at each date $t$, with the shocks chosen so that $t-by-t$, the counterfactual policy rule holds. Does not require to commit to a particular model. Subject to Lucas critique. 

Proposed method: 

- Constructs policy counterfactuals using empirical evidence on *multiple distinct* policy shocks, rather than just a single one.
- Does not rely on a particular parametric structural model.
- For a family of models that nests many of those popular on the lucas program, yields counterfactuals robust to the critique.

**Identification Result:** for a relatively general family of macro models, the causal effects of the contemporaneous as well as news shocks to a given policy rule are sufficient to construct robust counterfactuals for alternative policy rules.

Core intuition: By subjecting the economy to multiple distinct policy shocks at date 0 (rather than a new single shock at every t), we are able to enforce the contemplated counterfactual policy rule not just *ex post* along the equilibrium path, but also *ex ante* in private-sector expectations. Doing so is eough to sidestep the Lucas critique. 

*I am not fully convinced about imposing different shocks in just one time period.* 

Identification result requires knowledge of the causal effects of a very large number of policy shocks, but the proposed empirical method can be applied in the empirically relevant case when access to only a couple of distinct shocks.

### Identification Result

Analysis built on a *general linear data -generating process* with one added restriction: Policy is allowed to affect private-sector **only** through the current and future expected path of the policy instrument (expected path of instument and equilibrium selection).

Why? Private sector only cares about the expected future path of the instrument, not wheter this path is systematic component of policy (the rule) or due to shocks to a given rule. 

*This makes sense most of the time.*

Observed data under some baseline policy rule subject to shocks -> with standard TS methods, estimates causal effects of these policy shocks -> predict how would a shock have propagated under some alternative policy rule. 

If the econometrician is able to estimate how contemporaneous shocks to the prevailing rule as well as news about deviations from that rule *al all futere horizons* affect the variables that enter the hypothesized counterfactual rule, then these estimates contain all the information needed to construct a counterfactual. We don't need to know any of the structural equations of the underlying model, including the prevailing rule. 

Since only the expected future path of the policy instrument matters, any given rule -characterized by the instrument path it implies- can equivalenty be synthesized by addin shocks to the baseline rule.

*This means that you can impose paths of the instrument, if you know the IRF functions. Not very novel...*

Additionally, given a loss function, we can leverage the same logic to also characterize *optimal* policy.

**Key model restrictions:** (i) Linearity and (ii) the way policy is allowed to shape private-sector behavior.

Linearity is a practical assumption, implies that the effects of policy changes are invariant to size, sign and state of the economy. Focus on Expected values. Cost: methodology can be used to compare cyclical stabilizacion policies (Taylor rule types), but ***less suited to study policies that alter the steady state** (changes in inflation target, for example).

### Empirical Strategy

Challenge: empirical evidence on causal effects of policy shocks is very limited.

to obtain the effects of *"any possible expected policy instrument path of length T",* we would need access to T disctint policy shocks that each imply differentially shaped impulse-response paths of the policy instument, allowing us to sapn all of $\R^T$.

Empirical evidence falls short of this idea. Work on identifying shocks like Romer & Romer are useful here.

Given estimates of the dynamic causal effects of a small number $n_s$ of policy shocks and their associated policy instrument paths, the identification result cannot be applied inmediately. 

Select a linear combinarion of date-0 shocks that enforces the desired counterfactual rule as well as possible. Since there are no ex post surprises ($t = 1, 2,...$) is robust to lucas critique. **WHAT**

### Applications

-> propagation of a contractionary investment-specific techonology shock under differen monetary policy rules.

They use two shocks series that imply different kinds of monetary news:

- Romer & Romer (2004): Relative transitory innovation.
- Gertler and Karadi (2015): more gradual rate change.

Get causal effects of this two to construct counterfactuals for alternative policy rules that:

1. Target output gap.
1. Enforce Taylor-type rule.
1. Peg the nominal rate of interest.
1. Target nominal GDP.
1. Miniiza a simple dual-mandate loss function.

### Literature

Identification results provide a bridge between micro-founded models and empirical strategy. Christiano, Eichenbaum and Evans (1999) and Sims and Zha (1995)

In structural models the estimand of the econometric strategy is not equal to the true policy rule counterfactual due expectational effects related to the future conduct of policy. Using multiple distinct policy shocks at date 0 circumvents this problem. ***How to make sense to date-0 shocks in a policy exercise?***

Leepr and Zha (2003) -> if the policy shocks required to implent Sims and Zha are small enough, the it may be credible to ignore expectational effects. ***This could be the case of analysis done within the same policy framework, with shocks that does not change the way agents form their expectations about policy.***

Other work on counterfactual policy analysis:

Beraja (2020): policy counterfactual without relying on particular parametric model. Stronger exclusion restriction in the non-policy block of the economy. Less evidence on policy news shocks. ***OJO CON ESTE PAPER***

Barnichon and Mesters (2021): used Policy shock IRFs to evaluate the optimality of and then improve upon a given policy decision. Focus on a single policy choice. 

Literature on *sufficient statistics* for counterfactual analysis:

- Chetty (2009)
- Arkolakis, Costinot and Rodriguez-clare (2012)
- **Nakamura and Steinsson (2018)**

The identification result reveals that across a broad class of models, the empirically esitmable causal effects of policy shocks are precisely such sufficient statistics. **OJO CON ESTO**

$\rightarrow$ **DIG DEEPER ON SUFFICIENT STATISTICS**

Methods for structural macroeconomic models: ***Equilibria in such models can be characterized by matrices of impulse-response funcions**. *

Conect this sequence-space representation to empirically estimable objects, like in:

- Guren, McKay, Nakamura and Steinsson (2021)
- Wolf (2020)

We aim to calculate policy counterfactuals directly from empirical evidence, ***forcing us to confront the fact that such evidence is limited.***

## From policy shocks to policy rule counterfactuals

Linearized perfect-foresight economy. 

Equilibrium dynamics of a linear model with uncertainty = solution to linearized perfect-foresight enviroment. 

The perfect-foresight transition paths $\rightarrow$ Impulse-response functions in the linearized economy with agreggate risk (*expected* transition paths).

#### Simple example

They use a three-equation New Keynesian Model. The method does not require knowledge of the underlying structural model, but the do it anyway.

Two kinds of distrurbances:

- $\varepsilon_t$ - Cost push shock, induces a MA(1) on inflation
- Policy Shocks:  $\nu_{l,t-l}$: where $\nu_{0,t}$ is a contemporaneous policy shock, and $\nu_{1,t-1}$ denotes a deviation from the policy rule at time $t$ announced at $t-1$ (*forward guidance?*) one-period *news shock*. 

Given a vector of time-0 shocks $\{\varepsilon_t, \nu_{0,0}, \nu_{1,0}\}$, a perfect-foresigth transition path -Impulse response function- consist of the paths $\{y_t, \pi_t, i_t\}$ such that the equations system holds at all $t= 1,2 , ...$

##### Identification Argument

The main identification result states that knowledge of the response of the macro agreggates to the cost-push shock and to the policy shocks (under the baseline rule), and nothing else about the structure of the economy, is sufficient to predict the counterfactual propagation of the shock $\varepsilon_t$ under the alternative rule (namely, the same rule with different parametrization).

Key idea -> choose time-0 policy shocks to the baseline rule in order to mimic the desired counterfactual rule.

Intuition underlying identification result: Since the private sector's decision only depend on the expected path of the policy instrument, it follows that it does not matter whether this path comes from about due the systematic conduc of policy or due to policy shocks. 

##### Informational Requirements

The identification result implies that, to predict policy rule counterfactuals, the econometrician does not need to know the structural equations of the economy; rather, *all she needs are the impulse responses to policy shocks*. **"all she needs"**

This argument relies on Knowledge of the dynamic causal effects of both the contemporaneous policy shock as well as the policy news shock. It is only with those two that we can actually enforce the counterfactual rule along the entire transition path. 

Under the approach of Sims and Zha, the counterfactual policy rule only holds ex post along the equilibrium transmition path, but not in ex ante expectation. ***How is this managed in the VAR-plus paper???***

To construct further, now we need to know the causal effects  of all policy shocks $\{\nu_{l,0}\}_{l=0}^{\infty}$
