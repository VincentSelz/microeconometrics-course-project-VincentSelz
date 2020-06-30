%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%goodness of fit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

K=30;
NP=59;
rand('state',2947828324)
randn('state',435789237)
r_it_2=rand(NP,R,K);
r_i_2=rand(NP,K);

W=inv(NP*diag(diag(cov(M_s))));
omega=inv(NP*cov(M_s));

[f1,mk]=msm_60(parameters,E1o,E2o,NP,R,V,gamma,MaxEffort,omega,K,r_it_2,M_obs,r_i_2,1)
[junk,df]=size(mk);
disp('Chi squared statistic'); disp(K/(K+1)*NP*f1)
disp('Degrees of freedom/Over-identifying restrictions'); disp(df-sz)
disp('p value'); disp(1-chi2cdf(K/(K+1)*NP*f1,df-sz))

sd=diag(inv(NP*W)).^.5;

fit=[M_obs',mk' sd (mk'-M_obs')./sd]

test=[K/(K+1)*NP*f1,df-sz,1-chi2cdf(K/(K+1)*NP*f1,df-sz)]