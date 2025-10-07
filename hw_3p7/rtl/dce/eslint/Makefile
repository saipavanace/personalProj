WORK_TOP = ../../../..
BLOCK_TOP = ../..

help:
	@echo ""
	@echo "SYNTAX: make [tool] NAME=[name]"
	@echo ""
	@echo "Perform eslint on every file in the /src directory"
	@echo "Output directory will be created at eslint.[name]"
	@echo ""
	@echo "[tool]"
	@echo "eslint - run ESLint"
	@echo ""
	@echo "Example:"
	@echo "make eslint NAME=eslint"
	@echo ""

clean:
	@rm -rf eslint.*

create:
ifneq ("$(wildcard eslint.${NAME})", "")
	@echo "Directory eslint.${NAME} already existed"
else
	@mkdir eslint.${NAME}
endif

eslint:
	@make create NAME=${NAME}
	@cd eslint.${NAME}; ${WORK_TOP}/node_modules/eslint/bin/eslint.js -c ${BLOCK_TOP}/eslint/scripts/eslint.json ${BLOCK_TOP}/src/*.js | tee eslint.log
