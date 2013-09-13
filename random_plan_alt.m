function random_action_seq = random_plan_alt(visible,known,occupied,free,dim1,dim2,res,horizon)
%UNTITLED Summary of this function goes here
%   
% This function selects an action that results in revealing most of the unobserved cells.

nrows = dim1/res;
ncols = dim2/res;

%prev_occupied = occupied;
%prev_free = free;
%n_unknown_occupying_objects = length(occupied) - size(known,1);

%If the goal is know identity and location of each object
%prev_unobserved = nrows*ncols - (length(prev_occupied)+length(prev_free) - n_unknown_occupying_objects);

%If the goal is only to know state of each voxel - occupied or free
%prev_unobserved = nrows*ncols - (length(prev_occupied)+length(prev_free));

horizon;
allowed_actions = find_actions2_alt(visible,occupied,free,dim1,dim2,res);
if (isempty(allowed_actions) == 0)
    A = size(allowed_actions,1);
    random_action = allowed_actions(randi(A),:);
    old_config = known;
    true_config = known;
    [~,~,~,new_visible,new_known,new_occupied,new_free,~,~] = ...
        simulate_action2_alt(old_config,random_action,true_config,known,occupied,free,nrows,ncols);
    
    if (horizon > 1)
        action_seq = random_plan_alt(new_visible,new_known,new_occupied,new_free,dim1,dim2,res,horizon-1);
        horizon;
    else
        action_seq = [];
    end
    random_action_seq = [random_action;action_seq];
else
    disp('No more moves possible');
    random_action_seq = [];
end

end

