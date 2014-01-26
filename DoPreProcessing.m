function [Net,params,graphConnectivity, OriginalIds] = DoPreProcessing(Net,params)
% Do the pre-processing to make sure the network is connected with no
% isolated node.

% 09/23/2012
% Author Mahsa Maghami
% UCF.edu

connectionTreshold = 1; % previously it was params.adBudget for ASONAM 

OriginalIds = [1: size(Net,1)] ;
%% Prunning Data (low connectivity nodes)

%Find the id of the nodes wit                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               h low outDegree and inDegree
ind1_Net = find(sparse(sum(Net,1)<=connectionTreshold));
ind2_Net = find(sparse(sum(Net,2)<=connectionTreshold));
indFin_Net = union (ind1_Net, ind2_Net);

% Delete the nodes with low cconnectivity
Net(:,indFin_Net)=[];
Net(indFin_Net,:)=[];
OriginalIds (indFin_Net)= [];
Net = sparse(Net);
Net = Net - Net.* speye(size(Net,1)); % To make sure there are no loops in the network
%% Updating Parameters based on new pruned network
% New Number of Agents
params.numAgents = size(Net,1);
params.numTotal = params.numAgents + params.numAds;

%% Graph Connectivity (if needed)
% Build graphConnectivity (Adjacency matrix) based on Net
graphConnectivity = Net>0 ;
