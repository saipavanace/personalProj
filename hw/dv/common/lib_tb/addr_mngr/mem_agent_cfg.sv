<%
const chipletObj = obj.lib.getAllChipletRefs();
const chipletInstances = obj.lib.getAllChipletInstanceNames();
%>
// This is the object to configure address manager
// Description: TBD
// Author: Sai Pavan Yaraguti

class mem_agent_cfg extends uvm_object;
    `uvm_object_utils(mem_agent_cfg)

    // Per-chiplet declarations
    // Arrays sized at runtime to num_chiplets
    dii_unit_t         dii_units              [<%=chipletInstances.length%>][$] =  '{
                                                                                <%for(let i=0; i< chipletInstances.length; i+=1){%>
                                                                                   '{
                                                                                    <%for(let j=0; j<chipletObj[i].system.nDiis-1; j+=1){%>
                                                                                        '{<%=chipletObj[i].DiiInfo[j].FUnitId%>}
                                                                                        <% if (j < chipletObj[i].system.nDiis -2) { %>,<% } %>
                                                                                        <%}%>
                                                                                        }
                                                                                        <% if (i < chipletInstances.length - 1) { %>,<% } %>
                                                                                        <%}%>
                                                                                 };

    dmi_unit_t         dmi_units              [<%=chipletInstances.length%>][$] =  '{
                                                                                <%for(let i=0; i< chipletInstances.length; i+=1){%>
                                                                                   '{
                                                                                    <%for(let j=0; j<chipletObj[i].system.nDmis; j+=1){%>
                                                                                        '{<%=chipletObj[i].DmiInfo[j].FUnitId%>, 0}
                                                                                        <% if (j < chipletObj[i].system.nDmis - 1) { %>,<% } %>
                                                                                        <%}%>
                                                                                        }
                                                                                        <% if (i < chipletInstances.length - 1) { %>,<% } %>
                                                                                        <%}%>
                                                                                 };

    int unsigned       num_dii_per_chiplet    [<%=chipletInstances.length%>] = '{<%for(let i=0; i<chipletInstances.length; i+=1){%>
                                                                                <%=chipletObj[i].system.nDiis%>
                                                                                <%if(i<chipletInstances.length-1){%>,<%}%>
                                                                            <%}%>};
    int unsigned       num_dmi_per_chiplet    [<%=chipletInstances.length%>] = '{<%for(let i=0; i<chipletInstances.length; i+=1){%>
                                                                                <%=chipletObj[i].system.nDmis%>
                                                                                <%if(i<chipletInstances.length-1){%>,<%}%>
                                                                            <%}%>};
                                                                             // FIXME: Below code assumes that we have only 1 DMI interleaving group. This needs to be updated
    int unsigned       num_igs_per_chiplet    [<%=chipletInstances.length%>] = '{<%for(let i=0; i<chipletInstances.length; i+=1){%>
                                                                                1
                                                                                <%if(i<chipletInstances.length-1){%>,<%}%>
                                                                            <%}%>};
    int unsigned       num_gpras_per_chiplet  [<%=chipletInstances.length%>] = '{<%for(let i=0; i<chipletInstances.length; i+=1){%>
                                                                                <%=chipletObj[i].system.nGPWindows%>
                                                                                <%if(i<chipletInstances.length-1){%>,<%}%>
                                                                            <%}%>};

    // Policy: probability (0..100) to choose REMOTE for leftover regions
    int unsigned remote_probability_pct [<%= chipletInstances.length %>] = '{
                                                                            <% for (let i = 0; i < chipletInstances.length; i++) { %>
                                                                                50<% if (i < chipletInstances.length - 1) { %>, <% } %>
                                                                            <% } %>
                                                                            };

    // Fabric connectivity
    <%if(obj.links.length > 0){%>
        link_t  fabric_links[<%=obj.links.length%>] = '{<%for(let i=0; i<obj.links.length; i+=1){%>
                                                            '{from_chiplet_id: <%=obj.links[i].from_chiplet_id%>, to_chiplet_id: <%=obj.links[i].to_chiplet_id%>, from_giu_id: <%=obj.links[i].from_giu_id%>, to_giu_id: <%=obj.links[i].to_giu_id%>}
                                                            <%if(i < obj.links.length-1){%>
                                                            ,
                                                            <%}%>
                                                        <%}%>
                                                        };
    <%}%>

    bit enable_custom_memregions = 0;
    bit enable_external_memregions = 0;

    extern function new(string name = "mem_agent_cfg");

endclass: mem_agent_cfg

function mem_agent_cfg::new(string name = "mem_agent_cfg");
    super.new(name);
endfunction: new
