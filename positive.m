
%% returns minimum positive index of given vector
function [min_positive_idx] = positive(numbers)
    positive_numbers = numbers(numbers > 0);
    if isempty(positive_numbers)  % check if there are number greater than 0
        min_positive_idx=[]
    else

    
        % Find the minimum positive value and its index
        [min_val, min_idx] = min(positive_numbers);
        
        % Find the index of the minimum positive value in the original array
        min_positive_idx = find(numbers == positive_numbers(min_idx));
        %selecting one value in case of multiple values
        min_positive_idx = min_positive_idx(randperm(length(min_positive_idx), 1));
    end
end

        
    

