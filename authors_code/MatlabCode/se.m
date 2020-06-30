
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fit of Moments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
User.K=30;
R=10;
NP=User.NP;
rand('state',2947828324)
randn('state',435789237)
User.r_it_2=rand(NP,R,User.K);
User.r_i_2=rand(NP,User.K);
User.r_sigma_lambda=randn(NP,User.K);

[f,j1,mk]=msm_60(parameters,User);
f
fit=[M_obs',mk' diag(inv(NP*omega_all)).^.5 (mk'-M_obs')./diag(inv(NP*omega_all)).^.5]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute standard errors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


User.K=30;
R=10;
rand('state',2947828324)
randn('state',435789237)
User.r_it_2=rand(NP,R,User.K);
User.r_i_2=rand(NP,User.K);
User.r_sigma_lambda=randn(NP,User.K);
[f,j1,mk1]=msm_60(parameters,User);

[sz,junk]=size(parameters);

M=[];
M1=[];

PA=parameters;
for j=1:sz
    j
    parameters=PA;
    Diff(j)=min(max(abs(PA(j))*0.01,0.01),.1);
    parameters(j)=PA(j)+Diff(j);
    
    [f,j1,junk]=msm_60(parameters,User);
    M(:,j)=junk';
    parameters=PA;
    
    parameters(j)=PA(j)-Diff(j);
    [f,j1,junk]=msm_60(parameters,User);
    M1(:,j)=junk';
    parameters=PA;
    
end

% moments scaling
MS=User.MS;
K=30;
User.K=K;
omega_scalled=(1./MS*ones(1,38)).*omega.*(1./MS*ones(1,38))';
omega_all_scalled=(1./MS*ones(1,38)).*omega_all.*(1./MS*ones(1,38))';
[a b]=size(M_s);
S=NP*cov((ones(a,1))*MS'.*M_s);
[sz2,junk]=size(M);
g=(M-M1).*(MS*ones(1,sz))./(2*ones(sz2,1)*Diff);
invhessian=(1+1/K)*inv(NP*g'*omega_scalled*g)*(NP*g'*omega_scalled*inv(omega_all_scalled)*omega_scalled*g)*inv(NP*g'*omega_scalled*g);
sd=diag(invhessian).^.5;

ste=[parameters,sd,parameters./sd]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Newey stat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P=eye(38)-g*pinv(g'*omega_scalled*g)*(g'*omega_scalled);
R=P*S*P;
IO=NP*[M_obs.*MS'-mk.*MS']*pinv(R)*[M_obs.*MS'-mk.*MS']'*(K/(K+1));
test_N=[IO,sz2-sz,1-chi2cdf(IO,sz2-sz)]


