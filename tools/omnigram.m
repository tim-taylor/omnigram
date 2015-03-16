function [] = omnigram(simulation_data)
% OMNIGRAM(SIMULATION_DATA) prepares simluation data and writes XML file
% for loading data into Omnigram Explorer

% SIMULATION_DATA is the name (string format without extension) of a 
% dataset in .csv format, with each row representing a simulation and 
% each variable in a column. The first row of the file must contain 
% variable names.

% The user first interactively selects which variables from the dataset are
% to be included, and then designates them as input (root) or output (leaf)
% and whether discrete or continuous

% Written by Trish Campbell 16 January 2015

%% load data set

% load full set of data
simulations = importdata(strcat(simulation_data,'.csv'),',',1); 

% identify variable names 
allNames = simulations.colheaders;

%% interactive selection of variables 

% choose required variables
[selected_vars, ok1] = listdlg('ListString', allNames,...
                      'SelectionMode','multiple', 'PromptString',...
                      'Select required variables: ctrl-click for multiple',...
                      'InitialValue',[]);
if ok1 == 0
    error('No variables selected to load')
end

% modify dataset to match selection
selectedData = simulations.data(:,selected_vars);
names = allNames(selected_vars);

% save modified dataset
csvwrite('selectedData.csv',selectedData)

%% interactive selection of attributes
% identify output variables (remaining are treated as parameters)

choices = names;
choices{1,length(names)+1} = 'None';

[output, ok2] = listdlg('ListString',choices,...
                      'SelectionMode','multiple',...
                      'PromptString',...
                      sprintf('Select output variables:'),...
                      'InitialValue',length(choices));
if ok2 == 0 || sum(ismember(output,length(choices)))==1
    warning('No output variables selected: all will be treated as input')
end
 
% identify discrete variables
[discrete_var, ok3] = listdlg('ListString',choices,...
                      'SelectionMode','multiple',...
                      'PromptString',...
                      sprintf('Select discrete variables:'),...
                      'InitialValue',length(choices));
                  
if ok3 == 0 || sum(ismember(output,length(choices)))==1
    warning('All variables will be treated as continuous')
end

%% get parameter and output attributes required for XML file
for i = 1: length(names)
    
    if ismember(i,output)
       attributes.(names{i}).role = 'leaf';
    else
       attributes.(names{i}).role = 'root';
    end
    
    if ismember(i,discrete_var)
        attributes.(names{i}).datatype = 'discrete';
    else
        attributes.(names{i}).datatype = 'continuous';
    end
    
    attributes.(names{i}).min = min(selectedData(:,i));
    attributes.(names{i}).max = max(selectedData(:,i));

end

%% generate xml file
fid = fopen(strcat(simulation_data,'-loader.xml'),'w');

fprintf(fid,'<?xml version="1.0"?>\n\n');
fprintf(fid,'<model>\n\n');
fprintf(fid,'\t <general data="selectedData.csv"\n');
fprintf(fid,'\t \t num-samples="%d" rng-seed="1"\n',1000);
fprintf(fid,'\t \t has-labels="false" live="false">\n');
fprintf(fid,sprintf('\t \t <label>%s</label>\n',simulation_data));
fprintf(fid,'\t </general>\n\n');

fprintf(fid,'\t <appearance node-bin-scale-factor="5.0"');
fprintf(fid,' node-default-height="150" node-default-width="330"\n');
fprintf(fid,'\t \t \t min-internode-gap="20"\n');
fprintf(fid,'\t \t \t num-root-cols="3" num-inter-cols="0" num-leaf-cols="3">\n');
fprintf(fid,'\t </appearance>\n\n');

fprintf(fid,'\t <nodes>\n\n');
for i = 1: length(names)
    datatype = attributes.(names{i}).datatype;
    min_var = attributes.(names{i}).min;
    max_var = attributes.(names{i}).max;
    role = attributes.(names{i}).role;
    if strcmp(datatype,'discrete')
        fprintf(fid,'\t \t <node id="%d" datatype="%s" min="%d" max="%d"',i,datatype,min_var,max_var);
    else
    fprintf(fid,'\t \t <node id="%d" datatype="%s" min="%f2" max="%f2"',i,datatype,min_var,max_var);
    end
    fprintf(fid,' role="%s" filecol="%d">\n',role,i);
    fprintf(fid,'\t \t \t <label>%s</label>\n',names{i});
    fprintf(fid,'\t \t </node>\n\n');    
end
fprintf(fid,'\t </nodes>\n\n');
fprintf(fid,'</model>\n');
fclose(fid);







