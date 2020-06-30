function Rho=v_corr(x,y)

m = size(x,1);
xc = x - sum(x)/m; % remove mean
yc = y - sum(y)/m;
Sigma = (xc' * yc) / (m-1);
sx = sqrt(sum(xc.^2) / (m-1)); % compute std dev
sy = sqrt(sum(yc.^2) / (m-1));
Rho = Sigma ./ (sx'*sy);