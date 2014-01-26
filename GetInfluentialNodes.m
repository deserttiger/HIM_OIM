function listOfInfluentialNodes = GetInfluentialNodes(agent,params)
% finds the list of influential nodes based on InfTags of agent
%
% listOfInfluentialNodes -- is a cell with params.numAds elements. Each
% contains the ID of the agents in the current hierarchy that are selected
% as influential

% ad2AgentMatrix = reshape([agent(1:params.numAgents).InfTag],params.numAds,[]);
ad2AgentMatrix = [agent(1:params.numAgents).InfTag];
% figure(2)
% imagesc(ad2AgentMatrix)
% title('ad2AgentMatrix')
% pause

%TODO: improve or change this criteria for node selection based on research
% influential nodes are those nodes that are at lease selected once
for iAd = 1:params.numAds
    [val listOfInfluentialNodes{iAd}] = sort(ad2AgentMatrix(iAd,:),'descend');
    listOfInfluentialNodes{iAd}(val==0) =[];  
    if length(listOfInfluentialNodes{iAd})<= 2*params.adBudget;
        continue;
    else
        num = ceil(length(listOfInfluentialNodes{iAd})/2);
        listOfInfluentialNodes{iAd}= listOfInfluentialNodes{iAd}(1:num);
    end;
end;