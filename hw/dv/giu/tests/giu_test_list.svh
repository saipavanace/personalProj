<% if(obj.useResiliency) { %>
  /*
   *demoter class used for the Resiliency feature testing
   *to demote any error occur due to UECC generation
   */
  `include "report_catcher_demoter_base.sv"
<% } %>
`include "giu_base_test.svh"
`include "giu_bringup_test.svh"
`include "giu_ral_test.svh"
