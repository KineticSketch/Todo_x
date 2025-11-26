generate-app-icons:
	@echo "生成应用图标..."
	@echo "详情: https://pub.dev/packages/flutter_launcher_icons#2-run-the-package"
	dart run flutter_launcher_icons
	@echo "生成完成"

generate-name:
	@echo "生成应用名"
	dart run names_launcher:change
	@echo "生成完成"

build-apk:
	flutter build apk --release --no-tree-shake-icons

build-all-apk:
	flutter build apk --split-per-abi --release --no-tree-shake-icons
	
build-android:
	make build-apk
	make build-all-apk