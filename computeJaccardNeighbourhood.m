function JaccardMatrix = computeJaccardNeighbourhood(MethodsStruct,Net)

n = length (MethodsStruct);
JaccardMatrix = zeros(n);

for i = 1:n
    for j = i+1:n             
        aveJaccardSimilarity = 0 ;
        U1 = MethodsStruct(i).U;
        U2 = MethodsStruct(j).U; 
        if isempty (U1) || isempty (U2)
            continue;
        end
        for iAd = 1:size(U1,1)
            indUser1 = find(U1(iAd,:)>0);
            indUser1=  cat(1,indUser1',find(Net(indUser1,:)));
            indUser2 = find(U2(iAd,:)>0);
            indUser2=  cat(1,indUser2',find(Net(indUser2,:)));
            jacc = length(intersect(indUser1,indUser2))  / (length(union(indUser1,indUser2))+eps);
            aveJaccardSimilarity = aveJaccardSimilarity + jacc;
        end;
        aveJaccardSimilarity = aveJaccardSimilarity / (size(U1,1)+eps);
        JaccardMatrix(i,j) = aveJaccardSimilarity;
        
    end;
end;

JaccardMatrix = JaccardMatrix + JaccardMatrix';