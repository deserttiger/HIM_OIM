function M = generate_M (numAds)
 
M = zeros(numAds);

for i = 1:numAds
    a = rand(1,numAds);
    a = a./ sum(a);
    a(1) = [];
    b = cat(2,0,a);
    b = circshift(b, [0,i-1]);
    M(i,:) = b;
end

M = M + 1*eye(size(M));
for i = 1:numAds
    M(i,:) = M(i,:)./sum(M(i,:));
end;

M = (M+M')/2;