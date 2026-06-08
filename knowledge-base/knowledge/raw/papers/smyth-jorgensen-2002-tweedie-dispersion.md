# Fitting Tweedie's Compound Poisson Model to Insurance Claims Data: Dispersion Modelling
_Authors_: Gordon K. Smyth, Bent Jorgensen — _Year_: 2002

---


## Page 1

FITTING TWEEDIE'S COMPOUND POISSON MODEL 
TO INSURANCE CLAIMS DATA: DISPERSION MODELLING 
BY 
GORDON K. SMYTH 1 AND BENT JORGENSEN 
ABSTRACT 
We reconsider the problem of producing fair and accurate tariffs based on 
aggregated insurance data giving numbers of claims and total costs for the 
claims. Jorgensen and de Souza (Scand. Actuarial J., 1994) assumed Poisson 
arrival of claims and gamma distributed costs for individual claims. Jorgensen 
and de Souza (1994) directly modelled the risk or expected cost of claims 
per insured unit, p say. They observed that the dependence of the likelihood 
function on p is as for a linear exponential family, so that modelling similar 
to that of generalized linear models is possible. In this paper we observe 
that, when modelling the cost of insurance claims, it is generally necessary to 
model the dispersion of the costs as well as their mean. In order to model the 
dispersion we use the framework of double generalized linear models. Model- 
ling the dispersion increases the precision of the estimated tariffs. The use of 
double generalized linear models also allows us to handle the case where only 
the total cost of claims and not the number of claims has been recorded. 
KEYWORDS 
Car insurance, Claims data, Compound Poisson model, Exposure, Generalized 
linear models, Dispersion modelling, Double generalized linear models, Power 
variance function, REML, Risk theory, Tarification 
1. INTRODUCTION 
We reconsider the problem considered by Jorgensen and de Souza (1994), 
namely that of producing fair and accurate tariffs based on aggregated insur- 
ance data giving numbers of claims and total costs for the claims. Jorgensen 
and de Souza (1994) assumed Poisson arrival of claims and gamma distributed 
costs for individual claims. These assumptions imply that the total cost of 
I Address for correspondence: Dr G.K. Smyth, Bioinformatics, Walter and Eliza Hall Institute of 
Medical Research, Post Office, Royal Melbourne Hospital, Parkville, VIC 3050, Australia. 
ASTIN BULLETIN, Vol. 32, No. 1, 2002, pp. 143-157 


## Page 2

144 
GORDON K. SMYTH AND BENT JORGENSEN 
claims in each category over a given time period follows a Tweedie compound 
Poisson distribution. Jorgensen and de Souza (1994) directly modelled their 
parameter of interest, namely the risk or expected cost of claims per insured 
unit,/~ say. They observed that the dependence of the likelihood function 
on/z is as for a linear exponential family, so that modelling similar to that of 
generalized linear models is possible. 
In this paper we observe that, when modelling the cost of insurance 
claims, it is generally necessary to model the dispersion of the costs as well as 
their mean. In order to model the dispersion we use the framework of double 
generalized linear models developed by Nelder and Pregibon (1987), Smyth 
(1989) and Smyth and Verbyla (1999), Modelling the dispersion increases the 
precision of the estimated tariffs. The use of double generalized linear models 
also allows us to handle the case where only the total cost of claims and not 
the number of claims has been recorded. 
The method used by Jorgensen and de Souza (1994) implicitly assumes 
that explanatory variables affect the expected cost of claims/t by simultane- 
ously increasing or decreasing both the frequency of claims and the average 
claim size. In practice however, some explanatory factors will have a greater 
impact on the frequency of claims than on their size, while other variables may 
impact more on the size of claims. It is also possible for certain factors, such 
as a no-claims bonus, to affect the frequency of claims and the claim size in 
opposite directions. This does not invalidate the method of Jorgensen and de 
Souza (1994), which continues to provide consistent estimators of the risk. 
It does mean though that insurance claims data are likely to display non- 
constant dispersion, so that it is necessary to model the dispersion as well as 
the mean in order to obtain efficient estimation of/z. We add that refinement 
to the method in this paper. 
Double generalized linear models allow the simultaneous modelling of 
both the mean and the dispersion in generalized linear models. Estimation of 
the dispersion is affected by a second generalized linear model, the dispersion 
submodel, in which the responses are the unit deviances from the original 
model. The unit deviances are approximately ~0;X 2, where ~. is the dispersion 
parameter, so that the dispersion submodel is a gamma generalized linear 
model with its own dispersion parameter, which is 2. When modelling insurance 
data with counts of claims as well as total costs, we use the same double gen- 
eralized linear model framework, but modify the definition of the response 
and the weights in the dispersion submodel. When only the total claim costs 
are observed and not the claim counts, the definitions of the response and 
weights in the dispersion submodel revert to their customary values. 
Excellent recent reviews of generalized linear models and their actuarial 
applications are given by Renshaw (1994), Haberman and Renshaw (1998), 
Millenhall (1999) and Murphy, Brockman and Lee (2000). Of these, Millenhall 
(1999) gives most information on the compound Poisson models used in this 
application. Mathematical details on the compound Poisson distributions them- 
selves are given by Jorgensen (1997) and by Rolski, Schmidli, Schmidt and 
Teugels (1999). McCullagh and Nelder (1989) and Dobson (2001) give thorough 
general introductions to generalized linear models and the first of these books 


## Page 3

TWEEDIE'S COMPOUND POISSON MODEL 
145 
includes in Sections 8.4.1 and 12.8.3 the earliest example of non-normal gen- 
eralized linear modelling of insurance claims. 
In normal regression and multivariate modelling it is well known that there 
are advantages to using residual maximum likelihood (REML) for estimating 
the variances rather than maximum likelihood estimation. The idea of REML 
is to adjust the variance estimators to take account of the fact that the means 
were estimated and are therefore closer to the data than the true means can be 
expected to be. REML produces more nearly unbiased estimators for the vari- 
ances, and can produce consistent estimators of the variances when the num- 
ber of parameters affecting the mean grows with the sample size, a situation 
in which maximum likelihood estimation fails. Lee and Nelder (1998), Smyth 
and Verbyla (1999) and Smyth, Huele and Verbyla (2001) study in some detail 
the problem of approximate REML for double generalized linear models, where 
the interest is to modify estimation of the dispersion submodel for estimation 
of the means. In this paper we extend the REML method of Smyth, Huele 
and Verbyla (2001) to the insurance claims context. 
In the next section we review the Tweedie compound Poisson model. 
Section 3 reviews double generalized linear models and describes the case when 
the claim counts are not observed. Section 4 considers the joint likelihood 
using the counts and the costs. In Section 5 we estimate tariffs from the Swedish 
third party automobile portfolio of 1977. 
2. THE COMPOUND-POISSON MODEL 
Let Ni be the number of claims observed in the ith classification category and 
Zi be the total claim size for that category. Suppose that the number of units 
at risk (typically measured in policy years) is wi, and write Y~ = Zi/wi for the 
observed claim per unit at risk. We suppose that N~ is Poisson distributed with 
mean 2~wi, and that the size of each claim is gamma distributed with mean zi 
and shape parameter a. It follows that Ni and Yi are zero with probability e -~,w, and 
that Y~ is otherwise continuous and positive. Individual claims are assumed to 
arrive independently so that the conditional distribution of Y,. given N; is also 
gamma distributed with mean Niri I wi whenever N,- is positive. We suppose that 
independent observations (ni, Yi) are available for categories i = 1 ..... m. 
Jorgensen and de Souza (1994) observed that the parameter of interest from 
the point of view of setting tariffs is/zi = E(Yi) = 
~,izi • From Jorgensen (1987, 
1997) it is known that the distribution of Y~ forms a linear exponential family 
as Pi varies, and that var(Yi) = q)i~lP[wi where p = (a + 2) / (a + 1) and ~i is 
the so-called dispersion parameter. The positivity of a implies that 1 < p < 2. 
The joint density of Ni and Y~ can usefully be parametrized in terms of Pi, ~; 
and p, which describe the mean and variance of the claim per unit risk. The 
variance parameters ~o i and p are statistically orthogonal to Pi, meaning that 
the off-diagonal elements of the Fisher information matrix are zero. This 
parametrization has the advantage, over the alternative parametrization in 
terms of 2i, zi and a, that it focuses attention of the parameter of interest and 
two other parameters which are orthogonal to it. 


## Page 4

146 
GORDON K. SMYTH AND BENT JORGENSEN 
The variance of Y/can be obtained directly as EN, var (Y~ [ Ni)+ yarN, E (Y~ [ Ni) : 
2 
2 
•i Ti /(Ol'Wi) + 2i z~/wi = (l/a + 1)2~ z 2/w~. Equating this to the alternative expression 
~/~f/w~ for the variance gives the dispersion parameter in terms of 2 and r as 
~oi= wivar(Yi) I /~i p= 2]-P l(2-p) 
The exponent 1 -p for 2i here is negative, so it can be seen that any factor which 
increases the frequency of claims 2,. without affecting their average size will 
decrease the dispersion ~- while increasing the mean/z`.. On the other hand the 
exponent 2-p for z`. is positive, so any factor which increases the average claim 
size r~ without increasing their frequency will increase both the mean and the 
dispersion. Any factor which affects the mean but not the dispersion must affect 
/~i and Z i in such a way that 2] -p Z~ -p remains constant. 
We therefore assume a model which allows both/-/i and (Pi to very depend- 
ing on the values of covariates. As in generalized linear models, we assume a 
link-linear model for the mean cost 
x[L 
(1) 
Here g is a known monotonic link function, x`. is a vector of covariates, and fl 
is a vector of regression coefficients. As in double generalized linear models, 
we simultaneously assume another link-linear model 
-- zf y 
(2) 
for the dispersion, where z`. is a vector of covariates thought to affect the dis- 
persion and 7 is another vector of regression parameters to be estimated. 
In many cases it will be convenient to take both g and gd to be logarithmic, 
in which case (1) and (2) imply log-linear models also for the expected claim 
frequency 2`. and for the expected claim size ~;. The model we describe is then 
equivalent to separate log-linear modelling of the claim frequency and the 
claim size, with the added-value that complete information is used for all 
inferences and the results are automatically collated for the cost per unit risk 
which is of direct interest. 
In all of the following we assume that a, and hence also p, does not vary 
between cases. 
3. CLAIM COST ONLY IS OBSERVED 
3.1. Maximum Likelihood 
Consider now the case in which only the total cost of claims in each category 
and not the actual number of claims has been recorded, i.e., we observe wi 
and Y`. = Yi, i = 1,..., m, but not N`.. The amount of information available is 
rather lower than when iV,- is observed as well but, as Jorgensen and de Souza 


## Page 5

TWEEDIE'S COMPOUND POISSON MODEL 
147 
(1994) observed, the information in the frequencies is directed mainly at the 
~0i and p, and is therefore of second order regarding the estimation of p; and 
the tariffs. In this case we have a double generalized linear model (Smyth, 
1989; Smyth and Verbyla, 1999) in which the response, Y, follows a Tweedie 
compound Poisson distribution. Approximate maximum likelihood estimates 
of the mean coefficients fl and the dispersion coefficients 7 can be obtained by 
alternating between two generalized linear models. With 7 and p fixed, fl can 
be estimated from a generalized linear model with response y;, mean Pi, vari- 
ance function V(pi) = pi p, link function g, linear predictor x/~ fl, weights w~ / ~i 
and dispersion parameter 1. Let di be the unit deviances from this generalized 
linear model. With fl and p fixed, y can be estimated from a generalized linear 
model with the di as responses. 
The saddleP2oint approximation ensures that the di are approximately dis- 
tributed as (frill for (ffi reasonably small (Nelder and Pregibon, 1987; J~rgen- 
sen, 1997; Smyth and Verbyla, 1999). The d; therefore follow approximately a 
gamma generalized linear model, with mean ~0 i, variance function ~ ((Pi) = tp~, 
link function gd, linear predictor z/r 7 and dispersion parameter 2. 
The Fisher scoring equations for fl and 7 are as follows. The Fisher scoring 
update equation for fl is 
/1~+1 = (Xr WX) -1XrWz 
where W is the diagonal matrix of working weights 
W= diag 
tPi V(/.ti) 
(3) 
with variance function V(p) =/zP, z is the working vector with components 
ag~i) 
Zi= 
~)IL l 
(Yi-I'ti)+g(l'ti) 
and all terms on the right-hand-side of (3) are evaluated at the previous iterate 
ff (McCullagh and Nelder, 1989, Section 2.5). Standard errors for/~ are obtained 
from the inverse of the Fisher information matrix 
3~ = X T WX. 
The unit deviances for the generalized linear model can be defined as 
d, = 2~0 i {log fr (Yi ; Y,, q~ /wi,p) - l°gfr (Yi "~ fli, ~°i /wi 'P)}' 
wherefr (y;/t, ~0, p) is the marginal density function of the Yi, which in our case 
gives 
i -p 
Yi 
-Pl -p 
y2-p_ 
-p 
di= 2wi Yi 
1-p 
2- 
" 


## Page 6

148 
GORDON K. SMYTH AND BENT JORGENSEN 
Note that d; does not depend on (p~. The approximate Fisher scoring iteration 
for y is 
yk+l= (ZrWdZ)-Izrwazd 
(4) 
where Wa is the diagonal matrix of working weights 
Wd= diag ~ - 2  
1 
} 
with variance function V a (~o)= ~0 2, Z d is the working vector with components 
3gd(~Oi) 
Zdi = 
~0 
(di -- ~Oi ) q- gd (q~i) 
and all terms on the right-hand-side of (4) are evaluated at the previous iterate 
yk (Smyth, 1989). Standard errors for p are obtained from the inverse of the 
Fisher information matrix 
3r= ZrWdZ. 
Since fl and y are orthogonal, alternating between (3) and (4) results in an effi- 
cient algorithm with typically rapid convergence (Smyth, 1996). The iteration 
can be initiated at Pi = Yi and ~0,. = 1. Score tests and estimated standard errors 
from each generalized linear model are correct for the combined model (Smyth, 
1989). Finally, estimation of p can be obtained by maximizing the saddlepoint 
profile likelihood forp (Nelder and Pregibon, 1987; Smyth and Verbyla, 1999). 
We have not adjusted the standard errors for y for estimation of p, although 
this could be done as in Jorgensen and de Souza (1994). The standard errors 
for fl, which are of most interest, do not require such adjustment as fl is orthog- 
onal to p. 
The accuracy of the saddlepoint approximation for the densityfr (y;/l, ~0, p) 
has been discussed by Smyth and Verbyla (1999) and by Dunn (2001). In the 
context of the likelihood calculations in this Section, the saddlepoint approxi- 
mation is most accurate when the number of claims per risk category is large 
or when the estimated variability ~bi/wg is small. In particular, the approxi- 
mation is likely to be satisfactory when the proportion of categories with zero 
claims is small. When there are many categories with zero claims, the ~0 i will 
tend to be overestimated. However this will have only a secondary effect on the 
estimated values for/z~ and corresponding risk factors. 
Use of the saddle-point approximation for estimation of y and p is essen- 
tially equivalent to the extended quasi-likelihood (EQL) of Nelder and Pregi- 
bon (1987) and Nelder and Lee (1992). The EQL approach emphasises the fact 
that the estimators depend only on second moment assumptions about the 
distribution of the Y/. The properties of the estimators therefore are not highly 
dependent in the compound Poisson distribution assumptions about the Y~, 
as long as the mean and dispersion are correctly specified. 


## Page 7

TWEEDIE'S COMPOUND POISSON MODEL 
149 
3.2. Approximate REML 
It is well known in linear regression that the maximum likelihood variance 
estimators are biased downwards when the number of parameters used to 
estimate the fitted values is large compared with the sample size. The same 
principle applies to double generalized linear models. The maximum likelihood 
estimators ~i are biased downwards and the estimated variances (oif~/w i are 
too small by an average factor of about klm where k is the dimension of fl 
and m is the sample size. In normal linear models, restricted or residual maxi- 
mum likelihood (REML) is usually used to estimate the variances, and this 
produces estimators which are approximately and sometimes exactly unbiased. 
Let the hi be the diagonal elements of the hat matrix 
W 112 X(X T W.e~() -1 X T W 1/2 ' 
often called the leverages for the generalized linear model for the y;. Approxi- 
mately unbiased estimators of the <A may be obtained by modifying the scoring 
update for y as follows. The leverage adjusted scoring update is 
T 
* 
-1 
T 
* * 
k+l=_(Z 
W d Z) 
Z 
W d Z d 
where W d is the diagonal matrix 
Wff_.. 
[[;ggd(~Oi)] -2 
l-hi 
} 
-°lagl[ 
 1 2Vd(~i ) 
and 
* ~)gd(tpS{ di--t, Oi ) 
Zdi= 
8~0 
~l-h i 
+gd(~°i)" 
(5) 
See Lee and Nelder (1998) and Smyth, Huele and Verbyla (2001) for a dis- 
cussion of this leverage adjustment. The appearance of the factor 1 
- 
h i in the 
information in a reflection of the fact that an observation with leverage hi = 1 
provides no information about ~0 i. The scoring iteration (5) approximately 
maximizes with respect to ~ the penalized profile log-likelihood 
, 
A 
12 p (y; y,p) = 12 (y; [3 ~, y,p) + 1 log X r WX 
(6) 
p, 
where 12 (y;fl, y,p) is the ordinary log-likelihood function, fly is the maximum 
likelihood estimator of fl for given values of y and p, and W is evaluated at 
fl = fly. This penalized log-likelihood reduces to the REML likelihood in the 
normal linear case and can be more generally justified as an approximate con- 
ditional log-likelihood (Cox and Reid, 1987). Approximately unbiased estima- 
tion of p can be obtained by maximizing (6) with respect to both y and p. 


## Page 8

150 
GORDON K. SMYTH AND BENT JIORGENSEN 
4. CLAIM COST AND FREQUENCY ARE BOTH OBSERVED 
4.1. The Joint Likelihood Function 
Consider Ni and Yi for a particular classification category, and for ease of 
notation drop the subscript i for most of the remainder of this section. The joint 
probability density function of N and Y is given by Jorgensen and de Souza 
(1994, equation 11). It can be written as 
with 
and 
f(n, y;Iz, ~o/w,p)= a (n, y, q~/w,p )exp { ~ t(v, lz,p) } 
(W / ~O)a+lY ~ 1 n 
1 
a(n,y;p,~o/w,p)= [~-~) 
] n!F (neOy 
1-p 
~//2-p 
t(v'I~'P)= Y 1- p 
2- p" 
The log-likelihood function for the unknown parameters fl, 7 and p is 
m 
~(n, y;fl, y,p)= ~,log f(ni,Yi;lzi, ~Oi /W ` ,p). 
i=l 
It can be seen that y is sufficient for p, and that the density follows a linear 
exponential family as/z varies. We have 
alogf(n,y;lu,~o/w,p) _ w at(y,p,p) _ w y-/u 
(7) 
At n = y = 0 the distribution has probability mass given by 
logf(O,O;lu, q~/w,p)=-w2= 
w #2-p 
W t(o,/u,P) 
~p 2-p =-~ 
so (7) holds over the whole range of the distribution. It follows, by differenti- 
ating (7) again with respect to ~0 or p, that the cross derivatives with respect to 
/z and either ~o or p have expectation zero. In other words, p is orthogonal to 
both q~ and p. 
Now consider the estimation of q~. Although the joint density is not a linear 
exponential family, we can fit the likelihood equations into a generalized linear 
model structure by creating suitable pseudo working responses and working 
weights. This will allow us to make use of the double generalized linear model 
framework in computations and in data analysis. We have 
a logf(n,y;Iz, q~/w,p) _ 
n 
W 
a~ 
(p-1)fp 
cp 2 t(y'Iz'P) 
and 


## Page 9

TWEEDIE'S COMPOUND POISSON MODEL 
151 
Now 
and 
a210gf(n,y;p, tp / w,p) _ 
n 
+ 2_~w 
3 t(y,lu,p)" 
~02 
(p-1)~o 2 
~0 
/./2-p 
E {t(Y,p,p)} - (1- p)(2- p) 
E(N) = w fl2-p 
tP2-p 
so the Fisher information for ~0 from a single (hi, Yi) pair is 
E{_ a21ogf]_ 
Wp 2.p 
a~o 2 
(2- p)(p- 1)~o 3 
Define dispersion-prior weights to be 
Then 
2Wfl 2-p 
Wd= (2- p)(p- 1)~o" 
E[ a21°gf } 
Wd 
- 
2 
with Vd(fP) = ~2. The choice of 2q~ 2 in the denominator is in order to match 
the dispersion model in Section 2. In insurance applications we will almost 
always have Wd > 1, in which case we interpret (Wd-1)/{2Vd(q0} as the extra 
information about ~ arising from observation of the number of claims n~. If 
Wd < l, then the saddlepoint approximation which underlies the computations 
in Section 3.1 is poor, and the true information about ~i arising from yg is less 
than that indicated in Section 3.1. Define dispersion-responses to be 
Wd 
aq~ 
t-q~=- 
+wt +~. 
We can now write the first derivative of the log-density in the form 
a logf(n,y;iz, ¢/w,p) _ w d (d-~) 
2 
• 
The above definitions for Wd and d are somewhat artificial, but have the effect 
of putting the likelihood calculations into the form of a double generalized 
linear model. The components of the likelihood score vector ~¢/Oq~ can now 
be written as 
()~ 
~'I Wdi (di - ~i ) 
~(Pi 
~i=1 2Vd ((Pi) 


## Page 10

152 
GORDON K. SMYTH AND BENT JfJRGENSEN 
and the Fisher information matrix for the tp i is 
$~ = diag/~-~w~-~/• 
/ 
d~ 
I 
4.2. Maximum Likelihood 
Since/z is orthogonal to tp and p, it follows that fl is orthogonal to ~, and p. It is 
sensible therefore to consider estimation of the parameters separately. For e 
and p fixed, the Yr are sufficient for fl and estimation of fl can proceed exactly 
as in Section 2. The estimating equations and information matrix for fl are 
exactly as when the nr are not observed. 
Now consider the estimation of y for fixed fl and p. Since 
-~- - diag 
Z 
where Z is the design matrix with rows z r, the information matrix for e is 
O r 
3 ~ = --~- $ ~ --~0 ~ = z T wa z 
where 
W d = diag 
2 V d (~0 i) 1" 
This is the same weight matrix that we would obtain from a generalized linear 
model with link function ga, variance function Vd(~0r) = ~0~ and prior weights War. 
The score vector for ~ is 
0l~ 
0~P r O~ 
07 -- be -~ = Z T W d rd 
with rai = {3ga(~0)/3~}(dr-~0i). The scoring iteration for e can be written in the 
standard generalized linear model form 
ek+l= (ZT Wd Z)-I ZT WdZd 
where zar = {bga(~oi)/3~o}(dr-~0,-)+ ga(~oi) is the dispersion-working vector. In 
this equation, all terms on the right hand size are evaluated at the current 
working estimate ?k and 7k+1 is the updated estimate. Note that war and dr are 
as defined in Section 4.1. 
4.3. Approximate REML 
When the nr are observed there is more information available for the estimation 
of ~ and p, and correspondingly less need to adjust the estimation of ~, for 


## Page 11

TWEEDIE'S COMPOUND POISSON MODEL 
153 
estimation of ft. The adjustment may still be useful however and is relatively 
straightforward. Since the information matrix for fl is unchanged by obser- 
vation of n,-, we may use the same adjustment to the profile likelihood as in 
Section 3.2. Therefore we need to adjust the score vector for y by the same 
quantity as in Section 3.2. We adjust the working weight matrix to 
dia- [[ Ogd(~°i)1-2 [Wd, ~ h~[ + [ 
<*= ql--- l 2vd%)J 
where [W d;- hi[ ÷ is the maximum of Wd~ -h i and zero, and replace d~ with 
* 
Wdi dr 
d i = Wd i - h i 
The adjusted scoring iteration for g is then 
k+l (zrw'z)-IZrW*z 
• 
= 
d 
d 
d 
with z5i = {Ogd(~O,-) / O~o}(d;- ~oi) + gd(~Oi). 
5. SWEDISH THIRD PARTY MOTOR INSURANCE 
We consider the Third Party Motor Insurance data for Sweden for 1977 
described by Andrews and Herzberg (1985) and previously analysed by Hallin 
and Ingenbleek (1983). The data can be obtained from the URL www.statsci. 
org/data/general/motorins.html. We consider only the data for Zone 1, which 
consists of the three largest cities, Stockholm, G6teborg and Maim6 with sur- 
roundings, and exclude Make class 9 which is a miscellaneous category of all 
makes other than the first eight. This leaves 5406 claims over the period in 
280 categories. Of the 280 categories, 20 had no claims in 1977. The explana- 
tory factors are the Make of the car (8 classes), the number of kilometres trav- 
elled per year (in 5 ordered categories) and the no claims bonus class. Bonus 
represents the number of years since last claim, from 1 up to 7. 
Exploratory analyses of claim frequency and claim size show that Bonus 
affects frequency and size in different directions, while the other two factors 
affect claim frequency more than claim size. We therefore expect to find strong 
factor effects on the dispersion as well as on the mean. We fit log-linear mod- 
els (with g and ga both equal to the logarithmic function) to both the mean 
and the dispersion. When main effects only are fitted all three factors for both 
the mean and the dispersion, the maximum likelihood estimator of p is found 
to be 1.725. We find that all three factors have highly significant main effects 
on both the mean and the dispersion (Table 1). The dispersion effects are 
rather more significant than those for the mean, emphasizing the importance 
of including the dispersion model. 
There is also definite evidence of interactions in the Swedish claims data. 
The likelihood ratio statistics to add interactions are given in Table 2. Although 


## Page 12

154 
GORDON K. SMYTH AND BENT JORGENSEN 
TABLE 1 
JOINT MODELLING OF FREQUENCY AND SIZE OF CLAIMS: 
DIFFERENCES IN TWICE THE LOG-LIKELIHOOD FOR REMOVING FACTORS. 
Factor 
df 
Deviance to Remove Factor 
from Mean 
from Dispersion 
Bonus 
6 
363.9 
1190.9 
Make 
7 
78.1 
179.8 
Kilometres 
4 
24.2 
45.1 
TABLE 2 
JOINT MODELLING OF FREQUENCY AND SIZE OF CLAIMS: 
DIFFERENCES IN TWICE THE LOG-LIKELIHOOD FOR ADDING INTERACTIONS. 
Factor 
df 
Deviance to Add Interaction 
to Mean 
to Dispersion 
Bonus: Make 
42 
63.3 
78.3 
Bonus: Kilometres 
24 
37.1 
36.0 
Make: Kilometres 
28 
35.6 
52.1 
the interactions are statistically significant, they are far less so than the main 
effects. Since the interactions produce a model which is too complex for prac- 
tical use in setting insurance tariffs, we will treat the main effects model as the 
final model. Some exploration of the data failed to find any way to explain 
the interactions with a small number of degrees of freedom. 
The effects for Bonus and Kilometres are monotonic, as would be 
expected from their meaning, except that Bonus level 6 and Kilometres level 3 
are out of sequence in the mean model. To achieve monotonic effects for the 
Bonus and Kilometres, Bonus levels 5 and 6 and Kilometres levels 2 and 3 
were combined. This increases minus twice the likelihood by only 1.0 on 4 df. 
The resulting model for the mean is given in the first column of Table 3. The 
base risk is estimated to be 694.5 Swedish kroner per car-year. This corresponds 
to drivers without a no claim bonus, driving Make 1, who drive fewer than 
1000 km per year. For the other categories the base risk should be multiplied 
by the factors given in the table. Increasing the no-claims bonus decreases the 
mean cost per unit risk but increases the dispersion. Increasing kilometres 
travelled increases the mean cost but decreases the dispersion. Make 8 is the 
most expensive while Make 4 (the Volkswagen bug) is the cheapest. Make 4 
also has the smallest dispersion. 
To investigate the stability of the results, the mean-dispersion main-effects 
model was fitted using four methods: maximum likelihood and approximate 
REML using the full data and approximate maximum likelihood and REML 


## Page 13

TWEEDIE'S COMPOUND POISSON MODEL 
155 
TABLE 3 
BASE RATE RISK AND MULTIPLIERS FOR VARIOUS RISK CATEGORIES. 
THE RISKS ARE ESTIMATED USING FIVE DIFFERENT METHODS. DISTANCE IS IN 1000S OF KILOMETRES PER 
YEAR. THE BASE RISK SHOULD BE MULTIPLIED BY THE FACTORS GIVEN FOR EACH RISK CATEGORY. 
Cost & Frequency 
Cost Only 
Constant 
Category 
ML 
REML 
ML 
REML 
Dispersion 
Base rate 
694.527 
694.536 
697.346 
692.904 
691.105 
Bonus 1 
1.000 
1.000 
1.000 
1.000 
1.000 
Bonus 2 
0.734 
0.734 
0.725 
0.725 
0.730 
Bonus 3 
0.685 
0.685 
0.676 
0.676 
0.686 
Bonus 4 
0.500 
0.500 
0.516 
0.517 
0.518 
Bonus 5-6 
0.418 
0.418 
0.401 
0.406 
0.430 
Bonus 7 
0.268 
0.268 
0.267 
0.267 
0.272 
Make 1 
1.000 
1.000 
1.000 
1.000 
1.000 
Make 2 
1.260 
1.260 
1.284 
1.294 
1.181 
Make 3 
0.960 
0.960 
1.015 
1.031 
0.902 
Make 4 
0.536 
0.536 
0.540 
0.543 
0.547 
Make 5 
1.005 
1.005 
1.035 
1.044 
1.034 
Make 6 
0.685 
0.685 
0.692 
0.690 
0.712 
Make 7 
0.768 
0.768 
0.808 
0.819 
0.765 
Make 8 
1.557 
1.557 
1.661 
1.701 
1.391 
Kilometres _< 1 
1.000 
1.000 
1.000 
1.000 
1.000 
Kilometres 1-20 
1.282 
1.282 
1.274 
1.272 
1.268 
Kilometres 20-25 
1.399 
1.400 
1.367 
1.356 
1.401 
Kilometres > 25 
1.663 
1.663 
1.598 
1.603 
1.734 
using the total cost of claims only. The value of the variance power p was esti- 
mated by the four methods to be 1.725, 1.735, 1.775 and 1.775 respectively. In 
addition, the main-effects model for the mean was also fitted with a constant 
dispersion model using approximate REML on the full data. This is the fifth 
estimation method and produces the last column of Table 3. It can be seen 
from the table that there is very little difference between the maximum likeli- 
hood and REML methods using the full data. The difference between the full 
data results and those using the total claim costs only is more noticeable but 
still not large. The difference between modelling the dispersion and assuming 
constant dispersion is of a similar magnitude to that between using the full data 
and using the claim costs only. 
The method has been implemented as an S-Plus function tariff available 
from the URL www.statsci.org/s/tariff.html. In this function the number of 
claims in an optional argument. When it is not given, the method defaults to 
the double generalized linear model method outlined in Section 3. Software 
to fit double generalized linear models and ordinary generalized linear models 
with power variance functions was previously described by Smyth and Verbyla 
(1999). 


## Page 14

156 
GORDON K. SMYTH AND BENT JORGENSEN 
6. CONCLUDING COMMENTS 
The approach based on Tweedie's compound Poisson distribution pro- 
vides a highly efficient method of analysing insurance claims data. The distri- 
butional assumptions can be assessed using standard data analysis techniques 
and in any case the relationship with extended quasi-likelihood suggests that 
the method will not be very sensitive to moderate deviations from the assumed 
Poisson and gamma distributions for the counts and claim sizes. 
One side-effect of the efficiency is that more terms are likely to be found 
to be significant in the fitted model compared with approximate methods 
or methods based on the univariate likelihoods. In particular, it may be that 
significant interactions will be found which are too complicated for practical 
insurance applications. In most cases the main effects will be dominant, so 
that the interactions might be neglected as of lesser importance, as for the 
Swedish motor insurance data. 
REFERENCES 
ANDREWS, D.E, and HERZBERG, A.M. (1985) Data. A collection of problems from many fields 
for the student and research worker. Springer-Vedag, New York, pp. 4t3-421. 
Cox, D.R. and REID, N. (1987) Parameter orthogonality and approximate conditional inference. 
JR. Statist. Soc B 49, 1-39. 
DOBSON, A.J. (2001) An Introduction to Generalized Linear Models, Second Edition. Chapman 
and Hall/CRC, London. 
DUNN, EK. (2001) Likelihood-Based Inference for Tweedie Generalized Linear Models. PhD The- 
sis, Department of Mathematics, University of Queensland, Brisbane, Australia. 
HABERMAN, S., and RENSHAW, A.E. (1998) Actuarial applications of generalized linear models. 
In Statistics in Finance, D.J. Hand and S.D. Jacka (eds), Arnold, London. 
HALLIN, M., and INGENBLEEK, J.-E (1983) The Swedish automobile portfolio in 1977. A statis- 
tical study. Scandinavian Actuarial Journal, 49-64. 
JORGENSEN, B. (1987) Exponential dispersion models. J. R. Statist. Soc. B 49, 127-162. 
JORGENSEN, B. (1997) Theory of Dispersion Models. Chapman & Hall, London. 
JI~RGENSEN, B. and DE SOUZA, M.C.P. (1994) Fitting Tweedie's compound Poisson model to 
insurance claims data. Scandinavian Actuarial Journal, 69-93. 
LEE, Y. and NELDER, J.A. (1998) Generalized linear models for the analysis of quality-improve- 
ment experiments. Canadian Journal of Statistics 26, 95-105. 
MCCULLAGH, P. and NELDER, J.A. (1989) Generalized Linear Models, 2nd Edition. Chapman & 
Hall, London. 
MILLENHALL, S.J. (1999) A systematic relationship between minimum bias and generalized lin- 
ear models. 1999 Proceedings of the Casualty Actuarial Society 86, 393-487. 
MURPHY, K.P., BROCKMAN, M.J. and LEE, P.K.W. (2000) Using generalized linear models to 
build dynamic pricing systems. Casualty Actuarial Forum, Winter 2000. 
NELDER, J.A., and LEE, Y. (1992) Likelihood, quasi-likelihood and pseudo-likelihood: some 
comparisons. J R. Statist. Soc. B 54, 273-284. 
NELDER, J.A. and PREGIBON, O. (1987) An extended quasi-likelihood function. Biometrik 74, 
221-231. 
RENSHAW, A.E. (1994) Modelling the claims process in the presence of covariates. ASTIN Bul- 
letin 24, 265-286. 
ROLSKI, T., SCHMIDLI, n., SCHMIDT, V., and TEUGELS, J. (1999) Stochastic Processes for Insur- 
ance and Finance. John Wiley & Sons, Chichester. 
SMYTH, G.K. (1989) Generalized linear models with varying dispersion. J Roy. Statist. Soc. B 
51, 47-60. 


## Page 15

TWEEDIE'S COMPOUND POISSON MODEL 
157 
SMYTH, G.K. (1996) Partitioned algorithms for maximum likelihood and other nonlinear estima- 
tion. Statistics and Computing 6, 201-216. 
SMYTH, G.K., and VERBYLA, A.P. (1999) Adjusted likelihood methods for modelling dispersion 
in generalized linear models. Environments 10, 696-709. 
SMYTH, G.K., HUELE, F., and VERBYLA, A.P. (2001) Exact and approximate REML for het- 
eroscedastic regression. Statistical Modelling 1, 161-175. 
GORDON K. SMYTH 
Walter and Eliza Hall Institute of Medical Research 
Melbourne, Australia 
BENT JORGENSEN 
Department of Statistics and Demography 
University of Southern Denmark 
