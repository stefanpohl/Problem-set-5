clear all
cd  "/Users/luigi/Library/Mobile Documents/com~apple~CloudDocs/Econometrics 2/Part 2/Problem set/PS5"



use "mroz.dta", clear

*Creating dummy variables
g d_kid6=kidslt6>1

*********************************************
	* Question a. Separate Probit Regressions
*********************************************
 
 
probit inlf nwifeinc educ exper expersq age 
probit d_kid6 nwifeinc educ exper expersq age

*********************************************
	* Question b. Bivariate Probit 
*********************************************

*can also use biptobit inlf d_kid6 nwifeinc educ exper expersq age
biprobit (inlf = nwifeinc educ exper expersq age ) (d_kid6 = nwifeinc educ exper expersq age) , 


/*We gain efficiency (SER's are smaller)- also see handwritten solutions
rho is positive meaning that unobservables influencing whether the woman has
kids or not are positively correlated with unobservables influencing whether
the woman self-selects into the labour force or not*/

*********************************************
	* Question c. IV in the bivariate probit
*********************************************


biprobit (inlf = d_kid6 nwifeinc educ exper expersq age ) ( d_kid6 = nwifeinc educ exper expersq age) , vce(r)
est sto m3


/*I am running this essentially as an nonlinear IV. 
Rho ie correlation between the error terms is positive, meaning that the factors 
that the unobservable influencing whether the woman works and whether 
she decides to have children are positively correlated.*/

*********************************************
	* Question e. finding rhos
*********************************************

foreach x in  0.3 0.4 0.5 0.6 0.7 0.8 0.9 {
		local r = 1/2*ln((1+`x')/(1-`x'))
		di `r'
		constraint 1 _b[athrho:_cons]=-`r'
		biprobit (inlf = d_kid6 nwifeinc educ exper expersq age) (d_kid6 = nwifeinc educ exper expersq age) , const(1)
		local i=`x'*10
		est sto bm`i'
		}

	esttab bm*, drop(_cons nwifeinc educ exper expersq age)

/*Coefficients become insignificant at -0.5 and positive and significant at -0.9*/



*********************************************
	* f. Compare rhos from d) to rho we get from selection on observables
*********************************************

	reg inlf d_kid6 nwifeinc educ exper expersq age
	predict resid
	replace resid=resid-d_kid6*_b[d_kid6]

	reg d_kid6  nwifeinc educ exper expersq age
	predict resid2

	corr resid resid2
	
	

/* Selection on observables gives us the value of rho=0.424
 */

 *********************************************
	* g. Lower bounds
*********************************************


	constraint 1 _b[athrho:_cons]= -0.424
	biprobit (inlf = d_kid6 nwifeinc educ exper expersq age) (d_kid6 = nwifeinc educ exper expersq age) , const(1)
	est sto bi
	esttab bi, drop(_cons nwifeinc educ exper expersq age)
	
	*Upper bound
		constraint 1 _b[athrho:_cons]= 0
	biprobit (inlf = d_kid6 nwifeinc educ exper expersq age) (d_kid6 = nwifeinc educ exper expersq age) , const(1)
	est sto bi
	esttab bi, drop(_cons nwifeinc educ exper expersq age)
	

/* Using the value of rho from point f.) as our rho for selection on
unobservables (ie we make selection on observables equal to selection on
unobservables, we get the lower bound of -0.702. Upper bound is -1.481.*/



