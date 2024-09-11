%{ Reads the folder under the path starting with the letter 'S / s'
   % Finds  'Sxxxx_xxxx.pairprofile.csv' files and reads the data and saves it as a 'Sxxxx_xxxx.mat' file within each "s / S " folder.
%}

function traces_Read(path)
% clear all;
% path='F:\shuqi\Test_dynamic data\LbCas12a-WT-0MM\0825';
% cd(path);

disp(path);
folderNames = dir(path);
folderNames = folderNames([folderNames.isdir]);  

for i = 1:numel(folderNames)
    folderName = folderNames(i).name;
    %%deal all S/s* .mat files
    if startsWith(folderName, 's', 'IgnoreCase', true)
    currentPath = fullfile(path, folderName);
    cd(currentPath)
    savename=currentPath(end-9:end);
    csvfile=dir(fullfile(currentPath, '*pairprofile*.csv'));
    Traces={};
    for k = 1:numel(csvfile)
        sigfname=csvfile(k).name;
        sigfid=fopen(sigfname,'r');
        opts = delimitedTextImportOptions("NumVariables", 4);
      
        opts.DataLines = [2, Inf];
        opts.Delimiter = ",";
   
        opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4"];
        opts.VariableTypes = ["double", "double", "string", "string"];
   
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";

        opts = setvaropts(opts, ["VarName3", "VarName4"], "WhitespaceRule", "preserve");
        opts = setvaropts(opts, ["VarName3", "VarName4"], "EmptyFieldRule", "auto");

        temp1 = readtable(sigfname, opts);
        if numel(temp1.VarName1)-1  %% 剔除不包含数据的excel表格
            data1=table2array(temp1(:,1));
            data2=table2array(temp1(:,2));
            fclose(sigfid);
            temptrace=[data1';data2'];
            Traces(end+1,1)={temptrace};
        end
    end
    cd(path)
    save(savename,'Traces');
    end
end
end




