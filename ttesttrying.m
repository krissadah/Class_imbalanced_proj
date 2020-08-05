clear all;clc;
load examgrades
x = grades(:,1);
y = grades(:,2);
[h,p] = ttest(x,y)
