function [U_OIM,isValidOIM]  = OIMAlgorithm(params, matrixParams, M)

[Q_mat,A,B_coef,W_coef,HasInverse] = GenerateQ(params{1},M,matrixParams{1});
isValidOIM = HasInverse;
isSubgraph = false;
try
    [tags,U_OIM,U_OIMContinious]= tagInfluentialNodesGLPK(W_coef,M,A,matrixParams{1},params{1},isSubgraph,[]);
catch
    isValidOIM = false;
    U_OIM = zeros(numAds, numAgents);
end;
