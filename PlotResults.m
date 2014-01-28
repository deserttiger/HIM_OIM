function PlotResults (ResultFileName) 


load (ResultFileName)
%ResultFileName = 'Results', 'totalAverageResults', 'params', 'simParams', 'matrixParams', 'MethodsStruct', 'TheFirstAgentStructure'

lineWidth = 3;
colors = lines(length(MethodsStruct));
figure(2),

for i = 1:length(MethodsStruct)
    tempMeanValueForProducts = mean(totalAverageResults{i}.Ave);
    tempSTEValueForProducts = 2*mean(totalAverageResults{i}.StE);
    plot(1:round(simParams.numItr/simParams.ResultsIterationFactor),tempMeanValueForProducts(1:end)','color',colors(i,:),'LineWidth',lineWidth);
    %errorbar(1:round(simParams.numItr/simParams.ResultsIterationFactor),tempMeanValueForProducts(1:end)',tempSTEValueForProducts(1:end)','color',colors(i,:),'LineWidth',lineWidth);
    if (i==1)
        hold on,
    end;
end;
hold off;
grid on
names = {MethodsStruct(:).Name};

[legh,objh,outh,outm] = legend(names{:},'Location','NorthWest');
set(objh(1:end/1),'LineWidth',lineWidth)
    xlabel(sprintf('iterations /%d ',simParams.ResultsIterationFactor))
    ylabel('Expectation')
    title( sprintf('Average Desire value'));
    
figure(4),
imagesc(JaccardMatrix),colormap gray
for i = 1:size(JaccardMatrix,1)
    for j= 1:size(JaccardMatrix,2)
        str = sprintf('%.2f',JaccardMatrix(i,j));
        color = [1-JaccardMatrix(i,j),JaccardMatrix(i,j)/2,JaccardMatrix(i,j) ];
        text(j,i,str,'Color',color);
    end;
end;
set(gca(),'XTick',1:length(names))
set( gca(), 'XTickLabel', names )
set(gca(),'YTick',1:length(names))
set( gca(), 'YTickLabel', names )
% title('Jaccard similarity of the methods:\n 1-Random 2-Degree 3-Betweenness 4-HIM 5-OIM 6-PageRank')
colorbar
rotateXLabelsIMGSC( gca(), 45 )