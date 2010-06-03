DEPS  = footer.haml header.haml menu.haml
PAGES = index.html start.html news.html contact.html downloads.html hardware.html

%.html: %.haml $(DEPS)
	haml $< $@

pages: $(PAGES)
