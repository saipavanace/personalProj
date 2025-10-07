covergroup toggle_cg with function sample(bit bit_cp);
    toggle: coverpoint bit_cp {
        bins zero2one = (0 => 1);
        bins one2zero = (1 => 0);
    }
endgroup 

class toggle_coverage;
    bit cp_bit;
    int bit_width;
    bit field[];
    toggle_cg toggle_cg[];
    
    function void sample();
        for (int i = 0; i < bit_width; i++) begin
            cp_bit = field[i];
            toggle_cg[i].sample(cp_bit);
        end
    endfunction

    function new(int width, string name);
        string str;
        field = new[width];
        bit_width = width;
        toggle_cg = new[width];
        for (int i = 0; i < width; i++) begin
            toggle_cg[i] = new();
            str.itoa(i);
            toggle_cg[i].option.name = {name,str};
        end
    endfunction
endclass: toggle_coverage
