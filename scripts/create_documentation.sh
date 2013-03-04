/usr/local/bin/appledoc \
--project-name "MoblicoSDK" \
--project-company "Moblico" \
--company-id "com.moblio" \
--output "~/Moblico/Documentation/MoblicoSDK" \
--logformat xcode \
--keep-undocumented-objects \
--keep-undocumented-members \
--keep-intermediate-files \
--include "${PROJECT_DIR}/doc_files/images/" \
--include "${PROJECT_DIR}/doc_files/examples/" \
--index-desc "${PROJECT_DIR}/readme.markdown" \
--exit-threshold 2 \
"${PROJECT_DIR}/MoblicoSDK.framework/Headers"