COFFEE = coffee --compile
COFFEECUP = coffeecup
ODIR = build
LIB = lib

all :
#html
	@$(COFFEECUP) --format --output $(ODIR)/ index.coffee
#js
	@$(COFFEE) --output $(ODIR) ./
	@rm $(ODIR)/index.js 
#lib
	@cp -r $(LIB)/* $(ODIR)/$(LIB)/


clean :
	@rm -rf $(ODIR)/*
	@mkdir $(ODIR)/$(LIB)

libraries :
	@rm -rf $(LIB)/*
	@wget https://raw.githubusercontent.com/jeremyfa/yaml.js/master/bin/yaml.js -O $(LIB)/yaml.js
