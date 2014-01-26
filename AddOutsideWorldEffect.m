% function [augmentedSubGraphNet,subgraphParams] = AddOutsideWorldEffect(Net,subGraphNet,agent,neighbourhoodList,boundryNodesID,subgraphParams)
function [augmentedSubMatrixParams,subgraphParams] = AddOutsideWorldEffect(matrixParams,subMatrixParams,agent,neighbourhoodList,boundaryNodesID,subgraphParams)
% Add outside world effect ( adding the virtual nodes to the   subgraph)
% for each boundary node add a virtual node
% We are adding the virtual nodes to the end of the subMatrixParams,
% matrixParams
%             .muAds              -- matrix of size (params.numAds^2,1)
%             .Alpha_agentAd      -- matrix of size (1,1), constant 0.6
%             .Alpha_agents       -- matrix of size (params.numAgents,params.numAgents);
%             .Eps_agentAd        -- matrix of size (1,1), constant 0.4
%             .Eps_agents         -- matrix of size (params.numAgents,params.numAgents);
%             .P_agents           -- matrix of size (params.numAgents,params.numAgents);
%


%**** CHANGE 1 : Uncomment following line in case of having one virtual node for all boundry agents.
%In case of having one virtual node for each boundry node, the augmented matrix will become ill-conditioned. 
%numNodesToAdd = length(boundaryNodesID);

% Add one virtual node and connect it to all boundry nodes.
%**** CHANGE 1 : Comment following lines.
numNodesToAdd = length(boundaryNodesID);
%iVirtualNodeID = subgraphParams.numAgents + 1;


augmentedSubMatrixParams.P_agents = padarray(subMatrixParams.P_agents,[numNodesToAdd, numNodesToAdd],'post');
augmentedSubMatrixParams.Alpha_agents = padarray(subMatrixParams.Alpha_agents,[numNodesToAdd, numNodesToAdd],'post');
augmentedSubMatrixParams.Eps_agents = padarray(subMatrixParams.Eps_agents,[numNodesToAdd, numNodesToAdd],'post');
augmentedSubMatrixParams.Alpha_agentAd = subMatrixParams.Alpha_agentAd;
augmentedSubMatrixParams.Eps_agentAd = subMatrixParams.Eps_agentAd;
augmentedSubMatrixParams.muAds = subMatrixParams.muAds;

% set the in out out weight for each newly added node
for iBound = 1:numNodesToAdd                                          %**** CHANGE 1 : iBound = 1:numNodesToAdd
    
    % id of the boundary node
    ID = boundaryNodesID(iBound);
    
    neighbors = agent(ID).neighbors;
    
    % id of the outside neighbors
    outsideNeighbors = setdiff(neighbors,neighbourhoodList);
    
    % the ith virtual node ID is the i+total number of nodes in the subgraph
    %**** CHANGE1 : uncomment following line
    iVirtualNodeID = subgraphParams.numAgents + iBound;       
    
    % compute the in and out weights for the virtual node (sum of probabilities) for P_agents
    
    % The sum of the in weights should not get higher than 1
    numInWeightNeighbor_P = find(matrixParams.P_agents(outsideNeighbors,ID)~=0);
    P_agents.inWeight = sum(matrixParams.P_agents(outsideNeighbors,ID))/(length(numInWeightNeighbor_P)+eps);
    P_agents.outWeight = sum(matrixParams.P_agents(ID,outsideNeighbors));
    
    % compute the in and out weights for the virtual node (sum of probabilities) Alpha
    numInWeightNeighbor_Alpha = find(matrixParams.Alpha_agents(outsideNeighbors,ID)~=0);
    Alpha_agents.outWeight = sum(matrixParams.Alpha_agents(outsideNeighbors,ID))/(length(numInWeightNeighbor_Alpha)+eps);
    Alpha_agents.inWeight = sum(matrixParams.Alpha_agents(ID,outsideNeighbors));
    
    % compute the in and out weights for the virtual node (sum of probabilities) Eps
    numInWeightNeighbor_Eps = find (matrixParams.Eps_agents(outsideNeighbors,ID)~=0);
    Eps_agents.inWeight = sum(matrixParams.Eps_agents(outsideNeighbors,ID))/(length(numInWeightNeighbor_Eps)+eps);
    numOutWeightNeighbor_Eps = find( matrixParams.Eps_agents(ID,outsideNeighbors)~=0);
    Eps_agents.outWeight = sum(matrixParams.Eps_agents(ID,outsideNeighbors))/(length(numOutWeightNeighbor_Eps)+eps);
    
    % assign the computed values
    % CONNECT IT TO ALL FIRST WITH .1 OF THE WEIGHT
    augmentedSubMatrixParams.P_agents(:,iVirtualNodeID) = (1-P_agents.outWeight)/(size(augmentedSubMatrixParams.P_agents,1)-1);
    augmentedSubMatrixParams.P_agents(iVirtualNodeID,:) = (1-P_agents.inWeight)/(size(augmentedSubMatrixParams.P_agents,1)-1);
    % CONNECT IT TO THE AGENT WITH INDEX= ID WITH FULL WEIGHT
    augmentedSubMatrixParams.P_agents(ID,iVirtualNodeID) = P_agents.outWeight;
    augmentedSubMatrixParams.P_agents(iVirtualNodeID,ID) = P_agents.inWeight;
    augmentedSubMatrixParams.Alpha_agents(ID,iVirtualNodeID) = Alpha_agents.inWeight;
    augmentedSubMatrixParams.Alpha_agents(iVirtualNodeID,ID) = Alpha_agents.outWeight;
    augmentedSubMatrixParams.Eps_agents(ID,iVirtualNodeID) = Eps_agents.outWeight;
    augmentedSubMatrixParams.Eps_agents(iVirtualNodeID,ID) = Eps_agents.inWeight;
end;


% update the subgraph params
subgraphParams.numAgents = size(augmentedSubMatrixParams.P_agents,1);%subgraphParams.numAgents + numNodesToAdd;
subgraphParams.numTotal = subgraphParams.numAgents + subgraphParams.numAds;