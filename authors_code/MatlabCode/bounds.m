function [lb ub parameters]=bounds(Normal,HetC,CA,Quad,NP,Restrictive,Additive,Regret)

% Pref. Spec / OWM
if (Normal==0 && HetC==1 && CA==0 && Quad==0 && Regret==0)
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        .2
        .2
        1
        .5]
    
    
    ub=[-20
        2.5
        0
        0
        0
        0
        0
        0
        0
        0
        0
        .7
        .7
        1.5
        1.5
        3
        2.5]
end

if (Normal==0 && HetC==1 && CA==0 && Quad==0 && Regret==0)
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        .2
        .2
        1
        .5
        0
        -2]
    
    
    ub=[-20
        2.5
        0
        0
        0
        0
        0
        0
        0
        0
        0
        .7
        .7
        1.5
        1.5
        3
        2.5
        3
        2]
end


% 60 Second Movers
if (Normal==0 && HetC==1 && CA==0 && Quad==0 && NP==60 && Regret==0)
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        .2
        .2
        1
        .5]
    
    
    ub=[-20
        2.5
        0
        0
        0
        0
        0
        0
        0
        0
        0
        .6
        .6
        2
        2
        5
        3]
    
end

% Non Quad costs
if (Normal==0 && HetC==1 && CA==0 && Quad==1 && Regret==0)
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        .2
        .2
        1
        .5
        1.5]
    
    
    ub=[-10
        2.5
        0
        0
        0
        0
        0
        0
        0
        0
        0
        1
        1
        1
        1
        3
        2.5
        2.7]
end

% Normal Costs
if (Normal==1 && HetC==1 && CA==0 && Quad==0 && Regret==0)
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        1
        .5]
    
    
    ub=[-20
        3
        0
        0
        0
        0
        0
        0
        0
        0
        0
        .5
        .5
        4
        3]
end

% Choice Acclimiting
if (Normal==0 && HetC==1 && CA==1 && Quad==0 && Regret==0)
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        .2
        .2
        1
        .5
        0]
    
    
    ub=[-20
        2.5
        0
        0
        0
        0
        0
        0
        0
        0
        0
        .7
        .7
        1.5
        1.5
        3
        2.5
        1]
end

if (Normal==0 && HetC==1 && CA==1 && Quad==1 && Regret==0)
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        .2
        .2
        1
        .5
        0
        1.1]
    
    
    ub=[-20
        2.5
        0
        0
        0
        0
        0
        0
        0
        0
        0
        1
        1
        2
        2
        4
        2
        1
        3]
end


if Restrictive==1 && Additive==0 && Regret==0
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        ]
    
    
    ub=[-20
        3
        0
        0
        0
        0
        0
        0
        0
        0
        0
        1
        4.000
        ]
end


if Restrictive==1 && Additive==1 && Regret==0
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        ]
    
    
    ub=[-20
        3
        0
        0
        0
        0
        0
        0
        0
        0
        0
        8
        4
        ]
end


if (Normal==0 && HetC==1 && CA==0 && Quad==0 && Regret==1)
    
    lb=[-35
        1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        -1
        0
        0
        .2
        .2
        0
        0
        0]
    
    
    ub=[-20
        2.5
        0
        0
        0
        0
        0
        0
        0
        0
        0
        .7
        .7
        1.5
        1.5
        0
        0
        2]
end


% Starting Values
parameters=(ub+lb)/2;

parameters(3:11)=0;
