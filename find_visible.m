function [visible,unknown,known] = find_visible(config,prev_seen_old)
%FIND_VISIBLE - Given a config, finds the set of visible objects

% config is an Nx3 matrix with row = [obj_id cellRow cellCol]
% visible is a matrix with #rows = #visible objects, #cols = 3

%First sort objects by their rows - objects closest to the camera are on
%top.
[~, idx] = sort(config(:,2));
sortedObjLocations = config(idx,:);
occCol = [];
visible = [];

% Fx2 matrix of grid cells that are known to be free. The two columns are
% row and column
%free = prev_free;

for obj = 1:size(sortedObjLocations,1)
    %find(occCol == sortedObjLocations(obj,3))
    if (isempty(find(occCol == sortedObjLocations(obj,3), 1)))
        visible = [visible; sortedObjLocations(obj,:)];
        occCol = [occCol; sortedObjLocations(obj,3)];
    end
end

% Objects that can't be seen at current time
hidden = setdiff(sortedObjLocations,visible,'rows');

% Objects that have never been seen and their locations are just guesses.
if (isempty(prev_seen_old))
    unknown = hidden;
elseif (isempty(setdiff(hidden(:,1),prev_seen_old(:,1))))
    % None of the hidden objects are unknown
    unknown = [];
else
    unknown_ids = setdiff(hidden(:,1),prev_seen_old(:,1));
    unknown_indices = [];
    for j = 1:length(unknown_ids)
        unknown_indices = [unknown_indices;find(hidden(:,1) == unknown_ids(j))];
    end
    unknown = hidden(unknown_indices,:);
end

% Objects that have been seen at least once and their locations are known.
if (isempty(prev_seen_old))
    known = visible;
else
    known = union(visible,prev_seen_old,'rows');
end
%     if isempty(find(prev_seen_old(:,1) == 0,1))
%         %There are no occupied cells for whom id of occupying object is
%         %unknown.
%         known = union(visible,prev_seen_old,'rows');
%     elseif (numel(find(visible(:,1) == 0)) ~= 0)
%         % At least one unknown occupying object has become visible.
%         
%         prev_unknown_occ_obj = find(prev_seen_old(:,1) == 0);
%         [~, idx1, idx2] = intersect(prev_seen_old(prev_unknown_occ_obj,2:3),visible(:,2:3),'rows');
%         prev_seen_old(prev_unknown_occ_obj(idx1),1) = visible(idx2,1); 
%         known = union(visible,prev_seen_old,'rows');
%     end
%end

end

