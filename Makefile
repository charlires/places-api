export PROJECT_NAME=app
export PROJECT_ROOT=$(shell pwd)
export GOPATH=$(PROJECT_ROOT)
GLIDE_BIN = $(PROJECT_ROOT)/build/glide
BIN_NAME = $(PROJECT_NAME)
GOLIST = $(shell GOPATH=$(GOPATH) go list ./... 2> /dev/null | grep -v vendor \
		 | grep -v golang | grep -v gopkg | grep -v github | sed -n '1!p')
PKG = $(PROJECT_NAME)
BUILD_SHA = $(shell git rev-parse --verify HEAD)
LDFLAGS = "-X main.buildSha='$(BUILD_SHA)'"

clean:
	@echo '::clean'
	@rm -rf bin pkg package coverage

init: clean
	@echo '::init';
	@mkdir $(PROJECT_ROOT)/bin;

build: init
	@echo '::build';
	cd $(PROJECT_ROOT)/src/$(PROJECT_NAME) && go build -o $(PROJECT_ROOT)/bin/$(BIN_NAME) -ldflags=$(LDFLAGS) $(BIN_NAME);

glide/clean:
	@echo '::glide/clean';
	@rm -rf $(GLIDE_BIN);

glide/setup: glide/clean
	@echo '::glide/setup';
	@cd $(PROJECT_ROOT)/build && bash glide_setup.sh;

deps: glide/setup
	@echo '::deps';
	cd $(PROJECT_ROOT)/src/$(PROJECT_NAME) && GIT_SSL_NO_VERIFY=1 $(PROJECT_ROOT)/build/glide install;

run: deps build
	@echo '::run'
	@$(PROJECT_ROOT)/bin/$(BIN_NAME) --config=dev_config;

vendor/clean:
	@echo '::vendor/clean';
	@rm -rf $(PROJECT_ROOT)/src/$(PROJECT_NAME)/vendor;

test/unit:
	@echo '::test/unit';
	@cd $(PROJECT_ROOT)/src/$(PROJECT_NAME) && go test -run=Unit -timeout=10s $(GOLIST) || exit 1;

test: vendor/clean deps test/unit

# glide/get: glide/setup
# 	@echo '::glide/get-$(GLIDE_PKG)';
# 	cd $(PROJECT_ROOT)/src/$(PROJECT_NAME) && $(GLIDE_BIN) get $(GLIDE_PKG);

# glide/update: glide/setup
# 	@echo '::glide/update';
# 	cd $(PROJECT_ROOT)/src/$(PROJECT_NAME) && $(GLIDE_BIN) update --all-dependencies;

# glide/install: glide/setup
# 	@echo '::glide/install';
# 	cd $(PROJECT_ROOT)/src/$(PROJECT_NAME) && $(GLIDE_BIN) install;
