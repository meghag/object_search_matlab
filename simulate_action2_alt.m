function [new_config,new_true_config,moved,visible,known,occupied,free,revealed,no_new_findings] = ...
    simulate_action2_alt(old_config,action,true_config,known,occupied,free,nrows,ncols)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%[new_config,moved,true_config,known] = take_action(old_config,first_action,true_config,known,free)
moved = 0;
revealed = 0;
no_new_findings = 1;
new_config = old_config;
new_true_config = true_config;
move_idx = find(old_config(:,1) == action(1));

%[occupied_rowcol(:,1), occupied_rowcol(:,2)] = ind2sub([nrows, ncols], occupied);
%unknown_occupying_objects = setdiff(occupied_rowcol,known(:,2:3),'rows');

new_config(move_idx,2:3) = action(4:5);

new_true_config(new_true_config(:,1) == action(1),2:3) = action(4:5);
known(known(:,1) == action(1),2:3) = action(4:5);

% Update free
now_occupied_idx = sub2ind([nrows,ncols],new_config(move_idx,2),new_config(move_idx,3));
now_free_idx = sub2ind([nrows,ncols],old_config(move_idx,2),old_config(move_idx,3));
occupied(occupied == now_free_idx) = now_occupied_idx;

%The cells that are expected to be occupied after this action
expected_occupied = occupied;

if (isempty(find(free == now_occupied_idx, 1)))
    % The object was moved to a previously unobserved cell.
    free = [free;now_free_idx];
else
    % The object was moved to a free cell which is, thus, now occupied.
    free(free == now_occupied_idx) = now_free_idx;
end

[visible,known] = find_visible2(new_true_config,known);
occupied = union(sub2ind([nrows,ncols],known(:,2),known(:,3)), occupied);
free = find_free(occupied,nrows,ncols,free);
moved = 1;

end

