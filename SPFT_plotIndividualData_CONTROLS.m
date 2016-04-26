function SPFT_plotIndividualData_CONTROLS(theDataSMP,plotName,yAxisName,SCALEX)
figure('name',plotName);
%plot((theDataLRN),'bo-','linewidth',1);
%hold on;
plot((theDataSMP),'go-','linewidth',1);
plot([9.5 9.5], [min(nanmean(theDataSMP)),max(nanmean(theDataSMP))],'k:');
plot([18.5 18.5], [min(nanmean(theDataSMP)),max(nanmean(theDataSMP))],'k:');
plot([27.5 27.5], [min(nanmean(theDataSMP)),max(nanmean(theDataSMP))],'k:');
plot([36.5 36.5], [min(nanmean(theDataSMP)),max(nanmean(theDataSMP))],'k:');
plot([45.5 45.5], [min(nanmean(theDataSMP)),max(nanmean(theDataSMP))],'k:');
plot([54.5 54.5], [min(nanmean(theDataSMP)),max(nanmean(theDataSMP))],'k:');

xlabel('Trial');
ylabel(yAxisName);
if SCALEX
    xlim([0,length(theDataSMP)+1])
end
end