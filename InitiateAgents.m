function agent = InitiateAgents(Net,graphConnectivity,params)
% Initializes the regular and ad agents

EXPECTED_DESIRE_Ad_to_Ad = params.EXPECTED_DESIRE_Ad_to_Ad;%-0.5; %- 1/(params.numAds);
EXPECTED_DESIRE_AD_to_Self  = params.EXPECTED_DESIRE_AD_to_Self;%1;

%% Initiate Regular Agents
agent(params.numAgents) = struct('id',[],'outDegree',[],'inDegree',[],'inWeight',[],'outWeight',[],'neighbors',[],'type',[],'status',[],'desireVec',[],'InfTag',[]);
for iAgent = 1: params.numAgents
    if mod(iAgent,100)==1
        fprintf('initializing agent %d/%d\r\n',iAgent,params.numAgents);
    end
    %Fixed Fields
    agent(iAgent).id = iAgent;
    agent(iAgent).outDegree = size (find (graphConnectivity(iAgent,:)),2);
    agent(iAgent).inDegree = size (find (graphConnectivity(:,iAgent)),1);
    agent(iAgent).inWeight = sum(Net(:,iAgent));
    agent(iAgent).outWeight = sum(Net(iAgent,:));
    % the id of neighbors
    agent(iAgent).outNeighbors = find (graphConnectivity(iAgent,:));
    agent(iAgent).inNeighbors = find (graphConnectivity(:,iAgent))';
    agent(iAgent).neighbors = union (agent(iAgent).outNeighbors,agent(iAgent).inNeighbors);
    agent(iAgent).type = 1  ;                                        % '1' = Regular agent
    
    %Variable Fields
    agent(iAgent).status = 0 ;                                       % 0 = uncommitted, 1= committed, 2 = active
    %TODO: What about writing : rand(params.numAds,1)-0.5 to have different desire value for each product.
    
    agent(iAgent).desireVec =  0*rand(params.numAds,1);%params.initialState(:,iAgent);%
    agent(iAgent).InfTag = zeros(params.numAds,1);
    
    %     %Fields for Stereotype
    %     agent(iAgent).profile = labelVec(iAgent);
    %     for k = 1: numGroups
    %         agent(iAgent).influence (k) = normrnd (G(k).mean , G(k).std);
    %     end
    %     agent(iAgent).featureVec = Attributes(iAgent,:);
    %agent(iAgent).FeatureVec = generate_feat_vec (Profile_vec(iAgent), zero_dist, one_dist);
    
end

%% Initiate Advertisement Agents

for iAgent = params.numAgents+1 : params.numTotal
    agent(iAgent).id = iAgent;
    agent(iAgent).type = 2;                                                      % '2'= Advertisement Agent
    agent(iAgent).desireVec = zeros(params.numAds,1) + EXPECTED_DESIRE_Ad_to_Ad;
    agent(iAgent).desireVec(iAgent-params.numAgents) = EXPECTED_DESIRE_AD_to_Self;
    agent(iAgent).neighbors = [];
end
