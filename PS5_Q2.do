*PS5 Question 2
use "/Users/Stefan/Desktop/FS19/Econometrics II - PhD/PS5/mroz.dta"

***Generating Dummy indicating of kids below 6 years of age

gen kidsbelow6=0
replace kidsbelow6=1 if kidslt6>0

***************************
			*a
***************************
*Probit inlf
probit inlf nwifeinc educ exper expersq age, robust

*Probit kidsbelow6
probit kidsbelow6 nwifeinc educ exper expersq age, robust


***************************
			*b
***************************
*Biprobit
biprobit inlf kidsbelow6 nwifeinc educ exper expersq age, robust


***************************
			*c
***************************
biprobit (inlf=kidsbelow6 nwifeinc educ exper expersq age) (kidsbelow6 nwifeinc educ exper expersq age), robust


***************************
			*e
***************************
constraint 1 kidsbelow6=0
biprobit (inlf=kidsbelow6 nwifeinc educ exper expersq age) (kidsbelow6 nwifeinc educ exper expersq age), constraint(1)


***************************
			*f
***************************
reg inlf kidsbelow6 nwifeinc educ exper expersq age
predict x_beta
replace x_beta=x_beta-kidsbelow6*_b[kidsbelow6]
reg kidsbelow6 nwifeinc educ exper expersq age
predict x_gamma
corr x_beta x_gamma
