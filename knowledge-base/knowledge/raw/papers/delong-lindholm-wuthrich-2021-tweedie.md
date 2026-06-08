European Actuarial Journal (2021) 11:185–226 https://doi.org/10.1007/s13385-021-00264-3 

**ORIGINAL RESEARCH PAPER** 

## **Making Tweedie’s compound Poisson model more accessible** 

## **Łukasz Delong[1] · Mathias Lindholm[2] · Mario V. Wüthrich[3]** 

Received: 9 June 2020 / Revised: 23 November 2020 / Accepted: 21 January 2021 / Published online: 13 February 2021 © The Author(s) 2021 

## **Abstract** 

The most commonly used regression model in general insurance pricing is the compound Poisson model with gamma claim sizes. There are two different parametrizations for this model: the Poisson-gamma parametrization and Tweedie’s compound Poisson parametrization. Insurance industry typically prefers the Poisson-gamma parametrization. We review both parametrizations, provide new results that help to lower computational costs for Tweedie’s compound Poisson parameter estimation within generalized linear models, and we provide evidence supporting the industry preference for the Poisson-gamma parametrization. 

**Keywords** Compound Poisson model · Gamma claim sizes · Tweedie’s distribution · Exponential dispersion family · Regression model · Generalized linear model · Neural network 

## **1 Introduction** 

The most commonly used regression model in general insurance pricing is the compound Poisson model with gamma claim sizes. State-of-the-art industry practice fits two separate generalized linear models (GLMs) to the two parts of this model, namely, a Poisson GLM to claim counts and a gamma GLM to claim amounts. Both the Poisson and the gamma distributions belong to the exponential dispersion family 

- Mario V. Wüthrich 

mario.wuethrich@math.ethz.ch 

Łukasz Delong lukasz.delong@sgh.waw.pl 

Mathias Lindholm lindholm@math.su.se 

- 1 SGH Warsaw School of Economics, Institute of Econometrics, Warsaw, Poland 

- 2 Department of Mathematics, Stockholm University, Stockholm, Sweden 

- 3 RiskLab, Department of Mathematics, ETH Zurich, Zurich, Switzerland 

Vol.:(0123456789)1 3 

Ł. Delong et al. 

186 

(EDF). It has been noted by Tweedie [19] that the compound Poisson model with i.i.d. gamma claim sizes itself belongs to the EDF and, in fact, it closes the interval of power variance functions between the Poisson model and the gamma model, see Section 3 in Jørgensen [5]. As a result of Tweedie’s and Jørgensen’s findings we obtain two different parametrizations of the compound Poisson model with i.i.d. gamma claim sizes. Selection between these two different parametrizations has been explored in the work of Jørgensen–de Souza [6] in the context of GLM insurance pricing. Interestingly, to predict total claim amounts we need to fit two GLMs in the compound Poisson-gamma parametrization, whereas one GLM is sufficient to get the corresponding predictions within Tweedie’s EDF parametrization. This indicates that in GLM applications these two parametrizations are not fully consistent. This point has been raised by Smyth–Jørgensen [17] who propose to use a double generalized linear model (DGLM) in Tweedie’s parametrization to simultaneously model mean and dispersion parameters within the EDF. 

The main purpose of this article is to revisit the work of Smyth–Jørgensen [17], and to give properties under which the two GLMs for claim counts and claim sizes and the DGLM with Tweedie’s EDF parametrization lead to the same predictive model; this involves a discussion about choices of covariate spaces and GLM link functions. Based on this, our first main contribution provides a new result for Tweedie’s DGLM that substantially reduces computational costs in calibrations of power variance parameters. 

The second point that we explore is whether the insurance industry’s preference of using the Poisson-gamma parametrization can be justified. A priori it is not clear whether either of the two ways lead to better predictive models. This part of our work is based on GLMs and on their neural network extensions. We receive evidence that supports the industry preference, in particular, under the choice of neural network regression models the Poisson-gamma parametrization is simpler in calibration and leads to more robust results. 

We close this introduction with a number of remarks. First, we mention the recent survey paper of Quijano Xacur–Garrido [12], which has similar goals to the present paper. This survey only considers the single GLM case of Tweedie’s parametrization, similar to Jørgensen–de Souza [6]. We emphasize that the full picture can only be obtained by comparing the Poisson-gamma parametrization to the DGLM case introduced in Smyth–Jørgensen [17]. Therefore, we revisit and extend this latter reference to receive a comprehensive comparison. Our view is supported by examples. These examples provide a proof of concept for situations with claims that are not too heavy tailed. However, these examples also highlight the weaknesses of this model on real insurance data, which often exhibits heavier tails than what is suitable under a gamma assumption. We remark that in our discussion we use the terminology of general insurance pricing, however, as commonly the case in general insurance, all our findings can be translated one-to-one to claims reserving problems. 

_Organization of the paper_ In Sect. 2 we introduce the compound Poisson model with i.i.d. gamma claim sizes and we derive its corresponding Tweedie parametrization. In Sect. 3 we embed both approaches into a GLM framework. We present the two GLMs needed for the Poisson-gamma parametrization, and we discuss a single GLM and a DGLM parametrization for Tweedie’s approach. Our main results, 

1 3 

Making Tweedie’s compound Poisson model more accessible 

187 

Theorems 3.6 and 3.8 , give conditions under which the different GLM parametrizations lead to identical predictive models. These theorems provide a remarkable property that allows us to lower calibration costs in Tweedie’s DGLMs. In Sect. 4 we give insights and intuition based on numerical examples both under GLMs and neural network regression models. In Sect. 5 we conclude, and the “Appendix” gives a short summary of GLMs and describes the data used. 

## **2  Tweedie’s compound Poisson model** 

In Sect. 2.1 we introduce the compound Poisson model with i.i.d. gamma claim sizes, and in Sect. 2.2 we revisit its Tweedie counterpart. For simplicity, in these two sections, we think of using these models for modeling one single insurance policy only. In Sect. 3, below, we consider multiple insurance policies also allowing for heterogeneity between policies. 

## **2.1  Compound Poisson model with i.i.d. gamma claim sizes** 

Let _N_ be the number of claims and let ( _Zj_ ) _j_ ≥1 be the corresponding claim sizes. We assume that the number of claims, _N_ , is Poisson distributed with mean _휆w_ , where _𝜆>_ 0 is the expected claim frequency relative to a given exposure _w >_ 0 ; we write _N_ ∼ Poi( _휆w_ ) . We assume that the claim sizes _Zj_ , _j_ ≥ 1 , are i.i.d. and independent of _N_ having a gamma distribution with shape parameter _𝛾>_ 0 and scale parameter _c >_ 0 ; we write _Z_ 1 ∼ G( _훾_ , _c_ ) for this gamma distribution. The moment generating function of the gamma claim sizes is given by, see Section 3.2.1 in [20], 

**==> picture [162 x 20] intentionally omitted <==**

The compound Poisson model with i.i.d. gamma claim sizes (CPG) is then defined by _S_ =[∑] _[N] j_ =1 _[Z][j]_[ ; we use notation ] _[S]_[ ∼][CPG][(] _[휆][w]_[,] _[ 훾]_[,] _[ c]_[)][ . The moment generating func-] tion of _S_ is given by 

**==> picture [279 x 21] intentionally omitted <==**

we refer to Proposition 2.11 in [20]. 

## **2.2  Tweedie’s compound Poisson model** 

Following [5, 6, 17, 19] we select a particular model within the EDF. A random variable _Y_ belongs to the EDF if its density has the following form (w.r.t. a _휎_ -finite measure on ℝ) 

**==> picture [274 x 25] intentionally omitted <==**

1 3 

Ł. Delong et al. 

188 

> with _w >_ 0 is a given exposure (weight, volume), _𝜙>_ 0 is the dispersion parameter, _휃_ ∈ **횯 횯** , _휅_ ∶ **횯** → ℝ is the cumu- is the canonical parameter in the effective domain lant function, _a_ (⋅;⋅) is the normalization, _not_ depending on the canonical parameter _휃_ . 

For properties of the EDF we refer to “Appendix A”, below. Tweedie’s compound Poisson (CP) model is obtained by choosing for _p_ ∈(1, 2) the cumulant function 

**==> picture [340 x 63] intentionally omitted <==**

**==> picture [257 x 57] intentionally omitted <==**

> Hyper-parameter _p_ ∈(1, 2) allows us to model the power variance functions _V_ ( _휇_ ) = _휇[p]_ between the Poisson boundary case _p_ = 1 and the gamma boundary case _p_ = 2 , we refer to Sect. 3.1, below, for the boundary cases. _휇_ ↦ _휃_ = ( _휅p_[�][)][−][1][(] _[휇]_[)][ gives ] the canonical link of Tweedie’s CP model. 

We calculate the moment generating function of the exposure scaled Tweedie’s CP random variable _wY_ , see also Corollary 7.21 in [20], 

**==> picture [311 x 61] intentionally omitted <==**

Note that this is a CPG model in a different parametrization; we call the model under this EDF parametrization Tweedie’s CP model. The following proposition follows by comparing the corresponding moment generating functions. 

**Proposition 2.1** _Choose S_ ∼ CPG( _휆w_ , _훾_ , _c_ ) _and Y_ ∼ Tweedie( _휃_ , _w_ , _휙_ , _p_ ). _We have_ (d) _identity in distribution S_ ∕ _w_ = _Y under parameter identification_ 

**==> picture [237 x 51] intentionally omitted <==**

**==> picture [20 x 9] intentionally omitted <==**

**==> picture [195 x 22] intentionally omitted <==**

1 3 

Making Tweedie’s compound Poisson model more accessible 

189 

Formula (2.8 ) can be rewritten in different ways. We have, using the canonical link of Tweedie’s CP model, _휃_ = ( _휅_[�] _p_[)][−][1][(] _[휇]_[) =] _[ 휇]_[1][−] _[p]_[∕(][1][ −] _[p]_[)][ and ] _휅p_ ( _휃_ ) = _휅p_ (( _휅p_[�][)][−][1][(] _[휇]_[)) =] _[ 휇]_[2][−] _[p]_[∕(][2][ −] _[p]_[)][ . This implies, using (][2.7][) in the second step ] and (2.6) in the last step, 

**==> picture [278 x 25] intentionally omitted <==**

The latter says that, of course, the expected claim frequency _휆_ is obtained by dividing the expected total claim amount 피[ _Y_ ] = _휇_ by the average claim size 피[ _Z_ 1] = _훾_ ∕ _c_ . 2.6)–(2.8) the two models are Thus, under parameter identification scheme ( identical: 

**==> picture [288 x 54] intentionally omitted <==**

This illustrates that there is a one-to-one correspondence between the CPG parametrization and Tweedie’s CP parametrization, i.e. the two models are identical and only differ in interpretation of parameters. The next section will demonstrate that these subtle differences can be crucial for GLM regression modeling, and resulting 3.3 models can be rather different as functions of explanatory covariates, see Sect. below. 

## **3  Generalized linear models and parameter estimation** 

In this section we study multiple insurance policies _i_ = 1, … , _n_ having claim distributions CPG( _휆iwi_ , _훾_ , _ci_ ) and Tweedie( _휃i_ , _wi_ , _휙i_ , _p_ ) , respectively. We allow for heterogeneity between the policies in all parameters that have a lower index _i_ . We describe modeling and parameter estimation within GLMs: we consider two GLMs to model _휆i_ (Poisson) and − _ci_ ∕ _훾_ (gamma) in the former case, and we consider a DGLM to model _휃i_ and _휙i_ in the latter case. There is a slight difference between “two GLMs” and “double GLM”, the former considers two independent GLMs, the latter does a simultaneous consideration of two GLMs. The volumes _wi_ are assumed to be known and do not need any modeling. The shape parameter _𝛾>_ 0 and the power variance parameter _p_ = ( _훾_ + 2)∕( _훾_ + 1) , see (2.6), are assumed to be the same for all policies _i_ , this is a standard assumption in state-of-the-art use of these GLMs. An overview of GLMs and their parameter estimation within the EDF is given in “Appendix A”. 

## **3.1  Compound Poisson model with i.i.d. gamma claim sizes** 

We begin with the CPG model. Since the log-likelihood function of the CPG model decouples into two separate parts for claim counts and claim sizes, maximum likelihood estimation (MLE) of claim counts and claim size models can be 

1 3 

Ł. Delong et al. 

190 

done independently from each other. We start from _n_ independent random variables _Si_ ∼ CPG( _휆iwi_ , _훾_ , _ci_ ) with 

**==> picture [200 x 31] intentionally omitted <==**

The joint log-likelihood function of this model, given observations ( _Ni_ ) _i_ and ( _Zi_ , _j_ ) _i_ , _j_ and weights ( _wi_ ) _i_ , is given by 

**==> picture [284 x 80] intentionally omitted <==**

where the term on the second line is zero for _Ni_ = 0 . Remark that in this log-likelihood function (for parameter estimation) we treat ( _Ni_ ) _i_ and ( _Zi_ , _j_ ) _i_ , _j_ as known observations; for notational convenience we do not use small fonts for observations. From (3.1) we now see that we can estimate the Poisson parameters _휆i_ and the gamma parameters _훾_ and _ci_ independently from each other; the former uses observations ( _Ni_ ) and the latter observations ( _Ni_ ) _i_ and ( _Zi_ , _j_ ) _i_ , _j_ . 

Furthermore, we assume that each insurance policy _i_ = 1, … , _n_ is established with covariate information _**x** i_ = ( _xi_ ,0, … , _xi_ , _d_ )[�] ∈ X _⊂_ {1} × ℝ _[d]_ , having initial component _xi_ ,0 = 1 for modeling the intercept component. 

_GLM for claim counts:_ Assume that the expected frequencies _휆i_ = _휆_ ( _**x** i_ ) of policies _i_ = 1, … , _n_ can be modeled by a log-linear regression function 

**==> picture [341 x 204] intentionally omitted <==**

1 3 

Making Tweedie’s compound Poisson model more accessible 

191 

_GLM for gamma claim sizes:_ Consider only insurance policies _i_ which have claims, i.e. with _Ni >_ 0 . All subsequent considerations in this paragraph are conditional on _Ni_ . The average claim amount on policy _i_ has a conditional gamma distribution 

**==> picture [239 x 31] intentionally omitted <==**

with shape parameter _훾Ni_ and scale parameter _ciNi_ (note that _훾_ is not policy _i_ dependent). This gamma distributed random variable has conditional mean and variance given by 

**==> picture [286 x 30] intentionally omitted <==**

> This model belongs to the EDF (2.2) with cumulant function _휅_ 2( _휃_ ) = − log(− _휃_ ) for _휃_ ∈ **횯** = ℝ− , dispersion parameter _휙_ = 1∕ _훾_ and exposure _wi_ = _Ni_ . The conditional mean and variance are 

**==> picture [319 x 27] intentionally omitted <==**

> This is the boundary case _p_ = 2 in Tweedie’s CP model with power variance func- 

> tion _V_ ( _휁_ ) = _휁_[2] , see (2.5). 

We set up a second GLM for gamma claim size modeling. This second GLM does not necessarily need to rely on the same covariate space X as the Poisson GLM (3.2) for claim counts modeling. To emphasize this point, we introduce a new covariate space containing covariate information _**z** i_ = ( _zi_ ,0, … , _zi_ , _q_ )[�] ∈ Z _⊂_ {1} × ℝ _[q]_ having initial component _zi_ ,0 = 1 modeling the intercept. We interpret the choices X and Z as follows: both covariates _**x** i_ ∈ X and _**z** i_ ∈ Z should belong to the same insurance policy _i_ , however, inclusion of individual covariate components and pre-processing of these components may differ in the two different regression models. This is a result of aiming at optimizing the predictive performance of both regression models. 

**==> picture [341 x 43] intentionally omitted <==**

> for regression parameter _**휶**_ ∈ ℝ _[q]_[+][1] . Formula (3.5) explains the relationship between mean _𝜁_ = 피[ _Z[̄]_ | _N_ ] = _𝜅_ 2[�][(] _[𝜃]_[)][ , canonical parameter ] _[휃]_[ and linear predictor ] _[휂]_[=] _[ 휂]_[(] _**[z]**_[)][ . Usu-] ally, one does not select the canonical link in the gamma GLM because the nega- 

> tivity constraint on the canonical parameter _휃_ ∈ **횯** = ℝ− may be too restrictive in choosing a linear functional regression form; this is in contrast to the Poisson 

> GLM (3.2). Therefore, the choice of the link function _g_ 2(⋅) has to be done carefully, because we require 1∕ _𝜃i_ = − _g_[−] 2[1][(] _[𝜂][i]_[) = −] _[g]_[−] 2[1][⟨] _**[휶]**_[,] _**[ z]**[i]_[⟩] _[<]_[ 0][ for all policies ] _[i]_[ =][ 1,][ …][ ,] _[ n]_[ , ] otherwise the canonical parameter _휃i_ is not in the effective domain **횯** . Below, we 

> will choose the log-link for _g_ 2 , which is a common choice for gamma GLMs. 

1 3 

Ł. Delong et al. 

192 

These choices imply for the log-likelihood function, only considering policies _i_ = 1, … , _m_ with _Ni >_ 0, 

**==> picture [256 x 28] intentionally omitted <==**

The MLE _**휶** ̂_ of _**휶**_ is found by solving the score equation, see “Appendix A”, 

**==> picture [229 x 12] intentionally omitted <==**

> with design matrix ℨ = ( _**z**_ 1, … , _**z** m_ )[�] ∈ ℝ _[m]_[×(] _[q]_[+][1][)] , diagonal working weight matrix 

> (using _V_ ( _휁i_ ) = _휁i_[−][2][)] 

**==> picture [338 x 58] intentionally omitted <==**

_**Remarks 3.1**_ 

- Shape parameter _훾_ may be treated as a hyper-parameter, and the explicit choice of _훾_ does _not_ influence parameter estimation because it cancels in the score Eq. (3.7). 

- MLE (3.6)–(3.7) is expressed in sufficient statistics _̂ Z[̄] i_ , and we receive the same regression parameter estimate _**휶**_ if we perform MLE directly on the individual claim sizes _Zi_ , _j_ . This is an important property, namely, the gamma GLM can be fit solely on the number of claims _Ni_ and the total claim amount _Z[̄] i_ on each policy _i_ . Moreover, this estimated model still allows us to simulate individual claim sizes _Zi_ , _j_ . Thus, GLM regression parameter estimation does not differ whether we consider total claim amounts _Z[̄] i_ or individual claim sizes _Zi_ , _j_ . On the other hand, the process of model and variable selection might give different results in the two estimation cases ( _Z[̄] i_ vs. _Zi_ , _j_ ) because the log-likelihood functions and the estimates for _훾_ differ, this is, e.g., important for model selection using likelihood ratio tests or Akaike’s information criterion, see Remarks 3.10, below. 

- If we model claim counts and claim sizes separately, we use maximal available information _Ni_ and _Zi_ , _j_ . Moreover, we can design covariate spaces X and Z in an optimal way, and independently from each other. 

- If (3.5) is not based on the canonical link of the gamma model, the balance property will not be fulfilled, see [22]. This should be corrected by shifting the intercept parameter _훽_ 0 correspondingly. Often one chooses the log-link for ⋅ 

- _g_ 2( ) , under the log-link choice we can also reformulate the regression problem by replacing the average claim amount response (3.4) by the (conditional) total claim amount _Si_ |{ _Ni_ } and treating log( _Ni_ ) as a known offset in the linear predictor. 

- Shape parameter _𝛾<_ 1 leads to an over-dispersed model with strictly decreasing density, and for _𝛾>_ 1 the density is uni-modal. Above _훾_ is treated as a hyperparameter, and below we discuss MLE of _훾_ . 

1 3 

Making Tweedie’s compound Poisson model more accessible 

193 

- If shape parameter _훾i_ needs explicit modeling as a function of _i_ , then (3.7)–(3.8) will no longer have such a simple structure, and MLE of _**휶**_ will depend on the explicit choices of _훾i_ . In this case, one can either use a gamma DGLM or one can rely on the 2-dimensional exponential family. The latter model is less tractable numerically. It considers cumulant function _휅_ ( _휃_ 1, _휃_ 2) = log Γ( _휃_ 2) − _휃_ 2 log(− _휃_ 1) for scale parameter _c_ = − _𝜃_ 1 _>_ 0 and shape parameter _𝛾_ = _𝜃_ 2 _>_ 0 . This gives inverse link function, see [21], 

**==> picture [191 x 27] intentionally omitted <==**

_Z_ , the first component being the mean of the gamma distributed random variable and the second component being the mean of log( _Z_ ) . We do not further follow up this approach because we would lose the connection to Tweedie’s CP approach with a policy independent power variance parameter, see next section. 

_̂_ There remains estimation of shape parameter _훾_ for given MLE _**휶**_ . One could either use Pearson’s dispersion estimate for 1∕ _훾_ or directly calculate the MLE of _훾_ . In view of (3.6), the MLE is obtained from score equation _[휕] 휕훾_[퓁][(] _**[휶]**[̂]_[,] _[ 훾]_[) =][ 0][ , which yields] 

**==> picture [312 x 28] intentionally omitted <==**

_̂_ where we set _휃[̂] i_ = − exp{−⟨ _**휶**_ , _**z** i_ ⟩} . Either we solve this score equation numerically using the Newton-Raphson algorithm, or we plot the one-dimensional log-likelihood _̂_ function _훾_ ↦ 퓁( _**휶**_ , _훾_ ) and determine the MLE _̂훾_ from this plot, see Fig. 1, below, for an example. 

> We conclude by calculating Fisher’s information matrix for ( _**휶**_ , _훾_ ) in our gamma GLM. We have, see “Appendix A”, 

**==> picture [156 x 19] intentionally omitted <==**

> For the second derivative of the _훾_ term we have 

**==> picture [340 x 82] intentionally omitted <==**

**==> picture [340 x 60] intentionally omitted <==**

1 3 

Ł. Delong et al. 

194 

**==> picture [213 x 26] intentionally omitted <==**

## **3.2  Tweedie’s compound Poisson generalized linear model** 

## **3.2.1  Homogeneous dispersion case** 

From Sect. 2.2 we know that Tweedie’s CP model belongs to the EDF, thus, GLM is straightforward. In this subsection we start with the homogeneous dispersion parameter _𝜙>_ 0 case; this case will not be supported in Remarks 3.2, below. We assume having _n_ independent random variables _Yi_ ∼ Tweedie( _휃i_ , _wi_ , _휙_ , _p_ ) , and we choose hyper-parameter _p_ = ( _훾_ + 2)∕( _훾_ + 1) ∈(1, 2) to make Tweedie’s CP model consistent with the CPG case, see Proposition 2.1. Choosing a suitable link function _gp_ (⋅) we make the following regression assumption for the linear predictor 

_gp_ ( _휇i_ ) = _gp_ (피[ _Yi_ ]) = _gp_ ( _휅p_[�][(] _[휃][i]_[)) =] _[ 휂][i]_[=][ ⟨] _**[휷]**_[∗][,] _**[ x]**_[∗] _i_ ⟩, (3.10) where _**x**_[∗] _i_[∈][X][∗] _[⊂]_[{][1][} ×][ ℝ] _[d]_[∗][ are the covariates of policy ] _[i]_[ and ] _**[휷]**_[∗][ is the regression ] parameter. We change the covariate notation compared to Sect. 3.1 because covariate pre-processing might be done differently for Tweedie’s CP model compared to the CPG case (because we consider different responses). In complete analogy with the above, MLE requires solving the score equations ∇ _**휷**_ ∗퓁( _**휷**_[∗] ) = **0** ⇔ 픛[�] _Wp_ _**R**_ = **0** , (3.11) with design matrix 픛 = ( _**x**_[∗] 1[,][ …][ ,] _**[ x]** n_[∗][)][�][ , diagonal working weight matrix (using ] _V_ ( _휇i_ ) = _휇i[p]_[)] 

**==> picture [258 x 59] intentionally omitted <==**

and working residual vector _**R**_ = ( 

_**Remarks 3.2**_ There are a couple of crucial differences between Tweedie’s CP approach with homogeneous dispersion _휙_ and the CPG approach of the previous section: 

1. The CPG approach of the previous section uses all available information of claim counts _Ni_ and claim sizes _Z[̄] i_ , whereas Tweedie’s CP approach with homogeneous dispersion parameter only uses total claim cost information _Yi_ . 

> X and Z for 2. The former approach allows us to consider different covariate spaces claim counts and claim size modeling, whereas the latter approach only relies on one version of the covariate space X[∗] . 

> 3. The mean estimates _휆[̂] i휁[̂] i_ in the CPG case do _not_ rely on the particular choice of 

> the shape parameter _훾_ , whereas in the homogeneous dispersion Tweedie’s CP 

1 3 

Making Tweedie’s compound Poisson model more accessible 

195 

approach the mean estimates _̂휇i_ rely on the specific choice of power variance parameter _p_ = ( _훾_ + 2)∕( _훾_ + 1) through the working weight matrix _Wp_ , see (3.12). 4. In general, the dispersions resulting from CPG( _휆iwi_ , _훾_ , _ci_ ) are _not_ constant: 

**==> picture [280 x 64] intentionally omitted <==**

The dispersion can only be constant if _휙i_ = − _휃i_ ∕ _ci_ does not depend on _i_ . Typically, this is not the case, see also Conclusions and Remarks 3.9, below. Therefore, we need to extend the homogeneous dispersion case of Tweedie’s CP model to a DGLM Tweedie’s CP model, otherwise it cannot be compared to the CPG case, which is more flexible in dispersion modeling. For more analysis of the homogeneous dispersion case see [12]. 

## **3.2.2  Heterogeneous dispersion case** 

As stated in Remarks 3.2, the homogeneous dispersion Tweedie’s CP approach does not use full information of claim counts and claim costs and it does not allow for flexible dispersion modeling _휙i_ . In Section 2 of [17], the authors raise the point that in applications of Tweedie’s CP model to insurance claim data it is important to use full information so that also the dispersion parameter _휙i_ is modeled flexibly. As a consequence, the dispersion parameter cannot be factored out as in (3.12), and it does not cancel in optimization (3.11). Therefore, [17] propose to use the framework of DGLMs which was introduced and developed by [8, 15, 18]. DGLMs allow for simultaneous modeling of both mean and dispersion parameters by using a second GLM for the dispersion parameter _휙i_ . The two GLMs are jointly calibrated using claim count _and_ claim cost information. The joint density of a single case ( _N_ , _Y_ ) has been derived in formula (11) of [6]: 

**==> picture [294 x 26] intentionally omitted <==**

> with _p_ = ( _훾_ + 2)∕( _훾_ + 1) , _휅p_ (⋅) given in (2.3), and 

**==> picture [207 x 26] intentionally omitted <==**

If we re-parametrize this joint distribution using mean parameter _휇_ = _휅_[�] _p_[(] _[휃]_[) = ((][1][ −] _[p]_[)] _[휃]_[)][1][∕(][1][−] _[p]_[)][ for total claim costs we arrive at the log-likelihood ] function 

1 3 

Ł. Delong et al. 

196 

**==> picture [319 x 46] intentionally omitted <==**

> In complete analogy with the above we determine the score equations w.r.t. _휇_ and _휙_ 

**==> picture [246 x 23] intentionally omitted <==**

**==> picture [289 x 25] intentionally omitted <==**

> with variance function _V_ ( _휇_ ) = _휇[p]_ . 

**Proposition 3.3** _Fisher’s information contribution in the heterogeneous dispersion Tweedie’s CP model w.r.t._ ( _휇_ , _휙_ ) _is given by_ 

**==> picture [281 x 33] intentionally omitted <==**

_Moreover, we have_ 

**==> picture [91 x 26] intentionally omitted <==**

Remark that in the above proposition we talk about Fisher’s information _contribution_ because the statement considers only one single random variable ( _Y_ , _N_ ). This is in contrast to (3.27) where we calculate Fisher’s information _matrix_ over the entire portfolio. 

> Joint MLE of _휇_ and _휙_ requires solving score Eqs. (3.14)-(3.15). This can be done by any suitable root search or gradient descent algorithm. In [17], this root search problem is approached using a slightly different representation, namely, by introducing a dispersion response variable _D_ . This allows for a reformulation of the model in a DGLM form. We revisit [17] after proving Proposition 3.3. 

_**Proof of Proposition 3.3**_ We start by calculating the means of the terms of the score in (3.15). We have 

**==> picture [273 x 25] intentionally omitted <==**

and for the second term we receive 

1 3 

Making Tweedie’s compound Poisson model more accessible 

197 

**==> picture [239 x 54] intentionally omitted <==**

From these two formulas it follows that, indeed, the score in (3.15) is a residual with mean zero. The cross-covariance terms are easily obtained by noting that also the score in (3.14) is a zero mean residual. This implies 

**==> picture [314 x 98] intentionally omitted <==**

There remain the diagonal terms. For the first one we have, using integration by parts, 

For the second diagonal term we have, this provides the variance of the zero mean score in (3.14), 

**==> picture [338 x 47] intentionally omitted <==**

> Thus, for MLE of _휇_ and _휙_ we need to consider the scores in (3.14)–(3.15), the latter one defining (unscaled) residuals w.r.t. the dispersion given by 

**==> picture [242 x 26] intentionally omitted <==**

> As mentioned above, solving score Eqs. (3.14)–(3.15) produce the MLEs for _휇_ and _휙_ ; basically, this finishes the MLE problem. In the remainder of this section, following [17], we rewrite this MLE problem. This different representation introduces a new (dispersion) response variable _D_ , such that the root search problem can directly be related to Fisher’s scoring method in a DGLM form. Choose square variance function _Vd_ ( _휙_ ) = _휙_[2] and dispersion-prior weights 

**==> picture [227 x 25] intentionally omitted <==**

This allows us to define so-called dispersion responses 

**==> picture [305 x 26] intentionally omitted <==**

1 3 

Ł. Delong et al. 

198 

**==> picture [218 x 15] intentionally omitted <==**

**==> picture [230 x 23] intentionally omitted <==**

Fisher’s information contribution (3.16) then reads as 

**==> picture [204 x 33] intentionally omitted <==**

> As emphasized by [16], orthogonality of _휇_ and ( _휙_ , _p_ ) , see (3.17), typically leads to fast convergence in estimation algorithms. 

## _**Remarks 3.4**_ 

- We start from the joint distribution of ( _N_ , _Y_ ), given in (3.13), for estimating ( _휇_ , _휙_ ) . This estimation problem is modified by considering a new response vector ( _Y_ , _D_ ), instead. The new dispersion response _D_ , defined in (3.19), is not gamma distributed, but in view of score (3.20) we bring it into a gamma EDF structure with weight _v >_ 0 , dispersion parameter 2 and square variance function _Vd_ ( _휙_ ) = _휙_[2] , see also (2.5). In [17] it is mentioned that these definitions of _v_ and _D_ are somewhat artificial, but they bring this estimation problem into a DGLM 

- form; note that this requires to include one dispersion term _휙_ into the weight _v_ and the response _D_ , this means that we have an approximate score equation equivalence with a gamma MLE problem. In view of Proposition 3.3, we could _D_ 

- also define dispersion response differently by choosing an inverse Gaussian power variance function, i.e. _Vd_ ( _휙_ ) = _휙_[3] , and defining the dispersion-prior weight correspondingly. This provides the same numerical solution for MLE, using an approximate score equation equivalence with an inverse Gaussian MLE problem. However, in this latter version the weights do not provide the right scaling for a distribution within the EDF. 

- Alternatively, we could try to estimate dispersion _휙_ using Tweedie’s deviance residuals 

**==> picture [326 x 111] intentionally omitted <==**

- There is a third alternative of including a dispersion estimation, and this third one is the one implemented in the R package `dglm` . This requires that the dispersion parameter is made policy dependent and then a DGLM is explored on 

1 3 

Making Tweedie’s compound Poisson model more accessible 

199 

( _Y_ , E) by alternating the corresponding score updates. Also this approach does _N_ , _Y_ ) (in contrast to the CPG model), and it is not benefit from full information ( therefore not further explored in this manuscript. 

## **3.2.3  Double generalized linear model in the heterogeneous Tweedie case** 

We use the heterogeneous dispersion Tweedie’s CP approach and bring it into a DGLM form as described in the previous section. Choosing a suitable link function ⋅ _gp_ ( ) we make the following regression assumption for the linear predictor of the mean 

**==> picture [267 x 15] intentionally omitted <==**

upper indices[∗] distinguishing the parametrization in Tweedie’s CP GLM case from the individual models in Sect. 3.1. For the modeling of the dispersion parameter we choose a second link function _gd_ (⋅) such that we have the linear predictor 

_gd_ ( _휙i_ ) =[⟨] _**휶**_[∗] , _**z**_[∗] _i_ ⟩, (3.22) where the covariates _**z**_[∗] _i_[∈][Z][∗] _[⊂]_[{][1][} ×][ ℝ] _[q]_[∗][ are potentially differently pre-processed ] than the ones _**x**_[∗] _i_[∈][X][∗] _[⊂]_[{][1][} ×][ ℝ] _[d]_[∗][ , but still belong to the same policy ] _[i]_[. MLE of ] ( _**휷**_[∗] , _**휶**_[∗] ) requires solving the score equations, see (3.14) and (3.20), 

**==> picture [298 x 28] intentionally omitted <==**

**==> picture [340 x 58] intentionally omitted <==**

**==> picture [341 x 145] intentionally omitted <==**

1 3 

Ł. Delong et al. 

200 

**==> picture [257 x 16] intentionally omitted <==**

_**휶**_[∗] _t_[↦] _**[휶]**_[∗] _t_ +1[=][ (][ℨ][�] _[W][d]_[ℨ][)][−][1][ℨ][�] _[W][d]_ ( _**R** d_ + _gd_ ( _**흓**_ )), (3.26) where all terms on the right-hand side are evaluated at algorithmic time _t_ , that is, _Wp_ = _Wp_ ( _**휷**_[∗] _t_[,] _**[ 휶]**_[∗] _t_[)][ , ] _[W][d]_[=] _[ W][d]_[(] _**[휶]**_[∗] _t_[)][ , ] _**[R]**_[ =] _**[ R]**_[(] _**[휷]**_[∗] _t_[)][ , ] _**[R]**[d]_[=] _**[ R]**[d]_[(] _**[휷]**_[∗] _t_[,] _**[ 휶]**_[∗] _t_[)][ , ] _[g][p]_[(] _**[흁]**_[) =] _[ g][p]_[(] _**[흁]**_[(] _**[휶]**_[∗] _t_[))] and _gd_ ( _**흓**_ ) = _gd_ ( _**흓**_ ( _**휶**_[∗] _t_[))][ . This also indicates how the two sets of parameters inter-] act. Since parameters _**휷**_[∗] and _**휶**_[∗] are orthogonal, alternating the updates leads to fast convergence. Standard errors are obtained from the inverse of Fisher’s information matrix 𝔛� _W_ 𝔛 0 I( _**휷**_[∗] , _**휶**_[∗] ) = _p_ . (3.27) ( 0 ℨ[�] _Wd_ ℨ ) There remains estimation of _p_ . This is usually done by considering the profile log-likelihood for ∗ ∗ _p_ , given optimal estimates of _̂_ ∗ ( _**휷**_[∗] , _**휶**_[∗] ) _̂_ , that is, we study ∗ _p_ ↦ 퓁( _**휷**[̂]_ ( _p_ ), _̂_ _**휶**_ ( _p_ ), _p_ ) where, in general, the MLEs _**휷**_ ( _p_ ) and _**휶**_ ( _p_ ) depend on the explicit choice of the power variance parameter _p_ ; for an example of a profile loglikelihood we refer to Fig. 1, below. 

## _**Remarks 3.5**_ 

- We emphasize that covariates may be chosen and pre-processed differently in the CPG and in Tweedie’s CP models; this is indicated by choosing different notation for the covariate spaces (X, Z) and (X[∗] , Z[∗] ) , respectively. Different pre-processing of covariates might be necessary because we aim at optimally modeling different responses in the two models. This optimal modeling also includes good choices of link functions which may even imply that a CPG GLM does not lead to a Tweedie CP DGLM counterpart (or vice versa) because the linear predictor structure does not necessarily carry through general choices of link functions. In Sect. 3.3 we fully rely on log-links which allow for a one-to-one identification 

- scheme between the different GLM frameworks. 

- The calculation of the terms of Fisher’s information matrix involving _p_ are a bit cumbersome, for this reason we do not give them explicitly. 

- As usual in MLE, typically, the dispersion parameters _휙i_ will be under-estimated because MLE is not unbiased for variance parameter estimation, we refer to [17], Sects. 3.2 and 4.3. Using both total claim costs _Y_ and claim counts _N_ , the bias is often small, see [17]. 

We close this subsection by considering the special case of log-links for _gp_ and _gd_ . This special choice provides working weight matrices _Wp_ and _Wd_ 

**==> picture [319 x 26] intentionally omitted <==**

1 3 

Making Tweedie’s compound Poisson model more accessible 

201 

and working residual vectors _**R**_ = (( _Yi_ ∕ _휇i_ − 1)) _i_ =1,…, _n_ and _**R** d_ = (( _Di_ ∕ _휙i_ − 1)) _i_ =1,…, _n_ This provides us with score equations 

**==> picture [236 x 13] intentionally omitted <==**

**==> picture [238 x 13] intentionally omitted <==**

thus, in both cases we can use the same working weight matrix _Wp_ . 

**Theorem 3.6** _Assume Tweedie’s CP DGLM holds with covariate spaces_ X[∗] = Z[∗] _and covariate choices_ _**x**_[∗] _i_[=] _**[ z]**_[∗] _i[ for all insurance policies ][i]_[ =][ 1,][ …][ ,] _[ n]_[.] _[ Moreover, ]_ ∗ ∗ _assume that for both GLMs we choose log-links for gp and gd_ . _The MLE_ _**휷**[̂] of_ _**휷** does not depend on the explicit choice of the power variance parameter_ ∗ _p_ ∈(1, 2), _and also the corresponding mean estimates ̂휇i_ = exp⟨ _**휷**[̂]_ , _**x**_ ∗ _i_[⟩] _[ are p]_[-] _[independent. Assume ] that ̂휇i and 휙[̂] i_ ( _p_ ) _solve the score Eqs._ (3.28) _–_ (3.29) _for power variance parameter p_ ∈(1, 2). _The dispersion parameter estimates scale as a function of power variance parameters q_ ∈(1, 2) _as_ 

**==> picture [106 x 24] intentionally omitted <==**

## for all insurance policies _i_ . 

## _**Remarks 3.7**_ 

- Theorem 3.6 is a very useful and strong result. In general, we have to run Fisher’s MLEs scoring method for every power variance parameter _**휷**[̂]_ ∗( _p_ ) and _**휶** ̂_ ∗( _p_ ) . In a second step, the optimal power variance parameter _p_ ∈(1, 2) to find optimal is found by considering the profile log-likelihood in _p_ . Under the assumptions of Theorem MLEs _**휷**[̂]_ ∗ and 3.6 _**휶** ̂_ ∗ we only need to run Fisher’s scoring method once to receive ( _p_ ) for a fixed power variance parameter _p_ . All dispersion estimates for different power variance parameters are then directly obtained from Theorem 3.6, and mean parameter estimates do not vary in _p_ . That is, we can directly maximize function _q_ ↦ 퓁( _̂휇i_ , _휙[̂] i_ ( _q_ ), _q_ ) where the dispersion _휙[̂] i_ ( _q_ ) scales in _q_ according to Theorem 3.6. 

- Theorem 3.6 also highlights that the heterogeneous dispersion case is fundamentally different from the homogeneous one. The mean estimates in the homogeneous case depend on the choice of the power variance parameter _p_ through the working weight matrix _Wp_ in (3.12). In contrast to the heterogeneous dispersion case, a constant dispersion parameter does not leave any room to balance different _p_ ’s through portfolio varying dispersions. On the other hand, under the assumptions of Theorem 3.6, the mean estimates are not _p_ sensitive, which is equivalent to the CPG case. 

_**Proof of Theorem 3.6**_ The score equations for _**휷**_[∗] and _**휶**_[∗] are under log-link choices provide, see (3.14)–(3.15), 

1 3 

Ł. Delong et al. 

202 

**==> picture [341 x 121] intentionally omitted <==**

**==> picture [223 x 29] intentionally omitted <==**

thus, the pairs ( _휇i_ , _휙[̃] i_ ) fulfill the first score equation. We now need to massage these pairs through the second score equation for power variance parameter _q_ 

**==> picture [280 x 103] intentionally omitted <==**

Next we apply that the pairs ( _휇i_ , _휙i_ ) solve the score equations for _p_ . This provides for the score function of _**휶**_[∗] 

**==> picture [319 x 111] intentionally omitted <==**

> Now we still have one parameter _k >_ 0 that we can choose. We require 

**==> picture [226 x 23] intentionally omitted <==**

This choice implies that (3.30) is equal to zero which follows from the fact that the pairs ( _휇i_ , _휙i_ ) solve the score equations for _**휷**_[∗] = _**휷**_[∗] ( _p_ ) . This finishes the proof. In Remarks 3.10 we give a shorter proof. ◻ 

1 3 

Making Tweedie’s compound Poisson model more accessible 

203 

## **3.3  Relation between the two GLM approaches** 

We compare the CPG model to its counterpart being parametrized through Tweed2.6)–(2.9 ie’s CP model. To start off, recall formulas ( ). The first formula gives relationship _p_ = ( _훾_ + 2)∕( _훾_ + 1) ∈(1, 2) . Since these two parameters are not modeled insurance policy dependent, we directly identify them. We start with the gamma claim size GLM of Sect. 3.1 using identification (2.7). The means are given by, see (3.5), 

**==> picture [315 x 50] intentionally omitted <==**

> where we have used canonical link _휃_ = ( _휅_[�] _p_[)][−][1][(] _[휇]_[) = −] _[휇]_[1][−] _[p]_[∕(] _[p]_[ −][1][)][ . From identifica-] tion (2.9) we have 

**==> picture [289 x 38] intentionally omitted <==**

From identities (3.31)–(3.32) we conclude that for general link functions it is nontrivial to derive one parametrization from the other, i.e. this requires quite some feature engineering to bring the models in line (if possible at all). If we choose loglinks for _g_ 2 , _gp_ and _gd_ (these are not the canonical links in all three cases but they are convenient because they preserve the right sign convention on the canonical scale) we can directly compare the linear predictors 

**==> picture [202 x 26] intentionally omitted <==**

Formulating this differently gives us the following theorem. 

**Theorem 3.8** _Assume all link functions in_ (3.2), (3.5), (3.21) _and_ (3.22) _are chosen to be the log-links. The CPG GLM having constant shape parameter 𝛾>_ 0 _and Tweedie’s CP DGLM with variance parameter p_ = ( _훾_ + 2)∕( _훾_ + 1) ∈(1, 2) _can be identified by (i.e. the resulting two models are equal under) the following equations for the linear predictors_ 

**==> picture [221 x 26] intentionally omitted <==**

## **Conclusions and Remarks 3.9** 

- If we have found a good parametrization for the Poisson claim counts GLM and the gamma claim size GLM involving covariates _**x**_ ∈ X and _**z**_ ∈ Z , then Tweedie’s CP model should include all components present in _**x**_ ∪ _**z**_ , and _**x**_[∗] and _**z**_[∗] should only differ if some components of _**x**_ ∪ _**z**_ cancel out by a particular choice 

1 3 

Ł. Delong et al. 

204 

> of regression parameters _**휷**_ and _**휶**_ . The same holds true if we exchange the roles of the two models. 

- From the second identity of Theorem 3.8 we see that dispersion _휙i_ is constant over all policies _i_ if and only if 

**==> picture [326 x 138] intentionally omitted <==**

- We believe that covariate pre-processing is more easily done within the CPG model. The reason being, as stated above, that claim counts and claim sizes often X and Z allow 

- behave differently w.r.t. covariate information. Covariate spaces us to explore such differences individually. In Tweedie’s CP model everything is merged together which makes it more difficult to choose good covariates and to separate the different systematic effects. 

- Tweedie’s CP model calibrated with MLE will typically differ from the corresponding CPG model if we follow Theorem 3.8. The CPG model involves |X| + |Z| = _d_ + _q_ + 2 parameters. This typically results in a Tweedie CP model with |X[∗] | + |Z[∗] | = 2|X[∗] | parameters, which is bigger than _d_ + _q_ + 2 if X ≠ Z . Thus, in Tweedie’s CP model there are more parameters to be estimated if we follow the above guidance. 

We close this section by giving the log-likelihoods of Tweedie’s CP DGLM and of the CPG GLM under log-link choices. The one of Tweedie’s CP DGLM is given by 

**==> picture [329 x 74] intentionally omitted <==**

To make the log-likelihood of the CPG GLM directly comparable to (3.34), we make a change of variables ( _Ni_ , _Z[̄] i_ ) ↦ ( _Ni_ , _Yi_ ) by setting _Yi_ = _NiZ[̄] i_ ∕ _wi_ . This gives us log-likelihood 

1 3 

Making Tweedie’s compound Poisson model more accessible 

205 

**==> picture [328 x 67] intentionally omitted <==**

> Assuming covariate relationship _**x**_[∗] _i_[=] _**[ z]**_[∗] _i_[ we can re-parametrize the first log-likeli-] 

> hood (3.34) by setting _**휷**_[+] = (2 − _p_ ) _**휷**_[∗] − _**휶**_[∗] and _**휶**_[+] = −(1 − _p_ ) _**휷**_[∗] + _**휶**_[∗] , this gives us (we drop irrelevant terms) 

**==> picture [340 x 61] intentionally omitted <==**

**==> picture [248 x 17] intentionally omitted <==**

this explicitly uses that we have the same data representation ( _Ni_ , _Yi_ ) _i_ in both log-likelihoods. 

## _**Remarks 3.10**_ 

- Under the assumptions of Theorem 3.8 and additionally assuming that _**x** i_ = _**z** i_ = _**x**_[∗] _i_[=] _**[ z]**_[∗] _i_[ , we receive an identity in (][3.36][). Since the mean estimates in ] the CPG case do not depend on the particular choice of the shape parameter _훾_ , the same must hold true for Tweedie’s CP DGLM model under identical covariates _**x** i_ = _**z** i_ = _**x**_[∗] _i_[=] _**[ z]**_[∗] _i_[ . Using Proposition ][2.1][ we then receive the dispersion scal-] ing of Theorem 3.6, thus, this gives us a second shorter proof for Theorem 3.6. 

- If _**x**_[∗] _i_[=] _**[ z]**_[∗] _i_[=] _**[ x]**[i]_[ ∪] _**[z]**[i]_[ and ] _**[x]**[i]_[≠] _**[z]**[i]_[ , the CPG model is strictly nested in Tweedie’s ] CP model and, in general, we do not get an identity in (3.36). In that case, Theorem 3.8 reflects an ideal world because noise in the data prevents MLE estimated 

- parameters (estimated separately in both models) from strictly satisfying the identities in Theorem 3.8. 

- To perform model selection in the general case we can use Akaike’s information criterion (AIC) [1]. This corrects both sides of (3.36) by the number of regression parameters involved, thus, with AIC the model with the smaller value should be preferred from either 

**==> picture [327 x 85] intentionally omitted <==**

1 3 

Ł. Delong et al. 

206 

statistics _Yi_ = _NiZ[̄] i_ ∕ _wi_ . If, instead, we use the individual claim sizes _Zi_ , _j_ to estimate the CPG GLM, AIC does not apply because the log-likelihoods to be compared use the available data in different ways. 

## **4  Numerical examples** 

We study two numerical examples to benchmark the two modeling approaches of Theorem 3.8. First, we design a synthetic data example that fully meets the assumptions of Theorem 3.8 . Thus, there is no model uncertainty involved in this first (synthetic) example about underlying distributions, covariate spaces and link functions, and we can fully focus on estimating parameters with MLE in the CPG GLM and in Tweedie’s CP DGLM. These results are then compared to neural network regression approaches on the same synthetic data. In contrast to GLMs, neural networks explore optimal covariate selection themselves. This is done in Sect. 4.2.2. Our second example in Sect. 4.3 is a real data example. This additionally raises the issue of model uncertainty because the real data has not been generated by a CPG model. Both examples are based on the motorcycle insurance data `swmotorcycle` used in [11], this data is available through the R package `CASdatasets` [3], see Listing 1 for an excerpt of the data. For the synthetic data we sample a portfolio of covariates from the original data, and then generate claims with a CPG GLM designed according to the assumptions of Theorem 3.8. For the real data example we fully rely on the `swmotorcycle` data and we use the corresponding claim observations. 

## **4.1  Description of motorcyle data** 

We briefly describe the data, for more information we refer to “Appendix B”, below. The data comprises comprehensive insurance for motorcycles which covers loss or damage of motorcycles other than collision, for instance, caused by theft, fire or vandalism. The data is aggregated on insurance policy level for years 1994–1998. The data is shown in Listing 1. We have applied some pre-processing, e.g., we have dropped all policies that have an exposure equal to zero. 

Listing 1: Swedish motorcycle data swmotorcycle of [11] from the R package CASdatasets [3]. 

1 ’data.frame ’: 62036 obs. of 9 variables: 2 $ Age : num 36 52 25 50 45 24 52 47 30 32 ... 3 $ Gender : Factor w/ 2 levels "Female ","Male ": 2 2 2 2 1 1 1 1 1 1 ... 4 $ Zone : Factor w/ 7 levels "Zone 1"," Zone 2" ,..: 4 4 4 3 3 1 4 4 4 4 ... 5 $ McClass : int 1 4 7 4 6 3 4 4 3 3 ... 6 $ McAge : num 12 19 9 14 11 2 16 17 16 16 ... 7 $ Bonus : int 6 4 3 1 7 6 2 7 1 4 ... 8 $ Exposure : num 0.0274 0.4986 0.3863 1.9507 1.5014 ... 9 $ ClaimNb : int 0 0 0 0 0 0 0 0 0 0 ... 10 $ ClaimCosts: int 0 0 0 0 0 0 0 0 0 0 ... 

We briefly describe the variables, the following enumeration refers to lines 2–10 of Listing 1: 

1 3 

Making Tweedie’s compound Poisson model more accessible 

207 

2. `Age` : age of motorcycle owner in {18, … , 70} years (we cap at 70 because of scarcity above); 

3. `Gender` : gender of motorcycle owner either being `Female` or `Male` ; 

4. `Zone` : seven geographical Swedish zones being (1) central parts of Sweden’s three largest cities, (2) suburbs and middle-sized towns, (3) lesser towns except those in zones (5)–(7), (4) small towns and countryside except those in zones (5)–(7), (5) Northern towns, (6) Northern countryside, and (7) Gotland (Sweden’s largest island); 

5. `McClass` : seven ordered motorcycle classes received from the so-called EV ratio defined as (Engine power in kW × 100)/(Vehicle weight in kg + 75 kg); 

6. `McAge` : age of motorcycle in {0, … , 30} years (we cap at 30 because of scarcity beyond); 

7. `Bonus` : ordered bonus-malus class from 1 to 7, entry level is 1; 

8. `Exposure` : total exposure in yearly units in interval [0.0274, 31.3397], the shortest entry referring to 1 day and the longest one to more than 31 years;[1] 

9. `ClaimNb` : number of claims _N_ on the policy; 

10. `ClaimCosts` : total claim costs _S_ =[∑] _[N] j_ =1 _[Z][j]_[ on the policy (thus, we do not have ] information about individual claims _Z Z_ on _j_ but only about sufficient statistics _[̄]_ 

each policy). 

The data is illustrated in “Appendix B”. 

## **4.2  Synthetic data example** 

This section is based on synthetic (simulated) data from a CPG GLM. 

## **4.2.1  A generalized linear model approach** 

We start by describing the simulation of the synthetic data. We randomly choose _n_ = 250[�] 000 insurance policies from `dat=swmotorcycle` using the R code: 

횙횘횛횝횏횘횕횒횘 _<_ − 획횊횝[횜횊횖횙횕횎(횡 = 회(ퟷ ∶ 횗횛횘횠(획횊횝)), 횜횒횣횎 = ퟸퟻퟶ,ퟶퟶퟶ, 횛횎횙횕횊회횎 = 횃횁횄홴), ] 

Based on this `portfolio` we generate claims ( _N_ , _Y_ ) using two GLMs that fulfill the CPG assumptions of Theorem 3.8, the modeling details are specified in columns 1–3 of Table 1. We especially emphasize that the covariate spaces X and Z differ for claim counts and claim sizes. 

_CPG GLM_ We estimate the Poisson claim counts GLM and the gamma claim amounts GLM separately, according to Sect. 3.1 and under log-link choices. The results are presented in column ‘estimated CPG’ of Table 1, the brackets provide one estimated standard deviation received from the inverse of Fisher’s information matrix. Note that we can estimate all regression parameters _훽k_ and _훼k without_ 

> 1 For a rigorous pricing exercise one should truncate longer exposures, say, to one accounting year, otherwise one implicitly considers a survival bias on policies with longer exposures, supposed that people give up motorcycling more likely after a claim. 

1 3 

Ł. Delong et al. 

208 

**Table 1** Synthetic CPG GLM example: the first 3 columns show the chosen (true) model; column ‘estimated CPG’ shows the resulting MLEs (with estimated std.dev. brackets) 

|Variable|Parameter|True|Estimated|Standard|
|---|---|---|---|---|
|||Value|Param. CPG|deviation|
|Intercept|_훽_0|13.80|12.99|(1.46)|
|홰횐횎|_훽_1|−0.180|−0.188|(0.010)|
|홰횐횎2|_훽_2|1.70×103|1.74×103|(0.12×103)|
|홶횎횗획횎횛|_훽_3|0.30|0.36|(0.07)|
|횉횘횗횎ퟸ|_훽_4|−0.60|−0.58|(0.05)|
|횉횘횗횎ퟹ|_훽_5|−1.10|−1.07|(0.06)|
|횉횘횗횎ퟺ|_훽_6|−1.50|−1.46|(0.05)|
|횉횘횗횎ퟻ|_훽_7|−1.60|−1.39|(0.10)|
|홼회홲횕횊횜횜|_훽_8|−14.50|−13.42|(1.72)|
|홼회홲횕횊횜횜2|_훽_9|2.30|2.16|(0.27)|
|log(홼회홲횕횊횜횜)|_훽_10|12.60|11.52|(1.58)|
|홼회홲횕횊횜횜3|_훽_11|−0.140|−0.134|(0.017)|
|홼회홰횐횎|_훽_12|−0.140|−0.147|(0.008)|
|홼회홰횐횎2|_훽_13|2.60×103|2.86×103|(0.36×103)|
|Intercept|_훼_0|8.650|8.650|(0.143)|
|홰횐횎|_훼_1|0.110|0.113|(0.008)|
|홰횐횎2|_훼_2|−1.40×103|−1.44×103|(0.10×103)|
|홼회홲횕횊횜횜|_훼_3|8.0×102|7.3×102|(1.0×102)|
|홼회홰횐횎2|_훼_4|−2.80×102|−2.90×102|(0.13×102)|
|홼회홰횐횎3|_훼_5|1.80×103|1.91×103|(0.12×103)|
|홼회홰횐횎4|_훼_6|−3.0×105|−3.3×105|(0.5×105)|
|Shape param.|_훾_|1.50|1.56|(0.04)|



**==> picture [338 x 155] intentionally omitted <==**

**----- Start of picture text -----**<br>
gamma log−likelihood for shape parameter Tweedie profile log−likelihood for p estimation<br>1.0 1.2 1.4 1.6 1.8 2.0 1.36 1.37 1.38 1.39 1.40 1.41<br>shape parameter gamma power variance parameter p<br>−30250<br>−43110<br>−43112<br>−30300<br>−43114<br>−43116<br>log−likelihood log−likelihood<br>−30350<br>−43118<br>−43120<br>−30400 −43122<br>**----- End of picture text -----**<br>


**Fig. 1** (lhs) Log-likelihood _훾_ ↦ 퓁( _**휶** ̂_ , _훾_ ) of the gamma GLM to estimate shape parameter ∗ ∗ _훾_ for given _**휶** ̂_ ; (rhs) Tweedie profile log-likelihood _p_ ↦ 퓁( _**휷**[̂]_ , _̂_ _**휶**_ ( _p_ ), _p_ ) to estimate _p_ 

1 3 

Making Tweedie’s compound Poisson model more accessible 

209 

> specifying shape parameter _𝛾>_ 0 explicitly. Most estimated parameters are within one standard deviation of the true parameter values. The true parameters have been chosen such that they resemble the true data `swmotorcycle` . The true data has an observed claim frequency of only 1.05%, see “Appendix B”. In the present example, claims are scarce too, and the gamma claim size GLM has been estimated on (only) 2’795 claims. The parameter estimates are remarkably accurate (we do not have model uncertainty here, only parameter estimation uncertainty). We conclude that this model can be calibrated well using the separate approach for claim counts and claim amounts. 

_̂_ Figure 1 (lhs) considers the log-likelihood function _훾_ ↦ 퓁( _**휶**_ , _훾_ ) of the gamma GLM to estimate shape parameter _훾_ , we also refer to score Eq. (3.9). From this we find MLE _̂훾_ = 1.56 , and the inverse of Fisher’s information matrix provides an estimated standard deviation of 0.04 for this estimate. Thus, the estimated shape parameter is slightly too high, though still within two standard deviations of the true value of _훾_ = 1.5 . We again highlight that this estimate is based on only 2’795 claims. Moreover, we remark that _̂훾_ has been used in the standard deviation estimates of Table 1, see (3.8). 

_Tweedie’s DGLM_ Next we turn our attention to Tweedie’s CP case. The true val- _̂_ ues _**휷**_ , _**휶**_ and _훾_ as well as their MLE counterparts _**휷**[̂]_ , _**휶**_ and _̂훾_ from the CPG model are transformed with Theorem 3.8 to receive the same model in Tweedie’s CP para2 metrization, this is illustrated in the first four columns of Table . In a first calibration step for Tweedie’s CP model, we choose _p_ = 1.39 which is the optimal power variance parameter estimate of the CPG model, see last line in column 4 of Table 2. We then calibrate Tweedie’s CP DGLM model for this power variance parameter _p_ with Fisher’s scoring method (3.25)–(3.26); as starting values for the algorithm we use the estimates from the CPG model (in italic in Table 2). Fisher’s scoring method converges in 7 iterations with these initial values. Due to (3.36) we receive a model that has a bigger log-likelihood than its CPG counterpart (we include all constants in this consideration so that the log-likelihoods are directly comparable). 

In the next step, we optimize over the power variance parameter _p_ . Therefore, we use Theorem 3.6, which says that the mean estimates _̂휇i_ do not depend on _p_ , and which provides the _p_ -scaling for dispersion parameter MLEs ∗ ∗ _휙[̂] i_ ( _p_ ) . This allows us to directly plot the profile log-likelihood _p_ ↦ 퓁( _**휷**[̂]_ , _̂_ _**휶**_ ( _p_ ), _p_ ) as a function of _̂ p_ ∈(1.36, 1.41) , see Fig. 1 (rhs). From this figure, we find maximizing value Table _p_ = 1.392 shows the resulting MLEs  , which is close to the true value of _**휷**[̂]_ ∗ and _**휶** ̂_ ∗( _̂p_ ) of the optimal Tweedie’s CP model. _p_ = 1.4 . The second last column in A first observation is that the parameter estimates from Tweedie’s CP model are not as close to the true values as the MLEs from the CPG model. However, model selection should not be based on this observation: note that the (true) CPG model has 22 parameters and Tweedie’s CP model has 33 parameters, therefore, we expect some differences in model calibration. 

log-likelihoods We summarize the two estimated models in Table 퓁CPG( _**휷**[̂]_ , _̂_ _**휶**_ , _̂p_ ) and 퓁Tw( _**휷**[̂]_ ∗, _̂_ _**휶**_ ∗, _̂p_ ) of the estimated models CPG and 3. On row (a) we compare the Tweedie’s CP, see also (3.36), to the one of the true model 퓁( _**휷**_[∗] , _**휶**_[∗] , _p_ ) : we observe that both models slightly overfit to the data, with Tweedie’s CP model having a 

1 3 

Ł. Delong et al. 

210 

**Table 2** Synthetic example: the first 3 columns show the chosen (true) model; column ‘estimated CPG’ (in italic) shows estimated parameters from the CPG model; column ‘estimated Tweedie’s CP’ shows the MLEs from Tweedie’s CP model (with estimated std.dev. in brackets) 

|Variable|Parameter|True|Estimated|Estimated|Standard|
|---|---|---|---|---|---|
|||Value|Param. CPG|Param. Tweedie’s CP|Deviation|
|Intercept|_훽_∗<br>0|22.45|21.64|19.50|(1.87)|
|홰횐횎|_훽_∗<br>1|− 7.0×102|− 7.5×102|− 7.5×102|(1.3×102)|
|홰횐횎2|_훽_∗<br>2|3.0×104|3.1×104|3.0×104|(1.6×104)|
|홶횎횗획횎횛|_훽_∗<br>3|0.30|0.36|0.40|(0.09)|
|횉횘횗횎ퟸ|_훽_∗<br>4|− 0.60|− 0.58|− 0.52|(0.07)|
|횉횘횗횎ퟹ|_훽_∗<br>5|− 1.10|− 1.07|− 0.99|(0.08)|
|횉횘횗횎ퟺ|_훽_∗<br>6|− 1.50|− 1.46|− 1.42|(0.07)|
|횉횘횗횎ퟻ|_훽_∗<br>7|− 1.60|− 1.39|− 1.36|(0.12)|
|홼회홲횕횊횜횜|_훽_∗<br>8|− 14.42|− 13.35|− 10.79|(2.20)|
|홼회홲횕횊횜횜2|_훽_∗<br>9|2.30|2.16|1.72|(0.35)|
|log(홼회홲횕횊횜횜)|_훽_∗<br>10|12.60|11.52|9.39|(2.03)|
|홼회홲횕횊횜횜3|_훽_∗<br>11|− 0.140|− 0.134|− 0.103|(0.0221)|
|홼회홰횐횎|_훽_∗<br>12|− 0.140|− 0.147|− 0.196|(0.047)|
|홼회홰횐횎2|_훽_∗<br>13|− 2.54×102|− 2.62×102|− 1.98×102|(0.77×102)|
|홼회홰횐횎3|_훽_∗<br>14|1.80×103|1.91×103|1.63×103|(0.49×103)|
|홼회홰횐횎4|_훽_∗<br>15|− 3.0×105|− 3.3×105|− 2.9×105|(0.8×105)|
|intercept|_훼_∗<br>0|0.1808|0.6909|− 0.5702|(0.9114)|
|홰횐횎|_훼_∗<br>1|0.1380|0.1420|0.1429|(0.0061)|
|홰횐횎2|_훼_∗<br>2|− 1.5×103|− 1.6×103|− 1.6×103|(0.1×103)|
|홶횎횗획횎횛|_훼_∗<br>3|− 0.120|− 0.140|− 0.115|(0.043)|
|횉횘횗횎ퟸ|_훼_∗<br>4|0.240|0.228|0.269|(0.034)|
|횉횘횗횎ퟹ|_훼_∗<br>5|0.440|0.417|0.462|(0.037)|
|횉횘횗횎ퟺ|_훼_∗<br>6|0.60|0.57|0.59|(0.03)|
|횉횘횗횎ퟻ|_훼_∗<br>7|0.640|0.543|0.558|(0.060)|
|홼회홲횕횊횜횜|_훼_∗<br>8|5.848|5.288|6.714|(1.074)|
|홼회홲횕횊횜횜2|_훼_∗<br>9|− 0.920|− 0.845|− 1.094|(0.169)|
|log(홼회홲횕횊횜횜)|_훼_∗<br>10|− 5.040|− 4.500|− 5.654|(0.990)|
|홼회홲횕횊횜횜3|_훼_∗<br>11|5.6×102|5.2×102|6.9×102|(1.1×102)|
|홼회홰횐횎|_훼_∗<br>12|5.6×102|5.7×102|5.2×102|(2.3×102)|
|홼회홰횐횎2|_훼_∗<br>13|− 1.78×102|− 1.88×102|− 1.74×102|(0.38×102)|
|홼회홰횐횎3|_훼_∗<br>14|1.1×103|1.2×103|1.0×103|(0.2×103)|
|홼회홰횐횎4|_훼_∗<br>15|− 2×105|− 2×105|− 2×105|(0.4×105)|
|variance param.|p|1.40|1.39|1.39||
|slightly larger|overft [this|is consistent|with (3.36)]. Therefore, we penalize in AIC|||
|the log-likelihoods of the models by the number of parameters involved,|||||see (3.37).|
|The AIC values are given on row (b)|||of Table3,|and we give preference to the||
|CPG calibration. Performing a likelihood-ratio test||||having the CPG model as null||
|1 3||||||



Making Tweedie’s compound Poisson model more accessible 

211 

**Table 3** Synthetic example: summary statistics of fitted CPG and Tweedie’s CP GLMs 

|**Table 3**Synthetic example: summary statist|ics of ftted CPG and|Tweedie’s CP GLMs||
|---|---|---|---|
||True|Estimated|Estimated|
||Parameters|CPG|Tweedie CP|
|(a) log-likelihood퓁(**_휷_**,**_휶_**,_p_)|-43’125|-43’115|-43’109|
|(b) Akaike information criterion AIC||86’273.56|86’283.27|
|(c) Rooted mean square error (RMSE)||58.30|80.49|
|(d) Average of means_wi휇i_ =_wi휆i휁i_|340|346|347|
|(e) Std. dev. in means_wi휇i_ =_wi휆i휁i_|835|853|857|
|(f) Average of dispersions_휙i_|4530|4724|4746|
|(g) Std. dev. in dispersions_휙i_|1847|1898|1924|



hypothesis model nested in Tweedie’s CP model, gives a _p_ -value of 34%, thus, we do not reject the null hypothesis on a 5% significance level. This gives support that we should go for the smaller CPG model in this example. Row (c) of Table 3 gives the rooted mean square error (RMSE) between the true model means _wi휇i_ and their estimated counterparts _wî휇i_ = _wi휆[̂] i휁[̂] i_ ; rows (d)–(g) show average means and dispersions as well as the corresponding standard deviations. We observe that these figures match the true values quite well. Recall that these figures are based on one simulation from the true model for each insurance policy, thus, they involve simulation error (but they do not involve model error because we only assume parameters _**휷**_ , _**휶**_ and _p_ as unknown in this example). Moreover, we remark that the dispersion is not under-estimated, here, we also refer to the last bullet point of Remark 3.5. 

Finally, in Fig. 2 we plot the predicted means _̂휇i_ against the true values _휇i_ . The left-hand side compares the two estimated models against the true model, and the right-hand side compares the two estimated models against each other. From these plots we conclude that both models are very accurate, the CPG estimated one (orange) being slightly closer to the true model than its Tweedie’s CP counterpart (green). Summarizing: This synthetic example gives evidence supporting industry practice on focusing on the CPG model. Specifying covariate spaces is easier in the CPG case because systematic effects of claim counts and claim amounts are clearly separated, and in our example accuracy is slightly higher because Tweedie’s CP seems to slightly overfit in our example. 

## **4.2.2  A neural network regression approach** 

Next we explore neural network regression models on the same synthetic data. Neural networks have the capability of representation learning which means that they can perform covariate engineering themselves, we refer to Sections 4 and 5 of [21]. Therefore, covariates can be provided in their raw form to neural networks. The neural networks then, at the same time, pre-process these covariates and predict the response variables. Starting from a GLM, the required changes to achieve this representation learning are comparably small. We illustrate this in the present 

1 3 

Ł. Delong et al. 

212 

**Fig. 2** (lhs) Comparison of estimated means _̂휇i_ versus true means _휇i_ : CPG GLM (orange) and Tweedie CP DGLM (green), (rhs) CPG GLM means versus Tweedie CP DGLM means over all _i_ = 1, … , _n_ policies 

section. Alternatively, one may also be interested in using generalized additive models (GAMs). GAMs are more flexible in modeling different functional forms in the components of the covariates compared to GLMs, however, they do not automatically allow for flexible interaction modeling between covariate components. For this reason, we favor neural networks over GAMs. 

We first define the (raw) covariate space X[†] which is going to be used throughout this section: 

**==> picture [287 x 12] intentionally omitted <==**

> where we use dummy coding for the categorical variable 횉횘횗횎 ∈{0, 1}[4] . In contrast to Table 1, we do not specify the continuous variables in all its functional forms, but we let the neural network find these functional forms. A neural network is a function 

**==> picture [238 x 12] intentionally omitted <==**

that consists of a composition of a fixed number of hidden network layers, each of them having a certain number of hidden neurons. For an explicit mathematical definition we refer to Section 3.1 in [21]. _**x**_[†] has the interpretation of being the raw covariate, and _**x**_ = _휓_ ( _**x**_[†] ) ∈ ℝ _[d]_ can be interpreted as the (network) pre-processed covariate. These pre-processed covariates _휓_ ( _**x**_[†] ) are then used in a classical GLM, e.g., for claim counts we may set for the log-link choice, see (3.2), 

**==> picture [329 x 42] intentionally omitted <==**

> note that we use a slight abuse of notation here because strictly speaking _휓_ ( _**x**_[†] ) does not include an intercept term for _훽_ 0 , so this always needs to be added. Neural 

1 3 

Making Tweedie’s compound Poisson model more accessible 

213 

> network regression function (4.3) involves regression parameters _**휷**_ ∈ ℝ _[d]_[+][1] as well 

> as network weights _휗_ ∈ ℝ _[r]_ which parametrize network function _휓_ = _휓휗_ . The dimension _r_ of _휗_ depends on the complexity of the chosen network _휓_ . Network fitting now trains at the same time network parameter _휗_ for an optimal covariate pre-processing 

> as well as GLM parameter _**휷**_ for response prediction. State-of-the-art fitting uses variants of the gradient descent algorithm, and a good performance depends on the 

> complexity of _휓_ , we just mention the universal approximation property of appropriately designed neural networks. For more information, we refer to the relevant literature, in particular, to [21]. Based on this reference we explore (4.3) and its counterparts for claim counts and Tweedie’s CP model. In all three prediction problems we use the identical covariate space X[†] , and only network function _휓_ will differ in the weights _휗_ to bring covariates into the appropriate form for the corresponding prediction task. 

_Poisson claim counts_ We start by modeling claim counts using neural network approach (4.3). We use the R library `keras` to implement this, and we use exactly the same architecture as in Listing 4 of [14], the only thing that changes is the dimension of X[†] from 40 on line 1 of Listing 4 in [14] to 8 in the present example, see (4.1). This results in _r_ = 655 and _d_ + 1 = 11 parameters. We fit these parameters in the usual way by considering 80% of the data for training and 20% of the data for out-of-sample validation to track overfitting in the gradient descent algorithm (we run 100 epochs on batch size 5000). We then choose the parameter that has the best out-of-sample performance on the validation data. To this network solution we apply the bias regularization step of Listing 5 in [21] to make the model unbiased. 

On rows (a1)–(a2) of Table 4 we present the results for the claim counts neural network model. We provide the Poisson deviance losses of the true model _휆i_ (which is known here because we simulate from this model), the intercept model that does not use covariate information (i.e. is only based on intercept parameter _훽_ 0 ), the claim counts GLM (upper part of Table 1) and its neural network counterpart. We observe that both regression models slightly overfit to the data 8.4366 ⋅ 10[−][2] and 8.4393 ⋅ 10[−][2] , respectively, compared to the true model loss of 8.4431 ⋅ 10[−][2] . 

On row (a2) we provide the RMSE between the true model means _휆i_ and the estimated ones _휆[̂] i_ . We note that the Poisson GLM has a smaller RMSE than the neural network Poisson regression model. This is not surprising because the Poisson GLM uses the right functional form (no model uncertainty) and only estimates regression parameter _**휷**_ whereas the neural network regression model also determines this functional form for the raw covariates _**x**_[†] . In Fig. 3 (lhs) we compare the resulting estimated frequencies to the true ones on all individual insurance policies _i_ = 1, … , _n_ . From this plot we conclude that both models do a fairly good job because the dots lie more or less on the diagonal (which reflects the perfect model). 

_Gamma claim sizes_ Next we consider a neural network approach for the gamma claim sizes. This essentially means that we replace linear predictor (3.5) by the following neural network predictor (under a log-link choice for _g_ 2) 

1 3 

Ł. Delong et al. 

214 

**Table 4** Comparison of deviance losses and RMSEs of the true (synthetic) model, the intercept model not using covariate information, the GLM approaches and the neural network approaches 

||True model|Intercept|GLM model|Neural network|
|---|---|---|---|---|
|||Model||Model|
|(a1) Poisson deviances for_Ni_(in10−2)|8.4431|9.8052|8.4366|8.4393|
|(a2) RMSE between_휆i_and_̂휆i_||2.06%|0.18%|0.55%|
|(b1) Gamma deviances for_̄Zi_|0.7058|1.1442|0.7052|0.7015|
|(b2) RMSE between_휁i_and_̂휁i_||27’210|693|4’460|



**Fig. 3** (lhs) Comparison of estimated models versus true model: (lhs) Poisson claim counts models for _Ni_ ; (rhs) gamma claim size models for _Z[̄] i_ 

**==> picture [325 x 43] intentionally omitted <==**

> where _휓_ is a neural network function (4.2) that may have the same structure as the one used for the Poisson regression model (4.3), but typically differs in network weights _휗_ . For simplicity, we use exactly the same neural network architecture as in the Poisson case, only the exposure offset is dropped and the Poisson deviance loss function is changed to the gamma deviance loss function (including weights), in line with the distributional assumptions made. 

The results are presented on rows (b1)–(b2) of Table 4 and Fig. 3 (rhs) (we run 1000 epochs on batch size 5000 and we callback the model with the smallest validation loss). Again we receive reasonably good results from the network approach, i.e., covariate engineering on X[†] is done quite well by the network, we emphasize that these results are based on only 2’795 claims. But we also see from Fig. 3 (rhs) that individual predictions spread more around the diagonal than in the gamma GLM case (where we assume perfect knowledge about the functional form of the 

1 3 

Making Tweedie’s compound Poisson model more accessible 

215 

**Table 5** Synthetic example: summary statistics of the fitted CPG and Tweedie’s CP neural network models 

|**Table 5**Synthetic example: summary statis<br>els|tics of the ftted CPG a|nd Tweedie’s CP neu|ral network mod-|
|---|---|---|---|
||True|Estimated|Estimated|
||Parameters|CPG|Tweedie CP|
|(a) Network log-likelihood퓁(**_휷_**,**_휶_**,_p_)|-43’125|-43’110|-43’079|
|(b) Power variance parameter_p_|1.400|1.389|1.390|
|(c) Rooted mean square error (RMSE)||190.33|225.50|
|(d) Average of means_wi휇i_ =_wi휆i휁i_|340|335|357|
|(e) Std. dev. in means_wi휇i_ =_wi휆i휁i_|835|812|872|
|(f) Average of dispersions_휙i_|4530|4595|5264|
|(g) Std. dev. in dispersions_휙i_|1847|1812|1950|



regression function). Better accuracy can only be achieved by having more claim observations. 

> Next, we estimate the shape parameter _훾_ . This is done analogously to the gamma 

> GLM case by plotting the corresponding log-likelihood 퓁( _훾_ ) as a function of _훾_ . This 

> gives estimate _̂훾_ = 1.57 , which is slightly too large but still reasonable compared to 

> the true value of _훾_ = 1.5 . A too high shape parameter implies a too low dispersion, which is a sign of over-fitting to the observations. 

We conclude with the summary statistics for the neural network approaches in Table 5 column ‘estimated CPG’, which look fairly similar to the GLM ones in Table 3. We obtain a larger RMSE, which is not surprising because we have more model uncertainty due to missing covariate knowledge, this is also obvious from Fig. 3. 

_Tweedie’s compound Poisson neural network approach_ First, we remark that, in general, there is no simple comparison between a CPG and a Tweedie CP neural network approach similar to (3.34)–(3.35). The relation (3.34)–(3.35) is strongly based on the fact that we can directly compare linear predictors under suitable choices of covariate spaces. Since the networks given (4.2) transform covariates in a non-trivial way under non-linear activation functions, there is no hope to get an easy comparison between the models unless the network architectures are chosen in a very specific way, i.e. artificial way, so to say. Therefore, we do not aim to nest the CPG neural network into Tweedie’s CP neural network model, but we directly focus on modeling the latter. This essentially implies that we have to replace linear predictors (3.21)–(3.22) by the following two-dimensional neural network predictors (under log-link choices for _gp_ and _gd_ ) 

**==> picture [310 x 13] intentionally omitted <==**

> where _휓_ is a neural network function (4.2). The first component of ( _휇_ , _휙_ )( _**x**_[†] ) ∈ ℝ[2] + predicts the total claim costs _Y_ and the second component estimates the dispersion 

> parameter _휙_ . We use one network _휓_ to simultaneously perform this prediction task for mean and dispersion parameter. We implement this in the R library `keras` and we use the same architecture as in Listing 4 of [14], but we need to change the 

1 3 

Ł. Delong et al. 

216 

**Fig. 4** (lhs) comparison of estimated means _̂휇i_ versus true means _휇i_ : CPG neural network (orange) and Tweedie CP neural network (green), (rhs) CPG network means versus Tweedie CP neural network means over all _i_ = 1, … , _n_ policies 

input dimension to 8 and the output dimension to 2. The exposures _wi_ are treated as weights as follows 

**==> picture [246 x 32] intentionally omitted <==**

This requires a custom made loss function in `keras` for parameter estimation, the details are provided in Listing 2 in the “Appendix”. We fit this model with the gradient descent algorithm exactly using the same methodology as outlined above (callback of the lowest validation loss model after 100 epochs on batch sizes 5000). 

In order to come up with the optimal neural network model we need to fit neural networks for multiple power variance parameters _p_ , because there is no result similar to Theorem 3.6 that allows for a shortcut. Of course, this disadvantages Tweedie’s CP neural network model from a computational point of view. We come up with _̂_ an optimal power variance parameter estimate of _p_ = 1.390 , which yields then the results in the last column of Table 5 . From the figures on rows (c)–(g) we conclude that Tweedie’s CP approach is not fully competitive with the CPG fitting. These differences are also illustrated in Fig. 4 with the CPG approach being slightly closer to the true model means. Nevertheless, all these estimates look very reasonable and the estimated neural network seems to capture the crucial features of the true model. 

_Conclusions from our synthetic data example_ Our findings support industry practice of focusing on the CPG parametrization. Our estimated models based on this parametrization are closer to the true model than the ones obtained from Tweedie’s CP parametrization. If we work under GLM assumptions we need to pre-process covariates which is easier in the CPG parametrization because systematic effects of claim counts and claim amounts can be separated. If we work under neural network regression models, model calibration is not efficient under Tweedie’s CP parametrization because we need to run gradient descent algorithms on multiple power 

1 3 

Making Tweedie’s compound Poisson model more accessible 

217 

|**Table 6**Comparison of gamma<br>deviance losses on real data:<br>intercept model and gamma<br>neural network regression model|Intercept<br>Neural network<br>Model<br>Model|
|---|---|
||Gamma deviances losses<br>for_̄Zi_<br>2.0854<br>1.5863|



variance parameters _p_ to find the optimal model. Moreover, in our example, the CPG case leads to more accurate predictive models. 

## **4.3  Real data example: an outlook** 

In view of the previous example everything seems to be fairly clear. However, our synthetic data is based on the very strong property of having gamma claim sizes with constant shape parameter _훾_ over the whole insurance portfolio. This assumption may be critical in real insurance applications. We briefly analyze it in terms of our real data example given in “Appendix B”, and we give an outlook in case this assumption is not fulfilled. We keep this section very short, and we mainly view it as a motivation to conduct future research in this direction. 

There are two possibilities in which the constant shape parameter assumption may fail, either the claim sizes are gamma distributed, but the shape parameter _훾i_ is also insurance policy _i_ dependent, or the gamma distribution is inappropriate due to that the claim sizes exhibit too heavy tails. We explore this on the real data example provided in “Appendix B”. For this it suffices to focus on the gamma claim size model, i.e. we do not study claim counts in this real data example. Moreover, to minimize covariate pre-processing we explore a gamma neural network regression model on these claim sizes, the chosen model architecture is identical to the one used in (4.4), in particular, it does covariate engineering itself. 

Table 6 shows the (in-sample) gamma deviance losses of the intercept model and the neural network regression model. Obviously, the neural network approach has a better performance (note that the network model has been received by a proper training-validation analysis as described above). Using the resulting mean estimates _휁[̂] i_ we can estimate the (constant) shape parameter _훾_ . This is illustrated in Fig. 5 (lhs): we estimate _̂훾_ = 0.75 . Thus, we receive a shape parameter smaller than 1, which provides over-dispersion 1∕ _�𝛾_ = 1.33 _>_ 1 , i.e., the estimated gamma densities are strictly decreasing. This fact requires further examination because there might be two situations: either the true shape parameter is smaller than 1 (and everything is fine), or the claim sizes are more heavy tailed than a gamma distribution allows. This is typically compensated by over-dispersion in the estimated model. We analyze this warning signal on our real data. 

Figure 5 (rhs) gives the Tukey–Anscombe plot of the gamma deviance residuals against the fitted means. This plot supports the model choice because we cannot see any particular structure in the figure, it also supports the constant shape parameter assumption on _훾_ . Figure 6 gives the QQ-plot and it compares the observed claims 

1 3 

Ł. Delong et al. 

218 

**==> picture [143 x 148] intentionally omitted <==**

**----- Start of picture text -----**<br>
gamma log−likelihood for shape parameter<br>0.6 0.8 1.0 1.2 1.4<br>shape parameter gamma<br>−7100<br>−7120<br>−7140<br>−7160<br>log−likelihood<br>−7180<br>−7200<br>−7220<br>**----- End of picture text -----**<br>


**Fig. 5** (lhs) Log-likelihood _훾_ ↦ 퓁( _훾_ ) of the gamma neural network to estimate shape parameter _훾_ on the real data, (rhs) Tukey–Anscombe plot giving gamma deviance residuals against fitted means 

**==> picture [210 x 149] intentionally omitted <==**

**----- Start of picture text -----**<br>
model empirical density of claim sizes<br>real data<br>simulated data<br>. F E<br>°<br>°<br>\<br>= = ———<br>8 0 50000 100000 150000 200000<br>claim amounts in SEK 1'000<br>4e−05<br>3e−05<br>2e−05<br>empirical density<br>1e−05<br>0e+00<br>**----- End of picture text -----**<br>


**Fig. 6** (rhs) QQ-plot of the estimated gamma model for claim sizes, (rhs) density of real data compared to one simulation from the estimated model 

against one simulation from the fitted model. Also these two plots look quite reasonable, one may only question the upper tail of the QQ-plot. 

_Conclusions_ The short analysis on the real data has shown that for the motorcycle claims data the gamma claim size model is fairly reasonable, thus, supporting the CPG model. On different data, one may relax the constant shape parameter assumption on _훾_ . This may result in a DGLM for gamma claim sizes (which is known in industry) and a Poisson GLM for claim counts. Again this model can easily be fitted in the Poisson-gamma parametrization, however, this approach does not have a Tweedie’s CP counterpart relying on a fixed parameter _p_ , giving more support to the industry preference of choosing the Poisson-gamma parametrization. 

1 3 

Making Tweedie’s compound Poisson model more accessible 

219 

## **5  Conclusion** 

We have revisited the compound Poisson model with i.i.d. gamma claim sizes. This model allows for two different parametrizations, namely, the Poisson-gamma parametrization and Tweedie’s compound Poisson parametrization. We have provided results for GLMs illustrating when the two parametrizations are identical, and we have provided a theorem that allows for efficient fitting of power variance parameters in Tweedie’s parametrization (under log-link choices for the GLMs). 

In the applied section, we have analyzed why the insurance industry gives preference to the Poisson-gamma parametrization. Based on examples, we find that, indeed, this parametrization is easier to fit, and results turn out to be more accurate in our examples. In particular, under neural network regression models we give a clear preference to the Poisson-gamma parametrization because Tweedie’s version does not possess an easy and efficient way in estimating the power variance parameter. That is, the Tweedie version is computationally clearly lacking behind the Poisson-gamma case. 

For our real data example it turns out that the gamma claim size model with constant shape parameter is quite reasonable. However, in many other applications this is not the case. Therefore, insurance industry explores double GLMs for a flexible modeling of shape parameters of claim sizes; on the other hand, a case-dependent _p_ modeling in Tweedie’s compound Poisson parametrization is not (easily) feasible. For modeling more heavy tailed claim sizes, mixture models are a promising proposal. 

## **Appendix** 

## **A Generalized linear models** 

GLMs have been introduced in [9], and they have been studied in the monograph [7]. GLMs are based on the EDF (2.2). The EDF has been studied extensively in [2, 4, 5], and its properties have been revisited in [21]. The original introduction of EDF distributions (2.2 **횯** ) is constructive from which it follows that the effective domain is a convex set and that the cumulant function _휅_ is a smooth and convex function on the interior of the effective domain **횯** _[̊]_ . Moreover, we get the following moments for _Y_ having EDF distribution (2.2) 

**==> picture [281 x 50] intentionally omitted <==**

1 3 

Ł. Delong et al. 

220 

for | _r_ | sufficiently small such that _𝜃_ + _r𝜙_ ∕ _w_ ∈ **횯** _[̊]_ for _𝜃_ ∈ **횯** _[̊]_ . Convexity of _휅_ implies existence of the canonical link providing canonical parameter and variance function, respectively, 

**==> picture [192 x 14] intentionally omitted <==**

> GLMs are based on a linear predictor _휂_ for modeling the mean parameter _휇_ = 피[ _Y_ ] . Assume we have ( _d_ + 1)-dimensional covariates _**x**_ ∈ X = {1} × ℝ _[d]_ . The linear pre- 

> dictor _휂_ = _휂_ ( _**x**_ ) is received by choosing a suitable link function _g_ (⋅) such that the following relationship holds 

**==> picture [74 x 10] intentionally omitted <==**

> for a given regression parameter _**휷**_ ∈ ℝ _[d]_[+][1] . We need to ensure to have a well-defined GLM by 

**==> picture [293 x 14] intentionally omitted <==**

> This might be a challenge for (one-sided) bounded effective domains **횯** and may 

> require a careful choice of the link function _g_ (⋅). 

Assume we have _n_ independent pairs of random variable and covariates ( _Yi_ , _**x** i_ ) following an EDF distribution (2.2) with the same cumulant function _휅_ ; we choose the same link function _g_ (⋅) to receive linear predictors _휂i_ = ⟨ _**휷**_ , _**x** i_ ⟩ . The log-likelihood function of this model is 

**==> picture [203 x 28] intentionally omitted <==**

> with canonical parameter _휃i_ = ( _휅_[�] )[−][1] ( _휇i_ ) =[(] ( _휅_[�] )[−][1] ◦ _g_[−][1][)] ( _휂i_ ) . The score w.r.t. _**휷**_ is obtained by the gradient 

**==> picture [207 x 154] intentionally omitted <==**

We define the diagonal working weight matrix _W_ and working residual vector _**R**_ by 

This allows us to write the score equation for finding the MLE of regression parameter _**휷**_ by 

1 3 

Making Tweedie’s compound Poisson model more accessible 

221 

**==> picture [227 x 13] intentionally omitted <==**

> with design matrix 픛 = ( _**x**_ 1, … , _**x** n_ )[�] ∈ ℝ _[n]_[×(] _[d]_[+][1][)] . MLE system (A.3) is solved either using Fisher’s scoring method or the iteratively re-weighted least squares (IRLS) algorithm, see [7, 9]. For Fisher’s scoring method we explore the scoring updates 

**==> picture [254 x 16] intentionally omitted <==**

where all terms on the right-hand side are evaluated for algorithmic time _t_ . It has been pointed out by an anonymous referee that the R command `glm()` does not directly calculate the inverse of the matrix 픛[′] _W_ 픛 in (A.4), but, instead, solves a linear system for _**휷** t_ +1 . The motivation for this approach is that in high-dimensional covariate spaces or in the situation of multiple categorical variables with many labels (implemented by dummy coding), the matrix 픛[′] _W_ 픛 may be close to singular and, henceforth, inversion of this matrix may lead to unstable results. 

Standard errors are obtained from the inverse of Fisher’s information matrix 

**==> picture [294 x 20] intentionally omitted <==**

> where ∇[2] _**휷**_[ denotes the Hessian w.r.t. ] _**[휷]**_[ . The IRLS algorithm replaces the inverse ] 

> Fisher’s information matrix I( _**휷**_ )[−][1] = (픛[�] _W_ 픛)[−][1] in the scoring updates by the inverse of the observed information matrix 

**==> picture [103 x 21] intentionally omitted <==**

## **B Motorcycle data example** 

We start with a descriptive and exploratory analysis of the Swedish motorcycle data of Listing 1. We have _n_ = 62[�] 036 insurance policies with positive exposures _wi >_ 0 The empirical claim frequency is _𝜆[̄]_ =[∑] _[n] i_ =1 _[N][i]_[∕][∑] _[n] i_ =1 _[w][i]_[=][ 1.05][%][ , and the average ] claim size is _𝜁[̄]_ =[∑] _[n] i_ =1 ∑ _Nj_ = _i_ 1 _[Z][i]_[,] _[j]_[∕][∑] _i[n]_ =1 _[N][i]_[=][ 24][�][641][ Swedish crowns SEK.] Figure 7 shows a boxplot over all exposures _wi_ and the claim counts _Ni_ on all insurance policies. We note that insurance claims are rare events for this product, because the claim frequency is only _𝜆[̄]_ = 1.05%. 

Figures 8 and 9 give the marginal total exposures (split by gender), the marginal claim frequencies and the marginal average claim amounts for the covariate components `Age` , `Zone` , `McClass` , `McAge` and `Bonus` . The first observation is that we have a very imbalanced portfolio between genders, only 11% of the total exposure is coming from females. The empirical claim frequency of females is 0.86% and the one of males is 1.08%. We note that the female claim frequency comes from (only) 61 claims (based on an exposure of female of 7’094 accounting years, versus 57’679 for male). Therefore, it is difficult to analyze females separately, and all marginal claim frequencies and claim sizes in Figs. 8 and 9 (middle and rhs) are analyzed 

1 3 

Ł. Delong et al. 

222 

**==> picture [316 x 183] intentionally omitted <==**

**----- Start of picture text -----**<br>
boxplot of exposures number of claims per policy<br>G G GG G GGGGGG G GG [G] GGGGGGGGGGGGGG [G] GGG [G] GGGGGGGGGGGGGGGGGGGGGGGGGGGGG [G] GGG [G] GGGGGG<br>GGG [G] GGGGGGGGGG [G] GGGGGGGGGGGGGGGGGGG [G] GGGGGGGGGGGGGGGGG<br>G<br>G<br>G<br>0 1 2<br>number of claims per policy<br>Fig. 7   (lhs) Boxplot of exposures  wii  on the log scale (the orange line corresponds to 1 accounting year),<br>(rhs) histogram of the number of observed claims  Ni  per policy. [I]<br>60000<br>2<br>50000<br>0 40000<br>30000<br>−2 frequency<br>exposure on log scale 20000<br>−4<br>10000<br>−6 0<br>**----- End of picture text -----**<br>


**Fig. 7** (lhs) Boxplot of exposures _wii_ on the log scale (the orange line corresponds to 1 accounting year), 

jointly for both genders. Average claim sizes are 18’237 SEK and 25’270 SEK for female and male, respectively. 

The empirical marginal frequencies in Figs. 8 and 9 (middle) are complemented with confidence bounds of two standard deviations (blue dotted lines) and the empirical overall frequency _𝜆[̄]_ = 1.05% (orange color). From the plots we conclude that we should keep the explanatory variables `Age` , `Zone` , `McClass` and `McAge` , but the variable `Bonus` does not seem to have any predictive power. At the first sight, this seems surprising because the bonus-malus level encodes the past claims history. The reason that the bonus-malus level is not needed for our claims is that we consider comprehensive insurance for motorcycles covering loss or damage of motorcycles other than collision (for instance, caused by theft, fire or vandalism), and the bonusmalus level encodes collision claims. The situation for average claim amounts is a bit more difficult to understand, but we make a similar conclusion, namely, that we can drop the covariate `Bonus` . Moreover, we merge Zones 5–7 because of small exposures and similar behavior. 

Figure 10 shows the correlations between the covariates: (lhs) correlations between continuous covariates, (plots rhs), dependence between continuous covariates and the categorical `Zone` covariate. We have some dependence, for instance, in `Zone 1` (three largest Swedish cities) motorcycles are more light ( `McClass` ) and less old. Older people drive less heavy motorcycles that are more old, and older motorcycles are less heavy. 

Figure 11 gives the empirical density, empirical distribution and log-log plot of average claim amounts _Z[̄] i_ . From the log-log plot we conclude that the average claim amounts are not heavy tailed, which does not reject the use of gamma claim size distributions at that stage. 

1 3 

Making Tweedie’s compound Poisson model more accessible 

223 

**==> picture [326 x 301] intentionally omitted <==**

**----- Start of picture text -----**<br>
total exposures per age frequency per age average claim amounts per age<br>femalemale GG<br>GG<br>GG<br>GG GG<br>GG G GG G<br>GG G<br>GG [G] G [G] G GG [G] G GG GG [G] G [G] G [G] G [G] G G<br>u ll , GGG<br>18 24 30 36 42age 48 54 60 66 20 30 G G G 40 [G] age [G] [G] 50 G G G 60 G G G 70 18 24 30 36 age42 48 54 60 66<br>total exposures per geographical zone frequency per geographical zone average claim amounts per geographical zone<br>femalemale<br>G<br>GG<br>GG<br>GG GG GG GG GG GG GG<br>ul. G<br>Zone 1 Zone 2 Zone 3 Zone 4 Zone 5 Zone 6 Zone 7 Zone 1 Zone 2 Zone 3 Zone 4 Zone 5 Zone 6 Zone 7 Zone 1 Zone 2 Zone 3 Zone 4 Zone 5 Zone 6 Zone 7<br>geographical zone geographical zone geographical zone<br>total exposures per motorcycle class frequency per motorcycle class average claim amounts per motorcycle class<br>femalemale<br>GG GG<br>GG GG GG GG GG G G<br>G<br>1 2 3 4 5 6 7 1 2 3 4 5 6 7 1 2 3 4 5 6 7<br>motorcycle class G G motorcycle class G motorcycle class<br>7000 0.05 12<br>6000 0.04 10<br>5000<br>exposure 40003000 0.030.02 86<br>observed frequency logged average claim amounts<br>2000<br>0.01<br>1000 4<br>0 0.00<br>0.05 12<br>25000<br>20000 0.04 10<br>exposure 1500010000 observed frequency 0.030.02 logged average claim amounts 86<br>0.01<br>5000 4<br>0 0.00<br>0.05 12<br>15000 0.04 10<br>exposure 10000 0.030.02 86<br>observed frequency logged average claim amounts<br>5000<br>0.01<br>4<br>0 0.00<br>**----- End of picture text -----**<br>


**Fig. 8** (top, middle and bottom rows) `Age` , `Zone` , `McClass` : (lhs) histogram of exposures (split by gender), (middle) observed claim frequency, (rhs) boxplot of observed average claim amounts _Z[̄] i_ of policies with _Ni >_ 0 (on log-scale) 

1 3 

Ł. Delong et al. 

224 

**==> picture [331 x 471] intentionally omitted <==**

**----- Start of picture text -----**<br>
total exposures per motorcycle age frequency per motorcycle age average claim amounts per motorcycle age<br>femalemale<br>GG<br>GG GG GG G G<br>l 0 3 6 l 9 12 15 18 . 21 24 27 30 0 5 10 GG G 15 GG GGG 20 GGG GGG 25 GGG G 30 GG 0 3 6 9 12 GG 15 18 21 24 27 30<br>motorcycle age motorcycle age G motorcycle age<br>total exposures per bonus−malus class frequency per bonus−malus class average claim amounts per bonus−malus class<br>femalemale<br>G<br>GG G G GG GG GG GG GG GGG<br>G G<br>G<br>1 2 3 4 5 6 7 1 2 3 4 5 6 7 1 2 3 4 5 6 7<br>bonus−malus class G G bonus−malus class G G G G bonus−malus class<br>Fig. 9   (top and bottom rows)  McAge ,  Bonus : (lhs) histogram of exposures (split by gender), (middle)<br>observed claim frequency, (rhs) boxplot of observed average claim amounts  Z [[̄]] i  of policies with  Nii ><br>(on log-scale)<br>age in each Swedish zone motorcycle class in each Swedish zone motorcycle age in each Swedish zone<br>Age McClass McAge<br>Age -11% 7%<br>McClass -10% -19%<br>PT McAge 6% -12%<br>Zone 1 Zone 2 Zone 3 Zone 4 Zone 5 Zone 1 Zone 2 Zone 3 Zone 4 Zone 5 Zone 1 Zone 2 Zone 3 Zone 4 Zone 5<br>Swedish zones (Zones 5−7 merged) Swedish zones (Zones 5−7 merged) Swedish zones (Zones 5−7 merged)<br>Fig. 10   (lhs) correlations: top-right shows Pearson’s correlation; bottom-left shows Spearman’s rho; (rhs)<br>boxplots of  Age ,  McClass ,  McAge  versus  Zone<br>empirical density of average claim amounts empirical distribution of average claim amounts log−log plot of average claim amounts<br>G [GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG] [GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG] G [GGGGG] [GGGGGGGGGGGGGG] [GGGGGGGGGGGGGGG] G [G] G [GG] [GGGGG] G [G] G G [G] [G] G [G] G [GGG] G G [GG] [G] G G G G G G G GGG GG G G GGGGGGGG GG GGGGGG GG GG G GG G G GG GG GGGGG G G GGG G GGG G G GG G G GGG G G GGG GGG G GGG G G GG G G G GGGGG GG GG GG GGGG G G G GGGGG G GGG G G GG GGG G GGG G G G G G GGGGGG G GG G GGGG G GGG G G G GGGGG G G G G G GG G GGGGGGG G GGGGGGGGG G GGG GG GGGGGGGGG G G G G GG GG G G G GG G G G GGGGGGGGGG G GG G GG GGGG GGGGG G G G G G G G G G G G G GG G G G G G GGGG G GGGGGGGGGGGGGGGG G GGGGG G GGGGGGGGGGGGGGGGGGGGGGGGGGGG G GG G GG G GGGGG G GGGGGGGGGGGGGGGGGGG G GGGGGGGGGGGGGG GGGGGGGGGGGGG<br>G<br>G<br>G [GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG] G<br>e a<br>0 50 100 150 200 0 50 100 150 200 −4 −2 0 2 4<br>average claim amounts in SEK 1'000 average claim amounts in SEK 1'000 logged average claim amounts in SEK 1'000<br>12000 0.05 12<br>10000 0.04 10<br>8000 0.03 8<br>exposure 6000 0.02 6<br>4000 observed frequency logged average claim amounts<br>0.01<br>2000 4<br>0 0.00<br>25000 0.05 12<br>20000 0.04 10<br>15000 0.03 8<br>exposure 10000 0.02 6<br>observed frequency logged average claim amounts<br>5000 0.01 4<br>0 0.00<br>70 7 30<br>60 6 25<br>50 5 20<br>age 40 motorcycle class 34 motorcycle age 1510<br>30 2 5<br>20 1 0<br>0.04 1.0 0<br>0.8 −1<br>0.03 −2<br>0.6<br>0.02 −3<br>0.4 −4<br>empirical density<br>empirical distribution<br>0.01 0.2 logged survival probability −5<br>−6<br>0.00 0.0<br>**----- End of picture text -----**<br>


**Fig. 9** (top and bottom rows) `McAge` , `Bonus` : (lhs) histogram of exposures (split by gender), (middle) observed claim frequency, (rhs) boxplot of observed average claim amounts _Z[[̄]] i_ of policies with _Nii >_ 0 (on log-scale) 

**Fig. 10** (lhs) correlations: top-right shows Pearson’s correlation; bottom-left shows Spearman’s rho; (rhs) boxplots of `Age` , `McClass` , `McAge` versus `Zone` 

**Fig. 11** (lhs) Empirical density (middle) empirical distribution and (rhs) log-log plot of average claim amounts _Z[̄] i_ of policies with _Ni >_ 0 

1 3 

Making Tweedie’s compound Poisson model more accessible 

225 

## **C** R **code** 

Listing 2: R code for Tweedie’s CP neural network model. 

1 library(keras) 2 # 3 network.Tweedie <- function (seed ){ 4 set.seed(seed) 5 use_session_with_seed (seed) 6 design <- layer_input (shape=c(8), dtype=’float32 ’, name=’design ’) 7 # 8 output = design %>% 9 layer_dense (units =20, activation =’tanh ’, name=’hidden1 ’) %>% 10 layer_dense (units =15, activation =’tanh ’, name=’hidden2 ’) %>% 11 layer_dense (units =10, activation =’tanh ’, name=’hidden3 ’) %>% 12 layer_dense (units =2, activation =’exponential ’, name=’output ’) 13 # 14 model <- keras_model (inputs=list(design), outputs=c(output )) 15 model 16 } 17 # 18 p <- 1.4 19 Tweedie_loss <- function (y_true , y_pred) 20 - k_mean( y_true [ ,3]*(( y_true [ ,1]* y_pred [ ,1]^(1 -p)/(1 -p)21 y_pred [ ,1]^(2 -p)/(2 -p))/ y_pred [,2]- y_true [ ,2]* log(y_pred [ ,2])/(p -1)) )} 22 # 23 model <- network.Tweedie(seed =200) 24 model %>% compile(loss = Tweedie_loss , optimizer = ’nadam ’) 25 # 26 XX <- as.matrix(dat[,c(" Age"," Gender "," Zone2 "," Zone3 "," Zone4 "," Zone5 "," McClass "," McAge ")]) 27 YY <- as.matrix(cbind( dat$ClaimCosts /dat$Exposure , dat$ClaimNb /dat$Exposure , dat$Exposure )) 28 # 29 fit <- model %>% fit(list(XX), YY , validation_split =0.2 , batch_size =5000 , epochs =200) 30 dat$predict <- model %>% predict(list(XX)) 

**Funding** Open Access funding provided by ETH Zurich. 

**Open Access** This article is licensed under a Creative Commons Attribution 4.0 International License, which permits use, sharing, adaptation, distribution and reproduction in any medium or format, as long as you give appropriate credit to the original author(s) and the source, provide a link to the Creative Commons licence, and indicate if changes were made. The images or other third party material in this article are included in the article’s Creative Commons licence, unless indicated otherwise in a credit line to the material. If material is not included in the article’s Creative Commons licence and your intended use is not permitted by statutory regulation or exceeds the permitted use, you will need to obtain permission directly from the copyright holder. To view a copy of this licence, visit http://creat iveco mmons .org/licen ses/by/4.0/. 

## **References** 

1. Akaike H (1974) A new look at the statistical model identification. IEEE Trans Autom Control 19(6):716–723 

2. Barndorff-Nielsen O (2014) Information and exponential families. In: Statistical theory. John Wiley & Sons, Chichester, UK 

3. Dutang C, Charpentier A (2019) CASdatasets 횁 package vignette. Reference manual, November 13, 2019. Version 1.0-10 

4. Jørgensen B (1986) Some properties of exponential dispersion models. Scand J Stat 13(3):187–197 

5. Jørgensen B (1987) Exponential dispersion models. J R Stat Soc Ser B (Methodol) 49/2:127–145 

1 3 

Ł. Delong et al. 

226 

6. Jørgensen B, de Souza MCP (1994) Fitting Tweedie’s compound Poisson model to insurance claims data. Scand Actuar J 1994(1):69–93 

7. McCullagh P, Nelder JA (1983) Generalized linear models. Chapman & Hall, London 

8. Nelder JA, Pregibon D (1987) An extended quasi-likelihood function. Biometrik 74:221–231 

9. Nelder JA, Wedderburn RWM (1972) Generalized linear models. J R Stat Soc Ser A (Gen) 135/3:370–384 

10. NIST Digital Library of Mathematical Functions. http://dlmf.nist.gov/ Release 1.0.28 of 2020-0915. In: Olver FWJ, Olde Daalhuis AB, Lozier DW, Schneider BI, Boisvert RF, Clark CW, Miller BR, Saunders BV, Cohl HS, McClain MA (eds) 

11. Ohlsson E, Johansson B (2010) Non-life insurance pricing with generalized linear models. Springer, Berlin 

12. Quijano Xacur OA, Garrido J (2015) Generalised linear models for aggregate claims: to Tweedie or not? Eur Actuar J 5(1):181–202 

13. R Core Team (2018) R: a language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria. https ://www.R-proje ct.org/ 

14. Schelldorfer J, Wüthrich MV (2019) Nesting classical actuarial models into neural networks. SSRN Manuscript ID 3320525. Version of January 22, 2019 

15. Smyth GK (1989) Generalized linear models with varying dispersion. J R Stat Soc Ser B (Methodol) 51:47–60 

16. Smyth GK (1996) Partitioned algorithms for maximum likelihood and other nonlinear estimation. Stat Comput 6:201–216 

17. Smyth GK, Jørgensen B (2002) Fitting Tweedie’s compound Poisson model to insurance claims data: dispersion modeling. ASTIN Bull 32(1):143–157 

18. Smyth GK, Verbyla AP (1999) Adjusted likelihood methods for modelling dispersion in generalized linear models. Environments 10:696–709 

19. Tweedie MCK (1984) An index which distinguishes between some important exponential families. In: Ghosh JK, Roy J (eds) Statistics: applications and new directions. Proceeding of the Indian statistical golden jubilee international conference. Indian Statistical Institute, Calcutta, pp 579–604 

20. Wüthrich MV (2013) Non-life insurance: mathematics & statistics. SSRN Manuscript ID 2319328. Version of January 7, 2020 

21. Wüthrich MV (2019) From generalized linear models to neural networks, and back. SSRN Manuscript ID 3491790. Version of April 3, 2020 

22. Wüthrich MV (2020) Bias regularization in neural network models for general insurance pricing. Eur Actuar J 10(1):179–202 

**Publisher’s Note** Springer Nature remains neutral with regard to jurisdictional claims in published maps and institutional affiliations. 

1 3 

