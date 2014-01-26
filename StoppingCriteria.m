function res = StoppingCriteria(listOfInfluentialNodesCurrent,listOfInfluentialNodesPrev,params,iH)
% res = 0 if budget limit is reached else otherwise
% listOfInfluentialNodes -- is a cell with params.numAds elements. Each
% contains the ID of the agents in the current hierarchy that are selected
% as influential

res = true;

% avoding the inf loop 
if iH> params.numMaxHierarchy 
    res = false;
    return;
end;

% the first iteration
if iH==1
    res = true;
    return;
end;

% if only one node is left
if length(unique([listOfInfluentialNodesCurrent{:}])) < 2
    res = false;
    return;

end;
% influential nodes are those nodes that are at lease selected once
for iAd = 1:params.numAds
    if length(listOfInfluentialNodesCurrent{iAd})<= params.adBudget;
        res = false;
        return;
    end;
end;

cntr = 0;
for iAd = 1:params.numAds
    if isempty(setdiff(listOfInfluentialNodesCurrent{iAd},listOfInfluentialNodesPrev{iAd}))
        cntr = cntr+1;
    end
end
if cntr == params.numAds
    res = false;
    return;
end