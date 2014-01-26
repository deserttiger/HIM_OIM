% function [subGraphNet,subGraphConnectivity,subgraphParams] = MakeSubgraph(Net,graphConnectivity,neighbourhoodList,params)
function [subMatrixParams,subgraphParams] = MakeSubgraph(matrixParams,listOfNodes,params,D)
% Make the subgraph from the neighbourhoodList
% matrixParams
%             .muAds              -- matrix of size (params.numAds^2,1)
%             .Alpha_agentAd      -- matrix of size (1,1), constant 0.6
%             .Alpha_agents       -- matrix of size (params.numAgents,params.numAgents);
%             .Eps_agentAd        -- matrix of size (1,1), constant 0.4
%             .Eps_agents         -- matrix of size (params.numAgents,params.numAgents);
%             .P_agents           -- matrix of size (params.numAgents,params.numAgents);
%

if (length(listOfNodes)>params.maxSubSampleNeighborhood)
    shuffled = randperm(length(listOfNodes));
    neighbourhoodList = listOfNodes(shuffled(1:params.maxSubSampleNeighborhood));
else
    neighbourhoodList = listOfNodes ;
end;
P_agents = 1./(spfun(@exp,D(neighbourhoodList,neighbourhoodList))+eps);

subMatrixParams.P_agents = P_agents;%matrixParams.P_agents(neighbourhoodList,neighbourhoodList) ;
subMatrixParams.Alpha_agents = matrixParams.Alpha_agents(neighbourhoodList,neighbourhoodList) ;
subMatrixParams.Eps_agents = matrixParams.Eps_agents(neighbourhoodList,neighbourhoodList) ;
subMatrixParams.Alpha_agentAd = matrixParams.Alpha_agentAd;
subMatrixParams.Eps_agentAd = matrixParams.Eps_agentAd;
subMatrixParams.muAds = matrixParams.muAds;


% copy the params and update the modified fields
subgraphParams = params;
subgraphParams.numAgents = length(neighbourhoodList);
subgraphParams.numTotal = subgraphParams.numAgents + subgraphParams.numAds;
