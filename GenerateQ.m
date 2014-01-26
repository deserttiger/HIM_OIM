function  [Q_mat,A,B_coef,W_coef,HasInverse] = GenerateQ(params,M,matrixParams)
% Generates the Q, A, B, and W matrices
% HasInverse -- indicates that A has inverse 

%% Build Matrices

% W matrix
W_agents = sparse(params.numAgents,params.numAgents);
% for i=1:params.numAgents
%     for j=1:params.numAgents
%         %%%ALERT! This doesn't contain M matrix.
%         W_agents(i,j) = matrixParams.Alpha_agents (i,j)* (1-matrixParams.Eps_agents(i,j));
%     end
% end

% tic
% % S matrix
% Q = cell(params.numAgents, params.numTotal);
% % Q matrix
% for i = 1: params.numAgents
%     for j = 1: params.numTotal
%         
%         if j<=params.numAgents
%             if i~=j         % off the diagonal elements
%                 wij =  matrixParams.Alpha_agents (i,j)* (1-matrixParams.Eps_agents(i,j)) * M ;
%                 Q{i,j} = (1/params.numTotal) * (matrixParams.P_agents(i,j) + matrixParams.P_agents(j,i)) * wij ;       % I can name it A
%             else            % on the diagonal elements
%                 for k= 1: params.numAgents
%                     % initially Q{i,j} when i = j are equal is [] so make
%                     % the inital value = 0
%                     if isempty(Q{i,j})
%                         Q{i,j}=0;
%                         
%                     end
%                     % NOTE: I removed the negative sign of this and it worked
%                     % q(i,j) = q(i,j) + 1/N * (Pik + Pki) * allpha_ik * (I-M * eps)
%                     % Q{i,j}= Q{i,j} + (1/params.numTotal) * ( matrixParams.P_agents(i,k) + matrixParams.P_agents(k,i) )* matrixParams.Alpha_agents(i,k) * ( eye(params.numAds)- matrixParams.Eps_agents(i,k)*M ) ;
%                     Wik =  matrixParams.Alpha_agents (i,k)* (1-matrixParams.Eps_agents(i,k)) * M ;
% %                     Sik = Wik+ matrixParams.Alpha_agents(i,k) * ( eye(params.numAds)- matrixParams.Eps_agents(i,k))*M ;
%                     Sik = Wik+ matrixParams.Alpha_agents(i,k) * ( eye(params.numAds)- M) ;
%                     
%                     Q{i,j}= Q{i,j} - (1/params.numTotal) * ( matrixParams.P_agents(i,k) + matrixParams.P_agents(k,i) )*   Sik ;% +...
%                         %(1/params.numTotal) * ( matrixParams.P_agents(i,k) + matrixParams.P_agents(k,i)' ) *Wik ;
%                 end
%                 %Wii =  matrixParams.Alpha_agents (i,i)* (1-matrixParams.Eps_agents(i,i)) * M ;
%                 %Q{i,j} = Q{i,j} + (1/params.numTotal) * ( matrixParams.P_agents(i,j) + matrixParams.P_agents(j,i)' ) *Wii ;
%             end
%             
%         elseif j>params.numAgents
%             Q{i,j} = ( 1/(params.numTotal*params.adBudget) ) * matrixParams.Alpha_agentAd * ( 1-matrixParams.Eps_agentAd ) * M  ;      % I can name it B
%         end
%         
%     end % FOR j
% end % FOR i
%Q_mat = cell2mat(Q);
matrixParams.Alpha_agents = .4+0*matrixParams.Alpha_agents;
P_agentSym = (1/params.numTotal)* (matrixParams.P_agents + matrixParams.P_agents');
WijPAgentSymAll =  kron((1/params.numTotal).* (matrixParams.P_agents + matrixParams.P_agents').*matrixParams.Alpha_agents .* (1-matrixParams.Eps_agents) , M) ;
filterDiagValues = kron(eye(size(P_agentSym)),ones(size(M)));
%SPartAgentSymAll = kron((1/params.numTotal).*P_agentSym .*matrixParams.Alpha_agents , eye(params.numAds)-M );
sigma_over_k = sum((1/params.numTotal).* (matrixParams.P_agents + matrixParams.P_agents') .*matrixParams.Alpha_agents ,2);
sigma_over_k_wikPart = sum((1/params.numTotal).* (matrixParams.P_agents + matrixParams.P_agents').*matrixParams.Alpha_agents .* (1-matrixParams.Eps_agents) ,2);

SPartAgentSymAll = kron( diag(sigma_over_k),eye(params.numAds)-M );
WPartAgentSymAll = kron( diag(sigma_over_k_wikPart),M );
% TODO:  ( matrixParams.P_agents(i,k) + matrixParams.P_agents(k,i) )* is multiplied to times in th Sik (part wik)!! -( matrixParams.P_agents(i,k) + matrixParams.P_agents(k,i) )*   Sik
% TODO: sum is not computed correctly becxause Wik exist in Sik and then later they have a different kron product! 
% TODO: Wik and Sik is not the same az kaghazi ke javab haye hamey donya
% tooshe
% TOSO: sum in kron is not the same as the sum in the for loop!!!
SikAll = WijPAgentSymAll - filterDiagValues.* (SPartAgentSymAll +WPartAgentSymAll);
adRelatedValues = ( 1/(params.numTotal*params.adBudget) ) * matrixParams.Alpha_agentAd * ( 1-matrixParams.Eps_agentAd );
QMatAdsB = repmat(adRelatedValues* M ,params.numAgents,params.numAds);

Q_mat = cat(2,SikAll,QMatAdsB);



% XPart=P_agentSym .*matrixParams.Alpha_agents .* (1-matrixParams.Eps_agents);
% QMatOffDiag = kron( XPart,M);
% 
% sigmaSik_minues_Wik_over_k = sum(XPart,2);
% QMatDiag = kron(diag(sigmaSik_minues_Wik_over_k),M);
% %P_agentSym_times_M = kron( P_agentSym,eye(size(M)));
% %S_minus_W =  kron(matrixParams.Alpha_agents .* (1-matrixParams.Eps_agents) , M) ;
% % filterTheValues = kron(eye(size(P_agentSym)),ones(size(M)));
% %diagValue = sum(P_agentSym_times_M.*S_minus_W.*filterTheValues,2);
% %QMatDiag = diag(diagValue);
% 
% 
% QMatAll = QMatOffDiag;
% 
% QMatAll = QMatAll-QMatAll.*filterDiagValues  + QMatDiag;
% QMatAll = cat(2,QMatAll,QMatAdsB);
% constraint matrix
%     const = zeros(params.numAgents*params.numAds,params.numAgents);
%             const(:,1) = [ones(params.numAgents,1);zeros(params.numAgents*params.numAds-params.numAgents,1)];
%
%     for i = 1:params.numAds
%
%     end;

%% Optimization Problem


% Separate A and B
A = sparse(Q_mat(1: params.numAds*params.numAgents, 1: params.numAds*params.numAgents));

% Check for availability of A^-1
%CheckInv = abs(eigs(A,1,'LM'))/abs(eigs(A,1,'SM')); %Large condition numbers indicate a nearly singular matrix.
CheckInv = condest(A);
if CheckInv > 1e5
    HasInverse = false; 
    fprintf('\t\t inv(A) not available!\r\n'); 
else
    HasInverse = true;
end
B_coef =  Q_mat(1: params.numAds*params.numAgents, params.numAds*params.numAgents +1 : end);
W_coef = kron(matrixParams.Alpha_agentAd .* (1-matrixParams.Eps_agentAd),M);
