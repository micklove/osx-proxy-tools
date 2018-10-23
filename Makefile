.PHONY: test proxy location

#TEST_URI:=www.google.com
TEST_URI?="https://myaccount.in.telstra.com.au/pwreset/pwd_account_status.asp"
# or https://myaccount.in.telstra.com.au/pwreset/pwd_account_status.asp

test: ## Ensure that the terminal has been setup up with the correct proxy details eg make TEST_URI="https://www.google.com"
	@echo "Testing Proxy with $(TEST_URI)"
	@printf "\n ** nb: ensure you run \"proxyenv\" to set proxy env variables **\n\n"
	scutil -r $(TEST_URI)
	@echo ""
	-curl -Is $(TEST_URI) | grep HTTP


# TODO Add run-vpn, run-location, etc...

proxy: ## create proxy config (if it doesn't exist)
	./run-proxy.sh telstra-proxy-config.json

location: ## switch location e.g. make location LOCATION="home"
	./run-location.sh telstra-proxy-config.json $$LOCATION

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

