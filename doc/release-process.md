Release Process
====================

* update translations (ping wumpus, Diapolo or tcatm on IRC)
* see https://github.com/carbonemissiontradecoin/carbonemissiontradecoin/blob/master/doc/translation_process.md#syncing-with-transifex

* * *

###update (commit) version in sources


	carbonemissiontradecoin-qt.pro
	contrib/verifysfbinaries/verify.sh
	doc/README*
	share/setup.nsi
	src/clientversion.h (change CLIENT_VERSION_IS_RELEASE to true)

###tag version in git

	git tag -a v(new version, e.g. 0.8.0)

###write release notes. git shortlog helps a lot, for example:

	git shortlog --no-merges v(current version, e.g. 0.7.2)..v(new version, e.g. 0.8.0)

* * *

##perform gitian builds

 From a directory containing the carbonemissiontradecoin source, gitian-builder and gitian.sigs
  
	export SIGNER=(your gitian key, ie bluematt, sipa, etc)
	export VERSION=(new version, e.g. 0.8.0)
	cd ./gitian-builder

 Fetch and build inputs: (first time, or when dependency versions change)

	mkdir -p inputs; cd inputs/
	wget 'http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.6.tar.gz' -O miniupnpc-1.6.tar.gz
	wget 'http://www.openssl.org/source/openssl-1.0.1c.tar.gz'
	wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
	wget 'http://zlib.net/zlib-1.2.6.tar.gz'
	wget 'ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.5.9.tar.gz'
	wget 'http://fukuchi.org/works/qrencode/qrencode-3.2.0.tar.bz2'
	wget 'http://downloads.sourceforge.net/project/boost/boost/1.50.0/boost_1_50_0.tar.bz2'
	wget 'http://releases.qt-project.org/qt4/source/qt-everywhere-opensource-src-4.8.3.tar.gz'
	cd ..
	./bin/gbuild ../carbonemissiontradecoin/contrib/gitian-descriptors/boost-win32.yml
	mv build/out/boost-win32-1.50.0-gitian2.zip inputs/
	./bin/gbuild ../carbonemissiontradecoin/contrib/gitian-descriptors/qt-win32.yml
	mv build/out/qt-win32-4.8.3-gitian-r1.zip inputs/
	./bin/gbuild ../carbonemissiontradecoin/contrib/gitian-descriptors/deps-win32.yml
	mv build/out/carbonemissiontradecoin-deps-0.0.5.zip inputs/

 Build carbonemissiontradecoind and carbonemissiontradecoin-qt on Linux32, Linux64, and Win32:
  
	./bin/gbuild --commit carbonemissiontradecoin=v${VERSION} ../carbonemissiontradecoin/contrib/gitian-descriptors/gitian.yml
	./bin/gsign --signer $SIGNER --release ${VERSION} --destination ../gitian.sigs/ ../carbonemissiontradecoin/contrib/gitian-descriptors/gitian.yml
	pushd build/out
	zip -r carbonemissiontradecoin-${VERSION}-linux-gitian.zip *
	mv carbonemissiontradecoin-${VERSION}-linux-gitian.zip ../../
	popd
	./bin/gbuild --commit carbonemissiontradecoin=v${VERSION} ../carbonemissiontradecoin/contrib/gitian-descriptors/gitian-win32.yml
	./bin/gsign --signer $SIGNER --release ${VERSION}-win32 --destination ../gitian.sigs/ ../carbonemissiontradecoin/contrib/gitian-descriptors/gitian-win32.yml
	pushd build/out
	zip -r carbonemissiontradecoin-${VERSION}-win32-gitian.zip *
	mv carbonemissiontradecoin-${VERSION}-win32-gitian.zip ../../
	popd

  Build output expected:

  1. linux 32-bit and 64-bit binaries + source (carbonemissiontradecoin-${VERSION}-linux-gitian.zip)
  2. windows 32-bit binary, installer + source (carbonemissiontradecoin-${VERSION}-win32-gitian.zip)
  3. Gitian signatures (in gitian.sigs/${VERSION}[-win32]/(your gitian key)/

repackage gitian builds for release as stand-alone zip/tar/installer exe

**Linux .tar.gz:**

	unzip carbonemissiontradecoin-${VERSION}-linux-gitian.zip -d carbonemissiontradecoin-${VERSION}-linux
	tar czvf carbonemissiontradecoin-${VERSION}-linux.tar.gz carbonemissiontradecoin-${VERSION}-linux
	rm -rf carbonemissiontradecoin-${VERSION}-linux

**Windows .zip and setup.exe:**

	unzip carbonemissiontradecoin-${VERSION}-win32-gitian.zip -d carbonemissiontradecoin-${VERSION}-win32
	mv carbonemissiontradecoin-${VERSION}-win32/carbonemissiontradecoin-*-setup.exe .
	zip -r carbonemissiontradecoin-${VERSION}-win32.zip carbonemissiontradecoin-${VERSION}-win32
	rm -rf carbonemissiontradecoin-${VERSION}-win32

**Perform Mac build:**

  OSX binaries are created by Gavin Andresen on a 32-bit, OSX 10.6 machine.

	qmake RELEASE=1 USE_UPNP=1 USE_QRCODE=1 carbonemissiontradecoin-qt.pro
	make
	export QTDIR=/opt/local/share/qt4  # needed to find translations/qt_*.qm files
	T=$(contrib/qt_translations.py $QTDIR/translations src/qt/locale)
	python2.7 share/qt/clean_mac_info_plist.py
	python2.7 contrib/macdeploy/macdeployqtplus Carbonemissiontradecoin-Qt.app -add-qt-tr $T -dmg -fancy contrib/macdeploy/fancy.plist

 Build output expected: Carbonemissiontradecoin-Qt.dmg

###Next steps:

* Code-sign Windows -setup.exe (in a Windows virtual machine) and
  OSX Carbonemissiontradecoin-Qt.app (Note: only Gavin has the code-signing keys currently)

* upload builds to SourceForge

* create SHA256SUMS for builds, and PGP-sign it

* update carbonemissiontradecoin.org version
  make sure all OS download links go to the right versions

* update forum version

* update wiki download links

* update wiki changelog: [https://en.carbonemissiontradecoin.it/wiki/Changelog](https://en.carbonemissiontradecoin.it/wiki/Changelog)

Commit your signature to gitian.sigs:

	pushd gitian.sigs
	git add ${VERSION}/${SIGNER}
	git add ${VERSION}-win32/${SIGNER}
	git commit -a
	git push  # Assuming you can push to the gitian.sigs tree
	popd

-------------------------------------------------------------------------

### After 3 or more people have gitian-built, repackage gitian-signed zips:

From a directory containing carbonemissiontradecoin source, gitian.sigs and gitian zips

	export VERSION=(new version, e.g. 0.8.0)
	mkdir carbonemissiontradecoin-${VERSION}-linux-gitian
	pushd carbonemissiontradecoin-${VERSION}-linux-gitian
	unzip ../carbonemissiontradecoin-${VERSION}-linux-gitian.zip
	mkdir gitian
	cp ../carbonemissiontradecoin/contrib/gitian-downloader/*.pgp ./gitian/
	for signer in $(ls ../gitian.sigs/${VERSION}/); do
	 cp ../gitian.sigs/${VERSION}/${signer}/carbonemissiontradecoin-build.assert ./gitian/${signer}-build.assert
	 cp ../gitian.sigs/${VERSION}/${signer}/carbonemissiontradecoin-build.assert.sig ./gitian/${signer}-build.assert.sig
	done
	zip -r carbonemissiontradecoin-${VERSION}-linux-gitian.zip *
	cp carbonemissiontradecoin-${VERSION}-linux-gitian.zip ../
	popd
	mkdir carbonemissiontradecoin-${VERSION}-win32-gitian
	pushd carbonemissiontradecoin-${VERSION}-win32-gitian
	unzip ../carbonemissiontradecoin-${VERSION}-win32-gitian.zip
	mkdir gitian
	cp ../carbonemissiontradecoin/contrib/gitian-downloader/*.pgp ./gitian/
	for signer in $(ls ../gitian.sigs/${VERSION}-win32/); do
	 cp ../gitian.sigs/${VERSION}-win32/${signer}/carbonemissiontradecoin-build.assert ./gitian/${signer}-build.assert
	 cp ../gitian.sigs/${VERSION}-win32/${signer}/carbonemissiontradecoin-build.assert.sig ./gitian/${signer}-build.assert.sig
	done
	zip -r carbonemissiontradecoin-${VERSION}-win32-gitian.zip *
	cp carbonemissiontradecoin-${VERSION}-win32-gitian.zip ../
	popd

- Upload gitian zips to SourceForge
- Celebrate 