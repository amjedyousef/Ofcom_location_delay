% ofcom_location_delay queries five different locations and plot the output
% using the boxplot function
%   Last update: 10 January 2015

% Reference:
%   P. Pawelczak et al. (2014), "Will Dynamic Spectrum Access Drain my
%   Battery?," submitted for publication.

%   Code development: Amjed Yousef Majid (amjadyousefmajid@student.tudelft.nl),
%                     Przemyslaw Pawelczak (p.pawelczak@tudelft.nl)

% Copyright (c) 2014, Embedded Software Group, Delft University of
% Technology, The Netherlands. All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions
% are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright
% notice, this list of conditions and the following disclaimer in the
% documentation and/or other materials provided with the distribution.
%
% 3. Neither the name of the copyright holder nor the names of its
% contributors may be used to endorse or promote products derived from this
% software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
% HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
% SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
% TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
tic;
clear;
close all;
clc;

%%
%Plot parameters
ftsz=16;
%Path to save files (select your own)
my_path='/home/amjed/Documents/Gproject/workspace/data/WSDB_DATA';
% Query params
request_type='"AVAIL_SPECTRUM_REQ"';
orientation= 45;
semiMajorAxis = 50;
SemiMinorAxis = 50;
start_freq = 470000000;
stop_freq = 790000000;
height=7.5;
heightType = '"AGL"';
%%
no_queries=1; %Select how many queries per location

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
        cd(my_path);
        [msg_ofcom,delay_ofcom_tmp,error_ofcom_tmp]=database_connect_ofcom(...
            request_type,latitude,longitude,orientation,...
            semiMajorAxis,SemiMinorAxis,start_freq,stop_freq,height,heightType,my_path)
        var_name=(['ofcom_',num2str(longitude),'_',datestr(instant_clock, 'DD_mmm_YYYY_HH_MM_SS')]);
        if error_ofcom_tmp==0
            dlmwrite([var_name,'.txt'],msg_ofcom,'');
            delay_ofcom=[delay_ofcom,delay_ofcom_tmp];
        end
    end
    %Clear old query results
    cd(my_path);
    
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