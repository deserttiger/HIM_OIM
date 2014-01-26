function [params,simParams,DoLoadNetwork,numAds,networkFileName,DoProbabilisticU] = initTestCases(testCaseIndex)

% testCaseIndex = 1 -->  3 ads, 50    initial agents
% testCaseIndex = 2 --> 10 ads, 100   initial agents
% testCaseIndex = 3 --> 10 ads, 400   initial agents
% testCaseIndex = 4 --> 10 ads, 70    initial agents
% testCaseIndex = 5 --> 10 ads, 150   initial agents
% testCaseIndex = 6 --> 10 ads, 1000  initial agents
% testCaseIndex = 7 --> 15 ads, 77360 initial agents, SlashDot,(networkFileName = 'slashdotdata.mat')
% testCaseIndex = 8 --> 4 ads, 75888 initial agents, Epinions,(networkFileName = 'epinion.mat')
networkFileName = '';
DoProbabilisticU = true; % default is true unless it's been turned off
communityClass =[];

switch testCaseIndex
    case 1  % small set
        numAds = 3;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',50, ...
            'numAgents',50,'adBudget',2 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            1,'maxNumNeighborhood',20,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.6,'Eps_agentAd',0.4,'Eps_agents',0.75);
        params{1}.initialState = rand(params{1}.numAds,params{1}.numAgents); % 2*(rand(params{1}.numAds,1)-0.5); % in [-1 1];
        DoLoadNetwork = false;
        
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',100000,'numRun',4,'numNetwork',1,'ResultsIterationFactor',20000,'numRepeatU',10);
        %load data\NetA
        params{1}.highDegreeTreshold = 200; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
    case 2 % 100
        numAds = 10;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',100, ...
            'numAgents',100,'adBudget',2 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            2,'maxNumNeighborhood',20,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = false;
        
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',60000,'numRun',10,'numNetwork',10,'ResultsIterationFactor',1000,'numRepeatU',50);
        params{1}.highDegreeTreshold = 200; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
    case 3 % 400
        numAds = 10;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',400, ...
            'numAgents',400,'adBudget',2 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            2,'maxNumNeighborhood',200,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = false;
        
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',60000,'numRun',3,'numNetwork',3,'ResultsIterationFactor',1000,'numRepeatU',3);
        params{1}.highDegreeTreshold = 200; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
    case 4 % 70
        numAds = 10;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',70, ...
            'numAgents',70,'adBudget',2 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            2,'maxNumNeighborhood',20,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = false;
        
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',60000,'numRun',10,'numNetwork',10,'ResultsIterationFactor',1000,'numRepeatU',50);
        params{1}.highDegreeTreshold = 200; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
    case 5 % 150
        numAds = 10;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',150, ...
            'numAgents',150,'adBudget',2 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            2,'maxNumNeighborhood',20,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = false;
        
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',60000,'numRun',10,'numNetwork',10,'ResultsIterationFactor',1000,'numRepeatU',50);
        params{1}.highDegreeTreshold = 200; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
    case 6 % 1000
        numAds = 10;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',2000, ...
            'numAgents',2000,'adBudget',2 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            2,'maxNumNeighborhood',20,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = false;
        
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',60000,'numRun',10,'numNetwork',10,'ResultsIterationFactor',1000,'numRepeatU',50);
        params{1}.highDegreeTreshold = 200; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
    case 7  %slash dot
        networkFileName = 'slashdotdata.mat';
        numAds = 15;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',77360,...
            'numAgents',77360,'adBudget',5 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            10,'maxNumNeighborhood',20,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = true;
        RealNetworkIndex = testCaseIndex;
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',10000,'numRun',5,'numNetwork',1,'ResultsIterationFactor',1000,'numRepeatU',50);
        params{1}.highDegreeTreshold = 200; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
    case 8  % Epinion
        networkFileName = 'Epinion.mat';
        numAds = 10;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',75888,...
            'numAgents',75888,'adBudget',50 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            3,'maxNumNeighborhood',300,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = true;
        DoProbabilisticU = false;
        RealNetworkIndex = testCaseIndex;
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',8000000,'numRun',10,'numNetwork',1,'ResultsIterationFactor',500000,'numRepeatU',1,'ProbabilisticU',0);
        params{1}.highDegreeTreshold = 500; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
        % load communityClass variable for Epinion
        %load('EpinionCommunity.mat');

    case 9  % SlashDot
        networkFileName = 'SlashDot.mat';
        numAds = 10;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',82168,...
            'numAgents',82168,'adBudget',50 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            5,'maxNumNeighborhood',150,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = true;
        DoProbabilisticU = false;
        RealNetworkIndex = testCaseIndex;
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',30000,'numRun',5,'numNetwork',1,'ResultsIterationFactor',1000,'numRepeatU',1,'ProbabilisticU',0);
        params{1}.highDegreeTreshold = 60; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
    case 10  % WikiVote
        networkFileName = 'WikiVote.mat';
        numAds = 10;
        params{1} = struct('neighbourhoodRadius',3,'numInitAgents',8297,...
            'numAgents',8297,'adBudget',50 ,'numAds',numAds,'numTotal',0,'numMaxHierarchy',...
            5,' m',30,'EXPECTED_DESIRE_Ad_to_Ad',-.1,...
            'EXPECTED_DESIRE_AD_to_Self',1,'Alpha_agentAd',0.8,'Eps_agentAd',0.4,'Eps_agents',0.75); % (1-Eps_agentAd) is multiplied with agent's desire value
        % (Eps_agents) is multiplied with the receving agent's desire value
        params{1}.initialState =2*(rand(params{1}.numAds,params{1}.numAgents)-.5); % in [-1 1];
        DoLoadNetwork = true;
        DoProbabilisticU = false;
        RealNetworkIndex = testCaseIndex;
        params{1}.numTotal = params{1}.numAgents + params{1}.numAds;
        simParams = struct('numItr',10000,'numRun',20,'numNetwork',1,'ResultsIterationFactor',1000,'numRepeatU',1,'ProbabilisticU',0);
        % HIM parameter for the hurestic in large networks
        params{1}.highDegreeTreshold = 60; % if the in+out degree of a node is greater than this this node is ignored as the initial seed of HIM
end;

params{1}.communityClass = communityClass;
params{1}.maxSubSampleNeighborhood = 50;

