function A=load_numeric(f)
%A=load_numeric(f)
% Load a numeric file in the Orange format.

% Isabelle Guyon -- Feb. 2009

if ~(exist(f)==2)
    A=[];
    return
end

fp=fopen(f, 'r');
header=fgetl(fp);
if ~isempty(strmatch(header, {'Churn', 'Toy', 'Upselling', 'Appetency', 'Conf', 'Selection'}))
    disp(header);
else
    fclose(fp);
    fp=fopen(f, 'r');
end
A=fscanf(fp, '%g');
fclose(fp);

