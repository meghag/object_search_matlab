function [goal_config,nsteps,first_action] = bfs_class(start,known,free,dim1,dim2,res,target_id)
% BFS - This function performs a breadth first search on a tree of
% configurations until it reaches the goal config. The tree is gradually
% unfolded, the whole tree is not used as an input. At the end, the goal
% config as well as the sequence of actions required to reach it are
% returned.

%V = vertices of the tree i.e. configurations
%E = edges of the graph 
%A = actions
%Adj = Adjacency matrix for the discretized space
%start = initial configuration -> root of BFS tree
%visible = vector of cell ids with visible objects

%[dim1, dim2] = size(Adj);

N = size(start,1);      %Number of objects
V = [start;[0,0,0]];          %List of visited nodes
Exp = V;        %List of nodes to be explored
%[visible, ~] = find_visible(start);

current = start;
depth = 0;
tree_levels = 0;
success = 0;
while (numel(Exp) ~= 0)
    if success == 1
        break;
    else
        current = Exp(1:N+1,:);
        depth = tree_levels(1)+1;
    end
    
    % Given the current config, we assume that all object locations are
    % known and so, we set known to all objects.
    prev_known = current(1:N,:);
    [visible,~,known] = find_visible(current(1:N,:),prev_known);
    allowed_actions = find_actions(visible,known,dim1,dim2,res);
    for i = 1:size(allowed_actions,1)
        repeat = 0;
        %new_config = simulate_action(current,i);
        idx = find(current(1:N,1) == allowed_actions(i,1));
        new_config = current(1:N,:);
        new_config(idx,2:3) = new_config(idx,2:3)+allowed_actions(i,2:3);
        
        
        %keyboard
        %Search for new_config in visited nodes. 
        %Proceed only if unvisited.
        for count = 1:N+1:size(V,1)-N
            cfg = V(count:count+N-1,:);
            if (numel(setdiff(new_config,cfg,'rows')) == 0)
                repeat = 1;
                break;
            end
        end
        
        if (depth == 1)
            new_config = [new_config;allowed_actions(i,:)];
        else
            new_config = [new_config;current(N+1,:)];
        end
        
        if (repeat == 0)
            [new_visible,~,~] = find_visible(new_config(1:N,:),new_config(1:N,:));
            if isempty(find(new_visible(:,1) == target_id, 1))
                % new_config ~= goal_config. Add to tree.
                
                %**** To Do ****
                %Need to make a class object of every config added to tree.
                %For now, a dirty hack
                V = [V;new_config];
                Exp = [Exp;new_config];
                tree_levels = [tree_levels;depth];
            else
                success = 1;
                goal_config = new_config(1:N,:);
                nsteps = depth;
                first_action = new_config(N+1,:);
                break;
            end
        end
    end
    
    % Now all neighbors of the current node have been explored.
    % Remove current from Exp.
    if (size(Exp,1) > N+1)
        Exp = Exp(N+2:end,:);
        tree_levels = tree_levels(2:end,:);
    else
        Exp = [];
        tree_levels = [];
    end
    
end



end

