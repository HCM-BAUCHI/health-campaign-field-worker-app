./tools/get_dependencies.sh

dir=$(PWD)

for i in / /packages/forms_engine/ /packages/digit_components/; do
  cd "$dir$i" || exit
  fvm flutter packages run build_runner build --delete-conflicting-outputs
done