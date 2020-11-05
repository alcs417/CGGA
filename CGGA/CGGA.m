function [idx_eg, idx_rc] = CGGA(X)

    v = length(X);
    layers = 2;     % number of layers to stack, 3 for cora 
%     projev = 1.5;
    k = 15;
    S = cell(v, 1);
    %% Data Normalization
    for i = 1 : v
        X{i} = NormalizeFea(X{i}, 0); % unit norm
        % Initialize each view
        [S{i}, ~] = InitializeSIGs(X{i}, k);
    end
    ZZ = cell(v, 1);
    NITER = 3;
    for i = 1:NITER
        fprintf('======================================\n');
        disp('create A_n');
        %create A_bar for each view
        for j = 1 : v
            n = size(X{j}, 2); % X{j} is d*n;
            A_bar = S{j} + speye(n);
            d = sum(A_bar);
            d_sqrt = 1.0./sqrt(d);
            d_sqrt(d_sqrt == Inf) = 0;
            DH = diag(d_sqrt);
            DH = sparse(DH);
            A_n = DH * sparse(A_bar) * DH;   %d*d
            fprintf('compute A_n finished for the %-th view', j);

            gcn = A_n * X{j}';   % n*n * n*d
            [~, m] = size(gcn);

            [allhx] = GAE(X{j}, layers, A_n);
            Z0 = allhx(end - m + 1 : end, :);
            ZZ{j} = Z0;
    %         Z1 = Z0' * Z0;
    %         ZZ{j} = (abs(Z1) + abs(Z1'))/2;
        end

        [U, S, ~] = consensus_learning(ZZ, 0, k);

    end
    NUMC = 2 : 15;
    [K1, ~, K12, ~] = Estimate_Number_of_Clusters_given_graph(U, NUMC);
    fprintf('The number of clusters estimated by eigen gap : %d\n', K1);
    idx_eg = computeLabels(U, K1);
    fprintf('The number of clusters estimated by rotation cost : %d\n', K12);
    idx_rc = computeLabels(U, K12);

end

function idx = computeLabels(T, k)
    Z = (abs(T) + abs(T')) / 2;
    idx = clu_ncut(Z, k);
end