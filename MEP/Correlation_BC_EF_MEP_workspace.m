% clear all prepare all the data
load('T:\Experimental Data\2021-10 CHASMEC\Results\simnibs\D_XML_SIMNIBS.mat')
load('T:\Experimental Data\2021-10 CHASMEC\Results\simnibs\E1_XML_SIMNIBS.mat')
load('T:\Experimental Data\2021-10 CHASMEC\Results\simnibs\E2_XML_SIMNIBS.mat')
load('T:\Experimental Data\2021-10 CHASMEC\Results\simnibs\R_XML_SIMNIBS.mat')
E1(:,6)=[19.2000   24.5100   19.4000   21.7700   25.0300   20.4700   27.8100   30.7400   24.0200   29.5800]';%Coil to cortex distance mm
E2(:,6)=[21.1100   18.0300   24.5100   22.9600    27.1200  20.8400  17.5000   23.4600   23.0400      27.5200 28.8200]';%Coil to cortex distance mm
D(:,6)=[23.1000   17.1800   25.9900   23.0700   18.9400   21.3900   20.2100   27.0800   25.8800   22.6700   24.7100   23.4700 20.4700   17.1400   27.1800   29.3900   24.8000   24.9600   25.8300]
R(:,6)=[19.2000   19.8700   17.2600   25.5800   24.9900   20.2000   20.3100   19.9300   23.0200   20.0800   21.9600   18.1800 27.4600   28.4600   21.5500]

Ridx=[1 2 7 8 9 10 11 12 13 14 15 16 17 19 20] % not subject ID ,Id accroding to the Intensity file
Didx=[3 4 5 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23]
E1idx=[1 8  14 17 20 22 24 26 28 29 ]
E2idx=[2 5 9 12 15 16 18 19 21 25 27]
Eall_idx=[E1idx,E2idx]
All_Emagn=[];
labelname={'Increase1','Decreased','Random'}
load('T:\Experimental Data\2021-10 CHASMEC\Results\HCP.mat')
MEP_E=load('T:\Experimental Data\2021-10 CHASMEC\Results\SPall_E.mat')
MEP_D=load('T:\Experimental Data\2021-10 CHASMEC\Results\SPall_D.mat')
MEP_R=load('T:\Experimental Data\2021-10 CHASMEC\Results\SPall_R.mat')
%ID for the BC
E1IDX=[HCP{1}(1,:);HCP{1}(5,:);HCP{1}(9,:);HCP{1}(11,:);HCP{1}(12,:);HCP{1}(13,:);HCP{1}(15,:);HCP{1}(16,:);HCP{1}(17,:);HCP{1}(18,:)]
E2IDX=[HCP{2}(1,:);HCP{2}(2,:);HCP{2}(4,:);HCP{2}(5,:);HCP{2}(6,:);HCP{1}(10,:);HCP{2}(7,:);HCP{2}(8,:);HCP{2}(9,:);HCP{2}(10,:);HCP{2}(11,:)]
Eall_BC=[E1IDX;E2IDX]
DIDX_BC=[HCP{4}(1,:);HCP{4}(2,:);HCP{3}(1,:);HCP{4}(3,:);HCP{3}(6,:);HCP{4}(4,:);HCP{3}(7,:);HCP{3}(8,:);HCP{3}(9,:);HCP{3}(10,:);HCP{4}(5,:);HCP{4}(6,:);HCP{3}(11,:);HCP{3}(12,:);HCP{3}(13,:);HCP{3}(14,:);HCP{3}(15,:);HCP{4}(7,:);HCP{3}(16,:)]
RIDX_BC=[HCP{5}(1,:);HCP{5}(2,:);HCP{5}(7,:);HCP{5}(8,:);HCP{5}(9,:);HCP{5}(10,:);HCP{5}(11,:);HCP{5}(12,:);HCP{5}(13,:);HCP{5}(14,:);HCP{5}(15,:);HCP{5}(16,:);HCP{5}(17,:);HCP{5}(19,:);HCP{5}(20,:)]
%% for the MEP correaltion with E-magn
Edata=MEP_E.SPall{2,5}-MEP_E.SPall{2,1}
Ddata=MEP_D.SPall{2,5}-MEP_D.SPall{2,1}
Rdata=MEP_R.SPall{2,3}-MEP_R.SPall{2,1}

Epostdata=MEP_E.SPall{2,3}-MEP_E.SPall{2,1}
Dpostdata=MEP_D.SPall{2,3}-MEP_D.SPall{2,1}
Rpostdata=MEP_R.SPall{2,2}-MEP_R.SPall{2,1}




%% for the loop E-magn with HCP data
for sinx=1:3
    
    rname=dir(['T:\Experimental Data\2021-10 CHASMEC\Datacollection\Workspace\',labelname{sinx}])
    rname(1:2,:)=[];
    
    SMA_int=[]
    M1_ins=[]
    for j=1:length(rname)
        
        load(['T:\Experimental Data\2021-10 CHASMEC\Datacollection\Workspace\',labelname{sinx},'\',rname(j).name])
        SMA_int=[SMA_int, SMA_amplitude]
        M1_ins=[M1_ins,M1_amplitude]
        
    end
    
    MSO=[100 90 80 70 60 50 40 30 20 10]';
    Didt=[93 83 75 63 55 45 35 25 17 7]';
    
    X = [ones(length(MSO),1) MSO];
    b = X\Didt
    
    ypred = [ones(length(SMA_int'),1) SMA_int'];
    yCalc2 = ypred*b;
    
    a=struct2cell(rname)';
    b=cell2table(a);
    T=table(b.a1,SMA_int',M1_ins',yCalc2)
    T.Properties.VariableNames = ["Session","SMA Intesntiy","M1 Intensity",'DiDt']
    filename = ['intensity_',labelname{sinx},'.xlsx'];
    writetable(T,filename,'Sheet','Rawdata','Range','A1')
    
    if sinx==1
        Eall=[E1;E2];
        Didt_value_E=SMA_int(Eall_idx)'.*Eall
        Didt_value_E(:,6)=Eall(:,6)
        Didt_value_E(:,7)=SMA_int(Eall_idx)'
        DataMEP=Edata(Eall_idx)
        DatapostMEP=Epostdata(Eall_idx)
        %save the ture emgn machting the Simnibs data
        
        
        % MEP diff with Emagn
        close all
        figure
        subplot(1,3,1)
        [a,b]=corrcoef([Didt_value_E(:,1) DataMEP'])
        
        s=scatter(Didt_value_E(:,1),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_E(:,1),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_E(:,1));
        
        hold on;
        plot(Didt_value_E(:,1), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.45*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Mean E-Magn from left SMA')
        
        subplot(1,3,2)
        [a,b]=corrcoef([Didt_value_E(:,2)  DataMEP'])
        
        s=scatter(Didt_value_E(:,2),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_E(:,2),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_E(:,2));
        
        hold on;
        plot(Didt_value_E(:,2), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Max E-Magn from left SMA')
        
        subplot(1,3,3)
        [a,b]=corrcoef([Didt_value_E(:,3)  DataMEP'])
        
        s=scatter(Didt_value_E(:,3),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_E(:,3),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_E(:,3));
        
        hold on;
        plot(Didt_value_E(:,3), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Max E-Magn from all regions')
        sgtitle('Increase')
        set(gcf,'position',[0,0,1200,300])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\MEP_diff_Increase_Correlation between the E-Magn and.png','Resolution',500)
        
        %Emagn Vs MEP diff in pre and POST
        close all
        
        figure
        subplot(1,2,1)
        
        [a1,b1]=corrcoef([Didt_value_E(:,4) DatapostMEP'])
        s=scatter(Didt_value_E(:,4),DatapostMEP',60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        hold on
        coefficients1 = polyfit(Didt_value_E(:,4),DatapostMEP', 1);
        yFit1 = polyval(coefficients1, Didt_value_E(:,4));
        hold on
        plot(Didt_value_E(:,4), yFit1, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        hold on
        text(0.4*100,0.53,['r=',num2str(round(a1(2),3)),newline,'p=',num2str(round(b1(2),3))])
        ylim([-0.7 0.7])
        
        xlabel('E-Magnitude(V/m)')
        ylabel('Post-Pre MEPs(Log10)')
        % title(' Mean E-Magn from left SMA')
        
        
        subplot(1,2,2)
        
        [a,b]=corrcoef([Didt_value_E(:,4) DataMEP'])
        
        s=scatter(Didt_value_E(:,4),DataMEP',60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_E(:,4),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_E(:,4));
        
        hold on;
        plot(Didt_value_E(:,4), yFit, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        
        
        hold on
        text(0.4*100,0.53,['r=',num2str(round(a(2),3)),newline,'p=',num2str(round(b(2),3))])
        
        ylim([-0.7 0.7])
        xlabel('E-Magnitude(V/m)')
        ylabel('Post30-Pre MEPs(Log10)')
        % title(' Mean E-Magn from left SMA')
        set(gcf,'position',[0,0,600,220])
        sgtitle('Increase')
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\PRE VS POST MEP_diff_Increase_Correlation.png','Resolution',500)
        
        
        
        
        
        
        
        
        % EMagn with brain connecitvity
        close all
        subplot(3,1,1)
        scatter(1:length(Eall),Didt_value_E(:,1),"filled")
        hold on
        yline(mean(Didt_value_E(:,1)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Mean Electric field magnitude in left SMA')
        subplot(3,1,2)
        scatter(1:length(Eall),Didt_value_E(:,2),"filled")
        hold on
        yline(mean(Didt_value_E(:,2)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in left SMA')
        sgtitle('Increase')
        
        hold on
        subplot(3,1,3)
        scatter(1:length(Eall),Didt_value_E(:,3),"filled")
        hold on
        yline(mean(Didt_value_E(:,3)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in all region')
        sgtitle('Increase')
        
        
        set(gcf,'position',[0,0,500,750])
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\Increase.png','Resolution',500)
        
        
        % plot the coordinate on SMA
        
        close all
        subplot(2,1,1)
        scatter(1:length(Eall),Didt_value_E(:,4),"filled")
        hold on
        yline(mean(Didt_value_E(:,4)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in MNI')
        subplot(2,1,2)
        scatter(1:length(Eall),Didt_value_E(:,5),"filled")
        hold on
        yline(mean(Didt_value_E(:,5)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Mean Electric field magnitude in MNI')
        sgtitle('Increase')
        set(gcf,'position',[0,0,500,500])
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\MNI_Coor_Increase.png','Resolution',500)
        
        
        
        All_Emagn=Didt_value_E
        % coorrealtion with BC
        Diff_BC=Eall_BC(:,2)-Eall_BC(:,1)
        
        close all
        figure
        subplot(1,3,1)
        [a,b]=corrcoef([Didt_value_E(:,1)  Diff_BC])
        
        s=scatter(Didt_value_E(:,1),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_E(:,1),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_E(:,1));
        
        hold on;
        plot(Didt_value_E(:,1), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.4*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Mean E-Magn from left SMA')
        
        subplot(1,3,2)
        [a,b]=corrcoef([Didt_value_E(:,2)  Diff_BC])
        
        s=scatter(Didt_value_E(:,2),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_E(:,2),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_E(:,2));
        
        hold on;
        plot(Didt_value_E(:,2), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Max E-Magn from left SMA')
        
        subplot(1,3,3)
        [a,b]=corrcoef([Didt_value_E(:,3)  Diff_BC])
        
        s=scatter(Didt_value_E(:,3),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_E(:,3),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_E(:,3));
        
        hold on;
        plot(Didt_value_E(:,3), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Max E-Magn from all regions')
        sgtitle('Increase')
        set(gcf,'position',[0,0,1200,300])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\Correlation between the E-Magn and icoh diff.png','Resolution',500)
        
        
        % close all
        close all
        figure
        
        [a,b]=corrcoef([Didt_value_E(:,4)  Diff_BC])
        
        s=scatter(Didt_value_E(:,4),Diff_BC,60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_E(:,4),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_E(:,4));
        
        hold on;
        plot(Didt_value_E(:,4), yFit, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        hold on
        text(0.6*100,0.04,['r=',num2str(round(a(2),3)),newline,'p=',num2str(round(b(2),3))])
        xlabel('E-Magnitude(V/m)')
        ylabel('Post30-Pre iCOH')
        title(' Increase')
        set(gcf,'position',[0,0,240,200])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\final_Increase_Correlation between the E-Magn and Connecitvity.png','Resolution',500)
        
        
    elseif sinx==2
        
        Didt_value_D=SMA_int(Didx)'.*D
        Didt_value_D(:,6)=D(:,6)
        Didt_value_D(:,7)=SMA_int(Didx)'
        
        DataMEP=Ddata(Didx)
        DatapostMEP=Dpostdata(Didx)
        % MEP with Emagn
        close all
        figure
        subplot(1,3,1)
        [a,b]=corrcoef([Didt_value_D(:,1) DataMEP'])
        
        s=scatter(Didt_value_D(:,1),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_D(:,1),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_D(:,1));
        
        hold on;
        plot(Didt_value_D(:,1), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.45*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Mean E-Magn from left SMA')
        
        subplot(1,3,2)
        [a,b]=corrcoef([Didt_value_D(:,2)  DataMEP'])
        
        s=scatter(Didt_value_D(:,2),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_D(:,2),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_D(:,2));
        
        hold on;
        plot(Didt_value_D(:,2), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Max E-Magn from left SMA')
        
        subplot(1,3,3)
        [a,b]=corrcoef([Didt_value_D(:,3)  DataMEP'])
        
        s=scatter(Didt_value_D(:,3),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_D(:,3),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_D(:,3));
        
        hold on;
        plot(Didt_value_D(:,3), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Max E-Magn from all regions')
        sgtitle('Decrease')
        set(gcf,'position',[0,0,1200,300])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\MEP diff_deCreased_Correlation between the E-Magn and.png','Resolution',500)
        % Emgan with PRe Vs POST MEP DIFF
        
        
        close all
        
        figure
        subplot(1,2,1)
        
        [a1,b1]=corrcoef([Didt_value_D(:,4) DatapostMEP'])
        s=scatter(Didt_value_D(:,4),DatapostMEP',60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        hold on
        coefficients1 = polyfit(Didt_value_D(:,4),DatapostMEP', 1);
        yFit1 = polyval(coefficients1, Didt_value_D(:,4));
        hold on
        plot(Didt_value_D(:,4), yFit1, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        hold on
        text(0.55*100,0.5,['r=',num2str(round(a1(2),3)),newline,'p=',num2str(round(b1(2),3))])
        ylim([-0.8 0.8])
        
        xlabel('E-Magnitude(V/m)')
        ylabel('Post-Pre MEPs(Log10)')
        % title(' Mean E-Magn from left SMA')
        
        
        subplot(1,2,2)
        
        [a,b]=corrcoef([Didt_value_D(:,4) DataMEP'])
        
        s=scatter(Didt_value_D(:,4),DataMEP',60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_D(:,4),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_D(:,4));
        
        hold on;
        plot(Didt_value_D(:,4), yFit, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        
        
        hold on
        text(0.55*100,0.5,['r=',num2str(round(a(2),3)),newline,'p=',num2str(round(b(2),3))])
        
        ylim([-0.8 0.8])
        xlabel('E-Magnitude(V/m)')
        ylabel('Post30-Pre MEPs(Log10)')
        % title(' Mean E-Magn from left SMA')
        set(gcf,'position',[0,0,600,220])
        sgtitle('Decrease')
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\PRE VS POST MEP_diff_Decrease_Correlation.png','Resolution',500)
        
        
        %Emagn with HCP
        close all
        subplot(3,1,1)
        scatter(1:length(D),Didt_value_D(:,1),"filled")
        hold on
        yline(mean(Didt_value_D(:,1)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Mean Electric field magnitude in left SMA')
        subplot(3,1,2)
        scatter(1:length(D),Didt_value_D(:,2),"filled")
        hold on
        yline(mean(Didt_value_D(:,2)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in in left SMA')
        
        
        hold on
        subplot(3,1,3)
        scatter(1:length(D),Didt_value_D(:,3),"filled")
        hold on
        yline(mean(Didt_value_D(:,3)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in all region')
        sgtitle('Decrease')
        
        
        set(gcf,'position',[0,0,500,750])
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\Decrease.png','Resolution',500)
        All_Emagn=[All_Emagn;Didt_value_D]
        % plot the coordinate on SMA
        
        close all
        subplot(2,1,1)
        scatter(1:length(D),Didt_value_D(:,4),"filled")
        hold on
        yline(mean(Didt_value_D(:,4)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in MNI')
        subplot(2,1,2)
        scatter(1:length(D),Didt_value_D(:,5),"filled")
        hold on
        yline(mean(Didt_value_D(:,5)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Mean Electric field magnitude in MNI')
        sgtitle('Decrease')
        set(gcf,'position',[0,0,500,550])
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\MNI_Coor_Decrease.png','Resolution',500)
        
        % coorrealtion with BC
        Diff_BC=DIDX_BC(:,2)-DIDX_BC(:,1)
        
        close all
        figure
        subplot(1,3,1)
        [a,b]=corrcoef([Didt_value_D(:,1)  Diff_BC])
        
        s=scatter(Didt_value_D(:,1),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_D(:,1),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_D(:,1));
        
        hold on;
        plot(Didt_value_D(:,1), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.4*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Mean E-Magn from left SMA')
        
        subplot(1,3,2)
        [a,b]=corrcoef([Didt_value_D(:,2)  Diff_BC])
        
        s=scatter(Didt_value_D(:,2),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_D(:,2),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_D(:,2));
        
        hold on;
        plot(Didt_value_D(:,2), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Max E-Magn from left SMA')
        
        subplot(1,3,3)
        [a,b]=corrcoef([Didt_value_D(:,3)  Diff_BC])
        
        s=scatter(Didt_value_D(:,3),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_D(:,3),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_D(:,3));
        
        hold on;
        plot(Didt_value_D(:,3), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Max E-Magn from all regions')
        sgtitle('Decrease')
        set(gcf,'position',[0,0,1200,300])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\_Decrease_Correlation between the E-Magn and icoh diff.png','Resolution',500)
        
        % close all
        close all
        figure
        
        [a,b]=corrcoef([Didt_value_D(:,4)  Diff_BC])
        
        s=scatter(Didt_value_D(:,4),Diff_BC,60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_D(:,4),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_D(:,4));
        
        hold on;
        plot(Didt_value_D(:,4), yFit, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        hold on
        text(0.55*100,-0.04,['r=',num2str(round(a(2),3)),newline,'p=',num2str(round(b(2),3))])
        xlabel('E-Magnitude(V/m)')
        ylabel('Post30-Pre iCOH')
        title(' Decrease')
        set(gcf,'position',[0,0,240,200])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\final_Decrease_Correlation between the E-Magn and Connecitvity.png','Resolution',500)
        
        
        
    elseif sinx==3
        Didt_value_R=SMA_int(Ridx)'.*R
        Didt_value_R(:,6)=R(:,6) % put the c2c distance into the matrix
        Didt_value_R(:,7)=SMA_int(Ridx)'% put the SMA intensity to the matrix
        
        DataMEP=Rdata(Ridx)
        DatapostMEP=Rpostdata(Ridx)
        % MEP diff with Emagn
        close all
        figure
        subplot(1,3,1)
        [a,b]=corrcoef([Didt_value_R(:,1) DataMEP'])
        
        s=scatter(Didt_value_R(:,1),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_R(:,1),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_R(:,1));
        
        hold on;
        plot(Didt_value_R(:,1), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.45*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Mean E-Magn from left SMA')
        
        subplot(1,3,2)
        [a,b]=corrcoef([Didt_value_R(:,2)  DataMEP'])
        
        s=scatter(Didt_value_R(:,2),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_R(:,2),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_R(:,2));
        
        hold on;
        plot(Didt_value_R(:,2), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Max E-Magn from left SMA')
        
        subplot(1,3,3)
        [a,b]=corrcoef([Didt_value_R(:,3)  DataMEP'])
        
        s=scatter(Didt_value_R(:,3),DataMEP','filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_R(:,3),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_R(:,3));
        
        hold on;
        plot(Didt_value_R(:,3), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.4,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('MEP diff')
        title(' Max E-Magn from all regions')
        sgtitle('Random')
        set(gcf,'position',[0,0,1200,300])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\MEP_diff_Random_Correlation between the E-Magn and.png','Resolution',500)
        
        % Emgan with PRe Vs POST MEP DIFF
        
        
        close all
        
        figure
        subplot(1,2,1)
        
        [a1,b1]=corrcoef([Didt_value_R(:,4) DatapostMEP'])
        s=scatter(Didt_value_R(:,4),DatapostMEP',60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        hold on
        coefficients1 = polyfit(Didt_value_R(:,4),DatapostMEP', 1);
        yFit1 = polyval(coefficients1, Didt_value_R(:,4));
        hold on
        plot(Didt_value_R(:,4), yFit1, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        hold on
        text(0.7*100,0.5,['r=',num2str(round(a1(2),3)),newline,'p=',num2str(round(b1(2),3))])
        ylim([-0.8 0.8])
        
        xlabel('E-Magnitude(V/m)')
        ylabel('Post-Pre MEPs(Log10)')
        % title(' Mean E-Magn from left SMA')
        
        
        subplot(1,2,2)
        
        [a,b]=corrcoef([Didt_value_R(:,4) DataMEP'])
        
        s=scatter(Didt_value_R(:,4),DataMEP',60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_R(:,4),DataMEP', 1);
        yFit = polyval(coefficients, Didt_value_R(:,4));
        
        hold on;
        plot(Didt_value_R(:,4), yFit, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        
        
        hold on
        text(0.7*100,0.5,['r=',num2str(round(a(2),3)),newline,'p=',num2str(round(b(2),3))])
        
        ylim([-0.8 0.8])
        xlabel('E-Magnitude(V/m)')
        ylabel('Post30-Pre MEPs(Log10)')
        % title(' Mean E-Magn from left SMA')
        set(gcf,'position',[0,0,620,220])
        sgtitle('Random')
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\PRE VS POST MEP_diff_Random_Correlation.png','Resolution',500)
        
        
        
        %Emagn with HCP
        close all
        subplot(3,1,1)
        scatter(1:length(R),Didt_value_R(:,1),"filled")
        hold on
        yline(mean(Didt_value_R(:,1)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Mean Electric field magnitude in left SMA')
        subplot(3,1,2)
        scatter(1:length(R),Didt_value_R(:,2),"filled")
        hold on
        yline(mean(Didt_value_R(:,2)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in in left SMA')
        
        hold on
        subplot(3,1,3)
        scatter(1:length(R),Didt_value_R(:,3),"filled")
        hold on
        yline(mean(Didt_value_R(:,3)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in all region')
        
        
        sgtitle('Random')
        set(gcf,'position',[0,0,500,550])
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\Random.png','Resolution',500)
        
        % plot the coordinate on SMA
        
        close all
        subplot(2,1,1)
        scatter(1:length(R),Didt_value_R(:,4),"filled")
        hold on
        yline(mean(Didt_value_R(:,4)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Max Electric field magnitude in MNI')
        subplot(2,1,2)
        scatter(1:length(R),Didt_value_R(:,5),"filled")
        hold on
        yline(mean(Didt_value_R(:,5)),'r')
        xlabel('Subject')
        ylabel('E-magnitude(V/m)')
        title('Mean Electric field magnitude in MNI')
        sgtitle('Random')
        set(gcf,'position',[0,0,500,550])
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\MNI_Coor_Random.png','Resolution',500)
        
        
        
        
        
        
        
        All_Emagn=[All_Emagn;Didt_value_R]
        %Conn for Random
        Diff_BC=RIDX_BC(:,2)-RIDX_BC(:,1)
        
        close all
        figure
        subplot(1,3,1)
        [a,b]=corrcoef([Didt_value_R(:,1)  Diff_BC])
        
        s=scatter(Didt_value_R(:,1),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_R(:,1),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_R(:,1));
        
        hold on;
        plot(Didt_value_R(:,1), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.4*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Mean E-Magn from left SMA')
        
        subplot(1,3,2)
        [a,b]=corrcoef([Didt_value_R(:,2)  Diff_BC])
        
        s=scatter(Didt_value_R(:,2),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_R(:,2),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_R(:,2));
        
        hold on;
        plot(Didt_value_R(:,2), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Max E-Magn from left SMA')
        
        subplot(1,3,3)
        [a,b]=corrcoef([Didt_value_R(:,3)  Diff_BC])
        
        s=scatter(Didt_value_R(:,3),Diff_BC,'filled')
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_R(:,3),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_R(:,3));
        
        hold on;
        plot(Didt_value_R(:,3), yFit, 'r-', 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.03,['R=',num2str(a(2)),newline,'p=',num2str(b(2))])
        xlabel('E-Magn(V/m)')
        ylabel('Icoh diff')
        title(' Max E-Magn from all regions')
        sgtitle('Random')
        set(gcf,'position',[0,0,1200,300])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\Random_Correlation between the E-Magn and icoh diff.png','Resolution',500)
        % FOR MNI, corr with Magn
        close all
        figure
        
        [a,b]=corrcoef([Didt_value_R(:,4)  Diff_BC])
        
        s=scatter(Didt_value_R(:,4),Diff_BC,60,"filled",'MarkerFaceColor','k','MarkerEdgeColor','k',...
            'MarkerFaceAlpha',.5,'MarkerEdgeAlpha',.5)
        % s.AlphaData = 0.7*ones(1,length(Phase_precent_all(:,1)));
        % s.MarkerFaceAlpha = 'flat';
        hold on
        coefficients = polyfit(Didt_value_R(:,4),Diff_BC, 1);
        yFit = polyval(coefficients, Didt_value_R(:,4));
        
        hold on;
        plot(Didt_value_R(:,4), yFit, 'Color', [0.8500 0.3250 0.0980 0.5], 'LineWidth', 2);
        
        hold on
        text(0.8*100,0.03,['r=',num2str(round(a(2),3)),newline,'p=',num2str(round(b(2),3))])
        xlabel('E-Magnitude(V/m)')
        ylabel('Post30-Pre iCOH')
        title(' Random')
        set(gcf,'position',[0,0,240,200])
        
        
        exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\final_Random_Correlation between the E-Magn and Connecitvity.png','Resolution',500)
        
        
        
        
        
        
        
        
        
        
        
    end
end

%%  over all plot
close all
subplot(1,3,1)
scatter(1:length(All_Emagn(1:21,1)),All_Emagn(1:21,1),100,[0.8500 0.3250 0.0980],"filled")
hold on

scatter(1:length(All_Emagn(22:40,1)),All_Emagn(22:40,1),100,[0 0.4470 0.7410],"filled")

hold on
scatter(1:length(All_Emagn(41:55,1)),All_Emagn(41:55,1),100,[0.4660 0.6740 0.1880],"filled")

xlabel('Subject')
ylabel('E-magnitude(V/m)')
title('Mean Electric field magnitude in left SMA')
legend({'Increase','Decrease','Random'})

subplot(1,3,2)
scatter(1:length(All_Emagn(1:21,2)),All_Emagn(1:21,2),100,[0.8500 0.3250 0.0980],"filled")
hold on

scatter(1:length(All_Emagn(22:40,2)),All_Emagn(22:40,2),100,[0 0.4470 0.7410],"filled")

hold on
scatter(1:length(All_Emagn(41:55,2)),All_Emagn(41:55,2),100,[0.4660 0.6740 0.1880],"filled")

xlabel('Subject')
ylabel('E-magnitude(V/m)')
title('Max Electric field magnitude in left SMA')
legend({'Increase','Decrease','Random'})


subplot(1,3,3)
scatter(1:length(All_Emagn(1:21,3)),All_Emagn(1:21,3),100,[0.8500 0.3250 0.0980],"filled")
hold on

scatter(1:length(All_Emagn(22:40,3)),All_Emagn(22:40,3),100,[0 0.4470 0.7410],"filled")

hold on
scatter(1:length(All_Emagn(41:55,3)),All_Emagn(41:55,3),100,[0.4660 0.6740 0.1880],"filled")

xlabel('Subject')
ylabel('E-magnitude(V/m)')
title('Min Electric field magnitude in Left SMA')
legend({'Increase','Decrease','Random'})

set(gcf,'position',[0,0,1550,400])
exportgraphics(gcf,'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\All conditions_color.png','Resolution',500)


%% show the mean and STD
close all

% Define
conditions = {'Increase','Decrease','Random'};
metrics = {'Mean in left SMA','Max in left SMA','Min in left SMA','Max in the whole brain'};
colors = [0.8500 0.3250 0.0980;   % Increase - muted red
    0 0.4470 0.7410;        % Decrease - blue
    0.4660 0.6740 0.1880];  % Random - green

% Preallocate
meanMatrix = zeros(4,3); % rows: metric, cols: condition
stdMatrix = zeros(4,3);

% Compute means and stds
for cond = 1:3
    switch cond
        case 1
            data = All_Emagn(1:21, :);      % Increase
        case 2
            data = All_Emagn(22:40, :);     % Decrease
        case 3
            data = All_Emagn(41:55, :);     % Random
    end
    for metric = 1:4
        values = data(:, metric);
        meanMatrix(metric, cond) = mean(values);
        stdMatrix(metric, cond) = std(values);
    end
end

% Bar plot
figure('Color','w')
hold on
b = bar(meanMatrix, 'grouped', 'BarWidth', 0.75);

% Color bars
for i = 1:3
    b(i).FaceColor = colors(i,:);
    b(i).EdgeColor = 'none';
end

% Add error bars
numGroups = size(meanMatrix, 1);
numBars = size(meanMatrix, 2);
groupWidth = min(0.8, numBars/(numBars + 1.5));
for i = 1:numBars
    x = (1:numGroups) - groupWidth/2 + (2*i-1) * groupWidth / (2*numBars);
    errorbar(x, meanMatrix(:,i), stdMatrix(:,i), 'k', ...
        'LineStyle', 'none', 'LineWidth', 1.5, 'CapSize', 10);
end

% Beautify axes
xticks(1:4)
xticklabels(metrics)
xtickangle(0)
ylabel('E-magnitude (V/m)', 'FontWeight','bold', 'FontSize', 14)
title('Group-Level Electric Field Magnitudes', 'FontWeight','bold', 'FontSize', 16)
set(gca, 'FontSize', 13, 'Box', 'off', 'LineWidth', 1.2)
ylim padded
grid on
set(gca,'GridAlpha', 0.2)

% Legend
lgd = legend(conditions, 'Location','northwest');
lgd.FontSize = 12;
lgd.Box = 'off';

% Set figure size for publication
set(gcf, 'Position', [200 200 800 300])

% Export
exportgraphics(gcf, ...
    'T:\Experimental Data\2021-10 CHASMEC\SIMNIBS\Corr_SIMNIBS_HCP\Efield_Bar_MeasuresByCondition_Publication.png', ...
    'Resolution', 600)  % 600 DPI for print
