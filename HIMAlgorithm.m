function  [U_HIM ,listOfInfluentialNodes,agent]= HIMAlgorithm (params, matrixParams, agent, M,communityClass)
% Hierarchical Influence Maximization (HIM) algorithm.
% Inputs:
%           params
%           matrixParams
%           agent
%           M
%           communityClass         : matrix of Nx2 (id,class) that defines the
%           community of the agent according to community detection
%
% output
%           U_HIM ,                : computed agent ad assignment 
%           listOfInfluentialNodes,: list of influential nodes for each
%                                    hierarchy
%           agent                  : contains the hierarchy

% initially the list of influential nodes for the first hierarchy is empty
listOfInfluentialNodes{1} = cell(params{1}.numAds,1);

% counter/iterator for the hierarchy
iH = 1;
stopCriteria = true;
numTags = 0;
usePredefinedSubgraphs  = false;
numSubgraph = 0;
listOfSubgraphClasses = [];

% reset inf tags
for i = 1:length(agent{1})
    agent{1}(i).InfTag = zeros(params{1}.numAds,1);
end;

% compute the log  of shortest path for all agents
spP_agents = sparse(matrixParams{1}.P_agents);
[D]= graphallshortestpaths(-spfun(@log,spP_agents));


while (stopCriteria)
    if iH ==1
        prev_params = params{iH};
        prev_matrixParams = matrixParams{iH};
        prev_agent = agent{iH};
        prev_listOfInfluentialNodes = listOfInfluentialNodes{iH};
        if (exist('communityClass','var') && ~isempty(communityClass) )  
            usePredefinedSubgraphs = true;            
            listOfSubgraphClasses = unique(communityClass(:,2));
            numSubgraph=length(listOfSubgraphClasses);
        end;
    else
        prev_params = params{iH-1};
        prev_matrixParams = matrixParams{iH-1};
        prev_agent = agent{iH-1};
        prev_listOfInfluentialNodes = listOfInfluentialNodes{iH-1};
        usePredefinedSubgraphs = false;
        numSubgraph = 0;
        listOfSubgraphClasses = [];
    end;
    fprintf('Starting Heirarchy %d\r\n',iH);
    
    [matrixParams{iH},agent{iH},params{iH},numInfluentialNodes] = UpdateHeirarchy(prev_listOfInfluentialNodes,prev_matrixParams,prev_agent,prev_params,D);
    
    % when available use the community class to define the subgraph in
    % the first hierarchy
    if (usePredefinedSubgraphs)
        for iSubgraph = 1:numSubgraph
                       
            fprintf('\tHeirarchy %d,subgraph %d/%d, #influentials %d, #tags %d\r\n',iH,iSubgraph,numSubgraph, numInfluentialNodes,numTags);
            
            %       1) Find the neighbourhood N and the Boundry nodes ID
            indz= find(communityClass(:,2) ==listOfSubgraphClasses(iSubgraph));            
            neighbourhoodList  = communityClass(indz,1) +1;  % +1 because current Gephi output is using zeros based data
            boundaryNodesID = [];

            [subMatrixParams,subgraphParams] = MakeSubgraph(matrixParams{iH},neighbourhoodList,params{iH});
            fprintf('\t\t subgraph of size = %d\n',subgraphParams.numTotal);
            
            [Q_mat,A,B_coef,W_coef,HasInverse] = GenerateQ(subgraphParams,M,subMatrixParams);
            
            if ~HasInverse
                continue;
            end;
            
            % the whole subgraph is processed once so there is not currentNode
            indCurrentNode = NaN;
            
            %       2) Solve the optimization problem
            [tags,U_opt,U_subgraphCont]= tagInfluentialNodesGLPK(W_coef,M,A,subMatrixParams,subgraphParams,true,indCurrentNode);
            
            %[tags,U_opt,U_subgraphCont]= tagInfluentialNodes(W_coef,M,A,subMatrixParams,subgraphParams,true,indCurrentNode);
            numTags = sum(tags(:)>0);
            
            % Update agent Influence tags InfTag ( don't use the virtual nodes)
            agent{iH} = UpdateAgentInfTag(agent{iH},tags,neighbourhoodList,indCurrentNode);%,U_subgraphCont);
        end %end for each subgraph
    else
        
        %   for each node do the following:
        for iNode = 1:params{iH}.numAgents
            
            
            fprintf('\tHeirarchy %d,Node %d/%d, #influentials %d, #tags %d\r\n',iH,iNode,params{iH}.numAgents, numInfluentialNodes,numTags);
            
            % ignore the high degree nodes in the first hierarchy
            if iH ==1
                if (agent{iH}(iNode).outDegree+ agent{iH}(iNode).inDegree > params{iH}.highDegreeTreshold)
                    fprintf('\t\t ignored because of high degree\n');
                    continue;
                end;
            end;
            
            %       % Find the neighbourhood N and the Boundry nodes ID
            
            [neighbourhoodList,boundaryNodesID] = FindNeighbourhood(agent{iH},iNode,params{iH});
            
            % Make the subgraph from the neighbourhoodList
            %TODO: CHECK why this is needed why different subgraph generation for slash dot
            %if (testCase==3)
            %           [subMatrixParams,subgraphParams] = MakeSubgraphSlashDot(matrixParams{iH},neighbourhoodList,params{iH});
            %      else
            [subMatrixParams,subgraphParams] = MakeSubgraph(matrixParams{iH},neighbourhoodList,params{iH},D);
            fileName = sprintf('data/subgraph_Hierarchy_%06d_node_%06d_%06d.dl',iH,iNode,agent{iH}(iNode).id);%C:\\Users\\Mahsa\\Documents\\ASONAM13\\Codes\\data\\processed_epinion.txt'
             %write2Gephi(subMatrixParams.P_agents,fileName,params{iH});
            fprintf('\t\t subgraph of size = %d, wrote %s\n',subgraphParams.numTotal,fileName);
            %       end; % end of if (testCase==3), special case for slash dot
            %
            %       % Add outside world effect ( adding the virtual nodes to the subgraph)
            %          [subMatrixParams,subgraphParams] = AddOutsideWorldEffect(matrixParams{iH},subMatrixParams,agent{iH},neighbourhoodList,boundaryNodesID,subgraphParams);
            
            %       Tag the influential nodes in N
            %       1) Build Q matrix
            
            [Q_mat,A,B_coef,W_coef,HasInverse] = GenerateQ(subgraphParams,M,subMatrixParams);
            
            if ~HasInverse
                continue;
            end;
            %       2) Solve the optimization problem
            %         [tags,U_opt]= tagInfluentialNodes(W_coef,A,augmentedSubMatrixParams,subgraphParams);\
            indCurrentNode = [];%find(neighbourhoodList==iNode);
            [tags,U_opt,U_subgraphCont]= tagInfluentialNodesGLPK(W_coef,M,A,subMatrixParams,subgraphParams,true,indCurrentNode);
            
            %[tags,U_opt,U_subgraphCont]= tagInfluentialNodes(W_coef,M,A,subMatrixParams,subgraphParams,true,indCurrentNode);
            numTags = sum(tags(:)>0);
            
            % Update agent Influence tags InfTag ( don't use the virtual nodes)
            agent{iH} = UpdateAgentInfTag(agent{iH},tags,neighbourhoodList,iNode);%,U_subgraphCont);
        end %end for each node
    end; % end if usePredefinedSubgraphs
    % finds the list of influential nodes based on InfTags of agent
    % influential nodes are those nodes that are at lease selected once
    % the content is the ID of the node in the current hierarchy
    listOfInfluentialNodes{iH} = GetInfluentialNodes(agent{iH},params{iH});
    
    listOfInfluentialNodesPrev=[];
    if iH>1
        listOfInfluentialNodesPrev =  listOfInfluentialNodes{iH-1};
    end
    stopCriteria = StoppingCriteria(listOfInfluentialNodes{iH},listOfInfluentialNodesPrev,params{iH},iH);
    if (~stopCriteria)
        fprintf('reached the stopping condition\r\n')
    end;
    listOfNodes = unique([listOfInfluentialNodes{iH}{:}]);
    numInfluentialNodes = length(listOfNodes);
    iH  = iH + 1 ;
end %END while

%Build the U_opt matrix which is a connection matrix from Ads to Agents.
U_HIM = BuildAdAgentConnection (listOfInfluentialNodes{iH-1},agent{iH-1},params{1});
