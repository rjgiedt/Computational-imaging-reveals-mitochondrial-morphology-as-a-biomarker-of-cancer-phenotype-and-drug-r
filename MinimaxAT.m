function [B,T] = MinimaxAT(I)
% I: input image
% B: thresholded image
% T: Threshold surface
% implements a line search

Iterations = 40; % increase if it is inadequate
epsilon=1e-10; % for termination condition, decrease if it is inadequate

pow=.4; % although 1 is a pretty good value, 
       % you may need to play with this parameter, pow takes POSITIVE real values

I = double(I);
% linearly map I to the range [0, 1]
I(:) = (I-min(I(:)))/(max(abs(I(:)))-min(I(:)));

% display I
figure(1),imagesc(I),colormap(gray);axis image; drawnow;

[h,w] = size(I);
rowC = 1:h;         rowN = [1 1:h-1];    rowS = [2:h h];
colC = 1:w;         colE = [1 1:w-1];    colW = [2:w w];

Ix = (I(rowC,colW) - I(rowC,colE))/2; Ix(:,1) = 0; Ix(:,end) = 0;
Iy = (I(rowS,colC) - I(rowN,colC))/2; Iy(1,:) = 0; Iy(end,:) = 0;

% [Ix,Iy] = gradient(I);
g = (Ix.^2+Iy.^2).^(pow/2);
g(:) = g/max(g(:));

% initialize threhold surface
T=zeros(h,w);
Tx = T;
Ty = T;
delT=T;
delTx=T;
delTy=T;

figure(2),set(gcf,'doublebuffer','on');
old_alpha=10;
for n=1:Iterations,
    % compute alpha
    Tx(:) = (T(rowC,colW) - T(rowC,colE))/2; Tx(:,1) = 0; Tx(:,end) = 0;
    Ty(:) = (T(rowS,colC) - T(rowN,colC))/2; Ty(1,:) = 0; Ty(end,:) = 0;
%     [Tx,Ty] = gradient(T);
    en1 = 0.5*sum(sum(g.*(T-I).^2));
    en2 = 0.5*sum(sum(Tx.^2+Ty.^2));
    alpha = en2/sqrt(en1^2+en2^2);
    
    % line search
    delT(:) = sqrt(1-alpha^2)*g.*(I-T) + alpha*(T(rowC,colW)+T(rowC,colE)+T(rowN,colC)+T(rowS,colC)-4*T);
    delTx(:) = (delT(rowC,colW) - delT(rowC,colE))/2; delTx(:,1) = 0; delTx(:,end) = 0;
    delTy(:) = (delT(rowS,colC) - delT(rowN,colC))/2; delTy(1,:) = 0; delTy(end,:) = 0;
%     [delTx,delTy] = gradient(delT);
    
    e2 = sqrt(1-alpha^2)*sum(sum(g.*(I-T).*delT)) - alpha*sum(sum(Tx.*delTx + Ty.*delTy));
    e3 = sqrt(1-alpha^2)*sum(sum(g.*delT.*delT)) + alpha*sum(sum(delTx.*delTx + delTy.*delTy));
    
    % delt should at least be 0.25
    % minimize a quadratic expression: e1 - delt*e2 + 0.5*delt*delt*e3, see
    % the journal paper
    delt = max(0.25,e2/e3); 
    
    T(:) = T+delt*delT;
    % show
    figure(2),imagesc(I>T),colormap(gray);axis image;
    title(['Iteration: ' num2str(n) ' alpha: ' num2str(alpha)]);
    drawnow;
    
    if abs(old_alpha-alpha)<=epsilon,
        break;
    end
    old_alpha=alpha;
end
B = I>T;
% figure(3),imagesc(T),colormap(gray);axis image;