function draw_grid(dim1,dim2,res)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

A = linspace(0,dim1,dim1/res+1);
B = linspace(0,dim2,dim2/res+1);
C = repmat(A,length(B),1);
D = repmat(B, length(A), 1);

hold on;
for i = 1:length(A)
    plot(B,C(:,i),'r', 'LineWidth', 4);
end
for j = 1:length(B)
    plot(D(:,j),A,'r', 'LineWidth', 4);
end
hold off

end

