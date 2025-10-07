const indentIncreaseKeywords = [
    'begin',
    'case',
    'casex',
    'casez',
    'class',
    'clocking',
    'config',
    'function',
    'generate',
    'covergroup',
    'fork',
    'interface',
    'module',
    'package',
    'primitive',
    'program',
    'property',
    'specify',
    'sequence',
    'table',
    'task',
    'randcase',
    '`ifdef',
    '`ifndef',
    '`else',
    '`elsif',
];

const indentDecreaseKeywords = [
    'end',
    'endcase',
    'endclass',
    'endclocking',
    'endconfig',
    'endfunction',
    'endgenerate',
    'endgroup',
    'join',
    'join_any',
    'join_none',
    'endinterface',
    'endmodule',
    'endpackage',
    'endprimitive',
    'endprogram',
    'endproperty',
    'endspecify',
    'endsequence',
    'endtable',
    'endtask',
    '`endif',
    '`else',
    '`elsif',
];

const indentBothKeywords = [
    'else',
    'constraint',
    'foreach',
    'inside',
    'solve',
    'before',
    'expect',
    'cross',
];

// Keywords that might require special handling
const specialKeywords = [
    'if',       // Only increases indent if not followed by a begin
    'else if',  // Same as 'if'
    'for',      // Only increases indent if not followed by a begin
    'while',    // Only increases indent if not followed by a begin
    'repeat',   // Only increases indent if not followed by a begin
    'forever',  // Only increases indent if not followed by a begin
    'initial',  // Doesn't increase indent itself, but often followed by begin
    'always',   // Doesn't increase indent itself, but often followed by begin
    'always_comb',
    'always_ff',
    'always_latch',
];

module.exports = {
    indentIncreaseKeywords,
    indentDecreaseKeywords,
    indentBothKeywords,
    specialKeywords
};