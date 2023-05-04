% Author : Shishir Lamichhane, Abodh Poudyal (Washington State University)
% Date : April 16, 2023

%% Scenario generation required for Monte Carlo simulations
tic;
clc;
clear all;

%seed for reproducibility
rng(2);
testcase = 118; % 14 for 14 bus system, 123 for 123 bus system
%% Loading given type test case data from matpower
case_name = strcat('case',num2str(testcase));
if testcase ~= 123

    mpc = loadcase(case_name);
    
end

% after economic dispatch with dc opf
result=dcopf(case_name);
Active_Supply = zeros(1,testcase); %equal to number of bus
Active_Supply(result.gen(:,1))=result.gen(:,2);

CL_Flag = 1; % 1 for critical load inclusion , 0 for not inclusion

if testcase == 123   % this is separated because we have manually added file for 123 case

    %loading line data
      
    Line_Data = load('Line_Config.txt');
    manually_added_virtual =5; % for virtual DG connection, lines are added
    
    Harden_Lines = [];  % index of hardened lines
    Source = [125]; % source node number
    
    %loading Load data
    
    Load_Data = load('Loaddata_updated.txt');
    Active_Demand = sum(Load_Data(:,[2 4 6]),2); % 2,4,6 column contains active load for each phase
    
    % giving more value to critical load
    if CL_Flag == 1
        CL = [1, 3, 4, 5, 6, 52, 53, 54, 55, 56, 76, 77, 78, 79, 86, 98, 99, ...
        100, 62, 63, 64, 65, 66, 47, 48, 49, 50, 28, 29, 30]; % nodes where critical loads are located
        Active_Demand(CL) = Active_Demand(CL)*10; % weightage of 10 is given for CL
    end

    n_lines = length(Line_Data)-manually_added_virtual;  % number of lines only in 123 bus system, -5 because this file contains manually added virtual line
else

    %loading line data for case loaded from matpower
      
    Line_Data = mpc.branch;
    
    Harden_Lines = [];  % index of hardened lines

    %% getting source node information
    
    Source = mpc.gen(:,1)'; % source node number, total sources are considered

    % if swing bus is considered only
  % if testcase==14
  %       Source = [1];
  %   elseif testcase==39
  %       Source=[31];
  %   elseif testcase==118
  %       Source=[69];
  %   end

      
       
    
    %% loading Load data
    
    Load_Data = mpc.bus;
    Active_Demand = Load_Data(:,3); % column 3 contains active load
    
    % giving more value to critical load
    if CL_Flag == 1
        CL = []; % nodes where critical loads are located
        Active_Demand(CL) = Active_Demand(CL)*10; % weightage of 10 is given for CL
    end
    n_lines = length(Line_Data);
end


%%
% Defining variables
n_monte = 1000; % number of monte carlo trials

%loading failure probability table
%FP(49*1) contains 49 samples of wind speed with corresponding failure probability

%load fp
load fp_modified
Fail_prob = FP; 
%%
for f=1:length(Fail_prob)  % for each wind speed
    %%
    failed_num = round(Fail_prob(f)*n_monte); % failed_num is number of failed outcomes out of n_monte total outcomes for that line

    % defining matrix that contains status of line for all scenarios (montecarlo trials) of each wind speed
    X = ones(n_monte,n_lines);  % 1 denotes healthy status

    for line=1:n_lines
        % rnd_indx should contain 'failed_num' of index between 1 to 1000 that should be made 0
        rnd_indx = [];  % assigning to empty list initially
        a=1; b=n_monte;
        while(size(rnd_indx)<failed_num) % there might be chance of repetition and length(rnd_indx) might be less than failed_num
            r = round((b-a).* rand(failed_num,1) + a); % generate failed_num number of integers between a and b
            rnd_indx = [rnd_indx; r];
            rnd_indx = unique(rnd_indx);     % to remove repetition
        end

        % selection of failed_num number of indices from rnd_indx as there
        % is chance of size(rnd_indx) > failed_num
        rnd_indx = rnd_indx(randperm(length(rnd_indx), failed_num));
        % equate value of these indices to 0 for this line in matrix X
        X(rnd_indx, line) = 0;
    end
   

    %% Loss calculation 

    %processing for line data

    fr = Line_Data(1:n_lines,1); % 1st column contains from node
    to = Line_Data(1:n_lines,2); %2nd column contains to node for each line
      %Lets sort 'to' node list in ascending order and assign line index  from top to bottom. For eg, lowest number to node will have line index 1 
      % and goes on increasing with increase of number assigned to 'to' node
      % and create a edge storing fr and to nodes
    [~,ind] = sort(to);
    edges = [fr(ind) to(ind)];   
    %%
    %run monte carlo trials for loss finding
    
    for k = 1:n_monte
        %%
        Failure = find(0==X(k,:)); % returns index of line which is failed for that trial
        Failure = setdiff(Failure,Harden_Lines); % remove hardened lines from failures as they are assumed not to be failed
        Power_Loss = Loss_Calculation(Failure,fr,to,Source, Active_Demand, edges,Active_Supply);
        Damage_Power(k,f) = Power_Loss;  %contains power loss for each trial for each wind speed
        Damage_Line{k,f} = Failure; % contains damage line index for each trial for each wind speed
        
        
    
    end
    
    Average_Loss(f) = mean(Damage_Power(:,f)); % average loss for each wind speed
    % for checking 
    f
    % if f == 1
    %     break;
    % end


   

end

%% scenario selection
fail_scenario = {}; %contains selected scenario
loss_final = []; %contains loss associated with selected scenario
Damage_Power1 = num2cell(Damage_Power);
[fail_scenario, loss_final] = scenario_selection2(Damage_Power1,...  %scenario_selection2 for non zerro type selection
   Average_Loss, Damage_Line, fail_scenario);
%just for column representation
Average_Loss=Average_Loss';
loss_final=loss_final';

toc;
    
    
%% function 'Loss_Calculation'
% This function takes Failed line index and returns the loss value due to
% such scenario

function [Power_Loss] = Loss_Calculation(Failure,fr,to,Source, Active_Demand, edges,Active_Supply)
    
    
    G = graph(fr,to); % create graph using from and to nodes data
    
     % Finding list of total nodes present in system
    Nodes_All = [];
    for s = Source
        Nodes_All = [Nodes_All; dfsearch(G,s)];
    end
    
    Nodes_All = unique(Nodes_All);

    
    G_Edges = table2array(G.Edges); % returns edge of graph, can also called line of system but direction of line is not specified
    
    Power_Loss = 0; %Assign loss as 0 initially
    
    % Finding nodes associated to each failure line
    
    for line = 1:length(Failure)
        c = edges(Failure(line),:); % returns node that are associated with that failed line
        edge_idx = find(G_Edges(:,1) == c(1) & G_Edges(:,2) == c(2) | G_Edges(:,2) == c(1) & G_Edges(:,1) == c(2)); % find index of that associated nodes present in Graph
        %remove that edge
        G = rmedge(G,edge_idx);
        G_Edges = table2array(G.Edges);
    end
    
    % Finding health nodes that are discoverable from atleast one source
    Nodes_Healthy = []; % it will store number of healthy nodes
    for s = Source
        Nodes_Healthy = [Nodes_Healthy; dfsearch(G,s)];
    end
    
    Nodes_Healthy = unique(Nodes_Healthy);
    
    % Finding missing nodes
    
    Nodes_Missing = setdiff(Nodes_All, Nodes_Healthy);
    
    %Calculating Power loss from offline nodes
    
    Power_Loss_Offline = sum(Active_Demand(Nodes_Missing));

    %calculating power loss due to load shedd
    Power_Loss_Loadshed = load_shedding(G,Source,Active_Demand,Active_Supply);

    %calculating total loss
    Power_Loss = Power_Loss_Offline + Power_Loss_Loadshed;
    
end




     






                    
       
         
       











