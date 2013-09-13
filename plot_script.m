avg_n_iterations =    [0.9600    2.0200;
    1.6000    4.9000;
    2.3800    8.0400;
    2.9600    9.6800;
    3.4600    9.1800;
    4.2400   14.6000;
    5.0800   18.6600];

avg_n_actions = [1.8889    3.3889;
    2.6905    7.7738;
    3.5794    9.6746;
    4.5397   13.0397];


avg_time_taken = [0.0900    0.0275;
    0.2035    0.0715;
    0.3926    0.1170;
    0.4960    0.1472;
    0.5672    0.1374;
    0.6482    0.2214;
    0.7382    0.2859];

%plot(avg_n_iterations(:,2)./avg_n_iterations(:,1),'ro-');
%hold on;
plot([2:size(avg_n_actions,1)+1], avg_n_actions(:,2)./avg_n_actions(:,1),...
    'bs-','MarkerSize',10,'LineWidth',2);
xlabel('Number of objects','FontSize',14);
ylabel({'Performance ratio:','Random/Adpative Look-ahead'}, 'FontSize', 14);
%xlim([2,size(avg_n_actions,1)+1]);
%plot(avg_time_taken(:,2)./avg_time_taken(:,1),'gd-');
%hold off