function [Results, totalAverageResults] = RunSimulation(simParams, params, matrixParams, MethodsStruct, TheFirstAgentStructure,M)

% Results{iRun}(iMethod).ItrAve                         --->  NumAds*NumOfIterations matrix 
%(Same for  ~.ItrMax , ~.ItrMin, ~.ItrStd, ~.ItrStE)
% Results{iRun}(iMethod).FinalDesireMatrix                 --->  NumAds*NumAgents
% Results{iRun}(iMethod).AveFinalDesireVec              --->  Vector of size NumAds
%(Same for  ~.Max* , ~.Min*, ~.Std*, ~.StE*)
matrixParams{1}.P_agents = single(full( matrixParams{1}.P_agents ));
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%
Results{simParams.numRun}(length(MethodsStruct)).ItrAve=[];
Results{simParams.numRun}(length(MethodsStruct)).ItrMax=[];
Results{simParams.numRun}(length(MethodsStruct)).ItrMin=[];
Results{simParams.numRun}(length(MethodsStruct)).ItrStd=[];
Results{simParams.numRun}(length(MethodsStruct)).ItrStE=[];
Results{simParams.numRun}(length(MethodsStruct)).FinalDesireMatrix=[];
Results{simParams.numRun}(length(MethodsStruct)).AveFinalDesireVec=[];
agentItr{length(MethodsStruct)} =[];
for iRun = 1:simParams.numRun

    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % RESULT INITIALIZATION
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for iMethod = 1:length(MethodsStruct)
        agentItr{iMethod} = TheFirstAgentStructure; %load agent
        
        % make the desire value of the agent that the U is connected to it
        % equal to one
        for iU = 1:size(MethodsStruct(iMethod).U,1)
            connectedAgents2U = find(MethodsStruct(iMethod).U(iU,:));
            for iCU = 1:length(connectedAgents2U)
                agentItr{iMethod}(connectedAgents2U(iCU)).desireVec(iU)=1;
            end;
        end;
        Results{iRun}(iMethod).ItrAve = zeros(params{1}.numAds,floor(simParams.numItr/simParams.ResultsIterationFactor));
        Results{iRun}(iMethod).ItrMax = zeros(params{1}.numAds,floor(simParams.numItr/simParams.ResultsIterationFactor));
        Results{iRun}(iMethod).ItrMin = zeros(params{1}.numAds,floor(simParams.numItr/simParams.ResultsIterationFactor));
        Results{iRun}(iMethod).ItrStd = zeros(params{1}.numAds,floor(simParams.numItr/simParams.ResultsIterationFactor));
        Results{iRun}(iMethod).ItrStE = zeros(params{1}.numAds,floor(simParams.numItr/simParams.ResultsIterationFactor));
        Results{iRun}(iMethod).FinalDesireMatrix = [];
        Results{iRun}(iMethod).AveFinalDesireVec = [] ;
    end
end;
%             P_interactionAll = matrixParams{1}.P_agents ;
%             nonNegativeInteractionIndex = find(P_interaction>0);
%             rolletAll = (cumsum (matrixParams{1}.P_agents,2));%(nonNegativeInteractionIndex));
rolletStrct(size(matrixParams{1}.P_agents,1)).rollet = [];
rolletStrct(size(matrixParams{1}.P_agents,1)).nonNegativeInteractionIndex = [];

id1Log = zeros(simParams.numRun,simParams.numItr);
id2Log = zeros(simParams.numRun,simParams.numItr);
for iRun = 1:simParams.numRun
    for iMethod = 1:length(MethodsStruct)
        agentItr{iMethod} = TheFirstAgentStructure; %load agent
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ITERATION START
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for itr = 1:simParams.numItr
        if mod(itr,simParams.ResultsIterationFactor) ==1
            fprintf(' Run %d/%d, iteration %d/%d\r\n',iRun,simParams.numRun,itr,simParams.numItr);
        end;
        
        id1 = randi(params{1}.numTotal,1);
        id1Log(iRun,itr) = id1;
        % If the selected agent is Regular agent
        if id1<= params{1}.numAgents      
            %Select the other agent to interact with
            % changed 11/21/2013 mid night: Fixed bug in rollet wheel
%            P_interaction = matrixParams{1}.P_agents (id1,:);
%             nonNegativeInteractionIndex = find(P_interaction);
%             rollet = cumsum (P_interaction(nonNegativeInteractionIndex));
%             tmpSubIndex = find (rollet >= rand);
%             tmp = nonNegativeInteractionIndex(tmpSubIndex);

            if (isempty(rolletStrct(id1).rollet))
                
                P_interaction = matrixParams{1}.P_agents (id1,:);
                rolletStrct(id1).nonNegativeInteractionIndex = find(P_interaction);
                rolletStrct(id1).rollet = cumsum (P_interaction(rolletStrct(id1).nonNegativeInteractionIndex ));
                
                
            end;
            tmpSubIndex = find ( rolletStrct(id1).rollet >= rand);
            tmp = rolletStrct(id1).nonNegativeInteractionIndex(tmpSubIndex);

%            P_interaction = matrixParams{1}.P_agents (id1,:);
%             nonNegativeInteractionIndex = find(matrixParams{1}.P_agents (id1,:)>0);
%             rollet = cumsum ( matrixParams{1}.P_agents (id1,nonNegativeInteractionIndex));
%             tmpSubIndex = find (rollet >= rand);
%             tmp = nonNegativeInteractionIndex(tmpSubIndex);
%             

%             
%             rollet = rolletAll(id1,:);
%             tmp=find(rollet>=rand);
%             
            %%%%%%%%%%%%%%%%%%%%%%%%
            % Special Case Warning for finding no interaction.
            %%%%%%%%%%%%%%%%%%%%%%%%
            if isempty(tmp),
                %fprintf('\tRun(%d) Warning: No interaction has been found! Continuing simulation, results are copied from the previous iteration.\r\n',iRun);
                if (mod(itr-1,simParams.ResultsIterationFactor)==0)
                    subItr = floor(itr/simParams.ResultsIterationFactor) + 1;
                    if subItr>1
                        for iMethod= 1:length(MethodsStruct)
                            Results{iRun}(iMethod).ItrAve(:,subItr) = Results{iRun}(iMethod).ItrAve(:,subItr-1);
                            Results{iRun}(iMethod).ItrMax(:,subItr) = Results{iRun}(iMethod).ItrMax(:,subItr-1);
                            Results{iRun}(iMethod).ItrMin(:,subItr) = Results{iRun}(iMethod).ItrMin(:,subItr-1);
                            Results{iRun}(iMethod).ItrStd(:,subItr) = Results{iRun}(iMethod).ItrStd(:,subItr-1);
                            Results{iRun}(iMethod).ItrStE(:,subItr) = Results{iRun}(iMethod).ItrStE(:,subItr-1);
                        end;
                    end;

                end;
                continue;
            end;
            %%%%%%%%%%%%%%%%%%%%%%%%
            
            id2= tmp(1);
            id2Log(iRun,itr) = id2;
            %%%%%%%%%%%%%%%%%%%%%%%%
            % Sharing the ideas:
            % With probabilty of Alpha(id1, id2), agent id1 will change its
            % desire value (get influence from agent id2). Otherwise the values will remain the same.
            %%%%%%%%%%%%%%%%%%%%%%%%
            if rand<= matrixParams{1}.Alpha_agents(id1,id2)
                for iMethod= 1:length(MethodsStruct)
                    agentItr{iMethod}(id1).desireVec = matrixParams{1}.Eps_agents (id1,id2)*(M*agentItr{iMethod}(id1).desireVec) + (1-matrixParams{1}.Eps_agents (id1,id2)) * (M*agentItr{iMethod}(id2).desireVec);
                    agentItr{iMethod}(id2).desireVec = agentItr{iMethod}(id2).desireVec;
                end
            end % IF rand
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            %RESULT SAVE
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            if (mod(itr-1,simParams.ResultsIterationFactor)==0)
                subItr = floor(itr/simParams.ResultsIterationFactor) + 1;
                for iMethod= 1:length(MethodsStruct)
                    Results{iRun}(iMethod).ItrAve(:,subItr) = sum([agentItr{iMethod}(1:params{1}.numAgents).desireVec],2)./ params{1}.numAgents ;
                    Results{iRun}(iMethod).ItrMax(:,subItr) = max([agentItr{iMethod}(1:params{1}.numAgents).desireVec],[],2);
                    Results{iRun}(iMethod).ItrMin(:,subItr) = min([agentItr{iMethod}(1:params{1}.numAgents).desireVec],[],2);
                    theStd = std([agentItr{iMethod}(1:params{1}.numAgents).desireVec],0,2);;
                    Results{iRun}(iMethod).ItrStd(:,subItr) = theStd ;
                    Results{iRun}(iMethod).ItrStE(:,subItr) = theStd ./ sqrt(params{1}.numAgents);
                end
            end;
        % If the selected agent is Ad agent    
        elseif id1> params{1}.numAgents    
            for iMethod= 1:length(MethodsStruct)
                U = MethodsStruct(iMethod).U ;
                connectedAgents =  find(U(id1-params{1}.numAgents,:)) ;
                
                % No interaction has been found! Continuing simulation,
                % results are copied from the previous iteration
                if isempty(connectedAgents)
                    if (mod(itr-1,simParams.ResultsIterationFactor)==0)
                        subItr = floor(itr/simParams.ResultsIterationFactor) + 1;                        
                        if subItr>1
                            if (Results{iRun}(iMethod).ItrAve(:,subItr)==0)
                                Results{iRun}(iMethod).ItrAve(:,subItr) = Results{iRun}(iMethod).ItrAve(:,subItr-1);
                                Results{iRun}(iMethod).ItrMax(:,subItr) = Results{iRun}(iMethod).ItrMax(:,subItr-1);
                                Results{iRun}(iMethod).ItrMin(:,subItr) = Results{iRun}(iMethod).ItrMin(:,subItr-1);
                                Results{iRun}(iMethod).ItrStd(:,subItr) = Results{iRun}(iMethod).ItrStd(:,subItr-1);
                                Results{iRun}(iMethod).ItrStE(:,subItr) = Results{iRun}(iMethod).ItrStE(:,subItr-1);
                            end;
                        end;
    
                    end
                    continue;
                end;
                
                %Select the other agent to interact with
                % changed 11/21/2013 mid night: Fixed bug in rollet wheel
                P_interaction = repmat( 1/length(connectedAgents), 1, length( connectedAgents ) );                

                rollet = cumsum (P_interaction);
                tmp = find (rollet >= rand);

                id2 = connectedAgents(tmp(1));
                id2Log(iRun,itr) = id2;
                % Agent id2 will get influence from the Ad
                if rand<= matrixParams{1}.Alpha_agentAd
                    agentItr{iMethod}(id1).desireVec = agentItr{iMethod}(id1).desireVec;
                    agentItr{iMethod}(id2).desireVec = matrixParams{1}.Eps_agentAd*(M*agentItr{iMethod}(id2).desireVec) + ((1-matrixParams{1}.Eps_agentAd) * (M*agentItr{iMethod}(id1).desireVec));
                end % IF rand
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                %RESULT SAVE
                %%%%%%%%%%%%%%%%%%%%%%%%%%%
                if (mod(itr-1,simParams.ResultsIterationFactor)==0)
                    subItr = floor(itr/simParams.ResultsIterationFactor) + 1;
                    for iMethod= 1:length(MethodsStruct)
                        Results{iRun}(iMethod).ItrAve(:,subItr) = sum([agentItr{iMethod}(1:params{1}.numAgents).desireVec],2)./ params{1}.numAgents ;
                        Results{iRun}(iMethod).ItrMax(:,subItr) = max([agentItr{iMethod}(1:params{1}.numAgents).desireVec],[],2);
                        Results{iRun}(iMethod).ItrMin(:,subItr) = min([agentItr{iMethod}(1:params{1}.numAgents).desireVec],[],2);
                        theStd = std([agentItr{iMethod}(1:params{1}.numAgents).desireVec],0,2);
                        Results{iRun}(iMethod).ItrStd(:,subItr) = theStd;
                        Results{iRun}(iMethod).ItrStE(:,subItr) = theStd./ sqrt(params{1}.numAgents);
                    end
                end;
                
%                 Results{iRun}(iMethod).ItrAve(:,itr) = sum([agentItr{iMethod}(1:params{1}.numAgents).desireVec],2)./ params{1}.numAgents ;
%                 Results{iRun}(iMethod).ItrMax(:,itr) = max([agentItr{iMethod}(1:params{1}.numAgents).desireVec],[],2);
%                 Results{iRun}(iMethod).ItrMin(:,itr) = min([agentItr{iMethod}(1:params{1}.numAgents).desireVec],[],2);
%                 Results{iRun}(iMethod).ItrStd(:,itr) = std([agentItr{iMethod}(1:params{1}.numAgents).desireVec],0,2); 
%                 Results{iRun}(iMethod).ItrStE(:,itr) = std([agentItr{iMethod}(1:params{1}.numAgents).desireVec],0,2)./ sqrt(params{1}.numAgents); 
            end % FOR iMethod       
        end;
        
    end % FOR itr
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %ITERATION ENDS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    %RESULT AVERAGING
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    for iMethod= 1:length(MethodsStruct)
        %Calculate Average of Desire Vector of ALL AGENTS
        Results{iRun}(iMethod).FinalDesireMatrix = [agentItr{iMethod}(1:params{1}.numAgents).desireVec];
        Results{iRun}(iMethod).AveFinalDesireVec = sum([agentItr{iMethod}(1:params{1}.numAgents).desireVec],2)./ params{1}.numAgents ;
        Results{iRun}(iMethod).MaxFinalDesireVec = max([agentItr{iMethod}(1:params{1}.numAgents).desireVec],[],2);
        Results{iRun}(iMethod).MinFinalDesireVec = min([agentItr{iMethod}(1:params{1}.numAgents).desireVec],[],2);
        Results{iRun}(iMethod).StdFinalDesireVec = std([agentItr{iMethod}(1:params{1}.numAgents).desireVec],0,2);
        Results{iRun}(iMethod).StEFinalDesireVec = std([agentItr{iMethod}(1:params{1}.numAgents).desireVec],0,2)./ sqrt(params{1}.numAgents) ;
        
    end % FOR iMethod
end % FOR iRun

for iMethod = 1:length(MethodsStruct)
    totalAverageResults{iMethod}.Ave = zeros(params{1}.numAds , round(simParams.numItr/simParams.ResultsIterationFactor));
    totalAverageResults{iMethod}.Max = zeros(params{1}.numAds ,round(simParams.numItr/simParams.ResultsIterationFactor));
    totalAverageResults{iMethod}.Min = zeros(params{1}.numAds , round(simParams.numItr/simParams.ResultsIterationFactor));
    totalAverageResults{iMethod}.Std = zeros(params{1}.numAds , round(simParams.numItr/simParams.ResultsIterationFactor));
    totalAverageResults{iMethod}.StE = zeros(params{1}.numAds , round(simParams.numItr/simParams.ResultsIterationFactor));
    
    for iRun = 1 : simParams.numRun
        totalAverageResults{iMethod}.Ave = totalAverageResults{iMethod}.Ave + Results{iRun}(iMethod).ItrAve/simParams.numRun;
        totalAverageResults{iMethod}.Max = totalAverageResults{iMethod}.Max + Results{iRun}(iMethod).ItrMax/simParams.numRun; 
        totalAverageResults{iMethod}.Min = totalAverageResults{iMethod}.Min + Results{iRun}(iMethod).ItrMin/simParams.numRun;
        totalAverageResults{iMethod}.Std = totalAverageResults{iMethod}.Std + (Results{iRun}(iMethod).ItrStd/simParams.numRun).^2;
        totalAverageResults{iMethod}.StE = totalAverageResults{iMethod}.StE + (Results{iRun}(iMethod).ItrStE/simParams.numRun).^2;
    end;
    % TODO: Double check StE (Propagation of error!)
    totalAverageResults{iMethod}.Std = sqrt(totalAverageResults{iMethod}.Std);
    totalAverageResults{iMethod}.StE  = sqrt(totalAverageResults{iMethod}.StE);
end;

save IDS id1Log id2Log

