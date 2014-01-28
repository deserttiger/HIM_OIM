function boundaryNodesID = FindBoundaryNodes (agent, neighbourhoodList)

numNoConnection = 0 ;
noConnectionList = [];
boundaryNodesID = neighbourhoodList;
for iBound = 1:length(neighbourhoodList)
    
    % id of the boundary node
    ID = neighbourhoodList(iBound);

    neighbors = agent(ID).neighbors;
    
    % id of the outside neighbors
    outsideNeighbors = setdiff(neighbors,neighbourhoodList);

    if isempty(outsideNeighbors)
        numNoConnection =  numNoConnection + 1;
        noConnectionList = cat(1,noConnectionList,iBound);
        continue;
    end;
end;
boundaryNodesID(noConnectionList)= [];