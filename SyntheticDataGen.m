function Net = SyntheticDataGen(numInitAgents)

ld = 0.9; %0.1:0.1:0.8;   % the parameter for link density
dh = 0.8;        % the paramenter determines the disassortativity (0~0.5)----contrast to homophily
attrNoise = 0.2;
numObjs = 5;
attrSize = 10;
numAct = 1;  % for the 'power-law' synthetic generator,
numGroups = 4;

[Net,Attributes,labelVec] = NetGeneration(numInitAgents,ld,dh,numGroups,attrNoise,numObjs,attrSize,numAct);