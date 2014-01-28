function [U_rnd, U_bet, U_deg, U_noU] = RunBenchmarks (params, agent, Net, graphConnectivity,DoProbabilisticU)

%% Random
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate Random U
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% it selects randomly to connect to any agent (regular agent)

U_rnd = zeros(params.numAds, params.numAgents);
for iAds = 1:params.numAds
    tmp_rnd = randperm(params.numAgents);
    SeedNodes_rnd = tmp_rnd(1:params.adBudget);
    U_rnd(iAds, SeedNodes_rnd)= 1;
    %     id = i+ numAgents;
    %     agent(id).neighbors = SeedNodes_rnd ;
end

%% Betweenness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate Betweenness-based U
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

U_bet = zeros(params.numAds, params.numAgents);

F = betweenness_centrality(Net);
[sortedBetweeness ,indB ]= sort(F,'descend');
%     for ad = 1:params{1}.numAds
%         selected = indB(1:params{1}.adBudget);
%         U_bet (ad,selected) = 1;
%     end;

if (DoProbabilisticU)
    P_attach_bet = F ./ sum(F) ;
    U_betCont = 0*U_bet;
    rollet_bet = cumsum (P_attach_bet);
    for ad = 1:params.numAds
        l=0;
        U_betCont(ad,:) = P_attach_bet;
        while (l ~= params.adBudget)
            tmp = find (rollet_bet >= rand);
            idLink = tmp(1);
            if  (U_bet(ad ,idLink)==0)
                l = l+1 ;
                U_bet (ad, idLink ) = 1;
            else
                continue;
            end
            
        end
    end % FOR ad
else
    
    bet_InfNodes = indB(1:params.adBudget) ;
    U_bet (:, bet_InfNodes)= 1;
end;

%% Degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate Degree_based U (PREFERENTIAL ATTACHMENT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

U_deg = zeros(params.numAds, params.numAgents);
deg = full([agent(1:params.numAgents).outWeight]);
U_degCont = 0*U_deg;
[sortedDegree ,indD ]= sort(deg,'descend');
%     for ad = 1:params{1}.numAds
%         selected = indD(1:params{1}.adBudget);
%         U_deg (ad,selected) = 1;
%     end;
if (DoProbabilisticU)
P_attach = [agent(1:params.numAgents).outWeight] ./ sum([agent(1:params.numAgents).outWeight]) ;
rollet_deg = cumsum (P_attach);
for iAds = 1:params.numAds
    l=0;
    U_degCont(iAds,:) = P_attach;
    while (l ~= params.adBudget)
        tmp_deg = find (rollet_deg >= rand);
        idLink = tmp_deg(1);
        if  (U_deg(iAds ,idLink)==0)
            l = l+1 ;
            U_deg (iAds, idLink ) = 1;
        else
            continue;
        end % IF
        
    end % WHILE
end % FOR iAds
else
    
    deg_InfNodes = indD(1:params.adBudget) ;
    U_deg (:, deg_InfNodes)= 1;
end;

%% PageRank
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate PageRank U
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% U_PageRank = zeros(params.numAds, params.numAgents);
% U_PageRankCont = U_PageRank*0;
% p = pagerank(graphConnectivity)  ;
% [sortedPR ,indPR ]= sort(p,'descend');
% %     for ad = 1:params{1}.numAds
% %         selected = indPR(1:params{1}.adBudget);
% %         U_PageRank (ad,selected) = 1;
% %     end;
% if (DoProbabilisticU)
% P_attach_pageRank = p ./ sum(p) ;
% rollet_pageRank = cumsum (P_attach_pageRank);
% for ad = 1:params.numAds
%     l=0;
%     U_PageRankCont(ad,:) = P_attach_pageRank;
%     while (l ~= params.adBudget)
%         tmp = find (rollet_pageRank >= rand);
%         idLink = tmp(1);
%         if  (U_PageRank(ad ,idLink)==0)
%             l = l+1 ;
%             U_PageRank (ad, idLink ) = 1;
%         else
%             continue;
%         end
%         
%     end
% end % FOR ad
% else
%     
%     pagerank_InfNodes = indPR(1:params.adBudget) ;
%     U_PageRank (:, pagerank_InfNodes)= 1;
% end;
%% No U
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% No U
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

U_noU = zeros(params.numAds, params.numAgents);
    