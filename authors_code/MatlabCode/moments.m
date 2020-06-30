function [M]=moments(parameters,E1o_s,E2o,NP,R,V_s,gamma,MaxEffort,K,r_it_2,sim,r_i_2,Normal,r_sigma_lambda,HetC,CA,Quad,CA_g,Restrictive,Additive,Regret)

S2=(1:1:NP)'*ones(1,10);
S2=reshape(S2',[],1);

vr=reshape(V_s',[],1);
e1r=reshape(E1o_s',[],1);

T2=[zeros(NP,1),ones(NP,1),zeros(NP,8)];
T3=[zeros(NP,2),ones(NP,1),zeros(NP,7)];
T4=[zeros(NP,3),ones(NP,1),zeros(NP,6)];
T5=[zeros(NP,4),ones(NP,1),zeros(NP,5)];
T6=[zeros(NP,5),ones(NP,1),zeros(NP,4)];
T7=[zeros(NP,6),ones(NP,1),zeros(NP,3)];
T8=[zeros(NP,7),ones(NP,1),zeros(NP,2)];
T9=[zeros(NP,8),ones(NP,1),zeros(NP,1)];
T10=[zeros(NP,9),ones(NP,1),zeros(NP,0)];
T2=reshape(T2',[],1);
T3=reshape(T3',[],1);
T4=reshape(T4',[],1);
T5=reshape(T5',[],1);
T6=reshape(T6',[],1);
T7=reshape(T7',[],1);
T8=reshape(T8',[],1);
T9=reshape(T9',[],1);
T10=reshape(T10',[],1);

% simulate data - replicate K times

pe1=zeros(K,1);
pe2=zeros(K,1);
pe3=zeros(K,1);
pe4=zeros(K,1);
pe5=zeros(K,1);

pg1=zeros(K,1);
pg2=zeros(K,1);
pg3=zeros(K,1);
pg4=zeros(K,1);
pg5=zeros(K,1);

ph1=zeros(K,1);
ph2=zeros(K,1);
ph3=zeros(K,1);
ph4=zeros(K,1);
ph5=zeros(K,1);

m1_2=zeros(K,1);
m3_2=zeros(K,1);
m2_2=zeros(K,1);
m4_2=zeros(K,1);
pm1=zeros(K,1);
pm2=zeros(K,1);
pm3=zeros(K,1);
m1=zeros(K,1);
m2=zeros(K,1);
m3=zeros(K,1);
m4=zeros(K,1);
m5=zeros(K,1);
m6=zeros(K,1);


for k=1:K
    
    if isequal(sim,1)
         [E2o_s]=simulation_60(parameters,E1o_s,NP,R,V_s,gamma,MaxEffort,r_it_2(:,:,k),r_i_2(:,k),Normal,r_sigma_lambda(:,k),HetC,CA,Quad,CA_g,Restrictive,Additive,Regret);
        e2r=reshape(E2o_s',[],1);
    else
       
        E2o_s=E2o;
        e2r=reshape(E2o_s',[],1);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Moments for variance
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % standard deviaton of e2 - pooled
    m1_2(k,1)=var(e2r).^.5;
    
    % 1st order autocorrelation - pooled
    m2_2(k,1)=corr(reshape(E2o_s(:, 2:R),[],1),reshape(E2o_s(:, 1:R-1),[],1),'rows','complete');
    
    % 2nd order autocorrelation (pooled)
    m3_2(k,1)=corr(reshape(E2o_s(:, 3:R),[],1),reshape(E2o_s(:, 1:R-2),[],1),'rows','complete');
    
    % sd of d.e (pooled)
    m4_2(k,1)=nanvar(reshape(E2o_s(:, 2:R)-E2o_s(:, 1:R-1),[],1)).^.5;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Moments for level and time effects
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    m6_2(k,:)=nanmean(E2o_s);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Moments for distribution of e2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %    individual specific correlations of e2 with v conditional on Period
    ee=zeros(NP,1);
    gg=zeros(NP,1);
    hh=zeros(NP,1);
    for j=1:NP
        
        xr=[(1:1:10)',ones(10,1)];
        b=(xr'*xr)\(xr'*E2o_s(j,:)');
        E2r=E2o_s(j,:)'-xr*b;
        
        b=(xr'*xr)\(xr'*V_s(j,:)');
        Vr=V_s(j,:)'-xr*b;
        
        b=(xr'*xr)\(xr'*E1o_s(j,:)');
        E1r=E1o_s(j,:)'-xr*b;
        
        b=(xr'*xr)\(xr'*(V_s(j,:)'.*E1o_s(j,:)'));
        Ir=V_s(j,:)'.*E1o_s(j,:)'-xr*b;
        
        ee(j)=v_corr(E2r,Vr);
        gg(j)=v_corr(E2r,E1r);
        hh(j)=v_corr(E2r,Ir);
        
    end
    
    ee=sortrows(ee);
    gg=sortrows(gg);
    hh=sortrows(hh);
    
    pe1(k,1)=ee(round(NP/6));
    pe2(k,1)=ee(round(NP/3));
    pe3(k,1)=ee(round(3*NP/6));
    pe4(k,1)=ee(round(2*NP/3));
    pe5(k,1)=ee(round(5*NP/6));
    
    pg1(k,1)=gg(round(NP/6));
    pg2(k,1)=gg(round(NP/3));
    pg3(k,1)=gg(round(3*NP/6));
    pg4(k,1)=gg(round(2*NP/3));
    pg5(k,1)=gg(round(5*NP/6));
    
    ph1(k,1)=hh(round(NP/6));
    ph2(k,1)=hh(round(NP/3));
    ph3(k,1)=hh(round(3*NP/6));
    ph4(k,1)=hh(round(2*NP/3));
    ph5(k,1)=hh(round(5*NP/6));
    
    % conditional correlation with prize
    bb=pfixed([e2r,e1r.*vr,e1r,T2,T3,T4,T5,T6,T7,T8,T9,T10],S2);
    Re2=bb.resid;
    bb=pfixed([vr,e1r.*vr,e1r,T2,T3,T4,T5,T6,T7,T8,T9,T10],S2);
    Rv=bb.resid;
    pm1(k,1)=v_corr(Re2,Rv);
    
    % conditional correlation with e1
    bb=pfixed([e2r,e1r.*vr,vr,T2,T3,T4,T5,T6,T7,T8,T9,T10],S2);
    Re2=bb.resid;
    bb=pfixed([e1r ,e1r.*vr,vr,T2,T3,T4,T5,T6,T7,T8,T9,T10],S2);
    Re1=bb.resid;
    pm2(k,1)=v_corr(Re2,Re1);
    
    % conditional correlation with interaction
    bb=pfixed([e2r,e1r,vr,T2,T3,T4,T5,T6,T7,T8,T9,T10],S2);
    Re2=bb.resid;
    bb=pfixed([e1r.*vr ,e1r,vr,T2,T3,T4,T5,T6,T7,T8,T9,T10],S2);
    Re1v=bb.resid;
    pm3(k,1)=v_corr(Re2,Re1v);
    

    ii=find(sign(reshape(E1o_s,[],1)-23)==1 | sign(reshape(V_s,[],1)-1.35)==1);
    e2=reshape(E2o_s,[],1);
    e2(ii)=[];
    m1(k,1)=nanmean(e2);
    
    
    ii=find(sign(reshape(E1o_s,[],1)-23)==1 | sign(reshape(V_s,[],1)-2.55)==-1);
    e2=reshape(E2o_s,[],1);
    e2(ii)=[];
    m2(k,1)=nanmean(e2);
    
    ii=find(sign(reshape(E1o_s,[],1)-28)==-1 | sign(reshape(V_s,[],1)-1.35)==1);
    e2=reshape(E2o_s,[],1);
    e2(ii)=[];
    m3(k,1)=nanmean(e2);
    
    ii=find(sign(reshape(E1o_s,[],1)-28)==-1 | sign(reshape(V_s,[],1)-2.55)==-1);
    e2=reshape(E2o_s,[],1);
    e2(ii)=[];
    m4(k,1)=nanmean(e2);
    
    ii=sign(e2r-15)==-1;
    m5(k,1)=mean(ii);
    
    ii=sign(e2r-35)==1;
    m6(k,1)=mean(ii);
    
end

%stack moments
M=[m1_2,m2_2,m3_2,m4_2,m6_2,pm1 pm2 pm3,pe1 pe2 pe3 pe4 pe5,pg1 pg2 pg3 pg4...
    pg5,ph1 ph2 ph3 ph4 ph5,m1 m2 m3 m4 m5 m6];

M(isnan(M))=0;
M=mean(M,1);




