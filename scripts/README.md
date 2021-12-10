# Scripts

This folder contains scripts for generating static websites out of the API definitions.

### dl-swagger

This script retrieves all API definitions from the specified API gateway and stores them in the `swagger-definitions` folder. This needs to be executed in order to update the definitions that are displayed in the documentation.

### local-api-generation

 You can use this script to test the generated API definition on your local system - make sure [widdershins][widdershins] and [Slate][slate] is installed. After it completes you can [run the MKDocs][../public-documentation#run-mkdocs] and see the generated APIs.

### github-action-*

These scripts are used by GitHub Actions to generate the documentation.
 
[widdershins]: https://github.com/mermade/widdershins
[slate]: https://github.com/slatedocs/slate