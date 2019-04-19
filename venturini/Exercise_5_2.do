**************************************
***   PROBLEM SET 5 - EXERCISE 2   ***			Miriam Venturini
**************************************
set more off
set matsize 10000
use "..\mroz.dta", clear

gen kids = kidslt6 > 0

*a)
probit inlf nwifeinc educ exper expersq age
probit kids nwifeinc educ exper expersq age

*b)
biprobit inlf kids nwifeinc educ exper expersq age
* you don't need to assume that the error terms (the unobservables) are 
* uncorrelated, you allow them to be arbitrarily correlated.

*c)
biprobit (kids =      nwifeinc educ exper expersq age) ///
		 (inlf = kids nwifeinc educ exper expersq age)
* rho = .0952328, s.e.= .181702  
* rho is not significantly different from 0
* you use the fact that having kids has an impact on labor force participation,
* but you assume that labor force participation does not have an impact on 
* having kids.

*d)
/* You can assess the selection on unobservables problem (how sensitive are the 
estimates to assumptions about selection on unobservables) by estimating 
your coeffient of interest fixing different arbitrary values of rho and finding 
which rho would make your coefficient non-significant. 
Moreover, if we are willing to assume that selection on observables is stronger 
than selection on unobservables, then we can consider the case in which the two 
are equal as an upper bound for rho (and a lower bound for the kids dummy 
coefficient) and the case in which the selection on unobservables is 0 as a 
lower bound for rho (and an upper bound for the kids dummy coefficient). This
allows to construct bounds for your coefficient of interest. However, the
idea of a lower bound of 0 for rho in our case does not seem plausible. I would
instead consider the case in which the selection on observables and
unobservables are equal in magnitude and opposite in sign as the one 
corresponding to a lower bound for rho and an upper bound for alpha
(see point g).*/

*e)		 
* This sets the coefficient of kids dummy=0
constraint 1 kids = 0

biprobit (kids =      nwifeinc educ exper expersq age) ///
		 (inlf = kids nwifeinc educ exper expersq age), constraints(1)
* The result is the same of running the bivariate probit without kids dummy in
* the inlf equation.
		
nlcom tanh([athrho]_b[_cons])	
nlcom atanh(-.5070269) /*this gives athrho for every rho I put*/

* Alternatively we could see for which rho the coefficient of kids dummy
* becomes non-significant. This could be done with a grid for rho.
* But let's only check if this approach would work with our result from the
* previous constrained regression.

local athrho = atanh(-0.5070269)
constraint 2 [athrho]_cons = `athrho'
biprobit (kids =      nwifeinc educ exper expersq age) ///
		 (inlf = kids nwifeinc educ exper expersq age), constraints(2)
* The rho found with the kids coefficient constrained to 0, gives a 
* non-significant result for the same coefficient once we fix rho to the value 
* we found.

*f) 
* We are basically not controlling for the matherhood selection (basically 
* dropping kids dummy in the equation for labor participation). Since the
* coefficient of kids dummy is negative, it seems plausible to observe a 
* negative correlation between the unobservables in the selection into 
* matherhood equation and unobservables in the selection into labor force 
* equation. 


*g)

*We are willing to assume that selection on observables should be stronger 
*than selection on unobservables, we can compute an upper bound for pho and use
*it to find a lower bound effect of having more than one child*

biprobit (kids =      nwifeinc educ exper expersq age) ///
		 (inlf = kids nwifeinc educ exper expersq age)
		 
matrix b = e(b)
matrix beta = b[1,1..6]
matrix gamma = b[1,8..13]

gen ones = 1

mkmat nwifeinc educ exper expersq age ones, matrix(x)

mat xbeta = x*beta'
mat xgamma =x*gamma'

svmat xbeta, names(xbeta)
svmat xgamma, names(xgamma)

reg xbeta xgamma

*lower bound for kids dummy coefficient*
local athrho = atanh(_b[xgamma])
constraint 3 [athrho]_cons = `athrho'
biprobit (kids =      nwifeinc educ exper expersq age) ///
		 (inlf = kids nwifeinc educ exper expersq age), constraints(3)
*coefficient is -1.747 standard error 0.135

* a possible upper bound for kids dummy coefficient*
reg xbeta xgamma
		 
local athrho = atanh(-_b[xgamma])
constraint 4 [athrho]_cons = `athrho'
biprobit (kids =      nwifeinc educ exper expersq age) ///
		 (inlf = kids nwifeinc educ exper expersq age), constraints(4)
* coefficient is -0.165  standard error 0.1345
* the pho is now set to be -0.477 actually quite close of the one we got
* contraining the coefficient for kids dummy to be equal to zero.
* In fact, the coefficient for kids dummy is not significantly different from 0
* anymore.

