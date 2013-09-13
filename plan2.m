function [info_gain, best_next_action_seq] = plan2(visible,known,occupied,free,dim1,dim2,res,horizon,prev_info_gain)
%UNTITLED Summary of this function goes here
%   
% This function selects an action that results in revealing most of the unobserved cells.

nrows = dim1/res;
ncols = dim2/res;

prev_occupied = occupied;
prev_free = free;
n_unknown_occupying_objects = length(occupied) - size(known,1);

%If the goal is know identity and location of each object
%prev_unobserved = nrows*ncols - (length(prev_occupied)+length(prev_free) - n_unknown_occupying_objects);

%If the goal is only to know state of each voxel - occupied or free
prev_unobserved = nrows*ncols - (length(prev_occupied)+length(prev_free));

horizon;
allowed_actions = find_actions2(visible,occupied,dim1,dim2,res);

info_gain = -1;
best_action_seq = [];

for i = 1:size(allowed_actions,1)
    temp = 0;
    
    %Calculate info gain
    horizon;
    allowed_action = allowed_actions(i,:);
    possible_revelation = 0;
    
    % Does the action move the object to a free spot as opposed to unknown?
    destination_cell = allowed_actions(i,4:5) + allowed_actions(i,2:3);
    destination_idx = sub2ind([nrows,ncols],destination_cell(1),destination_cell(2));
    if (numel(find(free == destination_idx,1)) ~= 0)
        possible_revelation = 0.2;
    end
    
    old_config = known;
    true_config = known;
    [~,~,~,new_visible,new_known,new_occupied,new_free,~,~] = ...
        simulate_action2(old_config,allowed_actions(i,:),true_config,visible,known,occupied,free,nrows,ncols);
    
    %[new_visible,new_known] = find_visible(new_config,new_known);
    n_unknown_occupying_objects = length(new_occupied) - size(new_known,1);
    
    %If the goal is know identity and location of each object
    %new_unobserved = nrows*ncols - (length(new_occupied)+length(new_free)-n_unknown_occupying_objects);
    
    %If the goal is only to know state of each voxel - occupied or free
    new_unobserved = nrows*ncols - (length(new_occupied)+length(new_free));
    
%     if (revealed > 0)
%         % Some unknown occupying objects have become visible
%         allowed_action;
%         revealed;
%     end

    %Taking the revealed objects into account while calcuating gain
    %greedy_info_gain = prev_unobserved - new_unobserved + revealed;
    
    %Not taking the revealed objects into account while calcuating gain
    greedy_info_gain = prev_unobserved - new_unobserved + possible_revelation;
    
    total_gain_so_far = prev_info_gain + greedy_info_gain;
    %action_seq_so_far = [prev_action_seq;allowed_actions(i,:)]
        
    %keyboard
     
    if (horizon > 1)
        [total_gain_so_far, best_next_action_seq] = ...
            plan2(new_visible,new_known,new_occupied,new_free,dim1,dim2,res,horizon-1,total_gain_so_far);
        horizon;
    else 
        best_next_action_seq = [];
    end
    
    if (total_gain_so_far > info_gain)
        %This action reveals more than previously tested actions
        info_gain = total_gain_so_far;
        best_action_seq = [allowed_actions(i,:);best_next_action_seq];
    end
    
    %keyboard
end
best_next_action_seq = best_action_seq;
%action_seq_so_far = [best_action; action_seq_so_far];

end

