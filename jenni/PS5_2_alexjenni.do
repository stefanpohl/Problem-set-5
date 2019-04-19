* Housekeeping
local repo XXX
cd `repo'
cap log close
log using "ps5_2_fls", replace
* Data cleaning
use mroz.dta, clear 
replace kidslt6 = (kidslt6 > 1)

* a) Two separate probits
local x "nwifeinc  educ  exper  expersq  age"
probit  inlf `x'
probit kidslt6 `x'

* b) Bivariate probit
biprobit inlf kidslt6 `x'

* c) Bivariate probit with one indep. variable as dep. var
biprobit (inlf = kidslt6  `x') (kidslt6  = `x')


* f) Relate selection on unobservables to selection on observables

* Find selection on observables: reg xb (from inlf) on xb (from kids) 
predict xb_inlf, xb equation(inlf) 
replace xb_inlf = xb_inlf - _b[kidslt6] * kidslt6
predict xb_kids, xb equation(kidslt6) 
reg xb_kids  xb_inlf
local rho = _b[xb_inlf]
di "Our first guess for rho = `=round(`rho',0.001)'"

* Nice, but this value of rho is not consistent with the one used 
* to compute the betas --> loop until the two converge

* Initiate bounds for rho
local i = 0
local rho_high = 0.99
local rho_low = 0

while abs(`rho_high'-`rho_low') > 0.0001{
	di "Values after iteration `i'"
	di "rho `rho', rho_min `rho_low', rho_max `rho_high'"
	if `i' > 100 continue, break
	quietly{
		* Need to pass constraint as atanh_rho_max
		local atanh_rho = 1/2*(ln(1+`rho')-ln(1-`rho'))
		constraint define 1 _b[/athrho ] = `atanh_rho'
		* Get new estimate of selection on observable
		biprobit (inlf = kidslt6  `x') (kidslt6  = `x'), constraint(1)
		drop xb_inlf xb_kids
		predict xb_inlf, xb equation(inlf) 
		replace xb_inlf = xb_inlf - _b[kidslt6] * kidslt6
		predict xb_kids, xb equation(kidslt6)
		reg xb_kids  xb_inlf
		local rho_new = _b[xb_inlf]
		* Update bounds and guess
		if `rho_new' > `rho' local rho_low = `rho'
		else local rho_high = `rho'
		local rho = (`rho_low' + `rho_high')/2
	}
	local ++i
}
di "rho_max = `=round(`rho',0.001)'"
	
		
* g) Lower bound effect of having more than one child
local atanh_rho = 1/2*(ln(1+`rho')-ln(1-`rho'))
constraint define 1 _b[/athrho ] = `atanh_rho'
biprobit (inlf = kidslt6  `x') (kidslt6  = `x'), constraint(1)
probit  inlf kidslt6 `x'

log close
