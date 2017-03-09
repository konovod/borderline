# copy resources
cp ../assets/* ../borderline.app/Contents/Resources/
# make Info.plist and copy icon
cp -f borderline_macosx.plist ../borderline.app/Contents/Info.plist
cp ../borderline.icns ../borderline.app/Contents/Resources/borderline.icns