help:
	@echo ""
	@echo "SYNTAX: make [tool] NAME=[name] APF=[apf] JSON=[json]"
	@echo ""
	@echo "Run parameter validation on source [apf] against"
	@echo "generated [json] file"
	@echo "Output directory will be created at parameter_validation.[name]"
	@echo ""
	@echo "[tool]"
	@echo "parameter_validation - run parameter validation"
	@echo ""
	@echo "Example:"
	@echo "make parameter_validation NAME=dmi_config1_v3 APF=../../../../../test_projects/achlProjects/dmi_config1_v3.apf JSON=../../../../debug/dmi/dmi_config1_v3/dmi_config1_v3AchlParams.json"
	@echo ""

clean:
	@rm -rf parameter_validation.*
	@rm -rf reg_run.log testlist

create:
ifneq ("$(wildcard parameter_validation.${NAME})", "")
	@echo "Directory parameter_validation.${NAME} already existed"
else
	@mkdir parameter_validation.${NAME}
endif

parameter_validation:
	@make create NAME=${NAME}
	@cd parameter_validation.${NAME}; node ${WORK_TOP}/dv/scripts/apf2achl.js ${APF} > expect.json
	@cd parameter_validation.${NAME}; cat expect.json | sed '/generateRtl/q' | sed '/env/q' > expect_int.json
	@cd parameter_validation.${NAME}; cat ${JSON} | sed '/generateRtl/q' | sed '/env/q' > actual_int.json
	@cd parameter_validation.${NAME}; sort expect_int.json | sed "s/,//g" | sed "/]/d" | sed "/env/d" | sed "/strProjectName/d" | sed "/fn*Select/d" | sed "/mainRegime/d" | sed "/useMemHints/d" | sed "/nUpdInFlight/d" > sort_expect.json
	@cd parameter_validation.${NAME}; sort actual_int.json | sed "s/,//g" | sed "/]/d" | sed "/env/d" | sed "/strProjectName/d" | sed "/fn*Select/d" | sed "/mainRegime/d" | sed "/useMemHints/d" | sed "/nUpdInFlight/d" | sed "/clockPort/d" | sed "/resetPort/d" > sort_actual.json
	@cd parameter_validation.${NAME}; diff sort_expect.json sort_actual.json -y > parameter_validation.log; grep -e ">" -e "<" -e "|" parameter_validation.log | wc -l > difference_count.log

