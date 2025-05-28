%% get the mean coordinate from the Localite matrix
clear all;
All_conds={'E1_XML','E2_XML','D_XML','R_XML'};
DistanceALL={};
AllSMA_DISTANCE={};


for j=1:4
    
    subname=dir(['Z:\Experimental Data\2021-10 CHASMEC\Datacollection\Localite\',All_conds{j}])
    subname(1:2,:)=[];
    Distance_Conds={};
    MeanDistance=[];
    
    
    Average_CoodSMA_all=[];
    DIS_XYZ=[];
    DIS_XYZ2=[]
    DIS_XYZ3=[];
    DIS_XYZ4=[];
    AVGSMA_all=[];
    
    
    SMAcoor=[];
    Czcoor=[];
    exname={};
    for f=1:length(subname)
        clear mri  seg  bnd  headmodel  mriras  mriras2
        
        
        subname2=['Z:\Experimental Data\2021-10 CHASMEC\Datacollection\Localite\',All_conds{j},'\',subname(f).name,'\']
        
        tmsname=dir(subname2)
        tmsname(1:2,:)=[];
        
        
        % find the the right ciol file
        index0=[]
        index1=[]
        
        strindex0='TriggerMarkers_Coil0'
        strindex1='TriggerMarkers_Coil1'
        strindex2='EEGMarkers'
        
        for t=1:length(tmsname)
            
            if contains(tmsname(t).name,strindex0)==1
                
                
                index0ID=tmsname(t).name
                
                
            end

            if contains(tmsname(t).name,strindex1)==1
                
                index1ID=tmsname(t).name
                
                
                
            end
            
            
            if contains(tmsname(t).name,strindex2)==1
                
                index2ID=tmsname(t).name
                
          
            end
    
        end
        
        
        
        M1=readstruct([subname2,index0ID]);
        
        
        SMA=readstruct([subname2,index1ID]);
        
        Cz=readstruct([subname2,index2ID]);
        
        SMABaseline=[];
        M1Baseline=[];
        
        Czbaseline=[];
        
        baselinefinalM1_all=[];
        baselinefinalSMA_all=[];
        baselinefinalSMA_MNI=[];
        neighdipolesSMA_all=[];
        SMAinORI=[];
        M1inORI=[];
        SMAinMNI=[];
        M1inMNI=[];
        
        
        
        SMA_distance_inMNI=[];
        SMA_distance_inMNI2=[];
        SMA_distance_inMNI3=[];
        SMA_distance_inMNI4=[];
        SMA_distance_inMNI5=[];
        SMA_distance_inMNI6=[];
        M1_distance_inMNI=[];
        
        Czx=Cz.Marker(5).ColVec3D.data0Attribute;
        Czy=Cz.Marker(5).ColVec3D.data1Attribute;
        Czz=Cz.Marker(5).ColVec3D.data2Attribute;
        
        if Cz.coordinateSpaceAttribute=='LPS'
            Czcoord=[-Czx -Czy Czz];% RAS
            
        else
            Czcoord=[Czx Czy Czz];
        end
        Czcoor=[Czcoor; Czcoord]
        namecood{f}=SMA.coordinateSpaceAttribute;
        Allmatrix=[]
        parfor k=1:length(SMA.TriggerMarker)
            SMAx=SMA.TriggerMarker(k).Matrix4D.data03Attribute;
            SMAy=SMA.TriggerMarker(k).Matrix4D.data13Attribute;
            SMAz=SMA.TriggerMarker(k).Matrix4D.data23Attribute;
            
            
            
            M1x=M1.TriggerMarker(k).Matrix4D.data03Attribute;
            M1y=M1.TriggerMarker(k).Matrix4D.data13Attribute;
            M1z=M1.TriggerMarker(k).Matrix4D.data23Attribute;
            
            
            
            % distance SMA
            
            
            if SMA.coordinateSpaceAttribute=='LPS'
                SMAcoord=[-SMAx -SMAy SMAz];% RAS
                M1coord=[-M1x  -M1y M1z]
            else
                SMAcoord=[SMAx SMAy SMAz];% RAS
                M1coord=[ M1x  M1y M1z]
            end
            
            
            
            SMAmatrix=[SMA.TriggerMarker(k).Matrix4D.data02Attribute,-SMA.TriggerMarker(k).Matrix4D.data01Attribute,SMA.TriggerMarker(k).Matrix4D.data00Attribute,SMAcoord(1);
                SMA.TriggerMarker(k).Matrix4D.data12Attribute,-SMA.TriggerMarker(k).Matrix4D.data11Attribute,SMA.TriggerMarker(k).Matrix4D.data10Attribute,SMAcoord(2);
                SMA.TriggerMarker(k).Matrix4D.data22Attribute,-SMA.TriggerMarker(k).Matrix4D.data21Attribute,SMA.TriggerMarker(k).Matrix4D.data20Attribute,SMAcoord(3);
                SMA.TriggerMarker(k).Matrix4D.data32Attribute, -SMA.TriggerMarker(k).Matrix4D.data31Attribute, SMA.TriggerMarker(k).Matrix4D.data30Attribute,SMA.TriggerMarker(k).Matrix4D.data33Attribute;
                
                
                
                
                M1matrix=[M1.TriggerMarker(k).Matrix4D.data00Attribute,M1.TriggerMarker(k).Matrix4D.data01Attribute,M1.TriggerMarker(k).Matrix4D.data02Attribute,M1coord(1);
                M1.TriggerMarker(k).Matrix4D.data10Attribute,M1.TriggerMarker(k).Matrix4D.data11Attribute,M1.TriggerMarker(k).Matrix4D.data12Attribute,M1coord(2);
                M1.TriggerMarker(k).Matrix4D.data20Attribute,M1.TriggerMarker(k).Matrix4D.data21Attribute,M1.TriggerMarker(k).Matrix4D.data22Attribute,M1coord(3);
                M1.TriggerMarker(k).Matrix4D.data30Attribute,M1.TriggerMarker(k).Matrix4D.data31Attribute,M1.TriggerMarker(k).Matrix4D.data32Attribute,M1.TriggerMarker(k).Matrix4D.data33Attribute;
                
                
                ]

                baselinefinalM1_all=[baselinefinalM1_all;M1coord];
                baselinefinalSMA_all=[baselinefinalSMA_all;SMAcoord];
                % baselinefinalSMA_MNI=[baselinefinalSMA_MNI;SMApos];
                Allmatrix=[Allmatrix;{subname(f).name,SMAmatrix,M1matrix}]
                
                
        end
    % baselinefinalM1=mean(baselinefinalM1_all(1:300,:));
    % baselinefinalSMA=mean(baselinefinalSMA_all(1:300,:));
    % AllSMA_DISTANCE{j,f}=rmoutliers(SMA_distance_inM9NI);
    
    DIStance=[];
    
    datamids=baselinefinalSMA_all;
    
    SMAindex_out=find(isoutlier(baselinefinalSMA_all)==0)
    
    for m=1:length(datamids)
        DIStance(m)=norm(datamids(m)-[-5 -5 73.5]);
        
    end
    
    
    
    if length(DIStance)>1300
        SMAindex_out=find(isoutlier(DIStance(300:1300))==0);
        Allmatrixtakeout=Allmatrix(300:1300,:)
        AllMat_Final{j,f}=Allmatrixtakeout(SMAindex_out,:);
    else
        SMAindex_out=find(isoutlier(DIStance)==0);
        AllMat_Final{j,f}=Allmatrix(SMAindex_out,:);
    end
    AllMat_Name{j,f}=subname(f).name;
    if length(DIStance)>1300
        SMAOUT=mean(baselinefinalSMA_all(300:1300,:))
    else
        SMAOUT=mean(baselinefinalSMA_all(300:length(DIStance),:))
    end
    
    SMAOUT=mean(baselinefinalSMA_all(SMAindex_out,:))
    SMAcoor=[SMAcoor;SMAOUT]
    exname{f}=subname(f).name
    end
    allccoor_Cz{j}=Czcoor;
    allccoor_SMA{j}=SMAcoor;
    nameLPS{j}=namecood;
    % Distance_Conds={Distance_Conds,[SMABaseline',M1Baseline']}
    DISCz=[];
    for tm=1:length(Czcoor)
        DISCz(tm)=norm(Czcoor(tm,:)-SMAcoor(tm,:))
    end
    
    T=table(exname',round(Czcoor(:,1),4),round(Czcoor(:,2),4), round(Czcoor(:,3),4),round(SMAcoor(:,1),4),round(SMAcoor(:,2),4), round(SMAcoor(:,3),4),DISCz')
    T.Properties.VariableNames = ["Session",'CzX','CzY','CzZ','SMAX','SMAY','SMAZ','Distance_mm']
    filename = [All_conds{j},'_DIS_Cz_SMA.xlsx'];
    writetable(T,filename,'Sheet','Rawdata','Range','A1')
    
end



%% Calculate the Mean

for m=1:10
    
    datav=zeros(4,4)
    for j=1:length(AllMat_Final{1,m}(:,1))
        
        datamid=AllMat_Final{1,m}(:,2);
        datav=datav+datamid{j};
        
    end
    
    DataE=datav/length(AllMat_Final{1,m}(:,1))
    
    AllE_Simnibs{m}=DataE;
    
end


for m=1:12
    
    datav=zeros(4,4)
    for j=1:length(AllMat_Final{2,m}(:,1))
        
        datamid=AllMat_Final{2,m}(:,2);
        datav=datav+datamid{j};
        
    end
    
    DataE=datav/length(AllMat_Final{2,m}(:,1))
    
    AllE2_Simnibs{m}=DataE;
    
end


for m=1:19
    
    datav=zeros(4,4)
    for j=1:length(AllMat_Final{3,m}(:,1))
        
        datamid=AllMat_Final{3,m}(:,2);
        datav=datav+datamid{j};
        
    end
    
    DataE=datav/length(AllMat_Final{3,m}(:,1))
    
    AllD_Simnibs{m}=DataE;
    
end


for m=1:15
    
    datav=zeros(4,4)
    for j=1:length(AllMat_Final{4,m}(:,1))
        
        datamid=AllMat_Final{4,m}(:,2);
        datav=datav+datamid{j};
        
    end
    
    DataE=datav/length(AllMat_Final{4,m}(:,1))
    
    AllR_Simnibs{m}=DataE;
    
end


