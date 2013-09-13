function [new_config,new_true_config,moved,visible,known,occupied,free,revealed,no_new_findings] = ...
    take_action2(old_config,action,true_config,visible,known,occupied,free,nrows,ncols)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%[new_config,moved,true_config,known] = take_action(old_config,first_action,true_config,known,free)
moved = 0;
revealed = 0;
no_new_findings = 1;
new_config = old_config;
new_true_config = true_config;
move_idx = find(old_config(:,1) == action(1));

[occupied_rowcol(:,1), occupied_rowcol(:,2)] = ind2sub([nrows, ncols], occupied);
unknown_occupying_objects = setdiff(occupied_rowcol,known(:,2:3),'rows');

new_config(move_idx,2:3) = new_config(move_idx,2:3) + action(2:3);
if (numel(setdiff(new_config(move_idx,2:3),true_config(:,2:3),'rows')) == 0)
    % There is an object where we want to move
    occupied = [occupied;sub2ind([nrows,ncols],new_config(move_idx,2),new_config(move_idx,3))];
    %known = [known;[0 new_config(move_idx,2:3)]];
    new_config = old_config;
else
    new_true_config(new_true_config(:,1) == action(1),2:3) = ...
        new_true_config(new_true_config(:,1) == action(1),2:3) + action(2:3);
    known(known(:,1) == action(1),2:3) = known(known(:,1) == action(1),2:3) + action(2:3);
    
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
    
    %The cells that are actually occupied after this action
    actual_occupied = occupied;
    
    if (isempty(setdiff(actual_occupied, expected_occupied)))
        %We saw what we expected to see.
        no_new_findings = 1;
    else
        no_new_findings = 0;
    end
    
    for s = 1:size(unknown_occupying_objects,1)
        row = unknown_occupying_objects(s,1);
        col = unknown_occupying_objects(s,2);
        known_rows = find(known(:,3) == col);
        if (isempty(known_rows))
            revealed = revealed+1;            
        elseif (min(known(known_rows,2)) > row)
%        if (numel(find(sub2ind([nrows,ncols],1,col) == free)) ~= 0)
            revealed = revealed+1;
        end
    end
%    revealed = size(intersect(unknown_occupying_objects,visible(:,2:3),'rows'),1)
end

end

