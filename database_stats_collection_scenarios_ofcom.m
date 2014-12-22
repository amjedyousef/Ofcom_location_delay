%   Amjad Yousef Majid  
%   Reference: [1] "Will Dynamic Spectrum Access Drain my
%   Battery?", submitted for publication, July 2014

%   Code development: 

%   Last update: 22 Dec 2014

%   This work is licensed under a Creative Commons Attribution 3.0 Unported
% 
tic;
clear;
close all;
clc;

%%
%Plot parameters
ftsz=16;

%Path to save files (select your own)
my_path='/home/amjed/Documents/Gproject/workspace/data/WSDB_DATA';
type='"AVAIL_SPECTRUM_REQ"';
height='7.5';
no_queries=10; %Select how many queries per location
    
    %Location data
    
    WSDB_data{1}.name='LO'; %LONDON
    WSDB_data{1}.latitude='51.487266';
    WSDB_data{1}.longitude='-0.097707';
    WSDB_data{1}.delay_ofcom=[];
    
    WSDB_data{2}.name='OX'; %Oxted
    WSDB_data{2}.latitude='51.238602';
    WSDB_data{2}.longitude='-0.012563';
    WSDB_data{2}.delay_ofcom=[];
    
    WSDB_data{3}.name='ST'; %Stroud
    WSDB_data{3}.latitude='51.741383';
    WSDB_data{3}.longitude='-2.187856';
    WSDB_data{3}.delay_ofcom=[];
    
    WSDB_data{4}.name='SH'; %Sharrow
    WSDB_data{4}.latitude='53.371760';
    WSDB_data{4}.longitude='-1.484731';
    WSDB_data{4}.delay_ofcom=[];
     
    WSDB_data{5}.name='SA'; %Sale
    WSDB_data{5}.latitude='53.422528';
    WSDB_data{5}.longitude='-2.281239';
    WSDB_data{5}.delay_ofcom=[];
    
    [wsbx,wsby]=size(WSDB_data); %Get location data size
    
    delay_ofcom_vector=[];
    legend_label_ofcom=[];
    
    
    for ln=1:wsby
        delay_ofcom=[];
        for xx=1:no_queries
            fprintf('[Query no., Location no.]: %d, %d\n',xx,ln)
            
            %Fetch location data
            latitude=WSDB_data{ln}.latitude;
            longitude=WSDB_data{ln}.longitude;
            
                instant_clock=clock; %Start clock again if scanning only one database
                cd([my_path,'/ofcom']);
                [msg_ofcom,delay_ofcom_tmp,error_ofcom_tmp]=database_connect_ofcom(...
                    type,latitude,longitude,height,[my_path,'/ofcom']);
                var_name=(['ofcom_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
                if error_ofcom_tmp==0
                    dlmwrite([var_name,'.txt'],msg_ofcom,'');
                    delay_ofcom=[delay_ofcom,delay_ofcom_tmp];
                end
        end
            %Clear old query results
            cd([my_path,'/ofcom']);
            
            %Save delay data per location
            WSDB_data{ln}.delay_ofcom=delay_ofcom;
            legend_label_ofcom=[legend_label_ofcom,repmat(ln,1,length(delay_ofcom))]; %Label items for boxplot
            delay_ofcom_vector=[delay_ofcom_vector,delay_ofcom];
            labels_ofcom(ln)={WSDB_data{ln}.name};
    end
    
    %%
    %Plot figure: Box plots for delay per location
    
    %Select maximum Y axis
    max_el=max([delay_ofcom_vector(1:end)]);
        figure('Position',[440 378 560/2.5 420/2]);

        boxplot(delay_ofcom_vector,legend_label_ofcom,...
            'labels',labels_ofcom,'symbol','g+','jitter',0,'notch','on',...
            'factorseparator',1);
        ylim([0 max_el]);
        set(gca,'FontSize',ftsz);
        ylabel('Response delay (sec)','FontSize',ftsz);
        set(findobj(gca,'Type','text'),'FontSize',ftsz); %Boxplot labels size
        %Move boxplot labels below to avoid overlap with x axis
        txt=findobj(gca,'Type','text');
        set(txt,'VerticalAlignment','Top');
    
    %Reserve axex properties for all figures
    fm=[];
    xm=[];
    fs=[];
    xs=[];
    fg=[];
    xg=[];

        figure('Position',[440 378 560 420/3]);
        name_location_vector=[];
        for ln=1:wsby
            delay_ofcom=WSDB_data{ln}.delay_ofcom;
            
            %Outlier removal (Ofcom delay)
            outliers_pos=abs(delay_ofcom-median(delay_ofcom))>3*std(delay_ofcom);
            delay_ofcom(outliers_pos)=[];
            
            [fg,xg]=ksdensity(delay_ofcom,'support','positive');
            fg=fg./sum(fg);
            plot(xg,fg);
            hold on;
            name_location=WSDB_data{ln}.name;
            name_location_vector=[name_location_vector,{name_location}];
        end
        
        box on;
        grid on;
        set(gca,'FontSize',ftsz);
        xlabel('Response delay (sec)','FontSize',ftsz);
        ylabel('Probability','FontSize',ftsz);
        legend(name_location_vector,'Location','Best');
 
%Set y axis limit manually at the end of plot
ylim([0 max([fg,fm,fs])]);        

%%
['Elapsed time: ',num2str(toc/60),' min']