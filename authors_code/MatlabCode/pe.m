%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reaction functions with bootstraped standard errors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

R=10;
K=1;
NP=500;
J=200;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%draw error terms
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

randn('state',348238904);
errors=randn(sz,J);

% person specific shocks fixed over boostraped replications
randn('state',348324326782)
rand('state',678632432)
r_it_2=rand(NP,R,K);
r_i_2=rand(NP,K);
r_sigma_lambda=zeros(NP,K,3);
e1=1;

[Med_Costs]=cost_fun(e1,parameters,NP,R,V,gamma,MaxEffort,r_it_2,r_i_2,Normal,HetC,CA,Quad,CA_g,Restrictive,Additive)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RF by lambda and prize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

r_sigma_lambda(:,:,2)=-.84*ones(NP,K);
r_sigma_lambda(:,:,3)=.84*ones(NP,K);

ME_plot=zeros(3,41,J,3);

for c=1:3
    for j=1:J
        j
        parametersE=parameters+chol(invhessian)'*errors(:,j);
        
        if isequal(Restrictive,0)
        if isequal(Normal,0)
            parametersE(12:17)=max(parametersE(12:17),0);
        else
            parametersE(13:14)=max(parametersE(13:14),0);
        end
        end
        if isequal(Restrictive,1)
            parametersE(11)=max(parametersE(11),1);
        end
        
        Mean_s=[];
        Mean_s=zeros(3,41,NP);
        for e1=0:40
            for v=1:3
                vc=v;
                if isequal(v,1)
                    vc=.1;
                end
                if isequal(v,2)
                    vc=2;
                end
                if isequal(v,3)
                    vc=3.9;
                end
                V_s=vc*ones(NP,R);
                E2o_s=simulation_60_2(e1,parametersE,NP,R,V_s,gamma,MaxEffort,r_it_2,r_i_2,1,Normal,r_sigma_lambda(:,:,c),HetC,CA,Quad,CA_g,Restrictive,Additive);
                E2o_s=reshape(E2o_s,[],10);
                Mean_s(v,e1+1,:)=reshape(E2o_s(:,5),1,1,[]);
            end
        end
        ME_plot(:,:,j,c)=mean(Mean_s,3);
    end
end



mME=mean(ME_plot,3);
mME_SE=var(ME_plot,0,3).^.5;

mME_mean=mME(:,:,1,1)
mME_20=mME(:,:,1,2)
mME_80=mME(:,:,1,3)

mME_SE_mean=mME_SE(:,:,1,1)
mME_SE_20=mME_SE(:,:,1,2)
mME_SE_80=mME_SE(:,:,1,3)

% test gradient of RF is zero (averagd over lambda)
G=ME_plot(:,2:41,:,1)-ME_plot(:,1:40,:,1);
mG=mean(G(:,22,:,1),3);
sdG=var(G(:,22,:,1),0,3).^.5;
t=mG./sdG;
RF=[mG,sdG,t]

% Test for gradient of RF zero, at low lambda
G=ME_plot(:,22,:,2)-ME_plot(:,21,:,2);
mG=mean(G(:,:,:,1),3);
sdG=var(G(:,:,:,1),0,3).^.5;
t=mG./sdG;
RF_low_lambda=[mG,sdG,t]

% Test for gradient of RF zero, at low lambda
G=ME_plot(:,22,:,3)-ME_plot(:,21,:,3);
mG=mean(G(:,:,:,1),3);
sdG=var(G(:,:,:,1),0,3).^.5;
t=mG./sdG;
RF_high_lambda=[mG,sdG,t]

r_it_2=rand(100000,1);
r_i_2=rand(100000,1);
for j=1:J
    j
    parametersE=parameters+chol(invhessian)'*errors(:,j);
    
    if isequal(Normal,0)
        parametersE(12:17)=max(parametersE(12:17),0);
        A1=parametersE(12);
        A2=parametersE(13);
        B1=parametersE(14);
        B2=parametersE(15);
        
        er1=A1*(-log(r_it_2)).^(1/B1);
        er2=(A2*(-log(r_i_2)).^(1/B2))*ones(1,R);
    end
    
    if isequal(Normal,1)
        parametersE(12:15)=max(parametersE(12:15),0);
        A1=parametersE(12);
        A2=parametersE(13);
        er1=A1*norminv(r_it_2);
        er2=(A2*norminv(r_i_2))*ones(1,R);
    end
    
    er1=min(er1,10);
    er2=min(er2,10);
    seit(j)=var(reshape(er1,[],1)).^.5;
    sei(j)=var(reshape(er2,[],1)).^.5;
end

mean(seit)
var(seit).^.5

mean(sei)
var(sei).^.5


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Monetary payoffs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


rand('state',2947828324)
randn('state',435789237)

e2a=[];
e2b=[];
c1=[];
c2=[];
Lambda=[];

for k=1:10
    r_it_2=rand(NP,R);
    r_i_2=rand(NP,1);
    r_sigma_lambda=randn(NP,1);
    
    [E2o_s,C1]=simulation_60(parameters,E1o,NP,R,V,gamma,MaxEffort,r_it_2,...
        r_i_2,Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive);
    c1=[c1;C1];
    
    lambda=(parameters(16)+r_sigma_lambda*parameters(17))*ones(1,R);
    Lambda=[Lambda;lambda];
    
    e2a=[e2a;E2o_s];
    
    parameters1=parameters;
    parameters1(16:17)=0;
    [E2o_s,C2]=simulation_60(parameters1,E1o,NP,R,V,gamma,MaxEffort,r_it_2,...
        r_i_2,Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive);
    c2=[c2;C2];
    e2b=[e2b;E2o_s];
   
end
 

P_win1=(e2a-repmat(E1o,10,1)+50)/100;
E_winnings1=mean(mean(P_win1.*repmat(V,10,1)));

P_win2=(e2b-repmat(E1o,10,1)+50)/100;
E_winnings2=mean(mean(P_win2.*repmat(V,10,1)));
 

C1=(25/2)*c1.*(e2a/50).^2+parameters(1)*e2a/50;
C2=(25/2)*c2.*(e2b/50).^2+parameters(1)*e2b/50;

U1=P_win1.*repmat(V,10,1)-Lambda.*P_win1.*(1-P_win1).*repmat(V,10,1)-C1;
U2=P_win2.*repmat(V,10,1)-C2;

% averaeg monetary loss (summed over 10 rounds)
E_winnings2-E_winnings1
mean(mean(U2-U1))
mean(100*mean((U2-U1)./(P_win1.*repmat(V,10,1))))



