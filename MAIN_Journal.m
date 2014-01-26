
%% Initialization
clear
addpath(genpath('matlab_bgl'));
addpath(genpath('pagerank-1.2'));

% initialize the test case
testCaseIndex = 8;
[params,simParams,DoLoadNetwork,numAds,networkFileName,DoProbabilisticU] = initTestCases(testCaseIndex);

DO_OIM = true;
iRun  = 0 ;

%% For loop over different networks
for iNetwork = 1:simParams.numNetwork
        
    %% Load or generate the network
    
    if (DoLoadNetwork)      %DoLoadNetwork boolean has been set in initTestCases
        % Load your network
        load (networkFileName)
    else
        % Generate the Network and Labels
        Net = SyntheticDataGen (params{1}.numInitAgents);
    end;
    
    %% Preprocessing
    [Net, params{1}, graphConnectivity, OriginalIds] = DoPreProcessing(Net,params{1});
    
    %% Generate matrix and connectivities of the network
    
    % Generate agent(s)
    agent{1} = InitiateAgents(Net,graphConnectivity,params{1});
    agent1= agent{1};
    TheFirstAgentStructure = agent1;
    
    % Generate matrix parameters based on Net
    matrixParams{1}= GenerateMatrixParameters(params{1},agent{1},Net,graphConnectivity);
    
    % Generate matrix M
    M = generate_M (params{1}.numAds);
    % M = eye(params{1}.numAds);
    
    matrixParams{1}.Alpha_agents = sparse(matrixParams{1}.Alpha_agents);
    matrixParams{1}.Eps_agents = sparse(matrixParams{1}.Eps_agents);
    matrixParams{1}.P_agents = sparse(matrixParams{1}.P_agents);
    graphConnectivity = sparse(graphConnectivity);
    if (DoLoadNetwork)
        % Load your network
        processedFileName = sprintf('processed_%s',networkFileName);
        save (processedFileName,'matrixParams','Net', 'params', 'graphConnectivity', 'M', 'agent', 'TheFirstAgentStructure','OriginalIds')
    end;
    
    %% HIM Algorithm
    startTimeHIM = tic;
    U_HIM = HIMAlgorithm (params, matrixParams, agent,M,params{1}.communityClass);
    elapsedTimeHIM(iNetwork) = toc(startTimeHIM);
    
    % Save HIM assigments
    U_HIMFileName = sprintf('U_HIM_%s.mat',networkFileName);
    save (U_HIMFileName,'U_HIM');
    
    if DO_OIM
        startTimeOIM = tic;
        U_OIM = OIMAlgorithm (params, matrixParams, M);
        elapsedTimeOIM(iNetwork) = toc(startTimeOIM);
        U_OIMFileName = sprintf('U_OIM_%s.mat',networkFileName);
        save (U_HIMFileName,'U_OIM');
    end
    %% Repeat computing the Us for benchmarks beacuase Us are constructed
    % in a probabilistic fashion (rollet wheel)
    for iUs = 1:simParams.numRepeatU
        %% Benchmarks
        [U_rnd, U_bet, U_deg, U_noU, U_PageRank] = RunBenchmarks (params{1}, agent{1}, Net, graphConnectivity,DoProbabilisticU);
        
        %% Build the Methods straucture
        
        % Generate MethodsStruct
        MethodsStruct(1).Name = 'HIM';
        MethodsStruct(1).U = U_HIM;
        
        MethodsStruct(2).Name = 'U_bet';
        MethodsStruct(2).U = U_bet;

        MethodsStruct(3).Name = 'PageRank';
        MethodsStruct(3).U = U_PageRank;
        
        MethodsStruct(4).Name = 'Degree';
        MethodsStruct(4).U = U_deg;
        
        numCurretMethods=4;
        
        if (DO_OIM)
            
            MethodsStruct(numCurretMethods+1).Name = 'OIM';
            MethodsStruct(numCurretMethods+1).U = U_OIM;
               
        end;
        
        MethodsStruct(numCurretMethods+2).Name = 'NO U';
        MethodsStruct(numCurretMethods+2).U = U_noU;

        %
        %% Compute Jaccard similarity of different assignments
        JaccardMatrix = eye(length(MethodsStruct));
        tmpJaccardMatrix = computeJaccardNeighbourhood(MethodsStruct,Net);
        JaccardMatrix = JaccardMatrix + tmpJaccardMatrix / simParams.numNetwork;
        
        figure(4),
        imagesc(JaccardMatrix),colormap gray
        for i = 1:size(JaccardMatrix,1)
            for j= 1:size(JaccardMatrix,2)
                str = sprintf('%.2f',JaccardMatrix(i,j));
                color = [1-JaccardMatrix(i,j),JaccardMatrix(i,j)/2,JaccardMatrix(i,j) ];
                text(j,i,str,'Color',color);
            end;
        end;
        names = {MethodsStruct(:).Name};
        set(gca(),'XTick',1:length(names))
        set( gca(), 'XTickLabel', names )
        set(gca(),'YTick',1:length(names))
        set( gca(), 'YTickLabel', names )

        
        %% Run the Simulation
        [Results, totalAverageResults] = RunSimulation(simParams, params, matrixParams, MethodsStruct, TheFirstAgentStructure,M);
        
        % Save each RUN results
        ResultFileName = sprintf('%s_subIter.%d_U%d_Net%d_Agent%d_Ad%d.mat',networkFileName,simParams.numItr,iUs,iNetwork,params{1}.numInitAgents,params{1}.numAds);
        save (ResultFileName,'Results', 'totalAverageResults', 'params', 'simParams', 'matrixParams', 'MethodsStruct', 'TheFirstAgentStructure', 'JaccardMatrix');
        plotResults(ResultFileName)
        figure(2)
        saveas(gcf,sprintf('Results/%s.fig',ResultFileName), 'fig')
        saveas(gcf,sprintf('Results/%s.png',ResultFileName), 'png')
    end; % FOR iUs
    
    % clear memory
    clear agent
end;

 fprintf('HIM Average executation time %.2f s, OMI Average executation time %0.2f s\r\n',mean(elapsedTimeHIM),mean(elapsedTimeOIM));