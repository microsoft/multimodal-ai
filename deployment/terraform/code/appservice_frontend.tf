resource "null_resource" "npm_build" {
  provisioner "local-exec" {
    command = "cd ../../../azure-search-openai-demo/app/frontend; npm install;  npm audit fix --force; npm run build"
  }
}
