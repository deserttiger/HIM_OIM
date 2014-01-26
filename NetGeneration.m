function [Net,Attributes,label] = NetGeneration(numNodes,alpha,dh,numLabels,attrNoise,numObjs,vocabSize,numAct)
% Generate synthetic dataset following the algorithm describe in Bollobas
% "Directed scale-free graphs"
% According to the paper "Link-based classification" by Sen and Getoor

% alpha: is a parameter that controls the number of links in the graph; roughly the final graph should contain
%       (1/(1-alpha))numNodes number of links (for undirected links).
% numObjs: maximum number of words in a node


i = 0;
Net = zeros(numNodes,numNodes);
%label = zeros(numNodes,1);
label = [];
while (i< numNodes)
    if mod(i,100)==1 
        fprintf('node %d\r\n',i);
    end;
    %r = random('unid',numNodes)/numNodes);   % sample r in [0,1] uniformly at random
    r = rand;
    if (r <= alpha && (i~=0 && i ~= 1))  %TODO: Should it not be i~=1??!! Also instead of OR should it not be AND?
        Net = connectNode(Net,i,numLabels,label,dh,numAct);
    else
        [Net,label] = addNode(Net, i, numLabels,label,dh,numAct);
        i = i+1;
    end
end
% % Add Attributes to nodes
% label = label';
Attributes = zeros(numNodes,vocabSize);
% for i =1:numNodes
%     Attributes  = genAttributes(i, numLabels, vocabSize, numObjs, attrNoise, Attributes,label);
% end

function [Net,label] = addNode(Net, i, numLabels, label, dh, numAct)

mu = [0.9,0.6,0.4,0.3];
sigma = [0.05;0.1;0.1;0.05];
v = i+1;
c = chooseNewNodeClass(numLabels);      %can be used to implement a set of class priors.
%In all our experiments with synthetic data we used a set of uniform class priors.
mlinks = 1; %mlinks controls the number of links a new node can make to the existing network nodes.
label(v) = c;

if v>1
    %     if length(label)<numAct
    %         numAct = length(label)-1;
    %     end
    %     for i = 1:numAct
    Cn = chooseClass(c, dh, numLabels, label, v);
    %     if dh==0 && Cn==c
    %         Net;
    %     else
    Net = SFNW(Net, mlinks, Cn, v, label, mu, sigma);
    %     end
    %     end
    
end

function Net = connectNode(Net,i,numLabels,label,dh,numAct)
%N = i+1;                 % number of nodes
mu = [0.9,0.6,0.4,0.3];
sigma = [0.05;0.1;0.1;0.05];
mlinks = 1; %mlinks controls the number of links a new node can make to the existing network nodes.

if length(label)<numAct
    numAct = length(label);
end
for j = 1: numAct
    if i>=1 
        v =  random('unid',i);   % randomly chooose a node from G/ i is the current number of nodes
        c = label(v);
        
        Cn = chooseClass(c, dh , numLabels,label,v);
        Net = SFNW(Net, mlinks,Cn, v,label, mu, sigma);
        %         end
    end
end


function Attributes = genAttributes(v,numLabels,vocabSize,numObjs,attrNoise,Attributes,label)
% numObjs: maximum number of words in a node
for i =1:numObjs
    % sample r uniformly at random
    %r = random('unid',numNodes)/numNodes;
    r = rand;
    if (r <= attrNoise)
        w = ceil(rand * vocabSize);
        % w = random('unid',vocabSize);
        Attributes(v,w) = 1;
    else
        p = (1 + (label(v)-1))/(1+numLabels);
        w = binornd(vocabSize-1,p); % generate binomial random number
        Attributes(v,w+1) = 1;    % label starts from 0
    end
end

function  Cn = chooseClass(c,dh, numLabels,label,v)
% dh specifying the percentage of a node's neighbor that is of the same type
% degree of the candidates (preferental attachement)

tmp =[];
while (isempty(tmp))
    %   r = random('unid',numLabels)/numLabels;   %%% modify
    r = rand;
    if (r >= dh )
        if (~isempty(find(label~=c)))
            ww = setdiff(1:numLabels,c);
            while (isempty(tmp))
                w = random('unid',length(ww));
                tmp = find(label == ww(w));
            end
            Cn = ww(w);
        else
            Cn = c;
            l = setdiff(1:length(label),v);
            tmp = find(label(l) == Cn);
        end
    else
        Cn = c;
        l = setdiff(1:length(label),v);
        tmp = find(label(l) == Cn);
    end
end

function c = chooseNewNodeClass(numLabels)

c = random('unid',numLabels);

function Net = SFNW(Net, mlinks, Cn, v,label,mu,sigma) %Scale-Free Network
% modified from the B-A ScaleFree Network ( Barabasi-Albert model)
% Cn is the label of the node to be connected
% mlinks controls the number of links a new node can make to the existing network nodes.

tp = setdiff(1:length(label),v);
label2 = label(tp);
tmp = find(label2 == Cn);
L = length(tmp);   % save the number of nodes with label Cn

% if (L < mlinks)
%     mlinks = L;
% end

%Net(1:pos,1:pos) = seed;
sumlinks = sum(sum(Net));

pos = v;
linkage = 0;

% generate mlinks for the given node
while linkage ~= mlinks
    t = ceil(rand * length(tmp)); % the index of the chosen node
    rnode = tp(tmp(t));
    deg = sum(Net(:,rnode)) + sum(Net(rnode,:));
    rlink = rand * 1;
    act = normrnd(mu(Cn),sigma(Cn));
    if (sumlinks == 0)
        Net(pos,rnode) = Net(pos,rnode) + 1;
%         Net(pos,rnode) = 1;
        linkage = linkage +1;
        if act >= 0.5
            Net(rnode,pos) = Net(rnode,pos) + 1;
%             Net(rnode,pos) = 1;
        else
            break;
        end
    elseif(rlink < deg / sumlinks) %&& (Net(pos,rnode) ~= 1 && Net(rnode,pos) ~= 1);   %% p = (deg/sumlinks)
        Net(pos,rnode) = Net(pos,rnode) + 1;
%         Net(pos,rnode) = 1;
        linkage = linkage + 1;
        if act >= 0.5
            Net(rnode,pos) = Net(rnode,pos) + 1;
%             Net(rnode,pos) = 1;
        else
            %         %             linkage = linkage + 1;
            %         %             sumlinks = sumlinks + 2;
            %         %             Net(1:pos,1:pos);
            break;
        end
        %         tmp = tmp(setdiff(1:length(tmp),t));
        %         n = n+1;
    end
end





