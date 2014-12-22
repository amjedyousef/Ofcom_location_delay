%   Amjad Yousef Majid  
%   Reference: [1] "Will Dynamic Spectrum Access Drain my
%   Battery?", submitted for publication, July 2014

%   Code development: 

%   Last update: 22 Dec 2014

%   This work is licensed under a Creative Commons Attribution 3.0 Unported
% 
function [response,delay,error]=database_connect_ofcom(request_type,latitude,longitude,height,my_path)

error=false; %Default error value
delay=[]; %Default delay value

server_name='https://tvwsdb.broadbandappstestbed.com/json.rpc';
text_coding='"Content-Type: text/xml; charset=utf-8"';

ofcom_query(request_type,latitude,longitude,height);

my_path=regexprep(my_path,' ','\\ ');

cmnd=['/usr/bin/curl -X POST ',server_name,' -H ',text_coding,' --data-binary @',my_path,'/google.json -w %{time_total}'];
[status,response]=system(cmnd);


    pos_end_query_str=findstr(response,'}');
    delay=str2num(response((pos_end_query_str(end)+1):end))

system('rm google.json');

function ofcom_query(request_type,latitude,longitude,height)

request=['{"jsonrpc": "2.0",',...
    '"method": "spectrum.paws.getSpectrum",',...
    '"params": {',...
    '"type": ',request_type,', ',...
    '"version": "0.6", ',...
    '"deviceDesc": ',...
    '{ "manufacturerId": "TuDelft", ',...
    '"modelId": "Test", ',...
    '"serialNumber": "0001", ',...
    '"etsiEnDeviceType": "A", ',...
    '"etsiEnDeviceEmissionsClass": "3", ',...
    '"etsiEnDeviceCategory": "master", ',...
    '"etsiEnTechnologyId": "466", '...
    '"rulesetIds": [ "OfcomWhiteSpacePilotV1-2013",],}, ',...
    '"location": ',...
    '{ "point": ',...
    '{ "center": ',...
    '{"latitude": ',latitude,', '...
    '"longitude": ',longitude,'}, ',...
    '"orientation": 45, ' ,...
    '"semiMajorAxis": 50, ' ,...
    '"semiMinorAxis": 50, ' ,...
      '},}, ',...
         '"capabilities": { ',...
          '"frequencyRanges": [ {' ,...
         '"startHz": 470000000, ',...
         '"stopHz": 790000000, ',...
         '},],},',...
         '"antenna": { ',...
          '"height": ',height,', ',...
         '"heightType": "AGL" }, ',...
    '},"id": "123456789"}'];

dlmwrite('google.json',request,'');