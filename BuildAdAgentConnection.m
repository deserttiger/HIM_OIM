function U_FinalOpt = BuildAdAgentConnection(listOfInfluentialNodes,agent,params)



U_FinalOpt = zeros(params.numAds, params.numAgents);
%theInfluentials = [agent{iH-1}(listOfNodes).id];

for iAd = 1:params.numAds
    indexOfSelectedAgents = listOfInfluentialNodes{iAd};
    indexOfSelectedAgents = indexOfSelectedAgents(1:min(length(indexOfSelectedAgents),params.adBudget));
    IDs = [agent(indexOfSelectedAgents).id];
    U_FinalOpt(iAd,IDs)=1;
    
end
