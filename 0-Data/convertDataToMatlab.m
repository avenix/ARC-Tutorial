
importer = TableImporter();

table = importer.importTable('allcanter.csv');
allcanter = table2array(table);
save('allcanter','allcanter');

table = importer.importTable('alljumps.csv');
alljumps = table2array(table);
save('alljumps','alljumps');

table = importer.importTable('alltrot.csv');
alltrot = table2array(table);
save('alltrot','alltrot');

table = importer.importTable('allwalk.csv');
allwalk = table2array(table);
save('allwalk','allwalk');

table = importer.importTable('jumps.csv');
jumps = table2array(table);
save('jumps','jumps');

table = importer.importTable('jumpslabels.csv');
jumpslabels = table2array(table);
save('jumpslabels','jumpslabels');
