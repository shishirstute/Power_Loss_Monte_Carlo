% Author : Shishir Lamichhane (Washington State University)
% Date : May 26, 2023

% selects required number of random scenarios from given total scenarios
% present in matrix Damage_Line which we will get after simulating main file
clear Sample_Damage
for i=1:49   % for each wind speed
    
    temp_damage = {}; % just for temporary storage of damage scenario
    
    for j = 1:20   % j represents the number of samples
        selected_idx = randi([1 1000]);  % selecting random index between 1 and 1000
        sum_b = 1;      
        counter = 1;
            while sum_b > 0 & counter < 20  % making sure that selected samples are not repeated
               
               sum_b = sum(cellfun(@(m)isequal(m,Damage_Line{selected_idx,i}),temp_damage(:)));
               if sum_b ~=0
                   selected_idx = randi([1 1000]);
               end
               counter = counter + 1;
            end
            temp_damage{j} = Damage_Line{selected_idx,i}; 
            Sample_Damage(j,i) = temp_damage(j); % samples selected
            
    end
    
end

               
           


