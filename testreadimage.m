obj=readObj('Model.obj');
display_obj(obj,'Model.jpg');


% Load an image into Matlab
pic=openfig('Coverted_Model1.fig');

% Define the number of times you want to repeat the process
% e.g. if there are multiple lines / shapes that you need to fit to
num_input = input(sprintf('Number of lines / shapes to detect? '));

for i = 1:num_input
    clearvars c_info
    shg
    dcm_obj = datacursormode(1);
    set(dcm_obj,'DisplayStyle','window',...
        'SnapToDataVertex','off','Enable','on')
    waitforbuttonpress
    c_info = getCursorInfo(dcm_obj);
    positions{i} = c_info.Position;
end

positions=positions';


