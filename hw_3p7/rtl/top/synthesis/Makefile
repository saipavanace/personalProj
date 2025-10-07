# DC SYNTHESIS MAKEFILE

all: <%=obj.projectName%>.ddc

<%=obj.projectName%>.ddc:
	dc_shell-t -f <%=obj.projectName%>.tcl |& tee synthesis.log

<% obj.NocStructures.forEach(function (struct) { %>../<%=struct%>/noc/optl.ddc:
	cd ../<%=struct%>/noc/; dc_shell-t -f optl.tcl |& tee synthesis.log

<% }); %>

