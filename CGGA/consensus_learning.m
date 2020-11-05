%
%% min sum_v{sum_i{||x_i - x_j||^2*s_ij + alpha*||s_i||^2} + w_v||U - Sv||^2
% s.t Sv>=0, 1^T*Sv_i=1, U>=0, 1^T*Ui=1
%
function [U, S0, S0_initial] = consensus_learning(X, normData, kneigh)
%% input:
% X{}: multi-view dataset, each cell is a view, each column is a data point
%% output:
% S0: similarity-induced graph (SIG) matrix for each view
% y: the final clustering result, i.e., cluster indicator vector
% U: the learned unified matrix
% evs: eigenvalues of learned graph Laplacian matrix

    NITER = 20;
    zr = 10e-11;
    pn = 15;% number of neighbours for constructS_PNG
    if exist('kneigh', 'var')
        pn = kneigh;
    end
    islocal = 1; % only update the similarities of neighbors if islocal=1
    if nargin < 2
        normData = 1;
    end

    num = size(X{1},2); % number of instances
    m = length(X); % number of views
    %% Normalization: Z-score
    if normData == 1
        for i = 1:m
            for  j = 1:num
                normItem = std(X{i}(:,j));
                if (0 == normItem)
                    normItem = eps;
                end;
                X{i}(:,j) = (X{i}(:,j)-mean(X{i}(:,j)))/(normItem);
            end;
        end;
    end;

    %% initialize S0: Constructing the SIG matrices
    S0 = cell(1,m);
    for i = 1:m
        [S0{i}, ~] = InitializeSIGs(X{i}, pn, 0);
    end;
    S0_initial = S0;

    %% initialize U, F and w
    U = zeros(num);
    for i = 1:m
        U = U + S0{i};
    end;
    U = U/m;
    for j = 1:num
        U(j,:) = U(j,:)/sum(U(j,:));
    end;
    w = ones(1,m)/m;

    idxx = cell(1,m);
    ed = cell(1,m);
    for v = 1:m
        ed{v} = L2_distance_1(X{v}, X{v});
        [~, idxx{v}] = sort(ed{v}, 2); % sort each row
    end;

    %%  update ...
    objValue = zeros(NITER, 1);
    for iter = 1 : NITER
        % update S^v
        for v = 1:m
            S0{v} = zeros(num);
            for i = 1:num
                id = idxx{v}(i,2:pn+2);
                di = ed{v}(i, id);
                numerator = di(pn+1)-di+2*w(v)*U(i,id(:))-2*w(v)*U(i,id(pn+1));
                denominator1 = pn*di(pn+1)-sum(di(1:pn));
                denominator2 = 2*w(v)*sum(U(i,id(1:pn)))-2*pn*w(v)*U(i,id(pn+1));
                S0{v}(i,id) = max(numerator/(denominator1+denominator2+eps),0);
            end
        end
        % update w
        for v = 1:m
            US = U - S0{v};
            distUS = norm(US, 'fro')^2;
            if distUS == 0
                distUS = eps;
            end
            w(v) = 0.5/sqrt(distUS);
        end;
        % disp(['weights: ',num2str(w)]);
        % update U
        U = zeros(num);
        for i = 1 : num
            idx = zeros();
            for v = 1 : m
                s0 = S0{v}(i,:);
                idx = [idx,find(s0>0)];
            end;
            idxs = unique(idx(2:end));
            if islocal == 1
                idxs0 = idxs;
            else
                idxs0 = 1:num;
            end;
            sumSJ = zeros(1, length(idxs0));
            for v = 1:m
                s1 = S0{v}(i,:);
                si = w(v) .* s1(idxs0);
                sumSJ = sumSJ + si;
            end;
            U(i,idxs0) = EProjSimplex_new(sumSJ / sum(w));
        end
        curValue = 0;
        for v = 1 : m
            curValue = curValue + w(v) * norm(U - S0{v}, 'fro');
            curValue = curValue + norm(S0{v}, 'fro')^2;
            curValue = curValue + sum(sum(ed{v} .* S0{v}));
        end
        objValue(iter) = curValue;
        if(iter > 1)
           diff = objValue(iter) - objValue(iter - 1);
           if diff <= zr
               fprintf('The algorithm has reached convergence at the %d-th iteration\n', iter);
               break;
           end
        end
    
    end
end


