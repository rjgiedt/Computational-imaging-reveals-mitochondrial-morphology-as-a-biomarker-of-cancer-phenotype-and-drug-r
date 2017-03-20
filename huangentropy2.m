function [ T, threshold ] = huangentropy2( img1 )
%Threshold using Huang method
tic
img1 = double(img1); %convert image format so algebraic manipulations are error free
img1a = img1(:);
a = size(img1);

% number of levels in image
gmin = min(img1a); gmax = max(img1a);
L = gmax - gmin + 1;
values = hist(img1a, L); %histogram of gray levels

stot = sum(values(1:L));
wtot = sum(values(1:L).*(linspace(gmin,gmax,L)));

% storage arrays
threshweights = zeros(5,L);
targets = zeros(2,L);
threshweights(:,1) = [0; stot; 0; wtot; gmin-1];
entropy = zeros(1,L);

% iterations - need to use for loop here as each iteration depends on
% previous.  k=1 corresponds to a threshold of gmin-1 (it's only used to
% generate the first iteration)
for k = 1 : L-1 
    %k
    
    threshweights(1,k+1) = threshweights(1,k) + values(1,k); % S(t)
    threshweights(2,k+1) = stot - threshweights(1,k+1); % S_bar(t)
    threshweights(3,k+1) = threshweights(3,k) + values(1,k)*(gmin+(k-1)); % W(t)
    threshweights(4,k+1) = wtot - threshweights(3,k+1); % W_bar(t)
    threshweights(5,k+1) = threshweights(5,k) + 1; %threshold level
    
    %targets for membership function - Note that I don't round uo and u1 as is done
    %in the paper
    targets(1,k+1) = (threshweights(3,k+1)/threshweights(1,k+1)); % This is u0 in the paper
    targets(2,k+1) = (threshweights(4,k+1)/threshweights(2,k+1)); % This is u1 in the paper
end

% the next set of processes are for calculating the entropy.  These don't
% depend on previous iterations so use parfor
targets_sliced1 = targets(1,:);
targets_sliced2 = targets(2,:);
parpool
parfor k = 1 : L-1
    
    %k
    ux1 = 1./(1.+abs(img1((img1 <= threshweights(5,k+1)))-targets_sliced1(1,k+1))/(L-1)); % membership fn.
    ux2 = 1./(1.+abs(img1((img1 > threshweights(5,k+1)))-targets_sliced2(1,k+1))/(L-1)); % membership fn.
    
    % shannon's entropy
    %ux1b = find(ux1~=1);
    %su1 = sum(-ux1(ux1b).*log(ux1(ux1b))-(1-ux1(ux1b)).*log(1-ux1(ux1b)));
    %ux2b = find(ux2~=1);
    %su2 = sum(-ux2(ux2b).*log(ux2(ux2b))-(1-ux2(ux2b)).*log(1-ux2(ux2b)));
    
    
    % yager's measure calculation, use p = 2
    dp1 = (2.*ux1-1).*(2.*ux1-1); 
    dp2 = (2.*ux2-1).*(2.*ux2-1);
    dp = sqrt(sum(dp1)+sum(dp2));

    entropy(1,k+1) = 1-(dp)/sqrt(a(1)*a(2));
end

[min_ent,ind] = min(entropy(1,2:end));
T = img1 > threshweights(5,ind);
threshold = threshweights(5,ind);
matlabpool close
toc
end                

