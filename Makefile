INSTALL_PATH = /usr/local/bin/swiftusing

build:
	swift package update
	swift build -c release -Xswiftc -static-stdlib

install: build
	cp -f .build/release/swiftusing $(INSTALL_PATH)

clean:
	rm -rf .build

uninstall:
	rm -f $(INSTALL_PATH)

xcode:
	swift package generate-xcodeproj
	xed .
