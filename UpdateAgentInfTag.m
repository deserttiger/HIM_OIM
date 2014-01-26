 function  agent = UpdateAgentInfTag(agent,tags,neighbourhoodList,iNode)
% Update agent Influence tags InfTag ( don't use the virtual nodes)
% neighbourhoodList -- Contains the valid IDs from the main Net
% tags              -- matrix  of (numAds,numLinks) each row contains the agent IDs where the ad is connected to. It  Contains the IDs from the sub Net


for iAd = 1:size(tags,1)
    
    % select the valid tags for each product: ignore all virtual tags
    validTags = intersect(tags(iAd,:),1:length(neighbourhoodList));
    

    % increment the InfTag of the for the corresponding product/ad
    for iAgent = 1:length(validTags)
        ind = neighbourhoodList(validTags(iAgent));
        
        % ignore the influential assignment for the agent that we found the
        % neighborhood around it
        if iNode==ind
            continue;
        end;
        agent(ind).InfTag(iAd) = agent(ind).InfTag(iAd) + 1; 
    end;
    
end;

   
