# copy resources
cp ../assets/* ../booo.app/Contents/Resources/
# make Info.plist and copy icon
cp -f booo_macosx.plist ../booo.app/Contents/Info.plist
cp ../booo.icns ../booo.app/Contents/Resources/booo.icns