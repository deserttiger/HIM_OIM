function [matrixParams]= GenerateMatrixParameters(params,agent,Net,graphConnectivity)
% Generates the matrix parameters based on the the params and Net
% output:
%
% matrixParams
%             .muAds              -- matrix of size (params.numAds^2,1)
%             .Alpha_agentAd      -- matrix of size (1,1), constant 0.6
%             .Alpha_agents       -- matrix of size (params.numAgents,params.numAgents);
%             .Eps_agentAd        -- matrix of size (1,1), constant 0.4
%             .Eps_agents         -- matrix of size (params.numAgents,params.numAgents);
%             .P_agents           -- matrix of size (params.numAgents,params.numAgents);
%
% 09/23/2012
% Author Mahsa Maghami
% UCF.edu

%
EXPECTED_DESIRE_Ad_to_Ad = params.EXPECTED_DESIRE_Ad_to_Ad;%-0.5; %- 1/(params.numAds);
EXPECTED_DESIRE_AD_to_Self  = params.EXPECTED_DESIRE_AD_to_Self;%1;
Alpha_agentAd = params.Alpha_agentAd;%0.6; % ALPHA = Probability of changing the desire

Eps_agentAd = params.Eps_agentAd;%
Eps_agents_grph_conn = params.Eps_agents;

% MU = Expected Desire  vector
muAds = zeros(params.numAds^2,1) + EXPECTED_DESIRE_Ad_to_Ad;
for i=1:params.numAds
    muAds((i-1)*params.numAds + i) = EXPECTED_DESIRE_AD_to_Self;
end

% ALPHA = Probability of changing the desire

Alpha_agents = sparse(params.numAgents,params.numAgents);
for i=1:params.numAgents
    %     for j=1:params.numAgents
    if mod(i,100)==1
        fprintf('Generate agent alpha %d/%d\r\n',i,params.numAgents);
    end;
    %         if (agent(i).inWeight ~=0)
    
    % changed 11/21/2013 mid night: Changed Net(:,i) to Net(i,:)
    ind = find(Net(i,:));
% ind = find(Net(i,:));
    %TODO: make this outweight similar to the thesis or make the thesis to
    %work with inweight (figure 4.2)
    % using a fixed weight divided by .outWeight 
    Alpha_agents(i,ind) = .7 /(eps+agent(i).outWeight ); %.7;%.7 /(eps+agent(i).outWeight )  ;%.7/(Net(ind,i)+1);%.7%;%Net(ind,i) /(eps+agent(i).inWeight );
    %         else
    %             Alpha_agents(i,j) = 0;
    %         end % IF
    %     end % FOR j
end % FOR i


% EPSILON = Portion of decision changing
Eps_agents = Eps_agents_grph_conn * (speye(size(graphConnectivity)) + graphConnectivity);
% Eps_agents = Eps_agents.*rand(size(Eps_agents));
%Eps_agents = zeros(params.numAgents);
% *** Consider the profile of agents

% for i=1:params.numAgents
%     for j=1:params.numAgents
%         tmp = agent(j).profile ;
%         %Eps_agents (i,j) = 1- Eps_agentAd * agent(i).influence(tmp);
%         Eps_agents (i,j) = 1- agent(i).influence(tmp);
%     end
% end

% *** Consider the Network interaction
% for iEps=1:params.numAgents
%     for jEps=1:params.numAgents
%         if (agent(i).inWeight ~=0)
%             Eps_agents(i,j) =  Net(j,i) /agent(i).inWeight ;
%         else
%             Eps_agents(i,j) = 0.1;
%         end % IF
%     end % FOR jEps
% end % FOR iEps



% P = Interaction Probability
P_agents = 0*Net;%sparse(params.numAgents,params.numAgents);
% P_agentAd --> This is what we selected parameteric
for i=1:params.numAgents
    %     for j=1:params.numAgents
    if mod(i,100)==1
        fprintf('Generate P_agents %d/%d\r\n',i,params.numAgents);
    end;
    %     if any(Net(i,:)) % agent.outWeight ~=0
    %         if i<=params.numAgents && j<=params.numAgents
    ind = find(Net(i,:));
    P_agents(i,ind) = Net(i,ind) /(eps+ agent(i).outWeight);
    %         elseif i<=R && j>R
    %             p(i,j) = u(j,i) / Threshold;
    %         else
    %             p(i,j) = 0;
    %         end
    %         else
    %             P_agents(i,j) = 0;
    %         end
    %     end
end
matrixParams = struct('muAds',muAds,'Alpha_agentAd',Alpha_agentAd,'Alpha_agents',Alpha_agents,'Eps_agentAd',Eps_agentAd,'Eps_agents',Eps_agents,'P_agents',P_agents);
