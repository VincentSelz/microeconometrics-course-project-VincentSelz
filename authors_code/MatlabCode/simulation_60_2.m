function [E2o_s]=simulation_60_2(e1,parameters,NP,R,V,gamma,MaxEffort,r_it_2,...
    r_i_2,cond,Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive)

if (Normal==0 && HetC==1 && CA==0 && Quad==0)
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    B1=parameters(14);
    B2=parameters(15);
    lambda=parameters(16);
    sigma_lambda=parameters(17);
    weight=1;
    eta=2;
    g=0;
end

if (Normal==1 && HetC==1 && CA==0 && Quad==0)
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    lambda=parameters(14);
    sigma_lambda=parameters(15);
    weight=1;
    eta=2;
    g=0;
end


if (Normal==0 && HetC==1 && CA==0 && Quad==1)
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    B1=parameters(14);
    B2=parameters(15);
    lambda=parameters(16);
    sigma_lambda=parameters(17);
    weight=1;
    eta=parameters(18);
    g=0;
end

if (Normal==0 && HetC==1 && CA==1 && Quad==0 && Restrictive==0)
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    B1=parameters(14);
    B2=parameters(15);
    lambda=parameters(16);
    sigma_lambda=parameters(17);
    eta=2;
    weight=parameters(18);
    g=CA_g;
end

if (Normal==0 && HetC==1 && CA==1 && Quad==1)
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    A2=parameters(13);
    B1=parameters(14);
    B2=parameters(15);
    lambda=parameters(16);
    sigma_lambda=parameters(17);
    weight=parameters(18);
    eta=parameters(19);
    g=CA_g;
end

if Restrictive==1
    beta=parameters(1);
    c_tt=parameters(2:11);
    A1=parameters(12);
    lambda=parameters(13);
    sigma_lambda=0;
    weight=1;
    eta=2;
    g=0;
end

if isequal(Normal,0) && isequal(Restrictive,0)
    er1=A1*(-log(r_it_2)).^(1/B1);
    er2=(A2*(-log(r_i_2)).^(1/B2))*ones(1,R);
end

if isequal(Normal,1) && isequal(Restrictive,0)
    er1=A1*norminv(r_it_2);
    er2=(A2*norminv(r_i_2))*ones(1,R);
end

if isequal(Restrictive,1)
    er1=A1*norminv(r_it_2);
    er2=zeros(NP,R);
end

if isequal(HetC,1) && isequal(Additive,0)
    C=(ones(NP,10)*c_tt(1)+ones(NP,1)*[0 c_tt(2:10)']+er1+er2);
    C=max(C,0.0001);
    C=reshape(C,[],1);
    beta2_r=reshape(beta*ones(NP,R),[],1);
    
else
    if isequal(Additive,0)
        C=(ones(NP,10)*c_tt(1));
        C=max(C,0.0001);
        C=reshape(C,[],1);
    else
        C=(ones(NP,10)*c_tt(1)+ones(NP,1)*[0 c_tt(2:10)']);
        C=max(C,0.0001);
        C=reshape(C,[],1);
    end
    
    if isequal(Additive,0)
        beta2_r=reshape(beta*ones(NP,R)+ones(NP,1)*[0 c_tt(2:10)']+er1+er2,[],1);
    else
        beta2_r=reshape(beta*ones(NP,R),[],1);
    end
end


V_r=reshape(V,[],1);

lambda=lambda+sigma_lambda*r_sigma_lambda;
lambda=lambda*ones(1,R);
lambda=reshape(lambda,[],1);

if isequal(cond,1)
    E1o_s=e1*ones(NP*R,1);
else
    E1o_s=e1';
end

% Simulate optimal second mover efforts
E2o_s=BR2_60(E1o_s,gamma,MaxEffort,V_r,beta2_r,lambda,C,NP*R,eta,weight,g);




