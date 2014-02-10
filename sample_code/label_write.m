function label_write(filename, Y);

fp=fopen(filename, 'w');
for i=1:length(Y)
    fprintf(fp, '%g\n', Y(i));
end
fclose(fp);
