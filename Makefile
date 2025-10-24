.PHONY: ping \
	syntax-check \

ANSIBLE_OPTS ?= --ask-become-pass

ENV ?= stage
INVENTORIES := -i stage.yaml
ifeq ($(ENV), prod)
	INVENTORIES := -i production.yaml
else ifeq ($(ENV), all)
	INVENTORIES += -i production.yaml
endif

ping:
	ansible k3s_node -m ping $(INVENTORIES)
	
syntax:
	ansible-playbook --syntax-check playbook/*.yml

%: playbook/%.yml
	ansible-playbook $(ANSIBLE_OPTS) $< $(INVENTORIES)
