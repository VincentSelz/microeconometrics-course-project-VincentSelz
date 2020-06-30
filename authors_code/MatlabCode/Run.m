%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Robustness parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

% Nornally distributed cost unobservables (0=Weibull; 1=Normal)
Normal=0;

% Number of 2nd Movers (59=Pref. Sample; 60=Full Sample)
NP=59;

% Weight Matrix (0=Diag weight matrix; 1= Optimal weight matrix)
OWM=0;

% Use parallel computing
Parallel=0;

% Bootstrap  to contruct weight matrix
BS=0;

% Unobserved heterogeneity in convexity parameter (1=yes; 0=Heterogeneity
% in b)
HetC=1;

% (1=reference point weighted average of expectations based reference point and reference point that adjusts to e1 but not e2)
CA=0;
CA_g=0;

% Cost of effort function (1=general polynomial; 0=quadratic)
Quad=0;

% Heterogeneity in lambda (0=lambda normally distributed; 1=common lambda)
Restrictive=0;

% Additive unobserved heterogeneity (1=additive; 0=unobservables in
% structural parameters)
Additive=0;

% Regret in addition to disappointment (0=No regret; 1=Regret permitted)
Regret=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load Experimental Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First Mover efforts
newData1 =importdata('e1.csv');
E1=newData1.data;
E1o=reshape(E1,10,[])';

% Second Mover efforts
newData1 = importdata('e2.csv');
E2=newData1.data;
E2o=reshape(E2,10,[])';

% Prizes
newData1 = importdata('prize.csv');
v=newData1.data;
V=reshape(v,10,[])';

if isequal(NP,59)
    E2o(21,:)=[];
    V(21,:)=[];
    E1o(21,:)=[];
end

R=10;

gamma=50;
MaxEffort=48;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parameter Search Bounds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[lb ub parameters]=bounds(Normal,HetC,CA,Quad,NP,Restrictive,Additive,Regret);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fix random draws
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

K=1;
rand('state',2947828324)
randn('state',435789237)
r_it_2=rand(NP,R,K);
r_i_2=rand(NP,K);
r_sigma_lambda=randn(NP,K);

% observed moments - to be matched
M_obs=moments(parameters,E1o,E2o,NP,R,V,gamma,MaxEffort,K,r_it_2,0,r_i_2,Normal,r_sigma_lambda);
[s1,s2]=size(M_obs);
omega=eye(s2);

% Bootstrapped covariance matrix (use only diagional elements)
rand('state',47828324)
E1o_sr=repmat(E1o,50,1);
E2o_sr=repmat(E2o,50,1);
V_sr=repmat(V,50,1);
BSR=2000;
M_s=zeros(BSR,s2);


User.E1o=E1o;
User.E2o=E2o;
User.NP=NP;
User.R=R;
User.V=V;
User.gamma=gamma;
User.MaxEffort=MaxEffort;
User.omega=omega;
User.K=K;
User.r_it_2=r_it_2;
User.M_obs=M_obs;
User.r_i_2=r_i_2;
User.sim=0;
User.Normal=Normal;
User.r_sigma_lambda=r_sigma_lambda;
User.HetC=HetC;
User.Quad=Quad;
User.CA=CA;
User.CA_g=CA_g;
User.Restrictive=Restrictive;
User.Additive=Additive;
User.Regret=Regret;

if isequal(BS,1)
    User.MS=ones(38,1);
    for k=1:BSR
        
        rr=rand(NP*50,1);
        
        E1o_s=[E1o_sr,rr];
        E1o_s=sortrows(E1o_s,11);
        E1o_s=E1o_s(1:NP,1:10);
        
        E2o_s=[E2o_sr,rr];
        E2o_s=sortrows(E2o_s,11);
        E2o_s=E2o_s(1:NP,1:10);
        
        V_s=[V_sr,rr];
        V_s=sortrows(V_s,11);
        V_s=V_s(1:NP,1:10);
        
        User.E1o=E1o_s;
        User.E2o=E2o_s;
        User.V=V_s;
        
        [j1,j2,M_s(k,:)]=msm_60(parameters,User);
    end
end
if isequal(BS,0) && isequal(NP,59)
    load('M_s')
elseif isequal(BS,0) && isequal(NP,60)
    load('M_s_60')
end

K=30;
User.E1o=E1o;
User.E2o=E2o;
User.V=V;
User.sim=1;
User.K=K;

rand('state',2947828324)
randn('state',435789237)
User.r_it_2=rand(NP,R,User.K);
User.r_i_2=rand(NP,User.K);
User.r_sigma_lambda=randn(NP,User.K);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Weight matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isequal(OWM,0)
    omega=inv(diag(diag(NP*cov(M_s))));
else
    omega=inv(NP*cov(M_s));
end
omega_all=inv(NP*cov(M_s));
User.omega=omega;
User.ub=ub;
User.lb=lb;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

MS=diag(omega).^.5;
User.MS=MS;
[sz,junk]=size(ub);
vm=(ub-lb);
Max=0; rt=.95; eps=0.001;
ns=4; nt=2;
neps=2;
maxevl=200*sz*ns*nt;
c=.2*ones(sz,1);
iprint=-5; seed=-1;
t=.1;


if isequal(Parallel,1)
    matlabpool open 4
    [parameters,fopt,nacc,nfcnev,nobds,ier,t_1,vm_1]=...
        psagio(@(parameters)msm_60(parameters,User),...
        parameters,Max,rt,eps,ns,nt,neps,maxevl,lb,ub,c,iprint,seed,t,vm);
    matlabpool close
else
    [parameters,fopt,nacc,nfcnev,nobds,ier,t_1,vm_1]=...
        sagio(@(parameters)msm_60(parameters,User),...
        parameters,Max,rt,eps,ns,nt,neps,maxevl,lb,ub,c,iprint,seed,t,vm);
end

% Compute post-estimation quantities
se
pe


