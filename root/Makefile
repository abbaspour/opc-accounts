main: bundle

bundle: sample/*
	@tar -zcf bundle.tar.gz sample
	@echo "content:"
	@tar -ztvf bundle.tar.gz

publish: bundle
	cp ./bundle.tar.gz ../modules/account
