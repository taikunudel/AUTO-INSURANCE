## Journal of Computational and Graphical Statistics 

ISSN: 1061-8600 (Print) 1537-2715 (Online) Journal homepage: http://www.tandfonline.com/loi/ucgs20 

## Tweedie’s Compound Poisson Model With Grouped Elastic Net 

## Wei Qian, Yi Yang & Hui Zou 

To cite this article: Wei Qian, Yi Yang & Hui Zou (2016) Tweedie’s Compound Poisson Model With Grouped Elastic Net, Journal of Computational and Graphical Statistics, 25:2, 606-625, DOI: 10.1080/10618600.2015.1005213 

To link to this article:  http://dx.doi.org/10.1080/10618600.2015.1005213 

View supplementary material 

Accepted author version posted online: 06 Mar 2015. Published online: 10 May 2016. 

Submit your article to this journal 

Article views: 102 

View related articles 

View Crossmark data 

Full Terms & Conditions of access and use can be found at http://www.tandfonline.com/action/journalInformation?journalCode=ucgs20 

Download by: [McGill University Library] 

Date: 24 May 2016, At: 13:46 

_Supplementary materials for this article are available online. Please go to www.tandfonline.com/r/JCGS_ 

## **Tweedie’s Compound Poisson Model With Grouped Elastic Net** 

## Wei QIAN, Yi YANG, and Hui ZOU 

Tweedie’s compound Poisson model is a popular method to model data with probability mass at zero and nonnegative, highly right-skewed distribution. Motivated by wide applications of the Tweedie model in various fields such as actuarial science, we investigate the grouped elastic net method for the Tweedie model in the context of the generalized linear model. To efficiently compute the estimation coefficients, we devise a two-layer algorithm that embeds the blockwise majorization descent method into an iteratively reweighted least square strategy. Integrated with the strong rule, the proposed algorithm is implemented in an easy-to-use R package HDtweedie, and is shown to compute the whole solution path very efficiently. Simulations are conducted to study the variable selection and model fitting performance of various lasso methods for the Tweedie model. The modeling applications in risk segmentation of insurance business are illustrated by analysis of an auto insurance claim dataset. Supplementary materials for this article are available online. 

**Key Words:** Coordinate descent; Insurance score; IRLS-BMD; Lasso; Variable selection. 

## **1. INTRODUCTION** 

Tweedie’s compound Poisson model is known to model data with highly right-skewed distribution, which has probability mass at zero and nonnegative support. As an example, the histogram of an auto insurance claim data in Figure 1 has a spike at zero and a heavy right tail at the positive range (see Section 5 for a description of the data illustrated here). Specifically, the response _Y_ of the Tweedie’s compound Poisson model can be represented as 

**==> picture [208 x 30] intentionally omitted <==**

Wei Qian is Assistant Professor, School of Mathematical Sciences, Rochester Institute of Technology, Rochester, NY 14623 (E-mail: _wxqsma@rit.edu_ ). Yi Yang is Assistant Professor, Department of Mathematics and Statistics, McGill University, Canada (E-mail: _yi.yang6@mcgill.ca_ ) Hui Zou is Professor of Statistics, School of Statistics, University of Minnesota, Minneapolis, MN 55455 (E-mail: _zouxx019@umn.edu_ ). 

> ⃝C _2016 American Statistical Association, Institute of Mathematical Statistics, and Interface Foundation of North America_ 

> _Journal of Computational and Graphical Statistics, Volume 25, Number 2, Pages 606–625 DOI: 10.1080/10618600.2015.1005213_ 

**606** 

**607** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

Figure 1. Histogram of an auto insurance claim data. 

where _N_ is a Poisson random variable with mean _ξ_ , and conditional on _N_ , _Xi_ ’s (1 ≤ _i_ ≤ _N_ ) are iid Gamma( _α, γ_ ) distribution with mean _αγ_ and variance _αγ_[2] . When _N_ = 0, _Y_ = 0. From now on, we call the distribution of _Y_ the Tweedie distribution or the Tweedie model for simplicity. It is clear that the Tweedie distribution has positive probability mass at zero, since _P_ ( _Y_ = 0) = _P_ ( _N_ = 0) = exp(− _ξ_ ). 

The Tweedie distribution has attracted applications from diverse fields. For example, in actuarial science, _Y_ refers to the total claim loss of an insurance policy, _N_ is the number of claims, and _Xi_ (1 ≤ _i_ ≤ _N_ ) is the individual loss of the _i_ th claim (e.g., Smyth and Jørgensen 2002; Zhang 2013b). In meteorological studies, _Y_ can be the total weekly precipitation, _N_ is the number of rainfall events, and _Xi_ is the precipitation of the _i_ th event (e.g., Dunn 2004). Also, data with patterns of the Tweedie distribution often arise in ecological studies and political science analysis. A typical example of ecological studies is fishery survey, in which _Y_ is the total biomass of a particular fish species, _N_ is the fish count, and _Xi_ is the weight of the _i_ th fish (e.g., Shono 2008; Foster and Bravington 2013). In political science, the dollar outcomes ( _Y_ ) are often a result of an aggregation of a number of projects or grants (e.g., Lauderdale 2012). For a broader account of Tweedie model applications and their references, see also Dunn and Smyth (2005). 

The Tweedie model is known to be closely connected to the dispersion exponential model (Jørgensen 1987), which has the form 

**==> picture [263 x 23] intentionally omitted <==**

where _a_ (·) and _κ_ (·) are given functions, _θ_ is a parameter in R, and _φ_ is the dispersion parameter in (0 _,_ +∞). By the well-known property of exponential family distributions, ˙ ˙ ¨ _µ_ := _E_ ( _Y_ ) = _κ_ ( _θ_ ) and var( _Y_ ) = _φ_ ¨ _κ_ ( _θ_ ), where _κ_ ( _θ_ ) and _κ_ ( _θ_ ) are the first and second derivatives of _κ_ ( _θ_ ), respectively. If the mean-variance relation is specified to be var( _Y_ ) = ¨ _φµ[ρ]_ , where _ρ_ is the power parameter (1 _< ρ <_ 2), we have _κ_ ( _θ_ ) = _µ[ρ]_ , _θ_ = _µ_[1][−] _[ρ] /_ (1 − _ρ_ ), 

**608** 

W. QIAN, Y. YANG, AND H. ZOU 

and _κ_ ( _θ_ ) = _µ_[2][−] _[ρ] /_ (2 − _ρ_ ). Then (2) can be written as 

**==> picture [293 x 26] intentionally omitted <==**

By comparing the moment-generating functions (Smyth 1996), it is easy to see that models (1) and (3) are equivalent when _ξ_ = _µ_[2][−] _[ρ] /φ_ (2 − _ρ_ ), _α_ = (2 − _ρ_ ) _/_ ( _ρ_ − 1), and _γ_ = _φ_ ( _ρ_ − 1) _µ[ρ]_[−][1] . Note that _ρ_ = 1 corresponds to the Poisson distribution and _ρ_ = 2 corresponds to the Gamma distribution. We only consider the case that 1 _< ρ <_ 2, which is the primary interest of this article, although the derived algorithm in Sections 2 and 3 can be applied to the cases of _ρ_ = 1 and _ρ_ = 2 with some minor modifications (see also Section 5 for an application of the Gamma distribution modeling with the grouped elastic net). 

One of the most important questions in Tweedie model applications is how to explain the response by predictor variables. For example, in actuarial studies, it is important to understand how the policy holder’s characteristics are related to the expected claim loss. In precipitation modeling, the precipitation amount can be associated with the history weather record and other relevant climate measurements. The biomass in fishery studies can be determined by temporospatial factors and other fishery and environmental variables. The dollar outcomes in political science studies can be related to political and demographic variables. In the context of the generalized linear model, we assume that _µ_ is associated with a _p_ -dimensional predictor vector **x** ∈ R _[p]_ . Here we use the log link, that is, log( _µ_ ) = _β_ 0 + _**β**[T]_ **x** , where _β_ 0 is the intercept and _**β**_ ∈ R _[p]_ is the coefficient vector. Such log-linear relation generates a multiplicative structure that is convenient for explanatory analysis and is widely adopted in the aforementioned applications. More arguments for the use of a multiplicative model and the log link in GLM for insurance applications can be found in, for example, Murphy, Brockman, and Lee (2000) and Ohlsson and Johansson (2010, sec. 1.3). Let {( _yi,_ **x** _i_ ) _, i_ = 1 _,_ 2 _, . . . , n_ } be the iid observations with sample size _n_ . Further assume that _φ_ is the same for all observations. Then, the _negative_ log-likelihood can be written as 

**==> picture [297 x 31] intentionally omitted <==**

where _vi_ ’s (1 ≤ _i_ ≤ _n_ ) are the observation weights (by default, they are all equal to 1 _/n_ ). When the dimension of **x** is high, which is common in practice, a model selection technique has to be applied. For example, in insurance industry, it is common practice that hundreds and even thousands of variables are created for insurance policy pricing purposes. However, only a very small proportion of these variables are adopted in the final model. 

Among various model selection techniques, the lasso (Tibshirani 1996) is a very popular method that selects variables by shrinking some coefficient estimates to zero. Specifically, in the classical lasso setting, an _L_ 1 penalty of coefficients is imposed to a negative log-likelihood function or other relevant loss functions. The minimizer of such penalized likelihood function is known to achieve both variable selection and coefficient estimation. The existence of efficient algorithms such as LARS (Efron et al. 2004; see also Osborne, Presnell, and Turlach 2000) and coordinate descent (Tseng 2001; Friedman, Hastie, and Tibshirani 2010) makes the lasso an attractive competitor to other well-known model selection methods such as the stepwise or subset selection. Since the seminal work of Tibshirani 

**609** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

(1996), a variety of lasso-type penalized methods are studied to achieve better results in different situations. For example, the adaptive lasso proposed by Zou (2006) imposes different weights on _L_ 1 penalties of different variables, and achieves both variable selection consistency and estimation asymptotic normality. The elastic net proposed by Zou and Hastie (2005) applies _L_ 2 penalties in addition to _L_ 1 penalties, and better handles the situation that some variables are highly correlated with a “group”-like selection phenomenon. Another particularly interesting extension to the lasso is the grouped lasso (Yuan and Lin 2006). By partitioning the variable coefficients into blocks and imposing a so-called grouped lasso penalty (which may be viewed as an intermediate between _L_ 1 and _L_ 2 penalties), for a given block, the grouped lasso solution either selects all the variables in the block or shrinks all coefficients of the block to zero. Such property of the grouped lasso is particularly important when categorical variables with multiple levels are present (e.g., in ANOVA model, we group dummy variables corresponding to one categorical factor into one block) or when some variables are treated as nonparametric components (e.g., in additive model, the nonparametric components are approximated by a linear combination of some basis functions, and we group the basis function terms that correspond to one nonparametric component into one block). The estimation and/or variable selection consistency properties of the grouped lasso estimators for linear models are studied in, for example, Bach (2008), Nardi et al. (2008), Wang and Leng (2008), Huang and Zhang (2010), and Wei and Huang (2010). 

In spite of the important progress in lasso methods and the broad applications of the Tweedie model, as far as we know, no publication is made regarding applications of the Tweedie model variable selection with lasso methods in any of the aforementioned scientific context. This somewhat surprising vacancy may be partially attributable to the lack of awareness in the relevant scientific community and the lack of publicly available software that is efficiently implemented to give the lasso-type solutions for the Tweedie model. The main purpose of this article is to introduce a unified algorithm that can efficiently solve various lasso-type problems for the Tweedie model and use data examples to illustrate its variable selection and model fitting performance. In particular, we choose the grouped lasso and the grouped elastic net as the main theme for the algorithm derivation since their special cases also give regular lasso and elastic net solutions. We also allow different weights for grouped lasso penalties so that the corresponding adaptive versions of the solutions can be generated. 

Various algorithms have been studied for the grouped lasso usually under the linear regression and logistic regression settings. Yuan and Lin (2006) showed that the solution path of the grouped lasso solution is generally not piecewise linear, which implies that the LARS-type algorithms do not apply for the grouped lasso. Motivated by the shooting algorithm of Fu (1998), they proposed a blockwise coordinate descent algorithm for linear regression. However, their algorithm assumes a blockwise orthonormal condition, which is not always desirable in statistical applications. The study of the grouped lasso is extended to the logistic regression by Kim, Kim, and Kim (2006), who proposed a gradient descent algorithm to solve the constrained-form problem. Meier, Van De Geer, and B¨uhlmann (2008) also proposed a blockwise coordinate gradient descent (BCGD) algorithm for the grouped lasso of the logistic regression to directly solve the penalized-form problem. 

For efficient computation of the grouped elastic net for the Tweedie model, we propose a new blockwise coordinate descent algorithm that extends from the iteratively reweighted least square (IRLS) strategy (Friedman, Hastie, and Tibshirani 2010). A blockwise ma- 

**610** 

W. QIAN, Y. YANG, AND H. ZOU 

jorization descent (BMD) method is embedded into the IRLS strategy to solve the penalized weighted least square (WLS) problem. In addition, the strong rule (Tibshirani et al. 2012) is integrated to the algorithm to further speed up the computation of the whole solution path. The algorithm is implemented in an easy-to-use R package named HDtweedie, which is available in the online supplementary materials. 

As we mentioned before, one of the primary motivations resides in the promising applications in actuarial science. In particular, the regression functions obtained by Tweedie models with the grouped elastic net can serve as a candidate insurance score to achieve risk segmentation. Frees, Meyers, and Cummings (2011) proposed an ordered version of the Lorenze curve to identify the discrepancy between the loss distribution and the baseline insurance premium distribution. The associated Gini index is used to gauge the performance of an insurance score for risk segmentation. Typically, a larger Gini index implies better risk segmentation, hence the better insurance score and underlying statistical model. In our numerical studies, we use the Gini index of the ordered Lorenze curve as a specific model comparison tool. A brief description of the ordered Lorenze curve and the Gini index in the context of insurance risk segmentation is deferred to the real data example in Section 5, although the scope of their use may not be restricted to such context. 

The rest of the article is organized as follows. Section 2 describes the algorithm for solving the Tweedie model with the grouped elastic net penalty. The computation of the solution path and the application of the strong rule are explained in Section 3. The simulations and an insurance data example are presented in Sections 4 and 5, respectively. A brief conclusion is given in Section 6. 

## **2. ALGORITHM** 

Assume the _p_ -dimensional coefficient vector _**β**_ is partitioned into _g_ blocks, that is, _**β**_ = ( _**β**[T]_ 1 _[,]_ _**[ β]**[T]_ 2 _[, . . . ,]_ _**[ β]**[T] g_[)] _[T]_[ , where] _**[ β]** j_[(1][ ≤] _[j]_[≤] _[g]_[) is] _[ p][j]_[-dimensional vector and][ �] _[g] j_ =1 _[p][j]_[=] _[ p]_[. In] the following, we focus on the minimization problem with grouped elastic net penalties 

**==> picture [327 x 30] intentionally omitted <==**

where _λ >_ 0 and 0 _< τ_ ≤ 1 are tuning parameters, and _wj_ ’s (1 ≤ _j_ ≤ _g_ ) are the positive weights for the grouped lasso penalties. Conforming to common practice, we do not penalize the intercept term _β_ 0. Note that the grouped elastic net penalty used above is very general for solving lasso-type problems. Indeed, if _pj_ = 1 for all 1 ≤ _j_ ≤ _g_ , the problem is reduced to the (adaptive) lasso when _τ_ = 1, and the (adaptive) elastic net when 0 _< τ <_ 1. If _τ_ = 1 and _pj >_ 1 for some _j_ , we have the (adaptive) grouped lasso problem. In the R package HDtweedie, the default choice of the observation weights _vi_ ’s (1 ≤ _i_ ≤ _n_ ) and the grouped lasso penalty weights _wj_ ’s (1 ≤ _j_ ≤ _g_ ) are 1 _/n_ and[√] _pj_ , respectively. The users can choose different values for _vi_ ’s and _wj_ ’s to meet their specific application needs. 

The proposed algorithm essentially consists of two layers of loops. The outer layer is the IRLS strategy, which, at each iteration, approximates the objective function in (5) by a penalized WLS objective function. After obtaining the minimizer of the penalized WLS objective function, the next iteration begins by updating the working response and 

**611** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

weight. Such outer-layer cycle continues until convergence. The inner layer is dedicated to obtaining the minimizer of the penalized WLS objective function by a BMD method. For simplicity, we call this two-layer strategy IRLS-BMD algorithm. 

Specifically, for the outer-layer IRLS strategy, suppose ( _β_[˜] 0 _,_ _**β**_[˜] ) is the solution of ( _β_ 0 _,_ _**β**_ ) from the most recent iteration. We approximate the negative log-likelihood _l_ ( _β_ 0 _,_ _**β**_ ) by the second-order Taylor expansion of _l_ ( _β_ 0 _,_ _**β**_ ) about ( _β_[˜] 0 _,_ _**β**_[˜] ): 

**==> picture [358 x 159] intentionally omitted <==**

where 

**==> picture [302 x 47] intentionally omitted <==**

and _C_ 1( _β_[˜] 0 _,_ _**β**_[˜] ) is a constant given ( _β_[˜] 0 _,_ _**β**_[˜] ). Therefore, we can rewrite (6) in the form of _n_ a WLS function _lQ_ ( _β_ 0 _,_ _**β**_ ) =[1] 2 � _i_ =1 _[v]_[˜] _[i]_[( ˜] _[y][i]_[−] _[β]_[0][ −] _**[β]**[T]_ **[ x]** _[i]_[)][2][ +] _[ C]_[( ˜] _[β]_[0] _[,]_ _**[β]**_[˜][),][where] _[C]_[( ˜] _[β]_[0] _[,]_ _**[β]**_[˜][)][is] a constant given ( _β_[˜] 0 _,_ _**β**_[˜] ). Here, we call _v_ ˜ _i_ and _y_ ˜ _i_ the working weight and the working response, respectively. Then, the penalized WLS objective function we intend to minimize is 

**==> picture [314 x 31] intentionally omitted <==**

The minimizer of (8) is used as the new ( _β_[˜] 0 _,_ _**β**_[˜] ) to update the working response and weight of _lQ_ ( _β_ 0 _,_ _**β**_ ) to start a new IRLS iteration. 

To find the minimizer of (8), we resort to the inner-layer loops, which employs a BMD method that sequentially updates the coefficients of each block by taking advantage of a majorization-minimization (MM) principle (see Wu et al. (2010) for a recent overview of the MM principle). In the following, we present the inner-layer BMD algorithm and its properties. 

Given observation _i_ (1 ≤ _i_ ≤ _n_ ), partitioning **x** _i_ the same way as _**β**_ , we have **x** _i_ = ( **x** _[T] i_ 1 _[,]_ **[ x]** _[T] i_ 2 _[, . . . ,]_ **[ x]** _[T] ig_[)] _[T]_[ ,][where] **[x]** _[ij]_[(1][ ≤] _[j]_[≤] _[g]_[)][is][the] _[p][j]_[-dimensional][predictor][vector][corre-] sponding to _**β** j_ . For 1 ≤ _j_ ≤ _g_ , denote the gradient vector and the Hessian matrix of 

**612** 

W. QIAN, Y. YANG, AND H. ZOU 

_lQ_ ( _β_ 0 _,_ _**β**_ ) with respect to _**β** j_ by 

**==> picture [295 x 65] intentionally omitted <==**

respectively. Let _γ_ ˜ _j_ (1 ≤ _j_ ≤ _g_ ) be the largest eigenvalue of _H_[˜] _j_ . 

To update the block _j_ coefficients (1 ≤ _j_ ≤ _g_ ), suppose ( _β_[˘] 0 _,_ _**β**_[˘] ) is the most recently updated estimate and define _U_[˘] _j_ = _U_[˜] _j_ ( _β_[˘] 0 _,_ _**β**_[˘] ). We update _**β**_[˘] _j_ by solving 

**==> picture [302 x 52] intentionally omitted <==**

which has a closed-form solution. Indeed, if we denote the solution of (11) by _**β**_[˘] _j_ (new), it is not hard to see by the Karush-Kuhn-Tucker (KKT) conditions that 

**==> picture [273 x 35] intentionally omitted <==**

where _z_ + denotes the positive part of _z_ . Similarly, to update the intercept term, define ˘ _T_ ˜ ˜ _n U_ then updated by0 = −[�] _[n] i_ =1 _[v]_[˜] _[i]_[( ˜] _β[y]_[˘] 0 _[i]_ (new)[−] _[β]_[˘][0][ −] = _**[β]** β_[˘][˘] 0 **x** − _i_ ) and _γ_ ˜0[−][1] _U_ ˘ _γ_ 00. Such BMD updates cycle through all the blocks= _H_ 0 =[�] _i_ =1 _[v]_[˜] _[i]_[. The intercept coefficient] _[β]_[˘][0][is] and the intercept sequentially until convergence, resulting in the minimizer of (8). 

The update in (11) is justified by the fact that the updated value of the given penalized WLS objective function (8) always decreases. Indeed, given a block _j_ (1 ≤ _j_ ≤ _g_ ), suppose ( _β_[˘] 0 _,_ _**β**_[˘] (new)) is the updated vector from ( _β_[˘] 0 _,_ _**β**_[˘] ) by (11). Then, 

**==> picture [353 x 78] intentionally omitted <==**

where the last inequality follows by the fact that _H_[˜] _j_ is a positive definite matrix, and _γ_ ˜ _j_ is its largest eigenvalue. Therefore, 

**==> picture [117 x 13] intentionally omitted <==**

**==> picture [313 x 83] intentionally omitted <==**

**613** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

**==> picture [252 x 71] intentionally omitted <==**

where the first inequality follows by (13) and the second inequality follows by the update scheme (11). Similarly, the downhill-going property that _PQ_ ( _β_[˘] 0(new) _,_ _**β**_[˘] ) ≤ _PQ_ ( _β_[˘] 0 _,_ _**β**_[˘] ) also holds for the intercept update. 

The IRLS-BMD algorithm described above is summarized in Algorithm 1. 

**Algorithm 1:** The IRLS-BMD algorithm for solving the Tweedie model grouped elastic net. 

1. Initialize _**β**_[˜] 0 and _**β**_[˜] . 

2. (Outer layer) Update the penalized WLS objective function (8). 

   - For _i_ = 1 _,_ 2 _, . . . , n_ , compute the working response _y_ ˜ _i_ and the working weight _v_ ˜ _i_ by (7). 

   - For _j_ = 1 _, . . . , g_ , compute _H_[˜] _j_ and its maximum eigenvalue _γ_ ˜ _j_ by (10); compute _γ_ ˜0 = _H_[˜] 0 =[�] _[n] i_ =1 _[v]_[˜] _[i]_[.] 

3. (Inner layer) Apply the BMD algorithm to obtain the minimizer of the penalized WLS objective function (8). 

   - Initialize _β_[˘] 0 = _β_[˜] 0 and _β_[˘] = _β_[˜] . 

   - Repeat the following updating scheme until ( _β_[˘] 0 _,_ _**β**_[˘] ) converges. 

   - Update _**β**_[˘] . For _j_ = 1 _,_ 2 _, . . . , g_ , do 

      - ∗ Compute _U_[˘] _j_ = _U_[˜] _j_ ( _**β**_[˘] 0 _,_ _**β**_[˘] ) by (9). 

      - ∗ Compute _**β**_[˘] _j_ (new) by (12). 

      - ∗ Set _**β**_[˘] _j_ = _**β**_[˘] _j_ (new). 

   - Update _β_ 0. Do 

**==> picture [190 x 15] intentionally omitted <==**

**==> picture [148 x 13] intentionally omitted <==**

      - ∗ Set _**β**_[˘] 0 = _**β**_[˘] 0(new). 

   - Set _β_[˜] 0 = _β_[˘] 0 and _**β**_[˜] = _**β**_[˘] . 

4. Repeat Steps 2–3 until ( _β_[˜] 0 _,_ _**β**_[˜] ) converges. 

**614** 

W. QIAN, Y. YANG, AND H. ZOU 

## **3. SOLUTION PATH AND STRONG RULE** 

As a common practice for lasso-type methods, we want to solve the solution path of the grouped elastic net rather than only giving the solution for one _λ_ value. Specifically, given _τ_ , we consider a decreasing sequence of _λ_ values { _λk, k_ = 1 _, . . . , m_ }. The grouped elastic ( _k_ ) net solution (5) of _λk_ is denoted by ( _β_[ˆ] 0[(] _[k]_[)] _[,]_ _**[β]**_[ˆ] ). The sequence { _λk, k_ = 1 _, . . . , m_ } is created by choosing a grid of _m_ points uniformly in log scale on [ _λm, λ_ 1], where _λm_ is a fixed small proportion of _λ_ 1, and _λ_ 1 is chosen to be the smallest value such that _**β**_[ˆ] = **0** . The default in the R package HDtweedie is _m_ = 100, _λm_ = 0 _._ 001 _λ_ 1 if _p_ ≤ _n_ and _λm_ = 0 _._ 05 _λ_ 1 if _p > n_ . 

To compute the whole solution path, we start with the computation of _λ_ 1 and ( _β_[ˆ] 0[(1)] _[,]_ _**[β]**_[ˆ] (1)). By definition of _λ_ 1, _**β**_[ˆ] (1) = **0** . The intercept estimate _β_ ˆ0(1) can be easily obtained by the _β_ 0 updating scheme in Algorithm 1. That is, we first initialize _β_[˜] 0 = 0 and _**β**_[˜] = **0** , and then repeatedly update _β_[˜] 0 until convergence with the following steps: (a) compute the _T_ working _γ_ ˜0 =[�] _[n] i_ =response1 _[v]_[˜] _[i]_[;][(c)][compute] and weight _[β]_[˜][0][(new)] by (7);[ =] (b) _[β]_[˜][0][ −] compute _[γ]_[˜][ −] 0[1] _U_ ˜ 0 _U_ ;[˜] (d)0 = −set[�] _β_ ˜0 _[n] i_ ==1 _[v] β_[˜] ˜ _[i]_ 0[( ˜] (new). _[y][i]_[−] _[β]_[˜][0] Subsequently,[ −] _**[β]**_[˜] **x** _i_ ) and (1) _λ_ 1 is obtained by the KKT conditions that _λ_ 1 = max1≤ _j_ ≤ _g_ ∥ _Uj_ ( _β_[ˆ] 0[(1)] _[,]_ _**[β]**_[ˆ] )∥2 _/τwj_ , where _Uj_ ( _β_ 0 _,_ _**β** j_ ) is the gradient vector of _l_ ( _β_ 0 _,_ _**β**_ ) with respect to _**β** j_ that 

**==> picture [290 x 28] intentionally omitted <==**

With _λ_ 1 and ( _β_[ˆ] 0[(1)] _[,]_ _**[β]**_[ˆ] (1)) at hand, we can determine the decreasing sequence of _λk_ ’s and compute the grouped elastic net solutions sequentially by Algorithm 1. At each _λk_ (2 ≤ _k_ ≤ _m_ ), the algorithm is “warm-started” by setting the initial coefficient estimate to be ( _β_[ˆ] 0[(] _[k]_[−][1)] _,_ _**β**_[ˆ] ( _k_ −1)), the solution of the preceding _λ_ . In addition, we apply on top of Algorithm 1 the strong rule (Tibshirani et al. 2012), which is known to be a very effective technique to save computing time by guessing the likely zero-coefficient estimates at the beginning of the algorithm and discarding them from the updating scheme. Tibshirani et al. (2012) showed that such practice is amazingly safe, and very rarely gives violations of the guess in linear regression and logistic regression. In the context of the grouped elastic net, the strong rule states that given 2 ≤ _k_ ≤ _m_ and 1 ≤ _j_ ≤ _g_ , if 

**==> picture [268 x 15] intentionally omitted <==**

then _**β**_[ˆ] ( _jk_ ) (the block _j_ coefficient estimate at _λk_ ) is very likely to be zero. At _λk_ , let _S_ be the set of _j_ ’s (1 ≤ _j_ ≤ _g_ ) such that (14) is _not_ satisfied. Let **x** _iS_ (1 ≤ _i_ ≤ _n_ ) be the subvector of **x** _i_ that contains only variables of blocks in _S_ . Then the strong rule statement implies that Algorithm 1 can be applied to the reduced dataset {( _yi,_ **x** _iS_ ) _, i_ = 1 _, . . . , n_ } to estimate _β_ 0 and the coefficients of _xiS_ , while estimated coefficients for blocks in _S[c]_ are set to be zero. We denote such obtained strong rule estimate of ( _β_ 0 _,_ _**β**_ ) by ( _β_[˜] 0[(][∗][)] _[,]_ _**[β]**_[˜] (∗)). To check if the strong rule correctly identifies the zero estimates, we have to apply a KKT condition check, that is, if ( _β_[˜] 0[(][∗][)] _[,]_ _**[β]**_[˜] (∗)) is the correct solution, then for every _j_ ∈ _S[c]_ , ∥ _Uj_ ( _β_[˜] 0[(][∗][)] _[,]_ _**[β]**_[˜] (∗))∥2 ≤ _λkτwj_ . Define _V_ = { _j_ ∈ _Sc_ : ∥ _Uj_ ( ˜ _β_ 0(∗) _[,]_ _**[β]**_[˜] (∗))∥2 _> λkτwj_ }, the 

**615** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

set of blocks in _S[c]_ that does not pass the KKT condition check. If _V_ = ∅, the correct solution is obtained. Otherwise, add all the elements in _V_ to _S_ , and repeat Algorithm 1 on the new reduced dataset followed by the KKT condition check until we find the correct solution. It turns out that the strong rule works very well for the Tweedie model, and the computing time can often be significantly reduced (see numerical results in Section 4). 

The algorithm with the strong rule for the grouped elastic net solution at _λk_ (2 ≤ _k_ ≤ _m_ ) is summarized in Algorithm 2. 

**Algorithm 2:** The algorithm with the strong rule for solving the Tweedie model grouped elastic net at _λk_ (2 ≤ _k_ ≤ _m_ ). 

1. Identify the set of groups for the updating scheme by the strong rule: 

**==> picture [307 x 35] intentionally omitted <==**

3. Apply Algorithm 1 on the reduced dataset {( _yi,_ **x** _iS_ ) _,_ 1 ≤ _i_ ≤ _n_ } to obtain the strong rule estimate ( _β_[˜] 0[(][∗][)] _[,]_ _**[β]**_[˜] (∗)). 

4. Perform the KKT condition check and identify the set of blocksthat fails the check: 

**==> picture [175 x 14] intentionally omitted <==**

**==> picture [360 x 29] intentionally omitted <==**

## **4. SIMULATION** 

In the simulation study, we intend to investigate the performance of the Tweedie model with lasso, grouped lasso, and grouped elastic net methods using the following two examples. 

## **4** _**.**_ **1 EXAMPLE 1** 

In each run of the simulation, we sample 500 observations for both the training and testing datasets. The design matrix is created as follows. First, sample eight-dimensional covariates **T** = ( _T_ 1 _, . . . , T_ 8) from a certain distribution scenario. Then, similar to simulation settings of Kim et al. (2006), each covariate _Tj_ ( _j_ = 1 _, . . . ,_ 8) generates three polynomial terms _p_ 1( _Tj_ ), _p_ 2( _Tj_ ), and _p_ 3( _Tj_ ), where _p_ 1( _x_ ) = _x_ , _p_ 2( _x_ ) = (3 _x_[2] − 1) _/_ 6, and _p_ 3( _x_ ) = (5 _x_[3] − 3 _x_ ) _/_ 10. The design matrix is formed by the resulting 24 terms. Naturally, we assign _p_ 1( _Tj_ ), _p_ 2( _Tj_ ), and _p_ 3( _Tj_ ) to the same block ( _j_ = 1 _, . . . ,_ 8). The response is generated by the Tweedie model with _ρ_ = 1 _._ 5 and _φ_ = 1 (with different scenarios considered). Then, the Tweedie models with lasso, grouped lasso, and grouped elastic net methods are fitted using the training dataset. The tuning parameter _λ_ is selected by the five-fold cross-validations with deviance. For the grouped elastic net, the additional tuning parameter _τ_ is selected from {0 _._ 1 _,_ 0 _._ 2 _, . . . ,_ 1 _._ 0}. 

**616** 

W. QIAN, Y. YANG, AND H. ZOU 

To compare the variable selection performance, we consider the blocks of the covariates and say that the block of a covariate is identified as active if at least one of the estimated coefficients in this block is nonzero. Similarly, we consider the individual predictor terms and say that a predictor term is identified as active if its estimated coefficient is nonzero. With the fitted models, we count the number of correctly identified active blocks (block-C) and the number of incorrectly identified active blocks (block-IC). In addition, we consider the coefficients of the individual terms, and count the number of correctly identified active coefficients (coefficient-C) and the number of incorrectly identified active coefficients (coefficient-IC). Also, we use the testing dataset to calculate the negative log-likelihood score and the Gini index (see Section 5 for a brief description of the Gini index). The experiment is repeated 100 times to obtain the averaged values for the aforementioned model fitting measurements. In the following, we consider three different cases for the distribution of covariates **T** and the link function. 

_4.1.1 Case 1._ We assume that **T** is multivariate normal with the mean being **0** and the variance matrix being a compound symmetry correlation matrix _�_ 1. Let ( _�_ 1) _ij_ = _ω_ ( _i_ ̸= _j,_ and _i, j_ = 1 _, . . . ,_ 8), where _ω_ = 0 or 0.5. The link function is 

**==> picture [268 x 32] intentionally omitted <==**

Clearly, the true model has three relevant blocks and nine relevant predictor terms. The simulation results are summarized in Table 1 (values in the parenthesis are standard errors). 

Since the link function is specified to have an explicit blockwise structure, there is no surprise that the grouped lasso and the grouped elastic net have better variable selection results than the lasso by identifying more relevant blocks and less irrelevant blocks. The grouped lasso and the grouped elastic net also show some advantages over the lasso when comparing the negative log-likelihood and the Gini index. As expected, coefficient-C and coefficient-IC show that for the grouped lasso and the grouped elastic net, all estimated coefficients of an active block are nonzero, while for the lasso, some estimated coefficients of an active block may be zero. In addition, the grouped elastic net appears to choose more blocks than the grouped lasso. Such feature of the grouped elastic net can be appealing in some situations, as shown in the next case. 

_4.1.2 Case 2._ This case is inspired by the simulation results of the elastic net in Zou and Hastie (2005). Let **Z** = ( _Z_ 1 _, . . . , Z_ 6) be a multivariate normal random variable with the mean being **0** and the variance being a compound symmetry correlation matrix _�_ 2. Let ( _�_ 2) _ij_ = _ω_ ( _i_ ̸= _j,_ and _i, j_ = 1 _, . . . ,_ 6), where _ω_ = 0 or 0.5. Then **T** is generated by _T_ 1 = _Z_ 1 + _ε_ 1, _T_ 2 = _Z_ 1 + _ε_ 2, _T_ 3 = _Z_ 1 + _ε_ 3, and _Tj_ = _Zj_ −2 ( _j_ = 4 _, . . . ,_ 8), where _ε_ 1, _ε_ 2, _ε_ 3 are Normal(0, 0.01). The link function remains the same as that of Case 1. Under this setting, _T_ 1, _T_ 2, and _T_ 3 are highly correlated, and their blocks are all active in the true model. 

Based on the results summarized in Table 1, it is interesting to see that the grouped elastic net correctly identifies almost all three relevant blocks (averaged block-C: 2.77 and 2.89), while the grouped lasso on average misses more than one relevant blocks (averaged block-C: 1.88 and 1.83). Such phenomenon shows the ability of the grouped elastic net to better handle the correlated covariates (and the blocks generated from them), which is 

**617** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

Table 1. (Example 1) Averaged simulation results based on 100 runs 

||Block-<br>C<br>IC|Coeffcient-<br>Negative<br>C<br>IC<br>log-likelihood<br>Gini index|
|---|---|---|
|||Case 1|
|Oracle<br>_ω_=0<br>Lasso<br>Grouped lasso<br>Grouped elastic net<br>_ω_=0_._5<br>Lasso<br>Grouped lasso<br>Grouped elastic net|3<br>0<br>2.95<br>0.80<br>3.00<br>0.26<br>3.00<br>0.69<br>2.86<br>1.21<br>2.87<br>0.60<br>2.94<br>1.08|9<br>0<br>—<br>—<br>5.65<br>0.87<br>45 (22)<br>0.961 (0.011)<br>9.00<br>0.78<br>33 (14)<br>0.972 (0.003)<br>9.00<br>2.07<br>35 (15)<br>0.975 (0.002)<br>5.25<br>1.25<br>46 (22)<br>0.961 (0.012)<br>8.61<br>1.80<br>37 (17)<br>0.961 (0.012)<br>8.82<br>3.24<br>35 (15)<br>0.963 (0.012)<br>Case 2|
|Oracle<br>_ω_=0<br>Lasso<br>Grouped lasso<br>Grouped elastic net<br>_ω_=0_._5<br>Lasso<br>Grouped lasso<br>Grouped elastic net|3<br>0<br>1.94<br>0.18<br>1.88<br>0.04<br>2.77<br>0.11<br>2.01<br>0.49<br>1.83<br>0.07<br>2.89<br>0.39|9<br>0<br>—<br>—<br>2.78<br>0.18<br>11.5 (2.0)<br>0.896 (0.011)<br>5.64<br>0.12<br>9.1 (0.7)<br>0.898 (0.010)<br>8.31<br>0.33<br>8.8 (0.6)<br>0.899 (0.010)<br>2.84<br>0.49<br>23 (12)<br>0.914 (0.009)<br>5.49<br>0.21<br>14 (4)<br>0.916 (0.009)<br>8.67<br>1.17<br>13 (3)<br>0.916 (0.009)<br>Case 3|
|Oracle<br>_ω_=0<br>Lasso<br>Grouped lasso<br>Grouped elastic net<br>_ω_=0_._5<br>Lasso<br>Grouped lasso<br>Grouped elastic net|6<br>0<br>6.00<br>0.51<br>6.00<br>0.85<br>6.00<br>1.23<br>6.00<br>0.63<br>6.00<br>0.94<br>6.00<br>1.22|6<br>0<br>—<br>—<br>6.00<br>4.42<br>5.63 (0.02)<br>0.604 (0.003)<br>6.00<br>14.55<br>5.64 (0.02)<br>0.599 (0.003)<br>6.00<br>15.69<br>5.64 (0.02)<br>0.599 (0.003)<br>6.00<br>4.26<br>5.137 (0.017)<br>0.447 (0.002)<br>6.00<br>14.82<br>5.151 (0.017)<br>0.441 (0.002)<br>6.00<br>15.66<br>5.146 (0.017)<br>0.442 (0.002)|



reminiscent of the unique property of the elastic net (Zou and Hastie 2005). From a practical viewpoint, the grouped elastic net reveals more relevant (and possibly highly correlated) covariates to an analyst so that a larger pool of variables is available for further investigation. Also, similar to Case 1, the grouped lasso and the grouped elastic net perform better than the lasso in terms of the negative log-likelihood and the Gini index, as is expected from the structure of the link function. 

_4.1.3 Case 3._ In this case, we intentionally use the link function that favors the lasso: 

**==> picture [136 x 32] intentionally omitted <==**

The distribution of **T** is the same as Case 1. Under this scenario, the true model has six relevant blocks and six relevant predictor terms. As summarized in Table 1, while all three methods correctly recover all six relevant blocks, the Gini index shows that the lasso is favored over the grouped lasso. 

**618** 

W. QIAN, Y. YANG, AND H. ZOU 

Table 2. Comparing the computing time (in seconds) with and without the strong rule 

|Strong rule|_q_|=|0|_q_|=10|_q_ =100|_q_ =500|_q_ =1000|
|---|---|---|---|---|---|---|---|---|
|No||2.5|||3.6|12.6|26.7|56.7|
|Yes||2.1|||3.1|11.1|11.7|26.7|



Recall that the strong rule is integrated into the proposed algorithm. Next, we use settings of Case 3 to evaluate the computing time reduction due to the strong rule. For evaluation of higher-dimensional situations, we add _q_ more irrelevant variables into the original design matrix ( _q_ = 0 _,_ 10 _,_ 100 _,_ 500 _,_ 1000). The distribution of these irrelevant variables are iid Normal(0,1). Using the covariate **T** with _ω_ = 0 _._ 5, the enlarged designed matrix, and the same link function, we fit Tweedie models with the lasso, and record the total computing time based on five runs of the experiment. For comparison, we remove the strong rule from the algorithm and repeat the experiment under exactly the same setting. From the results summarized in Table 2, we can see that the algorithm with the strong rule consistently has shorter computing time than its counterpart without the strong rule. The effects of the strong rule in terms of time saving become even more apparent as the predictor dimension grows larger. The corresponding variable selection results are given in Table 3, which satisfactorily show that the number of incorrectly identified active variables grows only moderately as _q_ increases. 

## **4** _**.**_ **2 EXAMPLE 2** 

In this example, we provide numerical comparisons between our method and some existing model selection methods. We consider a 20-dimensional covariate example. Assume the covariate **X** = ( _X_ 1 _, X_ 2 _, . . . , X_ 20) is multivariate normal with the mean being **0** and the variance matrix being an exponential decay correlation matrix _�_ . Let ( _�_ ) _i,j_ = _ω_[|] _[i]_[−] _[j]_[|] ( _i, j_ = 1 _, . . . ,_ 20), where _ω_ = 0 or 0.5. Different from the idealized settings of Example 1 where the (nonparametric) component of each covariate in the link function can be expanded by up to third-degree polynomials, we consider in Example 2 the following link functions for data generation: (Case 1) log _µ_ =[�][12] _j_ =1 _[g]_[1][(] _[X][j]_[);] (Case 2) log _µ_ =[�][8] _j_ =1 _[g]_[2][(] _[X][j]_[)][ +][ �][12] _j_ =9 _[g]_[1][(] _[X][j]_[),][where] _[g]_[1][(] _[x]_[)][ =][ 10][4] _[x]_[3][(1][ −] _[x]_[)][6][[][40] 3 _[x]_[8][ +] 32[(1][ −] _[x]_[)][4][]] _[I]_[(0][ ≤] _[x]_[≤][1)][and] _[g]_[2][(] _[x]_[)][ = {][2 sin(4] _[πx]_[)][ −][6[][|] _[x]_[−][0] _[.]_[4][|][0] _[.]_[3][ −][1] _[.]_[1]][ −][0] _[.]_[5sgn(0] _[.]_[7][ −] _x_ )} _I_ (0 ≤ _x_ ≤ 1). The plots for _g_ 1(·) and _g_ 2(·) are given in Figure 2. With the link functions above, the response is generated by the Tweedie model with _ρ_ = 1 _._ 5 and _φ_ = 1. We sample 100 observations for the training dataset and 300 observations for the testing dataset. 

Table 3. Variable selection results obtained in the computing time study 

||_q_|=|0|_q_|=10|_q_ =100|_q_ =500|_q_ =1000|
|---|---|---|---|---|---|---|---|---|
|Block-C||6.0|||6.0|6.0|6.0|6.0|
|Block-IC||1.0|||1.4|3.2|5.6|9.4|



**619** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

Figure 2. Plots for functions _g_ 1 and _g_ 2. 

To fit the training dataset with the proposed methods, we create the design matrix by expanding each covariate to cubic B-splines with eight degrees of freedom. The resulting design matrix has 160 terms, and we can naturally assign the eight terms of each covariate into one block. Then, we fit the data using the Tweedie models with lasso, grouped lasso, and grouped elastic net (the tuning parameters are selected the same way as described in Example 1). For comparison, we also implement the backward–forward stepwise selection method for the Tweedie model, which is commonly used in actuarial studies for variable selection purposes (R code for the stepwise selection is available online in the supplementary materials; the default _p_ -values for entering and removal of a covariate are set to be 0.05 and 0.10, respectively). 

The procedures described above is repeated 100 times, and the results are summarized in Table 4. We can see in this example that under almost all considered scenarios, the estimation performance of the grouped elastic net is significantly better than that of the lasso, the grouped lasso, and the stepwise method in terms of both negative log-likelihood and Gini index. As expected, the stepwise method performs poorly in both variable selection and estimation due to its inability to allow flexible nonlinear structure. 

## **5. REAL DATA EXAMPLE** 

In this section, we use an auto insurance claim dataset studied in Yip and Yau (2005) and Zhang (2013a) to illustrate applications and performance of the Tweedie model with the grouped elastic net. The response ( _y_ ) we want to predict is the aggregate claim loss of an auto insurance policy. Similar to the data treatment performed by Yip and Yau (2005) and Zhang (2013a), we only consider the new customers in the dataset and transform the response by _y_[∗] = _y/_ 1000. Then, the reduced dataset has 2812 insurance policy records, among which 60.7% of the policies has no claims (i.e., _y_[∗] = 0). The histogram of _y_[∗] is shown in Figure 1. The data also contains 21 predictor variables associated with the vehicle and the policy holder: number of children passengers ( _x_ 1), time to travel from home to work ( _x_ 2), whether the car is for commercial use ( _x_ 3), car value ( _x_ 4), number of policies ( _x_ 5), car type ( _x_ 6, six categories), whether the car color is red ( _x_ 7), whether the driver’s license 

**620** 

W. QIAN, Y. YANG, AND H. ZOU 

Table 4. (Example 2) Averaged simulation results based on 100 runs 

||Block-<br>Negative<br>C<br>IC<br>log-likelihood<br>Gini index|
|---|---|
||Case 1|
|Oracle<br>_ω_=0<br>Lasso<br>Grouped lasso<br>Grouped elastic net<br>Stepwise<br>_ω_=0_._5<br>Lasso<br>Grouped lasso<br>Grouped elastic net<br>Stepwise|12<br>0<br>—<br>—<br>2.00<br>0.28<br>2135 (9)<br>0.092 (0.011)<br>1.88<br>0.28<br>2135 (9)<br>0.087 (0.011)<br>5.78<br>1.78<br>2114 (9)<br>0.209 (0.011)<br>1.03<br>0.41<br>2231 (16)<br>0.019 (0.006)<br>1.73<br>0.22<br>2160 (10)<br>0.104 (0.013)<br>1.92<br>0.19<br>2154 (10)<br>0.124 (0.013)<br>6.95<br>1.83<br>2108 (11)<br>0.290 (0.010)<br>1.27<br>0.25<br>2236 (14)<br>0.071 (0.007)<br>Case 2|
|Oracle<br>_ω_=0<br>Lasso<br>Grouped lasso<br>Grouped elastic net<br>Stepwise<br>_ω_=0_._5<br>Lasso<br>Grouped lasso<br>Grouped elastic net<br>Stepwise|12<br>0<br>—<br>—<br>2.94<br>0.29<br>2305 (10)<br>0.125 (0.011)<br>3.36<br>0.41<br>2301 (10)<br>0.144 (0.013)<br>7.76<br>2.21<br>2270 (10)<br>0.267 (0.009)<br>1.00<br>0.33<br>2380 (13)<br>0.029 (0.005)<br>4.24<br>0.42<br>2302 (10)<br>0.210 (0.014)<br>3.77<br>0.28<br>2306 (10)<br>0.199 (0.014)<br>9.23<br>2.43<br>2251 (10)<br>0.354 (0.006)<br>1.81<br>0.31<br>2398 (11)<br>0.128 (0.005)|



was revoked in the past ( _x_ 8), motor vehicle record (MVR) point ( _x_ 9), age ( _x_ 10), number of children at home ( _x_ 11), years on job ( _x_ 12), income ( _x_ 13), gender ( _x_ 14), whether married ( _x_ 15), whether a single parent ( _x_ 16), job class ( _x_ 17, eight categories), education level ( _x_ 18, five categories), home value ( _x_ 19), years in current address ( _x_ 20), and whether the driver lives in urban area ( _x_ 21). 

We transform _x_ 4[∗][=][ log] _[ x]_[4][,] _[x]_ 13[∗][=][ log(] _[x]_[13][ +][ 10),][and][scale][all][the][numerical][variables] (except for _x_ 1, _x_ 5, _x_ 9, and _x_ 11) to have mean 0 and standard deviation 1. The polynomial terms (up to the third order) of the 11 numerical variable are created the same way as we do in the simulations. These polynomial terms of each variable are treated as one coefficient block for the grouped lasso and the grouped elastic net. For the categorical variables with more than two levels ( _x_ 6 _, x_ 17 _, x_ 18), we treat the first level (by alphabetical order) as the base level, and create dummy variables accordingly for the other levels. Naturally, the dummy variables belonging to the same categorial variable are treated as one block. In addition, binary variables (0–1) are created for categorical variables with two levels ( _x_ 3 _, x_ 7 _, x_ 8 _, x_ 14 _, x_ 15 _, x_ 16 _, x_ 21). 

The entire dataset is then randomly partitioned into a training set and a testing set with equal sample size. The training set is used to fit the Tweedie models with the grouped lasso (GrpLasso) and the grouped elastic net (GrpNet). Besides Tweedie models, another popular approach in analyzing insurance loss data is to model the frequency (whether a claim occurs) and severity (the amount of claim loss if a claim occurs) separately. 

**621** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

Table 5. The averaged number of active variables and the averaged Gini index in the auto insurance claim data example 

|GrpLasso<br>GrpNet|LogGam<br>Frequency<br>Severity<br>YY<br>WZ|
|---|---|
|NAV<br>4.9<br>6.2<br>Gini index<br>0.462 (0.007)<br>0.463 (0.008)|3.6<br>3.6<br>—<br>—<br>0.460 (0.008)<br>0.156 (0.009)<br>0.360 (0.007)|



Specifically, we first fit a logistic regression with the grouped lasso to model whether a claim occurs (frequency submodel); then we consider only the records with positive claim loss and fit a Gamma model with the grouped lasso for the claim loss (severity submodel). We refer to this two-component model as LogGam for short. The R package gglasso (Yang and Zou 2014) is used to fit the logistic regression with the grouped lasso. For the Gamma model with the grouped lasso, since it is a special case of the Tweedie model with _ρ_ = 2, our implementation described in the previous sections still applies. The aforementioned models select their tuning parameters by cross-validations as we do for the simulations. For comparison, we fit a regular Tweedie model with only the main effect variables considered in Yip and Yau (2005): _x_ 3, _x_ 13, _x_ 14, _x_ 15, and _x_ 21 (for short, we call it YY model). Similarly, another regular Tweedie model is fitted with only the main effect variables considered in Zhang (2013a): _x_ 3, _x_ 9, _x_ 13, _x_ 15, and _x_ 21 (for short, we call it WZ model). For simplicity, we set _ρ_ = 1 _._ 7 for all the Tweedie models in this section (the value of _ρ_ appears to have little influence on the results, the details of which are thus omitted). After fitting the models with the training set, we count the number of active variables (NAV for short), and use the testing set to calculate the Gini index of the ordered Lorenz curve (Frees, Meyers, and Cummings 2011). The procedures above are repeated 10 times, and the averaged values of NAV and the Gini index are summarized in Table 5 (the numbers in parenthesis are standard errors). As we have seen in the simulations, the grouped elastic net tends to select more variables than the grouped lasso. For the LogGam model, we have to settle with two possibly different sets of variables, one for the frequency submodel and one for the severity submodel. Although each of the submodels may involve less active variables than the grouped lasso and the grouped elastic net, such two submodel structure may not be desirable for a straightforward interpretation of the loss-variable association. 

Next, we briefly explain the ordered Lorenz curve and the associated Gini index proposed by Frees, Meyers, and Cummings (2011), which is especially useful for insurance risk segmentation purposes. In the insurance business, when an insurer writes a policy for a customer, the insurer is exchanging a future loss (or risk) _Y_ for an immediate premium income (or policy price) _M_ ( **X** ), where **X** is the covariate related to the policy holder’s characteristics, and _M_ (·) is a _known_ baseline premium calculation function currently in use and possibly dependent on **X** . Since the baseline premium _M_ ( **X** ) is not given in the auto insurance dataset, for simplicity, in this section, we choose the constant premium function _M_ (·) ≡ 1 for Gini index calculation. The constant _M_ (·) is also used for the simulations of Section 4. Given an alternative statistical model and a new covariate **X** , we can choose the predicted value _µ_ ˆ ( **X** ) of the response to be an insur- 

**622** 

W. QIAN, Y. YANG, AND H. ZOU 

Figure 3. The ordered Lorenz curves for the auto insurance claim data. Larger area between the ordered Lorenz curve and the break-even line means better risk segmentation. 

ance score _S_ ( **X** ). For example, under the settings of Section 2, the Tweedie model with the grouped elastic net chooses _S_ ( **X** ) = exp( _β_[ˆ] 0 + _**β**_[ˆ] _T_ **X** ). It is certainly desirable that the insurance score _S_ ( **X** ) can properly estimate the expected risk _E_ ( _Y_ | **X** ) and differentiate the profitable business from the unprofitable business. Such insurance score, if shown effective in risk segmentation, can be used to improve the existing premium calculation mechanism. 

To gauge whether an insurance score (and the underlying statistical model that generates the score) is effective, define a relativity _R_ ( **X** ) = _S_ ( **X** ) _/M_ ( **X** ). Given a random sample (namely, the testing dataset in our example) {(˜ **x** _i, y_ ˜ _i_ ) _, i_ = 1 _, . . . , n_ } of ( **X** _, Y_ ), define two empirical distribution functions 

**==> picture [306 x 26] intentionally omitted <==**

The ordered Lorenz curve is the graph of ( _F_[ˆ] _M_ ( _r_ ) _, F_[ˆ] _L_ ( _r_ )). The ordered Lorenz curves of GrpNet, YY, and WZ models in one run of our real data example are given in Figure 3, where the diagonal line is the so-called _break-even_ line. Since the diagonal line means that the proportion of premium selected by the cut-off relativity value _r_ is always equal to the proportion of the selected loss, it observes no risk segmentation, which gives the break-even situation. The Gini index is defined as twice the area between the ordered Lorenz curve and the break-even line. 

The Gini index summarized in Table 5 implies that the GrpNet and the GrpLasso models perform slightly better than the LogGam model. The YY and the WZ models 

**623** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

Figure 4. The solution path of the GrpNet model for the auto insurance claim data (the dotted line represents the _λ_ selected by cross-validations; _τ_ = 0.7). 

clearly underperform the others due to the lack of some relevant variables. We fit the GrpNet model with the entire dataset, and the variables _x_ 5 _, x_ 8 _, x_ 9 _, x_ 21 are selected as the important variables. The solution path of this model is shown in Figure 4. The partial fits of the selected variables are left in the Appendix, available online in the supplementary materials (Figure A2). 

## **6. CONCLUSION** 

Inspired by the success of the IRLS strategy in the coordinate descent algorithms (Friedman, Hastie, and Tibshirani 2010), we embed the BMD method into the IRLS loops to form the IRLS-BMD algorithm. The IRLS-BMD algorithm requires no blockwise orthonormal condition for the design matrix, and is shown to be computationally very efficient. In addition, by integrating the strong rule to the algorithm, we achieve faster computation of the solution path. With the wide applications of Tweedie models, our efficiently implemented R package HDtweedie can be an appealing tool for relevant scientific communities to investigate their own problems of interest when a large number of variables is involved. 

## **SUPPLEMENTARY MATERIALS** 

**Appendix:** This supplementary file contains additional numerical examples and results not shown in the main article. (appendix.pdf) 

**R package HDtweedie:** This supplementary file is the R package HDtweedie, which implements the algorithms proposed in this article. (HDtweedie 1.1.tar.gz) 

**R function step.tweedie:** This supplementary file contains the R code to perform the stepwise selection for the Tweedie model. (Tweedie stepwise.R) 

**624** 

W. QIAN, Y. YANG, AND H. ZOU 

**R code for data analysis:** This supplementary file contains the auto insurance claim data example illustrated in this article. (data analysis.R) 

## **ACKNOWLEDGMENTS** 

The authors thank the Editor, the Associate Editor, and an anonymous referee for their valuable comments that helped improve this article significantly. 

_[Received October 2013. Revised January 2015.]_ 

## **REFERENCES** 

- Bach, F. R. (2008), “Consistency of the Group Lasso and Multiple Kernel Learning,” _Journal of Machine Learning Research_ , 9, 1179–1225. [609] 

- Dunn, P. K. (2004), “Occurrence and Quantity of Precipitation Can be Modelled Simultaneously,” _International Journal of Climatology_ , 24, 1231–1239. [607] 

- Dunn, P. K., and Smyth, G. K. (2005), “Series Evaluation of Tweedie Exponential Dispersion Model Densities,” _Statistics and Computing_ , 15, 267–280. [607] 

- Efron, B., Hastie, T., Johnstone, I., and Tibshirani, R. (2004), “Least Angle Regression,” _The Annals of Statistics_ , 32, 407–499. [608] 

- Foster, S. D., and Bravington, M. V. (2013), “A Poisson–Gamma Model for Analysis of Ecological Non-Negative Continuous Data,” _Environmental and Ecological Statistics_ , 20, 533–552. [607] 

- Frees, E. W., Meyers, G., and Cummings, A. D. (2011), “Summarizing Insurance Scores Using a Gini Index,” _Journal of the American Statistical Association_ , 106, 1085–1098. [610,621] 

- Friedman, J., Hastie, T., and Tibshirani, R. (2010), “Regularization Paths for Generalized Linear Models via Coordinate Descent,” _Journal of Statistical Software_ , 33, 1–22. [608,609,623] 

- Fu, W. J. (1998), “Penalized Regressions: The Bridge Versus the Lasso,” _Journal of Computational and Graphical Statistics_ , 7, 397–416. [609] 

- Huang, J., and Zhang, T. (2010), “The Benefit of Group Sparsity,” _The Annals of Statistics_ , 38, 1978–2004. [609] 

- Jørgensen, B. (1987), “Exponential Dispersion Models” (with discussion), _Journal of the Royal Statistical Society,_ Series B, 49, 127–162. [607] 

- Kim, Y., Kim, J., and Kim, Y. (2006), “Blockwise Sparse Regression,” _Statistica Sinica_ , 16, 375. [609,615] 

- Lauderdale, B. E. (2012), “Compound Poisson–Gamma Regression Models for Dollar Outcomes That are Sometimes Zero,” _Political Analysis_ , 20, 387–399. [607] 

- Meier, L., Van De Geer, S., and B¨uhlmann, P. (2008), “The Group Lasso for Logistic Regression,” _Journal of the Royal Statistical Society,_ Series B, 70, 53–71. [609] 

- Murphy, K. P., Brockman, M. J., and Lee, P. K. W. (2000), “Using Generalized Linear Models to Build Dynamic Pricing Systems,” in _Casualty Actuarial Society Forum_ , pp. 107–139. [608] 

- Nardi, Y., and Rinaldo, A. (2008), “On the Asymptotic Properties of the Group Lasso Estimator for Linear Models,” _Electronic Journal of Statistics_ , 2, 605–633. [609] 

- Ohlsson, E., and Johansson, B. (2010), _Non-Life Insurance Pricing With Generalized Linear Models_ , Berlin: Springer. [608] 

- Osborne, M. R., Presnell, B., and Turlach, B. A. (2000), “A New Approach to Variable Selection in Least Squares Problems,” _IMA Journal of Numerical Analysis_ , 20, 389–403. [608] 

- Shono, H. (2008), “Application of the Tweedie Distribution to Zero-Catch Data in CPUE Analysis,” _Fisheries Research_ , 93, 154–162. [607] 

- Smyth, G. K. (1996), “Regression Analysis of Quantity Data With Exact Zeros,” in _Proceedings of the Second Australia-Japan Workshop on Stochastic Models in Engineering, Technology and Management, Gold Coast, Australia_ , pp. 17–19. [608] 

**625** 

TWEEDIE’S COMPOUND POISSON MODEL WITH GROUPED ELASTIC NET 

- Smyth, G. K., and Jørgensen, B. (2002), “Fitting Tweedie’s Compound Poisson Model to Insurance Claims Data: Dispersion Modelling,” _ASTIN Bulletin_ , 32, 143–157. [607] 

- Tibshirani, R. (1996), “Regression Shrinkage and Selection via the Lasso,” _Journal of the Royal Statistical Society,_ Series B, 58, 267–288. [608] 

- Tibshirani, R., Bien, J., Friedman, J., Hastie, T., Simon, N., Taylor, J., and Tibshirani, R. J. (2012), “Strong Rules for Discarding Predictors in Lasso-Type Problems,” _Journal of the Royal Statistical Society,_ Series B, 74, 245–266. [610,614] 

- Tseng, P. (2001), “Convergence of a Block Coordinate Descent Method for Nondifferentiable Minimization,” _Journal of Optimization Theory and Applications_ , 109, 475–494. [608] 

- Wang, H., and Leng, C. (2008), “A Note on Adaptive Group Lasso,” _Computational Statistics & Data Analysis_ , 52, 5277–5286. [609] 

- Wei, F., and Huang, J. (2010), “Consistent Group Selection in High-Dimensional Linear Regression,” _Bernoulli_ , 16, 1369. [609] 

- Wu, T. T., and Lange, K. (2010), “The MM Alternative to EM,” _Statistical Science_ , 25, 492–505. [611] 

- Yang, Y., and Zou, H. (2014), “A Fast Unified Algorithm for Solving Group-Lasso Penalized Learning Problems,” _Statistics and Computing_ , DOI: 10.1007/s11222-014-9498-5. [621] 

- Yip, K. C., and Yau, K. K. (2005), “On Modeling Claim Frequency Data in General Insurance With Extra Zeros,” _Insurance: Mathematics and Economics_ , 36, 153–163. [619,621] 

- Yuan, M., and Lin, Y. (2006), “Model Selection and Estimation in Regression With Grouped Variables,” _Journal of the Royal Statistical Society,_ Series B, 68, 49–67. [609] 

- Zhang, Y. (2013a), “cplm: Compound Poisson Linear Models,” A vignette for R package cplm. Available at _http://cran.r-project.org/web/packages/cplm_ . [619,621] 

- ——— (2013b), “Likelihood-Based and Bayesian Methods for Tweedie Compound Poisson Linear Mixed Models,” _Statistics and Computing_ , 23, 743–757. [607] 

- Zou, H. (2006), “The Adaptive Lasso and Its Oracle Properties,” _Journal of the American Statistical Association_ , 101, 1418–1429. [609] 

- Zou, H., and Hastie, T. (2005), “Regularization and Variable Selection via the Elastic Net,” _Journal of the Royal Statistical Society,_ Series B, 67, 301–320. [609,616] 

## Appendix to “Tweedie’s Compound Poisson Model With Grouped Elastic Net” 

Wei Qian, Yi Yang and Hui Zou School of Statistics University of Minnesota 

## **A. Additional Numerical Results of Simulation Example 1** 

We repeat the procedures in section 4.1 with smaller sample size ( _n_ = 100 _,_ 200 instead of 500), and the results appear to be close to that of sample size 500 in this example. The results are summarized in Tables A1-A3. 

## **B. Misspecification of Link Function** 

we use the log link in our implementation to ensure that the estimated conditional mean _µ_ ˆ( **x** ) is always positive, and at the same time, impose a multiplicative structure. In the context of insurance premium estimation, the log link is much used as it decomposes the expected premium into di↵erent risk factors in a multiplicative fashion (when only main e↵ects are considered), and generates convenient model for intuitive interpretation. However, if the true data is not generated by the log link, building models with the log link is subject to estimation bias. Inspired by the Associate Editor’s comment, we intend to illustrate this issue by a data simulation setting similar to that of Case 3 in Example 1 except for the link function. Let _⌘_ := 0 _._ 3 +[P][6] _j_ =1 _[p]_[1][(] _[T][j]_[).][Consider][the][following][two][scenarios][for][the][true][link] functions, from which the data is generated: (A) _µ_ =[[][ex][p(] _[⌘]_[)+] _r_[1][]] _[r][−]_[1] ; (B) _µ_ = exp(sgn( _⌘_ ) _|⌘|[r]_ ), where _r >_ 0 and sgn( _·_ ) is the sign function. Clearly, when _r_ = 1, both scenarios reduce to the log link. When _r_ = 1, however, the presumed log-link in our algorithm implementation does not match the true link function, resulting in the misspecification of the link function. To generate data, we choose _r_ = 0 _._ 5 _,_ 0 _._ 7 _,_ 1 _,_ 1 _._ 3 _,_ 1 _._ 5, and assume _!_ = 0. The corresponding data 

1 

Table A1: (Case 1) Averaged simulation results based on 100 runs. 

||block-|block-|coefcient-|coefcient-|Gini index|
|---|---|---|---|---|---|
||C|IC|C|IC||
|oracle|3|0|9|0|-|
|_n_= 100_, !_ = 0||||||
|lasso|2.87|1.57|5.59|1.94|0.871 (0.018)|
|grouped lasso|2.93|0.98|8.79|2.94|0.889 (0.015)|
|grouped elastic net|2.94|1.50|8.82|4.50|0.891 (0.015)|
|_n_= 100_, !_ = 0_._5||||||
|lasso|2.81|1.58|5.08|1.89|0.839 (0.024)|
|grouped lasso|2.93|1.34|8.79|4.02|0.877 (0.011)|
|grouped elastic net|2.95|1.87|8.85|5.61|0.882 (0.011)|
|_n_= 200_, !_ = 0||||||
|lasso|2.84|1.13|5.55|1.37|0.908 (0.023)|
|grouped lasso|2.90|0.65|8.70|1.95|0.925 (0.017)|
|grouped elastic net|2.96|1.13|8.88|3.39|0.948 (0.004)|
|_n_= 200_, !_ = 0_._5||||||
|lasso|2.78|1.65|5.46|1.84|0.891 (0.024)|
|grouped lasso|2.94|1.04|8.82|3.12|0.938 (0.006)|
|grouped elastic net|2.98|1.42|8.94|4.26|0.941 (0.006)|



each has 18 predictor terms, and 6 of them are relevant. We use the lasso method to obtain coefficient-C, coefficient-IC and the mean squared estimation error of _⌘_ (MSE _⌘_ ). Based on the results summarized in Table A4 and Figure A1, even though the implemented algorithm may still identify the relevant variables, the estimation of _⌘_ becomes unreliable when the true link function is very di↵erent from the log-link. We leave the further investigation regarding robust estimation for the misspecified link function to the future. 

2 

Table A2: (Case 2) Averaged simulation results based on 100 runs. 

||block-|block-|coefcient-|coefcient-|Gini index|
|---|---|---|---|---|---|
||C|IC|C|IC||
|oracle|3|0|9|0|-|
|_n_= 100_, !_ = 0||||||
|lasso|1.61|0.82|2.13|1.08|0.738 (0.017)|
|grouped lasso|1.42|0.48|4.26|1.44|0.733 (0.020)|
|grouped elastic net|2.81|0.72|8.43|2.16|0.746 (0.017)|
|_n_= 100_, !_ = 0_._5||||||
|lasso|1.67|0.92|2.28|1.11|0.758 (0.019)|
|grouped lasso|1.55|0.65|4.65|1.95|0.766 (0.018)|
|grouped elastic net|2.83|0.92|8.49|2.76|0.766 (0.018)|
|_n_= 200_, !_ = 0||||||
|lasso|1.88|0.30|2.59|0.30|0.819 (0.016)|
|grouped lasso|1.78|0.18|5.34|0.54|0.825 (0.015)|
|grouped elastic net|2.97|0.30|8.91|0.90|0.825 (0.015)|
|_n_= 200_, !_ = 0_._5||||||
|lasso|1.83|0.70|2.46|0.74|0.817 (0.016)|
|grouped lasso|1.73|0.43|5.19|1.29|0.823 (0.015)|
|grouped elastic net|2.89|0.55|8.67|1.65|0.823 (0.015)|



## **C. Partial Fits in Real Data Example** 

Based on the auto insurance claim data example in section 5, Figure A2 shows the partial fits of the variables selected by the Tweedie model with grouped elastic net (GrpNet). 

3 

Table A3: (Case 3) Averaged simulation results based on 100 runs. 

||block-|block-|coefcient-|coefcient-|Gini index|
|---|---|---|---|---|---|
||C|IC|C|IC||
|oracle|6|0|6|0|-|
|_n_= 100_, !_ = 0||||||
|lasso|5.86|0.68|5.73|4.29|0.541 (0.009)|
|grouped lasso|5.81|0.65|5.81|13.57|0.525 (0.010)|
|grouped elastic net|5.97|1.12|5.97|15.30|0.540 (0.007)|
|_n_= 100_, !_ = 0_._5||||||
|lasso|5.31|0.79|4.66|4.30|0.360 (0.015)|
|grouped lasso|4.76|0.48|4.76|10.96|0.317 (0.014)|
|grouped elastic net|5.52|0.91|5.52|13.77|0.369 (0.010)|
|_n_= 200_, !_ = 0||||||
|lasso|6.00|0.78|5.99|4.26|0.591 (0.004)|
|grouped lasso|5.99|0.94|5.99|14.80|0.580 (0.004)|
|grouped elastic net|6.00|1.32|6.00|15.96|0.582 (0.004)|
|_n_= 200_, !_ = 0_._5||||||
|lasso|5.92|0.72|5.80|4.34|0.416 (0.006)|
|grouped lasso|5.85|0.68|5.85|13.74|0.403 (0.006)|
|grouped elastic net|6.00|0.99|6.00|14.97|0.416 (0.004)|



4 

Table A4: Averaged simulation results for link function misspecification based on 100 runs. 

|Scenario|_r_|coefcient-|coefcient-|MSE_⌘_|
|---|---|---|---|---|
|||C|IC||
|A|0.5|5.90|4.04|0.457|
||0.7|5.97|4.20|0.313|
||1.0|6.00|4.41|0.160|
||1.3|6.00|4.60|0.162|
||1.5|6.00|4.59|0.256|
|B|0.5|5.88|4.04|0.546|
||0.7|5.94|4.12|0.391|
||1.0|6.00|4.41|0.160|
||1.3|6.00|5.44|0.165|
||1.5|6.00|6.13|0.534|



**==> picture [354 x 187] intentionally omitted <==**

**----- Start of picture text -----**<br>
0.5 0.7 1.0 1.3 1.5 0.5 0.7 1.0 1.3 1.5<br>r r<br>0.8 1.4<br>1.2<br>0.6<br>1.0<br>η η 0.8<br>MSE 0.4 MSE<br>0.6<br>0.4<br>0.2<br>0.2<br>0.0 0.0<br>**----- End of picture text -----**<br>


Figure A1: Boxplots of MSE _⌘_ for link function misspecification. Left panel: scenario (i). Right panel: scenario (ii). 

5 

**==> picture [376 x 329] intentionally omitted <==**

**----- Start of picture text -----**<br>
0 2 4 6 8 0 2 4 6 8 10<br>x 5 : Number of Policies x 9 : MVR points<br>0 1 0 1<br>x 8 : License Revoked (no or yes) x 21 : Area (suburban or urban)<br>1.0 1.0<br>0.5 0.5<br>fit 0.0 fit 0.0<br>-0.5 -0.5<br>-1.0 -1.0<br>1.0 1.0<br>0.5 0.5<br>fit 0.0 fit 0.0<br>-0.5 -0.5<br>-1.0 -1.0<br>**----- End of picture text -----**<br>


Figure A2: The partial fits of the selected variables by the GrpNet model for the auto insurance claim data. 

6 

