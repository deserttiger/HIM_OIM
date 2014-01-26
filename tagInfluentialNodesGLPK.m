function [tags,U_opt,U]= tagInfluentialNodesGLPK(W_coef,M,A,matrixParams,params,isSubgraph,indCurrentNode)
% U_opt             -- matrix of (numAds, numAgents) optimal binary assignments 0 or 1
% tags              -- matrix  of (numAds,numLinks) each row contains the agent IDs where the ad is connected to
% U                 -- matrix of (numAds, numAgents) continious assignments between 0 or 1
% isSubgraph        -- false: OIM, true: for HIM
% indCurrentNode    -- for OIM:  [], for HIM: the index of current node
muAds = matrixParams.muAds;
numAds = params.numAds;
numAgents  = params.numAgents;
numLinks = params.adBudget;
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve the Problem
%%%%%%%%%%%%%%%%%%%%%%%%%%%

invA = inv(A);
% eg = abs(eigs(invA,1));
if isSubgraph
    fprintf ('\t Optimizing in subgraph ...')
    
else
    fprintf ('\t Optimizing in graph ...')
end;


fid = fopen('tempDataFile.dat','w');
tic
% check if the file has been created
if (fid>=0)
    fprintf(fid,'# describe the data\r\n');
    fprintf(fid,'data;\r\n');
    
    fprintf(fid,'# numLinks\r\n');
    fprintf(fid,'param numLinks := %d;\r\n',numLinks);
    
    fprintf(fid,'# number of ads\r\n');
    fprintf(fid,'param numAds := %d;\r\n',numAds);
    
    fprintf(fid,'# number of agents\r\n');
    fprintf(fid,'param numAgents := %d;\r\n',numAgents);
    
    % write inv_wCoef_muAds
    inv_wCoef_muAds = inv(W_coef*reshape(muAds,numAds,numAds));
    fprintf(fid,'# inv_wCoef_muAds (matrix)\r\n');
    fprintf(fid,'param inv_wCoef_muAds :');
    for i = 1:numAds
        fprintf(fid,'%d ',i);
    end;
    fprintf(fid,':=\r\n');
    for i = 1:numAds
        
        for j = 1:numAds
            if (1==j)
                fprintf(fid,'%d ',i);
            end;
            
            fprintf(fid,'%g ',inv_wCoef_muAds(i,j));
            
        end;
        fprintf(fid,'\r\n');
    end;
    fprintf(fid,';\r\n');
    
    % write invA
    fprintf(fid,'# invA (matrix)\r\n');
    fprintf(fid,'param invA :');
    for i = 1:numAds*numAgents
        fprintf(fid,'%d ',i);
    end;
    
    fprintf(fid,':=\r\n');
    
        fclose(fid);
    ATemp = cat(2,[1:size(A,1)]',full(invA));
    dlmwrite('tempDataFile.dat',ATemp,'-append','delimiter',' ');
    fid = fopen('tempDataFile.dat','a');
    if (fid>=0)
        fprintf(fid,';\r\n');
        fprintf(fid,'\r\nend;');
        fclose(fid);
    end;
end;
toc

try
system('glpsol.exe -m HIMMOdel.mod -d tempDataFile.dat');
catch
        fprintf ('\t\tFailed in running glpsol.exe\r\n')
end;
U = zeros(numAds, numAgents);
U_opt = zeros(numAds, numAgents);
tags  = zeros(numAds,numLinks);

indOfU =[];
try
    indOfU =dlmread('results.txt',',');
catch
    
    fprintf ('\t\tdlmread read failed Happened. Not finished\r\n')
    return;
end;


% generate U_opt
for iU = 1:size(indOfU,1)
    if isSubgraph
        if (indOfU(iU,2) == indCurrentNode)
            continue;
        end;
    end;
    U_opt(indOfU(iU,1),indOfU(iU,2))=1;
end

% provided for backward compatibility only. U_opt is a binary assignment
% using GLPK integer programming
U  = U_opt;

% generate the tags
for iAd = 1:numAds
    indexOfSelectedAgents = find(U_opt(iAd,:)>0);
    if ~isempty(indexOfSelectedAgents)
        
        tags(iAd,1:length(indexOfSelectedAgents)) = indexOfSelectedAgents;
    end;
end;
fprintf ('finished\r\n')
