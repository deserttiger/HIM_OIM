function [newMatrixParams,newAgent,newParams,numInfluentialNodes] = UpdateHeirarchy(listOfInfluentialNodes,matrixParams,agent,params,D)
% Updates the hierarchy by computing a new Net new agent and a new
% matrixParams based on the selected influential nodes.
%   - if (the list of influential nodes is empty) 
%       the matrixParams and agent are the same as the input
%   - else 
%       - the Net and graphConnectivity are computed based on directional
%       shortest path between each influential node. That means the
%       inWeight and outWeight are computed from two directional subgraphs.
%       - agent is updated using the computed graph
%
% Input:
%      listOfInfluentialNodes -- is a cell with params.numAds elements. Each
%                                contains the ID of the agents in the current hierarchy that are selected
%                                as influential
%       D                       -- shortestpath for all the nodes in logarithm form
% Output:
% matrixParams
%             .muAds              -- matrix of size (params.numAds^2,1)
%             .Alpha_agentAd      -- matrix of size (1,1), constant 0.6
%             .Alpha_agents       -- matrix of size (params.numAgents,params.numAgents);
%             .Eps_agentAd        -- matrix of size (1,1), constant 0.4
%             .Eps_agents         -- matrix of size (params.numAgents,params.numAgents);
%             .P_agents           -- matrix of size (params.numAgents,params.numAgents);
%

% if (the list of influential nodes is empty) %
if isempty([listOfInfluentialNodes{:}]) || length(unique([listOfInfluentialNodes{:}])) <2
    newMatrixParams = matrixParams;
    newAgent = agent;
    newParams = params;
    numInfluentialNodes = 0;
    return;   
end;

USE_FIXED_ALPHA = true;


%% We have a list of influential node
% Make a list of nodes based on the influential node. If a node is selected
% once for any of the products we will use them in the next level.
% TODO: Consider the relation of the product to the selected node and change
% the related node importance probability (rho) in the optimization accordingly
listOfNodes = unique([listOfInfluentialNodes{:}]);
numInfluentialNodes = length(listOfNodes);
% update the paramters
newParams = params;
newParams.numAgents = length(listOfNodes);
newParams.numTotal = newParams.numAgents + newParams.numAds;

spP_agents = sparse(matrixParams.P_agents);
% compute shortest path in a directed graph (default DirectedValue is true)
% 'Dijkstra' — Default algorithm
%TODO: understand the meaning of the shortest path in this. 
%TODO: how to compute the new Net based on the shortest path, Net contains
%the interactions 
lg_Main.P_agents = -spfun(@log,matrixParams.P_agents);
lg_Main.Alpha_agents = -spfun(@log,matrixParams.Alpha_agents);
lg_Main.Eps_agents = -spfun(@log,matrixParams.Eps_agents);%lg_Main.P_agents =  -log(matrixParams.P_agents);
% lg_Main.Alpha_agents =  -log(matrixParams.Alpha_agents);
% lg_Main.Eps_agents =  -log(matrixParams.Eps_agents);
n  = size(lg_Main.Alpha_agents,1);
P_agents = zeros(newParams.numAgents);
Alpha_agents = zeros(newParams.numAgents);
Eps_agents =  zeros(newParams.numAgents);
% 

if (USE_FIXED_ALPHA)
    
    Alpha_agents = repmat(.7./(sum(D(listOfNodes,listOfNodes),2)+eps),1,newParams.numAgents);
    P_agents = 1./(spfun(@exp,D(listOfNodes,listOfNodes))+eps);
    Eps_agents = Eps_agents*0+.25;
else
    for iNode = 1:length(listOfNodes)
        fprintf('shortest path of Node #%d/%d\r\n',iNode,length(listOfNodes));
        [dist, path, pred]= graphshortestpath(-spfun(@log,spP_agents),listOfNodes(iNode),listOfNodes);
        for iPath = 1:length(path)
            % P_agents of this path is already computed in dist
            if iNode==iPath
                continue;
            end;
            P_agents(iNode,iPath) = 1./spfun(@exp,dist(iPath));
            pt = path{iPath};
            pt_next = circshift(pt,[0 -1]);
            inds  = sub2ind([n,n],pt(1:end-1),pt_next(1:end-1));
            
            if ~isempty(inds)
                % now find the log of alphas
                logAlphas = sum(lg_Main.Alpha_agents(inds));
                Alpha_agents(iNode,iPath) =  1/exp(logAlphas);
                
                % now find the log of EPS
                logEps = sum(lg_Main.Eps_agents(inds));
                Eps_agents(iNode,iPath) =  .25;%1/exp(logEps);
            end;
        end;
    end;
end ; % end USE_FIXED_ALPHA
Alpha_agents = Alpha_agents./repmat(eps+sum(Alpha_agents,2),1,size(Alpha_agents,2));
P_agents = P_agents./repmat(eps+sum(P_agents,1),size(P_agents,1),1);

newMatrixParams = matrixParams;
newMatrixParams.Alpha_agents = Alpha_agents;
newMatrixParams.P_agents = P_agents;
newMatrixParams.Eps_agents = Eps_agents;

% make the agent using the previous agent and the parameters (the high level agent
% don't have inward outward degree and weights
originalID = [agent(listOfNodes).id];
newAgent = InitiateHighAgents(agent,originalID,listOfNodes,newParams,params);

