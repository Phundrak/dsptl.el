EMACS ?= emacs
EASK ?= eask

.PHONY: clean package install compile test checkdoc lint

# CI entry point
ci: clean package install compile
#ci: clean package install compile checkdoc lint test

package:
	@echo "Packaging..."
	$(EASK) package

install:
	@echo "Installing..."
	$(EASK) install

compile:
	@echo "Compiling..."
	$(EASK) compile

checkdoc:
	@echo "Checking documentation..."
	$(EASK) lint checkdoc --strict

lint:
	@echo "Linting..."
	$(EASK) lint package

clean:
	$(EASK) clean-all
