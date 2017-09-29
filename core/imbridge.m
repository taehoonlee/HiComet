function out = imbridge(in)

    n = length(unique(in)) - 1;
    out = in;
    
    for i = 1:n
        
        oldobj = (in == i);
        newobj = bwmorph(oldobj, 'bridge');
        modifiedspace = xor(newobj, oldobj);
        
        out(modifiedspace) = i * newobj(modifiedspace);
        
    end
    
end