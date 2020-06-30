%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulate behavoral effect of disappointment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Run_real_data_60

parameters=[-26.899
    1.946
    -0.169
    -0.302
    -0.346
    -0.311
    -0.355
    -0.408
    -0.439
    -0.440
    -0.477
    0.333
    0.365
    1.055
    0.806
    1.729
    1.823];


rand('state',2947828324)
randn('state',435789237)
NP=59;

% Set number of simulated data sets
K=100;
r_it_2=rand(NP*K,R);
r_i_2=rand(NP*K,1);
r_sigma_lambda=randn(NP*K,1);

e1=repmat(E1o,K,1);
v=repmat(V,K,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Population average effects of disappointment aversion on effort and
% winnings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parameters(16)=0;
parameters(17)=0;
[E2o_s_lo]=simulation_60(parameters,e1,NP*K,R,v,gamma,MaxEffort,r_it_2,r_i_2,...
    Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive);
Win_P=(E2o_s_lo-e1+gamma)/(2*gamma);
Winnings_lo=Win_P.*v;

parameters(16)=1.729;
parameters(17)=1.823;
[E2o_s_hi]=simulation_60(parameters,e1,NP*K,R,v,gamma,MaxEffort,r_it_2,r_i_2,...
    Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive);
Win_P=(E2o_s_hi-e1+gamma)/(2*gamma);
Winnings_hi=Win_P.*v;

100*mean(mean(Winnings_hi-Winnings_lo))
mean(mean(E2o_s_hi-E2o_s_lo))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Effects of disappointment aversion on effort and winnings conditional on
% e1 and the prize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

e1_eval=[0 25 40];
v_eval=[.1 2 3.9];

DE2=zeros(9,1);
DWinnings=zeros(9,1);
d=1;
for j=1:3
    v(:,:)=v_eval(j);
    for k=1:3
        e1(:,:)=e1_eval(k);
        
        
        % Simulate efforts
        parameters(16)=.2;
        parameters(17)=0;
        [E2o_s_lo]=simulation_60(parameters,e1,NP*K,R,v,gamma,MaxEffort,r_it_2,r_i_2,...
            Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive);
        Win_P=(E2o_s_lo-e1+gamma)/(2*gamma);
        Winnings_lo=mean(mean(Win_P.*v));
       
        
        
        parameters(16)=3.26;
        parameters(17)=0;
        [E2o_s_hi]=simulation_60(parameters,e1,NP*K,R,v,gamma,MaxEffort,r_it_2,r_i_2,...
            Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive);
        Win_P=(E2o_s_hi-e1+gamma)/(2*gamma);
        Winnings_hi=mean(mean(Win_P.*v));
        
        
        
        DE2(d)=mean(mean(E2o_s_hi-E2o_s_lo))/mean(mean(E2o_s_lo));
        DWinnings(d)=(Winnings_hi-Winnings_lo)/Winnings_lo;
        
        d=d+1;
        
    end
end

DE2=100*DE2
DWinnings=100*DWinnings
