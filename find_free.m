function free = find_free(occupied_indices,nrows,ncols,prev_free)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

free = [];
[occupied(:,1),occupied(:,2)] = ind2sub([nrows,ncols],occupied_indices);

for col = 1:ncols
    occupied_row = min(occupied(col == occupied(:,2),1));
    if isempty(occupied_row)
        free = [free;sub2ind([nrows,ncols],(1:nrows)',col*ones(nrows,1))];
    else
        for i = 1:occupied_row-1
            free = [free;sub2ind([nrows,ncols],i,col)];
        end
    end
end

free = union(free,prev_free);

end

