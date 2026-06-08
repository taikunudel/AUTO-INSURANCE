## Risk Based Scores and the Gini Index 

Edward W. (Jed) Frees _[∗]_ Glenn Meyers _[†]_ A. David Cummings _[‡§]_ 

April 27, 2011 

_Abstract._ In 1905, Max Otto Lorenz displayed skewed income distributions using a graph now known as the Lorenz curve. In 1912, Corrado Gini summarized this curve with a statistic now known as the Gini index. Both devices are widely used in welfare economics, among other fields. In this paper, we extend these concepts to a financial context by ordering risks using relativities which are risk based scores relative to prices. 

Using the relativity ordering, we develop a Lorenz curve and the corresponding Gini index that can cope with adverse selection and measure potential profit. We provide a detailed example using personal lines homeowners insurance. Further, we show that the Gini index can be written in terms of covariance operators, thus expanding the scope of interpretations. We implement theory developed in a companion paper to calibrate sample sizes, establishing that the number of observations typically encountered in insurance practice are sufficient for reliable estimation of our new Gini index. 

> _∗_ University of Wisconsin and ISO Innovative Analytics 

> _†_ ISO Innovative Analytics 

> _‡_ ISO Innovative Analytics 

> _§_ Keywords: Insurance pricing, association measures, adverse selection, Lorenz curve 

1 

## **1 Introduction** 

We wish to compare the distribution of a financial risk _y_ to a price _P_ . We assume that the analyst has available a set of known exogenous risk characteristics **x** upon which both the risk and price distributions depend. Our goal is to develop a measure that quantifies the extent to which _P_ can be used to assess the distribution of _y_ . With such a measure, we could compare alternative pricing structures. Although this modeling framework is applicable broadly, for concreteness we focus on an insurance loss as the financial risk and the price is a premium that a policyholder would pay for an insurer to cover the risk. In this special case, characteristics **x** typically influence both distributions. Insurance scores, used for setting premiums, that are based on knowledge of **x** are known as “risk based scores.” 

**Measures of Association.** Classic statistics offers analysts many measures that quantify the association between _y_ and _P_ . For example, it is common to use a Pearson (the usual, or productmoment) correlation or a Spearman correlation (that quantifies correlations between ranks of variables) to assess association. Some alternative measures of association are based on quantifying the distribution of the difference between losses and premiums. For example, if one were interested in the bias of a premium, one could look to the mean absolute error statistic given as _MAE_ = _n[−]_[1][ ∑] _[n]_[An][alternative][is][to][look][through][mean][square][errors,][such][as][through] _i_ =1 _[|][y][i][ −][P][i][|]_[.] the root mean square error statistic _RMSE_ = √ _n[−]_[1] ~~[ ∑]~~ ~~_[n]_~~ _i_ =1[(] _[y][i][ −][P][i]_[)][2][.][Of course, many variations of] these basic statistics are available; for example, it is common to examine ratios in lieu of differences. 

Although useful, these classic statistics are limited in our financial context for at least three reasons. First, their optimality properties are motivated by theory based on symmetric distributions (such as the normal and LaPlace distributions) and do not account for the complexity of risk distributions. To illustrate this complexity, in typical homeowners insurance data described in Section 3, 94% of the losses are zeros (corresponding to no claims) and when losses are positive, the distribution tends to be right-skewed and thick-tailed. Second, they do not explicitly allow for the asymmetric nature of decisions faced by analysts. For example, one would only introduce a new premium methodology into an existing rating structure if the new methodology were dramatically better than an existing alternative. Third, these classic statistics lack economic interpretation. 

In this paper, we develop summary measures that can address these limitations. These measures are natural extensions of the classic Lorenz curve and associated Gini index, given as follows. 

2 

## **1.1 The Lorenz Curve and Gini Index** 

In welfare economics, it is common to compare distributions via the _Lorenz curve,_ developed by Max Otto Lorenz (1905). A Lorenz curve is a graph of the proportion of a population on the horizontal axis and a distribution function of interest on the vertical axis. It is typically used to represent income distributions. When the income distribution is perfectly aligned with the population distribution, the Lorenz curve results in a 45 degree line that is known as the “line of equality.” The area between the Lorenz curve and the line of equality is a measure of the discrepancy between the income and population distributions. Two times this area is known as the _Gini index_ , introduced by Corrado Gini in 1912. See, for example, Sen and Foster (1998), for additional background on income equality. For readers interested in examining current international inequality measures, see the online resource UNU-Wider World Income Inequality Database (2008). 

The contributions of Joseph Gastwirth in the 1970’s (e.g., Gastwirth, 1971, 1972) helped to emphasize the importance of the Lorenz curve and the Gini index as tools for comparing distributions, particularly in economic applications. The subsequent literature is extensive. In one strand of the literature, researchers have sought to understand differences in economic equality among population subgroups (e.g., Lambert and Decoster, 2005, Gastwirth, 1975). In another strand, analysts have introduced weight functions into the Lorenz curve (e.g., to account for the number of publications when studying impact factors, Egghe, 2005). Yitzhaki (1996) describes how weighted regression sampling estimators can be of interest in welfare economic applications. Here, the idea is to adjust regression weights for social attitudes toward inequality. In another stream of research, analysts have used the Gini index for model selection in genomics (Nicodemus and Malley, 2009) and in classification trees (Sandri and Zuccolotoo, 2008). 

**Example: Distribution of Homeowners Premiums.** For an insurance example, Figure 1 shows a distribution of premiums. This figure is based on a sample of 359,454 policyholders with premiums that will be described in Section 3. The left-hand panel shows a right-skewed histogram of premiums. When plotting this figure, premiums that exceeded 1,200 were ignored. The righthand panel provides the corresponding Lorenz curve, showing again a skewed distribution. For example, the arrow marks the point where 60% of the policyholders pay 40% of premiums. The 45 degree line is the “line of equality;” if each policyholder paid the same premium, then the premium distribution would be at this line. The Gini index, twice the area between the Lorenz curve and the 45 degree line, is 29.5% for this data set. 

3 

**==> picture [443 x 234] intentionally omitted <==**

**----- Start of picture text -----**<br>
(0.60, 0.40)<br>0 200 400 600 800 1200 0.0 0.2 0.4 0.6 0.8 1.0<br>Premiums Proportion of Policies<br>1.0<br>0.8<br>100000<br>0.6<br>60000<br>Frequency 0.4<br>Prem Distribution<br>20000 0.2<br>0<br>0.0<br>**----- End of picture text -----**<br>


Figure 1: Distribution of Premiums. The left-hand panel is a histogram of premiums from a group of 359,454 policyholders, showing a distribution that is right-skewed. The right-hand panel provides the corresponding Lorenz curve. The arrow marks the point where 60% of the policyholders pay 40% of premiums. 

## **1.2 Relating Premium to Loss Distributions** 

From Section 1.1, the Lorenz curve is a device that is well-known in welfare economics for displaying distributions. It is particularly useful for interpreting skewed distributions, a shape that insurance analysts are well acquainted with. 

One could use classic Lorenz curves to compare a premium to a loss distribution. For example, it would be straightforward to compute Lorenz curves for premiums and for losses, and then superimpose the two curves on the same figure. However, the population distribution for each curve would be based on different sort orders (by premiums and losses, respectively), so that it would not be meaningful to compare premiums to losses for any policyholder group. 

**The Role of Relativities.** As an alternative, in the following section we extend the Lorenz curve through the introduction of a third variable called a _relativity_ . The relativity connects the losses 

4 

to the premiums and is the variable that we will sort on, thus maintaining consistency between policyholder groups. In this way, we can track differences between losses and premiums and, through different sort orders, emphasize the differences between these two distributions. Because premiums (but not losses) can be influenced by insurance analysts, we will argue that this comparison provides a way to judge whether a given premium _P_ is somehow “better” than an alternative. 

The plan for the paper follows. In Section 2 we develop this extension of the Lorenz curve and Gini index, providing definitions, giving an example and focusing on a special case of interest. We developed theoretical properties of this Gini index elsewhere (Frees, Meyers and Cummings, 2011a); to keep this paper self-contained, these properties are summarized in Appendix Section 8. Section 3 provides a detailed example using a sample of policies from homeowners insurance that shows how one can use the new Gini index. Section 4 provides additional interpretations of the Gini index, showing how it can be expressed in terms of covariance functions. Details of the covariance calculations are in Appendix Section 9. Section 5 summarizes a small simulation study that shows how to use the Gini statistic as a tool for model selection. Section 6 then describes how one can use the Gini index to suggest an appropriate sample size for pilot testing, with supporting calculations in Appendix Section 10. Section 7 closes with a summary and some additional remarks. 

## **2 Ordered Lorenz Curve and the Gini Index** 

We now introduce an _ordered_ Lorenz curve which is a graph of the distribution of losses versus premiums, where both losses and premiums are ordered by relativities. Intuitively, the relativities point towards aspects of the comparison where there is a mismatch between losses and premiums. To make the ideas concrete, we first provide some notation. We will consider _i_ = 1 _, . . . , n_ policies. For the _i_ th policy, let 

- _yi_ denote the insurance loss, 

- **x** _i_ be the set of policyholder characteristics known to the analyst, 

- _Pi_ = _P_ ( **x** _i_ ) be the associated premium that is a function of **x** _i_ , 

- _Si_ = _S_ ( **x** _i_ ) be an insurance score under consideration for rate changes, and 

- _Ri_ = _R_ ( **x** _i_ ) = _S_ ( **x** _i_ ) _/P_ ( **x** _i_ ) is the “relativity,” or relative premium. 

5 

Thus, the set of information used to calculate the ordered Lorenz curve for the _i_ th policy is ( _yi, Pi, Si, Ri_ ). 

**Ordered Lorenz Curve.** We now sort the set of policies based on relativities (from smallest to largest) and compute the premium and loss distributions. Using notation, the premium distribution is 

**==> picture [308 x 28] intentionally omitted <==**

and the loss distribution is 

**==> picture [299 x 28] intentionally omitted <==**

where _I_ ( _·_ ) is the indicator function, returning a 1 if the event is true and zero otherwise. The graph _F_ ˆ _P_ ( _s_ ) _, F_ ˆ _L_ ( _s_ ) is an _ordered Lorenz curve_ . ( ) 

**Example: Homeowners Loss and Premium Distributions.** As an example of an ordered Lorenz curve, Figure 2 shows a curve using our homeowners data. For this curve, the score “SP ~~F~~ reqSev ~~B~~ asic” was used as the base premium and the score “IND ~~F~~ reqSev” was used to compute the relativities. To help interpret the curve, an arrow marks a typical point, corresponding to 60% of premium and 53.8% of losses. That is, with knowledge of relativities, an insurer could identify a portfolio that enjoys 60% of premiums with only 53.8% of losses. This is a profitable portfolio, one well worth retaining. □ 

**The Role of Adverse Selection.** If an insurer does not adopt a refined rating plan but its competitors do, then the insurer could become victim of adverse selection. The insurer’s good risks will switch to the competitor, and the insurer’s remaining risks will have higher losses. The ordered Lorenz curve quantifies the extent of this potential adverse selection. Through ordering of the relativity, it summarizes the performance of portfolios that are profitable and hence subject to potential raiding by competitors. Conversely, it also summarizes the performance of poorly performing portfolios that an insurer may wish to examine for potential loss control activities, e.g., tighter underwriting restrictions. 

6 

**==> picture [213 x 198] intentionally omitted <==**

**----- Start of picture text -----**<br>
Loss Distn<br>Line of Equality<br>60% Prem, 53.8% Loss<br>Ordered Lorenz Curve<br>0.0 0.2 0.4 0.6 0.8 1.0<br>Premium Distn<br>1.0<br>0.8<br>0.6<br>0.4<br>0.2<br>0.0<br>**----- End of picture text -----**<br>


Figure 2: An Ordered Lorenz Curve. For this curve, the corresponding Gini index is 10.03% with a standard error of 1.45% . 

**The Gini Index.** Of course, the selection of the 60th premium percentile is arbitrary. Insurers will wish to consider the profitability of different size portfolios. Thus, we summarize the curve using the Gini index which is (twice) the area between the curve and the 45 degree line, known as “the line of equality.” The line of equality can be interpreted as a “break-even” case for the insurer, where the percentage of losses equals the percentage of premiums. Curves below the line of equality represent a profitable situation for the insurer. 

Specifically, the Gini index can be calculated as follows. Suppose that the empirical ordered Lorenz curve is given by _{_ ( _a_ 0 = 0 _, b_ 0 = 0) _,_ ( _a_ 1 _, b_ 1) _, . . . ,_ ( _an_ = 1 _, bn_ = 1) _}_ for a sample of _n_ observations. Here, we use _aj_ = _F_[ˆ] _P_ ( _Rj_ ) and _bj_ = _F_[ˆ] _L_ ( _Rj_ ). Then, the empirical Gini index is 

**==> picture [362 x 74] intentionally omitted <==**

As described in Section 1.1, the classic Lorenz curve shows the proportion of policyholders on the horizontal axis and the loss distribution function on the vertical axis. The “ordered” Lorenz curve extends the classical Lorenz curve in two ways, (1) through the ordering of risks and prices by relativities and (2) by allowing prices to vary by observation. We summarize the ordered Lorenz 

7 

curve in the same way as the classic Lorenz curve using a Gini index, defined as twice the area between the curve and a 45 degree line. The analyst seeks ordered Lorenz curves that approach passing through the southeast corner (1,0); these have greater separation between the loss and premium distributions and therefore larger Gini indices. 

**Example.** Suppose we have only _n_ = 5 policyholders with experience as: 

|Variable<br>_i_|1<br>2<br>3<br>4<br>5|Sum|
|---|---|---|
|Loss<br>_yi_<br>Premium<br>_P_(**x**_i_)<br>Relativity<br>_R_(**x**_i_)|5<br>5<br>5<br>4<br>6<br>4<br>2<br>6<br>5<br>8<br>5<br>4<br>3<br>2<br>1|25<br>25|



Figure 3 compares the Lorenz curve to the ordered version based on this data. The left-hand panel shows the Lorenz curve. The horizontal axis is the cumulative proportion of policyholders (0, 0.2, 0.4, and so forth) and the vertical axis is the cumulative proportion of losses (0, 4/25, 9/25, and so forth). This figure shows little separation between the distributions of losses and policyholders. 

**==> picture [438 x 202] intentionally omitted <==**

**----- Start of picture text -----**<br>
Lorenz Ordered Lorenz<br>Loss Distn Loss Distn<br>0.0 0.2 0.4 0.6 0.8 1.0 0.0 0.2 0.4 0.6 0.8 1.0<br>People Distn Premium Distn<br>1.0 1.0<br>0.8 0.8<br>0.6 0.6<br>0.4 0.4<br>0.2 0.2<br>0.0 0.0<br>**----- End of picture text -----**<br>


Figure 3: Lorenz versus Ordered Lorenz Curve. The Gini index for the left-hand panel is 5.6%. The Gini index for the right-hand panel is 14.9%. 

8 

The right-hand panel shows the ordered Lorenz curve. Because observations are sorted by relativities, the first point after the origin (reading from left to right) is (8/25, 6/25). The second point is (13/25, 10/25), with the pattern continuing. For the ordered Lorenz curve, the horizontal axis uses premium weights, the vertical axis uses loss weights, and both axes are ordered by relativities. From the figure, we see that there is greater separation between losses and premiums when viewed through this relativity. □ 

**Rescaling of Premiums and Losses.** From equations (1) and (2), we see that we can arbitrarily rescale premiums and losses by any positive constant and the distribution functions remain unchanged. Thus, without loss of generality, we assume henceforth that the average loss _y_ ¯ and average premium _P_[¯] are both equal to 1. 

**Properties of the Gini Index.** Appendix Section 8 describes properties the Gini index, including its consistency and asymptotic normality, that were proved in a companion paper, Frees, Meyers and Cummings (2011a). We use this asymptotic normality extensively in this paper, it is the basis for assessing the statistical significance of the Gini index. 

Moreover, Frees, Meyers and Cummings (2011a) derived a result that shows that the Gini index becomes larger as one uses a “more refined” insurance score. Specifically, consider a rating plan with premiums _P_ and an insurance score _S_ that is determined by a regression function using a set of insured characteristics that produces a Gini index. Consider an alternative insurance score _SA_ that is determined by a regression function using the base set of insured characteristics plus additional information such as more precise geographic information or credit scores. Then, the Gini index produced using this refined set of information is at least as large as the Gini index using the base information. 

In this sense, the Gini index provides a summary statistic that indicates whether one insurance score is better than a competitor. The paper of Frees, Meyers and Cummings (2011a) also derived estimators to judge whether Gini indices produced by alternative scoring methods are statistically from one another. 

**The Gini Index as a Measure of Profit.** One reason that the Gini index is important is because it has a direct economic interpretation. Specifically, consider an average profit, 

**==> picture [317 x 33] intentionally omitted <==**

9 

that can be shown to be approximately equal to the Gini index divided by two. It is an “average” in the sense that we are taking a mean over all decision-making strategies, that is, each strategy retaining the policies with relativities less than or equal to _Ri_ . In this sense, insurers that adopt a rating structure with a large Gini index are more likely to enjoy a profitable portfolio. 

Thus, we can think about the Gini index as the average expected profit to be gained by using relativities (to form portfolios). That is, the Gini index calibrates potential mismatches between losses and premiums. We change the Gini index by using different relativities; the relativities gives an idea as to where potential mismatches occur. In particular, a low relativity means that a policy is highly profitable and a good candidate to retain. 

## **3 Homeowners Example** 

For the “gold standard” of model validation in predictive modeling, one examines the performance of a model on an independent held-out sample (e.g., Hastie, Tibshirani and Friedman, 2001). For this example, we used an in-sample dataset of 404,664 records to compute parameter estimates. We then use the estimated parameters from the in-sample model fit as well as predictor variables from a held-out, or validation, subsample of 359,454 records, whose losses we wish to predict. 

## **3.1 Comparison of Scores** 

More details on this database and scoring methods are available in two companion papers, Frees, Meyers and Cummings (2010, 2011b). Based on the theory developed in these two papers, we have under consideration fourteen scores that are listed in the legend of Table 2. This table summarizes the distribution of each score on the held-out data. Not surprisingly, each distribution is rightskewed. 

For example, Table 2 also shows that the single-peril frequency severity model using the extended set of variables (SP ~~F~~ reqSev) provides the lowest score, both for the mean and at each percentile (below the 75th percentile). Except for this, no model seems to give a score that is consistently high or low for all percentiles. All scores have a lower average than the average held-out actual losses (TotClaims). 

10 

## **3.2 Comparing Scoring Methods to a Selected Base Premium** 

To compare these scoring methods, we first assume that the insurer has adopted a base premium for rating purposes; to illustrate, we use the “SP ~~F~~ reqSev ~~B~~ asic” for this premium. This method uses only a basic set of rating variables to determine insurance scores from a single-peril, frequency and severity model. Assume that the insurer wishes to investigate alternative scoring methods to understand the potential vulnerabilities of this premium base; Table 3 summarizes several comparisons using the Gini index. This table includes the comparison with the alternative score IND ~~F~~ reqSev, shown in Figure 2, as well as twelve other scores. 

The standard errors are from Appendix Section 8 (derived in Frees et al., 2011a). Thus, to interpret Table 3, one may use the usual rules of thumb and reference to the standard normal distribution to assess statistical significance. For the three scores that use the basic set of variables, SP ~~P~~ urePrem ~~B~~ asic, IND ~~P~~ urePrem ~~B~~ asic, and IV ~~P~~ urePrem ~~B~~ asic, the Gini indices are between 2.5 and 4 standard errors above zero, indicating statistical significance. In contrast, the other Gini indices all are more than 7 standard errors above zero, indicating that the ordering used by each score helps detect important differences between losses and premiums. 

The paper of Frees, Meyers and Cummings (2011a) also derived distribution theory to assess statistical differences between Gini indices. Although we do not review that theory here, we did perform these calculations for our data. It turns out that there is no statistically significant differences among the ten Gini indices that are based on the extended set of explanatory variables. 

In summary, Table 3 suggests that there are important advantages to using extended sets of variables compared to the basic variables, regardless of the scoring techniques used. 

## **3.3 Comparison of Scores Using the Gini Index** 

As demonstrated in the preceding section, if a base premium is available, then the Gini index can be used to decide whether an alternative insurance score is useful for detecting differences between loss and premium distributions. In instances where no base premium is available, the Gini index is also useful although care is required when interpreting this measure. 

Table 4 summarizes the calculation of several Gini indices. Here, we allow the “base premium” _P_ ( _·_ ) to be each of the fourteen competing scores plus the benchmark “ConsPrem,” a premium that is constant over policyholders. For each base premium, Table 4 shows the Gini index for each of the thirteen competing scores. Standard errors are reported in Table 5. 

11 

From the first row of Table 4, we see that all of the Gini indices are large, indicating that any of the fourteen scores considered here provide useful separation between losses and a constant premium. The next block (of four rows) consists of scores that use the basic set of explanatory variables, including SP ~~F~~ reqSev ~~B~~ asic. These four scores seem to perform similarly. For example, when compared to one another, the Gini indices are in the single digits. When any of the four are adopted as the base premium, double digit Gini indices are possible using the extended set of explanatory variables. 

Using the Gini measure, the dependence ratio scores advanced by Frees, Meyers and Cummings (2010) seem to fare poorly. Almost every alternative score, except for the independence multi-peril frequency and severity models upon which they are based, allows for an ordering where there is a substantial separation between premium and loss distributions. 

One approach for selecting a score based on the Gini index is a “mini-max” strategy. That is, select the score that provides the smallest of the maximal Gini indices, taken over competing scores. The strategy is intuitively appealing. If one were to specify a base premium, then the maximum Gini index corresponds to the largest separation between the loss and premium distribution when considering different orderings. For example, when the base premium is SP ~~P~~ urePrem ~~B~~ asic, the maximum Gini index is 12.8 which is achieved when IV ~~F~~ reqSevC is used to compute relativities to order distributions. For this criterion, Table 4 shows that IV ~~F~~ reqSevA is the best score. It has the smallest maximum Gini index at 7.2. We interpret this to mean that this score is the least vulnerable to alternative scores. 

Table 5 shows that the standard errors of the Gini indices are relatively stable across different choices of scores and premiums. We will use this observation in Section 6 to propose some rules of thumb for sample size determination. 

## **4 Using Covariances to Express the Gini Index** 

Equation (3) defines our Gini index in terms of an area associated with the ordered Lorenz curve. For the classic Lorenz curve and associated Gini index, there are several alternative (equivalent) definitions, cf., Yitzhaki (1998). These different definitions encourage alternative interpretations of the Gini index, hence widening the scope of potential applications. As with the classic Gini, we can also provide an alternative expression for our Gini index using covariance operators. 

12 

## **4.1 The Gini Index in Terms of Covariances** 

We use the notation Cov([�] _y, P_ ) to denote the (empirical) covariance between losses _y_ and premiums _P_ . That is, define Cov([�] _y, P_ ) = _n[−]_[1][(∑] _[n] i_ =1 _[y][i][P][i][ −][n][y]_[¯][ ¯] _[P]_ ) (and recall that _y_ ¯ = _P_[¯] = 1). Then, after some pleasant algebra (see Appendix Section 9), we can express the Gini index as 

**==> picture [363 x 23] intentionally omitted <==**

where _F_[ˆ] _R_ = rank( _R_ ) _/n_ is the distribution function of the rank of relativities. For large sample sizes _n_ , the third term on the right-hand side of equation (5) is small and can be ignored. 

With equation (4), we interpret a low relativity means that a policy is highly profitable and a good candidate to retain. Additional insights arise from equation (5). Other things being equal: 

**1.** Under the relativity ordering, a large covariance between losses ( _y_ ) and the proportion of premiums retained ( _F_[ˆ] _P_ ( _R_ )) implies a high Gini index. 

**2.** A large negative covariance between premiums ( _P_ ) and relativities ( _F_[ˆ] _R_ ) implies a high Gini index. Stated differently, low relativities associated with high premiums implies a high Gini index. We retain policies with a low relativity. Other things being equal, it is more profitable to retain a policy with a high premium. 

For many datasets, we have found that, using equation (5), we can approximate the weighted premium distribution _F_[ˆ] _P_ ( _R_ ) with the unweighted distribution of relativities _F_[ˆ] _R_ . With this, we may define 

**==> picture [330 x 24] intentionally omitted <==**

Although this approximation to the Gini index provides little advantage computationally, it does give us another way to interpret the Gini index. We can think about _P −y_ as the “profit” associated with a policy. Then, we may interpret the Gini index to be proportional to the negative covariance between profits and the rank of relativities. That is, if policies with low profits are associated with high relativities and high profits are associated with low relativities, then we have a profitable situation meaning that the Gini index is positive and large. 

When “premiums” _P_ are interpreted as exposures, it is more helpful to think in terms of pure premiums. An alternative approximation is 

**==> picture [322 x 23] intentionally omitted <==**

13 

where the scaled pure premium _PP_ is loss per premium ( _y/P_ ) rescaled (divided) by its average. 

**Homeowners Example.** To understand the reliability of these approximations, we return to the homeowners example and show summaries in Table 6 and Figure 4. In Figure 4, we compare the two approximations to the Gini indices produced in Table 4. The left-hand panel shows that the approximation given in equation (6) to be very robust over a wide range of premiums and relativities. The right-hand panel shows that the approximation given in equation (7) to be less robust although still helpful for interpretation purposes. 

In Table 6, we show the Gini indices and approximations for only those using SP ~~F~~ reqSev ~~B~~ asic as a base premium. We also decompose the equation (6) approximation into “loss” and “premium” sources. Here, the loss source is given by 2Cov ([�] _y, rank_ ( _R_ )) _/n_ and similarly for premiums. These two sources can help interpret the magnitude of the Gini index. 

**==> picture [355 x 188] intentionally omitted <==**

**----- Start of picture text -----**<br>
0 5 10 15 20 25 30 0 5 10 15 20 25 30<br>GiniApprox GiniApprox2<br>30 30<br>25 25<br>20 20<br>15 15<br>GiniResults 10 GiniResults 10<br>5 5<br>0 0<br>**----- End of picture text -----**<br>


Figure 4: Gini Indices and Approximations. Observations in the upper-right hand corner correspond to using a constant premium as a base. 

## **4.2 Some Special Cases** 

## **4.2.1 Simple Gini Index** 

In some applications, one can use an exposure measure, such as car years, instead of a premium. In others, it is helpful to think about the premium and exposure as constant over policies. In this 

14 

case, the relativity _R_ ( **x** _i_ ) = _S_ ( **x** _i_ ) is simply an insurance score. The direct comparison of losses to scores results in what we call a “simple Gini.” 

When premiums are constant ( _Pi ≡_ 1), interpretations (and the algebra) are simpler. In this case,the relativity is the score ( _Ri_ = _Si_ in our notation). From equation (5), the Gini index reduces to 

**==> picture [300 x 24] intentionally omitted <==**

Equation (8) is an exact relationship, no approximations are involved. It states that the simple Gini index is proportional to the covariance between losses and the rank of scores. Note that it is not a Pearson correlation between losses and scores, nor is it a Spearman correlation (the correlation between ranks of losses and ranks of scores). As discussed in Frees et al. (2011a), this statistic seems to have been first proposed by Durbin (1954) who proposed it as an instrumental variable estimator in an errors-in-variables regression problem. Durbin argued that using the rank of an explanatory variable may be helpful in explaining the behavior of _y_ when values of the explanatory variable are mis-measured. 

## **4.2.2 Reverse Gini Index** 

We now reverse the roles of scores _S_ and premiums _P_ and call the resulting Gini index a “reverse Gini.” Returning to equation (6), an approximation for the reverse Gini is 

**==> picture [363 x 49] intentionally omitted <==**

Moreover, suppose that the score _S_ is an unbiased estimator of the loss in the sense that E( _y|_ **x** ) = _S_ . Then, 

**==> picture [420 x 58] intentionally omitted <==**

because E( _y|_ **x** ) = _S_ . This suggests that one can anticipate the reverse Gini, _GiniR_[�] _Approx_ , to be zero when the model is well-specified. We use the reverse Gini as another statistic to measure model 

15 

## **4.2.3 Gini Index for Scores** 

For another case, suppose that the score _S_ is a “more refined” version of a premium _P_ . For example, _S_ may reflect information in a new rating variable (such as a credit score) or more precise geographic information. Specifically, let _S_ = _P_ exp( **z** _[′]_ _**β**_ ), where **z** is a vector of new variables not contained in the premium base _P_ . It is helpful to think about some specific examples. 

**Continuous Variable.** Suppose that we consider on a single continuous variable (e.g., credit score). Then, the rank of the relative premium can be expressed as 

**==> picture [238 x 24] intentionally omitted <==**

assuming that _β_ is positive. Then, from equation (6), we may interpret the Gini index to be approximately 

**==> picture [188 x 23] intentionally omitted <==**

that is, the Gini is approximately the covariance between the policy “profit” _P − y_ and the rank of the new variable _z_ , rescaled by the constants. 

**Categorical Variable.** Suppose that we consider on a single discrete variable _z_ with three possible outcomes 1, 2, and 3 (e.g., urban, suburb and rural). Suppose we use **z** _[′]_ _**β**_ = _β_ 1I( _z_ = 1) + _β_ 2I( _z_ = 2) + _β_ 3I( _z_ = 3). Here, recall that I( _·_ ) is the indicator function. Without loss of generality, assume that _β_ 1 _< β_ 2 _< β_ 3 (otherwise, simply re-order _z_ ). Then, _rank_ ( _R_ ) = _rank_ (exp( _zβ_ )) = _rank_ ( _z_ ) = _z,_ and 

**==> picture [156 x 23] intentionally omitted <==**

Each level of _z_ represents a “segment” of the market that is implemented in the new score _S_ but not in the original premium base _P_ . The Gini index measures the relationship between the policy “profit” _P − y_ and the market segments in _z_ . 

For both examples, we can think about the Gini index as summarizing the linear relationship between policy profit _P − y_ and the rank of the refinement variable, _rank_ ( _z_ ). This suggests additional analyses, such as a plot of _P − y_ versus _rank_ ( _z_ ), in order to understand potential nonlinear relationships. 

## **5 Model Selection** 

In this section, we investigate the role of the Gini index as a statistic to aid in selecting a model through a simulation study. 

16 

## **5.1 Simulation Study Design** 

The study is designed to replicate many of the data features that we encountered when analyzing the homeowners data described in Section 3. 

For each scenario, we generated _n_ in-sample policyholder observations, estimated model parameters and then calculated scores for each of _n_ out-of-sample policyholders. In our simulation, we let _n_ equal 500,000. 

**Simulated Distributions.** For each policyholder, we assumed knowledge of two characteristics where each _xj_ was generated from a chi-square distribution with 20 degrees of freedom, rescaled to have a zero mean and variance 1/10. With these choices, the score distributions (score calculations are described below) exhibited a right-skewed distribution comparable to the premium distribution portrayed in Figure 1. The regression function was generated using a logarithmic link function, that is, m( **x** ) = exp ( _β_ 0 + _β_ 1 _x_ 1 + _β_ 2 _x_ 2). Using the regression function as the location parameter, we generated the loss _y_ using the Tweedie distribution. Here, parameters of the Tweedie distribution were set so that the simulated distribution was comparable to the distribution of our homeowners data in Section 3. We did this for _n_ in-sample and _n_ out-sample observations, respectively. **Score Calculation.** Using the in-sample data, we estimated parameters for each of eight scores: 

- S1( **x** ) = exp( _β_ 0 + _β_ 1 _x_ 1 + _β_ 2 _x_ 2), the true regression function 

- S2( **x** ) = exp( _β_ 0 + _β_ 1 _x_ 1), based on only _x_ 1 

- S3( **x** ) = exp( _β_ 0 + _β_ 2 _x_ 2), based on only _x_ 2 

- S4( **x** ) = exp( _β_ 0 + _β_ 1 _x_[1] 1[),][based][on][an][(incorrect)][reciprocal][transform][of] _[x]_[1] 

- S5( **x** ) = exp( _β_ 0 + _β_ 2 _x_[1] 2[),][based][on][an][(incorrect)][reciprocal][transform][of] _[x]_[2] 

- S6( **x** ) = exp( _β_ 0 + _β_ 1 _x_ 1 + _β_ 2 _x_[1] 2[),][based][on] _[x]_[1][and][an][(incorrect)][reciprocal][transform][of] _[x]_[2] 

- _•_ S7( **x** ) = exp( _β_ 0 + _β_ 1 _x_[1] 1[+] _[ β]_[2] _[x]_[2][),][based][on] _[x]_[2][and][an][(incorrect)][reciprocal][transform][of] _[x]_[1] _•_ S8( **x** ) = exp( _β_ 0 + _β_ 1 _x_[1] 1[+] _[ β]_[2] _x_[1] 2[),][based][on][(incorrect)][reciprocal][transforms][of] _[x]_[1][and] _[x]_[2] 

Then, with the parameter estimates of the score coefficients from the in-sample data, we used the out-of-sample characteristics to generate scores. We then compared scores to the actual out-ofsample losses. We report results based on 100 simulations. With these sample and simulation sizes, it turns out that the simulation standard errors for all Gini indices are less than 0.2%. 

17 

Using the regression function in score 1, we generated three scenarios by varying the regression coefficients. In the first scenario, we let _β_ 1 = _β_ 2 = 0 _._ 25 so that both explanatory variables contribute equally to the regression function. In the second, we let _β_ 1 = 0 _._ 25 and _β_ 2 = 0 _._ 05 so that the second explanatory variable contributes little to the regression function. In the third scenario, we let _β_ 1 = 0 _._ 05 and _β_ 2 = 0 _._ 25 so that the first explanatory variable contributes little to the regression function. 

For each scenario, we assume that the analyst is considering one of eight scores (with the first being the correct choice, unknown to the analyst). To measure the discrepancy between between the chosen score and the true regression function, we present the Spearman correlation that we label as the “True Correlation.” Note that even when the analyst chooses the correct score, the Spearman correlation is less than one due to the (in-sample) estimation error in the regression coefficients in the score. If the true correlation were available, then the analyst would simply choose the model with the largest true correlation. However, this is unavailable, and so the analyst must use available statistics, including the “Simple Gini” and the ratio Gini indices presented in Table 7. An analyst could select a model by searching for the largest simple Gini index. Alternatively, one could use a mini-max strategy discussed in Section 3.3. 

## **5.2 Simulation Study Results** 

Table 7 summarizes the results of the simulation study. Note that through our choice of scenarios we may observe outcomes over a broad range of models selected, ranging from a near perfect selection (where the correlation is 99.29%) to a very poor selection (where the correlation is only 5.35%). 

The simple Gini index seems to be a desirable proxy for the true correlation. Over different scenarios and different premiums, as the simple Gini index increases, so does the true correlation. This is intuitive plausible in that the simple Gini index may be interpreted as proportional to the covariance between the insurance loss and rank of the score and whereas the “true correlation” is the correlation between the rank of the regression function and the rank of scores (a Spearman correlation). If one converts the simple Gini to a correlation it turns out to be much smaller than the true correlation. This is simply because of the noise in the loss random variable as a estimate of its expectation, the regression function. 

Choosing the smallest of the maximum Gini ratios is also a viable model selection strategy. Table 7 shows a strong inverse relation between the “maximum” column and the true correlation column. 

18 

The simulation also allows us to document the “reverse Gini effect.” To see this, consider the first scenario and suppose that the analyst initially chooses Score 2 as the base premium. For Score 3 as an alternative, the resulting ratio Gini index is 4.97% suggesting that this score is preferred. However, if the analysts using Score 3 as the base and Score 2 as the alternative, then Table 7 shows that the resulting Gini index is 5.12, suggesting that Score 2 is preferred. This is the reverse Gini effect, where the Gini analysis provides seemingly contradictory advice. 

However, because we generated the scores and the model, we know that neither Score 2 nor Score 3 represents the true outcome. Thus, the decision-making process with Gini indices suffers from the same drawback as with statistical hypothesis testing. Model A can be rejected in favor of Model B and vice-versa if neither model is true. Table 7 shows that the reverse Gini effect is not present in the second and third scenarios when one variable dominates the other. 

## **6 Sample Size Determination** 

How large a sample size is required for a reliable _Gini_ statistic? In this section, we show how to use results from the theoretical properties, plus some basic knowledge of the loss distribution, to provide rules of thumb that can be used to select an appropriate sample size. This procedure could be used, for example, to determine the size of a block of business when examining alternative premium structures on a trial, or “pilot,” basis. 

In earlier work, we showed that the distribution of the _Gini_ statistic is approximately normal for large samples, see Theorem A2 of Appendix Section 8. The form of the large sample variance, Σ _Gini/n_ , given in Theorem A2, is complicated. However, Appendix Section 10 shows that using the assumption of independent relativities results in a much simpler expression, given as 

**==> picture [285 x 25] intentionally omitted <==**

This result is similar to one for the Pearson correlation, another measure of association, where the form of the variance simplifies under the independence assumption. 

To illustrate, for our sample described in Section 3, we have _n_ = 359 _,_ 454 observations. After rescaling so that premiums and losses are mean one, we have the standard deviation of losses and premiums are, respectively, _sy_ = 14 _._ 79591 and _sP_ = 0 _._ 70558. The covariance between losses and premium is _CovyP_ = 0 _._ 48538. From this and equation (10), an approximate standard error for the 

19 

Gini index is 

**==> picture [314 x 27] intentionally omitted <==**

This result is close to the standard errors presented in Table 5 (calculated using the complicated, yet more precise, expression for Σ _Gini_ given in Appendix Section 8). 

Because this approximation is valid over a range of relativities and premiums (with different dependency structures), we conclude that this approximation is helpful for determining the size of a sample to be collected for test studies. Figure 5 shows the effect of alternative sample sizes on the approximate Gini standard error for our homeowners data. 

**==> picture [266 x 115] intentionally omitted <==**

**----- Start of picture text -----**<br>
Gini Standard Error<br>5,000 10,000 50,000 100,000 500,000 1,000,000<br>Number of Risks<br>12<br>10<br>8<br>6<br>4<br>2<br>**----- End of picture text -----**<br>


Figure 5: Effect of Sample Size on Gini Approximate Standard Errors. 

## **7 Summary and Concluding Remarks** 

The Gini index is a measure of association between losses and premiums - one that has important economic content in insurance scoring applications. For a given ordering of risks, the Gini index summarizes the difference between the premium and loss distributions. An excess of premiums over losses can be interpreted to be an insurer’s profit. This observation leads an insurer to seek an ordering that produces to a large Gini index. Thus, the Gini index and associated ordered Lorenz curve are useful for identifying profitable blocks of insurance business. 

Unlike classical measures of association, the Gini index assumes that a premium base _P_ is currently in place and seeks to assess vulnerabilities of this structure. This approach is more akin to hypothesis testing (when compared to goodness of fit) where one identifies a “null hypothesis” as the current state of the world and uses decision-making criteria/statistics to compare this to an 

20 

“alternative hypothesis.” The purpose of this paper is not to say that either hypothesis testing or goodness of fit approaches are always good or bad; rather, both have their place in statistical inference. The purpose of the paper is provide another measure that can be used to augment the analyst’s toolkit; we argue that this new measure provides insights that are not available from classical measures of association. 

To summarize, we anticipate the Gini index being of use in at least the following three situations: 

**1.** A premium structure _P_ is in place and we wish to assess the usefulness of a generic alternative score _S_ . This is the basic scenario in which we introduced the ordered Lorenz curve and the Gini index to combat adverse selection. We also discussed the Gini index as a measure of profit in Section 2. To illustrate, we demonstrated its usefulness in the homeowners example in Section 3.2; analysts can supplement this analysis by looking to the reverse Gini as an additional measure of model 

**2.** A premium structure _P_ is in place and the alternative score is a refined version of the premium. Although this is the same as the basic scenario defined above, additional interpretations are available for the relativity that are potentially helpful in model diagnostics. 

**3.** No premium structure is in place - a number of alternative scoring methods are being considered. In this case, at least two strategies are available. One is to use the “minimax” strategy put forth in Section 3.3, where one chooses a score that is least vulnerable to competition from other scores. The other strategy is to use the “simple” Gini index that has no base premium as a reference. 

To assess the reliability of the Gini index, Section 6 describes principles for sample size determination. On the one hand, sample sizes required for reliable applications such as in personal lines homeowners insurance are quite large, in some cases ranging into the hundreds of thousands of observations. On the other hand, with large sample sizes available, we can enjoy reliable inferences for complex distributions that are mixtures of a large mass at zero and a right-skewed, thick-tailed positive distribution. Given the availability of large datasets in today’s world, we view these sample size requirements as feasible in some important areas of applications. 

As a concrete illustration, this paper has focussed on insurance as a financial risk. Further, Frees et al. (2011a) showed that traditional credit scoring arises as a special case of our formulation. Moreover, additional potential applications in credit scoring are easy to imagine. For example, one could let _y_ represent the _amount_ of credit default (not just the event) and allow the amount charged 

21 

for the loan to depend on an applicant’s creditworthiness. Results of this paper apply directly to this situation. 

## **References** 

Durbin, J. (1954). Errors in variables. _Review of International Statistical Institute_ 22, 23-32. Egghe, L. (2005). Continuous, weighted Lorenz theory and applications to the study of fractional relative impact factors. _Information Processing and Management_ 41, 1330-1359. 

Frees, Edward W., Glenn Meyers and A. David Cummings (2010). Dependent multi-peril ratemaking models. _Astin Bulletin_ 40(2), 699-726. 

Frees, Edward W., Glenn Meyers and A. David Cummings (2011a). Summarizing insurance scores using a Gini index. To appear, _Journal of the American Statistical Association_ . Available at http://research3.bus.wisc.edu/jfrees. 

Frees, Edward W., Glenn Meyers and A. David Cummings (2011b). Predictive modeling of multi-peril homeowners insurance. Working paper. Available at http://research3.bus.wisc.edu/jfrees. 

Gastwirth, Joseph L. (1971). A general definition of the Lorenz curve. _Econometrica_ 39 (6), 1037-1039. Gastwirth, Joseph L. (1972). The estimation of the Lorenz curve and the Gini index. _Review of Economics and Statistics_ 54 (3), 306-316. 

Gastwirth, Joseph L. (1975). Statistical measures of earnings differentials. _The American Statistician_ 29 (1), 32-35. 

Hastie, Trevor, Robert Tibshirani and Jerome Friedman (2001). _The Elements of Statistical Learning: Data Mining, Inference and Prediction._ Springer, New York. 

Lambert, Peter J. and Andr´e Decoster (2005). The Gini coefficient reveals more. _Metron_ 63 (3), 373-400. 

Lorenz, Max O. (1905). Methods of measuring the concentration of wealth. _Publications of the American Statistical Association_ 9 (70), 209-219. 

Meyers, Glenn and A. David Cummings (2009). “Goodness of Fit” vs. “Goodness of Lift”. _The Actuarial Review: Newsletter of the Casualty Actuarial Society_ , August, p. 16. 

Available at http://www.casact.org/newsletter/pdfUpload/ar/AR_Aug2009_1.pdf. 

Nicodemus, Kristin K. and James D. Malley (2009). Predictor correlation impacts machine learning algorithms: implications for genomic studies. _Bioinformatics_ 25 (15), 1884-1890. 

Sandri, Marco and Paola and Zuccolotto (2008). A bias correction algorithm for the Gini variable importance measure in classification trees. _Journal of Computational and Graphical Statistics_ 17 (3), 611628. 

Sen, Amartya and James E. Foster (1998). _On Economic Inequality_ . Oxford University Press, Delhi. 

UNU-WIDER World Income Inequality Database (2008). Version 2.0c, May 2008. Sponsored by the World Institute for Development Economics Research of the United Nations University, Helsinki, Finland. Available at: http://www.wider.unu.edu/research/Database/en_GB/database/. 

Yitzhaki, Shlomo (1996). On using linear regressions in welfare economics. _Journal of Business and Economic Statistics_ 14 (4), 478-486. 

Yitzhaki, Shlomo (1998). More than a dozen ways of spelling Gini. _Research on Economic Inequality_ 8, 13-30. 

## **8 Appendix A - Properties of the Gini Index** 

The (population) _Gini_ index is 

**==> picture [327 x 27] intentionally omitted <==**

22 

Here, _FP_ and _FL_ are weighted distributions functions which are the population versions of the empirical distributions given in equations (1) and (2), respectively. 

We summarize the consistency and asymptotic normality of the empirical Gini index _Gini_[�] in the following two results. 

**Theorem A1.** Under mild regularity conditions, the Gini statistic _Gini_[�] is a consistent estimator of of the Gini index. That is, _Gini_[�] _→ Gini,_ as _n →∞,_ with probability one. 

For asymptotic normality, we use the projection 

**==> picture [349 x 23] intentionally omitted <==**

Further, use the notation Σ _h_ = Var _h_ 1( **x** _, y_ ), Σ _y_ = Var _y_ , Σ _P_ = Var _P_ ( **x** ), Σ _hy_ = Cov( _h_ 1( **x** _, y_ ) _, y_ ), Σ _yP_ = Cov( _y, P_ ( **x** )), and Σ _hP_ = Cov( _h_ 1( **x** _, y_ ) _, P_ ( **x** )). With these terms, we can establish: 

**Theorem A2.** Under mild regularity conditions, the Gini statistic _Gini_[�] has an asymptotic � normal distribution. Specifically, _[√] n Gini − Gini →D N_ (0 _,_ Σ _Gini_ ) _,_ where ( ) 

**==> picture [415 x 30] intentionally omitted <==**

with _µh_ = _µyµP_ (1 _− Gini_ ) _/_ 2. 

To estimate the asymptotic variance, Table 1 provides moment-based estimators. 

Table 1: Moment-Based Estimators for the Asymptotic Variance 

**==> picture [360 x 111] intentionally omitted <==**

_Note_ : These estimators are based on rescaling so that _y_ ¯ = _P_[¯] = 1. 

**Theorem A3.** Under mild regularity conditions, a consistent estimator of Σ _Gini_ is 

**==> picture [389 x 21] intentionally omitted <==**

The proofs of these results are Frees, Meyers and Cummings (2011a). 

23 

## **9 Appendix B - Proof of Equation** (5) 

We establish equation (5) assuming ¯ _y_ = _P_[¯] = 1. First, from equation (1), we have that _aj −aj−_ 1 = _[P] n[j]_ and, from equation (2), we have that _bj_ + _bj−_ 1 = 2 _F_[ˆ] _L_ ( _Rj_ ) _−[y] n[j]_[.][Thus,][with][equation][(3),][we][have] 

**==> picture [333 x 70] intentionally omitted <==**

Now, with equation (2) and a change of summations, we can write 

**==> picture [325 x 156] intentionally omitted <==**

Putting this into equation (15), we have 

**==> picture [405 x 123] intentionally omitted <==**

We now use Cov([�] _P, R_ ) = _n[−]_[1] ([∑] _[n] i_ =1 _[P][i][ ×][ i][ −][n][n]_[+1] 2[)][(recall][that][premiums][are][sorted][by][relativities] so that the rank of the _i_ th relativity is _i_ ). To calculate the average weighted premium distribution, 

24 

we have 

**==> picture [312 x 127] intentionally omitted <==**

Putting this into equation (16) yields 

**==> picture [358 x 49] intentionally omitted <==**

which is equation (5). □ 

## **10 Appendix C - Sample Size Calculations** 

The following proposition is a corollary of Theorem A2 of Frees, Meyers and Cummings (2011a). 

**Proposition.** Assume that _R_ is independent of ( _y, P_ ) and the conditions of Theorem A2 hold. Then, we have _[√] n Gini_[�] _→D N_ (0 _,_ Σ _Gini_ ) _,_ where 

**==> picture [196 x 24] intentionally omitted <==**

For simplicity, we establish this proposition assuming by losses and premiums have been rescaled by dividing by their respective averages. Through this rescaling, we have that the mean loss is E _y_ = 1 and the mean premium is E _P_ = 1. 

_Proof._ Under the assumption that _R_ is independent of ( _y, P_ ), we first note that 

**==> picture [241 x 43] intentionally omitted <==**

and similarly, _FL_ ( _s_ ) = _FR_ ( _s_ ). Thus, using equation (12), we may write the projection as 

**==> picture [156 x 23] intentionally omitted <==**

25 

Recall, for continuous relativities _R_ , that _FR_ has a uniform distribution and so E _FR_ = 1 _/_ 2, Var _FR_ = 1 _/_ 12, and E _FR_[2][= 1] _[/]_[12 + (1] _[/]_[2)][2][= 1] _[/]_[3] _[.]_[Now,][assuming] _[R]_[is][independent][of][(] _[y, P]_[),][this] has mean 

**==> picture [252 x 23] intentionally omitted <==**

and so _Gini_ = 0. Further, 

**==> picture [319 x 111] intentionally omitted <==**

Similarly, 

**==> picture [217 x 109] intentionally omitted <==**

By symmetry, we have Σ _hP_ = (Σ _P_ + Σ _yP_ ) _/_ 4. 

Now, using equation (13), _µy_ = 1, _µP_ = 1, and _µh_ = 1 _/_ 2, we have 

**==> picture [422 x 94] intentionally omitted <==**

as required. □ 

26 

Table 2: Summary Statistics of Fourteen Scores and Total Claims 

|Score|Mini-<br>_Percentiles_<br>Maxi-<br>Mean<br>mum<br>1st<br>5th<br>25th<br>50th<br>75th<br>95th<br>99th<br>mum|
|---|---|
|SP<br>~~F~~reqSev<br>~~B~~asic<br>SP<br>~~P~~urePrem<br>~~B~~asic<br>IND<br>~~P~~urePrem<br>~~B~~asic<br>IV<br>~~P~~urePrem<br>~~B~~asic|291.10<br>20.48<br>85.00<br>120.25<br>182.74<br>240.37<br>334.62<br>618.37<br>1,025.88<br>8,856.79<br>289.91<br>33.01<br>89.48<br>127.80<br>189.87<br>246.44<br>329.79<br>586.33<br>1,050.15<br>5,467.41<br>290.91<br>37.49<br>92.08<br>124.04<br>182.68<br>240.30<br>328.87<br>612.47<br>1,087.06<br>13,577.91<br>293.55<br>36.61<br>93.91<br>128.21<br>187.57<br>241.29<br>327.75<br>616.05<br>1,122.84<br>15,472.82|
|SP<br>~~F~~reqSev<br>SP<br>~~P~~urePrem<br>IND<br>~~F~~reqSev<br>IND<br>~~P~~urePrem<br>IV<br>~~P~~urePrem|287.79<br>8.78<br>71.55<br>105.39<br>171.55<br>237.95<br>339.40<br>631.98<br>1,039.19<br>6,864.46<br>290.00<br>10.23<br>72.17<br>107.90<br>175.83<br>242.17<br>338.64<br>616.64<br>1,113.73<br>7,993.52<br>294.93<br>33.05<br>97.14<br>126.61<br>185.07<br>244.99<br>333.68<br>606.03<br>1,106.17<br>22,402.49<br>292.18<br>28.04<br>86.53<br>119.74<br>181.22<br>240.52<br>326.60<br>592.07<br>1,078.25<br>49,912.59<br>294.06<br>12.42<br>78.41<br>113.14<br>178.62<br>240.38<br>330.21<br>614.22<br>1,095.70<br>107,158.09|
|IV<br>~~F~~reqSevA<br>IV<br>~~F~~reqSevB<br>IV<br>~~F~~reqSevC|290.91<br>23.99<br>88.70<br>121.70<br>182.29<br>241.42<br>327.81<br>606.23<br>1,096.86<br>18,102.93<br>295.32<br>28.52<br>94.58<br>124.77<br>184.29<br>245.26<br>335.38<br>606.63<br>1,100.61<br>24,394.06<br>291.17<br>20.88<br>84.78<br>118.21<br>180.63<br>241.57<br>329.92<br>608.28<br>1,098.40<br>20,046.03|
|DepRatio1<br>DepRatio36|301.12<br>33.38<br>98.80<br>128.95<br>188.73<br>249.97<br>340.64<br>619.79<br>1,129.96<br>23,255.94<br>302.39<br>33.48<br>99.27<br>129.65<br>189.87<br>251.41<br>342.30<br>620.38<br>1,132.36<br>23,092.35|
|TotClaims|332.89<br>0.00<br>0.00<br>0.00<br>0.00<br>0.00<br>0.00<br>660.00<br>5,916.33<br>350,000.00|
|_Legend:_||
|**Score**|**Interpretation**|
|_Scores using the basic set of explanatory variables_<br>SP<br>~~F~~reqSev<br>~~B~~asic<br>Single-peril, frequency and severity model<br>SP<br>~~P~~urePrem<br>~~B~~asic<br>Single-peril, pure premium model<br>IND<br>~~P~~urePrem<br>~~B~~asic<br>Multi-peril independence, pure premium model<br>IV<br>~~P~~urePrem<br>~~B~~asic<br>Instrumental variable multi-peril pure premium model<br>_Scores using the extended set of explanatory variables_<br>SP<br>~~F~~reqSev<br>Single-peril, frequency and severity model<br>SP<br>~~P~~urePrem<br>Single-peril, pure premium model<br>IND<br>~~F~~reqSev<br>Multi-peril frequency and severity model assuming independence among perils<br>IND<br>~~P~~urePrem<br>Multi-peril pure premium model assuming independence among perils<br>IV<br>~~P~~urePrem<br>Instrumental variable multi-peril pure premium model.<br>_Instrumental variable multi-peril frequency and severity models, using the extended set of explanatory variables_<br>IV<br>~~F~~reqSevA<br>Uses instruments in frequency model<br>IV<br>~~F~~reqSevB<br>Uses instruments in severity model<br>IV<br>~~F~~reqSevC<br>Uses instruments in frequency and severity models<br>_Dependence ratio multi-peril frequency and severity models, using the extended set of explanatory variables_||
|DepRatio1<br>DepRatio36|Uses a single parameter for frequency dependencies<br>Uses 36 parameters for frequency dependencies|



Table 3: Gini Indices and Standard Errors 

|Alternative<br>Standard<br>Score<br>Gini<br>Error|Alternative<br>Standard<br>Score<br>Gini<br>Error|
|---|---|
|SP<br>~~P~~urePrem<br>~~B~~asic<br>4.89<br>1.43<br>IND<br>~~P~~urePrem<br>~~B~~asic<br>4.01<br>1.46<br>IV<br>~~P~~urePrem<br>~~B~~asic<br>4.33<br>1.46|IV<br>~~F~~reqSevA<br>12.59<br>1.39<br>IV<br>~~F~~reqSevB<br>10.61<br>1.44<br>IV<br>~~F~~reqSevC<br>12.80<br>1.38|
|SP<br>~~F~~reqSev<br>11.15<br>1.42<br>SP<br>~~P~~urePrem<br>9.97<br>1.42<br>IND<br>~~F~~reqSev<br>10.03<br>1.45<br>IND<br>~~P~~urePrem<br>10.96<br>1.45<br>IV<br>~~P~~urePrem<br>11.29<br>1.45|DepRatio1<br>10.09<br>1.45<br>DepRatio36<br>10.06<br>1.46|



_Note: Base Premium is SP_ ~~_F_~~ _reqSev_ ~~_B_~~ _asic._ 

27 

|Table 4: Gini Indices for Fourteen Scores|Extended Explanatory Variables<br>Single Peril<br>IND<br>IV<br>Freq<br>Pure<br>Freq<br>Pure<br>Pure<br>IV<br>FreqSev<br>DepRatio<br>_Maxi-_<br>Sev<br>Prem<br>Sev<br>Prem<br>Prem<br>A<br>B<br>C<br>1<br>36<br>_mum_|_Maxi-_<br>_mum_|29.4|12.8<br>11.7<br>13.4<br>13.2|9.5<br>10.5<br>11.3<br>8.6<br>8.4|7.2<br>11.0<br>7.4|11.3<br>11.2|
|---|---|---|---|---|---|---|---|
|||DepRatio<br>1<br>36|28.0<br>28.0|10.1<br>10.1<br>8.1<br>8.1<br>10.0<br>10.0<br>10.2<br>10.2|7.2<br>7.2<br>8.6<br>8.6<br>2.5<br>2.3<br>4.3<br>4.2<br>5.4<br>5.4|-2.2<br>-2.2<br>-1.6<br>-1.3<br>-0.9<br>-0.9|0.0<br>-0.5<br>0.9<br>0.0|
|||IV<br>FreqSev<br>A<br>B<br>C|29.4<br>28.2<br>29.4|12.6<br>10.6<br>12.8<br>11.4<br>8.8<br>11.7<br>13.4<br>10.6<br>13.4<br>13.2<br>10.6<br>13.2|9.2<br>7.3<br>9.1<br>10.3<br>8.8<br>10.5<br>10.5<br>4.4<br>10.3<br>7.4<br>4.2<br>7.3<br>7.2<br>5.5<br>7.5|0.0<br>-2.2<br>1.9<br>10.1<br>0.0<br>9.9<br>0.8<br>-1.7<br>0.0|10.4<br>4.4<br>10.2<br>10.4<br>4.0<br>10.2|
||||28.8<br>28.1<br>28.0<br>28.5<br>28.4|11.1<br>10.0<br>10.0<br>11.0<br>11.3<br>11.2<br>8.0<br>8.0<br>9.9<br>9.9<br>13.4<br>11.1<br>10.0<br>11.8<br>12.2<br>12.8<br>10.7<br>10.2<br>11.5<br>11.7|0.0<br>4.4<br>7.2<br>9.3<br>9.5<br>9.1<br>0.0<br>8.6<br>9.7<br>9.5<br>11.3<br>9.0<br>0.0<br>9.6<br>11.1<br>8.6<br>6.8<br>4.2<br>0.0<br>3.7<br>8.4<br>6.6<br>5.4<br>4.1<br>0.0|7.2<br>4.0<br>-2.3<br>4.5<br>5.1<br>11.0<br>8.5<br>-1.6<br>8.9<br>10.3<br>7.4<br>3.9<br>-0.9<br>4.5<br>4.5|11.3<br>9.0<br>-2.3<br>9.5<br>11.0<br>11.2<br>8.9<br>-2.0<br>9.5<br>11.0|
||Basic Explanatory Variables<br>Single Peril<br>IND<br>IV<br>Freq<br>Pure<br>Pure<br>Pure<br>Sev<br>Prem<br>Prem<br>Prem||27.0<br>27.0<br>26.8<br>26.9|0.0<br>4.9<br>4.0<br>4.3<br>4.3<br>0.0<br>2.7<br>3.3<br>8.1<br>7.1<br>0.0<br>3.4<br>7.9<br>6.6<br>3.6<br>0.0|1.7<br>4.0<br>4.2<br>4.9<br>7.0<br>5.9<br>6.8<br>7.0<br>6.8<br>6.3<br>3.2<br>4.1<br>6.1<br>5.0<br>1.2<br>2.2<br>6.7<br>6.4<br>3.6<br>3.5|2.8<br>1.3<br>-1.1<br>-0.9<br>6.8<br>5.9<br>3.3<br>3.9<br>3.4<br>1.8<br>0.0<br>-0.2|6.8<br>6.3<br>3.2<br>4.1<br>6.8<br>6.2<br>3.2<br>4.0|
||Base<br>Premium||ConsPrem|SP<br>FreqSev<br>Basic<br>SP<br>PurePrem<br>Basic<br>IND<br>PurePrem<br>Basic<br>IV<br>PurePrem<br>Basic|SP<br>FreqSev<br>SP<br>PurePrem<br>IND<br>FreqSev<br>IND<br>PurePrem<br>IV<br>PurePrem|IV<br>FreqSevA<br>IV<br>FreqSevB<br>IV<br>FreqSevC|DepRatio1<br>DepRatio36|



28 

|Table 5: Gini Standard Errors for Fourteen Scores|Extended Explanatory Variables<br>Single Peril<br>IND<br>IV<br>Freq<br>Pure<br>Freq<br>Pure<br>Pure<br>IV<br>FreqSev<br>DepRatio<br>Sev<br>Prem<br>Sev<br>Prem<br>Prem<br>A<br>B<br>C<br>1<br>36||IV<br>FreqSev<br>DepRatio<br>A<br>B<br>C<br>1<br>36|1.45<br>1.46|1.45<br>1.44<br>1.47<br>1.48<br>1.34<br>1.41<br>1.46<br>1.43|1.49<br>1.50<br>1.49<br>1.52<br>1.52<br>1.49<br>0.00<br>1.46<br>1.46<br>0.00|1.53<br>1.52<br>1.54<br>1.49<br>1.53<br>1.53|1.52<br>1.49<br>1.52<br>1.49|Table 6: Gini Indices, Approximations and Decompositions|Score<br>Gini<br>Gini<br>approx<br>LossSource<br>PremSource<br>Gini<br>approx2<br>GiniReverse<br>SumGinis<br>SP<br>PurePrem<br>Basic<br>4.89<br>4.83<br>-6.14<br>-10.97<br>3.82<br>4.34<br>9.37<br>IND<br>PurePrem<br>Basic<br>4.01<br>3.98<br>-3.60<br>-7.58<br>3.81<br>8.08<br>12.49<br>IV<br>PurePrem<br>Basic<br>4.33<br>4.42<br>-4.45<br>-8.87<br>4.91<br>7.88<br>12.75<br>SP<br>FreqSev<br>11.15<br>11.29<br>9.25<br>-2.03<br>10.79<br>1.71<br>13.18<br>SP<br>PurePrem<br>9.97<br>10.04<br>4.51<br>-5.53<br>9.15<br>6.97<br>16.92<br>IND<br>FreqSev<br>10.03<br>10.31<br>0.59<br>-9.72<br>10.71<br>6.85<br>17.39<br>IND<br>PurePrem<br>10.96<br>11.21<br>1.65<br>-9.56<br>10.10<br>6.13<br>17.60<br>IV<br>PurePrem<br>11.29<br>11.44<br>4.28<br>-7.16<br>10.56<br>6.69<br>18.26<br>IV<br>FreqSevA<br>12.59<br>12.86<br>5.06<br>-7.80<br>12.31<br>2.79<br>15.64<br>IV<br>FreqSevB<br>10.61<br>10.83<br>1.54<br>-9.29<br>11.18<br>6.77<br>17.76<br>IV<br>FreqSevC<br>12.80<br>12.99<br>5.89<br>-7.10<br>12.31<br>3.44<br>16.37<br>DepRatio1<br>10.09<br>10.36<br>0.76<br>-9.60<br>10.74<br>6.83<br>17.41<br>DepRatio36<br>10.06<br>10.34<br>0.65<br>-9.69<br>10.72<br>6.77<br>17.33<br>_Note: Base Premium is SP_<br>_FreqSev_<br>_Basic._|
|---|---|---|---|---|---|---|---|---|---|---|
|||||1.39<br>1.34<br>1.38|1.39<br>1.44<br>1.38<br>1.42<br>1.45<br>1.40<br>1.40<br>1.42<br>1.38<br>1.40<br>1.40<br>1.39|1.45<br>1.47<br>1.45<br>1.46<br>1.46<br>1.46<br>1.53<br>1.30<br>1.50<br>1.50<br>1.50<br>1.49<br>1.49<br>1.45<br>1.50|0.00<br>1.55<br>1.34<br>1.55<br>0.00<br>1.53<br>1.34<br>1.53<br>0.00|1.53<br>1.30<br>1.50<br>1.53<br>1.27<br>1.50|||
|||||1.45<br>1.43<br>1.34<br>1.34<br>1.34|1.42<br>1.42<br>1.45<br>1.45<br>1.45<br>1.45<br>1.42<br>1.46<br>1.46<br>1.46<br>1.40<br>1.40<br>1.44<br>1.44<br>1.44<br>1.45<br>1.48<br>1.41<br>1.41<br>1.41|0.00<br>1.44<br>1.47<br>1.47<br>1.46<br>1.41<br>0.00<br>1.45<br>1.45<br>1.45<br>1.45<br>1.48<br>0.00<br>1.38<br>1.40<br>1.47<br>1.48<br>1.49<br>1.49<br>1.49<br>1.48<br>1.51<br>1.45<br>1.45<br>1.45|1.43<br>1.49<br>1.54<br>1.54<br>1.54<br>1.46<br>1.49<br>1.30<br>1.30<br>1.27<br>1.44<br>1.49<br>1.52<br>1.51<br>1.51|1.45<br>1.48<br>1.38<br>0.00<br>1.32<br>1.45<br>1.48<br>1.40<br>1.32<br>0.00|||
||Basic Explanatory Variables<br>Single Peril<br>IND<br>IV<br>Freq<br>Pure<br>Pure<br>Pure<br>Sev<br>Prem<br>Prem<br>Prem|||1.43<br>1.43<br>1.42<br>1.41|0.00<br>1.43<br>1.46<br>1.46<br>1.44<br>0.00<br>1.41<br>1.45<br>1.44<br>1.39<br>0.00<br>1.38<br>1.45<br>1.43<br>1.39<br>0.00|1.47<br>1.49<br>1.45<br>1.50<br>1.42<br>1.43<br>1.42<br>1.49<br>1.47<br>1.48<br>1.48<br>1.45<br>1.43<br>1.45<br>1.33<br>1.44<br>1.44<br>1.47<br>1.41<br>1.42|1.41<br>1.43<br>1.45<br>1.43<br>1.47<br>1.47<br>1.47<br>1.44<br>1.41<br>1.42<br>1.43<br>1.43|1.47<br>1.48<br>1.48<br>1.45<br>1.48<br>1.48<br>1.48<br>1.45|||
||Base<br>Premium|||ConsPrem|SP<br>FreqSev<br>Basic<br>SP<br>PurePrem<br>Basic<br>IND<br>PurePrem<br>Basic<br>IV<br>PurePrem<br>Basic|SP<br>FreqSev<br>SP<br>PurePrem<br>IND<br>FreqSev<br>IND<br>PurePrem<br>IV<br>PurePrem|IV<br>FreqSevA<br>IV<br>FreqSevB<br>IV<br>FreqSevC|DepRatio1<br>DepRatio36|||



29 

|Table 7: Gini Indices from a Simulation Study|True<br>Correlation|99.29<br>68.78<br>68.77<br>68.78<br>68.77<br>96.90<br>96.69<br>94.65|98.48<br>96.49<br>21.33<br>94.56<br>20.38<br>97.64<br>95.79<br>94.86|98.47<br>5.35<br>99.08<br>5.85<br>99.08<br>97.53<br>98.11<br>97.05|
|---|---|---|---|---|
||Ratio Gini Indices<br>Score1<br>Score2<br>Score3<br>Score4<br>Score5<br>Score6<br>Score7<br>Score8<br>_maximum_|0.00<br>0.10<br>-0.09<br>0.06<br>-0.02<br>0.02<br>-0.12<br>-0.03<br>0.10<br>7.08<br>0.00<br>4.97<br>-0.12<br>4.29<br>7.08<br>6.42<br>6.08<br>7.08<br>7.13<br>5.12<br>0.00<br>4.38<br>0.00<br>6.61<br>7.13<br>6.25<br>7.13<br>7.79<br>2.73<br>5.02<br>0.00<br>4.29<br>7.67<br>7.08<br>7.09<br>7.79<br>7.75<br>5.11<br>2.64<br>4.32<br>0.00<br>7.13<br>7.59<br>7.13<br>7.75<br>2.63<br>-1.23<br>1.08<br>-0.98<br>-0.09<br>0.00<br>1.87<br>-0.12<br>2.63<br>2.73<br>1.38<br>-1.46<br>0.09<br>-1.04<br>2.19<br>0.00<br>0.02<br>2.73<br>4.13<br>0.59<br>0.27<br>-1.24<br>-1.47<br>2.73<br>2.63<br>0.00<br>4.13|0.00<br>0.40<br>-0.08<br>0.36<br>-0.01<br>0.30<br>-0.12<br>0.03<br>0.40<br>1.44<br>0.00<br>0.34<br>-0.12<br>0.25<br>1.34<br>0.80<br>0.64<br>1.44<br>7.13<br>7.04<br>0.00<br>6.67<br>0.31<br>7.07<br>6.96<br>6.88<br>7.13<br>3.13<br>2.74<br>-0.48<br>0.00<br>-0.64<br>3.07<br>1.44<br>1.34<br>3.13<br>7.16<br>7.10<br>0.50<br>6.78<br>0.00<br>7.13<br>7.01<br>6.96<br>7.16<br>0.52<br>0.27<br>0.08<br>0.28<br>-0.08<br>0.00<br>0.22<br>-0.11<br>0.52<br>2.74<br>2.67<br>-1.22<br>0.40<br>-1.14<br>2.67<br>0.00<br>0.29<br>2.74<br>2.87<br>2.71<br>-1.02<br>0.27<br>-1.22<br>2.74<br>0.53<br>0.00<br>2.87|0.00<br>0.36<br>0.63<br>0.40<br>0.56<br>0.16<br>0.41<br>0.34<br>0.63<br>6.94<br>0.00<br>7.00<br>0.36<br>6.92<br>6.94<br>6.94<br>6.90<br>7.00<br>0.53<br>0.44<br>0.00<br>0.46<br>0.17<br>0.40<br>0.52<br>0.43<br>0.53<br>6.95<br>0.25<br>7.00<br>0.00<br>6.91<br>6.91<br>6.94<br>6.94<br>7.00<br>2.56<br>-0.75<br>2.51<br>-0.73<br>0.00<br>0.53<br>2.53<br>0.52<br>2.56<br>2.53<br>-0.97<br>2.73<br>-0.87<br>0.62<br>0.00<br>2.57<br>0.41<br>2.73<br>0.20<br>0.41<br>0.66<br>0.35<br>0.61<br>0.29<br>0.00<br>0.16<br>0.66<br>2.52<br>-0.87<br>2.72<br>-0.98<br>0.67<br>0.21<br>2.53<br>0.00<br>2.72|
||Base<br>Simple<br>Premium<br>Gini|Score1<br>10.05<br>Score2<br>7.13<br>Score3<br>7.08<br>Score4<br>7.13<br>Score5<br>7.08<br>Score6<br>9.75<br>Score7<br>9.70<br>Score8<br>9.57|Score1<br>7.19<br>Score2<br>7.13<br>Score3<br>1.44<br>Score4<br>6.95<br>Score5<br>1.30<br>Score6<br>7.15<br>Score7<br>6.93<br>Score8<br>6.89|Score1<br>6.91<br>Score2<br>0.52<br>Score3<br>6.94<br>Score4<br>0.52<br>Score5<br>6.94<br>Score6<br>6.82<br>Score7<br>6.90<br>Score8<br>6.81|
||Scenario|Explanatory<br>variables<br>contribute<br>equally|Second<br>explanatory<br>variable<br>contributes<br>little|First<br>explanatory<br>variable<br>contributes<br>little|



30 

