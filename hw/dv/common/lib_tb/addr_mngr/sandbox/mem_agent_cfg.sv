

// This is the object to configure address manager
// Description: TBD
// Author: Sai Pavan Yaraguti

class mem_agent_cfg extends uvm_object;
    `uvm_object_utils(mem_agent_cfg)

    // Per-chiplet declarations
    // Arrays sized at runtime to num_chiplets
    dii_unit_t         dii_units              [2][$] =  '{
                                                                                    
                                                                                        '{'{4}}
                                                                                        
                                                                                    
                                                                                    
                                                                                        ,
                                                                                    
                                                                                
                                                                                    
                                                                                        '{'{4}}
                                                                                        
                                                                                    
                                                                                    
                                                                                
                                                                                };

    dmi_unit_t         dmi_units              [2][$] =  '{
                                                                                    
                                                                                        '{'{3, 0}}
                                                                                        
                                                                                    
                                                                                    
                                                                                        ,
                                                                                    
                                                                                
                                                                                    
                                                                                        '{'{3, 0}}
                                                                                        
                                                                                    
                                                                                    
                                                                                
                                                                                };
    int unsigned       num_dii_per_chiplet    [2] = '{
                                                                                2
                                                                                ,
                                                                            
                                                                                2
                                                                                
                                                                            };
    int unsigned       num_dmi_per_chiplet    [2] = '{
                                                                                1
                                                                                ,
                                                                            
                                                                                1
                                                                                
                                                                            };
                                                                             // FIXME: Below code assumes that we have only 1 DMI interleaving group. This needs to be updated
    int unsigned       num_igs_per_chiplet    [2] = '{
                                                                                1
                                                                                ,
                                                                            
                                                                                1
                                                                                
                                                                            };
    int unsigned       num_gpras_per_chiplet  [2] = '{
                                                                                3
                                                                                ,
                                                                            
                                                                                3
                                                                                
                                                                            };

    // Policy: probability (0..100) to choose REMOTE for leftover regions
    int unsigned       remote_probability_pct [2] = '{50, 50};

    // Fabric connectivity
    link_t             fabric_links[1] = '{
                                                                  '{from_chiplet_id: 0, to_chiplet_id: 1, from_giu_id: 0, to_giu_id: 0}
                                                                  
                                                                
                                                              };

    bit enable_custom_memregions = 0;
    bit enable_external_memregions = 0;

    extern function new(string name = "mem_agent_cfg");

endclass: mem_agent_cfg

function mem_agent_cfg::new(string name = "mem_agent_cfg");
    super.new(name);
endfunction: new
