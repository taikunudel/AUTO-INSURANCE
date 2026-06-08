# **Insurance Premium Prediction via Gradient Tree-Boosted Tweedie Compound Poisson Models** 

Yi Yang _[∗]_ , Wei Qian _[†]_ and Hui Zou _[‡]_ 

April 22, 2016 

## **Abstract** 

The Tweedie GLM is a widely used method for predicting insurance premiums. However, the structure of the logarithmic mean is restricted to a linear form in the Tweedie GLM, which can be too rigid for many applications. As a better alternative, we propose a gradient tree-boosting algorithm and apply it to Tweedie compound Poisson models for pure premiums. We use a profile likelihood approach to estimate the index and dispersion parameters. Our method is capable of fitting a flexible nonlinear Tweedie model and capturing complex interactions among predictors. A simulation study confirms the excellent prediction performance of our method. As an application, we apply our method to an auto insurance claim data and show that the new method is superior to the existing methods in the sense that it generates more accurate premium predictions, thus helping solve the adverse selection issue. We have implemented our method in a user-friendly R package that also includes a nice visualization tool for interpreting the fitted model. 

> _∗_ McGill University 

> _†_ Rochester Institute of Technology 

> _‡_ Corresponding author, zoux019@umn.edu, University of Minnesota 

1 

## **1 Introduction** 

One of the most important problems in insurance business is to set the premium for the customers (policyholders). In a competitive market, it is advantageous for the insurer to charge a fair premium according to the expected loss of the policyholder. In personal car insurance, for instance, if an insurance company charges too much for old drivers and charges too little for young drivers, then the old drivers will switch to its competitors, and the remaining policies for the young drivers would be underpriced. This results in the _adverse selection_ issue (Dionne et al., 2001): the insurer loses profitable policies and is left with bad risks, resulting in economic loss both ways. 

To appropriately set the premiums for the insurer’s customers, one crucial task is to predict the size of actual (currently unforeseeable) claims. In this paper, we will focus on modeling claim loss, although other ingredients such as safety loadings, administrative costs, cost of capital, and profit are also important factors for setting the premium. One difficulty in modeling the claims is that the distribution is usually highly right-skewed, mixed with a point mass at zero. Such type of data cannot be transformed to normality by power transformation, and special treatment on zero claims is often required. As an example, Figure 1 shows the histogram of an auto insurance claim data (Yip and Yau, 2005), in which there are 6,290 policy records with zero claims and 4,006 policy records with positive losses. 

The need for predictive models emerges from the fact that the expected loss is highly dependent on the characteristics of an individual policy such as age and motor vehicle record points of the policyholder, population density of the policyholder’s residential area, and age and model of the vehicle. Traditional methods used generalized linear models (GLM; Nelder and Wedderburn, 1972) for modeling the claim size (e.g. Renshaw, 1994; Haberman and Renshaw, 1996). However, the authors of the above papers performed their analyses on a subset of the policies, which have at least one claim. Alternative approaches have employed Tobit models by treating zero outcomes as censored below some cutoff points (Van de Ven and van Praag, 1981; Showers and Shotick, 1994), but these approaches rely on a normality assumption of the latent response. Alternatively, Jørgensen and de Souza (1994) and Smyth and Jørgensen (2002) used GLMs with a Tweedie distributed outcome to simultaneously model frequency and severity of insurance claims. They assume Poisson arrival of claims and gamma distributed amount for individual claims so that the size of the total claim amount 

2 

**==> picture [454 x 261] intentionally omitted <==**

**----- Start of picture text -----**<br>
0 2 4 6 8 10 12<br>Total Insurance Claim Amount (in $1000) Per Policy Year<br>6000<br>4000<br>Frequency<br>2000<br>0<br>**----- End of picture text -----**<br>


Figure 1: Histogram of the auto insurance claim data as analyzed in Yip and Yau (2005). It shows that there are 6290 policy records with zero total claims per policy year, while the remaining 4006 policy records have positive losses. 

follows a Tweedie compound Poisson distribution. Due to its ability to simultaneously model the zeros and the continuous positive outcomes, the Tweedie GLM has been a widely used method in actuarial studies (Mildenhall, 1999; Murphy et al., 2000; Peters et al., 2008). 

Despite of the popularity of the Tweedie GLM, a major limitation is that the structure of the logarithmic mean is restricted to a linear form, which can be too rigid for real applications. In auto insurance, for example, it is known that the risk does not monotonically decrease as age increases (Anstey et al., 2005). Although nonlinearity may be modeled by adding splines (Zhang, 2011), low-degree splines are often inadequate to capture the non-linearity in the data, while high-degree splines often result in the over-fitting issue that produces unstable estimates. Generalized additive models (GAM; Hastie and Tibshirani, 1990; Wood, 2006) overcome the restrictive linear assumption of GLMs, and can model the continuous variables by smooth functions estimated from data. The structure of the model, however, has to be determined _a priori_ . That is, one has to specify the main effects and interaction effects to be used in the model. As a result, misspecification of non-ignorable effects is likely to adversely affect prediction accuracy. 

3 

In this paper, we aim to model the insurance claim size by a nonparametric Tweedie compound Poisson model, and propose a gradient tree-boosting algorithm (TDboost henceforth) to fit this model. To our knowledge, before this work, there is no existing nonparametric Tweedie method available. Additionally, we also implemented the proposed method as an easy-to-use R package, which is publicly available. 

Gradient boosting is one of the most successful machine learning algorithms for nonparametric regression and classification. Boosting adaptively combines a large number of relatively simple prediction models called _base learners_ into an ensemble learner to achieve high prediction performance. The seminal work on the boosting algorithm called _AdaBoost_ (Freund and Schapire, 1997) was originally proposed for classification problems. Later Breiman (1998) and Breiman (1999) pointed out an important connection between the AdaBoost algorithm and a functional gradient descent algorithm. Friedman et al. (2000) and Hastie et al. (2009) developed a statistical view of boosting and proposed gradient boosting methods for both classification and regression. There is a large body of literature on boosting. We refer interested readers to B¨uhlmann and Hothorn (2007) for a comprehensive review of boosting algorithms. 

The TDboost model is motivated by the proven success of boosting in machine learning for classification and regression problems (Friedman, 2001, 2002; Hastie et al., 2009). Its advantages are threefold. First, the model structure of TDboost is learned from data and not predetermined, thereby avoiding an explicit model specification. Non-linearities, discontinuities, complex and higher order interactions are naturally incorporated into the model to reduce the potential modeling bias and to produce high predictive performance, which enables TDboost to serve as a benchmark model in scoring insurance policies, guiding pricing practice, and facilitating marketing efforts. Feature selection is performed as an integral part of the procedure. In addition, TDboost handles the predictor and response variables of any type without the need for transformation, and it is highly robust to outliers. Missing values in the predictors are managed almost without loss of information (Elith et al., 2008). All these properties make TDboost a more attractive tool for insurance premium modeling. On the other hand, we acknowledge that its results are not as straightforward as those from the Tweedie GLM model. Nevertheless, TDboost does not have to be regarded as a black box. It can provide interpretable results, by means of the partial dependence plots, and relative importance of the predictors. 

4 

The remainder of this paper is organized as follows. We briefly review the gradient boosting algorithm and the Tweedie compound Poisson model in Section 2 and Section 3, respectively. We present the main methodological development with implementation details in Section 4. In Section 5, we use simulation to show the high predictive accuracy of TDboost. As an application, we apply TDboost to analyze an auto insurance claim data in Section 6. 

## **2 Gradient Boosting** 

Gradient boosting (Friedman, 2001) is a recursive, nonparametric machine learning algorithm that has been successfully used in many areas. It shows remarkable flexibility in solving different loss functions. By combining a large number of base learners, it can handle higher order interactions and produce highly complex functional forms. It provides high prediction accuracy and often outperforms many competing methods, such as linear regression/classification, bagging (Breiman, 1996), splines and CART (Breiman et al., 1984). 

To keep the paper self-contained, we briefly explain the general procedures for the gradient boosting. Let **x** = ( _x_ 1 _, . . . , xp_ )[⊺] be a _p_ -dimensional column vector for the predictor variables and _y_ be the one-dimensional response variable. The goal is to estimate the optimal prediction function _F_[˜] ( _·_ ) that maps **x** to _y_ by minimizing the expected value of a loss function Ψ( _·, ·_ ) over the function class _F_ : 

**==> picture [162 x 24] intentionally omitted <==**

where Ψ is assumed to be differentiable with respect to _F_ . Given the observed data _{yi,_ **x** _i}[n] i_ =1[,][where] **[x]** _[i]_[=][(] _[x][i]_[1] _[, . . . , x][ip]_[)][⊺][,][estimation][of] _[F]_[˜][(] _[·]_[)][can][be][done][by][minimizing][the] empirical risk function 

**==> picture [297 x 34] intentionally omitted <==**

For the gradient boosting, each candidate function _F ∈F_ is assumed to be an ensemble of _M_ base learners 

**==> picture [318 x 35] intentionally omitted <==**

where _h_ ( **x** ; _**ξ**_[[] _[m]_[]] ) usually belongs to a class of some simple functions of **x** called base learners (e.g., regression/decision tree) with the parameter _**ξ**_ **[[]** _**[m]**_ **[]]** ( _m_ = 1 _,_ 2 _, · · · , M_ ). _F_[[0]] is a constant 

5 

scalar and _β_[[] _[m]_[]] is the expansion coefficient. Note that differing from the usual structure of an additive model, there is no restriction on the number of predictors to be included in each _h_ ( _·_ ), and consequently, high-order interactions can be easily considered using this setting. 

A forward stagewise algorithm is adopted to approximate the minimizer of (1), which builds up the components _β_[[] _[m]_[]] _h_ ( **x** ; _**ξ**_[[] _[m]_[]] ) ( _m_ = 1 _,_ 2 _, . . . , M_ ) sequentially through a gradientdescent-like approach. At each iteration stage _m_ ( _m_ = 1 _,_ 2 _, . . ._ ), suppose that the current estimate for _F_[˜] ( _·_ ) is _F_[ˆ][[] _[m][−]_[1]] ( _·_ ). To update the estimate from _F_[ˆ][[] _[m][−]_[1]] ( _·_ ) to _F_[ˆ][[] _[m]_[]] ( _·_ ), the gradient boosting fits a negative gradient vector (as the working response) to the predictors using a base learner _h_ ( **x** ; _**ξ**_[[] _[m]_[]] ). This fitted _h_ ( **x** ; _**ξ**_[[] _[m]_[]] ) can be viewed as an approximation of the negative gradient. Subsequently, the expansion coefficient _β_[[] _[m]_[]] can then be determined by a line search minimization with the empirical risk function, and the estimation of _F_[˜] ( **x** ) for the next stage becomes 

**==> picture [334 x 15] intentionally omitted <==**

where 0 _< ν ≤_ 1 is the shrinkage factor (Friedman, 2001) that controls the update step size. A small _ν_ imposes more shrinkage while _ν_ = 1 gives complete negative gradient steps. Friedman (2001) has found that the shrinkage factor reduces over-fitting and improves the predictive accuracy. 

## **3 Compound Poisson Distribution and Tweedie Model** 

In insurance premium prediction problems, the total claim amount for a covered risk usually has a continuous distribution on positive values, except for the possibility of being exact zero when the claim does not occur. One standard approach in actuarial science in modeling such data is using Tweedie compound Poisson models, which we briefly introduce in this section. 

Let _N_ be a Poisson random variable denoted by Pois( _λ_ ), and let _Z_[˜] _d_ ’s ( _d_ = 0 _,_ 1 _, . . . , N_ ) be i.i.d. gamma random variables denoted by Gamma( _α, γ_ ) with mean _αγ_ and variance _αγ_[2] . Assume _N_ is independent of _Z_[˜] _d_ ’s. Define a random variable _Z_ by 

**==> picture [349 x 51] intentionally omitted <==**

6 

Thus _Z_ is the Poisson sum of independent Gamma random variables. In insurance applications, one can view _Z_ as the total claim amount, _N_ as the number of reported claims and _Z_[˜] _d_ ’s as the insurance payment for the _d_ th claim. The resulting distribution of _Z_ is referred to as the compound Poisson distribution (Jørgensen and de Souza, 1994; Smyth and Jørgensen, 2002), which is known to be closely connected to exponential dispersion models (EDM) (Jørgensen, 1987). Note that the distribution of _Z_ has a probability mass at zero: _Pr_ ( _Z_ = 0) = exp( _−λ_ ). Then based on that _Z_ conditional on _N_ = _j_ is Gamma( _jα, γ_ ), the distribution function of _Z_ can be written as 

**==> picture [298 x 75] intentionally omitted <==**

where _d_ 0 is the Dirac delta function at zero and _fZ|N_ = _j_ is the conditional density of _Z_ given _N_ = _j_ . Smyth (1996) pointed out that the compound Poisson distribution belongs to a special class of EDMs known as Tweedie models (Tweedie, 1984), which are defined by the form 

**==> picture [330 x 28] intentionally omitted <==**

where _a_ ( _·_ ) is a normalizing function, _κ_ ( _·_ ) is called the cumulant function, and both _a_ ( _·_ ) and _κ_ ( _·_ ) are known. The parameter _θ_ is in R and the dispersion parameter _φ_ is in R[+] . ˙ ¨ For Tweedie models the mean _E_ ( _Z_ ) _≡ µ_ = _κ_ ( _θ_ ) and the variance Var( _Z_ ) = _φκ_ ( _θ_ ), where _κ_ ˙ ( _θ_ ) and _κ_ ¨( _θ_ ) are the first and second derivatives of _κ_ ( _θ_ ), respectively. Tweedie models have the power mean-variance relationship Var( _Z_ ) = _φµ[ρ]_ for some index parameter _ρ_ . Such mean-variance relation gives 

**==> picture [361 x 51] intentionally omitted <==**

One can show that the compound Poisson distribution belongs to the class of Tweedie models. Indeed, if we reparametrize ( _λ, α, γ_ ) by 

**==> picture [366 x 30] intentionally omitted <==**

7 

the compound Poisson model will have the form of a Tweedie model with 1 _< ρ <_ 2 and _µ >_ 0. As a result, for the rest of this paper, we only consider the model (4), and simply refer to (4) as the Tweedie model (or Tweedie compound Poisson model), denoted by Tw( _µ, φ, ρ_ ), where 1 _< ρ <_ 2 and _µ >_ 0. 

It is straightforward to show that the log-likelihood of the Tweedie model is 

**==> picture [375 x 30] intentionally omitted <==**

where the normalizing function _a_ ( _·_ ) can be written as 

**==> picture [392 x 51] intentionally omitted <==**

and _α_ = (2 _− ρ_ ) _/_ ( _ρ −_ 1) and[�] _[∞] t_ =1 _[W][t]_[is][an][example][of][Wright’s][generalized][Bessel][function] (Tweedie, 1984). 

## **4 Our Proposal** 

In this section, we propose to integrate the Tweedie model to the tree-based gradient boosting algorithm to predict insurance claim size. Specifically, our discussion focuses on modeling the personal car insurance as an illustrating example (see Section 6 for a real data analysis), since our modeling strategy is easily extended to other lines of non-life insurance business. 

Given an auto insurance policy _i_ , let _Ni_ be the number of claims (known as the claim frequency) and _Z_[˜] _di_ be the size of each claim observed for _di_ = 1 _, . . . , Ni_ . Let _wi_ be the policy duration, that is, the length of time that the policy remains in force. Then _Zi_ =[�] _[N] di[i]_ =1 _[Z]_[˜] _[d] i_ is the total claim amount. In the following, we are interested in modeling the ratio between the total claim and the duration _Yi_ = _Zi/wi_ , a key quantity known as the pure premium (Ohlsson and Johansson, 2010). 

Following the settings of the compound Poisson model, we assume _Ni_ is Poisson distributed, and its mean _λiwi_ has a multiplicative relation with the duration _wi_ , where _λi_ is a policy-specific parameter representing the expected claim frequency under unit duration. Conditional on _Ni_ , assume _Zdi_ ’s ( _di_ = 1 _, . . . , Ni_ ) are i.i.d. Gamma( _α, γi_ ), where _γi_ is a 

8 

policy-specific parameter that determines claim severity, and _α_ is a constant. Furthermore, we assume that under unit duration (i.e., _wi_ = 1), the mean-variance relation of a policy satisfies _V ar_ ( _Yi[∗]_[) =] _[ φ]_[[] _[E]_[(] _[Y] i[∗]_[)]] _[ρ]_[for][all][policies,][where] _[Y] i[∗]_[is][the][pure][premium][under][unit][du-] ration, _φ_ is a constant, and _ρ_ = ( _α_ +2) _/_ ( _α_ +1). Then, it is known that _Yi ∼_ Tw( _µi, φ/wi, ρ_ ), the details of which are provided in Appendix Part A. 

Then, we consider a portfolio of policies _{_ ( _yi,_ **x** _i, wi_ ) _}[n] i_ =1[from] _[n]_[independent][insurance] contracts, where for the _i_ th contract, _yi_ is the policy pure premium, **x** _i_ is a vector of explanatory variables that characterize the policyholder and the risk being insured (e.g. house, vehicle), and _wi_ is the duration. Assume that the expected pure premium _µi_ is determined by a predictor function _F_ : R _[p] →_ R of **x** _i_ : 

**==> picture [321 x 13] intentionally omitted <==**

In this paper, we do not impose a linear or other parametric form restriction on _F_ ( _·_ ). Given the flexibility of _F_ ( _·_ ), we call such setting as the boosted Tweedie model (as opposed to the Tweedie GLM). Given _{_ ( _yi,_ **x** _i, wi_ ) _}[n] i_ =1[,][the][log-likelihood][function][can][be][written][as] 

**==> picture [432 x 72] intentionally omitted <==**

## **4.1 Estimating** _F_ ( _·_ ) **via TDboost** 

We estimate the predictor function _F_ ( _·_ ) by integrating the boosted Tweedie model into the tree-based gradient boosting algorithm. To develop the idea, we assume that _φ_ and _ρ_ are given for the time being. The joint estimation of _F_ ( _·_ ), _φ_ and _ρ_ will be studied in Section 4.2. 

Given _ρ_ and _φ_ , we replace the general objective function in (1) by the negative loglikelihood derived in (10), and target the minimizer function _F[∗]_ ( _·_ ) over a class _F_ of base learner functions in the form of (2). That is, we intend to estimate 

**==> picture [441 x 34] intentionally omitted <==**

9 

where 

**==> picture [344 x 37] intentionally omitted <==**

Note that in contrast to (11), the function class targeted by Tweedie GLM (Smyth, 1996) is restricted to a collection of linear functions of **x** . 

We propose to apply the forward stagewise algorithm described in Section 2 for solving (11). The initial estimate of _F[∗]_ ( _·_ ) is chosen as a constant function that minimizes the negative log-likelihood: 

**==> picture [160 x 75] intentionally omitted <==**

This corresponds to the best estimate of _F_ without any covariates. Let _F_[ˆ][[] _[m][−]_[1]] be the current estimate before the _m_ th iteration. At the _m_ th step, we fit a base learner _h_ ( **x** ; _**ξ**_[[] _[m]_[]] ) via 

**==> picture [330 x 33] intentionally omitted <==**

where ( _u_ 1[[] _[m]_[]] _[, . . . , u]_[[] _n[m]_[]][)][⊺][is][the][current][negative][gradient][of][Ψ(] _[· |][ ρ]_[),][i.e.,] 

**==> picture [407 x 59] intentionally omitted <==**

and use an _L_ -terminal node regression tree 

**==> picture [316 x 35] intentionally omitted <==**

with parameters _**ξ**_[[] _[m]_[]] = _{Rl_[[] _[m]_[]] _, u_[[] _l[m]_[]] _}[L] l_ =1[as][the][base][learner.][To][find] _[R] l_[[] _[m]_[]] and _u_[[] _l[m]_[]] , we use a fast top-down “best-fit” algorithm with a least squares splitting criterion (Friedman et al., 2000) to find the splitting variables and corresponding split locations that determine the fitted terminal regions _{R_[�] _l_[[] _[m]_[]] _}[L] l_ =1[.][Note][that][estimating][the] _[R] l_[[] _[m]_[]] entails estimating the _u_[[] _l[m]_[]] 

10 

as the mean falling in each region: 

**==> picture [216 x 21] intentionally omitted <==**

Once the base learner _h_ ( **x** ; _**ξ**_[[] _[m]_[]] ) has been estimated, the optimal value of the expansion coefficient _β_[[] _[m]_[]] is determined by a line search 

**==> picture [403 x 74] intentionally omitted <==**

The regression tree (15) predicts a constant value ¯ _u_[[] _l[m]_[]] within each region _R_[�] _l_[[] _[m]_[]] , so we can solve (16) by a separate line search performed within each respective region _R_[�] _l_[[] _[m]_[]] . The problem (16) reduces to finding a best constant _ηl_[[] _[m]_[]] to improve the current estimate in each region � _Rl_[[] _[m]_[]] based on the following criterion: 

**==> picture [404 x 34] intentionally omitted <==**

where the solution is given by 

**==> picture [418 x 42] intentionally omitted <==**

Having found the parameters _{η_ ˆ _l_[[] _[m]_[]] _}[L] l_ =1[,][we][then][update][the][current][estimate] _[F]_[ˆ][ [] _[m][−]_[1]][(] **[x]**[)] in each corresponding region 

**==> picture [382 x 16] intentionally omitted <==**

where 0 _< ν ≤_ 1 is the shrinkage factor. Following (Friedman, 2001), we set _ν_ = 0 _._ 005 in our implementation. More discussions on the choice of tuning parameters are in Section 4.4. 

In summary, the complete TDboost algorithm is shown in Algorithm 1. The boosting step is repeated _M_ times and we report _F_[ˆ][[] _[M]_[]] ( **x** ) as the final estimate. 

11 

## **Algorithm 1** TDboost 

**==> picture [298 x 49] intentionally omitted <==**

2. For _m_ = 1 _, . . . , M_ repeatedly do steps 2.(a)–2.(d) 

**==> picture [272 x 16] intentionally omitted <==**

**==> picture [411 x 18] intentionally omitted <==**

**==> picture [445 x 47] intentionally omitted <==**

**==> picture [444 x 72] intentionally omitted <==**

**==> picture [294 x 17] intentionally omitted <==**

**==> picture [299 x 17] intentionally omitted <==**

3. Report _F_[ˆ][[] _[M]_[]] ( **x** ) as the final estimate. 

12 

## **4.2 Estimating** ( _ρ, φ_ ) **via profile likelihood** 

Following Dunn and Smyth (2005), we use the profile likelihood to estimate the dispersion _φ_ and the index parameter _ρ_ , which jointly determine the mean-variance relation _V ar_ ( _Yi_ ) = _φµ[ρ] i[/w][i]_[of][the][pure][premium.][We][exploit][the][fact][that][in][Tweedie][models][the][estimation] of _µ_ depends only on _ρ_ : given a fixed _ρ_ , the mean estimate _µ[∗]_ ( _ρ_ ) can be solved in (11) without knowing _φ_ . Then conditional on this _ρ_ and the corresponding _µ[∗]_ ( _ρ_ ), we maximize the log-likelihood function with respect to _φ_ by 

**==> picture [317 x 22] intentionally omitted <==**

which is a univariate optimization problem that can be solved using a combination of golden section search and successive parabolic interpolation (Brent, 2013). In such a way, we have determined the corresponding ( _µ[∗]_ ( _ρ_ ) _, φ[∗]_ ( _ρ_ )) for each fixed _ρ_ . Then we acquire the estimate of _ρ_ by maximizing the profile likelihood with respect to 50 equally spaced values _{ρ_ 1 _, . . . , ρ_ 50 _}_ on (0 _,_ 1): 

**==> picture [325 x 23] intentionally omitted <==**

Finally, we apply _ρ[∗]_ in (11) and (20) to obtain the corresponding estimates _µ[∗]_ ( _ρ[∗]_ ) and _φ[∗]_ ( _ρ[∗]_ ). Some additional computational issues for evaluating the log-likelihood functions in (20) and (21) are discussed in Appendix Part B. 

## **4.3 Model interpretation** 

Compared to other nonparametric statistical learning methods such as neural networks and kernel machines, our new estimator provides interpretable results. In this section, we discuss some ways for model interpretation after fitting the boosted Tweedie model. 

## **4.3.1 Marginal effects of predictors** 

The main effects and interaction effects of the variables in the boosted Tweedie model can be extracted easily. In our estimate we can control the order of interactions by choosing the tree size _L_ (the number of terminal nodes) and the number _p_ of predictors. A tree with _L_ terminal nodes produces a function approximation of _p_ predictors with interaction order of at most min( _L −_ 1 _, p_ ). For example, a stump ( _L_ = 2) produces an additive TDboost model 

13 

with only the main effects of the predictors, since it is a function based on a single splitting variable in each tree. Setting _L_ = 3 allows both main effects and second order interactions. 

Following Friedman (2001) we use the so-called partial dependence plots to visualize the main effects and interaction effects. Given the training data _{yi,_ **x** _i}[n] i_ =1[, with a] _[ p]_[-dimensional] input vector **x** = ( _x_ 1 _, x_ 2 _, . . . , xp_ )[⊺] , let **z** _s_ be a subset of size _s_ , such that **z** _s_ = _{z_ 1 _, . . . , zs} ⊂ {x_ 1 _, . . . , xp}._ For example, to study the main effect of the variable _j_ , we set the subset **z** _s_ = _{zj}_ , and to study the second order interaction of variables _i_ and _j_ , we set **z** _s_ = _{zi, zj}_ . Let **z** _\s_ be the complement set of **z** _s_ , such that **z** _\s ∪_ **z** _s_ = _{x_ 1 _, . . . , xp}_ . Let the prediction ˆ _F_ ( **z** _s|_ **z** _\s_ ) be a function of the subset **z** _s_ conditioned on specific values of **z** _\s_ . The partial dependence of _F_[ˆ] ( **x** ) on **z** _s_ then can be formulated as _F_[ˆ] ( **z** _s|_ **z** _\s_ ) averaged over the marginal density of the complement subset **z** _\s_ 

**==> picture [321 x 28] intentionally omitted <==**

where _p\s_ ( **z** _\s_ ) = � _p_ ( **x** ) _d_ **z** _s_ is the marginal density of **z** _\s_ . We estimate (22) by 

**==> picture [302 x 34] intentionally omitted <==**

where _{_ **z** _\s,i}[n] i_ =1[are][evaluated][at][the][training][data.][We][then][plot] _[F]_[¯] _[s]_[(] **[z]** _[s]_[)][against] **[z]** _[s]_[.][We] have included the partial dependence plot function in our R package “TDboost”. We will demonstrate this functionality in Section 6. 

## **4.3.2 Variable importance** 

In many applications identifying relevant predictors of the model in the context of treebased ensemble methods is of interest. The TDboost model defines a variable importance measure for each candidate predictor _Xj_ in the set _X_ = _{X_ 1 _, . . . , Xp}_ in terms of prediction/explanation of the response _Y_ . The major advantage of this variable selection procedure, as compared to univariate screening methods, is that the approach considers the impact of each individual predictor as well as multivariate interactions among predictors simultaneously. 

We start by defining the variable importance (VI henceforth) measure in the context of a single tree. First introduced by Breiman et al. (1984), the VI measure _IXj_ ( _Tm_ ) of the 

14 

variable _Xj_ in a single tree _Tm_ is defined as the total heterogeneity reduction of the response variable _Y_ produced by _Xj_ , which can be estimated by adding up all the decreases in the squared error reductions _δ_[ˆ] _l_ obtained in all _L −_ 1 internal nodes when _Xj_ is chosen as the splitting variable. Denote _v_ ( _Xj_ ) = _l_ the event that _Xj_ is selected as the splitting variable in the internal node _l_ , and let _Ijl_ = _I_ ( _v_ ( _Xj_ ) = _l_ ). Then 

**==> picture [286 x 35] intentionally omitted <==**

where _δ_[ˆ] _l_ is defined as the squared error difference between the constant fit and the two sub-region fits (the sub-region fits are achieved by splitting the region associated with the internal node _l_ into the left and right regions). Friedman (2001) extended the VI measure _IXj_ for the boosting model with a combination of _M_ regression trees, by averaging (24) over _{T_ 1 _, . . . , TM }_ : 

**==> picture [293 x 35] intentionally omitted <==**

Despite of the wide use of the VI measure, Breiman et al. (1984) and White and Liu (1994) among others have pointed out that the VI measures (24) and (25) are biased: even if _Xj_ is a non-informative variable to _Y_ (not correlated to _Y_ ), _Xj_ may still be selected as a splitting variable, hence the VI measure of _Xj_ is non-zero by Equation (25). Following Sandri and Zuccolotto (2008) and Sandri and Zuccolotto (2010) to avoid the variable selection bias, in this paper we compute an adjusted VI measure for each explanatory variable by permutating each _Xj_ , the computational details are provided in Appendix Part C. 

## **4.4 Implementation** 

We have implemented our proposed method in an R package “TDboost”, which is publicly available from the Comprehensive R Archive Network at `http://cran.r-project.org/ web/packages/TDboost/index.html` . Here, we discuss the choice of three meta parameters in Algorithm 1: _L_ (the size of the trees), _ν_ (the shrinkage factor) and _M_ (the number of boosting steps). 

To avoid over-fitting and improve out-of-sample predictions, the boosting procedure can be regularized by limiting the number of boosting iterations _M_ (early stopping; Zhang and 

15 

Yu, 2005) and the shrinkage factor _ν_ . Empirical evidence (Friedman, 2001; B¨uhlmann and Hothorn, 2007; Ridgeway, 2007) showed that the predictive accuracy is almost always better with a smaller shrinkage factor at the cost of more computing time. However, smaller values of _ν_ usually requires a larger number of boosting iterations _M_ and hence induces more computing time (Friedman, 2001). We choose a “sufficiently small” _ν_ = 0 _._ 005 throughout and determine _M_ by the data. 

The value _L_ should reflect the true interaction order in the underlying model, but we almost never have such prior knowledge. Therefore we choose the optimal _M_ and _L_ using _K_ - fold cross validation, starting with a fixed value of _L_ . The data are split into _K_ roughly equalsized folds. Let an index function _π_ ( _i_ ) : _{_ 1 _, . . . , n} �→{_ 1 _, . . . , K}_ indicate the fold to which observation _i_ is allocated. Each time, we remove the _k_ th fold of the data ( _k_ = 1 _,_ 2 _, . . . , K_ ), and train the model using the remaining _K −_ 1 folds. Denoting by _F_[ˆ] _−_[[] _[M] k_[]][(] **[x]**[)][the][resulting] model, we compute the validation loss by predicting on each _k_ th fold of the data removed: 

**==> picture [341 x 34] intentionally omitted <==**

We select the optimal _M_ at which the minimum validation loss is reached 

**==> picture [128 x 20] intentionally omitted <==**

If we need to select _L_ too, then we repeat the whole process for several _L_ (e.g. _L_ = 2 _,_ 3 _,_ 4 _,_ 5) and choose the one with the smallest minimum generalization error 

**==> picture [124 x 20] intentionally omitted <==**

For a given _ν_ , fitting trees with higher _L_ leads to smaller _M_ being required to reach the minimum error. 

## **5 Simulation Studies** 

In this section, we compare TDboost with the Tweedie GLM model (TGLM: Jørgensen and de Souza, 1994) and the Tweedie GAM model in terms of the function estimation performance. The Tweedie GAM model is proposed by Wood (2001), which is based on a 

16 

penalized regression spline approach with automatic smoothness selection. There is an R package “MGCV” accompanying the work, available at `http://cran.r-project.org/web/ packages/mgcv/index.html` . In all numerical examples below using the TDboost model, five-fold cross validation is adopted for selecting the optimal ( _M, L_ ) pair, while the shrinkage factor _ν_ is set to its default value of 0 _._ 005. 

## **5.1 Case I** 

In this simulation study, we demonstrate that TDboost is well suited to fit target functions that are non-linear or involve complex interactions. We consider two true target functions: 

- **Model 1** (Discontinuous function): The target function is discontinuous as defined by _F_ ( _x_ ) = 0 _._ 5 _I_ ( _x >_ 0 _._ 5). We assume _x ∼_ Unif(0 _,_ 1), and _y ∼_ Tw( _µ, φ, ρ_ ) with _ρ_ = 1 _._ 5 and _φ_ = 0 _._ 5. 

- **Model 2** (Complex interaction): The target function has two hills and two valleys. 

**==> picture [206 x 16] intentionally omitted <==**

which corresponds to a common scenario where the effect of one variable changes depending on the effect of another. We assume _x_ 1 _, x_ 2 _∼_ Unif(0 _,_ 1), and _y ∼_ Tw( _µ, φ, ρ_ ) with _ρ_ = 1 _._ 5 and _φ_ = 0 _._ 5. 

We generate _n_ = 1000 observations for training and _n[′]_ = 1000 for testing, and fit the training data using TDboost, MGCV, and TGLM. Since the true target functions are known, we consider the mean absolute deviation (MAD) as performance criteria, 

**==> picture [160 x 36] intentionally omitted <==**

where both the true predictor function _F_ ( **x** _i_ ) and the predicted function _F_[ˆ] ( **x** _i_ ) are evaluated on the test set. The resulting MADs on the testing data are reported in Table 1, which are averaged over 100 independent replications. The fitted functions from Model 2 are plotted in Figure 2. In both cases, we find that TDboost outperforms TGLM and MGCV in terms of the ability to recover the true functions and gives the smallest prediction errors. 

17 

**==> picture [439 x 227] intentionally omitted <==**

**----- Start of picture text -----**<br>
(a) True F ( x 1 , x 2) (b) TDboost F [ˆ] ( x 1 , x 2)<br>2.5<br>2.5<br>2.0<br>2.0<br>F ( x 1 , x 2) F ˆ( x 1 , x 2)<br>1.5 1.5<br>1.0 1.0<br>0.8 0.8<br>0.6 0.8 0.6 0.8<br>0.6 0.6<br>0.4 0.4<br>0.4 0.4<br>x 2 0.2 0.2 x 1 x 2 0.2 0.2 x 1<br>0.0 0.0 0.0 0.0<br>**----- End of picture text -----**<br>


**==> picture [439 x 227] intentionally omitted <==**

**----- Start of picture text -----**<br>
(c) TGLM F [ˆ] ( x 1 , x 2) (d) MGCV F [ˆ] ( x 1 , x 2)<br>2.0<br>1.35<br>1.30<br>ˆ 1.25 ˆ 1.5<br>F ( x 1 , x 2) F ( x 1 , x 2)<br>1.20<br>1.15 1.0<br>1.10<br>0.8 0.8<br>0.6 0.8 0.6 0.8<br>0.6 0.6<br>0.4 0.4<br>0.4 0.4<br>x 2 0.2 0.2 x 1 x 2 0.2 0.2 x 1<br>0.0 0.0 0.0 0.0<br>**----- End of picture text -----**<br>


Figure 2: Fitted curves that recover the target function defined in Model 2. The top left figure shows the true target function. The top right, bottom left, and bottom right figures show the predictions on the testing data from TDboost, TGLM, and MGCV, respectively. 

18 

|Model||TGLM||MGCV|TDboost|
|---|---|---|---|---|---|
|1|0.1102|(0.0006)|0.0752|(0.0016)|0.0595 (0.0021)|
|2|0.3516|(0.0009)|0.2511|(0.0004)|0.1034 (0.0008)|



Table 1: The averaged MADs and the corresponding standard errors based on 100 independent replications. 

## **5.2 Case II** 

The idea is to see the performance of the TDboost estimator and MGCV estimator on a variety of very complicated, randomly generated predictor functions, and study how the size of the training set, distribution settings and other characteristics of problems affect final performance of the two methods. We use the “random function generator” (RFG) model by Friedman (2001) in our simulation. The true target function _F_ is randomly generated as a linear expansion of functions _{gk}_[20] _k_ =1[:] 

**==> picture [288 x 36] intentionally omitted <==**

Here each coefficient _bk_ is a uniform random variable from Unif[ _−_ 1 _,_ 1]. Each _gk_ ( **z** _k_ ) is a function of **z** _k_ , where **z** _k_ is defined as a _pk_ -sized subset of the ten-dimensional variable **x** in the form 

**==> picture [278 x 15] intentionally omitted <==**

where each _ψk_ is an independent permutation of the integers _{_ 1 _, . . . , p}_ . The size _pk_ is randomly selected by min( _⌊_ 2 _._ 5 + _rk⌋ , p_ ), where _rk_ is generated from an exponential distribution with mean 2. Hence the expected order of interactions presented in each _gk_ ( **z** _k_ ) is between four and five. Each function _gk_ ( **z** _k_ ) is a _pk_ -dimensional Gaussian function: 

**==> picture [347 x 25] intentionally omitted <==**

where each mean vector **u** _k_ is randomly generated from N(0 _,_ **I** _pk_ ). The _pk × pk_ covariance matrix **V** _k_ is defined by 

**==> picture [276 x 14] intentionally omitted <==**

where **U** _k_ is a random orthonormal matrix, **D** _k_ = _diag{dk_ [1] _, . . . , dk_ [ _pk_ ] _}_ , and the square root of each diagonal element � _dk_ [ _j_ ] is a uniform random variable from Unif[0 _._ 1 _,_ 2 _._ 0]. We 

19 

generate data _{yi,_ **x** _i}[n] i_ =1[according][to] 

**==> picture [359 x 14] intentionally omitted <==**

where _µi_ = exp _{F_ ( **x** _i_ ) _}_ . 

## **Setting I: when the index is known** 

Firstly, we study the situation that the true index parameter _ρ_ is known when fitting models. ˜ We generate data according to the RFG model with index parameter _ρ_ = 1 _._ 5 and the dispersion parameter _φ_[˜] = 1 in the true model. We set the number of predictors to be _p_ = 10 and generate _n ∈{_ 1000 _,_ 2000 _,_ 5000 _}_ observations as training sets, on which both MGCV and TDboost are fitted with _ρ_ specified to be the true value 1.5. An additional test set of _n[′]_ = 5000 observations was generated for evaluating the performance of the final estimate. 

Figure 3 shows simulation results for comparing the estimation performance of MGCV and TDboost, when varying the training sample size. The empirical distributions of the MADs shown as box-plots are based on 100 independent replications. We can see that in all of the cases, TDboost outperforms MGCV in terms of prediction accuracy. 

We also test estimation performance on _µ_ when the index parameter _ρ_ is misspecified, that is, we use a guess value _ρ_ differing from the true value _ρ_ ˜ when fitting the TDboost model. Because _µ_ is statistically orthogonal to _φ_ and _ρ_ , meaning that the off-diagonal elements of the Fisher information matrix are zero (Jørgensen, 1997), we expect _µ_ ˆ will vary very slowly ˜ as _ρ_ changes. Indeed, using the previous simulation data with the true value _ρ_ = 1 _._ 5 and ˜ _φ_ = 1, we fitted TDboost models with nine guess values of _ρ ∈{_ 1 _._ 1 _,_ 1 _._ 2 _, . . . ,_ 1 _._ 9 _}_ . The resulting MADs are displayed in Figure 4, which shows the choice of the value _ρ_ has almost no significant effect on estimation accuracy of _µ_ . 

## **Setting II: using the estimated index** 

Next we study the situation that the true index parameter _ρ_ is unknown, and we use the estimated _ρ_ obtained from the profile likelihood procedure discussed in Section 4.2 for fitting the model. The same data generation scheme is adopted as in Setting I, except now both MGCV and TDboost are fitted with _ρ_ estimated by maximizing the profile likelihood. Figure 5 shows simulation results for comparing the estimation performance of MGCV and TDboost 

20 

**==> picture [469 x 235] intentionally omitted <==**

**----- Start of picture text -----**<br>
N = 1000 N = 2000 N = 5000<br>-<br>0.35 -<br>- -<br>-<br>0.30<br>- [-]<br>0.25<br>0.20<br>0.15 -<br>-<br>MGCV TDBoost MGCV TDBoost MGCV TDBoost<br>Method<br>(MAD)<br>deviation<br>absolute<br>Mean<br>**----- End of picture text -----**<br>


Figure 3: Simulation results for Setting I: compare the estimation performance of **MGCV** and **TDboost** when varying the training sample size and the dispersion parameter in the true model. Box-plots display empirical distributions of the MADs based on 100 independent replications. 

**==> picture [469 x 235] intentionally omitted <==**

**----- Start of picture text -----**<br>
0.5<br>-<br>- - - - - - - -<br>0.4 - -- - - -- [-] - [-] - [-] - - - - - -- - -<br>0.3<br>0.2<br>0.1<br>1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9<br>ρ [∗]<br>(MAD)<br>deviation<br>absolute<br>Mean<br>**----- End of picture text -----**<br>


Figure 4: Simulation results for Setting I when the index is misspecified: the estimation performance of **TDboost** when varying the value of the index parameter _ρ ∈{_ 1 _._ 1 _,_ 1 _._ 2 _, . . . ,_ 1 _._ 9 _}_ . ˜ In the true model _ρ_ = 1 _._ 5 and _φ_[˜] = 1. Box-plots show empirical distributions of the MADs based on 200 independent replications. 

21 

**==> picture [469 x 235] intentionally omitted <==**

**----- Start of picture text -----**<br>
N = 1000 N = 2000 N = 5000<br>0.40 - -<br>- - [-]<br>0.35<br>0.30<br>0.25<br>0.20<br>0.15 -<br>-<br>-<br>MGCV TDBoost MGCV TDBoost MGCV TDBoost<br>Method<br>(MAD)<br>deviation<br>absolute<br>Mean<br>**----- End of picture text -----**<br>


Figure 5: Simulation results for Setting II: compare the estimation performance of **MGCV** and **TDboost** when varying the training sample size and the dispersion parameter in the true model. Box-plots display empirical distributions of the MADs based on 100 independent replications. 

in such setting. We can see that the results have no significant difference to the results of Setting I: TDboost still outperforms MGCV in terms of prediction accuracy when using the estimated _ρ_ instead of the true value. 

Lastly, we demonstrate our results from the estimation of the dispersion _φ_ and the index _ρ_ by using the profile likelihood. A total number of 200 sets of training samples are randomly generated from a true model according to the setting (31) with _φ_ = 2 and _ρ_ = 1 _._ 7, each sample having 2000 observations. We fit the TDboost model on each sample and compute the estimates _φ[∗]_ at each of the 50 equally spaced values _{ρ_ 1 _, . . . , ρ_ 50 _}_ on (1 _,_ 2). The ( _ρj, φ[∗]_ ( _ρj_ )) corresponding to the maximal profile likelihood is the estimate of ( _ρ, φ_ ). The estimation process is repeated 200 times. The estimated indices have mean _ρ[∗]_ = 1 _._ 68 and standard error _SE_ ( _ρ[∗]_ ) = 0 _._ 026, so the true value _ρ_ = 1 _._ 7 is within _ρ[∗] ± SE_ ( _ρ[∗]_ ). The estimated dispersions have mean _φ[∗]_ = 1 _._ 82 and standard error _SE_ ( _φ[∗]_ ) = 0 _._ 12. Figure 6 shows the profile likelihood function of _ρ_ for a single run. 

22 

**==> picture [430 x 245] intentionally omitted <==**

**----- Start of picture text -----**<br>
1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9<br>ρ<br>-4000<br>ℓ<br>-6000<br>log-likelihood<br>Profile -8000<br>-10000<br>**----- End of picture text -----**<br>


Figure 6: The curve represents the profile likelihood function of _ρ_ from a single run. The dotted line shows the true value _ρ_ = 1 _._ 7. The solid line shows the estimated value _ρ[∗]_ = 1 _._ 68 corresponding to the maximum likelihood. The associated estimated dispersion is _φ[∗]_ =1.89. 

## **6 Application: Automobile Claims** 

## **6.1 Dataset** 

We consider an auto insurance claim dataset as analyzed in Yip and Yau (2005) and Zhang and Yu (2005). The data set contains 10,296 driver vehicle records, each record including an individual driver’s total claim amount ( _zi_ ) in the last five years ( _wi_ = 5) and 17 characteristics _xi_ = ( _xi,_ 1 _, . . . , xi,_ 17) for the driver and the insured vehicle. We want to predict the expected pure premium based on _xi_ . Table 3 summarize the data set. The descriptive statistics of the data are provided in Appendix Part D. The histogram of the total claim amounts in Figure 1 shows that the empirical distribution of these values is highly skewed. We find that approximately 61 _._ 1% of policyholders had no claims, and approximately 29 _._ 6% of the policyholders had a positive claim amount up to 10,000 dollars. Note that only 9 _._ 3% of the policyholders had a high claim amount above 10,000 dollars, but the sum of their claim amount made up to 64% of the overall sum. Another important feature of the data is that there are interactions among explanatory variables. For example, from Table 2 we can 

23 

|REVOKED<br>No<br>Yes|AREA|
|---|---|
||Urban<br>Rural<br>3150.57<br>904.70<br>14551.62<br>7624.36|
|Diference|11401.05<br>6719.66|



Table 2: The averaged total claim amount for different categories of the policyholders. 

|ID|Variable|Type|Description|
|---|---|---|---|
|1|AGE|N|Driver’s age|
|2|BLUEBOOK|N|Value of vehicle|
|3|HOMEKIDS|N|Number of children|
|4|KIDSDRIV|N|Number of driving children|
|5|MVR<br>~~P~~TS|N|Motor vehicle record points|
|6|NPOLICY|N|Number of policies|
|7|RETAINED|N|Number of years as a customer|
|8|TRAVTIME|N|Distance to work|
|9|AREA|C|Home/work area: Rural, Urban|
|10|CAR<br>USE|C|Vehicle use: Commercial, Private|
|11|CAR<br>TYPE|C|Type of vehicle: Panel Truck, Pickup,|
||||Sedan, Sports Car, SUV, Van|
|12|GENDER|C|Driver’s gender: F, M|
|13|JOBCLASS|C|Unknown, Blue Collar, Clerical, Doctor,|
||||Home Maker, Lawyer, Manager, Professional, Student|
|14|MAX<br>~~E~~DUC|C|Education level: High School or Below, Bachelors,|
||||High School, Masters, PhD|
|15|MARRIED|C|Married or not: Yes, No|
|16|REVOKED|C|Whether license revoked in past 7 years: Yes, No|



Table 3: Explanatory variables in the claim history data set. Type N stands for numerical variable, Type C stands for categorical variable. 

see that the marginal effect of the variable REVOKED on the total claim amount is much greater for the policyholders living in the urban area than those living in the rural area. The importance of the interaction effects will be confirmed later in our data analysis. 

## **6.2 Models** 

We separate the entire dataset into a training set and a testing set with equal size. Then the TDboost model is fitted on the training set and tuned with five-fold cross validation. 

24 

For comparison, we also fit TGLM and MGCV, both of which are fitted using all the explanatory variables. In MGCV, the numerical variables AGE, BLUEBOOK, HOMEKIDS, KIDSDRIV, MVR PTS, NPOLICY, RETAINED and TRAVTIME are modeled by smooth terms represented using penalized regression splines. We find the appropriate smoothness for each applicable model term using Generalized Cross Validation (GCV) (Wahba, 1990). For the TDboost model, it is not necessary to carry out data transformation, since the treebased boosting method can automatically handle different types of data. For other models, we use logarithmic transformation on BLUEBOOK, i.e. log(BLUEBOOK), and scale all the numerical variables except for HOMEKIDS, KIDSDRIV, MVR ~~P~~ TS and NPOLICY to have mean 0 and standard deviation 1. We also create dummy variables for the categorical variables with more than two levels (CAR ~~T~~ YPE, JOBCLASS and MAX EDUC). For all models, we use the profile likelihood method to estimate the dispersion _φ_ and the index _ρ_ , which are in turn used in fitting the final models. 

## **6.3 Performance comparison** 

To examine the performance of TGLM, MGCV and TDboost, after fitting on the training set, we predict the pure premium _P_ ( **x** ) = _µ_ ˆ( **x** ) by applying each model on the independent heldout testing set. However, attention must be paid when measuring the differences between predicted premiums _P_ ( **x** ) and real losses _y_ on the testing data. The mean squared loss or mean absolute loss is not appropriate here because the losses have high proportions of zeros and are highly right skewed. Therefore an alternative statistical measure – the ordered – Lorenz curve and the associated Gini index proposed by Frees et al. (2011) are used for capturing the discrepancy between the premium and loss distributions. By calculating the Gini index, the performance of different predictive models can be compared. Here we only briefly explain the idea of the ordered Lorenz curve (Frees et al., 2011, 2013). Let _B_ ( **x** ) be the “base premium”, which is calculated using the existing premium prediction model, and let _P_ ( **x** ) be the “competing premium” calculated using an alternative premium prediction model. In the ordered Lorenz curve, the distribution of losses and the distribution of premiums are sorted based on the relative premium _R_ ( **x** ) = _P_ ( **x** ) _/B_ ( **x** ). The ordered premium distribution is 

25 

**==> picture [176 x 30] intentionally omitted <==**

and the ordered loss distribution is 

**==> picture [156 x 31] intentionally omitted <==**

Two empirical distributions are based on the same sort order, which makes it possible to compare the premium and loss distributions for the same policyholder group. The ordered Lorenz curve is the graph of ( _D_[ˆ] _P_ ( _s_ ) _, D_[ˆ] _L_ ( _s_ )). When the percentage of losses equals the percentage of premiums for the insurer, the curve results in a 45-degree line, known as “the line of equality”. Twice the area between the ordered Lorenz curve and the line of equality measures the discrepancy between the premium and loss distributions, and is defined as the Gini index. Curves below the line of equality indicate that, given knowledge of the relative premium, an insurer could identify the profitable contracts, whose premiums are greater than losses. Therefore, a larger Gini index (hence a larger area between the line of equality and the curve below) would imply a more favorable model. 

Following Frees et al. (2013), we successively specify the prediction from each model as the base premium _B_ ( **x** ) and use predictions from the remaining models as the competing premium _P_ ( **x** ) to compute the Gini indices. The entire procedure of the data splitting and Gini index computation are repeated 20 times, and a matrix of the averaged Gini indices and standard errors is reported in Table 4. To pick the “best” model, we use a “minimax” strategy (Frees et al., 2013) to select the base premium model that are least vulnerable to competing premium models; that is, we select the model that provides the smallest of the maximal Gini indices, taken over competing premiums. We find that the maximal Gini index is 15.528 when using _B_ ( **x** ) = _µ_ ˆ[TGLM] ( **x** ) as the base premium, 12.979 when _B_ ( **x** ) = _µ_ ˆ[MGCV] ( **x** ), ˆ and 4.000 when _B_ ( **x** ) = _µ_[TDboost] ( **x** ). Therefore, TDboost has the smallest maximum Gini index at 4.000, hence is the least vulnerable to alternative scores. Figure 7 also shows that when TGLM (or MGCV) is selected as the base premium, the area between the line of equality and the ordered Lorenz curve is larger when choosing TDboost as the competing premium, indicating again that the TDboost model represents the most favorable choice. 

26 

**==> picture [433 x 217] intentionally omitted <==**

**----- Start of picture text -----**<br>
MGCV TGLM<br>100<br>75<br>Model<br>TGLM<br>50<br>MGCV<br>TDBoost<br>25<br>0<br>0 25 50 75 100 0 25 50 75 100<br>Premium<br>Loss<br>**----- End of picture text -----**<br>


Figure 7: The ordered Lorenz curves for the auto insurance claim data. 

|Base Premium<br>TGLM<br>MGCV<br>TDboost|Competing Premium|
|---|---|
||TGLM<br>MGCV<br>TDboost|
||0<br>7.833 (0.338)<br>15.528 (0.509)<br>3.044 (0.610)<br>0<br>12.979 (0.473)<br>4.000 (0.364)<br>3.540 (0.415)<br>0|



Table 4: The averaged Gini indices and standard errors in the auto insurance claim data example based on 20 random splits. 

## **6.4 Interpreting the results** 

Next, we focus on the analysis using the TDboost model. There are several explanatory variables significantly related to the pure premium. The VI measure and the baseline value of each explanatory variable are shown in Figure 8. We find that REVOKED, MVR ~~P~~ TS, AREA and BLUEBOOK have high VI measure scores (the vertical line), and their scores all surpass the corresponding baselines (the horizontal line-length), indicating that the importance of those explanatory variables is real. We also find the variables AGE, JOBCLASS, CAR ~~T~~ YPE, NPOLICY, MAX ~~E~~ DUC, MARRIED, KIDSDRIV and CAR ~~U~~ SE have largerthan-baseline VI measure scores, but the absolute scales are much less than aforementioned four variables. On the other hand, although the VI measure of, e.g., TRAVTIME is quite large, it does not significantly surpass the baseline importance. 

We now use the partial dependence plots to visualize the fitted model. Figure 9 shows 

27 

**==> picture [364 x 273] intentionally omitted <==**

**----- Start of picture text -----**<br>
l Relative Influence Baseline<br>REVOKED l<br>MVR P TS l<br>AREA l<br>BLUEBOOK l<br>TRAVTIME l<br>AGE l<br>JOBCLASS l<br>CAR T YPE l<br>NPOLICY l<br>MAX E DUC l<br>RETAINED l<br>MARRIED l<br>KIDSDRIV l<br>CAR U SE l<br>HOMEKIDS l<br>GENDER l<br>0 10 20 30 40 50<br>Fraction of Reduction in Sum of Squared Error in Gradient Prediction<br>**----- End of picture text -----**<br>


Figure 8: The variable importance measures and baselines of 17 explanatory variables for modeling the pure premium. 

the main effects of four important explanatory variables on the pure premium. We clearly see that the strong nonlinear effects exist in predictors BLUEBOOK and MVR ~~P~~ TS: for the policyholders whose vehicle values are below 40K, their pure premium is negatively associated with the value of vehicle; after the value of vehicle passes 40K, the pure premium curve reaches a plateau; Additionally, the pure premium is positively associated with motor vehicle record points MVR PTS, but the pure premium curve reaches a plateau when MVR ~~P~~ TS exceeds six. On the other hand, the partial dependence plots suggest that a policyholder who lives in the urban area (AREA=“URBAN”) or with driver’s license revoked (REVOKED=“YES”) typically has relatively high pure premium. 

In our model, the data-driven choice for the tree size is _L_ = 7, which means that our model includes higher order interactions. In Figure 10, we visualize the effects of four important second order interactions using the joint partial dependence plots. These four interactions are AREA _×_ MVR PTS, AREA _×_ NPOLICY, AREA _×_ REVOKED and AREA _×_ TRAVTIME. These four interactions all involve the variable AREA: we can see that the marginal effects of MVR ~~P~~ TS, NPOLICY, REVOKED and TRAVTIME on the pure 

28 

**==> picture [397 x 397] intentionally omitted <==**

**----- Start of picture text -----**<br>
REVOKED AREA<br>No Yes Rural Urban<br>BLUEBOOK MVR P TS<br>0 20 40 60 0 5 10<br>x<br>10<br>3.0<br>8 2.5<br>6 2.0<br>1.5<br>4<br>1.0<br>2<br>2.6<br>Pure Premium (in $1000) 6<br>2.4 5<br>2.2 4<br>3<br>2.0<br>2<br>1.8<br>**----- End of picture text -----**<br>


Figure 9: Marginal effects of four most significant explanatory variables on the pure premium. 

premium are greater for the policyholders living in the urban area (AREA=“URBAN”) than those living in the rural area (AREA=“RURAL”). For example, a strong AREA _×_ MVR ~~P~~ TS interaction suggests that for the policyholders living in the rural area, motor vehicle record points of the policyholders have a weaker positive marginal effect on the expected pure premium than for the policyholders living in the urban area. 

## **7 Conclusions** 

The need for nonlinear risk factors as well as risk factor interactions for modeling insurance claim sizes is well-recognized by actuarial practitioners, but practical tools to study them 

29 

**(a)** 

**(b)** 

**==> picture [435 x 175] intentionally omitted <==**

**----- Start of picture text -----**<br>
6 2.5<br>5 2.0<br>4<br>µ ( x ) µ ( x ) 1.5<br>3<br>1.0<br>2<br>1 0.5<br>12<br>10 Urban<br>8<br>6 2<br>Urban<br>MVR P TS 4 AREA Rural 4<br>2 Rural 6<br>0 AREA 8 NPOLICY<br>**----- End of picture text -----**<br>


**==> picture [497 x 263] intentionally omitted <==**

**----- Start of picture text -----**<br>
(c) (d)<br>10 3.0<br>8 2.5<br>µ ( x ) 6 µ ( x ) 2.0<br>1.5<br>4<br>1.0<br>2<br>0.5<br>Yes Urban<br>20<br>Urban 40<br>REVOKED No AREA Rural 80 60<br>Rural 100<br>AREA 140 120 TRAVTIME<br>**----- End of picture text -----**<br>


Figure 10: Four strong pairwise interactions. 

30 

are very limited. In this paper, relying on neither the linear assumption nor a pre-specified interaction structure, a flexible tree-based gradient boosting method is designed for the Tweedie model. We implement the proposed method in a user-friendly R package “TDboost” that can make accurate insurance premium predictions for complex data sets and serve as a convenient tool for actuarial practitioners to investigate the nonlinear and interaction effects. In the context of personal auto insurance, we implicitly use the policy duration as a volume measure (or exposure), and demonstrate the favorable prediction performance of TDboost for the pure premium. In cases that exposure measures other than duration are used, which is common in commercial insurance, we can extend the TDboost method to the corresponding claim size by simply replacing the duration with any chosen exposure measure. 

TDboost can also be an important complement to the traditional GLM model in insurance rating. Even under the strict circumstances that the regulators demand the final model to have a GLM structure, our approach can still be quite helpful due to its ability to extract additional information such as non-monotonicity/non-linearity and important interaction. In Appendix Part E, we provide an additional real data analysis to demonstrate that our method can provide insights into the structure of interaction terms. After integrating the obtained information about the interaction terms into the original GLM model, we can much enhance the overall accuracy of the insurance premium prediction while maintaining a GLM model structure. 

In addition, it is worth mentioning that the applications of the proposed method can go beyond the insurance premium prediction and be of interest to researchers in many other fields including ecology (Foster and Bravington, 2013), meteorology (Dunn, 2004) and political science (Lauderdale, 2012). See, for example, Dunn and Smyth (2005) and Qian et al. (2015) for descriptions of the broad Tweedie distribution applications. The proposed method and the implementation tool allow researchers in these related fields to venture outside the Tweedie GLM modeling framework, build new flexible models from nonparametric perspectives, and use the model interpretation tools demonstrated in our real data analysis to study their own problems of interests. 

31 

## **References** 

- Anstey, K. J., Wood, J., Lord, S., and Walker, J. G. (2005), “Cognitive, sensory and physical factors enabling driving safety in older adults,” _Clinical psychology review_ , 25, 45–65. 

- Breiman, L. (1996), “Bagging predictors,” _Machine learning_ , 24, 123–140. 

- (1998), “Arcing classifier (with discussion and a rejoinder by the author),” _The Annals_ 

- _of Statistics_ , 26, 801–849. 

- (1999), “Prediction games and arcing algorithms,” _Neural Computation_ , 11, 1493–1517. 

- Breiman, L., Friedman, J., Olshen, R., Stone, C., Steinberg, D., and Colla, P. (1984), “CART: Classification and regression trees,” _Wadsworth_ . 

- Brent, R. P. (2013), _Algorithms for minimization without derivatives_ , Courier Dover Publications. 

- B¨uhlmann, P. and Hothorn, T. (2007), “Boosting algorithms: Regularization, prediction and model fitting,” _Statistical Science_ , 22, 477–505. 

- Dionne, G., Gouri´eroux, C., and Vanasse, C. (2001), “Testing for evidence of adverse selection in the automobile insurance market: A comment,” _Journal of Political Economy_ , 109, 444– 453. 

- Dunn, P. K. (2004), “Occurrence and quantity of precipitation can be modelled simultaneously,” _International Journal of Climatology_ , 24, 1231–1239. 

- Dunn, P. K. and Smyth, G. K. (2005), “Series evaluation of Tweedie exponential dispersion model densities,” _Statistics and Computing_ , 15, 267–280. 

- Elith, J., Leathwick, J. R., and Hastie, T. (2008), “A working guide to boosted regression trees,” _Journal of Animal Ecology_ , 77, 802–813. 

- Foster, S. D. and Bravington, M. V. (2013), “A Poisson–Gamma model for analysis of ecological non-negative continuous data,” _Environmental and ecological statistics_ , 20, 533– 552. 

32 

- Frees, E. W., Meyers, G., and Cummings, A. D. (2011), “Summarizing insurance scores using a Gini index,” _Journal of the American Statistical Association_ , 106. 

- Frees, E. W. J., Meyers, G., and Cummings, A. D. (2013), “Insurance ratemaking and a Gini index,” _Journal of Risk and Insurance_ . 

- Freund, Y. and Schapire, R. (1997), “A decision-theoretic generalization of on-line learning and an application to boosting,” _Journal of Computer and System Sciences_ , 55, 119–139. 

- Friedman, J. (2001), “Greedy function approximation: A gradient boosting machine,” _The Annals of Statistics_ , 29, 1189–1232. 

- Friedman, J., Hastie, T., and Tibshirani, R. (2000), “Additive logistic regression: A statistical view of boosting (With discussion and a rejoinder by the authors),” _The Annals of Statistics_ , 28, 337–407. 

- Friedman, J. H. (2002), “Stochastic gradient boosting,” _Computational Statistics & Data Analysis_ , 38, 367–378. 

- Haberman, S. and Renshaw, A. E. (1996), “Generalized linear models and actuarial science,” _Statistician_ , 45, 407–436. 

- Hastie, T., Tibshirani, R., and Friedman, J. (2009), _The elements of statistical learning: Data mining, inference, and prediction. Second Edition._ , Springer Series in Statistics, Springer. 

- Hastie, T. J. and Tibshirani, R. J. (1990), _Generalized additive models_ , vol. 43, CRC Press. 

- Jørgensen, B. (1987), “Exponential dispersion models,” _Journal of the Royal Statistical Society. Series B (Methodological)_ , 127–162. 

- (1997), _The theory of dispersion models_ , vol. 76, CRC Press. 

- Jørgensen, B. and de Souza, M. C. (1994), “Fitting Tweedie’s compound Poisson model to insurance claims data,” _Scandinavian Actuarial Journal_ , 1994, 69–93. 

- Lauderdale, B. E. (2012), “Compound Poisson–Gamma regression models for dollar outcomes that are sometimes zero,” _Political Analysis_ , 20, 387–399. 

33 

- Mildenhall, S. J. (1999), “A systematic relationship between minimum bias and generalized linear models,” in _Proceedings of the Casualty Actuarial Society_ , vol. 86, pp. 393–487. 

- Murphy, K. P., Brockman, M. J., and Lee, P. K. (2000), “Using generalized linear models to build dynamic pricing systems,” in _Casualty Actuarial Society Forum, Winter_ , pp. 107–139. 

- Nelder, J. and Wedderburn, R. (1972), “Generalized Linear Models,” _Journal of the Royal Statistical Society. Series A (General)_ , 135, 370–384. 

- Ohlsson, E. and Johansson, B. (2010), _Non-life insurance pricing with generalized linear models_ , Springer. 

- Peters, G. W., Shevchenko, P. V., and W¨uthrich, M. V. (2008), “Model risk in claims reserving within Tweedie’s compound Poisson models,” _ASTIN Bulletin, to appear_ . 

- Qian, W., Yang, Y., and Zou, H. (2015), “Tweedie’s compound Poisson model with grouped elastic net,” _Journal of Computational and Graphical Statistics_ , preprint. 

- Renshaw, A. E. (1994), “Modelling the claims process in the presence of covariates,” _ASTIN Bulletin_ , 24, 265–285. 

- Ridgeway, G. (2007), “Generalized Boosted Regression Models,” _R package manual_ . 

- Sandri, M. and Zuccolotto, P. (2008), “A bias correction algorithm for the Gini variable importance measure in classification trees,” _Journal of Computational and Graphical Statistics_ , 17. 

- (2010), “Analysis and correction of bias in Total Decrease in Node Impurity measures for tree-based algorithms,” _Statistics and Computing_ , 20, 393–407. 

- Showers, V. E. and Shotick, J. A. (1994), “The effects of household characteristics on demand for insurance: A tobit analysis,” _Journal of Risk and Insurance_ , 492–502. 

- Smyth, G. and Jørgensen, B. (2002), “Fitting Tweedie’s compound Poisson model to insurance claims data: Dispersion modelling,” _ASTIN Bulletin_ , 32, 143–157. 

34 

- Smyth, G. K. (1996), “Regression analysis of quantity data with exact zeros,” in _Proceedings of the second Australia–Japan workshop on stochastic models in engineering, technology and management_ , Citeseer, pp. 572–580. 

- Tweedie, M. (1984), “An index which distinguishes between some important exponential families,” in _Statistics: Applications and New Directions: Proc. Indian Statistical Institute Golden Jubilee International Conference_ , pp. 579–604. 

- Van de Ven, W. and van Praag, B. M. (1981), “Risk aversion and deductibles in private health insurance: Application of an adjusted tobit model to family health care expenditures,” _Health, economics, and health economics_ , 125–48. 

- Wahba, G. (1990), _Spline models for observational data_ , vol. 59, SIAM. 

- White, A. P. and Liu, W. Z. (1994), “Technical note: Bias in information-based measures in decision tree induction,” _Machine Learning_ , 15, 321–329. 

- Wood, S. (2001), “mgcv: GAMs and generalized ridge regression for R,” _R News_ , 1, 20–25. 

- (2006), _Generalized additive models: An introduction with R_ , CRC press. 

- Yip, K. C. and Yau, K. K. (2005), “On modeling claim frequency data in general insurance with extra zeros,” _Insurance: Mathematics and Economics_ , 36, 153–163. 

- Zhang, T. and Yu, B. (2005), “Boosting with early stopping: Convergence and consistency,” _The Annals of Statistics_ , 1538–1579. 

- Zhang, W. (2011), “cplm: Monte Carlo EM algorithms and Bayesian methods for fitting Tweedie compound Poisson linear models,” _R package_ , `http://cran.r-project.org/ web/packages/cplm/index.html` . 

35 

