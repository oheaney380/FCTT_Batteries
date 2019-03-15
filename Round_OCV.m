for i = 1:100
    
    SoC_round(i) = i;
    OCV_round(i) = OCV_prof(find(SoC_prof<i/100, 1));
    
end