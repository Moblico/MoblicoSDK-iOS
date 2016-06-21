#appledoc Xcode script  
# Start constants  
company="Moblico";  
companyID="com.moblio";
companyURL="http://moblio.com";
target="iphoneos";
#target="macosx";
outputPath="~/Moblico/Documentation/MoblicoSDK";
# End constants
/usr/local/bin/appledoc \
--project-name "${PROJECT_NAME}" \
--project-company "${company}" \
--company-id "${companyID}" \
--docset-atom-filename "${company}.atom" \
--docset-feed-url "${companyURL}/${company}/%DOCSETATOMFILENAME" \
--docset-package-url "${companyURL}/${company}/%DOCSETPACKAGEFILENAME" \
--docset-fallback-url "${companyURL}/${company}" \
--output "${outputPath}" \
--publish-docset \
--docset-platform-family "${target}" \
--logformat xcode \
--keep-intermediate-files \
--no-repeat-first-par \
--no-warn-invalid-crossref \
--exit-threshold 2 \
--no-install-docset \
--keep-undocumented-objects \
--keep-undocumented-members \
--merge-categories \
--include "${PROJECT_DIR}/doc_files/images/" \
--include "${PROJECT_DIR}/doc_files/examples/" \
--index-desc "${PROJECT_DIR}/readme.markdown" \
"${PROJECT_DIR}/../build/MoblicoSDK.framework/Headers"
