%% randomly select n scenario based on a criteria
%damage_loss = load('losses_49.mat');
%avg_loss = load('avg_loss_all.csv');

% returns representative scenario with damaged line index and loss power
% associated with that representative scenario
function [fail_scenario, loss_final] = scenario_selection(damage_loss,...
   avg_loss, damage, fail_scenario)
    for i = 1:49
        %min_idxs = find(cell2mat([damage_loss(:,i)]) == abs(avg_loss(i) ...
        %- min(abs(cell2mat([damage_loss(:,i)]) - avg_loss(i)))));

        min_idxs = find(abs(cell2mat([damage_loss(:,i)]) - abs(avg_loss(i) ...
        - min(abs(cell2mat([damage_loss(:,i)]) - avg_loss(i)))))<0.000001);

        if isempty(min_idxs)
            %min_idxs = find(cell2mat([damage_loss(:,i)]) == abs(avg_loss(i) ...
            %+ min(abs(cell2mat([damage_loss(:,i)]) - avg_loss(i)))));

            min_idxs = find(abs(cell2mat([damage_loss(:,i)]) - abs(avg_loss(i) ...
            + min(abs(cell2mat([damage_loss(:,i)]) - avg_loss(i)))))<0.00001);

            selected_idx = min_idxs(randperm(length(min_idxs),1));
        else
            selected_idx = min_idxs(randperm(length(min_idxs),1));
        end
    
        sum_b = 1;
        counter = 1;
        while sum_b > 0 & i > 1 & counter < 20
           sum_b = sum(cellfun(@(m)isequal(m,damage{selected_idx,i}),fail_scenario(1,:)));
           if sum_b ~= 0
               selected_idx = min_idxs(randperm(length(min_idxs),1));         
           end
           counter = counter + 1;
        end         
        fail_scenario{i} = damage{selected_idx,i};
        loss_final(i) = cell2mat([damage_loss(selected_idx,i)]);
               

    end
end