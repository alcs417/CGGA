function result = computeClustLabel(T, gnd, rep)

    nCluster = length(unique(gnd));
    Z = (abs(T) + abs(T')) / 2;
    idx = clu_ncut(Z, nCluster);
    result = ClusteringMeasure(gnd, idx);
    
    % multiple runs
%     accAvg=0;
%     for j = 1 : rep
%         idx = clu_ncut(Z,nCluster);
%         acc = compacc(idx,gnd); 
%         accAvg = accAvg+acc;
%     end
%     accAvg = accAvg/rep;

end