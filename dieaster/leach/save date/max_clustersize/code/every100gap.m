z_spare_ori_new = [];
for t = 1:1:3000
    if mod(t,100)==0
             z_spare_ori_new=[z_spare_ori_new,z_spare_ori(t)];
    end
end
x=1:1:30;
plot(x, z_spare_ori_new, 'g-', 'LineWidth', 2); % Plot fitted line.