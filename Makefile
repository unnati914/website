DOCKER_IMG = klakegg/hugo:ext-alpine
DRAFT_ARGS = --buildDrafts --buildFuture  --buildExpired

# Keep these consistent with the values in config.yaml and layouts/index.redirects:
NEXTv=v3.5
LATESTv=v3.5

HTMLTEST_DIR=tmp
HTMLTEST?=htmltest # Specify as make arg if different
# Use $(HTMLTEST) in PATH, if available; otherwise, we'll get a copy
ifeq (, $(shell which $(HTMLTEST)))
GET_LINK_CHECKER_IF_NEEDED=get-link-checker
override HTMLTEST=$(HTMLTEST_DIR)/bin/htmltest
endif

check-internal-links: clean-htmltest-dir link-check-prep
	$(HTMLTEST)

check-all-links: clean-htmltest-dir link-check-prep
	$(HTMLTEST) --conf .htmltest.external.yml

docker-serve:
	docker run --rm -it -v $(PWD):/src -p 1313:1313 $(DOCKER_IMG) server $(DRAFT_ARGS)

clean-htmltest-dir:
	rm -Rf $(HTMLTEST_DIR)

get-link-checker:
	curl https://htmltest.wjdp.uk | bash -s -- -b $(HTMLTEST_DIR)/bin

link-check-prep: $(GET_LINK_CHECKER_IF_NEEDED)
	mkdir -p $(HTMLTEST_DIR)
	rm -Rf $(HTMLTEST_DIR)/public
	cp -R public/ $(HTMLTEST_DIR)/public && \
	( \
		cd $(HTMLTEST_DIR)/public/docs; \
		ln -s $(NEXTv) next; \
		ln -s $(LATESTv) latest; \
	)
