function [new_config,new_true_config,moved,known,free,revealed] = take_action(old_config,action,true_config,known,free,nrows,ncols)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%[new_config,moved,true_config,known] = take_action(old_config,first_action,true_config,known,free)
moved = 0;
revealed = 0;
new_config = old_config;
new_true_config = true_config;
move_idx = find(old_config(:,1) == action(1));
new_config(move_idx,2:3) = new_config(move_idx,2:3) + action(2:3);
if (numel(setdiff(new_config(move_idx,2:3),true_config(:,2:3),'rows')) == 0)
    % There is an object where we want to move
    known = [known;[0 new_config(move_idx,2:3)]];
    new_config = old_config;
else
    new_true_config(new_true_config(:,1) == action(1),2:3) = ...
        new_true_config(new_true_config(:,1) == action(1),2:3) + action(2:3);
    known(known(:,1) == action(1),2:3) = known(known(:,1) == action(1),2:3) + action(2:3);
    
    % Update free
    now_occupied_idx = sub2ind([nrows,ncols],new_config(move_idx,2),new_config(move_idx,3));
    now_free_idx = sub2ind([nrows,ncols],old_config(move_idx,2),old_config(move_idx,3));
    free(free == now_occupied_idx) = now_free_idx;
    [new_visible,~,known] = find_visible(new_true_config,known);
    [~,new_free] = find_occupied(known,nrows,ncols);
    free = union(free,new_free);
    
    now_visible_idx = find(new_visible(:,1) == 0);
    if (numel(now_visible_idx) ~= 0)
        % Set the id to actual object id instead of zero.
        indices_visible = sub2ind([nrows,ncols],new_visible(now_visible_idx,2),new_visible(now_visible_idx,3));
        indices_known = sub2ind([nrows,ncols],known(:,2),known(:,3));
        indices_trueconfig = sub2ind([nrows,ncols],new_true_config(:,2),new_true_config(:,3));
        
        for p = 1:length(now_visible_idx)
            obj_id = new_true_config(indices_visible(p) == indices_trueconfig,1);
            known(indices_known == indices_visible(p),1) = obj_id;
        end
        revealed = length(now_visible_idx);
    end
    
    moved = 1;
end

end

