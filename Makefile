SHELL=/bin/bash -o pipefail

all: index.bs
	bikeshed spec index.bs index.html
