function [neighbourhoodList,boundaryNodesID] = FindNeighbourhood(agent,iNode,params)
%       % Find the neighbourhood N around current node ID

currentNodes = iNode;
selectedNodesVec = iNode;
numSelectedNodes = length (selectedNodesVec);
neighbourhoodRadius = 0 ;

while ( (neighbourhoodRadius< params.neighbourhoodRadius) ...
        &&(numSelectedNodes < params.numAgents) ...
        && (numSelectedNodes < params.maxNumNeighborhood))
%         && (numSelectedNodes < params.numAds * params.adBudget) ...
        
    neighborsId = [];
    %TODO: I think that this neighborsId should not get earased here! It
    %will earase all the neighbors we had so far! 
    for i = 1:length (currentNodes)
        neighborsId = cat(2,neighborsId,agent(currentNodes(i)).neighbors);
    end % END i
    
    % unique set of neighbors
    currentNodes = unique (neighborsId);
    
    % make sure we've not visited any of the neighbors before
    currentNodes = setdiff(currentNodes,selectedNodesVec);
    
%     % make sure the number of nodes is less than or equal to params.numAds * params.adBudget
%     if length(currentNodes)+length(selectedNodesVec) >params.numAds * params.adBudget
%         currentNodes =  currentNodes(1:params.numAds * params.adBudget- length(selectedNodesVec));
%     end;
    if length(currentNodes)+length(selectedNodesVec) >params.maxNumNeighborhood
        currentNodes =  currentNodes(1:params.maxNumNeighborhood - length(selectedNodesVec));
    end;
    selectedNodesVec = union (currentNodes, selectedNodesVec );

    numSelectedNodes = length (selectedNodesVec);
    neighbourhoodRadius = neighbourhoodRadius  + 1;
    
end % END While
neighbourhoodList= selectedNodesVec;
boundaryNodesID = FindBoundaryNodes (agent, neighbourhoodList);

